-- default values
require("spider").setup({
  skipInsignificantPunctuation = true,
  consistentOperatorPending = false, -- see the README for details
  subwordMovement = true,
  customPatterns = {}, -- see the README for details
})

vim.keymap.set({ "n", "o", "x" }, "w", "<cmd>lua require('spider').motion('w')<CR>")
vim.keymap.set({ "n", "o", "x" }, "e", "<cmd>lua require('spider').motion('e')<CR>")
vim.keymap.set({ "n", "o", "x" }, "b", "<cmd>lua require('spider').motion('b')<CR>")
