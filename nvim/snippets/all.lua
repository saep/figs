return {
  postfix("_", {
    f(function(_, parent)
      return require("textcase").api.to_snake_case(parent.snippet.env.POSTFIX_MATCH)
    end, {}),
  }),
  postfix("-", {
    f(function(_, parent)
      return require("textcase").api.to_dash_case(parent.snippet.env.POSTFIX_MATCH)
    end, {}),
  }),
  postfix(".", {
    f(function(_, parent)
      return require("textcase").api.to_camel_case(parent.snippet.env.POSTFIX_MATCH)
    end, {}),
  }),
  postfix(":", {
    f(function(_, parent)
      return require("textcase").api.to_pascal_case(parent.snippet.env.POSTFIX_MATCH)
    end, {}),
  }),
  postfix("/", {
    f(function(_, parent)
      return require("textcase").api.to_path_case(parent.snippet.env.POSTFIX_MATCH)
    end, {}),
  }),
  postfix("!", {
    f(function(_, parent)
      return require("textcase").api.to_constant_case(parent.snippet.env.POSTFIX_MATCH)
    end, {}),
  }),
  s({ trig = "now", name = "now as iso timestamp" }, {
    c(1, {
      f(function()
        local res = vim.system({ "date", "--iso-8601=seconds" }, { text = true }):wait()
        local stdout = res.stdout
        local end_index = string.find(stdout, "\n") or stdout:len()
        return '"' .. string.sub(stdout, 1, end_index - 1) .. '"'
      end, {}),
      f(function()
        local res = vim.system({ "date", "--utc", "--iso-8601=seconds" }, { text = true }):wait()
        local stdout = res.stdout
        local end_index = string.find(stdout, "\n") or stdout:len()
        return '"' .. string.sub(stdout, 1, end_index - 1) .. '"'
      end, {}),
      i(1),
    }),
    i(0),
  }),
}, {}
