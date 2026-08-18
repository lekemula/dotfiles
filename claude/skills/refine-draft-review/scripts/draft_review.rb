#!/usr/bin/env ruby
# frozen_string_literal: true

# Reads and refines the authenticated user's PENDING (draft, unsubmitted) review on a GitHub PR.
# Never submits the review — there is no code path here that sets `event`.
#
# Usage:
#   # 1. Dump the pending review + its inline comments as JSON (for the caller to refine):
#   ruby draft_review.rb fetch --repo OWNER/REPO --pr NUMBER
#
#   # 2. Write the refined bodies back in place:
#   ruby draft_review.rb apply --repo OWNER/REPO --pr NUMBER --comments refined.json \
#     --impression "Generally I like this pattern, some remarks on the new modules."
#
#   # 3. Same, but print what would change and touch nothing:
#   ruby draft_review.rb apply --repo OWNER/REPO --pr NUMBER --comments refined.json --dry-run
#
# `fetch` output shape:
#   {
#     "review": { "id": 123, "node_id": "PRR_...", "body": "...", "state": "PENDING" },
#     "comments": [
#       { "id": 456, "node_id": "PRRC_...", "path": "app/foo.rb", "position": 42,
#         "body": "this shoudl be extraced", "diff_hunk": "@@ ..." }, ...
#     ]
#   }
#   Anchors: a pending comment has only `position` (a diff offset); `line`/`side` stay null until
#   the review is submitted. Read `diff_hunk` to see what it points at.
#
# `--comments` input shape (only comments whose body actually changed need to be listed):
#   [{ "node_id": "PRRC_...", "body": "<refined body>" }, ...]
#   `id` is accepted instead of `node_id` (the script resolves it against the fetched review).
#
# Behavior:
#   - `fetch` exits 3 with a message on stderr if the user has no pending review on the PR.
#   - `apply` edits each listed comment IN PLACE via the GraphQL
#     `updatePullRequestReviewComment` mutation, falling back to REST
#     `PATCH /repos/{repo}/pulls/comments/{id}` if GraphQL rejects it. Comments not listed in
#     the file are left untouched; nothing is ever deleted.
#   - `apply` also tries to (re)write the review-level summary body from --impression, subject
#     to GitHub's "missing body" limitation (see try_update_review_body).
#   - Either way it prints the full post-edit state of the pending review so the caller can
#     report the whole picture, plus a reminder that it is still a draft.

require 'json'
require 'optparse'
require 'open3'

class GhCommandError < StandardError; end

module Gh
  def self.run(*args, input: nil)
    stdout, stderr, status = if input
                               Open3.capture3('gh', *args, stdin_data: input)
                             else
                               Open3.capture3('gh', *args)
                             end
    raise GhCommandError, "gh #{args.join(' ')} failed: #{stderr.strip}" unless status.success?

    stdout
  end

  def self.api(path, method: 'GET', input: nil)
    args = ['api', path]
    args += ['-X', method] if method != 'GET'
    args += ['--input', '-'] if input
    run(*args, input: input)
  end
end

DISCLAIMER = 'These are my own review notes, rewritten by AI for linguistic clarity and manually ' \
             'reviewed before posting.'

Options = Struct.new(:command, :repo, :pr, :comments_path, :impression, :body, :dry_run)

def parse_options
  opts = Options.new
  opts.dry_run = false
  opts.command = ARGV.shift

  OptionParser.new do |o|
    o.banner = 'Usage: draft_review.rb {fetch|apply} --repo OWNER/REPO --pr NUMBER [options]'
    o.on('--repo OWNER/REPO') { |v| opts.repo = v }
    o.on('--pr NUMBER') { |v| opts.pr = v }
    o.on('--comments PATH', 'apply only: JSON array of {node_id|id, body} refinements') do |v|
      opts.comments_path = v
    end
    o.on('--impression TEXT', 'The reviewer\'s own short general-impression note for the review body') do |v|
      opts.impression = v
    end
    o.on('--body TEXT', 'Full override of the review body, including the disclaimer — skips --impression') do |v|
      opts.body = v
    end
    o.on('--dry-run') { opts.dry_run = true }
  end.parse!

  raise ArgumentError, "unknown command #{opts.command.inspect} (expected fetch or apply)" unless
    %w[fetch apply].include?(opts.command)

  %i[repo pr].each do |field|
    raise ArgumentError, "missing required --#{field}" unless opts[field]
  end
  raise ArgumentError, 'apply needs --comments PATH' if opts.command == 'apply' && !opts.comments_path

  opts
