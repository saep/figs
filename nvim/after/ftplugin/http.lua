vim.keymap.set({ "n" }, "<LocalLeader>hr", "<cmd>Rest run<cr>", { buffer = true })
vim.keymap.set({ "n" }, "<LocalLeader>hh", "<cmd>Rest last<cr>", { buffer = true })
vim.keymap.set({ "n" }, "<LocalLeader>ho", "<cmd>Rest open<cr>", { buffer = true })
vim.keymap.set({ "n" }, "<LocalLeader>hl", "<cmd>Rest logs<cr>", { buffer = true })
vim.keymap.set({ "n" }, "<LocalLeader>hc", "<cmd>Rest cookies<cr>", { buffer = true })
vim.keymap.set({ "n" }, "<LocalLeader>hee", "<cmd>Rest env show<cr>", { buffer = true })
vim.keymap.set(
  { "n" },
  "<LocalLeader>hes",
  require("telescope").extensions.rest.select_env,
  { buffer = true }
)
