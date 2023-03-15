(module saep.nvim-tree
  {require {: nvim-tree}})

(nvim-tree.setup {:view {:mappings {:list [{:key "<CR>" :action "edit_in_place"}]}}})
