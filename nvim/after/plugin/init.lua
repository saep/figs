require("saep.orgmode")
require("saep.noice")
require("saep.toggleterm")
require("saep.cmp")
require("saep.nvim-tree")
require("saep.lsp")
require("saep.gitsigns")
require("saep.tree-sitter")
require("saep.neotest")
require('leap').add_default_mappings()
require("saep.project")
require("saep.autopairs")

if vim.g.neovide then
  require("saep.neovide")
end

require("saep.keys")

-- Appearance {{{1
vim.opt.background = "dark"
vim.cmd "highlight WinSeparator guibg=None"
vim.opt.hlsearch = false
vim.o.ch = 0 -- comand height: Removes bottom line of nothingness
vim.o.laststatus = 2

require("catppuccin").setup {
  flavour = "mocha";
  compile_path = vim.fn.stdpath "cache" .. "/catpuccin"
}
vim.cmd.colorscheme "catppuccin"

-- Figure out highlighting group {{{2
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

-- options for nvim-lualine/lualine.nvim {{{2
require('lualine').setup {
  options = {
    icons_enabled = true,
    theme = 'auto',
    component_separators = { left = '', right = '' },
    section_separators = { left = '', right = '' },
    disabled_filetypes = {},
    always_divide_middle = true,
    globalstatus = false,
  },
  sections = {
    lualine_a = { 'mode' },
    lualine_b = { 'branch', 'diff', 'diagnostics' },
    lualine_c = { 'filename' },
    lualine_x = { 'encoding', 'fileformat', 'filetype' },
    lualine_y = { 'progress' },
    lualine_z = { 'location' }
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = { 'filename' },
    lualine_x = { 'location' },
    lualine_y = {},
    lualine_z = {}
  },
  tabline = {},
  extensions = {}
}

-- Fix saving spell checking by prepending a specific writable directory to the runtimepath.
vim.opt.rtp:prepend('~/.local/share/nvim/site/')
