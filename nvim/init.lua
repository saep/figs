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
  {
    "folke/noice.nvim",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
  },
  {
    "Olical/aniseed",
    init = function()
      local aniseed_compiled_lua_directory = vim.fn.stdpath("cache") .. "/aniseed"
      vim.opt.rtp:append(aniseed_compiled_lua_directory)
      vim.g['aniseed#env'] = {
        output = aniseed_compiled_lua_directory .. "/lua",
      }
    end,
  },
  "Olical/conjure",
  {
    "eraserhd/parinfer-rust",
    build = 'nix-shell --run \"cargo build --release \"',
  },
  "windwp/nvim-autopairs",
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
    "L3MON4D3/LuaSnip"
  },
  "hrsh7th/cmp-nvim-lsp",
  "hrsh7th/cmp-buffer",
  "hrsh7th/cmp-path",
  "hrsh7th/cmp-cmdline",
  "hrsh7th/nvim-cmp",
  {
    "PaterJason/cmp-conjure",
    dependencies = {
      "Olical/conjure",
      "Olical/aniseed",
    },
  },
  "saadparwaiz1/cmp_luasnip",
  { "catppuccin/nvim", name = "catppuccin" },
  "nvim-tree/nvim-web-devicons",
  "nvim-lualine/lualine.nvim",
  "nvim-orgmode/orgmode",
})

P = function(t)
  print(vim.inspect(t))
  return t
end

require("saep.settings")
