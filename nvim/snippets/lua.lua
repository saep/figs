return {
	s(",d", {
		t('describe("'),
		i(1, "category"),
		t({ '", function()', '    it("' }),
		i(2, "test case"),
		t({ '", function()', "        " }),
		i(0),
		t({ "", "    end)", "end)" }),
	}),
	s(",it", {
		t('it("'),
		i(1, "test case"),
		t({ '", function()', "    " }),
		i(0),
		t({ "", "end)" }),
	}),
	s(",r", {
		t('require("'),
		i(1),
		t('")'),
		i(0),
	}),
}
