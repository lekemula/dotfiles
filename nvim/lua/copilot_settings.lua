require("copilot").setup({
  suggestion = {
    enabled = false,
    auto_trigger = false,
    keymap = {
      accept = "<C-l>",
      accept_word = false,
      accept_line = false,
      next = "<C-j>",
      prev = "<M-k>",
      dismiss = "<C-h>",
    },
  },
  panel = {
    enabled = false,
  },
  -- "*" is the fallback for any filetype without an explicit entry; a per-filetype
  -- `true` here would still turn suggestions back on for that filetype.
  filetypes = {
    ["*"] = false,
  },
})
