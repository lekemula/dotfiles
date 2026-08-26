# Read by *every* zsh — interactive, non-interactive (`zsh -c`), and scripts.
# Keep it fast, side-effect free, and idempotent: .zprofile re-sources this file
# to undo path_helper (see below). Anything interactive belongs in .zshrc.
# $DF_HOME isn't available here — .zshrc sets it, and that runs much later.

# Put mise's shims at the front of PATH.
#
# `mise activate` only runs from .zshrc, which non-interactive shells never read.
# Without this, `zsh -c ...` (agent tooling, scripts, editor subprocesses) falls
# through to /usr/bin/ruby — macOS system Ruby 2.6 — even when a mise-managed
# Ruby is installed. The nasty case is `bundle exec <cmd>`: bundler resolves the
# child command via PATH, so `bundle exec rake` boots system Ruby 2.6, which then
# loads mise's bundler lib and dies with a confusing mixed-Ruby NameError.
#
# The shims dir is deliberately version-agnostic — it resolves whatever
# .ruby-version / .mise.toml asks for — so nothing here needs touching when a
# project's Ruby or Node version changes.
#
# This wins over /opt/homebrew/bin too, which is intentional: it matches what
# `mise activate` already does in interactive shells, so brew-installed node,
# java, etc. lose to the mise-managed ones in both.
() {
  local shims="${MISE_DATA_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/mise}/shims"
  [[ -d $shims ]] || return 0
  # Strip any existing copy before prepending. It's usually already on PATH but
  # in the wrong place — inherited from a parent process, or shuffled behind
  # /usr/bin by macOS's path_helper — which is the whole problem.
  path=("$shims" ${path:#$shims})
}
