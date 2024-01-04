local next = require("saep.next")

-- Set a default timeout len (/ms) which is used by which-key to dealy displaying key bindings
vim.opt.timeoutlen = 250
vim.g.mapleader = " "
vim.g.maplocalleader = vim.api.nvim_replace_termcodes('<BS>', false, false, true)

local map = function(description, modes, lhs, rhs, opts)
  opts = opts or {}
  opts.desc = description
  vim.keymap.set(modes, lhs, rhs, opts)
end

require("which-key").setup {
  plugins = {
    presets = {
      windows = false,
      nav = false,
    }
  },
}


map("local leader", { "n" }, "<LocalLeader>", "<cmd>lua require'which-key'.show('<LocalLeader>', {mode='n'})<cr>")

map("ESC", "i", "jk", "<ESC>")
map("format gqgq", "n", "Q", "gqgq")
map("format gq", "v", "Q", "gq")
map("repeat", "v", ".", "<Cmd>normal .<CR>")
map("ESC", "t", "<C-]>", "<C-\\><C-n>")
map("join lines", "n", "J", "mzJ`z")
map(":wall", "n", "<leader>s", "<Cmd>wall<CR>")
map("n and center", "n", "n", function() vim.api.nvim_feedkeys("nzz", "n", true) end)
map("N and center", "n", "N", function() vim.api.nvim_feedkeys("Nzz", "n", true) end)

map("move selection down", "v", "J", ":m '>+1<CR>gv=gv")
map("move selection up", "v", "K", ":m '<-2<CR>gv=gv")

map("window down", { "n", "i" }, "<A-j>", "<C-w>j")
map("window up", { "n", "i" }, "<A-k>", "<C-w>k")
map("window right", { "n", "i" }, "<A-l>", "<C-w>l")
map("window left", { "n", "i" }, "<A-h>", "<C-w>h")

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

map("window down", { "t" }, "<A-j>", [[<C-\><C-n><C-w>j]])
map("window up", { "t" }, "<A-k>", [[<C-\><C-n><C-w>k]])
map("window right", { "t" }, "<A-l>", [[<C-\><C-n><C-w>l]])
map("window left", { "t" }, "<A-h>", [[<C-\><C-n><C-w>h]])

map("yank to clipboard", { "n", "v" }, "Y", [["+y]])

map("previous buffer", "n", "<leader><space>", "<C-^>")

map("open diagnostics popup", "n", "<leader>d", vim.diagnostic.open_float)
map("next", "n", "<leader>dn", vim.diagnostic.goto_next)
map("previous", "n", "<leader>dp", vim.diagnostic.goto_prev)
map("open in location list", "n", "<leader>dq", vim.diagnostic.setloclist)

map("find buffer", "n", "<leader>b", require('telescope.builtin').buffers)
map("find buffer", "n", "<leader>fb", require('telescope.builtin').buffers)
map("find files", "n", "<leader>ff", function() require('telescope.builtin').find_files({ follow = true }) end)
map("live grep", "n", "<leader>fg", require('telescope.builtin').live_grep)
map("neovim help", "n", "<leader>fh", require('telescope.builtin').help_tags)

map("next thing", "n", ";", function() next.next() end)
map("previous thing", "n", ",", function() next.prev() end)
map("close thing ", "n", "[", function() next.close() end)
map("select thing", "n", "]]", function() next.select_in_telescope() end)
map("next diagnostic", "n", "]e", function()
  next.push(next.actions.lspsaga_diagnostic)
  next.next()
end)
map("next qf item", "n", "]q", function()
  next.push(next.actions.qf)
  next.next()
end, { silent = true, })
map("next loc item", "n", "]l", function()
  next.push(next.actions.loclist)
  next.next()
end, { silent = true })

-- t -- test bindings
map("neotest run nearest", "n", "<leader>tt", function()
  vim.api.nvim_command("silent write")
  require('neotest').run.run()
end)
map("neotest run file", "n", "<leader>tf", function()
  vim.api.nvim_command("silent write")
  require("neotest").run.run(vim.fn.expand("%"))
end)
map("neotest open output", "n", "<leader>to", function() require('neotest').output.open() end)
map("neotest summary", "n", "<leader>ts", function() require('neotest').summary.toggle() end)

map("oi", "n", "-", require("oil").open)

local ls = require("luasnip")
map("next in snippet", { "i", "s" }, "<C-j>", function()
  if (ls.expand_or_jumpable()) then
    ls.expand_or_jump()
  end
end, { silent = true })
map("prev in snippet", { "i", "s" }, "<C-k>", function()
    if (ls.jumpable(-1)) then
      ls.jump(-1)
    end
  end,
  { silent = true })
map("change snippet choice", { "i", "s" }, "<C-l>", function()
  if ls.choice_active() then
    ls.change_choice(1)
  end
end)
map("edit snippet", { "n" }, "<Leader>fs", function()
  require("luasnip.loaders").edit_snippet_files()
end)

map("neogit", "n", "<leader>gg", "<cmd>Neogit<cr>")
