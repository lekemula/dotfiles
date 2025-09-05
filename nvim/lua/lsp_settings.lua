local lspconfig = require('lspconfig')

require('cmp')
require('nvim_cmp_settings')

-- local capabilities = vim.lsp.protocol.make_client_capabilities()

-- https://github.com/j-hui/fidget.nvim#options
require("fidget").setup {} -- LSP progress indicator

-- TypeScript
lspconfig.ts_ls.setup{
  settings = {
    typescript = {
      preferences = {
        includePackageJsonAutoImports = "on"
      }
    }
  },
  root_dir = require("lspconfig")["util"].root_pattern("tsconfig.json", "tsconfig.base.json", "tsconfig.lib.json", "package.json", ".git")
}

-- Javascript/Typescript ESLint
local base_on_attach = vim.lsp.config.eslint.on_attach
vim.lsp.config("eslint", {
  on_attach = function(client, bufnr)
    if not base_on_attach then return end

    base_on_attach(client, bufnr)
    -- Format on save
    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = bufnr,
      command = "LspEslintFixAll",
    })
  end,
})
vim.lsp.enable('eslint')

-- AngularLSP
-- use globally installed ngserver
local node_path = os.getenv("NPM_PATH") or os.execute("npm root -g")
local tsProbeLocations = node_path .. "/typescript/lib"
local ngProbeLocations = node_path .. "/@angular/language-server/bin"
local cmd = {"ngserver", "--stdio", "--tsProbeLocations", tsProbeLocations , "--ngProbeLocations", ngProbeLocations}

lspconfig.angularls.setup{
  cmd = cmd,
  root_dir = require("lspconfig")["util"].root_pattern("tsconfig.json", "tsconfig.base.json", "tsconfig.lib.json", "package.json", ".git")
}

-- local capabilities = require('cmp_nvim_lsp').default_capabilities()
lspconfig.solargraph.setup{
  -- cmd = { "vernier", "run", "--output", "/tmp/solargraph_verier_profile.json.gz", "--", "solargraph", "stdio" },
  settings = {
    solargraph = {
      diagnostics = true,
      logLevel = os.getenv("SOLARGRAPH_LOG_LEVEL") or "warn"
    }
  }
}

-- yaml
lspconfig.yamlls.setup{}

-- lua
lspconfig.lua_ls.setup{
  on_init = function(client)
    if client.workspace_folders then
      local path = client.workspace_folders[1].name
      if path ~= vim.fn.stdpath('config') and (vim.loop.fs_stat(path..'/.luarc.json') or vim.loop.fs_stat(path..'/.luarc.jsonc')) then
        return
      end
    end

    client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
      runtime = {
        -- Tell the language server which version of Lua you're using
        -- (most likely LuaJIT in the case of Neovim)
        version = 'LuaJIT'
      },
      -- Make the server aware of Neovim runtime files
      workspace = {
        checkThirdParty = false,
        library = {
          vim.env.VIMRUNTIME
          -- Depending on the usage, you might want to add additional paths here.
          -- "${3rd}/luv/library"
          -- "${3rd}/busted/library",
        }
        -- or pull in all of 'runtimepath'. NOTE: this is a lot slower and will cause issues when working on your own configuration (see https://github.com/neovim/nvim-lspconfig/issues/3189)
        -- library = vim.api.nvim_get_runtime_file("", true)
      }
    })
  end,
  settings = {
    Lua = {}
  }
}

-- Keymaps for LSP actions
vim.api.nvim_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'gtd', '<cmd>lua vim.lsp.buf.type_definition()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'grf', '<cmd>lua vim.lsp.buf.references()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>fa', '<cmd>lua vim.lsp.buf.code_action()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>fr', '<cmd>lua vim.lsp.codelens.run()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>o', '<cmd>lua vim.lsp.buf.document_symbol()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>O', '<cmd>lua vim.lsp.buf.workspace_symbol()<CR>', { noremap = true, silent = true })
vim.keymap.set("n", "[e", vim.diagnostic.goto_prev, { noremap = true, silent = true })
vim.keymap.set("n", "]e", vim.diagnostic.goto_next, { noremap = true, silent = true })
vim.keymap.set("n", "<leader>e", vim.diagnostic.setqflist, { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>fd', '<cmd>lua vim.lsp.buf.format({timeout_ms = 10000})<CR>', { noremap = true, silent = true })
