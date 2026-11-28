-- Folded lines show the fold's first line with its own syntax colours and a muted
-- line count, instead of Vim's "+--- 26 lines: …" padded with dashes.

-- Runs of the same syntax group across a line, as foldtext chunks.
local function highlighted_chunks(lnum, line)
  local chunks, run, run_hl = {}, '', nil
  for col = 1, #line do
    local hl = vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.synID(lnum, col, 1)), 'name')
    if hl ~= run_hl and run ~= '' then
      table.insert(chunks, { run, run_hl ~= '' and run_hl or 'Folded' })
      run = ''
    end
    run, run_hl = run .. line:sub(col, col), hl
  end
  if run ~= '' then table.insert(chunks, { run, run_hl ~= '' and run_hl or 'Folded' }) end
  return chunks
end

function _G.fold_text()
  local first = vim.v.foldstart
  local line = vim.fn.getline(first):gsub('\t', string.rep(' ', vim.bo.tabstop))
  local chunks = highlighted_chunks(first, line)
  table.insert(chunks, { ('  ⋯ %d lines'):format(vim.v.foldend - first + 1), 'Comment' })
  return chunks
end

vim.opt.foldtext = 'v:lua.fold_text()'
vim.opt.fillchars:append({ fold = ' ' })
