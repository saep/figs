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
    init = function()
      require("telescope").load_extension("project")
    end
  },
  {
    "folke/which-key.nvim",
    config = true,
  },
  {
    "folke/noice.nvim",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
    opts = {
      override = {
        ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
        ["vim.lsp.util.stylize_markdown"] = true,
        ["cmp.entry.get_documentation"] = true,
      },
      -- you can enable a preset for easier configuration
      presets = {
        bottom_search = true, -- use a classic bottom cmdline for search
        command_palette = true, -- position the cmdline and popupmenu together
        long_message_to_split = true, -- long messages will be sent to a split
        inc_rename = false, -- enables an input dialog for inc-rename.nvim
        lsp_doc_border = false, -- add a border to hover docs and signature help
      },
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
  {
    "PaterJason/cmp-conjure",
    dependencies = {
      "Olical/conjure",
      "Olical/aniseed",
    },
    ft = { "fennel", },
  },
  {
    "eraserhd/parinfer-rust",
    build = 'nix-shell --run \"cargo build --release \"',
  },
  {
    "windwp/nvim-autopairs",
    config = true,
  },
  "neovim/nvim-lspconfig",
  "glepnir/lspsaga.nvim",
  "tpope/vim-fugitive",
  {
    "lewis6991/gitsigns.nvim",
    config = true,
  },
  "anuvyklack/hydra.nvim",
  "folke/trouble.nvim",
  {
    "nvim-tree/nvim-tree.lua",
    config = true,
    opts = {
      view = {
        mappings = {
          list = {
            { key = "<CR>", action = "edit_in_place" },
          },
        },
      },
    },
  },
  {
    "nvim-tree/nvim-web-devicons",
    dependencies = {
      "nvim-tree/nvim-tree.lua",
    },
  },
  {
    "akinsho/toggleterm.nvim",
    opts = {
      open_mapping = [[<C-t>]],
      float_opts = {
        border = 'curved'
      },
    },
  },
  "tpope/vim-commentary",
  "tpope/vim-speeddating",
  "tpope/vim-surround",
  "tpope/vim-unimpaired",
  "tpope/vim-repeat",
  "tommcdo/vim-exchange",
  {
    "nvim-neotest/neotest",
    dependencies = {
      -- Note that these are not dependencies of neotest, but put here as these
      -- plugins are specifically for neotest and I want the configuration to
      -- be here
      "mrcjkb/neotest-haskell",
    },
    ft = { "haskell" },
    config = true,
    opts = function()
      return {
        adapters = {
          require("neotest-haskell") {
            build_tools = { "cabal" },
          }
        },
      }
    end,
  },
  {
    "ggandor/leap.nvim",
    init = function()
      require("leap").add_default_mappings()
    end,
  },
  {
    'mrcjkb/haskell-tools.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope.nvim',
    },
    branch = '1.x.x',
    ft = { "cabal", "haskell", },
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
  {
    "catppuccin/nvim",
    name = "catppuccin",
    config = true,
    opts = {
      flavour = "mocha",
      compile_path = vim.fn.stdpath "cache" .. "/catpuccin"
    },
    init = function()
      vim.cmd.colorscheme "catppuccin"
    end,
  },
  "nvim-lualine/lualine.nvim",
  "nvim-orgmode/orgmode",
})

P = function(t)
  print(vim.inspect(t))
  return t
end

require("saep.settings")
