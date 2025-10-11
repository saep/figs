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
  textObjects = {
    select = {
      keymaps = {
        ["at"] = "@function.outer",
        ["it"] = "@function.inner",
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
