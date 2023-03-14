(module saep.neotest
  {autoload {neotest neotest
             neotest-haskell neotest-haskell}})
(neotest.setup {:adapters [(neotest-haskell {:build_tools ["cabal"]})]})

