require("conform").setup({
  formatters_by_ft = {
    gleam = { "gleam format" },
    haskell = { "fourmolu", "ormolu", stop_after_first = true },
    javascript = { "prettierd", "prettier", stop_after_first = true },
    typescript = { "prettierd", "prettier", stop_after_first = true },
    lua = { "stylua" },
    markdown = { "my_comrak", "prettierd", "prettier", stop_after_first = true },
    nix = { "nixfmt" },
    rust = { "rustfmt", lsp_format = "fallback" },
    sql = { "pg_format" },
    xml = { "my_xml" },
  },
  format_on_save = function(bufnr)
    -- Disable with a global or buffer-local variable
    if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
      return
    end
    return { timeout_ms = 5000, lsp_format = "fallback" }
  end,
  formatters = {
    prettierd = {
      command = "prettierd",
      args = { "$FILENAME" },
      stdin = true,
    },
    my_comrak = {
      command = "comrak",
      args = { "--to", "commonmark", "--gfm", "--width", "80" },
    },
    my_xml = {
      command = "xmlstarlet",
      args = { "fo" },
    },
  },
})

vim.api.nvim_create_user_command("FormatDisable", function(args)
  if args.bang then
    -- FormatDisable! will disable formatting just for this buffer
    vim.b.disable_autoformat = true
  else
    vim.g.disable_autoformat = true
  end
end, {
  desc = "Disable autoformat-on-save",
  bang = true,
})
vim.api.nvim_create_user_command("FormatEnable", function()
  vim.b.disable_autoformat = false
  vim.g.disable_autoformat = false
end, {
  desc = "Re-enable autoformat-on-save",
})
