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

-- Use the project's solargraph (and its plugins, e.g. solargraph-rspec) when it is in the bundle,
-- like VS Code's `solargraph.useBundler`
local function solargraph_bundled()
  local lockfile = vim.fs.find("Gemfile.lock", { upward = true, path = vim.fn.getcwd() })[1]
  if not lockfile then return false end
  for line in io.lines(lockfile) do
    if line:match("^    solargraph %(") then return true end
  end
  return false
end

if solargraph_cmd[1] == "solargraph" and solargraph_bundled() then
  solargraph_cmd = { "bundle", "exec", "solargraph", "stdio" }
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

-- solargraph-rspec code lenses ("▶ Run RSpec"): show them, and run them like vim-test does, through
-- vim-dispatch. `solargraph.runRspec` is a client-side command, so the client has to implement it.
vim.lsp.commands["solargraph.runRspec"] = function(command)
  local rspec_command = command.arguments and command.arguments[1] and command.arguments[1].command
  if not rspec_command then return end
  if vim.fn.exists(":Dispatch") == 2 then
    vim.cmd("Dispatch " .. rspec_command)
  else
    vim.cmd("botright split | terminal " .. rspec_command)
  end
end

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client and client.name == "solargraph" then
      -- Scoped to the client (it takes either `bufnr` or `client_id`) so other Ruby servers show no lenses
      vim.lsp.codelens.enable(true, { client_id = client.id })
    end
  end,
})

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
  -- Pin to the global node: the bare shim resolves to the project's node, which often lacks the package
  cmd = { "mise", "exec", "node@lts", "--", "stimulus-language-server", "--stdio" },
  -- Lets extensionless imports in controllers/index.js resolve to TypeScript controllers
  cmd_env = {
    NODE_OPTIONS = vim.trim(("%s --require %s"):format(
      vim.env.NODE_OPTIONS or "",
      vim.fs.joinpath(vim.fn.stdpath("config"), "lua", "stimulus_ls_resolve_ts.js")
    )),
  },
  filetypes = { "html", "ruby", "eruby", "blade", "php" },
  root_markers = { "Gemfile", ".git" },
  -- The server indexes controllers only at startup and ignores watched-file events for them, so a controller
  -- added later stays "invalid". It re-indexes on didChangeConfiguration, so send one when JS/TS files change.
  on_init = function(client)
    local notify = client.notify
    local timer = assert(vim.uv.new_timer())
    client.notify = function(self, method, params)
      local result = notify(self, method, params)
      if method == "workspace/didChangeWatchedFiles" then
        local relevant = vim.iter(params.changes):any(function(change)
          return change.uri:match("%.[jt]s$") and not change.uri:match("/node_modules/")
        end)
        if relevant then
          timer:start(300, 0, vim.schedule_wrap(function()
            if not self:is_stopped() then
              notify(self, "workspace/didChangeConfiguration", { settings = self.settings or {} })
            end
          end))
        end
      end
      return result
    end
  end
})
vim.lsp.enable('stimulus_ls')

-- HerbLS for Ruby (experimental)
vim.lsp.enable('herb_ls')

-- nvim-lspconfig skips :LspInfo/:LspLog on Nvim 0.12+ (PR #4234). Re-register them.
vim.api.nvim_create_user_command('LspInfo', 'checkhealth vim.lsp', { desc = 'Alias to `:checkhealth vim.lsp`' })
vim.api.nvim_create_user_command('LspLog', function()
  vim.cmd('tabnew ' .. vim.lsp.log.get_filename())
end, { desc = 'Open the Nvim LSP client log' })

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
local float_opts = { border = 'rounded', max_width = 100, max_height = 30 }
vim.keymap.set('n', 'K', function() vim.lsp.buf.hover(float_opts) end, { noremap = true, silent = true })
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

-- The old :LspRestart Ex command was dropped in nvim 0.12 in favor of the
-- :lsp restart [<client_name>] subcommand. Re-expose it under the familiar name.
vim.api.nvim_create_user_command("LspRestart", function(opts)
  vim.cmd("lsp restart " .. (opts.args or ""))
end, { nargs = "?", desc = "Restart LSP client(s) — wraps :lsp restart" })
