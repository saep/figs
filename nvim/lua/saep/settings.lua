vim.opt.tildeop = true
vim.opt.undofile = true
vim.opt.inccommand = "nosplit"
vim.opt.mouse = "a"
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 2
vim.opt.scrolloff = 8
vim.opt.updatetime = 300
vim.opt.shortmess = vim.opt.shortmess + "Wc"
vim.opt.wildignore = vim.opt.wildignore + "*.bak,*~,*.o,*.hi,*.swp,*.so,*.aux,*.xlsx,*.ods"
vim.opt.errorbells = false
vim.opt.visualbell = false
vim.opt.diffopt = vim.opt.diffopt + "iwhite"
vim.opt.formatoptions = vim.opt.formatoptions - "ao"
vim.opt.formatoptions = vim.opt.formatoptions + "cqtnjr"
vim.opt.swapfile = false
vim.opt.spelllang = "en_us,de_de"
vim.opt.spellfile = vim.fn.stdpath("cache") .. "/ende.utf-8.add"
vim.o.pumblend = 15
vim.o.pumheight = 15
vim.o.winblend = 15
vim.o.signcolumn = "yes"
vim.o.number = true
vim.o.relativenumber = true

vim.opt.background = "dark"
vim.cmd "highlight WinSeparator guibg=None"
vim.opt.hlsearch = false
vim.o.ch = 1 -- comand height: Removes bottom line of nothingness if set to 0, but causes too many Hit-Enter-Prompts currently :-(
vim.o.laststatus = 2

local function go_to_last_known_position()
  if ((vim.fn.line("'\"") > 1) and (vim.fn.line("'\"") <= vim.fn.line("$"))) then
    return vim.api.nvim_command("exe \"normal! g`\\\"\"")
  else
    return nil
  end
end

vim.api.nvim_create_augroup("vimrcEx", {})
vim.api.nvim_create_autocmd({ "BufReadPost" },
  {
    callback = go_to_last_known_position,
    desc = "Go to last known position when opening a buffer",
    group = "vimrcEx",
    pattern = "*"
  })

return {}
