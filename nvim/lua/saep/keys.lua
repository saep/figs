-- Set a default timeout length (/ms) which is used by which-key to delay displaying key bindings
vim.opt.timeoutlen = 250
vim.g.mapleader = " "

-- Set localleader to <BS>
vim.g.maplocalleader = "\\"
vim.api.nvim_set_keymap("n", "<BS>", ":WhichKey \\<cr>", { noremap = true, silent = true })
-- The below definition works, but which-key doesn't work with that and sometimes plugins
-- act weird with such a local leader.
-- vim.g.maplocalleader = vim.api.nvim_replace_termcodes("<BS>", false, false, true)

local map = function(description, modes, lhs, rhs, opts)
	opts = opts or {}
	opts.desc = description
	vim.keymap.set(modes, lhs, rhs, opts)
end

require("which-key").setup({
	preset = "modern",
	plugins = {
		spelling = {
			enabled = false,
		},
		presets = {
			windows = false,
			nav = false,
		},
	},
})

map("local leader", { "n" }, "<LocalLeader>", "<cmd>lua require'which-key'.show('<LocalLeader>', {mode='n'})<cr>")

map("ESC", "i", "jk", "<ESC>")
map("format gqgq", "n", "Q", "gqgq")
map("format gq", "v", "Q", "gq")
map("repeat", "v", ".", "<Cmd>normal .<CR>")
map("ESC", "t", "<C-]>", "<C-\\><C-n>")
map("join lines", "n", "J", "mzJ`z")
map(":wall", "n", "<leader>s", "<Cmd>wall<CR>")
map("n and center", "n", "n", function()
	vim.api.nvim_feedkeys("nzz", "n", true)
end)
map("N and center", "n", "N", function()
	vim.api.nvim_feedkeys("Nzz", "n", true)
end)

map("move selection down", "v", "J", ":m '>+1<CR>gv=gv")
map("move selection up", "v", "K", ":m '<-2<CR>gv=gv")

map("window down", "n", "<A-j>", "<C-w>j")
map("window down", "i", "<A-j>", "<C-o><C-w>j<Esc>")
map("window up", "n", "<A-k>", "<C-w>k")
map("window up", "i", "<A-k>", "<C-o><C-w>k<Esc>")
map("window right", "n", "<A-l>", "<C-w>l")
map("window right", "i", "<A-l>", "<C-o><C-w>l<Esc>")
map("window left", "n", "<A-h>", "<C-w>h")
map("window left", "i", "<A-h>", "<C-o><C-w>h<Esc>")

map("window down", "n", "<leader>wj", "<C-w>j")
map("window up", "n", "<leader>wk", "<C-w>k")
map("window right", "n", "<leader>wl", "<C-w>l")
map("window left", "n", "<leader>wh", "<C-w>h")
map("window only", "n", "<leader>wo", "<C-w>o")
map("window close", "n", "<leader>wc", "<Cmd>quit<CR>")
map("window delete buffer", "n", "<leader>wd", function()
	require("mini.bufremove").wipeout()
end)
map("window delete buffer", "n", "<leader>wu", function()
	require("mini.bufremove").unshow_in_window()
end)
for i = 1, 9 do
	map("window " .. i, "n", "<leader>" .. i, i .. "<C-w>w")
	map("window " .. i, "n", "<A-" .. i .. ">", i .. "<C-w>w")
	map("window " .. i, "t", "<A-" .. i .. ">", [[<C-\><C-n>]] .. i .. [[<C-w>w]])
end

map("zen-mode", "n", "<Leader>wz", function()
	require("zen-mode").toggle({})
end)

map("window down", { "t" }, "<A-j>", [[<C-\><C-n><C-w>j]])
map("window up", { "t" }, "<A-k>", [[<C-\><C-n><C-w>k]])
map("window right", { "t" }, "<A-l>", [[<C-\><C-n><C-w>l]])
map("window left", { "t" }, "<A-h>", [[<C-\><C-n><C-w>h]])

