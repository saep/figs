vim.keymap.set("n", "<localleader><space>", function()
  vim.api.nvim_command("write")
  vim.api.nvim_command("ConjureEvalBuf")
end, { desc = "Save and eval buffer", buffer = true, silent = true })
