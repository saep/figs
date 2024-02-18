require("neotest").setup {
  adapters = {
    require("neotest-haskell") {
      build_tools = { "cabal" },
    },
    require("neotest-rust") {
    },
    -- once available require('rustaceanvim.neotest') ,
  },
}
