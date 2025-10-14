require("blink.cmp").setup({
  fuzzy = {
    sorts = {
      "exact",
      "score",
      "sort_text",
    },
  },
  completion = {
    accept = {
      auto_brackets = {
        enabled = true,
      },
    },
    documentation = {
      auto_show = true,
    },
    keyword = {
      range = "full",
    },
    list = {
      selection = {
        preselect = true,
        auto_insert = false,
      },
    },
    menu = {
      auto_show = false,
    },
  },
  signature = { enabled = true },
  sources = {
    default = { "lsp", "path", "buffer" },
    per_filetype = {
      sql = { "dadbod", "buffer" },
    },
    providers = {
      dadbod = { name = "Dadbod", module = "vim_dadbod_completion.blink" },
    },
    transform_items = function(_, items)
      return vim.tbl_filter(function(item)
        return item.kind ~= require("blink.cmp.types").CompletionItemKind.Snippet
          and item.kind ~= require("blink.cmp.types").CompletionItemKind.Keyword
      end, items)
    end,
  },
  keymap = {
    ["<C-space>"] = {
      "show_and_insert",
    },
    ["<cr>"] = {
      "select_and_accept",
      "fallback",
    },
    ["<C-b>"] = {
      "scroll_documentation_down",
      "fallback",
    },
    ["<C-f>"] = {
      "scroll_documentation_up",
      "fallback",
    },
    ["<C-e>"] = {
      "cancel",
      "fallback",
    },
    ["<C-k>"] = false,
    ["<C-s>"] = {
      "show_signature",
      "hide_signature",
      "fallback",
    },
  },
})
