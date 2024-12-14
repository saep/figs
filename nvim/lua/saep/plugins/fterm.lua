require("FTerm").setup({
  cmd = "nu",
  border = "double",
  dimensions = {
    height = 0.9,
    width = 0.9,
  },
})

-- Example keybindings
vim.keymap.set("n", "<A-t>", '<CMD>lua require("FTerm").toggle()<CR>')
vim.keymap.set("t", "<A-t>", '<C-\\><C-n><CMD>lua require("FTerm").toggle()<CR>')
