require("conform").setup({
	formatters_by_ft = {
		gleam = { "gleam format" },
		haskell = { "fourmolu", "ormolu" },
		lua = { "stylua" },
		markdown = { "prettier" },
		nix = { "nixfmt" },
		rust = { "cargo fmt" },
		sql = { "pg_format" },
	},
	format_on_save = {
		timeout_ms = 500,
		lsp_fallback = true,
	},
})
