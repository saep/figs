local cmp = require("cmp")
vim.opt.completeopt = "menu,menuone,noselect"
cmp.setup({
  completion = {
    keyword_length = 0,
    autocomplete = false,
  },
  snippet = {
    expand = function(args)
      require("luasnip").lsp_expand(args.body)
    end,
  },
  window = {
    -- completion = cmp.config.window.bordered(),
    -- documentation = cmp.config.window.bordered(),
  },
  mapping = cmp.mapping.preset.insert({
    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
    ["<C-Space>"] = cmp.mapping.complete({}),
    ["<C-e>"] = cmp.mapping.abort(),
    ["<CR>"] = cmp.mapping.confirm({ select = true }),
  }),
  sources = cmp.config.sources({
    {
      name = "nvim_lsp",
      entry_filter = function(entry)
        local completionKind = cmp.lsp.CompletionItemKind
        return completionKind.Snippet ~= entry:get_kind()
          and completionKind.Keyword ~= entry:get_kind()
      end,
    },
    { name = "luasnip" },
    { name = "nvim_lua" },
    { name = "path" },
  }, {
    { name = "buffer" },
  }),
})
-- Set configuration for specific filetype.
cmp.setup.filetype("gitcommit", {
  sources = cmp.config.sources({
    { name = "cmp_git" },
  }, {
    { name = "buffer" },
  }),
})

cmp.setup.filetype("sql", {
  sources = cmp.config.sources({
    { name = "vim-dadbod-completion" },
  }),
})

-- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline("/", {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = "buffer" },
  },
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(":", {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = "path" },
  }, {
    { name = "cmdline" },
  }),
})
