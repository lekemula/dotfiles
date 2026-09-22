#!/usr/bin/env bash
# Row body for each subagent in the agent panel. Wired via claude.json's
# subagentStatusLine.command -> ~/.claude/subagent-statusline.sh (see install.sh).
#
# The main statusLine only ever reports the session's own model, so selecting a
# subagent row never changes it. The per-task model is exposed only here.
# Model arrives as a resolved id, so it needs mapping to a display name.

jq -c '
  def pretty:
    if . == "" then ""
    elif test("fable-5-1") then "Fable 5.1"
    elif test("opus-5")    then "Opus 5"
    elif test("sonnet-5")  then "Sonnet 5"
    elif test("haiku-4-5") then "Haiku 4.5"
    else (split("-20")[0] | sub("^claude-"; "")) end;

  (.columns // 100) as $cols
  | .tasks[]
  | (.model // "" | pretty) as $m
  | (if (.contextWindowSize // 0) > 0 and (.tokenCount // 0) > 0
       then ((.tokenCount / .contextWindowSize * 100) | floor)
       else null end) as $pct
  | {
      id: .id,
      content: ([
        .name,
        (if $m == "" then null else $m end),
        (if (.effort // "") == "" then null else (.effort | tostring) end),
        (if $pct == null then null else (($pct | tostring) + "%") end),
        (if (.description // "") == "" then null
         else .description[0:(($cols / 3) | floor)] end)
      ] | map(select(. != null)) | join(" · "))
    }
'
