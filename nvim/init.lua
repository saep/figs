vim.loader.enable()

P = function(t)
	print(vim.inspect(t))
	return t
end

require("saep.lsp")
