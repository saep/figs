-- This module defines standard keybindings and returns a table that contains
-- the function 'createLspKeymapForBuffer' which should be used in 'on_attach'
-- for lsp servers.

-- Stores hydras for buffers that support LSP.
-- When an LSP server is started, the on_atach method calls
-- createLspKeymapForBuffer which will then add a hydra to this table which is
-- then used by the hydraSpace to execute buffer specific lsp actions.
local bufferSpecificLspHydras = {}

-- Set a default timeout len (/ms)
vim.opt.timeoutlen = 500
vim.g.mapleader = "\\"
vim.g.maplocalleader = "_"

vim.keymap.set("i", "jk", "<ESC>")
vim.keymap.set("i", "<C-u>", "<C-g>u<C-u>")
vim.keymap.set("i", "<C-w>", "<C-g>u<C-u>")

vim.keymap.set("n", "Q", "gqgq")
vim.keymap.set("v", "Q", "gq")

vim.keymap.set("v", ".", "<Cmd>normal .<CR>")

vim.keymap.set("t", "<C-]>", "<C-\\><C-n>")

local ls = require "luasnip"
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

local hydraTerminal = hydra {
  name = "terminal",
  mode = "n",
  config = {
    color = "blue",
    hint = {
      border = "rounded",
    },
  },
  hint = [[
  ^   Open
  ------------
  _t_: new tab
  _k_: above
  _j_: below
  _h_: left
  _l_: right
  _w_: this window  ^
  ]],
  heads = {
    { "t", "<Cmd>tabnew +term<CR>" },
    { "k", "<Cmd>sp +term<CR>" },
    { "j", "<Cmd>sp +term<CR><C-w>J" },
    { "w", "<Cmd>term<CR>" },
    { "h", "<Cmd>vsp +term<CR>" },
    { "l", "<Cmd>vsp +term<CR><C-w>L" },
    { "<Esc>", nil, { exit = true, desc = "quit" } },
  },
}

local hydraFind = hydra {
  name = "Space prefixed commands",
  mode = "n",
  config = {
    color = "blue",
    hint = {
      border = "rounded",
    }
  },
  hint = [[
  _b_: buffer     _t_: file tree browser  ^
  _f_: files
  _g_: live grep
  _h_: help tags
  ]],
  heads = {
    { "b", require('telescope.builtin').buffers },
    { "f", function() require('telescope.builtin').find_files({ follow = true }) end },
    { "g", require('telescope.builtin').live_grep },
    { "h", require('telescope.builtin').help_tags },
    { "t", "<Cmd>NvimTreeFindFileToggle<CR>" },
    { "<Esc>", nil, { exit = true, desc = "quit" } },
  }
}

local hydraRun = hydra {
  name = "Run",
  mode = "n",
  config = {
    color = "blue",
    hint = {
      border = "rounded",
    },
  },
  hint = [[
  _t_: Run tests of file
  ]],
  heads = {
    { "t",
      function()
        if vim.opt.filetype:get() == "lua" then
          vim.cmd ":write"
          require('plenary.test_harness').test_directory(vim.fn.expand("%:p"))
        end
      end
    },
    { "<Esc>", nil, { exit = true, desc = "quit" } },
  },
}

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
    { "g", "<Cmd>Neogit<CR>", { exit = true } },
    { "<Esc>", nil, { exit = true, nowait = true, desc = "exit" } },
  }
}

local hydraSpace = hydra {
  name = "Space prefixed commands",
  mode = "n",
  config = {
    color = "blue",
    hint = {
      border = "rounded",
    }
  },
  hint = [[
    _w_: window    _g_: git
    _f_: find      _b_: search buffer
    _t_: terminal
    _l_: LSP
    _r_: run
    ^
    _<space>_: alternate buffer
    _s_: :w :so
  ]],
  heads = {
    { "r", function() hydraRun:activate() end },
    { "s",
      function() vim.cmd([[
        :write
        :source
      ]] )
      end, { desc = ":w :so" } },
    { "f", function() hydraFind:activate() end },
    { "g", function() hydraGit:activate() end },
    { "b", require('telescope.builtin').buffers },
    { "l",
      function()
        local buffer = vim.api.nvim_get_current_buf()
        local lspHydra = bufferSpecificLspHydras[buffer]
        if (lspHydra) then
          lspHydra:activate()
        end
      end },
    { "t", function() hydraTerminal:activate() end },
    { "w", function() hydraWindow:activate() end },
    { "<space>", "<C-^>" },
    { "<Esc>", nil, { exit = true, desc = "quit" } },
  },
}

vim.keymap.set({ "n", "i" }, "<A-j>", "<C-w>j")
vim.keymap.set({ "n", "i" }, "<A-k>", "<C-w>k")
vim.keymap.set({ "n", "i" }, "<A-l>", "<C-w>l")
vim.keymap.set({ "n", "i" }, "<A-h>", "<C-w>h")

