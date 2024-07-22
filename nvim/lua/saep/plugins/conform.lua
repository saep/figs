require("conform").setup({
	formatters_by_ft = {
		gleam = { "gleam format" },
		haskell = { "fourmolu", "ormolu" },
		lua = { "stylua" },
		nix = { "nixfmt" },
		sql = { "pg_format" },
		rust = { "cargo fmt" },
	},
	format_on_save = {
		timeout_ms = 500,
		lsp_fallback = true,
	},
})
