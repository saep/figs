require("conform").setup({
	formatters_by_ft = {
		haskell = { "fourmolu" },
		lua = { "stylua" },
		sql = { "pg_format" },
	},
	format_on_save = {
		timeout_ms = 500,
		lsp_fallback = true,
	},
})
