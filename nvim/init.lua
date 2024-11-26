-- nushell settings
-- taken from: https://github.com/nushell/integrations/blob/main/nvim/init.lua
vim.opt.sh = "nu"
vim.opt.shelltemp = false
vim.opt.shellredir = "out+err> %s"
vim.opt.shellcmdflag = "--stdin --no-newline -c"
vim.opt.shellxescape = ""
vim.opt.shellxquote = ""
vim.opt.shellquote = ""
vim.opt.shellpipe =
	"| complete | update stderr { ansi strip } | tee { get stderr | save --force --raw %s } | into record"

vim.loader.enable()

P = function(t)
	print(vim.inspect(t))
	return t
end

require("saep.lsp")

local float_term_win = nil
function Float_term(opts)
	if float_term_win then
		pcall(vim.api.nvim_win_close, float_term_win, true)
		float_term_win = nil
		return
	end
	opts = opts or {}

	local buf = vim.api.nvim_create_buf(false, true)
	-- vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = buf })
	vim.api.nvim_set_option_value("modifiable", false, { buf = buf })

	local height = math.ceil(vim.o.lines * 0.85)
	local width = math.ceil(vim.o.columns * 0.95)
	float_term_win = vim.api.nvim_open_win(buf, true, {
		style = "minimal",
		relative = "editor",
		width = width,
		height = height,
		row = math.ceil((vim.o.lines - height) / 2),
		col = math.ceil((vim.o.columns - width) / 2),
		border = "rounded",
	})

	vim.api.nvim_set_current_win(float_term_win)

	vim.fn.termopen({ "nu" }, {
		on_exit = function(_, _, _)
			if vim.api.nvim_win_is_valid(float_term_win) then
				vim.api.nvim_win_close(float_term_win, true)
			end
			float_term_win = nil
		end,
	})
	vim.cmd.startinsert()
end
