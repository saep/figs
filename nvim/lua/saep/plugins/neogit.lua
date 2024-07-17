require("neogit").setup({
	disable_hint = true,
	graph_style = "unicode",
	mappings = {
		status = {
			[";"] = "OpenOrScrollDown",
			[","] = "OpenOrScrollUp",
		},
	},
})
