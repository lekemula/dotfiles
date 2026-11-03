#!/usr/bin/env ruby
# frozen_string_literal: true

# Helper for the rex-cleanup skill — the Rex counterpart of tmux-cleanup. Subcommands:
#   reorder                         move tabs into rex-workspace order
#   merged   [--done FILE] [--apply] worktrees whose PR is merged or whose Jira ticket is closed
#                                   (--apply removes the safe ones)
#   stale    [--apply]              tabs whose worktree is gone (--apply closes them)
#   tickets  [--all]                ticket keys of all worktree tabs (--all: of every worktree), as JSON
#   group    --map FILE [--apply]   move tabs into one session per epic/parent ticket
#   summary                         markdown table of every worktree and its PR
#
# Destructive subcommands are dry-run unless --apply is given.

require 'json'
require 'open3'
require 'optparse'

HOME = Dir.home
WORKSPACE_SCRIPT = File.join(HOME, 'dotfiles/bin/rex-workspace')
REPO_GLOBS = [File.join(HOME, 'Projects/finlink/*'), File.join(HOME, 'Projects/open_source/*'),
              File.join(HOME, 'Projects/private/*')].freeze
TICKET_RE = /\b([A-Z][A-Z0-9]+-\d+)\b/i.freeze
SHELLS = %w[zsh bash sh fish -zsh -bash].freeze
WORKTREE_ICON = "\u{f418}"

def sh(*cmd, chdir: nil)
  out, _err, st = Open3.capture3(*cmd, chdir: chdir || Dir.pwd)
  st.success? ? out : nil
end

def rex(*args) = sh('rex', *args)

Worktree = Struct.new(:repo, :repo_dir, :path, :branch, :head, keyword_init: true) do
  def name = File.basename(path)
  def ticket = branch[TICKET_RE, 1]&.upcase&.then { _1.end_with?('-000') ? nil : _1 }
  def contains?(dir) = dir == path || dir.start_with?("#{path}/")
end

Pane = Struct.new(:block_id, :program, :cwd, keyword_init: true) do
  def idle? = SHELLS.include?(program)
end

Tab = Struct.new(:session, :window_id, :label, :layout, :panes, keyword_init: true) do
  def own? = ENV['REX_BLOCK'] && panes.any? { _1.block_id == ENV['REX_BLOCK'] }
end

def leaves(node)
  node['split'] ? leaves(node['split']['before']) + leaves(node['split']['after']) : [node['block_id']]
end

# Every tab in every Rex session, with each pane's foreground program and directory.
def tabs
  @tabs ||= rex('ls').to_s.lines.drop(1).map { _1.split.first }.flat_map do |session|
    view = JSON.parse(rex('window', 'ls', '-s', session, '--json') || '{"windows":[]}')
    view['windows'].map do |w|
      layout = w.dig('layers', 0, 'layout')
      panes = (layout ? leaves(layout) : []).compact.map do |b|
        fg = JSON.parse(rex('block', 'call', '-s', session, '-b', b, 'process') || '{}')['foreground'] || {}
        Pane.new(block_id: b, program: fg['name'], cwd: fg['cwd'].to_s)
      end
      Tab.new(session: session, window_id: w['window_id'], label: w['label'], layout: layout, panes: panes)
    end
  end
end

# Repos come from the usual project dirs plus wherever any Rex pane is sitting.
def repo_dirs
  from_globs = REPO_GLOBS.flat_map { Dir[_1] }.select { File.exist?(File.join(_1, '.git')) }
  from_panes = tabs.flat_map { _1.panes.map(&:cwd) }.uniq.select { Dir.exist?(_1) }.filter_map do |cwd|
    common = sh('git', 'rev-parse', '--path-format=absolute', '--git-common-dir', chdir: cwd)&.strip
    File.dirname(common) if common&.end_with?('/.git')
  end
  (from_globs + from_panes).uniq
end

# Secondary worktrees only (main checkout excluded).
def worktrees
  @worktrees ||= repo_dirs.flat_map do |dir|
    out = sh('git', 'worktree', 'list', '--porcelain', chdir: dir) or next []
    out.split("\n\n").filter_map do |block|
      h = block.lines.to_h { |l| k, v = l.chomp.split(' ', 2); [k, v] }
      next if h['worktree'] == dir || !h['branch']

      Worktree.new(repo: File.basename(dir), repo_dir: dir, path: h['worktree'],
                   branch: h['branch'].delete_prefix('refs/heads/'), head: h['HEAD'])
    end
  end
end

# A tab belongs to the worktree most of its panes sit in (shared panes like a
# sidebar shell in another repo don't steal it).
def tab_worktree(tab)
  counts = tab.panes.filter_map { |p| worktrees.find { _1.contains?(p.cwd) } }.tally
  counts.max_by(&:last)&.first
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

# A session left without tabs is killed too.
def close_tab(tab)
  rex('window', 'close', '-s', tab.session, tab.window_id)
  left = JSON.parse(rex('window', 'ls', '-s', tab.session, '--json') || '{}')['windows']
  rex('kill', tab.session) if left&.empty?
