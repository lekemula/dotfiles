vim.cmd('set runtimepath^=~/.vim runtimepath+=~/.vim/after')
vim.cmd('let &packpath = &runtimepath')
vim.cmd('source ~/.vimrc')

-- NOT WORKING
-- vim.lsp.start({
--   name = 'angular',
--   cmd = {'ngserver', '--stdio', '--tsProbeLocations', '/Users/lekemula/.nvm/versions/node/v20.5.1/lib/node_modules/typescript/lib', "--ngProbeLocations", '/Users/lekemula/.nvm/versions/node/v20.5.1/lib/node_modules/@angular/language-server/lib'},
--   filetypes = { "typescript", "ts", "html"  },  -- Filetypes to trigger the LSP on
--   -- root_dir = vim.lsp.util.root_pattern("tsconfig.json", "angular.json")
-- })
