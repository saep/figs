local zellij_nav = require("zellij-nav")
zellij_nav.setup()

vim.keymap.set({ "n", "i", "t" }, "<A-j>", zellij_nav.down, { desc = "window down" })
vim.keymap.set({ "n", "i", "t" }, "<A-k>", zellij_nav.up, { desc = "window up" })
vim.keymap.set({ "n", "i", "t" }, "<A-l>", zellij_nav.right, { desc = "window right" })
vim.keymap.set({ "n", "i", "t" }, "<A-h>", zellij_nav.left, { desc = "window left" })

vim.api.nvim_create_autocmd("VimLeave", {
  pattern = "*",
  command = "silent !zellij action switch-mode normal",
})
