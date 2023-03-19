vim.keymap.set(
  { "n" },
  "<Leader>lh",
  function()
    require('haskell-tools').hoogle.hoogle_signature()
  end,
  { desc = "hoogle signature search" }
)
