-- Prefix comment-related buffer mappings with "o" (octo) instead of "c",
-- e.g. <localleader>ca -> <localleader>oca (octo comment add).
local comment_mappings = {
  add_comment = { lhs = "<localleader>oca", desc = "add comment" },
  add_reply = { lhs = "<localleader>ocr", desc = "add reply" },
  delete_comment = { lhs = "<localleader>ocd", desc = "delete comment" },
  comment_edits = { lhs = "<localleader>oce", desc = "show comment edit history" },
}

require("octo").setup({
  picker = "default",
  mappings = {
    discussion = comment_mappings,
    issue = comment_mappings,
    pull_request = comment_mappings,
    review_thread = comment_mappings,
    review_diff = {
      add_review_comment = { lhs = "<localleader>oca", desc = "add a new review comment", mode = { "n", "x" } },
    },
  },
})

local map = function(lhs, rhs, desc)
  vim.keymap.set('n', lhs, rhs, { silent = true, desc = desc })
end

map('<leader>oil', ':Octo issue list<CR>',       'octo-issue-list')
map('<leader>oic', ':Octo issue create<CR>',     'octo-issue-create')
map('<leader>opl', ':Octo pr list<CR>',          'octo-pr-list')
map('<leader>opc', ':Octo pr create<CR>',        'octo-pr-create')
map('<leader>opo', ':Octo pr checkout<CR>',      'octo-pr-checkout')
map('<leader>ors', ':Octo review start<CR>',     'octo-review-start')
map('<leader>orS', ':Octo review submit<CR>',    'octo-review-submit')
map('<leader>orr', ':Octo review resume<CR>',    'octo-review-resume')
map('<leader>osr', ':Octo search<CR>',           'octo-search')

vim.cmd([[
  let g:which_key_map.o = {
        \   'name': '+octo/github',
        \   'i':    {
        \     'name': '+issue',
        \     'l':    'octo-issue-list',
        \     'c':    'octo-issue-create',
        \   },
        \   'p':    {
        \     'name': '+pr',
        \     'l':    'octo-pr-list',
        \     'c':    'octo-pr-create',
        \     'o':    'octo-pr-checkout',
        \   },
        \   'r':    {
        \     'name': '+review',
        \     's':    'octo-review-start',
        \     'S':    'octo-review-submit',
        \     'r':    'octo-review-resume',
        \   },
        \   's':    { 'name': '+search', 'r': 'octo-search' },
        \ }
]])
