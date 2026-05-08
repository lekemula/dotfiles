local actions = require("diffview.actions")

require("diffview").setup({
  keymaps = {
    view = {
      { "n", "<leader>gdh", actions.conflict_choose("ours"),       { desc = "Choose the OURS version of a conflict" } },
      { "n", "<leader>gdl", actions.conflict_choose("theirs"),     { desc = "Choose the THEIRS version of a conflict" } },
      { "n", "<leader>gda", actions.conflict_choose("all"),        { desc = "Choose all the versions of a conflict" } },
      { "n", "<leader>gdn", actions.conflict_choose("none"),       { desc = "Delete the conflict region" } },
      { "n", "<leader>gdH", actions.conflict_choose_all("ours"),   { desc = "Choose the OURS version of a conflict for the whole file" } },
      { "n", "<leader>gdL", actions.conflict_choose_all("theirs"), { desc = "Choose the THEIRS version of a conflict for the whole file" } },
      { "n", "<leader>gdA", actions.conflict_choose_all("all"),    { desc = "Choose all the versions of a conflict for the whole file" } },
      { "n", "<leader>gdN", actions.conflict_choose_all("none"),   { desc = "Delete the conflict region for the whole file" } },
    },
  },
})

local map = function(lhs, rhs, desc)
  vim.keymap.set('n', lhs, rhs, { silent = true, desc = desc })
end

map('<leader>gvd',  ':DiffviewOpen<CR>',              'diffview-diff')
map('<leader>gvdb', ':DiffviewOpen origin/main<CR>',  'diffview-diff-base')
map('<leader>gvcf', ':DiffviewOpen origin/main<CR>',  'diffview-changed-files')
map('<leader>gvlo', ':DiffviewFileHistory<CR>',       'diffview-log')
map('<leader>gvlf', ':DiffviewFileHistory %<CR>',     'diffview-log-file')
map('<leader>gvc',  ':DiffviewClose<CR>',             'diffview-close')

vim.cmd([[
  let g:which_key_map.g.v = {
        \   'name': '+diffview',
        \   'd':    'diffview-diff',
        \   'db':   'diffview-diff-base',
        \   'dh':   'diffview-diff-left (in 3-way)',
        \   'dl':   'diffview-diff-right (in 3-way)',
        \   'cf':   'diffview-changed-files',
        \   'lo':   'diffview-log',
        \   'lf':   'diffview-log-file',
        \   'c':    'diffview-close',
        \ }
]])
