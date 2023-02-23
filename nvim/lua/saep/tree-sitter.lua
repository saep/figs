local parserPath = vim.fn.stdpath "cache" .. "treesitter"

vim.opt.runtimepath:append(parserPath)

require('nvim-treesitter.configs').setup({
  parser_install_dir = parserPath,
  ensure_installed = {"lua", "haskell", "vim", "help", "nix"},
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

