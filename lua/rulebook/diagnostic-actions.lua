local M = {}
local actions = {}
local notify = require("rulebook.utils").notify
--------------------------------------------------------------------------------

---@param diag vim.Diagnostic
---@return boolean
---@nodiscard
local function sourceUsesCodes(diag)
	local config = require("rulebook.config").config
	local sourcesWithNoCodes = vim.iter(config.ignoreComments)
		:filter(function(_, conf) return conf.doesNotUseCodes end)
		:map(function(linter, _) return linter end)
		:totable()
	return not vim.tbl_contains(sourcesWithNoCodes, diag.source)
end

---checks whether rule has id and source, as prescribed in nvim diagnostic structure
---@param diag vim.Diagnostic
---@return boolean
---@nodiscard
local function validDiagObj(diag)
	if not sourceUsesCodes(diag) then return true end

	local issuePlea =
		"\nIf you are using `efm` or `nvim-lint`, please check your linter config. Otherwise open an issue at the diagnostic source or the diagnostic provider."
	if not diag.source then
		notify("Diagnostic is missing a source." .. issuePlea, "warn")
		return false
	elseif not diag.code and sourceUsesCodes(diag) then
		notify("Diagnostic is missing a code (rule id)." .. issuePlea, "warn")
		return false
	end
	return true
end

---@param diag vim.Diagnostic
local function moveCursorToDiagnostic(diag)
	vim.api.nvim_win_set_cursor(0, { diag.lnum + 1, diag.col })
end

---@param unencoded string
local function urlEncode(unencoded)
	local encoded = unencoded:gsub(
		"([^%w%-_.~])",
		function(c) return string.format("%%%02X", string.byte(c)) end
	)
	return encoded
end

--------------------------------------------------------------------------------

---@param diag vim.Diagnostic
function actions.lookupRule(diag)
	local config = require("rulebook.config").config
	local diagnosticInfo = (diag.code or diag.message):gsub("[\n\r]", " ")

	local template = config.ruleDocs[diag.source]
	local urlToOpen
	if type(template) == "string" then
		if not validDiagObj(diag) then return end
		-- `:format` can fail if there are other common `%` placeholders in the
		-- template, thus using `:gsub`
		urlToOpen = template:gsub("%%s", diag.code)
	elseif type(template) == "function" then
		urlToOpen = template(diag)
	else
		template = config.ruleDocs.fallback
		if type(template) ~= "string" and type(template) ~= "function" then
			notify("The `fallback` for `ruleDocs` needs to be a string or a function.", "error")
			---@cast template string
			return
		end
		local query = ("%q (%s)"):format(diagnosticInfo, diag.source)
		local encoded = urlEncode(query)
		local escaped = encoded:gsub("%%", "%%%%") -- avoid `%1` in replacement making `gsub` fail
		urlToOpen = template:gsub("%%s", escaped)
	end

	vim.ui.open(urlToOpen)
end

---@param diag vim.Diagnostic
function actions.ignoreRule(diag)
	---@type ruleIgnoreConfig
	local sourceConf = require("rulebook.config").config.ignoreComments[diag.source]
	if not sourceConf then
		notify(("No ignore comment configured for %q."):format(diag.source), "warn")
		return
	end
	if not validDiagObj(diag) then return end

	local indent = vim.api.nvim_get_current_line():match("^%s*")
	local prevLn = vim.api.nvim_win_get_cursor(0)[1] - 1
	local ignoreComment = sourceConf.comment
	if type(ignoreComment) == "function" then ignoreComment = ignoreComment(diag) end

	-- used with `str.match`, this pattern will return the already ignored code(s)
	local existingRulePattern = vim.pesc(ignoreComment[1] or ignoreComment)
		:gsub("%%%%s", "([%%w-_,%%[%%] ]+)") .. "%s*$"

	-----------------------------------------------------------------------------
	if sourceConf.location == "prevLine" then
		---@cast ignoreComment string

		if sourceConf.multiRuleIgnore then
			local prevLine = vim.api.nvim_buf_get_lines(0, prevLn - 1, prevLn, false)[1]
			local oldCode = prevLine:match(existingRulePattern)
			if oldCode then
				local sep = sourceConf.multiRuleSeparator or ", "
				diag.code = oldCode .. sep .. diag.code
				vim.api.nvim_buf_set_lines(0, prevLn - 1, prevLn, false, {}) -- = deletes previous line
				prevLn = prevLn - 1 -- account for the deleted line
			end
		end

		local comment = indent .. ignoreComment:format(diag.code)
		vim.api.nvim_buf_set_lines(0, prevLn, prevLn, false, { comment })
	-----------------------------------------------------------------------------
	elseif sourceConf.location == "sameLine" then
		---@cast ignoreComment string
		local curLine = vim.api.nvim_get_current_line():gsub("%s+$", "")

		if sourceConf.multiRuleIgnore then
			local oldCode = curLine:match(existingRulePattern)
			if oldCode then
				local sep = sourceConf.multiRuleSeparator or ", "
				diag.code = oldCode .. sep .. diag.code
				curLine = curLine
					:gsub(existingRulePattern, "") -- remove old ignore comment
					:gsub("%s+$", "")
			end
		end

		local comment = ignoreComment:format(diag.code)
		local extraSpace = vim.bo.filetype == "python" and " " or "" -- formatters expect an extra space
		vim.api.nvim_set_current_line(curLine .. " " .. extraSpace .. comment)
	-----------------------------------------------------------------------------
	elseif sourceConf.location == "encloseLine" then
		---@cast ignoreComment string[]
		local comment1 = indent .. ignoreComment[1]:format(diag.code)
		local comment2 = indent .. ignoreComment[2]:format(diag.code)
		local nextLn = prevLn + 1
		-- next line first to not shift the line number
		vim.api.nvim_buf_set_lines(0, nextLn, nextLn, false, { comment2 })
		vim.api.nvim_buf_set_lines(0, prevLn, prevLn, false, { comment1 })
	end