end

# ── reorder ──────────────────────────────────────────────────────────────────
def desired_order
  order = Hash.new { |h, k| h[k] = [] }
  File.foreach(WORKSPACE_SCRIPT) do |line|
    m = line.match(/^\s*(?:session_tab|tab) (\S+) (\S+)/) and order[m[1]] << m[2]
  end
  order
end

def reorder
  desired_order.each do |session, names|
    wins = tabs.select { _1.session == session }
    next if wins.empty?

    first = names.filter_map { |n| wins.find { _1.label == n } }
    (first + (wins - first)).each_with_index do |tab, i|
      rex('window', 'move', '-s', session, tab.window_id, '--index', (i + 1).to_s)
    end
    puts "#{session}: #{first.size} workspace tabs first, #{wins.size - first.size} others after"
  end
end

# ── merged ───────────────────────────────────────────────────────────────────
# Refs that exist locally and count as "pushed": the PR head (a squash merge leaves
# the branch "unmerged" to git, so compare to the PR head instead), upstream, default branch.
def pushed_refs(wt, pr)
  [pr && pr['headRefOid'], "#{wt.branch}@{upstream}", 'origin/HEAD'].compact.select do |ref|
    system('git', '-C', wt.path, 'rev-parse', '--verify', '--quiet', "#{ref}^{commit}", out: File::NULL)
  end
end

def pushed?(wt, pr)
  pushed_refs(wt, pr).any? do |ref|
    system('git', '-C', wt.path, 'merge-base', '--is-ancestor', wt.head, ref, out: File::NULL, err: File::NULL)
  end
end

