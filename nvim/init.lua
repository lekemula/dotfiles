vim.cmd('set runtimepath^=~/.vim runtimepath+=~/.vim/after')
vim.cmd('let &packpath = &runtimepath')
vim.cmd('source ~/.vimrc')

require('lsp_settings')
require('copilot_settings')
require('diffview_settings')
require('autopairs_settings')
require('octo_settings')

local function soften_diff_highlights()
  vim.api.nvim_set_hl(0, 'DiffText', { bg = '#3a5050', bold = true })
  vim.api.nvim_set_hl(0, 'DiffChange', { bg = 'NONE' })
end
soften_diff_highlights()
vim.api.nvim_create_autocmd('ColorScheme', { callback = soften_diff_highlights })
require('render-markdown').setup({
  file_types = { "markdown", "Avante" }
})
-- require('avante').setup({
--   provider = "copilot",
--   -- system_prompt as function ensures LLM always has latest MCP server state
--   -- This is evaluated for every message, even in existing chats
--   system_prompt = function()
--     local hub = require("mcphub").get_hub_instance()
--     return hub and hub:get_active_servers_prompt() or ""
--   end,
--   -- Using function prevents requiring mcphub before it's loaded
--   custom_tools = function()
--     return {
--       require("mcphub.extensions.avante").mcp_tool(),
--     }
--   end,
-- })

-- Remove default keybinding for 'gri' for textDocument/implementation - conflicts with vim-scripts/ReplaceWithRegister
vim.keymap.del("n", "gri")

require("mcphub").setup({
  extensions = {
    avante = {
      make_slash_commands = true,       -- make /slash commands from MCP server prompts
    }
  }
})
