local function executableOnPath(executable)
  if vim.fn.executable(executable) == 1 then
    return executable
  else
    return nil
  end
end

vim.diagnostic.config({
  virtual_text = false,
})

local function max_severity_diagnostics()
  local severity = nil
  local res = {}
  for _, d in ipairs(vim.diagnostic.get()) do
    if not severity or d.severity < severity then
      res = {}
      severity = d.severity
    end
    if d.severity == severity then
      table.insert(res, d)
    end
  end
  vim.diagnostic.setqflist({ severity = severity })
end

-- on_attach function for language servers
--
-- This sets up keybindings which only work when a language server is used.
---@param client any
---@param bufnr any
---@diagnostic disable-next-line client is unused, but required for the on_attach signature
local on_attach = function(client, bufnr)
  local opts = function(desc, args)
    local opts = { silent = true, buffer = bufnr, desc = desc }
    if args then
      for key, value in pairs(args) do
        opts[key] = value
      end
    end
    return opts
  end
  if bufnr then
    vim.keymap.set("n", "<Leader>u", vim.lsp.buf.references, opts("usages"))
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts("hover docs"))
    vim.keymap.set("n", "H", max_severity_diagnostics, opts("cursor diagnostics"))
    vim.keymap.set("n", "L", vim.diagnostic.open_float, opts("line diagnostics"))

    vim.keymap.set(
      "n",
      "<space>lwa",
      vim.lsp.buf.add_workspace_folder,
      opts("add workspace folder")
    )
    vim.keymap.set(
      "n",
      "<space>lwr",
      vim.lsp.buf.remove_workspace_folder,
      opts("remove workspace folder")
    )
    vim.keymap.set(
      "n",
      "<space>lwl",
      vim.lsp.buf.list_workspace_folders,
      opts("list workspace folders")
    )
    vim.keymap.set({ "n", "v" }, "<Leader>ll", vim.lsp.codelens.run, opts("code lens"))
    vim.keymap.set({ "n", "v" }, "<Leader>lf", function()
      vim.lsp.buf.format({ async = false })
    end, opts("format buffer"))
    vim.keymap.set({ "n" }, "<Leader>ld", vim.lsp.buf.definition, opts("definition"))
    vim.keymap.set({ "n" }, "<Leader>lD", vim.lsp.buf.declaration, opts("declaration"))
    vim.keymap.set({ "n" }, "<Leader>li", vim.lsp.buf.implementation, opts("implementation"))
    vim.keymap.set({ "n" }, "<Leader>r", vim.lsp.buf.rename, opts("rename"))
    vim.keymap.set({ "n" }, "<Leader>lr", vim.lsp.buf.rename, opts("rename"))
    vim.keymap.set({ "n" }, "<Leader>lt", vim.lsp.buf.type_definition, opts("type definition"))
    vim.keymap.set({ "n" }, "<Leader>lu", vim.lsp.buf.references, opts("usages"))
    vim.keymap.set({ "n", "v" }, "<Leader>lc", vim.lsp.buf.code_action, opts("code action"))
  end
end

local lsp_server_opts = {
  lua_ls = {
    can_start = function()
      return executableOnPath("lua-language-server")
    end,
    cmd = { "lua-language-server" },
    settings = {
      Lua = {
        runtime = {
          -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
          version = "LuaJIT",
        },
        diagnostics = {
          -- Get the language server to recognize the `vim` global
          globals = {
            "vim",

            -- Busted
            "after_each",
            "assert",
            "before_each",
            "clear",
            "describe",
            "it",
            "pending",
            "teardown",
          },
        },
        workspace = {
          -- Make the server aware of Neovim runtime files
          library = vim.api.nvim_get_runtime_file("", true),
          checkThirdParty = false,
        },
        -- Do not send telemetry data containing a randomized but unique identifier
        telemetry = {
          enable = false,
        },
      },
    },
  },
  bashls = {},
  clojure_lsp = {},
  gopls = {
    settings = {
      gopls = {
        gofumpt = true,
      },
    },
  },
  tailwindcss = {
    can_start = function()
      return executableOnPath("tailwindcss-language-server")
    end,
  },
  angularls = {
    can_start = function()
      return executableOnPath("ngserver")
    end,
  },
  nushell = {},
  ts_ls = {},
  eslint = {},
  gleam = {},
  html = {},
  cssls = {},
  hls = {
    filetypes = { "haskell", "lhaskell", "cabal" },
    settings = {
      haskell = {
        formattingProvider = "fourmolu",
        plugin = {
          fourmolu = {
            config = {
              external = true,
            },
          },
        },
      },
    },
  },
  rust_analyzer = {
    settings = {
      ["rust-analyzer"] = {
        diagnostics = {
          enable = true,
        },
        cargo = {
          features = "all,",
        },
      },
    },
  },
}

local function hostname()
  local f = io.popen("uname -n")
  if f then
    local n = f:read("*a") or ""
    f:close()
    n = string.gsub(n, "\n$", "")
    return n
  end
end
local host = hostname()

local flakeDir = os.getenv("FLAKE_PATH")
local nixd_options = {}
if flakeDir then
  nixd_options = {
    nixos = {
      expr = '(builtins.getFlake "' .. flakeDir .. '").nixosConfigurations.' .. host .. ".options",
    },
    home_manager = {
      expr = '(builtins.getFlake "' .. flakeDir .. '").homeConfigurations.' .. host .. ".options",
    },
  }
end

lsp_server_opts["nixd"] = {
  cmd = { "nixd" },
  setttings = {
    nixd = {
      nixpkgs = {
        expr = "import <nixpkgs>{ }",
      },
      formatting = {
        command = { "nixfmt" },
      },
      options = nixd_options,
    },
  },
}

local cmp_nvim_lsp = require("cmp_nvim_lsp")
local lspconfig = require("lspconfig")
for server, config in pairs(lsp_server_opts) do
  if not config.can_start or config.can_start() then
    config.can_start = nil
    config.capabilities =
      cmp_nvim_lsp.default_capabilities(vim.lsp.protocol.make_client_capabilities())
    config.on_attach = on_attach
    lspconfig[server].setup(config)
  end
end

return {
  on_attach = on_attach,
}
