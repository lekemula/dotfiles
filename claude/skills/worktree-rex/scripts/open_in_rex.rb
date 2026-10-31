#!/usr/bin/env ruby
# frozen_string_literal: true

# Creates a workmux worktree and opens it as a Rex tab: nvim left, claude right.
#
#   open_in_rex.rb NAME PROMPT_FILE [--session LABEL]
#
# workmux stays the owner of the worktree (branch, file ops, hooks, so `workmux
# list/merge/remove` keep working), but it only drives tmux: `-C` leaves its tmux
# window a bare shell in the background, and the agent runs in Rex instead.
#
# The Rex session is LABEL, else the ticket key in NAME (`LI-2025-foo` -> `LI-2025`),
# else the caller's own Rex session. A missing session is created; an existing one
# gets the worktree as a new tab.

require 'json'
require 'open3'
require 'optparse'

TMUX_PARENT = 'rex-worktrees'

def run!(*cmd, chdir: Dir.pwd)
  out, err, status = Open3.capture3(*cmd, chdir: chdir)
  abort "#{cmd.join(' ')} failed:\n#{err.strip.empty? ? out : err}" unless status.success?
  out
end

def rex_sessions
  run!('rex', 'ls').lines.drop(1).map { |line| line.split.first }
end

session = nil
OptionParser.new { |o| o.on('--session LABEL') { |v| session = v } }.parse!
name, prompt_file = ARGV
abort 'usage: open_in_rex.rb NAME PROMPT_FILE [--session LABEL]' unless name && prompt_file

prompt = File.read(prompt_file)
session ||= name[/\A[A-Za-z]+-\d+/]&.upcase
abort "no ticket key in #{name.inspect} and not inside Rex; pass --session" unless session || ENV['REX_SESSION']

run!('workmux', 'add', name, '-b', '-C', '--prompt-file-only', '-P', prompt_file,
     '--parent-session', TMUX_PARENT)
path = run!('workmux', 'path', name).strip

scope =
  if session.nil?
    ['-s', ENV.fetch('REX_SESSION')]
  elsif rex_sessions.include?(session)
    ['-s', session]
  end

if scope
  run!('rex', 'window', 'new', *scope, name, '-c', path, '--', 'nvim')
else
  run!('rex', 'new', session, '-c', path, '--window', name, '--', 'nvim')
  scope = ['-s', session]
end
run!('rex', 'split', *scope, '-c', path, '--label', 'claude', '--', 'claude', prompt)

puts JSON.generate(worktree: path, branch: name, rex_session: scope.last)
