local telescope = require("telescope")
telescope.setup({
  defaults = {
    layout_strategy = "flex",
    layout_config = {
      prompt_position = "bottom",
      width = 0.99,
      height = 0.99,
    },
  },
  picker = {
    layout_config = {
      flip_columns = 160,
    },
  },
  extensions = {
    ["ui-select"] = {},
  },
})

telescope.load_extension("fzf")
telescope.load_extension("ui-select")
telescope.load_extension("textcase")
telescope.load_extension("rest")
