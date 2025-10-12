require("nvim-treesitter.configs").setup({
  ensure_installed = {},
  ignore_install = { "all" },
  modules = {},
  sync_install = false,
  auto_install = false,
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
  textobjects = {
    select = {
      enable = true,
      lookahead = true,
      keymaps = {
        ["af"] = { query = "@function.outer", desc = "outer function" },
        ["if"] = { query = "@function.inner", desc = "inner function" },

        -- Hack for xml files
        ["at"] = { query = "@function.outer", desc = "outer tag" },
        ["it"] = { query = "@function.inner", desc = "inner tag" },

        ["aa"] = { query = "@parameter.outer", desc = "outer param" },
        ["ia"] = { query = "@parameter.inner", desc = "inner param" },

        ["ac"] = { query = "@class.outer", desc = "outer class" },
      },
      selection_modes = {
        -- charwise
        ["@parameter.outer"] = "v",
        ["@parameter.inner"] = "v",

        -- linewise
        ["@function.outer"] = "V",
        ["@function.inner"] = "V",

        --blockwise
        ["@class.outer"] = "<c-v>",
      },
    },
  },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = "<Right>", -- set to `false` to disable one of the mappings
      node_incremental = "<Up>",
      scope_incremental = "<Left>",
      node_decremental = "<Down>",
    },
  },
})
