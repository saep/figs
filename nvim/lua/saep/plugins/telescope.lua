local telescope = require("telescope")
telescope.setup({
  defaults = {
    layout_strategy = "flex",
    layout_config = {
      prompt_position = "bottom",
      flip_columns = 160,
      width = 0.99,
      height = 0.99,
    },
  },
  extensions = {
    ["ui-select"] = {
    }
  }
})

telescope.load_extension("ui-select")
