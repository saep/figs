require("conform").setup({
	formatters_by_ft = {
		haskell = { "fourmolu", "ormolu" },
		lua = { "stylua" },
		nix = { "nixfmt" },
		sql = { "pg_format" },
	},
	format_on_save = {
		timeout_ms = 500,
		lsp_fallback = true,
	},
})
