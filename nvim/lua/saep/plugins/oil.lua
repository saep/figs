local detail = false
require("oil").setup({
  -- Temporarily set to false if you have netrw issues (e.g. when trying to download spell files)
  -- default_file_explorer = false,
  keymaps = {
    ["gd"] = {
      desc = "Toggle file detail view",
      callback = function()
        detail = not detail
        if detail then
          require("oil").set_columns({ "icon", "permissions", "size", "mtime" })
        else
          require("oil").set_columns({ "icon" })
        end
      end,
    },
  },
})
