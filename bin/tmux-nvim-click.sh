#!/bin/bash
# Open a cmd-clicked file path in the nvim pane that already exists in the
# terminal multiplexer the click came from (tmux or herdr).
#
# Wired up as iTerm2's Semantic History command (com.googlecode.iterm2.plist):
#   action = raw command ("Always run command..."), text = tmux-nvim-click.sh \1 \2
#
# The action has to be "Always run command...", not "Run command...": the latter
# only fires once iTerm has itself resolved the click to an existing file, and
# iTerm cannot resolve a relative path inside tmux -- the cwd it sees belongs to
# the tmux *client*, not to the pane that printed the path. So relative clicks
# never reached this script at all. "Always run command..." hands over the raw
# clicked text and leaves the resolving to absolutize() below.
#
# This never types into the clicked pane. The previous version used AppleScript
# `write text`, which only works when a shell prompt owns the pane -- a TUI
# (Claude Code, lazygit, a pager) takes the keystrokes as input instead.
# AppleScript is now only used to *read* which iTerm session was clicked, so the
# multiplexer's own CLI can do the rest.
#
# A click that does not resolve to a real file is ignored, so every cmd-click on
# prose reaching this script is harmless.
#
# Overrides, for manual runs and debugging:
#   TMUX_NVIM_CLICK_TARGET=tmux|herdr   skip multiplexer detection
#   TMUX_NVIM_CLICK_SESSION=<name>      force the target tmux session
#   TMUX_NVIM_CLICK_DRY_RUN=1           print what would happen, change nothing
#
# The last run is logged to $TMPDIR/tmux-nvim-click.log -- iTerm reports nothing
# when a semantic history command fails.

set -uo pipefail
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:$PATH"

LOG="${TMPDIR:-/tmp}/tmux-nvim-click.log"
: >"$LOG" 2>/dev/null

log() { printf '%s\n' "$*" >>"$LOG" 2>/dev/null; }

run() {
  if [ -n "${TMUX_NVIM_CLICK_DRY_RUN:-}" ]; then
    log "DRY $*"
    printf 'DRY %s\n' "$*"
    return 0
  fi
  log "RUN $*"
  "$@" >>"$LOG" 2>&1
}

file="${1:-}"
line="${2:-}"
[ -n "$file" ] || {
  log "no file argument"
  exit 0
}
log "argv: file=$file line=${line:-none}"

