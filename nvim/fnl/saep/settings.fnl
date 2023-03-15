(module saep.settings 
  {autoload {nvim aniseed.nvim}})

(set vim.opt.tildeop true)
(set vim.opt.undofile true)
(set vim.opt.inccommand :nosplit)
(set vim.opt.mouse :a)
(set vim.opt.expandtab true)
(set vim.opt.tabstop 4)
(set vim.opt.shiftwidth 2)
(set vim.opt.scrolloff 8)
(set vim.opt.updatetime 300)
(set vim.opt.shortmess (+ vim.opt.shortmess :c))
(set vim.opt.wildignore
     (+ vim.opt.wildignore "*.bak,*~,*.o,*.hi,*.swp,*.so,*.aux,*.xlsx,*.ods"))
(set vim.opt.errorbells false)
(set vim.opt.visualbell false)
(set vim.opt.diffopt (+ vim.opt.diffopt :iwhite))
(set vim.opt.formatoptions (- vim.opt.formatoptions :ao))
(set vim.opt.formatoptions (+ vim.opt.formatoptions :cqtnjr))
(set vim.opt.swapfile false)
(set vim.opt.spelllang "en_us,de_de")
(set vim.opt.spellfile (.. (vim.fn.stdpath "cache") "/ende.utf-8.add"))

(fn go-to-last-known-position []
  (when (and (> (vim.fn.line "'\"") 1)
             (<= (vim.fn.line "'\"") (vim.fn.line "$")))
    (vim.api.nvim_command "exe \"normal! g`\\\"\"")))
(vim.api.nvim_create_augroup :vimrcEx {})
(vim.api.nvim_create_autocmd [:BufReadPost]
                             {:callback go-to-last-known-position
                              :desc "Go to last known position when opening a buffer"
                              :group :vimrcEx
                              :pattern "*"})  

