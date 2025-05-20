require("neogit").setup({
  kind = "tab",
  disable_hint = true,
  graph_style = "unicode",
  mappings = {
    status = {
      [";"] = "OpenOrScrollDown",
      [","] = "OpenOrScrollUp",
    },
  },
})
