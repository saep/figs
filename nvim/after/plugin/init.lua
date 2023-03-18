require("saep.orgmode")
require("saep.cmp")
require("saep.lsp")

if vim.g.neovide then
  require("saep.neovide")
end

require("saep.keys")

-- Appearance
vim.opt.background = "dark"
vim.cmd "highlight WinSeparator guibg=None"
vim.opt.hlsearch = false
vim.o.ch = 0 -- comand height: Removes bottom line of nothingness
vim.o.laststatus = 2


-- Figure out highlighting group
function SynStack()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local linenr = cursor[1]
  local columnnr = cursor[2] + 1
  for _, synID in ipairs(vim.call("synstack", linenr, columnnr)) do
    local i2 = vim.call("synIDtrans", synID)
    local n1 = vim.call("synIDattr", synID, "name")
    local n2 = vim.call("synIDattr", i2, "name")
    vim.api.nvim_echo({ [1] = { n1 .. "->" .. n2 } }, nil, {})
  end
end

-- Fix saving spell checking by prepending a specific writable directory to the runtimepath.
vim.opt.rtp:prepend('~/.local/share/nvim/site/')
