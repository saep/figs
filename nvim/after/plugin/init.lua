require("saep.catppuccin")
require("saep.settings")

if vim.g.neovide then
  require("saep.neovide")
end
require("saep.snippets")

local plugin_configs = vim.api.nvim_get_runtime_file("lua/saep/plugins/*.lua", true)
for _, config_file in ipairs(plugin_configs) do
  local start, _ = string.find(config_file, "lua/saep/plugins/")
  if start then
    local module = string.sub(config_file, start + 4, config_file:len() - 4):gsub("/", ".")
    require(module)
  end
end

require("saep.keys")

-- Must be set here for some reason as the hydras aren't colored otherwise
vim.cmd.colorscheme("catppuccin")

-- Fix saving spell checking by prepending a specific writable directory to the runtimepath.
vim.opt.rtp:prepend("~/.local/share/nvim/site/")

-- I'd like this to be 0, but it's often a bit jank
vim.opt.cmdheight = 1

vim.filetype.add({
  pattern = {
    [".*"] = {
      function(path, bufnr)
        local content = vim.api.nvim_buf_get_lines(bufnr, 0, 1, false)[1] or ""
        if string.find(content, "^#!/usr/bin/env%s+bb$") then
          return "clojure"
        end
      end,
      { priority = 1 },
    },
  },
})