end

# First non-blank line of a comment body that falls *outside* any ``` fenced block —
# used as its one-line gist, so a `suggestion` block never masquerades as the note itself.
def comment_gist(body)
  in_fence = false
  body.to_s.lines.map(&:strip).each do |line|
    if line.start_with?('```')
      in_fence = !in_fence
      next
    end
    return line unless in_fence || line.empty?
  end
  ''
end

def summary_body_with_disclaimer(impression)
  "_#{DISCLAIMER}_\n\n#{impression}"
end

def find_pending_review(repo, pr)
  me = JSON.parse(Gh.api('user'))['login']
  reviews = JSON.parse(Gh.api("repos/#{repo}/pulls/#{pr}/reviews"))
  reviews.find { |r| r['state'] == 'PENDING' && r['user']['login'] == me }
end

def review_comments(repo, pr, review_id)
  JSON.parse(Gh.api("repos/#{repo}/pulls/#{pr}/reviews/#{review_id}/comments"))
end

# NOTE: a *pending* review comment carries no `line`/`side` yet — GitHub only resolves those
# when the review is submitted. Until then the only anchor it exposes is `position` /
# `original_position` (an offset into the file's diff, not a file line number), so that's what
# gets reported. Neither can be edited over the API; re-anchoring is a GitHub-UI-only action.
COMMENT_FIELDS = %w[
  id node_id path position original_position line original_line start_line original_start_line side body diff_hunk
].freeze

# Best available anchor label for a comment, pending or submitted.
def comment_anchor(comment)
  line = comment['line'] || comment['original_line']
  return "line #{line}" if line

  position = comment['position'] || comment['original_position']
  position ? "diff position #{position}" : 'unanchored'
end

def fetch(opts)
  review = find_pending_review(opts.repo, opts.pr)
  if review.nil?
    warn "No pending (draft) review by you on #{opts.repo}##{opts.pr} — nothing to refine."
    exit 3
  end

  comments = review_comments(opts.repo, opts.pr, review['id']).map do |comment|
    comment.slice(*COMMENT_FIELDS)
  end

  puts JSON.pretty_generate(
    'review' => review.slice('id', 'node_id', 'body', 'state', 'commit_id'),
    'comments' => comments
  )
end

UPDATE_COMMENT_MUTATION = <<~GRAPHQL
  mutation($commentId: ID!, $body: String!) {
    updatePullRequestReviewComment(input: {pullRequestReviewCommentId: $commentId, body: $body}) {
      pullRequestReviewComment { id }
    }
  }
GRAPHQL

def update_comment_body(repo, comment, body)
  Gh.run(
    'api', 'graphql',
    '-f', "query=#{UPDATE_COMMENT_MUTATION}",
    '-f', "commentId=#{comment['node_id']}",
    '-f', "body=#{body}"
  )
rescue GhCommandError => e
  warn "  GraphQL edit failed (#{e.message.lines.first.to_s.strip}) — retrying over REST."
  Gh.api(
    "repos/#{repo}/pulls/comments/#{comment['id']}",
    method: 'PATCH',
    input: JSON.generate(body: body)
  )
end

UPDATE_BODY_MUTATION = <<~GRAPHQL
  mutation($reviewId: ID!, $body: String!) {
    updatePullRequestReview(input: {pullRequestReviewId: $reviewId, body: $body}) {
      pullRequestReview { id }
    }
  }
GRAPHQL

