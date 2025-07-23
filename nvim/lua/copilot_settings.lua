require("copilot").setup({
  suggestion = {
    enabled = true,
    auto_trigger = true,
    keymap = {
      accept = "<C-l>",
      accept_word = false,
      accept_line = false,
      next = "<C-j>",
      prev = "<M-k>",
      dismiss = "<C-h>",
    },
  }
})

require("CopilotChat").setup {
  mappings = {
    reset = {
      normal = '<leader>air',
      insert = '<leader>air',
    }
  },
  prompts = {
    YARD = {
      prompt = 'Add Ruby Yard Documentation',
      -- system_prompt = 'You are very good at explaining stuff',
      mapping = '<leader>aiyd',
      description = 'Add Ruby Yard Documentation',
    }
  }
}

vim.cmd('nnoremap <leader>tai :CopilotChatToggle<CR>')
vim.cmd('nnoremap <leader>aic :CopilotChat ')
vim.cmd('vnoremap <leader>aic :CopilotChat ')
vim.cmd('vnoremap <leader>aie :CopilotChatExplain<CR>')
vim.cmd('nnoremap <leader>ais :CopilotChatSave ')
vim.cmd('nnoremap <leader>aiS :CopilotChatStop<CR>')
vim.cmd('nnoremap <leader>aip :CopilotChatPrompts<CR>')
vim.cmd('vnoremap <leader>aip :CopilotChatPrompts<CR>')
