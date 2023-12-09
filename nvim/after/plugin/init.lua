require("saep.catppuccin")
require("saep.lsp")
require("saep.settings")

if vim.g.neovide then
  require("saep.neovide")
end

require("saep.cmp")
require("saep.mini")
require("saep.lualine")
require("saep.neogit")
require("saep.neotest")
require("orgmode").setup_ts_grammar()
require("saep.rest")
require("saep.snippets")
require("oil").setup()
require("saep.telescope")
require("saep.toggleterm")
require("saep.treesitter")

require("saep.keys")

-- Must be set here for some reason as the hydras aren't colored otherwise
vim.cmd.colorscheme("catppuccin")

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
