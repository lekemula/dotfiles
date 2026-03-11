require('cmp')
require('nvim_cmp_settings')

-- local capabilities = vim.lsp.protocol.make_client_capabilities()

-- https://github.com/j-hui/fidget.nvim#options
require("fidget").setup {} -- LSP progress indicator

-- TypeScript
vim.lsp.config("ts_ls", {
  settings = {
    typescript = {
      preferences = {
        includePackageJsonAutoImports = "on"
      }
    }
  },
  root_markers = {"tsconfig.json", "tsconfig.base.json", "tsconfig.lib.json", "package.json", ".git"}
})
vim.lsp.enable('ts_ls')

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
local angularls_cmd = {"ngserver", "--stdio", "--tsProbeLocations", tsProbeLocations , "--ngProbeLocations", ngProbeLocations}

vim.lsp.config("angularls", {
  cmd = angularls_cmd,
  root_markers = {"tsconfig.json", "tsconfig.base.json", "tsconfig.lib.json", "package.json", ".git"}
})
vim.lsp.enable('angularls')

-- local capabilities = require('cmp_nvim_lsp').default_capabilities()
local timestamped_output_file = "/tmp/solargraph_vernier_profile_" .. os.date("%Y%m%d%H%M%S") .. ".json.gz"

local solargraph_cmd
if os.getenv("SOLARGRAPH_PROFILE") then
  -- solargraph_cmd = { "vernier", "run", "--allocation-interval", "10", "--output", timestamped_output_file, "--", "solargraph", "stdio" }
  solargraph_cmd = { "vernier", "run", "--out", timestamped_output_file, "--", "solargraph", "stdio" }
elseif os.getenv("SOLARGRAPH_PROFILE_MEMORY") then
  -- ruby-memory-profiler run --pretty --output solargraph_memory_profile.json.gz -- solargraph stdio
  solargraph_cmd = { "ruby-memory-profiler", "run", "--pretty", "--output", timestamped_output_file, "--", "solargraph", "stdio" }
else
  solargraph_cmd = { "solargraph", "stdio" }
end

vim.lsp.config("solargraph", {
  cmd = solargraph_cmd,
  settings = {
    solargraph = {
      diagnostics = true,
      logLevel = os.getenv("SOLARGRAPH_LOG_LEVEL") or "warn"
    }
  }
})
vim.lsp.enable('solargraph')

-- yaml
vim.lsp.config("yamlls", {
  settings = {
    yaml = {
      schemas = {
        ["kubernetes"] = "*/kubernetes/*.yaml",
      }
    }
  }
})
vim.lsp.enable('yamlls')

-- JSON
vim.lsp.enable('jsonls')

-- C/C++
vim.lsp.config("clangd", {})
vim.lsp.enable('clangd')

-- lua
vim.lsp.config("lua_ls", {
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
})
vim.lsp.enable('lua_ls')

-- stimuls js
vim.lsp.config("stimulus_ls", {
  filetypes = { "html", "ruby", "eruby", "blade", "php" },
  root_markers = { "Gemfile", ".git" }
})
vim.lsp.enable('stimulus_ls')

-- HerbLS for Ruby (experimental)
vim.lsp.enable('herb_ls')

-- Keymaps for LSP actions
vim.api.nvim_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', { noremap = true, silent = true })

-- Automatically fetch workspace symbols (silently) for Ruby files
-- Symbols are fetched but not displayed in quickfix, in order to pre-cache Solargraph symbols for faster subsequent searches
-- Mimics the same behaviour as VScode's Solargraph extension with `"solargraph.symbols": true` (default)
-- See: https://github.com/castwide/solargraph/pull/1029#issuecomment-3229874738
-- vim.api.nvim_create_autocmd("BufReadPost", {
--   pattern = "*.rb",
--   callback = function()
--     vim.lsp.buf_request(0, 'textDocument/documentSymbol', vim.lsp.util.make_position_params(), function(err, result)
--       -- do nothing, just fetch symbols to warm up the cache
--     end)
--   end,
-- })
vim.api.nvim_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'gtd', '<cmd>lua vim.lsp.buf.type_definition()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'grf', '<cmd>lua vim.lsp.buf.references()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>fa', '<cmd>lua vim.lsp.buf.code_action()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>fr', '<cmd>lua vim.lsp.codelens.run()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>O', '<cmd>lua vim.lsp.buf.workspace_symbol()<CR>', { noremap = true, silent = true })
vim.keymap.set("n", "[e", vim.diagnostic.goto_prev, { noremap = true, silent = true })
vim.keymap.set("n", "]e", vim.diagnostic.goto_next, { noremap = true, silent = true })
vim.keymap.set("n", "<leader>e", vim.diagnostic.setqflist, { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>fd', '<cmd>lua vim.lsp.buf.format({timeout_ms = 10000})<CR>', { noremap = true, silent = true })
