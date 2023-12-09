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
    pin = true,
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
      "nvim-treesitter/nvim-treesitter-context",
    },
    config = function()
      local parserPath = vim.fn.stdpath "cache" .. "treesitter"

      vim.opt.runtimepath:append(parserPath)

      require('nvim-treesitter.configs').setup({
        parser_install_dir = parserPath,
        ensure_installed = {
          "bash",
          "haskell",
          "markdown",
          "markdown_inline",
          "org",
          "nix",
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
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope-project.nvim",
      "nvim-telescope/telescope-file-browser.nvim",
    },
    config = function()
      require("telescope").load_extension("project")
      require("telescope").setup({
        defaults = {
          layout_strategy = "flex",
          layout_config = {
            prompt_position = "bottom",
            flip_columns = 160,
            width = 0.99,
            height = 0.99,
          },
        },

      })
    end,
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
  "eraserhd/parinfer-rust",
  {
    "windwp/nvim-ts-autotag",
    config = true,
  },
  {
    "neovim/nvim-lspconfig",
  },
  {
    "simrat39/rust-tools.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "mfussenegger/nvim-dap",
    },
    ft = { "rust", },
    config = function()
      local rt = require("rust-tools")
      rt.setup({
        server = {
          settings = {
            ["rust-analyzer"] = {
              cargo = {
                features = "all",
              }
            },
          },
          on_attach = function(client, bufnr)
            require("saep.lsp").on_attach(client, bufnr)
            -- Hover actions
            vim.keymap.set("n", "<C-space>", rt.hover_actions.hover_actions, { buffer = bufnr })
            -- Code action groups
            vim.keymap.set("n", "<Leader>a", rt.code_action_group.code_action_group, { buffer = bufnr })
          end,
        },
      })
    end,
  },
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
  "norcalli/nvim-colorizer.lua",
  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",         -- required
      "nvim-telescope/telescope.nvim", -- optional
      "sindrets/diffview.nvim",        -- optional
      "ibhagwan/fzf-lua",              -- optional
    },
    config = {
      disable_hint = true,
    },
  },
  {
    "lewis6991/gitsigns.nvim",
    config = true,
  },
  "anuvyklack/hydra.nvim",
  {
    "stevearc/oil.nvim",
    opts = {},
    dependencies = { "nvim-tree/nvim-web-devicons" },
  },
  {
    "akinsho/toggleterm.nvim",
    opts = {
      open_mapping = [[<C-t>]],
      float_opts = {
        border = "curved"
      },
    },
  },
  {
    "echasnovski/mini.nvim",
    config = function()
      require("mini.bufremove").setup {}
      require("mini.comment").setup {}
      require("mini.jump").setup {
        mapping = {
          repeat_jump = nil,
        },
      }
      require("mini.jump2d").setup {}
      require("mini.surround").setup {
        highlight_duration = 300,
        search_method = "cover_or_next",
      }
      require("mini.align").setup {}
    end
  },
  "tpope/vim-speeddating",
  "tpope/vim-repeat",
  "tommcdo/vim-exchange",
  "mg979/vim-visual-multi",
  {
    "nvim-neotest/neotest",
    dependencies = {
      -- Note that these are not dependencies of neotest, but put here as these
      -- plugins are specifically for neotest and I want the configuration to
      -- be here
      "mrcjkb/neotest-haskell",
      "rouge8/neotest-rust",
    },
    ft = { "haskell" },
    config = true,
    opts = function()
      return {
        adapters = {
          require("neotest-haskell") {
            build_tools = { "cabal" },
          },
          require("neotest-rust") {
          },
        },
      }
    end,
  },
  {
    "mrcjkb/haskell-tools.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
    },
    version = "^3",
    ft = { "cabal", "haskell", "cabalproject", },
    init = function()
      vim.g.haskell_tools = {
        hls = {
          on_attach = function(client, bufnr, ht)
            require("saep.lsp").on_attach(client, bufnr)
          end,
          settings = {
            haskell = {
              formattingProvider = "fourmolu",
              plugin = {
                fourmolu = {
                  config = {
                    external = true,
                  }
                },
              },
            },
          },
        },
      }
    end,
  },
  {
    "L3MON4D3/LuaSnip",
  },
  {
    "saadparwaiz1/cmp_luasnip",
    dependencies = {
      "L3MON4D3/LuaSnip",
    },
  },
  "hrsh7th/cmp-nvim-lsp",
  "hrsh7th/cmp-nvim-lua",
  "hrsh7th/cmp-buffer",
  "hrsh7th/cmp-path",
  "hrsh7th/cmp-cmdline",
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "L3MON4D3/LuaSnip",
    },
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
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
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
        lualine_a = { 'require("saep.next").current()', 'mode' },
        lualine_b = { 'branch', 'diff', 'diagnostics' },
        lualine_c = {
          {
            function()
              return tostring(vim.fn.winnr())
            end
          },
          'filename'
        },
        lualine_x = { 'encoding', 'fileformat', 'filetype' },
        lualine_y = { 'progress' },
        lualine_z = { 'location' }
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {
          {
            function()
              return tostring(vim.fn.winnr())
            end
          },
          'filename',
        },
        lualine_x = {},
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
  {
    "rest-nvim/rest.nvim",
    config = function()
      require("rest-nvim").setup({
        -- Open request results in a horizontal split
        result_split_horizontal = false,
        -- Keep the http file buffer above|left when split horizontal|vertical
        result_split_in_place = false,
        -- Skip SSL verification, useful for unknown certificates
        skip_ssl_verification = false,
        -- Encode URL before making request
        encode_url = true,
        -- Highlight request on run
        highlight = {
          enabled = true,
          timeout = 150,
        },
        result = {
          -- toggle showing URL, HTTP info, headers at top the of result window
          show_url = true,
          -- show the generated curl command in case you want to launch
          -- the same request via the terminal (can be verbose)
          show_curl_command = true,
          show_http_info = true,
          show_headers = true,
          -- executables or functions for formatting response body [optional]
          -- set them to false if you want to disable them
          formatters = {
            json = "jq",
            html = function(body)
              return vim.fn.system({ "tidy", "-i", "-q", "-" }, body)
            end
          },
        },
        -- Jump to request line on run
        jump_to_request = false,
        env_file = '.env',
        custom_dynamic_variables = {},
        yank_dry_run = true,
      })
    end
  },
})

P = function(t)
  print(vim.inspect(t))
  return t
end
