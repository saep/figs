-- Helper functions {{{1
local function executableOnPath(executable)
  if (vim.fn.executable(executable) == 1) then
    return executable
  else
    return nil
  end
end

local on_attach = require('saep.keys').lsp_on_attach

-- Setup lspconfig. {{{1
local capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities())
-- Haskell {{{2
require('haskell-tools').setup {
  hls = {
    on_attach = on_attach,
    settings = {
      haskell = {
        formattingProvider = 'fourmolu',
      },
    },
  },
}

-- lua {{{2
local luaLanguageServer = executableOnPath('lua-language-server')
    or executableOnPath('lua-language-server.sh')

if (luaLanguageServer ~= nil) then
  require('lspconfig')['lua_ls'].setup {
    capabilities = capabilities,
    on_attach = on_attach,
    cmd = { luaLanguageServer },
    settings = {
      Lua = {
        runtime = {
          -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
          version = 'LuaJIT',
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
        },
        -- Do not send telemetry data containing a randomized but unique identifier
        telemetry = {
          enable = false,
        },
      },
    },
  }
end

-- elm {{{2
require('lspconfig').elmls.setup {
  on_attach = on_attach
}

-- go {{{2
require('lspconfig').gopls.setup {
  on_attach = on_attach,
  settings = {
    gopls = {
      gofumpt = true
    }
  }
}

-- nix {{{2
require('lspconfig').rnix.setup {
  on_attach = on_attach
}

require('lspsaga').setup {
  symbol_in_winbar = {
    enable = true,
    separator = ' ',
    show_file = true,
    hide_keyword = true;
    folder_level = 2;
    respect_root = false;
    color_mode = true;
  },
}
