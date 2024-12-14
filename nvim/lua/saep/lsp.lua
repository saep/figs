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
    vim.keymap.set({ "n" }, "<Leader>ll", vim.lsp.codelens.run, opts("code lens"))
    vim.keymap.set({ "n" }, "<Leader>lf", function()
      vim.lsp.buf.format({ async = false })
    end, opts("format buffer"))
    vim.keymap.set({ "n" }, "<Leader>ld", vim.lsp.buf.definition, opts("definition"))
    vim.keymap.set({ "n" }, "<Leader>lD", vim.lsp.buf.declaration, opts("declaration"))
    vim.keymap.set({ "n" }, "<Leader>li", vim.lsp.buf.implementation, opts("implementation"))
    vim.keymap.set({ "n" }, "<Leader>r", vim.lsp.buf.rename, opts("rename"))
    vim.keymap.set({ "n" }, "<Leader>lr", vim.lsp.buf.rename, opts("rename"))
    vim.keymap.set({ "n" }, "<Leader>lt", vim.lsp.buf.type_definition, opts("type definition"))
    vim.keymap.set({ "n" }, "<Leader>lu", vim.lsp.buf.references, opts("usages"))
    vim.keymap.set({ "n" }, "<Leader>lc", vim.lsp.buf.code_action, opts("code action"))
  end
end

local capabilities =
  require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())

local luaLanguageServer = executableOnPath("lua-language-server")
  or executableOnPath("lua-language-server.sh")

if luaLanguageServer ~= nil then
  require("lspconfig")["lua_ls"].setup({
    capabilities = capabilities,
    on_attach = on_attach,
    cmd = { luaLanguageServer },
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
  })
end

require("lspconfig").bashls.setup({
  on_attach = on_attach,
  capabilities = capabilities,
})

require("lspconfig").clojure_lsp.setup({
  on_attach = on_attach,
  capabilities = capabilities,
})

require("lspconfig").elmls.setup({
  on_attach = on_attach,
  capabilities = capabilities,
})

require("lspconfig").gopls.setup({
  on_attach = on_attach,
  settings = {
    gopls = {
      gofumpt = true,
    },
  },
})

if executableOnPath("tailwindcss-language-server") then
  require("lspconfig").tailwindcss.setup({
    on_attach = on_attach,
  })
end

if executableOnPath("ngserver") then
  require("lspconfig").angularls.setup({
    on_attach = on_attach,
    capabilities = capabilities,
  })
end

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
require("lspconfig").nixd.setup({
  cmd = { "nixd" },
  setttings = {
    nixd = {
      nixpkgs = {
        expr = "import <nixpkgs>{ }",
      },
      formatting = {
        command = { "nixfmt" },
      },
      options = {
        nixos = {
          expr = '(builtins.getFlake "'
            .. flakeDir
            .. '").nixosConfigurations.'
            .. host
            .. ".options",
        },
        home_manager = {
          expr = '(builtins.getFlake "'
            .. flakeDir
            .. '").homeConfigurations.'
            .. host
            .. ".options",
        },
      },
    },
  },
  on_attach = on_attach,
  capabilities = capabilities,
})

require("lspconfig").nushell.setup({
  on_attach = on_attach,
  capabilities = capabilities,
})

require("lspconfig").ts_ls.setup({
  on_attach = on_attach,
  capabilities = capabilities,
})

require("lspconfig").eslint.setup({
  on_attach = on_attach,
  capabilities = capabilities,
})

require("lspconfig").gleam.setup({
  on_attach = on_attach,
  capabilities = capabilities,
})

require("lspconfig").html.setup({
  on_attach = on_attach,
  capabilities = capabilities,
})

require("lspconfig").cssls.setup({
  on_attach = on_attach,
  capabilities = capabilities,
})

require("lspconfig").dhall_lsp_server.setup({
  on_attach = on_attach,
})

require("lspconfig")["hls"].setup({
  on_attach = on_attach,
  capabilities = capabilities,
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
})

require("lspconfig").rust_analyzer.setup({
  on_attach = on_attach,
  capabilities = capabilities,
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
})
