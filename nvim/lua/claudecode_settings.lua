require('snacks').setup({})

local in_tmux = vim.env.TMUX ~= nil and vim.env.TMUX ~= ''

-- A tmux pane outlives the nvim that spawned it, so after an nvim restart the old
-- Claude is still running but its CLAUDE_CODE_SSE_PORT points at the dead server:
-- it looks alive, answers nothing, and sends silently go nowhere. Report whether
-- the pane we found is still talking to *this* nvim.
---@return string? pane_id, boolean? connected_to_this_nvim
local function existing_claude_pane()
  if not vim.env.TMUX_PANE then
    return nil
  end

  local out = vim.fn.systemlist({
    'tmux', 'list-panes', '-t', vim.env.TMUX_PANE, '-F', '#{pane_id} #{pane_current_command} #{pane_pid}',
  })
  if vim.v.shell_error ~= 0 then
    return nil
  end

  for _, line in ipairs(out) do
    local pane, command, pid = line:match('^(%%%d+)%s+(%S+)%s+(%d+)$')
    if command == 'claude' then
      local ok, server = pcall(require, 'claudecode.server.init')
      local port = ok and server.state and server.state.port
      local target = vim.fn.system({ 'ps', 'eww', '-p', pid }):match('CLAUDE_CODE_SSE_PORT=(%d+)')
      return pane, port ~= nil and target == tostring(port)
    end
  end
  return nil
end

-- Run Claude in a real tmux pane rather than an nvim terminal buffer: workmux
-- keys agent status off panes, and a pane hosting nvim reports
-- pane_current_command=nvim, so an in-editor session is invisible to it.
-- The MCP connection is unaffected - Claude finds the server through the env
-- vars forwarded with -e, so diffs and @-mentions still land in this nvim.
local function tmux_claude_cmd(cmd, env)
  local pane, connected = existing_claude_pane()

  if pane and not connected then
    -- Orphaned by an nvim restart: useless for IDE integration, and keeping it
    -- around would also give workmux two claude panes to choose between.
    vim.notify('Replacing Claude pane left over from a previous nvim (use --resume to pick the session back up)',
      vim.log.levels.INFO)
    vim.fn.system({ 'tmux', 'kill-pane', '-t', pane })
    pane = nil
  end

  if pane then
    local model = cmd:match('%-%-model%s+(%S+)')
    local stripped = cmd:gsub('%-%-model%s+%S+', '')
    local other_args = stripped:match('%-%-%S') ~= nil

    -- A running Claude cannot be re-execed with a new --model, but it can switch
    -- via its own /model command, which keeps the conversation.
    if model and not other_args then
      return {
        'tmux', 'send-keys', '-l', '-t', pane, '/model ' .. model,
        ';', 'send-keys', '-t', pane, 'Enter',
        ';', 'select-pane', '-t', pane,
      }
    end

    if not other_args then
      return { 'tmux', 'select-pane', '-t', pane }
    end

    -- --resume/--continue start a different session, so they need a new process.
    vim.fn.system({ 'tmux', 'kill-pane', '-t', pane })
  end

  local args = { 'tmux', 'split-window', '-h', '-l', '35%', '-c', vim.fn.getcwd() }
  if vim.env.TMUX_PANE then
    vim.list_extend(args, { '-t', vim.env.TMUX_PANE })
  end
  for key, value in pairs(env) do
    vim.list_extend(args, { '-e', key .. '=' .. value })
  end
  table.insert(args, cmd) -- single arg: tmux hands the whole string to sh -c
  return args
end

