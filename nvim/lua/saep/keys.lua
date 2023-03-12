-- This module defines standard keybindings and returns a table that contains
-- the function 'createLspKeymapForBuffer' which should be used in 'on_attach'
-- for lsp servers.

local wk = require("which-key")
wk.setup {
}

-- Set a default timeout len (/ms)
vim.opt.timeoutlen = 500
vim.g.mapleader = " "
vim.g.maplocalleader = vim.api.nvim_replace_termcodes('<BS>', false, false, true)

local map = function(description, modes, lhs, rhs)
  vim.keymap.set(modes, lhs, rhs, { desc = description })
end

map("ESC", "i", "jk", "<ESC>")
map("format gqgq", "n", "Q", "gqgq")
map("format gq", "v", "Q", "gq")
map("repeat", "v", ".", "<Cmd>normal .<CR>")
map("ESC", "t", "<C-]>", "<C-\\><C-n>")
map("join lines", "n", "J", "mzJ`z")

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

map("window down", { "t" }, "<A-j>", [[<C-\><C-n><C-w>j]])
map("window up", { "t" }, "<A-k>", [[<C-\><C-n><C-w>k]])
map("window right", { "t" }, "<A-l>", [[<C-\><C-n><C-w>l]])
map("window left", { "t" }, "<A-h>", [[<C-\><C-n><C-w>h]])

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
map("nvim-tree", "n", "<leader>ft", "<Cmd>NvimTreeFindFileToggle<CR>")
map("find project ", "n", "<leader>fp", require('telescope').extensions.project.project)

-- t -- test bindings
map("neotest run nearest", "n", "<Leader>tt", function() require('neotest').run.run() end)
map("neotest open output", "n", "<Leader>to", function() require('neotest').output.open() end)
map("neotest summary", "n", "<Leader>ts", function() require('neotest').summary.toggle() end)

local function toggle_replace()
  local view = require "nvim-tree.view"
  if view.is_visible() then
    view.close()
  else
    require("nvim-tree").open_replacing_current_buffer()
  end
end

map("nvim-tree current buffer", "n", "-", toggle_replace)


local ls = require("luasnip")
vim.keymap.set({ "i", "s" }, "<C-j>", function()
  if (ls.expand_or_jumpable()) then
    ls.expand_or_jump()
  end
end, { desc = "next in snippet", silent = true })
vim.keymap.set({ "i", "s" }, "<C-k>", function()
  if (ls.jumpable(-1)) then
    ls.jump(-1)
  end
end,
  { desc = "prev in snippet", silent = true })

local hydra = require "hydra"
local hydraWindow = hydra {
  name = "Window",
  mode = { "n" },
  config = {
    color = "red",
    hint = {
      border = "rounded",
    }
  },
  hint = [[
   Move   ^^^^^  Swap  ^^^^^     Resize
  ------- ^^^^^------- ^^^^^ --------------
  ^   _k_ ^^      _K_  ^^^       _<C-k>_
   _h_   _l_   _H_   _L_ ^^  _<C-h>_   _<C-l>_
  ^   _j_   ^^    _J_    ^^^     _<C-j>_
  ^^^^^^^^^^                
  ^
   Open              Split
  ---------------   ---------------  ^
   _f_: file         _s_: horizontally
   _b_: buffer       _v_: vertically
   _t_: terminal     _o_: only
   _g_: live grep    _c_: close
  ^^                 _=_: equalize
  ]],
  heads = {
    { "h", "<C-w>h" },
    { "H", "<C-w>H" },
    { "<C-h>", "<Cmd>winc <<CR>", },
    { "j", "<C-w>j" },
    { "J", "<C-w>J" },
    { "<C-j>", "<Cmd>winc -<CR>", },
    { "k", "<C-w>k" },
    { "<C-k>", "<Cmd>winc +<CR>" },
    { "K", "<C-w>K" },
    { "l", "<C-w>l" },
    { "<C-l>", "<Cmd>winc ><CR>", },
    { "L", "<C-w>L" },
    { "o", "<Cmd>only<CR>" },
    { "c", "<Cmd>q<CR>" },
    { "s", "<Cmd>sp<CR>" },
    { "v", "<Cmd>vsp<CR>" },
    { "b", "<Cmd>Telescope buffers<CR>", { exit = true } },
    { "f", "<Cmd>Telescope find_files<CR>", { exit = true } },
    { "g", "<Cmd>Telescope live_grep<CR>", { exit = true } },
    { "t", "<Cmd>term<CR>", { exit = true } },
    { "=", "<C-w>=" },
    { "<Esc>", nil, { exit = true, desc = "quit" } },
  }
}
map("persistent window hydra", "n", "<C-w>", function() hydraWindow:activate() end)

