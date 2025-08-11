local M = {}
local actions = {} ---@type table<string, fun(vim.Diagnostic): nil>
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

---@param diag vim.Diagnostic
---@return boolean
---@nodiscard
local function diagHasCodeAndSource(diag)
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
	local template = config.ruleDocs[diag.source]
	local urlToOpen

	if type(template) == "string" then
		if not diagHasCodeAndSource(diag) then return end
		-- `:format` can fail if there are other common `%` placeholders in the
		-- template, thus using `:gsub`
		urlToOpen = template:gsub("%%s", diag.code)
	elseif type(template) == "function" then
		urlToOpen = template(diag)
	else
		template = config.ruleDocs.fallback
		if type(template) == "function" then template = template(diag) end
		if not template then
			notify("Neither docs nor fallback are configured for " .. diag.source, "warn")
			return
		end

		local query = ("%s (%s): %q"):format(diag.code or "", diag.source, diag.message or "")
		local encoded = urlEncode(query)
		local escaped = encoded:gsub("%%", "%%%%") -- avoid `%1` in replacement making `gsub` fail
		urlToOpen = template:gsub("%%s", escaped)
	end

	vim.ui.open(urlToOpen)
end

---@param diag vim.Diagnostic
function actions.ignoreRule(diag)
	---@type Rulebook.RuleIgnoreConfig
	local sourceConf = require("rulebook.config").config.ignoreComments[diag.source]
	if not sourceConf then
		notify(("No ignore comment configured for %q."):format(diag.source), "warn")
		return
	end
	if not diagHasCodeAndSource(diag) then return end

	-- parameters
	local curLine = vim.api.nvim_get_current_line()
	local indent = curLine:match("^%s*")
	local prevLnum = vim.api.nvim_win_get_cursor(0)[1] - 1
	local ignoreComment = sourceConf.comment
	if type(ignoreComment) == "function" then ignoreComment = ignoreComment(diag) end
	---@cast ignoreComment string
	local code = diag.code
	local location = type(sourceConf.location) == "function" and sourceConf.location(diag)
		or sourceConf.location ---@cast location Rulebook.Location

	-- consider multi-rule-ignore
	if sourceConf.multiRuleIgnore then
		-- used with `str.match`, this pattern will return the already ignored code(s)
		local existingRulePattern = vim.pesc(ignoreComment):gsub("%%%%s", "([%%w-_,%%[%%] ]+)")
			.. "%s*$"
		local sep = sourceConf.multiRuleSeparator or ", "

		if location == "location" or location == "inlineBeforeDiagnostic" then
			local oldCode = curLine:match(existingRulePattern)
			if oldCode then
				code = oldCode .. sep .. code
				curLine = curLine
					:gsub(existingRulePattern, "") -- remove old ignore comment
					:gsub("%s+$", "")
			end
		elseif location == "prevLine" then
			local prevLine = vim.api.nvim_buf_get_lines(0, prevLnum - 1, prevLnum, false)[1]
			local oldCode = prevLine:match(existingRulePattern)
			if oldCode then
				code = oldCode .. sep .. code
				vim.api.nvim_buf_set_lines(0, prevLnum - 1, prevLnum, false, {}) -- = deletes previous line
				prevLnum = prevLnum - 1 -- account for the deleted line
			end
		end
		assert(location ~= "encloseLine", "encloseLine does not support for multi-rule-ignore.")
	end

	-- insert comment
	local comment = ignoreComment:format(code)

	if location == "prevLine" then
		vim.api.nvim_buf_set_lines(0, prevLnum, prevLnum, false, { indent .. comment })
	elseif location == "sameLine" then
		local extraSpace = vim.bo.filetype == "python" and " " or "" -- formatters expect an extra space
		vim.api.nvim_set_current_line(indent .. vim.trim(curLine) .. " " .. extraSpace .. comment)
	elseif location == "inlineBeforeDiagnostic" then
		local updatedLine = curLine:sub(1, diag.col) .. comment .. curLine:sub(diag.col + 1)
		vim.api.nvim_set_current_line(updatedLine)
	elseif location == "encloseLine" then
		---@cast ignoreComment string[]
		local comment1 = indent .. ignoreComment[1]:format(code)
		local comment2 = indent .. ignoreComment[2]:format(code)
		local nextLnum = prevLnum + 1
		-- next line first to not shift the line number
		vim.api.nvim_buf_set_lines(0, nextLnum, nextLnum, false, { comment2 })
		vim.api.nvim_buf_set_lines(0, prevLnum, prevLnum, false, { comment1 })
	end
