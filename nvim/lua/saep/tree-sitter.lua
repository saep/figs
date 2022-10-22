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