local gitsigns = require "gitsigns"
local hydraGit = hydra {
  name = "Git",
  hint = [[
  _J_: next hunk   _s_: stage hunk        _d_: show deleted   _b_: blame line
  _K_: prev hunk   _u_: undo last stage   _p_: preview hunk   _B_: blame show full  ^
  ^ ^              _S_: stage buffer      ^ ^                 
  ^
  ^ ^              _g_: status              
   ]],
  config = {
    color = "pink",
    invoke_on_body = true,
    hint = {
      border = "rounded"
    },
    on_enter = function()
      if pcall(vim.cmd, "mkview") then
        vim.cmd "silent! %foldopen!"
        vim.bo.modifiable = false
        gitsigns.toggle_signs(true)
        gitsigns.toggle_linehl(true)
      end
    end,
    on_exit = function()
      local cursor_pos = vim.api.nvim_win_get_cursor(0)
      if pcall(vim.cmd, "loadview") then
        vim.api.nvim_win_set_cursor(0, cursor_pos)
        vim.cmd "normal zv"
        gitsigns.toggle_signs(false)
        gitsigns.toggle_linehl(false)
        gitsigns.toggle_deleted(false)
      end
    end,
  },
  mode = { "n", "x" },
  heads = {
    { "J",
      function()
        if vim.wo.diff then return "]c" end
        vim.schedule(function() gitsigns.next_hunk() end)
        return "<Ignore>"
      end
    },
    { "K",
      function()
        if vim.wo.diff then return "[c" end
        vim.schedule(function() gitsigns.prev_hunk() end)
        return "<Ignore>"
      end,
    },
    { "s", "<Cmd>Gitsigns stage_hunk<CR>", { silent = true } },
    { "u", gitsigns.undo_stage_hunk },
    { "S", gitsigns.stage_buffer },
    { "p", gitsigns.preview_hunk },
    { "d", gitsigns.toggle_deleted, { nowait = true } },
    { "b", gitsigns.blame_line },
    { "B", function() gitsigns.blame_line { full = true } end },
    { "g", "<Cmd>Git<CR>", { exit = true } },
    { "<Esc>", nil, { exit = true, nowait = true, desc = "exit" } },
  }
}
map("Git hydra", "n", "<leader>g", function() hydraGit:activate() end)

vim.keymap.set("n", "[e", "<cmd>Lspsaga diagnostic_jump_prev<CR>", { silent = true, desc = "previous diagnostic" })
vim.keymap.set("n", "]e", "<cmd>Lspsaga diagnostic_jump_next<CR>", { silent = true, desc = "next diagnostic" })

-- on_attach function for language servers
--
-- This sets up keybindings which only work when a language server is used.
---@param client any
---@param bufnr any
---@diagnostic disable-next-line client is unused, but required for the on_attach signature
local lsp_on_attach = function(client, bufnr)
  local opts = function(desc, args)
    local opts = { silent = true, buffer = bufnr, desc = desc }
    if (args) then
      for key, value in pairs(args) do
        opts[key] = value
      end
    end
    return opts
  end
  if (bufnr) then
    vim.keymap.set("n", "<Leader>u", vim.lsp.buf.references, opts("usages"))
    vim.keymap.set("n", "K", "<cmd>Lspsaga hover_doc<CR>", opts("hover docs"))
    vim.keymap.set("n", "H", "<cmd>Lspsaga show_cursor_diagnostics<CR>", opts("cursor diagnostics"))
    vim.keymap.set("n", "L", "<cmd>Lspsaga show_line_diagnostics<CR>", opts("line diagnostics"))

    -- See `:help vim.lsp.*` for documentation on any of the below functions
    -- vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bufopts)
    -- vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
    -- vim.keymap.set('n', '<space>wl', function()
    --   print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    -- end, opts("vim inspect"))

    local lspHydra = hydra({
      name = "LSP",
      mode = "n",
      config = {
        color = "blue",
        hint = {
          border = "rounded",
        }
      },
      hint = [[
      commands              goto
  ------------------  ^^  -------------------  ^
   _f_: format buffer      _d_: definition
   _r_: rename             _D_: declaration
   _u_: usages             _i_: implementation
   _l_: code lens          _t_: type_definition
   _h_: hoogle             _p_: peek definition
   _c_: code action
  ]]   ,
      heads = {
        { "l", vim.lsp.codelens.run, opts("code lens") },
        { "f", function() vim.lsp.buf.format { async = false } end, opts("format buffer") },
        { "d", vim.lsp.buf.definition, opts("definition") },
        { "D", vim.lsp.buf.declaration, opts("declaration") },
        { "h", require('haskell-tools').hoogle.hoogle_signature, opts("hoogle") },
        { "i", vim.lsp.buf.implementation, opts("implementation") },
        { "r", "<cmd>Lspsaga rename<CR>", opts("rename") },
        { "t", vim.lsp.buf.type_definition, opts("type defintion") },
        { "u", vim.lsp.buf.references, opts("usages") },
        { "c", "<cmd>Lspsaga code_action<CR>", opts("code action") },
        { "p", "<cmd>Lspsaga peek_definition<CR>", opts("preview definition") },
        { "<Esc>", nil, { exit = true, desc = "quit" } },
      },
    })
    vim.keymap.set("n", "<Leader>l", function() lspHydra:activate() end, opts("lsp commands"))
  end
end

return {
  lsp_on_attach = lsp_on_attach,
}
