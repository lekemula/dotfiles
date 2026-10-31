#!/usr/bin/env ruby
# frozen_string_literal: true

# Helper for the tmux-cleanup skill. Subcommands:
#   reorder                         move windows into tmux-workspace order
#   merged   [--apply]              worktrees whose PR is merged (--apply removes the safe ones)
#   stale    [--apply]              windows whose worktree is gone (--apply kills them)
#   tickets                         ticket keys of all worktree windows, as JSON
#   group    --map FILE [--apply]   move windows into one session per epic/parent ticket
#   summary                         markdown table of every worktree and its PR
#
# Destructive subcommands are dry-run unless --apply is given.

require 'json'
require 'open3'
require 'optparse'

HOME = Dir.home
WORKSPACE_SCRIPT = File.join(HOME, 'dotfiles/bin/tmux-workspace')
REPO_GLOBS = [File.join(HOME, 'Projects/finlink/*'), File.join(HOME, 'Projects/open_source/*')].freeze
TICKET_RE = /\b([A-Z][A-Z0-9]+-\d+)\b/i.freeze

def sh(*cmd, chdir: nil)
  out, _err, st = Open3.capture3(*cmd, chdir: chdir || Dir.pwd)
  st.success? ? out : nil
end

def tmux(*args) = sh('tmux', *args)

Worktree = Struct.new(:repo, :repo_dir, :path, :branch, :head, keyword_init: true) do
  def name = File.basename(path)
  def ticket = branch[TICKET_RE, 1]&.upcase&.then { _1.end_with?('-000') ? nil : _1 }
end

# Repos come from the usual project dirs plus wherever any pane in any session is sitting,
# so worktrees of repos outside those globs are still found.
def repo_dirs
  from_globs = REPO_GLOBS.flat_map { Dir[_1] }.select { File.exist?(File.join(_1, '.git')) }
  cwds = tmux('list-panes', '-a', '-F', '#{pane_current_path}').to_s.lines.map(&:chomp).uniq.select { Dir.exist?(_1) }
  from_panes = cwds.filter_map do |cwd|
    common = sh('git', 'rev-parse', '--path-format=absolute', '--git-common-dir', chdir: cwd)&.strip
    File.dirname(common) if common&.end_with?('/.git')
  end
  (from_globs + from_panes).uniq
end

# workmux finds a worktree's window by its @workmux_token, but only in the session
# recorded in git config. Re-point that at wherever the window now lives, so
# `workmux remove` closes windows that were moved into another session.
def sync_window_session(wt)
  key = "workmux.worktree.#{wt.name}"
  token = sh('git', 'config', '--get', "#{key}.window-token", chdir: wt.repo_dir)&.strip or return
  windows = tmux('list-windows', '-a', '-F', "\#{@workmux_token}\t\#{session_name}").to_s.lines
  session = windows.map { _1.chomp.split("\t", 2) }.find { _1.first == token }&.last or return
  sh('git', 'config', "#{key}.window-session", session, chdir: wt.repo_dir)
end

# Secondary worktrees only (main checkout excluded).
def worktrees
  repo_dirs.flat_map do |dir|
    out = sh('git', 'worktree', 'list', '--porcelain', chdir: dir) or next []
    out.split("\n\n").filter_map do |block|
      h = block.lines.to_h { |l| k, v = l.chomp.split(' ', 2); [k, v] }
      next if h['worktree'] == dir || !h['branch']

      Worktree.new(repo: File.basename(dir), repo_dir: dir, path: h['worktree'],
                   branch: h['branch'].delete_prefix('refs/heads/'), head: h['HEAD'])
    end
  end
end

def prs_for(wt)
  out = sh('gh', 'pr', 'list', '--head', wt.branch, '--state', 'all', '--json',
           'number,state,url,title,headRefOid,isDraft', chdir: wt.repo_dir)
  out.to_s.empty? ? [] : JSON.parse(out)
end

# Prefer the merged PR, then open, then whatever exists.
def best_pr(prs)
  %w[MERGED OPEN CLOSED].each { |s| (pr = prs.find { _1['state'] == s }) && (return pr) }
  nil
end

# ── reorder ──────────────────────────────────────────────────────────────────
def desired_order
  order = Hash.new { |h, k| h[k] = [] }
  File.foreach(WORKSPACE_SCRIPT) do |line|
    if (m = line.match(/new_session (\S+) (\S+)/))
      order[m[1]] << m[2]
    elsif (m = line.match(/new_window "?(\S+?)"? (\S+)/))
      order[m[1]] << m[2]
    end
  end
  order
end

def reorder
  desired_order.each do |session, names|
    out = tmux('list-windows', '-t', session, '-F', "\#{window_id}\t\#{window_name}") or next
    wins = out.lines.map { _1.chomp.split("\t", 2) }
    first = names.filter_map { |n| wins.find { |_, wn| wn == n } }
    ordered = first + (wins - first)
    ordered.each_with_index { |(id, _), i| tmux('move-window', '-s', id, '-t', "#{session}:#{1000 + i}") }
    tmux('move-window', '-r', '-t', session)
    puts "#{session}: #{first.size} workspace windows first, #{ordered.size - first.size} others after"
  end
end

# ── merged ───────────────────────────────────────────────────────────────────
# Safe = PR merged, clean tree, and every local commit is in the PR head
# (a squash merge leaves the branch "unmerged" to git, so compare to the PR head instead).
def removal_verdict(wt, pr)
  return [:skip, "PR #{pr ? pr['state'].downcase : 'missing'}"] unless pr && pr['state'] == 'MERGED'

  dirty = sh('git', 'status', '--porcelain', chdir: wt.path).to_s.strip
  return [:keep, 'uncommitted changes'] unless dirty.empty?

  pr_head = pr['headRefOid']
  contained = system('git', '-C', wt.path, 'merge-base', '--is-ancestor', wt.head, pr_head,
                     out: File::NULL, err: File::NULL)
  return [:keep, "local commits not in PR head #{pr_head[0, 8]}"] unless contained

  [:remove, "merged #{pr['url']}"]
