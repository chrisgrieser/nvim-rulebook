local M = {}
local fn = vim.fn

--------------------------------------------------------------------------------
-- CONFIG

---@class pluginConfig for this plugin
---@field ignoreComments table<string, ruleIgnoreConfig>
---@field ruleDocs table<string, string>

---@type pluginConfig
local defaultConfig = {
	ignoreComments = require("rulebook.rule-data").ignoreComments,
	ruleDocs = require("rulebook.rule-data").ruleDocs,
}
defaultConfig.ruleDocs.fallback = "https://duckduckgo.com/?q=%s+%%21ducky&kl=en-us"

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

--------------------------------------------------------------------------------

---@param diag diagnostic
local function searchForTheRule(diag)
	if not validDiagObj(diag) then return end

	-- determine url to open
	local docsUrl = config.ruleDocs[diag.source]
	local urlToOpen
	if docsUrl then
		urlToOpen = docsUrl:format(diag.code)
	else
		local escapedQuery = (diag.code .. " " .. diag.source):gsub(" ", "%%20")
		urlToOpen = config.ruleDocs.fallback:format(escapedQuery)
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
	-- INFO no need to check that source has rule-data, since filtered beforehand

	local ignoreData = config.ignoreComments

	-- add rule id and indentation into comment
	local currentIndent = vim.api.nvim_get_current_line():match("^%s*")
	local ignoreComment = ignoreData[diag.source].comment
	if type(ignoreComment) == "string" then ignoreComment = { ignoreComment } end
	for i = 1, #ignoreComment, 1 do
		ignoreComment[i] = currentIndent .. ignoreComment[i]:format(diag.code)
	end

	-- insert the comment
	local ignoreLocation = ignoreData[diag.source].location
	if ignoreLocation == "prevLine" then
		local prevLineNum = vim.api.nvim_win_get_cursor(0)[1] - 1
		vim.api.nvim_buf_set_lines(0, prevLineNum, prevLineNum, false, ignoreComment)
	elseif ignoreLocation == "sameLine" then
		local currentLine = vim.api.nvim_get_current_line():gsub("%s+$", "")
		vim.api.nvim_set_current_line(currentLine .. " " .. ignoreComment[1])
	elseif ignoreLocation == "encloseLine" then
		local prevLineNum = vim.api.nvim_win_get_cursor(0)[1] - 1
		local nextLineNum = vim.api.nvim_win_get_cursor(0)[1]
		vim.api.nvim_buf_set_lines(0, nextLineNum, nextLineNum, false, { ignoreComment[2] })
		vim.api.nvim_buf_set_lines(0, prevLineNum, prevLineNum, false, { ignoreComment[1] })
	end
end

--------------------------------------------------------------------------------

---Selects a rule in the current line. If one rule, automatically selects it
---@param operation function(diag)
local function selectRuleInCurrentLine(operation)
	local lnum = vim.api.nvim_win_get_cursor(0)[1] - 1
	local curLineDiags = vim.diagnostic.get(0, { lnum = lnum })

	-- filter diagnostics for which there are no ignore comments defined
	if operation == addIgnoreComment then
		curLineDiags = vim.tbl_filter(
			function(diag) return config.ignoreComments[diag.source] ~= nil end,
			curLineDiags
		)
	end

	-- one or zero diagnostics
	if #curLineDiags == 0 then
		notify("No supported diagnostics found in current line.", "warn")
		return
	elseif #curLineDiags == 1 then
		operation(curLineDiags[1])
		return
	end

	-- select from multiple diagnostics
	local title = operation == addIgnoreComment and "Ignore Rule:" or "Lookup Rule:"
	vim.ui.select(curLineDiags, {
		prompt = title,
		format_item = function(diag)
			local source = diag.source and "[" .. diag.source .. "] " or ""
			local code = diag.code or ""
			local display = source .. code
			if display == "" then display = diag.message end
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
function M.lookupRule() selectRuleInCurrentLine(searchForTheRule) end

---Add ignore comment for the rule
function M.ignoreRule() selectRuleInCurrentLine(addIgnoreComment) end

return M
