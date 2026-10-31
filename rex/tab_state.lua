-- Shared state for ctrl+b ctrl+l (last_tab in init.lua), written by tab-history.lua
-- and bin/rex-tab-picker. `previous` is the tab to go back to; `pending` is a jump
-- in flight, so the watcher doesn't record the jump's own tab change as history.

local M = {}

M.path = os.getenv("HOME") .. "/.local/state/rex/last-tab.json"
-- A pending jump older than this was a no-op (the tab was already active).
M.pending_ttl = 3

function M.read()
  local f = io.open(M.path)
  if not f then return {} end
  local state = rex.json.decode(f:read("*a")) or {}
  f:close()
  return state
end

function M.write(state)
  rex.exec({ "mkdir", "-p", (M.path:gsub("/[^/]*$", "")) })
  local f = assert(io.open(M.path, "w"))
  f:write(rex.json.encode(state))
  f:close()
end

return M
