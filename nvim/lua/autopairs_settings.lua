require('nvim-autopairs').setup({})

-- Make <CR> also confirm the current cmp completion and insert matching pairs.
local cmp_autopairs = require('nvim-autopairs.completion.cmp')
local cmp = require('cmp')
cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())