end

def merged(apply:)
  worktrees.each do |wt|
    verdict, why = removal_verdict(wt, best_pr(prs_for(wt)))
    next if verdict == :skip

    puts "#{verdict.to_s.upcase.ljust(6)} #{wt.repo}/#{wt.name} (#{wt.branch}) — #{why}"
    next unless apply && verdict == :remove

    sync_window_session(wt)
    out, st = Open3.capture2e('workmux', 'remove', '-f', wt.name, chdir: wt.repo_dir)
    puts "       #{st.success? ? 'removed' : "FAILED: #{out.lines.last}"}"
  end
end

# ── stale ────────────────────────────────────────────────────────────────────
# A window is stale when any pane sits in a missing directory, or in a
# *__worktrees/* path git no longer lists (e.g. removed with `git worktree remove`).
def stale(apply:)
  live = repo_dirs.flat_map { |d| sh('git', 'worktree', 'list', '--porcelain', chdir: d).to_s.scan(/^worktree (.+)$/).flatten }
  out = tmux('list-panes', '-a', '-F', "\#{window_id}\t\#{session_name}\t\#{window_name}\t\#{pane_id}\t\#{pane_current_path}") or return
  windows = out.lines.map { _1.chomp.split("\t", 5) }.group_by(&:first)
  windows.each do |id, panes|
    next if panes.any? { |_, _, _, pane, _| pane == ENV['TMUX_PANE'] }

    gone = panes.any? do |_, _, _, _, cwd|
      !Dir.exist?(cwd) || (cwd.include?('__worktrees/') && live.none? { cwd == _1 || cwd.start_with?("#{_1}/") })
    end
    next unless gone

    _, session, name, = panes.first
    puts "STALE #{session}:#{name.strip} (#{panes.first.last})"
    tmux('kill-window', '-t', id) if apply
  end
  puts '(dry run — pass --apply to kill windows)' unless apply
end

# ── tickets / group ──────────────────────────────────────────────────────────
# window_id => worktree, via the pane's working directory.
def window_worktrees
  by_path = worktrees.to_h { [_1.path, _1] }
  out = tmux('list-panes', '-a', '-F', "\#{window_id}\t\#{session_name}\t\#{pane_current_path}") or return {}
  out.lines.each_with_object({}) do |line, acc|
    id, session, cwd = line.chomp.split("\t", 3)
    wt = by_path.keys.find { |p| cwd == p || cwd.start_with?("#{p}/") }
    acc[id] ||= { session: session, wt: by_path[wt] } if wt
  end
end

def tickets
  keys = window_worktrees.values.filter_map { _1[:wt].ticket }.uniq.sort
  puts JSON.pretty_generate(keys)
end

def group(map_file:, apply:)
  map = JSON.parse(File.read(map_file))
  moves = Hash.new { |h, k| h[k] = [] }
  window_worktrees.each do |id, info|
    ticket = info[:wt].ticket or next
    target = map.fetch(ticket, ticket)
    moves[target] << [id, info[:session], info[:wt].name, info[:wt]]
  end

  moves.each do |target, wins|
    next if wins.size < 2 && !map.key?(target) && !map.value?(target)

    puts "#{target}: #{wins.map { _1[2] }.join(', ')}"
    next unless apply

    wins.each do |id, session, _, wt|
      unless session == target
        if tmux('has-session', '-t', target).nil?
          # Seed the session with the first window, so no throwaway shell window is left behind.
          tmux('new-session', '-d', '-s', target, '-c', HOME)
          seed = tmux('list-windows', '-t', target, '-F', '#{window_id}').to_s.strip
          tmux('move-window', '-s', id, '-t', "#{target}:")
          tmux('kill-window', '-t', seed)
        else
          tmux('move-window', '-s', id, '-t', "#{target}:")
        end
      end
      sync_window_session(wt)
    end
    tmux('move-window', '-r', '-t', target)
  end
  puts '(dry run — pass --apply to move windows)' unless apply
end

# ── summary ──────────────────────────────────────────────────────────────────
def summary
  rows = worktrees.map do |wt|
    pr = best_pr(prs_for(wt))
    dirty = !sh('git', 'status', '--porcelain', chdir: wt.path).to_s.strip.empty?
    state = pr ? (pr['isDraft'] && pr['state'] == 'OPEN' ? 'DRAFT' : pr['state']) : 'NO PR'
    [wt.ticket || '-', wt.repo, wt.name, state, pr ? "[##{pr['number']}](#{pr['url']})" : '-', dirty ? 'dirty' : 'clean']
  end
  rows.sort_by! { |r| [r[0], r[1], r[2]] }
  puts '| Ticket | Repo | Worktree | PR state | PR | Tree |'
  puts '|---|---|---|---|---|---|'
  rows.each { puts "| #{_1.join(' | ')} |" }
end

# ── main ─────────────────────────────────────────────────────────────────────
opts = { apply: false }
OptionParser.new do |o|
  o.on('--apply') { opts[:apply] = true }
  o.on('--map FILE') { opts[:map] = _1 }
end.parse!

case ARGV.first
when 'reorder' then reorder
when 'merged'  then merged(apply: opts[:apply])
when 'stale'   then stale(apply: opts[:apply])
when 'tickets' then tickets
when 'group'   then group(map_file: opts[:map] || abort('--map FILE required'), apply: opts[:apply])
when 'summary' then summary
else abort(File.read(__FILE__)[/\A.*?^$/m].gsub(/^# ?/, ''))
end
