local M = {}
local fn = vim.fn

---Send notification
---@param msg string
---@param level? "info"|"trace"|"debug"|"warn"|"error"
local function notify(msg, level)
	if not level then level = "info" end
	local pluginName = "nvim-rulebook"
	vim.notify(msg, vim.log.levels[level:upper()], { title = pluginName })
end

--------------------------------------------------------------------------------
-- CONFIG

---@class pluginConfig for this plugin
---@field ignoreComments table<string, ruleIgnoreConfig>
---@field ruleDocs table<string, string|function>
---@field forwSearchLines number

---@type pluginConfig
local defaultConfig = {
	ignoreComments = require("rulebook.data.add-ignore-comment"),
	ruleDocs = require("rulebook.data.rule-docs"),
	forwSearchLines = 10,
}

-- if user does not call setup, use default
local config = defaultConfig

---@param userConfig table
function M.setup(userConfig)
	config = vim.tbl_deep_extend("force", defaultConfig, userConfig)

	-- validate config
	for name, linter in pairs(config.ignoreComments) do
		local comType = type(linter.comment)
		local errorMsg
		if not (vim.tbl_contains({ "prevLine", "sameLine", "encloseLine" }, linter.location)) then
			errorMsg = "'location' must be one of 'prevLine', 'sameLine' or 'encloseLine'"
		elseif linter.location == "encloseLine" and comType ~= "table" and #linter.comment ~= 2 then
			errorMsg = "'encloseLine' requires 'comment' to be a list of two strings"
		elseif linter.location ~= "encloseLine" and comType ~= "string" and comType ~= "function" then
			errorMsg = ("'%s' requires 'comment' to be a string or function"):format(linter.location)
		end
		if errorMsg then notify(("Config for %s: "):format(name) .. errorMsg, "error") end
	end
end

--------------------------------------------------------------------------------

---checks whether rule has id and source, as prescribed in nvim diagnostic structure
---@param diag Diagnostic
---@return boolean whether rule is valid
---@nodiscard
local function validDiagObj(diag)
	local sourcesWithNoCodes = { "editorconfig-checker", "codespell" }
	if vim.tbl_contains(sourcesWithNoCodes, diag.source) then return true end

	local issuePlea = "\nPlease open an issue at the diagnostic source or the diagnostic provider."
	if not diag.code then
		notify("Diagnostic is missing a code (rule id)." .. issuePlea, "warn")
		return false
	elseif not diag.source then
		notify("Diagnostic is missing a source." .. issuePlea, "warn")
		return false
	end
	return true
end

--------------------------------------------------------------------------------

---@param diag Diagnostic
local function searchForTheRule(diag)
	if not validDiagObj(diag) then return end

	-- determine url to open
	local docResolver = config.ruleDocs[diag.source]
	local urlToOpen
	if type(docResolver) == "string" and docResolver:find("%%s") then
		urlToOpen = docResolver:format(diag.code)
	elseif type(docResolver) == "string" and not docResolver:find("%%s") then
		-- for cases where a specific rule cannot be linked, copy the code to
		-- the clipboard, so it is easier at the rule index page
		fn.setreg("+", diag.code)
		urlToOpen = docResolver
	elseif type(docResolver) == "function" then
		urlToOpen = docResolver(diag)
	else
		-- fallback
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

---@param diag Diagnostic
local function addIgnoreComment(diag)
	if not validDiagObj(diag) then return end

	local ignoreData = config.ignoreComments
	local indent = vim.api.nvim_get_current_line():match("^%s*")
	local ignoreComment = ignoreData[diag.source].comment
	if type(ignoreComment) == "function" then ignoreComment = ignoreComment(diag) end
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
local function findAndSelectRule(operation)
	local operationIsIgnore = operation == addIgnoreComment
	local lnum = vim.api.nvim_win_get_cursor(0)[1] - 1
	local startLine = lnum
	local lastLine = vim.api.nvim_buf_line_count(0)
	local diagsAtLine

	-- loop through lines until we find a diagnostic
	while true do
		diagsAtLine = vim.diagnostic.get(0, { lnum = lnum })
		if operationIsIgnore then
			-- INFO for rule search, there is no need to filter the diagnostics, since there
			-- is a fallback mechanic
			diagsAtLine = vim.tbl_filter(
				function(d) return config.ignoreComments[d.source] ~= nil end,
				diagsAtLine
			)
		end

		-- no diagnostic -> search the next lines
		if #diagsAtLine > 0 then break end
		lnum = lnum + 1

		-- abort if not diagnostics found in the next few lines as well
		if lnum > lastLine or lnum > startLine + config.forwSearchLines then
			local msg = ("No supported diagnostics found in the next %s lines."):format(config.forwSearchLines)
			notify(msg, "warn")
			return
		end
	end

	-- remove duplicate rules
	local uniqueRule = {}
	for _, diag in ipairs(diagsAtLine) do
		-- not using code to create hash-key, since some diagnostics have no code
		uniqueRule[diag.source .. diag.message] = diag
	end
	diagsAtLine = vim.tbl_values(uniqueRule)

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
			local source = diag.source and diag.source .. ": " or ""
			local desc = diag.code or diag.message
			local display = source .. desc
			if not (diag.code and diag.source) then display = " " .. display end
			return display
		end,
	}, function(diag)
		if not diag then return end -- user aborted

		-- move cursor to location where we add the comment
		if operationIsIgnore and startLine ~= lnum then
			vim.api.nvim_win_set_cursor(0, { lnum + 1, 0 }) 
			vim.cmd("normal! ^")
		end

		operation(diag)
	end)
end

--------------------------------------------------------------------------------
-- COMMANDS FOR USER

---Search via DuckDuckGo for the rule
function M.lookupRule() findAndSelectRule(searchForTheRule) end

---Add ignore comment for the rule
function M.ignoreRule() findAndSelectRule(addIgnoreComment) end

---Utility for diagnostic formatting config (vim.diagnostic.config), that
---returns whether nvim-rulebook has documentation for the diagnostic that can
---be opened via `lookupRule`
---@param diag Diagnostic
---@return boolean hasDocs
function M.hasDocs(diag)
	local hasDocumentations = config.ruleDocs[diag.source] ~= nil
	return hasDocumentations
end

--------------------------------------------------------------------------------

return M
