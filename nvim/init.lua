vim.cmd('set runtimepath^=~/.vim runtimepath+=~/.vim/after')
vim.cmd('let &packpath = &runtimepath')
vim.cmd('source ~/.vimrc')

require('lsp_settings')
require('copilot_settings')
require('render-markdown').setup({
  file_types = { "markdown", "Avante" }
})
require('avante').setup({
  provider = "copilot",
})

-- Remove default keybinding for 'gri' for textDocument/implementation - conflicts with vim-scripts/ReplaceWithRegister
vim.keymap.del("n", "gri")
