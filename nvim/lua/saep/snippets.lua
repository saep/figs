local ls = require("luasnip")
local s = ls.snippet
local sn = ls.snippet_node
-- local isn = ls.indent_snippet_node
local t = ls.text_node
local i = ls.insert_node
-- local f = ls.function_node
local c = ls.choice_node
-- local d = ls.dynamic_node
-- local r = ls.restore_node
-- local events = require("luasnip.util.events")
-- local ai = require("luasnip.nodes.absolute_indexer")
-- local extras = require("luasnip.extras")
-- local l = extras.lambda
-- local rep = extras.rep
-- local p = extras.partial
-- local m = extras.match
-- local n = extras.nonempty
-- local dl = extras.dynamic_lambda
-- local fmt = require("luasnip.extras.fmt").fmt
-- local fmta = require("luasnip.extras.fmt").fmta
-- local conds = require("luasnip.extras.expand_conditions")
-- local postfix = require("luasnip.extras.postfix").postfix
-- local types = require("luasnip.util.types")
-- local parse = require("luasnip.util.parser").parse_snippet
-- local ms = ls.multi_snippet

ls.add_snippets("rust", {
  s("fn", {
    t("fn "), i(1, "function_name"), t("("), i("&self"), t(") "),
    c(2, {
      i(2),
      sn(nil, { t("-> "), i(1), t(" ") }),
      sn(nil, { t("-> Result<"), i(1), t(", "), i(2), t("> ") }),
    }),
    t({ "{", "    " }),
    i(0),
    t({"", "}"}),
  }),
  s("mt (test module)", {
    t({
      "#[cfg(test)]",
      "mod test {",
      "    use super::*;",
      "",
      "    " }), i(0),
    t({
      "",
      "}" })
  })
})
