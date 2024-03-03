return {
	s(",fn", {
		t("fn "),
		i(1, "function_name"),
		t("("),
		i(2, "&self"),
		t(") "),
		c(3, {
			i(1),
			sn(nil, { t("-> "), i(1), t(" ") }),
			sn(nil, { t("-> Result<"), i(1), t(", "), i(2), t("> ") }),
		}),
		t({ "{", "    " }),
		i(0),
		t({ "", "}" }),
	}),
	s(",mt (test module)", {
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
	s(",st (struct)", {
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
	s(",l (let x = x;)", {
		t("let "),
		i(1, "var"),
		t(" = "),
		d(2, function(args)
			return sn(nil, {
				t(args[1]),
			})
		end, { 1 }),
	}),
}, {}
