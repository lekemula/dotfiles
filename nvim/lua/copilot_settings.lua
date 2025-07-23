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
