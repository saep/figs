-- nushell settings
-- taken from: https://github.com/nushell/integrations/blob/main/nvim/init.lua
vim.opt.sh = "nu"
vim.opt.shelltemp = false
vim.opt.shellredir = "out+err> %s"
vim.opt.shellcmdflag = "--stdin --no-newline -c"
vim.opt.shellxescape = ""
vim.opt.shellxquote = ""
vim.opt.shellquote = ""
vim.opt.shellpipe =
  "| complete | update stderr { ansi strip } | tee { get stderr | save --force --raw %s } | into record"

vim.loader.enable()

P = function(t)
  print(vim.inspect(t))
  return t
end

require("saep.float")
require("snacks").setup({
  animate = { enabled = true },
  bigfile = { enabled = true },
  indent = { enabled = true },
  input = { enabled = true },
  notifier = { enabled = true },
  notify = { enabled = true },
  scope = { enabled = true },
  scroll = { enabled = true },
})
require("saep.lsp")

-- vim.opt.runtimepath:append("/home/saep/git/neogit")

vim.g.sexp_mappings = {
  sexp_move_to_prev_top_element = "", -- '[[',
  sexp_move_to_next_top_element = "", -- ']]',
  sexp_select_prev_element = "", -- '[e',
  sexp_select_next_element = "", -- ']e',
  sexp_swap_list_backward = "", -- '<M-k>',
  sexp_swap_list_forward = "", -- '<M-j>',
  sexp_swap_element_backward = "", -- '<M-h>',
  sexp_swap_element_forward = "", -- '<M-l>',
}
