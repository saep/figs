vim.keymap.set("n", "<Localleader>x", "<cmd>RustTest<cr>")
vim.keymap.set("n", "<Localleader>t", function()
	vim.cmd([[RustTest!]])
end)
