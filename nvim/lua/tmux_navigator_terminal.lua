-- vim-tmux-navigator's terminal-mode <C-h/j/k/l> maps leave terminal mode with
-- <C-w>, Vim 8's termwinkey. Neovim has no termwinkey, so nothing is consumed
-- and the whole sequence lands in the running program instead: <C-U> wipes the
-- line and " TmuxNavigateLeft<CR>" gets submitted — visible as a stray prompt
-- in a Claude Code split. Redo the maps with Neovim's <C-\><C-n>.
--
-- On VimEnter because vim-plug only puts the plugin on the runtimepath; its
-- plugin/ files are sourced after init.lua, so mapping here directly loses.
if vim.env.TMUX == nil or vim.env.TMUX == '' then
  return
end

vim.api.nvim_create_autocmd('VimEnter', {
  callback = function()
    for key, direction in pairs({ h = 'Left', j = 'Down', k = 'Up', l = 'Right' }) do
      local lhs = '<C-' .. key .. '>'
      vim.keymap.set('t', lhs, function()
        -- fzf's terminal UI binds these itself.
        if vim.bo.filetype == 'fzf' then
          return lhs
        end
        return '<C-\\><C-n><Cmd>TmuxNavigate' .. direction .. '<CR>'
      end, { expr = true, replace_keycodes = true, silent = true, desc = 'tmux navigate ' .. string.lower(direction) })
    end
  end,
})