# Terminals hand paths over with decoration around them.
file=${file#\'}
file=${file%\'}
file=${file#\"}
file=${file%\"}
file=${file%:}

# Under iTerm's "Always run command..." action every cmd-click reaches this
# script, ahead of iTerm's own URL handling -- so hand URLs back to the browser
# rather than swallowing them. Checked before the :line split below, which would
# otherwise eat the port out of "https://host:8080/x".
case "$file" in
  [a-z]*://* | mailto:* | www.*)
    log "handing URL to the browser: $file"
    if [ -n "${TMUX_NVIM_CLICK_DRY_RUN:-}" ]; then
      printf 'DRY open %s\n' "$file"
    else
      open "$file" >>"$LOG" 2>&1
    fi
    exit 0
    ;;
esac

# A smart selection rule passes its whole match, so "path:12" (or "path:12:7")
# can arrive as one argument; semantic history splits it into \1 \2 for us.
if [ -z "$line" ]; then
  if [[ $file =~ ^(.*):([0-9]+):([0-9]+)$ ]]; then
    file=${BASH_REMATCH[1]}
    line=${BASH_REMATCH[2]}
  elif [[ $file =~ ^(.*):([0-9]+)$ ]]; then
    file=${BASH_REMATCH[1]}
    line=${BASH_REMATCH[2]}
  fi
fi
case "$line" in
  '' | *[!0-9]*) line=1 ;;
esac

# Nothing downstream expands a leading ~ -- not iTerm, not tmux, not the vim
# command line once the path is escaped.
case "$file" in
  '~') file=$HOME ;;
  '~/'*) file="$HOME/${file#\~/}" ;;
esac

orig_file=$file
log "file=$file line=$line"

# A relative path is relative to the cwd of the pane that printed it, which is
# not this process's cwd -- so the callers below hand over every cwd they know
# of and each one is tried in turn. $PWD comes last: iTerm runs this from the
# tmux client's cwd, which is rarely where the clicked text came from.
#
# Each base is also tried as its enclosing git worktree root, for the paths that
# tools print relative to the repo root while the pane sits in a subdirectory.
absolutize() {
  [ "${file#/}" = "$file" ] || return 0
  local base root
  for base in "$@" "$PWD"; do
    [ -n "$base" ] || continue
    if [ -e "$base/$file" ]; then
      file="$base/$file"
      log "resolved relative path against $base"
      return 0
    fi
    root=$(git -C "$base" rev-parse --show-toplevel 2>/dev/null)
    if [ -n "$root" ] && [ "$root" != "$base" ] && [ -e "$root/$file" ]; then
      file="$root/$file"
      log "resolved relative path against repo root $root"
      return 0
    fi
  done
}

# Guard against opening junk: an absolute path may legitimately not exist yet
# (clicking a path to create it), but a bare word that resolved to nothing is a
# click on prose, not on a file.
#
# A single word with no slash is held to the stricter test of being a regular
# file. Under "Always run command..." every cmd-click lands here, and plain
# prose ("bin", "tmp", "docs") otherwise resolves to a directory next to the
# pane and gets opened in netrw.
openable() {
  if [ "${orig_file#/}" != "$orig_file" ]; then
    [ -e "$file" ] || log "opening absolute path that does not exist yet: $file"
    return 0
  fi
  case "$orig_file" in
    */*) [ -e "$file" ] && return 0 ;;
    *) [ -f "$file" ] && return 0 ;;
  esac
  log "ignoring click that is not a file: $orig_file"
  return 1
}

# :drop reuses a window already showing the file instead of stacking buffers.
nvim_cmd() {
  # Escape the characters vim's command line treats specially in a filename.
  local vim_file=${file//\\/\\\\}
  vim_file=${vim_file// /\\ }
  vim_file=${vim_file//%/\\%}
  vim_file=${vim_file//\#/\\#}
  vim_file=${vim_file//|/\\|}
  vim_file=${vim_file//\$/\\\$}
  printf ':drop +%s %s' "$line" "$vim_file"
}

iterm_tty() {
  osascript -e 'tell application "iTerm2" to tell current session of current window to get tty' 2>/dev/null
}

herdr_running() { herdr pane current >/dev/null 2>&1; }

client_tty=""
client_session=""
target="${TMUX_NVIM_CLICK_TARGET:-}"

# Sets client_tty, client_session and (unless overridden) target. Not a command
# substitution: the globals have to survive for the tmux client switch below.
detect_target() {
  client_tty=$(iterm_tty)
  log "clicked tty=${client_tty:-unknown}"

  if [ -n "$client_tty" ]; then
    client_session=$(tmux list-clients -F '#{client_tty} #{client_session}' 2>/dev/null |
      awk -v t="$client_tty" '$1 == t { print $2; exit }')
    if [ -n "$client_session" ]; then
      [ -n "$target" ] || target=tmux
      return
    fi
    if ps -t "${client_tty#/dev/}" -o comm= 2>/dev/null | grep -q 'herdr$'; then
      [ -n "$target" ] || target=herdr
      return
    fi
  fi

  [ -n "$target" ] && return
  # Neither client owns the clicked session (or iTerm would not say which
  # session was clicked): fall back to whichever multiplexer is up.
  if tmux has-session 2>/dev/null; then
    target=tmux
  elif herdr_running; then
    target=herdr
  else
    target=none
  fi
}

# Echoes "session:window.pane" of the first pane running nvim, preferring the
# current window of $1, then the rest of that session, then any session.
tmux_nvim_pane() {
  local session="$1" fmt='#{session_name}:#{window_index}.#{pane_index} #{pane_current_command}' pane scope
  for scope in "-t $session" "-s -t $session" "-a"; do
    # shellcheck disable=SC2086 # scope is meant to be word-split
    pane=$(tmux list-panes $scope -F "$fmt" 2>/dev/null |
      awk '$2 == "nvim" { print $1; exit }')
    [ -n "$pane" ] && {
      printf '%s\n' "$pane"
      return 0
    }
  done
  return 1
}

open_in_tmux() {
  local session="${TMUX_NVIM_CLICK_SESSION:-$client_session}" pane window
  if [ -z "$session" ]; then
    session=$(tmux list-clients -F '#{client_activity} #{client_session}' 2>/dev/null |
      sort -rn | head -1 | cut -d' ' -f2)
  fi
  [ -n "$session" ] || session=$(tmux list-sessions -F '#{session_name}' 2>/dev/null | head -1)
  [ -n "$session" ] || {
    log "tmux: no session"
    return 1
  }
  log "tmux session=$session"

  local clicked_path
  clicked_path=$(tmux display-message -p -t "${session}:" '#{pane_current_path}' 2>/dev/null)

  # Cwds to resolve a relative path against, nearest the click first. iTerm does
  # not move tmux's focus, so a click in an unfocused pane only tells us the
  # window -- hence the sibling panes, and then the rest of the session.
  local -a bases=("$clicked_path")
  local path
  while IFS= read -r path; do
    [ -n "$path" ] && bases+=("$path")
  done < <(tmux list-panes -t "${session}:" -F '#{pane_current_path}' 2>/dev/null)

  pane=$(tmux_nvim_pane "$session") || {
    log "tmux: no nvim pane, opening a new window"
    absolutize "${bases[@]}"
    openable || exit 0
    run tmux new-window -t "${session}:" nvim "+${line}" "$file"
    return $?
  }
  window=${pane%.*}
  log "tmux nvim pane=$pane"
  bases+=("$(tmux display-message -p -t "$pane" '#{pane_current_path}' 2>/dev/null)")
  while IFS= read -r path; do
    [ -n "$path" ] && bases+=("$path")
  done < <(tmux list-panes -s -t "$session" -F '#{pane_current_path}' 2>/dev/null)
  absolutize "${bases[@]}"
  openable || exit 0

  run tmux select-window -t "$window"
  run tmux select-pane -t "$pane"
  # A pane in another session needs the client moved over as well.
  if [ -n "$client_tty" ] && [ "${window%%:*}" != "$client_session" ]; then
    run tmux switch-client -c "$client_tty" -t "$window"
  fi
  run tmux send-keys -t "$pane" Escape
  run tmux send-keys -t "$pane" "$(nvim_cmd)" Enter
}

open_in_herdr() {
  local panes focused_tab focused_cwd candidates id pane="" tab split new_pane
  panes=$(herdr pane list 2>/dev/null) || {
    log "herdr: pane list failed"
    return 1
  }
  focused_tab=$(printf '%s' "$panes" | jq -r 'first(.result.panes[] | select(.focused) | .tab_id) // empty')
  focused_cwd=$(printf '%s' "$panes" | jq -r 'first(.result.panes[] | select(.focused) | .foreground_cwd) // empty')
  log "herdr focused tab=${focused_tab:-none}"

  # Panes of the focused tab first, then every other pane.
  candidates=$(printf '%s' "$panes" | jq -r --arg tab "$focused_tab" '
    [.result.panes[] | select(.tab_id == $tab)] + [.result.panes[] | select(.tab_id != $tab)]
    | .[].pane_id')

  for id in $candidates; do
    if herdr pane process-info --pane "$id" 2>/dev/null |
      jq -e '.result.process_info.foreground_processes[]? | select(.name == "nvim")' >/dev/null; then
      pane="$id"
      break
    fi
  done

  if [ -z "$pane" ]; then
    log "herdr: no nvim pane, splitting one off"
    absolutize "$focused_cwd"
    openable || exit 0
    split=$(herdr pane split --current --direction right 2>/dev/null)
    new_pane=$(printf '%s' "$split" | jq -r '[.. | objects | .pane_id? // empty] | first // empty')
    [ -n "$new_pane" ] || {
      log "herdr: split returned no pane id: $split"
      return 1
    }
    run herdr pane run "$new_pane" "nvim '+${line}' '${file}'"
    return $?
  fi

  tab=$(printf '%s' "$panes" | jq -r --arg p "$pane" 'first(.result.panes[] | select(.pane_id == $p) | .tab_id) // empty')
  log "herdr nvim pane=$pane tab=${tab:-none}"
  absolutize "$focused_cwd" \
    "$(printf '%s' "$panes" | jq -r --arg p "$pane" 'first(.result.panes[] | select(.pane_id == $p) | .foreground_cwd) // empty')"
  openable || exit 0

  [ -n "$tab" ] && run herdr tab focus "$tab"
  run herdr pane send-keys "$pane" esc
  run herdr pane send-text "$pane" "$(nvim_cmd)"
  run herdr pane send-keys "$pane" enter
}

# No multiplexer to open the file in -- a fresh iTerm window beats typing into
# whatever is running in the clicked one.
open_in_new_iterm_window() {
  absolutize
  openable || exit 0
  local quoted="${file//\'/\'\\\'\'}"
  local cmd="nvim '+${line}' '${quoted}'"
  log "no multiplexer, opening a new iTerm window: $cmd"
  if [ -n "${TMUX_NVIM_CLICK_DRY_RUN:-}" ]; then
    printf 'DRY iterm window: %s\n' "$cmd"
    return 0
  fi
  osascript -e "tell application \"iTerm2\" to create window with default profile command \"${cmd//\"/\\\"}\"" >>"$LOG" 2>&1
}

detect_target
log "target=$target"

case "$target" in
  tmux) open_in_tmux || open_in_new_iterm_window ;;
  herdr) open_in_herdr || open_in_tmux || open_in_new_iterm_window ;;
  *) open_in_new_iterm_window ;;
esac

exit 0
