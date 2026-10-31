-- Tab history for ctrl+b ctrl+l. Runs as `rex do --all tab-history.lua dir=<config dir>`
-- (init.lua starts it) and records the tab you left whenever a session's active tab
-- changes. Rex reports no event when the app switches sessions, so cross-session
-- history comes only from last_tab and bin/rex-tab-picker writing it themselves.

local state = dofile(rex.args.dir .. "/tab_state.lua")

local active = {}
for _, s in ipairs((rex.call("session.list") or {}).sessions or {}) do
  local view = rex.session.view{ session_id = s.session_id }
  active[s.session_id] = view and view.active_window_id
end

rex.on("active_window_changed", function(ctx, ev)
  local sid = ctx.session_id
  local left = active[sid]
  active[sid] = ev.window_id
  if not left or left == ev.window_id then return end

  local st = state.read()
  local pending = st.pending
  if pending and os.time() - (pending.at or 0) <= state.pending_ttl then
    if pending.window_id == ev.window_id then
      st.pending = nil
      state.write(st)
      return
    end
  end
  st.pending = nil
  st.previous = { session_id = sid, window_id = left }
  state.write(st)
end)
