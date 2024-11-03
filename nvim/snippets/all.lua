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
}, {}
