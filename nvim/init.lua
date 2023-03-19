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
  {
    "nvim-treesitter/nvim-treesitter",
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
    },
    config = function()
      local parserPath = vim.fn.stdpath "cache" .. "treesitter"

      vim.opt.runtimepath:append(parserPath)

      require('nvim-treesitter.configs').setup({
        parser_install_dir = parserPath,
        ensure_installed = {
          "bash",
          "haskell",
          "help",
          "lua",
          "markdown",
          "markdown_inline",
          "org",
          "nix",
          "vim",
        },
        sync_install = false,
        auto_install = true,
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false
        },
        textobjects = {
          select = {
            enable = true,
            disable = { "fennel" },
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
    end
  },
  {
    "nvim-telescope/telescope.nvim", branch = "0.1.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope-project.nvim",
      "nvim-telescope/telescope-file-browser.nvim",
    },
    init = function()
      require("telescope").load_extension("project")
    end
  },
  {
    "folke/which-key.nvim",
    config = true,
    opts = {
      plugins = {
        presets = {
          windows = false,
          nav = false,
        }
      },
    },
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
    ft = { "fennel", "lua", },
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
  {
    "glepnir/lspsaga.nvim",
    opts = {
      symbol_in_winbar = {
        enable = true,
        separator = ' ',
        show_file = true,
        hide_keyword = true,
        folder_level = 2,
        respect_root = false,
        color_mode = true,
      },
    },
  },
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
    opts = function()
      return {
        hls = {
          on_attach = require("saep.keys").lsp_on_attach,
          settings = {
            haskell = {
              formattingProvider = 'fourmolu',
            },
          },
        },
      }
    end,
  },
  {
    "L3MON4D3/LuaSnip"
  },
  "hrsh7th/cmp-nvim-lsp",
  "hrsh7th/cmp-buffer",
  "hrsh7th/cmp-path",
  "hrsh7th/cmp-cmdline",
  {
    "hrsh7th/nvim-cmp",
    config = function()
      local cmp = require("cmp")
      vim.opt.completeopt = "menu,menuone,noselect"
      cmp.setup {
        snippet = {
          expand = function(args)
            require("luasnip").lsp_expand(args.body)
          end,
        },
        window = {
          -- completion = cmp.config.window.bordered(),
          -- documentation = cmp.config.window.bordered(),
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping.scroll_docs( -4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete({}),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "nvim_lua" },
          { name = "luasnip" },
          { name = "orgmode" },
        }, {
          { name = "buffer" },
        })
      }
      -- Set configuration for specific filetype.
      cmp.setup.filetype("gitcommit", {
        sources = cmp.config.sources({
          { name = "cmp_git" },
        }, {
          { name = "buffer" },
        })
      })

      -- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
      cmp.setup.cmdline("/", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = "buffer" }
        }
      })

      -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = "path" }
        }, {
          { name = "cmdline" }
        })
      })
    end,
  },
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
  },
  {
    "nvim-lualine/lualine.nvim",
    opts = {
      options = {
        icons_enabled = true,
        theme = 'auto',
        component_separators = { left = '', right = '' },
        section_separators = { left = '', right = '' },
        disabled_filetypes = {},
        always_divide_middle = true,
        globalstatus = false,
      },
      sections = {
        lualine_a = { 'mode' },
        lualine_b = { 'branch', 'diff', 'diagnostics' },
        lualine_c = { 'filename' },
        lualine_x = { 'encoding', 'fileformat', 'filetype' },
        lualine_y = { 'progress' },
        lualine_z = { 'location' }
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { 'filename' },
        lualine_x = { 'location' },
        lualine_y = {},
        lualine_z = {}
      },
      tabline = {},
      extensions = {}
    },
  },
  {
    "nvim-orgmode/orgmode",
    config = true,
    init = function()
      require("orgmode").setup_ts_grammar()
    end
  },
})

P = function(t)
  print(vim.inspect(t))
  return t
end

require("saep.settings")