map("yank to clipboard", { "n", "v" }, "Y", [["+y]])

map("previous buffer", "n", "<leader><space>", "<C-^>")

-- debug and diagnostics
map("open diagnostics popup", "n", "<leader>dd", vim.diagnostic.open_float)
map("next", "n", "<leader>dn", vim.diagnostic.goto_next)
map("previous", "n", "<leader>dp", vim.diagnostic.goto_prev)
map("open diagnostics in location list", "n", "<leader>dq", vim.diagnostic.setloclist)

map("set breakpoint", "n", "<Leader>db", require("dap").toggle_breakpoint)
map("continue", "n", "<Leader>dc", require("dap").continue)
map("step over", "n", "<Leader>do", require("dap").step_over)
map("step into", "n", "<Leader>di", require("dap").step_into)
map("launch debugging session", "n", "<Leader>ds", function()
	local ft = vim.o.filetype
	if ft == "lua" then
		require("osv").launch({ port = 8086 })
	else
		print("No debugger configured for filetype " .. ft)
	end
end)
map("toggle dapui", "n", "<Leader>du", require("dapui").toggle)

map("spell suggestion", "n", "z=", function()
	require("telescope.builtin").spell_suggest(require("telescope.themes").get_cursor({}))
end)

map("find buffer", "n", "<leader>b", require("telescope.builtin").buffers)
map("find buffer", "n", "<leader>fb", require("telescope.builtin").buffers)
map("find files", "n", "<leader>ff", function()
	require("telescope.builtin").find_files({ follow = true })
end)
map("live grep", "n", "<leader>fg", require("telescope.builtin").live_grep)
map("neovim help", "n", "<leader>fh", require("telescope.builtin").help_tags)
map("textcase", { "n", "v" }, "ga.", "<Cmd>TextCaseOpenTelescope<CR>")

map("quickfix next", "n", "]q", function()
	vim.api.nvim_command("cnext")
end)
map("quickfix prev", "n", "[q", function()
	vim.api.nvim_command("cprevious")
end)

map("loclist next", "n", "]l", function()
	vim.api.nvim_command("lnext")
end)
map("loclist prev", "n", "[l", function()
	vim.api.nvim_command("lprevious")
end)

map("diagnostic next", "n", "]e", function()
	vim.api.nvim_command("Lspsaga diagnostic_jump_next")
end)
map("diagnostic prev", "n", "[e", function()
	vim.api.nvim_command("Lspsaga diagnostic_jump_prev")
end)

map("oi", "n", "-", require("oil").open)

local ls = require("luasnip")
map("next in snippet", { "i", "s" }, "<C-j>", function()
	if ls.expand_or_jumpable() then
		ls.expand_or_jump()
	end
end, { silent = true })
map("prev in snippet", { "i", "s" }, "<C-k>", function()
	if ls.jumpable(-1) then
		ls.jump(-1)
	end
end, { silent = true })
map("change snippet choice", { "i", "s" }, "<C-l>", function()
	if ls.choice_active() then
		ls.change_choice(1)
	end
end)
map("edit snippet", { "n" }, "<Leader>fs", function()
	require("luasnip.loaders").edit_snippet_files()
end)

map("neogit", "n", "<leader>gg", "<cmd>Neogit<cr>")
map("neogit", "n", "<leader>gl", "<cmd>Neogit log<cr>")

map("floating terminal", { "n", "t" }, "<A-t>", Float_term)

local http_group = vim.api.nvim_create_augroup("http_autocommands", { clear = true })
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	pattern = { "*.http" },
	callback = function()
		if vim.o.filetype ~= "http" then
			vim.o.filetype = "http"
		end
	end,
	group = http_group,
})
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "http" },
	callback = function(ev)
		map("http request under cursor", "n", "<LocalLeader>t", "<cmd>Rest run<cr>", { buffer = ev.buf })
		map("http request last", "n", "<LocalLeader>x", "<cmd>Rest run last<cr>")
		map("http request last", "n", "<LocalLeader>e", require("telescope").extensions.rest.select_env)
	end,
	group = http_group,
})
