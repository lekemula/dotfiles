#!/usr/bin/env bash
# Claude Code statusline. Wired via claude.json's statusLine.command -> ~/.claude/statusline.sh (see install.sh).

input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir')
session=$(echo "$input" | jq -r '.session_name // empty')
model=$(echo "$input" | jq -r '.model.display_name // empty')
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
five=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
week=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
dir=$(basename "$cwd")

bar() {
  pct=$1
  filled=$((pct / 10)); [ $filled -gt 10 ] && filled=10; [ $filled -lt 0 ] && filled=0
  empty=$((10 - filled))
  b=$(printf '%*s' "$filled" '' | tr ' ' '█')$(printf '%*s' "$empty" '' | tr ' ' '░')
  if [ "$pct" -ge 80 ]; then color=203; elif [ "$pct" -ge 50 ]; then color=221; else color=108; fi
  echo "\033[38;5;${color}m${b} ${pct}%\033[0m"
}

s=''
[ -n "$session" ] && s+="\033[38;5;141m󰭹 $session\033[0m "
s+="\033[38;5;39m \033[0m \033[38;5;45m$dir\033[0m "

[ -n "$model" ] && s+="\033[38;5;250m$model\033[0m "

if [ -n "$used" ]; then
  pct=$(printf '%.0f' "$used")
  s+="$(bar "$pct") "
fi
if [ -n "$five" ]; then
  pct=$(printf '%.0f' "$five")
  s+="5h $(bar "$pct") "
fi
if [ -n "$week" ]; then
  pct=$(printf '%.0f' "$week")
  s+="7d $(bar "$pct")"
fi

echo -e "$s"
