local function executableOnPath(executable)
  if (vim.fn.executable(executable) == 1) then
    return executable
  else
    return nil
  end
end

-- on_attach function for language servers
--
-- This sets up keybindings which only work when a language server is used.
---@param client any
---@param bufnr any
---@diagnostic disable-next-line client is unused, but required for the on_attach signature
local on_attach = function(client, bufnr)
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
    -- vim.keymap.set("n", "K", "<cmd>Lspsaga hover_doc<CR>", opts("hover docs"))
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts("hover docs"))
    vim.keymap.set("n", "H", "<cmd>Lspsaga show_cursor_diagnostics<CR>", opts("cursor diagnostics"))
    vim.keymap.set("n", "L", "<cmd>Lspsaga show_line_diagnostics<CR>", opts("line diagnostics"))

    -- See `:help vim.lsp.*` for documentation on any of the below functions
    -- vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bufopts)
    -- vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
    -- vim.keymap.set('n', '<space>wl', function()
    --   print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    -- end, opts("vim inspect"))
    vim.keymap.set({ "n" }, "<Leader>ll", vim.lsp.codelens.run, opts("code lens"))
    vim.keymap.set({ "n" }, "<Leader>lf", function() vim.lsp.buf.format { async = false } end, opts("format buffer"))
    vim.keymap.set({ "n" }, "<Leader>ld", vim.lsp.buf.definition, opts("definition"))
    vim.keymap.set({ "n" }, "<Leader>lD", vim.lsp.buf.declaration, opts("declaration"))
    vim.keymap.set({ "n" }, "<Leader>li", vim.lsp.buf.implementation, opts("implementation"))
    vim.keymap.set({ "n" }, "<Leader>lr", "<cmd>Lspsaga rename<CR>", opts("rename"))
    -- vim.keymap.set({ "n" }, "<Leader>lr", vim.lsp.buf.rename, opts("rename"))
    vim.keymap.set({ "n" }, "<Leader>lt", vim.lsp.buf.type_definition, opts("type definition"))
    vim.keymap.set({ "n" }, "<Leader>lu", vim.lsp.buf.references, opts("usages"))
    vim.keymap.set({ "n" }, "<Leader>lc", "<cmd>Lspsaga code_action<CR>", opts("code action"))
    -- vim.keymap.set({ "n" }, "<Leader>lc", vim.lsp.buf.code_action, opts("code action"))
    vim.keymap.set({ "n" }, "<Leader>lp", "<cmd>Lspsaga peek_definition<CR>", opts("peek definition"))
    -- vim.keymap.set({ "n" }, "<Leader>dl", "<cmd>Lspsaga show_line_diagnostics<Cr>", opts("show line diagnostics"))
    -- vim.keymap.set({ "n" }, "<Leader>dc", "<cmd>Lspsaga show_cursor_diagnostics<Cr>", opts("show line diagnostics"))
  end
end

local capabilities = require('cmp_nvim_lsp')
    .default_capabilities(vim.lsp.protocol.make_client_capabilities())

local luaLanguageServer = executableOnPath('lua-language-server')
    or executableOnPath('lua-language-server.sh')

if (luaLanguageServer ~= nil) then
  require('lspconfig')['lua_ls'].setup {
    capabilities = capabilities,
    on_attach = on_attach,
    cmd = { luaLanguageServer },
    settings = {
      Lua = {
        runtime = {
          -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
          version = 'LuaJIT',
        },
        diagnostics = {
          -- Get the language server to recognize the `vim` global
          globals = {
            "vim",

            -- Busted
            "after_each",
            "assert",
            "before_each",
            "clear",
            "describe",
            "it",
            "pending",
            "teardown",
          },
        },
        workspace = {
          -- Make the server aware of Neovim runtime files
          library = vim.api.nvim_get_runtime_file("", true),
          checkThirdParty = false,
        },
        -- Do not send telemetry data containing a randomized but unique identifier
        telemetry = {
          enable = false,
        },
      },
    },
  }
end

require('lspconfig').elmls.setup {
  on_attach = on_attach
}

require('lspconfig').gopls.setup {
  on_attach = on_attach,
  settings = {
    gopls = {
      gofumpt = true
    }
  }
}

require('lspconfig').rnix.setup {
  on_attach = on_attach
}

require('lspconfig').tailwindcss.setup {
  on_attach = on_attach
}

return {
  on_attach = on_attach
}
