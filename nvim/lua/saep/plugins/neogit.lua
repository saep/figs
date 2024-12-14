require("neogit").setup({
  kind = "floating",
  disable_hint = true,
  graph_style = "unicode",
  mappings = {
    status = {
      [";"] = "OpenOrScrollDown",
      [","] = "OpenOrScrollUp",
    },
  },
})
