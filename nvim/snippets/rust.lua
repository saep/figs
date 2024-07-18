local replace_whitespace_with_underscores_on_leave = {
	node_callbacks = {
		[events.leave] = function(node)
			local text_with_spaces = node:get_text()
			print(vim.inspect(text_with_spaces))
			local text_with_underscores = {}
			for _, t in ipairs(text_with_spaces) do
				local u = t:gsub("%s+", "_")
				table.insert(text_with_underscores, u)
			end
			print(vim.inspect(text_with_underscores))
			local from_pos, to_pos = node.mark:pos_begin_end_raw()
			vim.api.nvim_buf_set_text(
				0,
				from_pos[1],
				from_pos[2],
				to_pos[1],
				to_pos[2],
				{ table.concat(text_with_underscores, "_") }
			)
		end,
	},
}

return {
	s({ trig = ",fn", name = "function" }, {
		t("fn "),
		i(1, "function_name", replace_whitespace_with_underscores_on_leave),
		t("("),
		c(2, {
			i(1, ""),
			i(1, "&self"),
			sn(nil, {
				i(1, "name"),
				t(": "),
				i(2, "Type"),
			}),
		}),
		t(") "),
		c(3, {
			i(1),
			sn(nil, { t("-> "), i(1), t(" ") }),
			sn(nil, { t("-> Result<"), i(1, "()"), t(", "), i(2, "anyhow::Error"), t("> ") }),
		}),
		t({ "{", "    " }),
		i(0, "todo!()"),
		t({ "", "}" }),
	}),
	s({ trig = ",mt", name = "test module" }, {
		t({
			"#[cfg(test)]",
			"mod test {",
			"    use super::*;",
			"",
			"    ",
		}),
		i(0),
		t({
			"",
			"}",
		}),
	}),
	s({ trig = ",st", name = "struct" }, {
		c(2, {
			i(1),
			sn(nil, { t("#[derive("), i(1, "Debug"), t({ ")]", "" }) }),
			sn(nil, { t("#[derive(Debug, PartialEq, Eq"), i(1), t({ ")]", "" }) }),
			sn(nil, { t("#[derive(Debug, PartialEq, Eq, PartialOrd, Ord, Clone"), i(1), t({ ")]", "" }) }),
		}),
		t("struct "),
		i(1, "StructName"),
		t({ " {", "    " }),
		i(0),
		t({ "", "}", "" }),
	}),
	s({ trig = ",l", name = "let x = x;" }, {
		t("let "),
		i(1, "var"),
		t(" = "),
		d(2, function(args)
			return sn(nil, {
				t(args[1]),
			})
		end, { 1 }),
		t(";"),
	}),
	s({ trig = ",tt", name = "#[tokio::test]" }, {
		t({ "#[tokio::test]", "async fn " }),
		i(1, "function_name", replace_whitespace_with_underscores_on_leave),
		t({ "() {", "    " }),
		i(0, "todo()"),
		t({ "", "}" }),
	}),
	s({ trig = "json!", name = "serde_json::json!" }, {
		t({ "serde_json::json!({", '    "' }),
		i(1),
		t('": '),
		i(0),
		t({ "", "})" }),
	}),
}, {}
