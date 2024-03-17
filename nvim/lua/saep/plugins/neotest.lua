require("neotest").setup({
	adapters = {
		require("neotest-plenary"),
		require("neotest-haskell")({
			build_tools = { "cabal" },
		}),
		require("rustaceanvim.neotest"),
	},
})
