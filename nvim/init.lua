-- This config is used together with home manager. It therefore lacks
-- initialization of plugins because the home manager configuration sets up the
-- plugins and they can therefore be freely used here. If you were to use this
-- without nix and home manager, you would have to load the plugins in some way:
-- e.g. by using packer or vim-plug

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)


require("lazy").setup({
  "nvim-lua/plenary.nvim",
  "nvim-treesitter/nvim-treesitter",
  "nvim-treesitter/nvim-treesitter-textobjects",
  {
    "nvim-telescope/telescope.nvim", branch = "0.1.x",
    dependencies = { "nvim-lua/plenary.nvim", },
  },
  {
    "nvim-telescope/telescope-project.nvim",
    dependencies = {
      "nvim-telescope/telescope.nvim",
      "nvim-telescope/telescope-file-browser.nvim",
    },
  },
  "folke/which-key.nvim",
  "neovim/nvim-lspconfig",
  "glepnir/lspsaga.nvim",
  "nvim-neotest/neotest",
  "tpope/vim-fugitive",
  "lewis6991/gitsigns.nvim",
  "anuvyklack/hydra.nvim",
  "folke/trouble.nvim",
  "nvim-tree/nvim-tree.lua",
  "tpope/vim-commentary",
  "akinsho/toggleterm.nvim",
  "tpope/vim-speeddating",
  "tpope/vim-surround",
  "tpope/vim-unimpaired",
  "tpope/vim-repeat",
  "tommcdo/vim-exchange",
  "mrcjkb/neotest-haskell",
  "ggandor/leap.nvim",
  {
     'mrcjkb/haskell-tools.nvim',
      dependencies = {
        'nvim-lua/plenary.nvim',
        'nvim-telescope/telescope.nvim',
      },
      branch = '1.x.x',
  },
  {
    "L3MON4D3/LuaSnip",
    build = "make install_jsregexp",
  },
  "hrsh7th/cmp-nvim-lsp",
  "hrsh7th/cmp-buffer",
  "hrsh7th/cmp-path",
  "hrsh7th/cmp-cmdline",
  "hrsh7th/nvim-cmp",
  "saadparwaiz1/cmp_luasnip",
  { "catppuccin/nvim", name = "catppuccin" },
  "nvim-tree/nvim-web-devicons",
  "nvim-lualine/lualine.nvim",
  "nvim-orgmode/orgmode",
}) --

P = function(t)
  print(vim.inspect(t))
  return t
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
vim.opt.scrolloff = 8

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