# Best-effort: try to (re)write the review-level summary. Returns true on success.
#
# NOTE: GitHub rejects this with "Could not edit a review with a missing body." for any
# pending review whose body is currently empty/unset — confirmed on both this GraphQL
# mutation and the equivalent REST `PUT .../reviews/{id}`. There is no known API workaround;
# a body can only be attached at review-*creation* time, or later by the user themselves via
# the "Finish your review" submit dialog on GitHub. Since a hand-started draft review usually
# has no body typed in yet, expect this to fail and to hand the text back to the user instead.
def try_update_review_body(review_node_id, body)
  Gh.run(
    'api', 'graphql',
    '-f', "query=#{UPDATE_BODY_MUTATION}",
    '-f', "reviewId=#{review_node_id}",
    '-f', "body=#{body}"
  )
  true
rescue GhCommandError => e
  raise unless e.message.include?('missing body')

  false
end

def load_refinements(path)
  refinements = JSON.parse(File.read(path))
  raise ArgumentError, "#{path} must contain a JSON array" unless refinements.is_a?(Array)

  refinements.each do |refinement|
    raise ArgumentError, "refinement missing body: #{refinement.inspect}" unless refinement['body']
    unless refinement['node_id'] || refinement['id']
      raise ArgumentError, "refinement needs node_id or id: #{refinement.inspect}"
    end
  end

  refinements
end

def match_comment(comments, refinement)
  comments.find do |comment|
    (refinement['node_id'] && comment['node_id'] == refinement['node_id']) ||
      (refinement['id'] && comment['id'].to_s == refinement['id'].to_s)
  end
end

def print_state(repo, pr, review_id)
  comments = review_comments(repo, pr, review_id)
  puts "\nPending review ##{review_id} now has #{comments.size} comment(s):"
  comments.each { |c| puts "  #{c['path']} (#{comment_anchor(c)}) — #{comment_gist(c['body'])}" }
end

def apply(opts)
  review = find_pending_review(opts.repo, opts.pr)
  if review.nil?
    warn "No pending (draft) review by you on #{opts.repo}##{opts.pr} — nothing to refine."
    exit 3
  end

  comments = review_comments(opts.repo, opts.pr, review['id'])
  refinements = load_refinements(opts.comments_path)

  pairs = refinements.map do |refinement|
    comment = match_comment(comments, refinement)
    raise ArgumentError, "no pending comment matches #{refinement.slice('node_id', 'id')}" if comment.nil?

    [comment, refinement['body']]
  end

  changed = pairs.reject { |comment, body| comment['body'] == body }

  if opts.dry_run
    puts "Dry run — would rewrite #{changed.size} of #{comments.size} comment(s) on review ##{review['id']}:"
    changed.each { |comment, body| puts "  #{comment['path']} (#{comment_anchor(comment)}) — #{comment_gist(body)}" }
    puts "  (#{pairs.size - changed.size} listed comment(s) already match their refined text)" if
      pairs.size > changed.size
    return
  end

  changed.each do |comment, body|
    puts "Rewriting #{comment['path']} #{comment_anchor(comment)} (##{comment['id']})"
    update_comment_body(opts.repo, comment, body)
  end
  puts 'No comment bodies needed rewriting.' if changed.empty?

  summary_body = opts.body || (opts.impression && summary_body_with_disclaimer(opts.impression))
  if summary_body
    if try_update_review_body(review['node_id'], summary_body)
      puts 'Updated the review summary body.'
    else
      warn "Could not set the review summary — GitHub disallows adding a body to an already-empty\n" \
           "pending review (which is what a hand-started draft usually is). Paste this in yourself\n" \
           "when you open \"Finish your review\" on GitHub:\n\n#{summary_body}\n"
    end
  end

  print_state(opts.repo, opts.pr, review['id'])
  puts "\nStill a DRAFT — open the PR on GitHub and click \"Submit review\" to make it visible to others."
end

def main
  opts = parse_options
  opts.command == 'fetch' ? fetch(opts) : apply(opts)
end

main if $PROGRAM_NAME == __FILE__