vim.keymap.set({ "t" }, "<A-j>", [[<C-\><C-n><C-w>j]])
vim.keymap.set({ "t" }, "<A-k>", [[<C-\><C-n><C-w>k]])
vim.keymap.set({ "t" }, "<A-l>", [[<C-\><C-n><C-w>l]])
vim.keymap.set({ "t" }, "<A-h>", [[<C-\><C-n><C-w>h]])

vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, { desc = "open diagnostics popup" })
vim.keymap.set("n", "<leader>dn", vim.diagnostic.goto_next, { desc = "next" })
vim.keymap.set("n", "<leader>dp", vim.diagnostic.goto_prev, { desc = "previous" })
vim.keymap.set("n", "<leader>dq", vim.diagnostic.setloclist, { desc = "open in location list" })

vim.keymap.set("n", "<leader>gg", "<Cmd>Git<CR>", { desc = "Git status" })
vim.keymap.set("n", "<leader>gll", "<Cmd>Gllog<CR>", { desc = "bottom location list" })
vim.keymap.set("n", "<leader>glv", "<Cmd>vertical Gllog<CR>", { desc = "vertical location list" })


vim.keymap.set("n", "<space>", function() hydraSpace:activate() end, { desc = "spacey" })

local function toggle_replace()
  local view = require "nvim-tree.view"
  if view.is_visible() then
    view.close()
  else
    require "nvim-tree".open_replacing_current_buffer()
  end
end
vim.keymap.set("n", "-", toggle_replace, { desc = "nvim-tree current buffer" })

local createLspHydraForBuffer = function(buffer)
  local opts = function(desc, args)
    local opts = { silent = true, buffer = buffer, desc = desc }
    if (args) then
      for key, value in pairs(args) do
        opts[key] = value
      end
    end
    return opts
  end
  if (buffer) then
    local codeaction = require("lspsaga.codeaction")
    bufferSpecificLspHydras[buffer] = hydra({
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
   ^ ^                     _t_: type_definition
  ]]   ,
      heads = {
        { "f", function() vim.lsp.buf.format { async = true } end, opts("format buffer") },
        { "d", vim.lsp.buf.definition, opts("definition") },
        { "D", vim.lsp.buf.declaration, opts("declaration") },
        { "i", vim.lsp.buf.implementation, opts("implementation") },
        { "r", require("lspsaga.rename").rename, opts("rename") },
        { "t", vim.lsp.buf.type_definition, opts("type defintion") },
        { "u", vim.lsp.buf.references, opts("usages") },
        { "a", codeaction.code_action, opts("code action") },
        { "a",
          function()
            vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<C-U>", true, false, true))
            codeaction.range_code_action()
          end,
          opts("code action")
        },
        { "<Esc>", nil, { exit = true, desc = "quit" } },
      },
    })
  end
end

-- Used in the on_attach callback when configuring lsp providers to provide LSP
-- keybindings only when an LSP is installed.
local createLspKeymapForBuffer = function(buffer)
  local opts = function(desc, args)
    local opts = { silent = true, buffer = buffer, desc = desc }
    if (args) then
      for key, value in pairs(args) do
        opts[key] = value
      end
    end
    return opts
  end
  vim.keymap.set("n", "K", require("lspsaga.hover").render_hover_doc, opts("hover docs"))
  local action = require("lspsaga.action")
  vim.keymap.set("n", "<C-f>", function()
    action.smart_scroll_with_saga(1)
  end, opts("scroll down in preview"))
  vim.keymap.set("n", "<C-b>", function()
    action.smart_scroll_with_saga(-1)
  end, opts("scroll up in preview"))

  -- See `:help vim.lsp.*` for documentation on any of the below functions
  -- vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bufopts)
  -- vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
  -- vim.keymap.set('n', '<space>wl', function()
  --   print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  -- end, opts("vim inspect"))
  createLspHydraForBuffer(buffer)

  -- TODO lspsaga jump to diagnostic and jump to error
  local hasLspsagaDefinition, lspsagaDefinition = pcall(require, "lspsaga.definition")
  if (hasLspsagaDefinition) then
    vim.keymap.set("n", "<leader>lp", lspsagaDefinition.preview_definition, opts("preview definition"))
  end

  local hasLspsagaSignature, lspsagaSignature = pcall(require, "lspsaga.signature")
  if (hasLspsagaSignature) then
    vim.keymap.set("n", "<leader>ls", lspsagaSignature.signature_help, opts("preview definition"))
  else
    vim.keymap.set("n", "<leader>ls", vim.lsp.buf.signature_help, opts("signature help"))
  end

end
return {
  createLspKeymapForBuffer = createLspKeymapForBuffer;
}