end

---@param diag vim.Diagnostic
function actions.yankDiagnosticCode(diag)
	if not validDiagObj(diag) then return end
	vim.fn.setreg("+", diag.code)
	notify(("Diagnostic code copied: \n%s"):format(diag.code), "info")
end

--------------------------------------------------------------------------------

---Selects a diagnostic in the current line. If one diagnostic, automatically
---selects it. If no diagnostic found, searches in the next lines.
---@param operation "lookupRule"|"ignoreRule"|"yankDiagnosticCode"
local function selectRule(operation)
	local config = require("rulebook.config").config
	local lnum = vim.api.nvim_win_get_cursor(0)[1] - 1
	local startLine = lnum
	local lastLine = vim.api.nvim_buf_line_count(0)
	local diagsAtLine

	-- loop through lines until we find a line with diagnostics
	while true do
		diagsAtLine = vim.diagnostic.get(0, { lnum = lnum })
		if #diagsAtLine > 0 then break end -- no diagnostic -> search the next lines
		lnum = lnum + 1

		-- GUARD
		if lnum > lastLine or lnum > startLine + config.forwSearchLines then
			local msg = ("No diagnostics found in the next %s lines."):format(config.forwSearchLines)
			notify(msg, "warn")
			return
		end
	end

	-- remove duplicate rules
	local uniqueRule = {}
	for _, diag in ipairs(diagsAtLine) do
		uniqueRule[(diag.source or "") .. (diag.code or diag.message)] = diag
	end
	diagsAtLine = vim.tbl_values(uniqueRule)

	-- autoselect if only one diagnostic
	if #diagsAtLine == 1 then
		moveCursorToDiagnostic(diagsAtLine[1])
		actions[operation](diagsAtLine[1])
		return
	end

	-- select from multiple diagnostics
	local title
	if operation == "ignoreRule" then title = "Ignore rule:" end
	if operation == "lookupRule" then title = "Lookup rule:" end
	if operation == "yankDiagnosticCode" then title = "Yank diagnostic code:" end

	vim.ui.select(diagsAtLine, {
		prompt = title,
		kind = "rulebook.diagnostic_selection",
		format_item = function(diag)
			local msg = vim.trim((diag.message or ""):sub(1, 50))
			if not diag.source then return ("[ No source] %s %s"):format(diag.code or "", msg) end

			local display = diag.source .. ": " .. (diag.code or msg)
			if operation == "ignoreRule" then
				local configForSource = require("rulebook.config").config.ignoreComments[diag.source]
				if not configForSource then display = "[ No config] " .. display end
				if sourceUsesCodes(diag) and not diag.code then
					display = "[ No code] " .. display
				end
			elseif not diag.code then
				display = "[ No code] " .. display
			end
			return display
		end,
	}, function(diag)
		if not diag then return end
		moveCursorToDiagnostic(diag)
		actions[operation](diag)
	end)
end

function M.lookupRule() selectRule("lookupRule") end
function M.ignoreRule() selectRule("ignoreRule") end
function M.yankDiagnosticCode() selectRule("yankDiagnosticCode") end

--------------------------------------------------------------------------------
return M
