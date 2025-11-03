require("catppuccin").setup({
  flavour = "mocha",
  compile_path = vim.fn.stdpath("cache") .. "/catpuccin",
  highlight_overrides = {
    mocha = function(mocha)
      return {
        Comment = { fg = mocha.text },
      }
    end,
  },
})
