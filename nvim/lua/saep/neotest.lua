require("neotest").setup {
  adapters = {
    require("neotest-haskell") {
      build_tools = { "cabal" },
    },
    require("neotest-rust") {
    },
  },
}
