#!/usr/bin/env ruby
# frozen_string_literal: true

# Posts (or appends to) a PENDING/draft GitHub PR review from a JSON comments file.
# Never submits the review — there is no code path here that sets `event`.
#
# Usage:
#   ruby post_review.rb --repo OWNER/REPO --pr NUMBER --commit SHA --comments comments.json \
#     --impression "Generally I like this pattern, some remarks on the new modules and attr_accessors."
#
# The review body is the disclaimer plus --impression verbatim — NOT a listing of the inline
# comments. --impression must be the human reviewer's own words; the caller (the skill driving
# this script) is expected to have asked them for it, not invented it from the diff or notes.
# Pass --body instead to override the whole thing (disclaimer included, if you want one).
#
# comments.json shape:
#   [{ "path": "...", "line": 5, "side": "RIGHT", "body": "..." }, ...]
#   side is "RIGHT" for newRange-anchored notes, "LEFT" for oldRange-anchored ones.
#
# Behavior:
#   - If the authenticated user has no pending review yet on this PR, creates one in a
#     single bulk call with all comments attached.
#   - If a pending review already exists (e.g. started by hand on GitHub, or left over
#     from a previous run), appends each comment to that SAME review via the GraphQL
#     `addPullRequestReviewThread` mutation instead of failing — GitHub's REST review-create
#     endpoints (bulk and single-comment alike) hard-reject any second pending review for a
#     user, so appending is the only way to add to it without disturbing what's already there.
#   - Either way, prints a path/line/body-summary of every comment now on the pending
#     review (not just the ones this run added), so the caller can report the full picture.

require 'json'
require 'optparse'
require 'open3'
require 'tempfile'

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

  def self.graphql(query, **vars)
    args = ['api', 'graphql', '-f', "query=#{query}"]
    vars.each { |k, v| args += ['-f', "#{k}=#{v}"] }
    run(*args)
  end
end

DISCLAIMER = 'These are my own review notes, rewritten by AI for linguistic clarity and manually ' \
             'reviewed before posting.'

Options = Struct.new(:repo, :pr, :commit, :comments_path, :impression, :body, :dry_run)

def parse_options
  opts = Options.new
  opts.dry_run = false

  OptionParser.new do |o|
    o.on('--repo OWNER/REPO') { |v| opts.repo = v }
    o.on('--pr NUMBER') { |v| opts.pr = v }
    o.on('--commit SHA') { |v| opts.commit = v }
    o.on('--comments PATH') { |v| opts.comments_path = v }
    o.on('--impression TEXT', 'The reviewer\'s own short general-impression note for the review body') do |v|
      opts.impression = v
    end
    o.on('--body TEXT', 'Full override of the review body, including the disclaimer — skips --impression') do |v|
      opts.body = v
    end
    o.on('--dry-run') { opts.dry_run = true }
  end.parse!

  %i[repo pr commit comments_path].each do |field|
    raise ArgumentError, "missing required --#{field.to_s.tr('_', '-')}" unless opts[field]
  end

  opts
end

# First non-blank line of a comment body that falls *outside* any ``` fenced block —
# used as its one-line gist. Comments here are quoted-code-then-prose, so the naive
# "skip lines starting with ```" would grab a line of Ruby instead of the actual note.
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

# Builds the review-level summary body: the disclaimer plus the reviewer's OWN short
# general-impression note (never derived from the individual comments — a review body is
# meant to read like "generally I like this, some remarks on X", not a mechanical index of
# every inline comment; the caller must ask the human for that impression and pass it here).
# GitHub only accepts a body at review-creation time (see NOTE on try_update_review_body),
# so this is what ends up as the pending review's top-level comment when creating fresh.
def summary_body_with_disclaimer(impression)
  "_#{DISCLAIMER}_\n\n#{impression}"
end

def load_comments(path)
  comments = JSON.parse(File.read(path))
  raise ArgumentError, "#{path} must contain a JSON array" unless comments.is_a?(Array)

  comments.each do |c|
    %w[path line side body].each do |key|
      raise ArgumentError, "comment missing #{key}: #{c.inspect}" unless c.key?(key)
    end
  end

  comments
end

