-- Set a default timeout length (/ms) which is used by which-key to delay displaying key bindings
vim.opt.timeoutlen = 250
vim.g.mapleader = " "

-- Set localleader to <BS>
vim.g.maplocalleader = "\\"
vim.keymap.set({ "v", "n", "x" }, "<BS>", ":WhichKey \\<cr>", { silent = true })
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
map("window delete buffer", "n", "<leader>wd", Snacks.bufdelete.delete)

map("zen-mode", "n", "<Leader>wz", Snacks.zen.zen)

map("window down", { "t" }, "<A-j>", [[<C-\><C-n><C-w>j]])
map("window up", { "t" }, "<A-k>", [[<C-\><C-n><C-w>k]])
map("window right", { "t" }, "<A-l>", [[<C-\><C-n><C-w>l]])
map("window left", { "t" }, "<A-h>", [[<C-\><C-n><C-w>h]])

local create_tabs_up_to = function(n)
  local tab_pages = vim.api.nvim_list_tabpages()
  while #tab_pages < n do
    vim.cmd.tabnew()
    tab_pages = vim.api.nvim_list_tabpages()
  end
end

for i = 1, 9 do
  map("tab " .. i, { "i", "n", "v" }, "<A-" .. i .. ">", function()
    create_tabs_up_to(i)
    vim.api.nvim_feedkeys(i .. "gt", "n", true)
  end)
  map("tab " .. i, { "t" }, "<A-" .. i .. ">", function()
    create_tabs_up_to(i)
    local key = vim.api.nvim_replace_termcodes([[<C-\><C-n>]] .. i .. "gt", true, false, true)
    vim.api.nvim_feedkeys(key, "n", false)
  end)
end

map("magic prev", { "n", "v" }, "<C-,>", function()
  local actions = {
    { vim.cmd.cprev, {} },
    { vim.cmd.lprev, {} },
    { vim.diagnostic.jump, { count = -1, float = true } },
  }
  for _, f in ipairs(actions) do
    local ok, _ = pcall(f[1], f[2])
    if ok then
      return
    end
  end
end)
map("magic next", { "n", "v" }, "<C-.>", function()
  local actions = {
    { vim.cmd.cnext, {} },
    { vim.cmd.lnext, {} },
    { vim.diagnostic.jump, { count = 1, float = true } },
  }
  for _, f in ipairs(actions) do
    local ok, _ = pcall(f[1], f[2])
    if ok then
      return
    end
  end
end)
map("magic close", { "n", "v" }, "<C-/>", function()
  local current_tab_windows = vim.iter(vim.api.nvim_tabpage_list_wins(0))
  if current_tab_windows:any(function(w)
    return vim.fn.win_gettype(w) == "quickfix"
  end) then
    vim.cmd.cclose()
    return
  end
  local actions = {
    { vim.cmd.lclose, {} },
  }
  for _, f in ipairs(actions) do
    local ok, _ = pcall(f[1], f[2])
    if ok then
      return
    end
  end
end)

map("yank to clipboard", { "n", "v" }, "Y", [["+y]])

map("previous buffer", "n", "<leader><space>", "<C-^>")

map("floating terminal", { "n", "t" }, "<A-f>", function()
  Snacks.terminal.toggle("nu")
end)
map("bottom terminal", { "n", "t" }, "<A-t>", function()
  Snacks.terminal.toggle()
end)

-- debug and diagnostics
map("open diagnostics popup", "n", "<leader>dd", vim.diagnostic.open_float)
map("next", "n", "<leader>dn", function()
  vim.diagnostic.jump({ count = 1, float = true })
end)
map("previous", "n", "<leader>dp", function()
  vim.diagnostic.jump({ count = -1, float = true })
end)
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

map("find buffer", "n", "<leader>b", require("fzf-lua").buffers)
map("find buffer", "n", "<leader>fb", require("fzf-lua").buffers)
map("find files", "n", "<leader>ff", require("fzf-lua").files)
map("live grep", "n", "<leader>fg", require("fzf-lua").live_grep)
map("neovim help", "n", "<leader>fh", require("fzf-lua").help_tags)

map("diagnostic next", "n", "]e", function()
  vim.diagnostic.jump({ count = 1, float = true })
end)
map("diagnostic prev", "n", "[e", function()
  vim.diagnostic.jump({ count = -1, float = true })
end)

map("leap", { "n", "x", "o" }, "s", "<Plug>(leap)")
map("leap from window", "n", "S", "<Plug>(leap-from-window)")

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
map("neogit", "n", "<A-g>", "<cmd>Neogit<cr>")
map("neogit", "n", "<leader>gl", "<cmd>Neogit log<cr>")
map("blame line", { "n", "v" }, "<leader>gb", Snacks.git.blame_line)

map("test nearest", "n", "<Leader>tt", require("neotest").run.run)
map("test file", "n", "<Leader>tf", function()
  require("neotest").run.run(vim.fn.expand("%"))
end)
map("test debug", "n", "<Leader>td", function()
  require("neotest").run.run({ strategy = "dap" })
end)
map("test summary", "n", "<Leader>ts", require("neotest").summary.toggle)
map("test output", "n", "<Leader>to", require("neotest").output.open)

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
