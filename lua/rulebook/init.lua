local M = {}
local fn = vim.fn

--------------------------------------------------------------------------------
-- CONFIG

---@class pluginConfig for this plugin
---@field ignoreComments table<string, ruleIgnoreConfig>
---@field ruleDocs table<string, string|function>
---@field forwSearchLines number

---@type pluginConfig
local defaultConfig = {
	ignoreComments = require("rulebook.rule-data").ignoreComments,
	ruleDocs = require("rulebook.rule-data").ruleDocs,
	forwSearchLines = 10,
}

-- if user does not call setup, use default
local config = defaultConfig

---@param userConfig table
function M.setup(userConfig) config = vim.tbl_deep_extend("force", defaultConfig, userConfig) end

--------------------------------------------------------------------------------

---Send notification
---@param msg string
---@param level? "info"|"trace"|"debug"|"warn"|"error"
local function notify(msg, level)
	if not level then level = "info" end
	local pluginName = "nvim-rulebook"
	vim.notify(msg, vim.log.levels[level:upper()], { title = pluginName })
end

---checks whether rule has id and source, as prescribed in nvim diagnostic structure
---@param diag diagnostic
---@return boolean whether rule is valid
---@nodiscard
local function validDiagObj(diag)
	local issuePlea = "\nPlease open an issue at the plugin that provides the diagnostics."
	if not diag.code then
		notify("Diagnostic is missing a code (rule id). " .. issuePlea, "warn")
		return false
	elseif not diag.source then
		notify("Diagnostic is missing a source" .. issuePlea, "warn")
		return false
	end
	return true
end

---@param lnum number
---@param operationIsIgnore boolean
---@nodiscard
local function getDiagsInCurLine(lnum, operationIsIgnore)
	local diags = vim.diagnostic.get(0, { lnum = lnum })
	-- INFO for rule search, there is no need to filter the diagnostics, since there
	-- is a fallback mechanic
	if operationIsIgnore then
		diags = vim.tbl_filter(function(d) return config.ignoreComments[d.source] ~= nil end, diags)
	end
	return diags
end

--------------------------------------------------------------------------------

---@param diag diagnostic
local function searchForTheRule(diag)
	if not validDiagObj(diag) then return end

	-- determine url to open
	local docResolver = config.ruleDocs[diag.source]
	local urlToOpen
	if type(docResolver) == "string" then
		urlToOpen = docResolver:format(diag.code)
	elseif type(docResolver) == "function" then
		urlToOpen = docResolver(diag)
	else -- fallback
		urlToOpen = config.ruleDocs.fallback:format(diag.code .. "%%20" .. diag.source)
	end

	-- open with the OS-specific shell command
	local opener
	if fn.has("macunix") == 1 then
		opener = "open"
	elseif fn.has("linux") == 1 then
		opener = "xdg-open"
	elseif fn.has("win64") == 1 or fn.has("win32") == 1 then
		opener = "start"
	end
	local openCommand = string.format("%s '%s' >/dev/null 2>&1", opener, urlToOpen)
	fn.system(openCommand)
end

---@param diag diagnostic
local function addIgnoreComment(diag)
	if not validDiagObj(diag) then return end

	local ignoreData = config.ignoreComments
	local indent = vim.api.nvim_get_current_line():match("^%s*")
	local ignoreComment = ignoreData[diag.source].comment
	local ignoreLocation = ignoreData[diag.source].location

	-- insert the comment
	if ignoreLocation == "prevLine" then
		ignoreComment = indent .. ignoreComment:format(diag.code)
		local prevLnum = vim.api.nvim_win_get_cursor(0)[1] - 1
		vim.api.nvim_buf_set_lines(0, prevLnum, prevLnum, false, { ignoreComment })
	elseif ignoreLocation == "sameLine" then
		ignoreComment = ignoreComment:format(diag.code)
		local curLine = vim.api.nvim_get_current_line():gsub("%s+$", "")
		vim.api.nvim_set_current_line(curLine .. " " .. ignoreComment)
	elseif ignoreLocation == "encloseLine" then
		ignoreComment[1] = indent .. ignoreComment[1]:format(diag.code)
		ignoreComment[2] = indent .. ignoreComment[2]:format(diag.code)
		local prevLnum = vim.api.nvim_win_get_cursor(0)[1] - 1
		local nextLnum = vim.api.nvim_win_get_cursor(0)[1]
		vim.api.nvim_buf_set_lines(0, nextLnum, nextLnum, false, { ignoreComment[2] })
		vim.api.nvim_buf_set_lines(0, prevLnum, prevLnum, false, { ignoreComment[1] })
	end
end

--------------------------------------------------------------------------------

---Selects a diagnostic in the current line. If one diagnostic, automatically
---selects it. If no diagnostic found, searches in the next lines.
---@param operation function(diag)
local function selectRule(operation)
	local operationIsIgnore = operation == addIgnoreComment
	local lnum = vim.api.nvim_win_get_cursor(0)[1] - 1
	local startLine = lnum
	local lastLine = vim.api.nvim_buf_line_count(0)

	local diagsAtLine = getDiagsInCurLine(lnum, operationIsIgnore)

	-- no diagnostic -> search the next lines
	while #diagsAtLine == 0 do
		lnum = lnum + 1
		if lnum > lastLine or lnum > startLine + config.forwSearchLines then
			local msg = ("No diagnostics found in the next %s lines."):format(config.forwSearchLines)
			notify(msg, "warn")
			return
		end
		diagsAtLine = getDiagsInCurLine(lnum, operationIsIgnore)
	end

	-- move cursor when adding comment
	if operationIsIgnore and startLine ~= lnum then
		vim.api.nvim_win_set_cursor(0, { lnum + 1, 0 }) -- +1 cause indexing difference
		vim.cmd("normal! ^")
	end

	-- autoselect if only one diagnostic
	if #diagsAtLine == 1 then
		operation(diagsAtLine[1])
		return
	end

	-- select from multiple diagnostics
	local title = operationIsIgnore and "Ignore Rule:" or "Lookup Rule:"
	vim.ui.select(diagsAtLine, {
		prompt = title,
		kind = "rule_selection",
		format_item = function(diag)
			local source = diag.source .. ": " or ""
			local desc = diag.code or diag.message
			local display = source .. desc
			if not (diag.code and diag.source) then display = " " .. display end
			return display
		end,
	}, function(diag)
		if not diag then return end
		operation(diag)
	end)
end

--------------------------------------------------------------------------------
-- COMMANDS FOR USER

---Search via DuckDuckGo for the rule
function M.lookupRule() selectRule(searchForTheRule) end

---Add ignore comment for the rule
function M.ignoreRule() selectRule(addIgnoreComment) end

return M