def find_pending_review(repo, pr, me)
  reviews = JSON.parse(Gh.api("repos/#{repo}/pulls/#{pr}/reviews"))
  reviews.find { |r| r['state'] == 'PENDING' && r['user']['login'] == me }
end

def create_review_with_comments(repo, pr, commit, body, comments)
  payload = { commit_id: commit, body: body, comments: comments }
  Tempfile.create(['review_payload', '.json']) do |f|
    f.write(JSON.generate(payload))
    f.flush
    Gh.api("repos/#{repo}/pulls/#{pr}/reviews", method: 'POST', input: File.read(f.path))
  end
end

APPEND_MUTATION = <<~GRAPHQL
  mutation($reviewId: ID!, $path: String!, $line: Int!, $side: DiffSide!, $body: String!) {
    addPullRequestReviewThread(input: {pullRequestReviewId: $reviewId, path: $path, line: $line, side: $side, body: $body}) {
      thread { id }
    }
  }
GRAPHQL

def append_comment_to_review(review_node_id, comment)
  Gh.run(
    'api', 'graphql',
    '-f', "query=#{APPEND_MUTATION}",
    '-f', "reviewId=#{review_node_id}",
    '-f', "path=#{comment['path']}",
    '-F', "line=#{comment['line']}",
    '-f', "side=#{comment['side']}",
    '-f', "body=#{comment['body']}"
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
# the "Finish your review" submit dialog on GitHub. So: this only actually succeeds when the
# pending review already has *some* non-empty body to overwrite.
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

def print_summary(repo, pr, review_id)
  posted = JSON.parse(Gh.api("repos/#{repo}/pulls/#{pr}/reviews/#{review_id}/comments"))
  puts "\nPending review ##{review_id} now has #{posted.size} comment(s):"
  posted.each { |c| puts "  #{c['path']}:#{c['line']} — #{comment_gist(c['body'])}" }
end

def main
  opts = parse_options
  comments = load_comments(opts.comments_path)

  if opts.dry_run
    puts "Dry run — would post #{comments.size} comment(s) to #{opts.repo}##{opts.pr}:"
    comments.each { |c| puts "  #{c['path']}:#{c['line']}" }
    return
  end

  unless opts.body || opts.impression
    raise ArgumentError, 'pass --impression "..." (the reviewer\'s own general take) or --body to fully override'
  end

  me = JSON.parse(Gh.api('user'))['login']
  pending = find_pending_review(opts.repo, opts.pr, me)
  summary_body = opts.body || summary_body_with_disclaimer(opts.impression)

  if pending
    warn "Existing pending review ##{pending['id']} found — appending #{comments.size} comment(s) to it."
    comments.each { |c| append_comment_to_review(pending['node_id'], c) }
    review_id = pending['id']

    if try_update_review_body(pending['node_id'], summary_body)
      puts 'Updated the review summary body.'
    else
      warn "Could not set the review summary — GitHub disallows adding a body to an already-empty\n" \
           "pending review (this one was likely started by hand with no body). Paste this in yourself\n" \
           "next time you open \"Finish your review\" on GitHub:\n\n#{summary_body}\n"
    end
  else
    result = JSON.parse(create_review_with_comments(opts.repo, opts.pr, opts.commit, summary_body, comments))
    review_id = result['id']
    puts "Created pending review ##{review_id} with #{comments.size} comment(s) and a summary body."
  end

  print_summary(opts.repo, opts.pr, review_id)
  puts "\nStill a DRAFT — open the PR on GitHub and click \"Submit review\" to make it visible to others."
rescue GhCommandError => e
  # A second run racing against itself (or a review opened by hand between our check and our
  # bulk-create call) can still hit GitHub's "one pending review" rule after we've already
  # checked. Fall back to append-by-GraphQL once instead of failing outright.
  if e.message.include?('one pending review')
    warn 'Bulk create hit the one-pending-review limit after all — retrying by appending instead.'
    pending = find_pending_review(opts.repo, opts.pr, me ||= JSON.parse(Gh.api('user'))['login'])
    raise if pending.nil?

    comments.each { |c| append_comment_to_review(pending['node_id'], c) }
    print_summary(opts.repo, opts.pr, pending['id'])
  else
    raise
  end
end

main if $PROGRAM_NAME == __FILE__
