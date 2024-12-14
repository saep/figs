local replace_whitespace_with_dashes_on_leave = {
  node_callbacks = {
    [events.leave] = function(node)
      local text_with_spaces = node:get_text()
      local text_with_underscores = {}
      for _, t in ipairs(text_with_spaces) do
        local u = t:gsub("%s+", "-")
        table.insert(text_with_underscores, u)
      end
      local from_pos, to_pos = node.mark:pos_begin_end_raw()
      vim.api.nvim_buf_set_text(
        0,
        from_pos[1],
        from_pos[2],
        to_pos[1],
        to_pos[2],
        { table.concat(text_with_underscores, "-") }
      )
    end,
  },
}

return {
  s({ trig = "f", name = "function" }, {
    t({ "(with-test", "  (defn " }),
    i(1, "function-name", replace_whitespace_with_dashes_on_leave),
    c(2, {
      sn(nil, {
        t({ "", "    [" }),
        i(1, ""),
        t("]"),
      }),
      sn(nil, {
        t({ "", '    "' }),
        i(1),
        t({ '"', "    [" }),
        i(2),
        t("]"),
      }),
    }),
    t({ "", "    " }),
    i(3),
    t("))"),
  }),
}, {}