# Safe = clean tree and every local commit pushed. Candidates are worktrees whose PR
# is merged or whose ticket is in `done` (keys closed in Jira as done or won't do).
def removal_verdict(wt, pr, done)
  merged = pr && pr['state'] == 'MERGED'
  ticket_done = wt.ticket && done.include?(wt.ticket)
  return [:skip, "PR #{pr ? pr['state'].downcase : 'missing'}"] unless merged || ticket_done

  dirty = sh('git', 'status', '--porcelain', chdir: wt.path).to_s.strip
  return [:keep, 'uncommitted changes'] unless dirty.empty?
  return [:keep, "local commits not pushed#{pr ? " (PR head #{pr['headRefOid'][0, 8]})" : ''}"] unless pushed?(wt, pr)
  return [:remove, "merged #{pr['url']}"] if merged

  [:remove, "#{wt.ticket} closed in Jira#{pr ? ", PR #{pr['state'].downcase} #{pr['url']}" : ', no PR'}"]
end

# workmux removes the worktree, branch and its (background) tmux window; the Rex
# tabs sitting in the worktree are closed here.
def merged(apply:, done: [])
  worktrees.each do |wt|
    verdict, why = removal_verdict(wt, best_pr(prs_for(wt)), done)
    next if verdict == :skip

    open_tabs = tabs.select { tab_worktree(_1) == wt }
    puts "#{verdict.to_s.upcase.ljust(6)} #{wt.repo}/#{wt.name} (#{wt.branch}) — #{why}" \
         "#{open_tabs.empty? ? '' : " [tabs: #{open_tabs.map { "#{_1.session}:#{_1.label}" }.join(', ')}]"}"
    next unless apply && verdict == :remove

    out, st = Open3.capture2e('workmux', 'remove', '-f', wt.name, chdir: wt.repo_dir)
    open_tabs.reject(&:own?).each { close_tab(_1) } if st.success?
    puts "       #{st.success? ? "removed, closed #{open_tabs.reject(&:own?).size} tab(s)" : "FAILED: #{out.lines.last}"}"
  end
end

# ── stale ────────────────────────────────────────────────────────────────────
# A tab is stale when any pane sits in a missing directory, or in a
# *__worktrees/* path git no longer lists (e.g. removed with `git worktree remove`).
# It is also stale when workmux labelled it after a worktree (WORKTREE_ICON prefix)
# that no repo has any more, and no pane sits in a live worktree: its shells have
# since moved out of the removed directory, so the paths alone don't give it away.
def stale(apply:)
  live = worktrees.map(&:path)
  in_live = ->(cwd) { live.any? { cwd == _1 || cwd.start_with?("#{_1}/") } }
  tabs.reject(&:own?).each do |tab|
    gone = tab.panes.any? do |p|
      next false if p.cwd.empty?

      !Dir.exist?(p.cwd) || (p.cwd.include?('__worktrees/') && !in_live.(p.cwd))
    end
    orphan = tab.label.to_s.start_with?(WORKTREE_ICON) &&
             worktrees.none? { _1.name == tab.label.delete_prefix(WORKTREE_ICON).strip } &&
             tab.panes.none? { in_live.(_1.cwd) }
    next unless gone || orphan

    busy = tab.panes.reject(&:idle?).map(&:program).uniq
    puts "#{busy.any? ? 'SKIP ' : 'STALE'} #{tab.session}:#{tab.label} (#{tab.panes.map(&:cwd).uniq.join(', ')})" \
         "#{busy.any? ? " — running #{busy.join(', ')}" : ''}"
    close_tab(tab) if apply && busy.empty?
  end
  puts '(dry run — pass --apply to close tabs)' unless apply
end

# ── tickets / group ──────────────────────────────────────────────────────────
def tickets(all: false)
  keys = (all ? worktrees : tabs.filter_map { tab_worktree(_1) }).filter_map(&:ticket).uniq.sort
  puts JSON.pretty_generate(keys)
end

# Rex can't move a tab between sessions, so a tab is recreated in the target
# (same label, directories and split ratios) and the original closed. Only tabs
# whose panes are idle shells move: anything running would be killed.
def rebuild(node, block, session, cwds)
  return unless (split = node['split'])

  after = split['after']
  dir = split['direction'] == 'horizontal' ? 'right' : 'below'
  ratio = ((1 - split['ratio']) * 100).round.clamp(1, 99)
  out = rex('split', '-s', session, '-b', block, '--split', dir, '--ratio', ratio.to_s,
            '-c', cwds.fetch(leaves(after).first), '--focus=false', '--json')
  rebuild(split['before'], block, session, cwds)
  rebuild(after, JSON.parse(out)['block_ids'].first, session, cwds)
end

def move_tab(tab, target)
  cwds = tab.panes.to_h { [_1.block_id, _1.cwd.empty? ? HOME : _1.cwd] }
  first = cwds.fetch(leaves(tab.layout).first)
  if rex('ls').to_s.lines.drop(1).none? { _1.split.first == target }
    rex('new', target, '-c', first, '--window', tab.label)
    block = JSON.parse(rex('window', 'ls', '-s', target, '--json'))['windows'].first['focused_block_id']
  else
    out = rex('window', 'new', '-s', target, tab.label, '-c', first, '--focus=false', '--json')
    block = JSON.parse(out)['block_ids'].first
  end
  rebuild(tab.layout, block, target, cwds)
  close_tab(tab)
end

def group(map_file:, apply:)
  map = JSON.parse(File.read(map_file))
  moves = Hash.new { |h, k| h[k] = [] }
  tabs.each do |tab|
    ticket = tab_worktree(tab)&.ticket or next
    moves[map.fetch(ticket, ticket)] << tab
  end

  moves.each do |target, group_tabs|
    next if group_tabs.size < 2 && !map.key?(target) && !map.value?(target)

    puts "#{target}: #{group_tabs.map(&:label).join(', ')}"
    group_tabs.reject { _1.session == target }.each do |tab|
      busy = tab.panes.reject(&:idle?).map(&:program).uniq
      if tab.own? || busy.any?
        puts "  SKIP #{tab.session}:#{tab.label} — #{tab.own? ? 'this tab' : "running #{busy.join(', ')}"}"
      else
        puts "  move #{tab.session}:#{tab.label} -> #{target}"
        move_tab(tab, target) if apply
      end
    end
  end
  puts '(dry run — pass --apply to move tabs)' unless apply
end

# ── summary ──────────────────────────────────────────────────────────────────
def summary
  rows = worktrees.map do |wt|
    pr = best_pr(prs_for(wt))
    dirty = !sh('git', 'status', '--porcelain', chdir: wt.path).to_s.strip.empty?
    state = pr ? (pr['isDraft'] && pr['state'] == 'OPEN' ? 'DRAFT' : pr['state']) : 'NO PR'
    sessions = tabs.select { tab_worktree(_1) == wt }.map(&:session).uniq.join(', ')
    [wt.ticket || '-', wt.repo, wt.name, state, pr ? "[##{pr['number']}](#{pr['url']})" : '-',
     dirty ? 'dirty' : 'clean', sessions.empty? ? '-' : sessions]
  end
  rows.sort_by! { |r| [r[0], r[1], r[2]] }
  puts '| Ticket | Repo | Worktree | PR state | PR | Tree | Rex session |'
  puts '|---|---|---|---|---|---|---|'
  rows.each { puts "| #{_1.join(' | ')} |" }
end

# ── main ─────────────────────────────────────────────────────────────────────
opts = { apply: false }
OptionParser.new do |o|
  o.on('--apply') { opts[:apply] = true }
  o.on('--map FILE') { opts[:map] = _1 }
  o.on('--done FILE') { opts[:done] = JSON.parse(File.read(_1)).map(&:upcase) }
  o.on('--all') { opts[:all] = true }
end.parse!

case ARGV.first
when 'reorder' then reorder
when 'merged'  then merged(apply: opts[:apply], done: opts.fetch(:done, []))
when 'stale'   then stale(apply: opts[:apply])
when 'tickets' then tickets(all: opts[:all])
when 'group'   then group(map_file: opts[:map] || abort('--map FILE required'), apply: opts[:apply])
when 'summary' then summary
else abort(File.read(__FILE__)[/\A.*?^$/m].gsub(/^# ?/, ''))
end
