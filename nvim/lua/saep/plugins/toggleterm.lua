require("toggleterm").setup({
	open_mapping = [[<C-t>]],
	float_opts = {
		border = "curved",
		width = vim.o.columns - 4,
		height = vim.o.lines - 6,
	},
})
