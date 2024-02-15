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
    ["ui-select"] = {
    },
    ["project"] = {
      on_project_selected = function(prompt_bufnr)
        require("telescope._extensions.project.actions").change_working_directory(prompt_bufnr, false)
        require("neogit").open()
      end
    },
  }
})

telescope.load_extension("ui-select")
telescope.load_extension('project')