require('claudecode').setup({
  -- The plugin's built-in list predates Fable and is hardcoded, not read from the
  -- CLI, so overriding is the only way to offer it. Note this shadows the default
  -- list entirely - new models the plugin adds later won't show up until added here.
  models = {
    { name = 'Claude Fable (Latest)', value = 'fable' },
    { name = 'Claude Opus (Latest)', value = 'opus' },
    { name = 'Claude Opus (Latest, 1M context)', value = 'opus[1m]' },
    { name = 'Claude Sonnet (Latest)', value = 'sonnet' },
    { name = 'Claude Sonnet (Latest, 1M context)', value = 'sonnet[1m]' },
    { name = 'Claude Haiku (Latest)', value = 'haiku' },
    { name = 'Default (account recommended)', value = 'default' },
  },
  terminal = {
    split_side = 'right',
    split_width_percentage = 0.35,
    -- Outside tmux there is no pane to own, so fall back to the in-editor split.
    provider = in_tmux and 'external' or 'auto',
    provider_opts = {
      external_terminal_cmd = in_tmux and tmux_claude_cmd or nil,
    },
    auto_close = true,
  },
  diff_opts = {
    layout = 'vertical',
    auto_resize_terminal = true,
  },
})

-- claudecode.nvim launches the tmux CLI with jobstart{detach = true}, so its
-- on_exit never fires and the external provider never clears its jobid. is_valid()
-- then stays true for the rest of the session, making every later :ClaudeCode take
-- the "already running" branch - which silently drops arguments, so --model and
-- --resume did nothing. Clearing the dead job first puts the provider back into
-- open(), where external_terminal_cmd above gets to decide what to do.
local function reset_external_job()
  local ok, external = pcall(require, 'claudecode.terminal.external')
  if ok then
    pcall(external.close) -- jobstop on an already-dead job is a no-op
  end
end

local function claude(args)
  reset_external_job()
  vim.cmd('ClaudeCode' .. (args and (' ' .. args) or ''))
end

-- Same reset, then let the plugin's picker issue its own :ClaudeCode --model <x>.
local function claude_select_model()
  reset_external_job()
  vim.cmd('ClaudeCodeSelectModel')
end

local map = vim.keymap.set

-- With the external provider <leader>ac opens or focuses the pane; it cannot
-- hide it, and :ClaudeCodeSendText is unavailable (native/snacks only).
map('n', '<leader>ac', function() claude() end, { desc = 'Claude: open/focus' })
map('n', '<leader>af', function() claude() end, { desc = 'Claude: focus' })
map('n', '<leader>ar', function() claude('--resume') end, { desc = 'Claude: resume session' })
map('n', '<leader>aC', function() claude('--continue') end, { desc = 'Claude: continue session' })
map('n', '<leader>am', claude_select_model, { desc = 'Claude: select model' })
map('n', '<leader>ab', '<cmd>ClaudeCodeAdd %<cr>', { desc = 'Claude: add current buffer' })
map('v', '<leader>as', '<cmd>ClaudeCodeSend<cr>', { desc = 'Claude: send selection' })
map('n', '<leader>aa', '<cmd>ClaudeCodeDiffAccept<cr>', { desc = 'Claude: accept diff' })
map('n', '<leader>ad', '<cmd>ClaudeCodeDiffDeny<cr>', { desc = 'Claude: deny diff' })
map('n', '<leader>ax', '<cmd>ClaudeCodeCloseAllDiffs<cr>', { desc = 'Claude: close pending diffs' })

-- focus_after_send only works for in-editor terminals, so with Claude in its own
-- tmux pane a send moves nothing and looks like it did nothing. The plugin fires
-- this event precisely so external setups can focus the session themselves.
if in_tmux then
  vim.api.nvim_create_autocmd('User', {
    pattern = 'ClaudeCodeSendComplete',
    callback = function()
      local pane = existing_claude_pane()
      if pane then
        vim.fn.system({ 'tmux', 'select-pane', '-t', pane })
      end
    end,
  })
end

-- claudecode.nvim's :ClaudeCodeTreeAdd only knows nvim-tree/neo-tree/oil/mini/netrw,
-- so read the node under the cursor out of NERDTree ourselves.
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'nerdtree',
  callback = function(args)
    map('n', '<leader>as', function()
      local ok, path = pcall(vim.fn.eval, 'g:NERDTreeFileNode.GetSelected().path.str()')
      if ok and path ~= '' then
        vim.cmd('ClaudeCodeAdd ' .. vim.fn.fnameescape(path))
      end
    end, { buffer = args.buf, desc = 'Claude: add file under cursor' })
  end,
})