end

---@param diag vim.Diagnostic
function actions.yankDiagnosticCode(diag)
	if not diagHasCodeAndSource(diag) then return end
	vim.fn.setreg("+", diag.code)
	notify("Diagnostic code copied: \n" .. diag.code)
end

---@param diag vim.Diagnostic
function actions.prettifyError(diag)
	---@type Rulebook.ErrorPrettifierFunc
	local prettifyFunc = require("rulebook.config").config.prettifyError[diag.source]
	local errorLines = prettifyFunc(diag)

	local height = math.min(#errorLines, vim.api.nvim_win_get_config(0).height - 2)
	local title = ("  %s %s "):format(diag.source, diag.code)
	-- using `open_floating_preview` not only saves a lot of code, but also
	-- automatically closes potentially diagnostics floats
	local _bufnr, winid = vim.lsp.util.open_floating_preview(errorLines, "markdown", {
		close_events = { "CursorMoved", "CursorMovedI", "BufHidden", "LspDetach" },
		wrap = false,

		focus = true,
		title = { { title, "ErrorMsg" } },
		height = height,
	})

	-- FIX `title` and `height` not working
	vim.api.nvim_win_set_config(winid, {
		title = { { title, "ErrorMsg" } },
		height = height,
	})
	-- FIX `focus` not working
	vim.api.nvim_set_current_win(winid)
end

--------------------------------------------------------------------------------

---Selects a diagnostic in the current line. If one diagnostic, automatically
---selects it. If no diagnostic found, searches in the next lines.
---@param operation "lookupRule"|"ignoreRule"|"yankDiagnosticCode"|"prettifyError"
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
			local msg = ("No diagnostics found in the next %d lines."):format(config.forwSearchLines)
			notify(msg, "warn")
			return
		end
	end

	-- remove irrelevant rules
	-- * unconfigured rules when prettyfiying
	-- * duplicate rules for the other operations
	if operation == "prettifyError" then
		diagsAtLine = vim.tbl_filter(
			function(diag) return config.prettifyError[diag.source] ~= nil end,
			diagsAtLine
		)
		if #diagsAtLine == 0 then
			local msg = "No diagnostics found in the next "
				.. config.forwSearchLines
				.. " lines for which `prettifyError` is configured."
			notify(msg, "warn")
			return
		end
	else
		local uniqueRule = {}
		for _, diag in ipairs(diagsAtLine) do
			uniqueRule[(diag.source or "") .. (diag.code or diag.message)] = diag
		end
		diagsAtLine = vim.tbl_values(uniqueRule)
	end

	-- autoselect if only one diagnostic
	if #diagsAtLine == 1 then
		if operation ~= "prettifyError" then moveCursorToDiagnostic(diagsAtLine[1]) end
		actions[operation](diagsAtLine[1])
		return
	end

	-- select from multiple diagnostics
	local title
	if operation == "ignoreRule" then title = "Ignore rule: " end
	if operation == "lookupRule" then title = "Lookup rule: " end
	if operation == "yankDiagnosticCode" then title = "Yank diagnostic code: " end
	if operation == "prettyError" then title = "Pretty error: " end

	vim.ui.select(diagsAtLine, {
		prompt = title,
		kind = "rulebook.diagnostic_selection",
		format_item = function(diag)
			local msg = diag.message or ""
			if #msg > 30 then msg = vim.trim(diag.message:sub(1, 30)) .. "…" end
			if not diag.source then return ("[ No source] %s %s"):format(diag.code or "", msg) end

			local display = ("%s: %s"):format(diag.source, diag.code or msg)
			if diag.code and type(diag.code) == "number" then
				-- make diagnostics with unverbose codes like `typescript 1234` more readable
				display = ("%s: %s | %s"):format(diag.source, diag.code, msg)
			end

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
		if operation ~= "prettifyError" then moveCursorToDiagnostic(diag) end
		actions[operation](diag)
	end)
end

function M.lookupRule() selectRule("lookupRule") end
function M.ignoreRule() selectRule("ignoreRule") end
function M.yankDiagnosticCode() selectRule("yankDiagnosticCode") end
function M.prettifyError() selectRule("prettifyError") end

--------------------------------------------------------------------------------
return M
