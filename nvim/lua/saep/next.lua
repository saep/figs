local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local function send_keys(keys)
	local key = vim.api.nvim_replace_termcodes(keys, true, false, true)
	vim.api.nvim_feedkeys(key, "n", false)
end

local auto_select_next_action
local nextActions = {
	auto = {
		short = "a",
		description = "Automatically perforn an action based on context",
		next = function()
			auto_select_next_action().next()
		end,
		prev = function()
			auto_select_next_action().prev()
		end,
		close = function()
			local action = auto_select_next_action()
			if action.close then
				action.close()
			end
		end,
		canBeExecuted = function()
			return true
		end,
	},
	qf = {
		short = "q",
		description = "quickfix list - :cnext :cprevious",
		next = function()
			vim.api.nvim_command("cnext")
		end,
		prev = function()
			vim.api.nvim_command("cprevious")
		end,
		close = function()
			vim.api.nvim_command("cclose")
		end,
		canBeExecuted = function()
			local winIdOfQfList = vim.fn.getqflist({ winid = true }).winid
			return winIdOfQfList and winIdOfQfList ~= 0
		end,
	},
	loclist = {
		short = "l",
		description = "location list - :lnext :lprevious",
		next = function()
			vim.api.nvim_command("lnext")
		end,
		prev = function()
			vim.api.nvim_command("lprevious")
		end,
		close = function()
			vim.fn.getloclist(0)
			vim.api.nvim_command("lclose")
		end,
		canBeExecuted = function()
			local winIdOfLoclist = vim.fn.getloclist(0, { winid = true }).winid
			return winIdOfLoclist and winIdOfLoclist ~= 0
		end,
	},
	lspsaga_diagnostic = {
		short = "d",
		description = "Lspsaga diagnostic",
		next = function()
			vim.api.nvim_command("Lspsaga diagnostic_jump_next")
		end,
		prev = function()
			vim.api.nvim_command("Lspsaga diagnostic_jump_prev")
		end,
		canBeExecuted = function()
			local diagnosticsOfBuffer = vim.diagnostic.get(0)
			return diagnosticsOfBuffer and #diagnosticsOfBuffer > 0
		end,
	},
	scroll_last_window = {
		short = "w",
		description = "Scroll last window",
		next = function()
			send_keys("<C-w>p<C-d><C-w>p")
		end,
		prev = function()
			send_keys("<C-w>p<C-u><C-w>p")
		end,
		canBeExecuted = function()
			return true
		end,
	},
	scroll = {
		short = "s",
		description = "Scroll - <C-d> <C-u>",
		next = function()
			send_keys("<C-d>")
		end,
		prev = function()
			send_keys("<C-u>")
		end,
		canBeExecuted = function()
			return true
		end,
	},
}

local Stack = { items = {} }

function Stack:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	self.items = {}
	return o
end

NextState = Stack:new()

function Stack:pop()
	local lastIndex = #self.items
	local action = self.items[lastIndex]
	if action then
		table.remove(self.items, lastIndex)
		return action
	end
	return nextActions.auto
end

function Stack:peek()
	return self.items[#self.items] or nextActions.auto
end

function Stack:push(item)
	local i = 1
	repeat
		i = i + 1
	until not self.items[i] or self.items[i].short == item.short
	if self.items[i] then
		while i < #self.items do
			self.items[i] = self.items[i + 1]
			i = i + 1
		end
	end
	self.items[i] = item
	return item
end

auto_select_next_action = function()
	local selectable = {
		nextActions.loclist,
		nextActions.qf,
		nextActions.lspsaga_diagnostic,
		nextActions.scroll_last_window,
	}
	for _, action in ipairs(selectable) do
		if action.canBeExecuted() then
			return action
		end
	end
end

local function to_next()
	local action = NextState:peek()
	if action and action.next then
		pcall(action.next)
	end
end

local function to_prev()
	local action = NextState:peek()
	if action and action.prev then
		pcall(action.prev)
	end
end

local function close()
	local action = NextState:pop()
	if action and action.close then
		pcall(action.close)
	end
end

local function create_telescope_results()
	local results = {}
	for k, t in pairs(nextActions) do
		if t.canBeExecuted() then
			table.insert(results, { tostring(k), t })
		end
	end
	return results
end

local function select_in_telescope(opts)
	opts = opts or {}
	pickers
		.new(opts, {
			prompt_title = "select next/prev action",
			finder = finders.new_table({
				results = create_telescope_results(),
				entry_maker = function(entry)
					return {
						value = entry,
						display = entry[2].description,
						ordinal = entry[1],
					}
				end,
			}),
			sorter = conf.generic_sorter(opts),
			attach_mappings = function(prompt_bufnr, map)
				actions.select_default:replace(function()
					actions.close(prompt_bufnr)
					local selection = action_state.get_selected_entry()
					NextState:push(selection.value[2])
				end)
				return true
			end,
		})
		:find()
end

return {
	next = to_next,
	prev = to_prev,
	close = close,
	current = function()
		local c = NextState:peek()
		return (c and c.short) or "a"
	end,
	select_in_telescope = function(opts)
		select_in_telescope(opts or require("telescope.themes").get_dropdown({}))
	end,
	actions = nextActions,
	push = function(action)
		NextState:push(action)
	end,
}
