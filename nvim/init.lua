-- This config is used together with home manager. It therefore lacks
-- initialization of plugins because the home manager configuration sets up the
-- plugins and they can therefore be freely used here. If you were to use this
-- without nix and home manager, you would have to load the plugins in some way:
-- e.g. by using packer or vim-plug

P = function(t)
  print(vim.inspect(t))
  return t
end

-- Helper functions {{{1
local function executableOnPath(executable)
  if (vim.fn.executable(executable) == 1) then
    return executable
  else
    return nil
  end
end

-- Key bindings {{{1

local on_attach = function(_ --[[client]] , bufnr)

  require('lsp_signature').on_attach({
    bind = true,
    handler_opts = {
      border = "rounded"
    }
  }, bufnr)

  -- Enable completion triggered by <c-x><c-o>
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  require("saep.keys").createLspKeymapForBuffer(bufnr)

end



-- General Behavior {{{1
local HOME = os.getenv("HOME")
vim.opt.tildeop = true
vim.opt.undofile = true
vim.opt.inccommand = "nosplit"
vim.opt.mouse = "a"

vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 2

vim.opt.updatetime = 300
vim.opt.shortmess = vim.opt.shortmess + "c"
vim.opt.wildignore = vim.opt.wildignore + "*.bak,*~,*.o,*.hi,*.swp,*.so,*.aux,*.xlsx,*.ods"
vim.opt.errorbells = false
vim.opt.visualbell = false
vim.opt.diffopt = vim.opt.diffopt + "iwhite"
vim.opt.formatoptions = vim.opt.formatoptions - "ao"
vim.opt.formatoptions = vim.opt.formatoptions + "cqtnjr"
vim.opt.swapfile = false
vim.opt.spelllang = "en_us,de_de"
vim.opt.spellfile = HOME .. "/.cache/nvim/ende.utf-8.add"

local goToLastKnownPosition = function()
  if vim.fn.line("'\"") > 1 and vim.fn.line("'\"") <= vim.fn.line("$") then
    vim.api.nvim_command([[exe "normal! g`\""]])
  end
end
vim.api.nvim_create_augroup("vimrcEx", {})
vim.api.nvim_create_autocmd({ "BufReadPost" }, {
  desc = "Go to last known position when opening a buffer",
  group = "vimrcEx",
  pattern = "*",
  callback = goToLastKnownPosition
})


-- Completion {{{2

vim.opt.completeopt = "menu,menuone,noselect"

-- Setup plugins {{{1
require('gitsigns').setup()

-- Setup lspconfig. {{{1
local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())
-- Haskell {{{2
require('lspconfig')['hls'].setup {
  capabilities = capabilities,
  on_attach = on_attach
}

-- lua {{{2
local luaLanguageServer = executableOnPath('lua-language-server')
    or executableOnPath('lua-language-server.sh')

if (luaLanguageServer ~= nil) then
  require('lspconfig')['sumneko_lua'].setup {
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
            "describe",
            "it",
            "before_each",
            "after_each",
            "teardown",
            "pending",
            "clear",
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
  on_attach = on_attach
}

-- nix {{{2
require('lspconfig').rnix.setup {
  on_attach = on_attach
}

-- treesitter {{{1
require('nvim-treesitter.configs').setup({
  sync_install = false,
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false
  },
  textobjects = {
    select = {
      enable = true,
      keymaps = {
        -- You can use the capture groups defined in textobjects.scm
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        ["ac"] = "@class.outer",
        ["ic"] = "@class.inner",
        ["ia"] = "@parameter.inner",
        ["aa"] = "@parameter.outer",
      },
    },
  },
})

-- 1}}}
-- file tree {{{1
require('nvim-tree').setup {
  hijack_netrw = false -- still using vim-vinegar
}
-- hex color highlighter {{{1
vim.opt.termguicolors = false
require('colorizer').setup {}

-- vim: foldmethod=marker
