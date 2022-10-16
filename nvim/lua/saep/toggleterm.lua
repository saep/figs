require("toggleterm").setup {
  open_mapping = [[<C-t>]],
  float_opts = {
    border = 'curved'
  },
}

local Terminal = require("toggleterm.terminal").Terminal

local lazygit = Terminal:new {
  cmd = "lazygit",
  hidden = true,
  direction = "float",
}

local lazigitToggle = function()
  lazygit:toggle()
end

vim.keymap.set({ "n", "i", "t" }, "<C-g>", lazigitToggle)
