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
		"\nIf you are using efm or nvim-lint, please check your linter config. Otherwise open an issue at the diagnostic source or the diagnostic provider."
	if not diag.source then
		notify("Diagnostic is missing a source." .. issuePlea, "warn")
		return false
	elseif not diag.code and sourceUsesCodes(diag) then
		notify("Diagnostic is missing a code (rule id)." .. issuePlea, "warn")
		return false
	end
	return true
end

--------------------------------------------------------------------------------

---@param diag vim.Diagnostic
function actions.lookupRule(diag)
	if not validDiagObj(diag) then return end
	local config = require("rulebook.config").config

	-- determine url to open
	local docResolver = config.ruleDocs[diag.source]
	local urlToOpen
	if type(docResolver) == "string" and docResolver:find("%%s") then
		urlToOpen = docResolver:format(diag.code)
	elseif type(docResolver) == "string" and not docResolver:find("%%s") then
		-- for cases where a specific rule cannot be linked, copy the code to
		-- the clipboard, so it is easier at the rule index page
		vim.fn.setreg("+", diag.code)
		urlToOpen = docResolver
	elseif type(docResolver) == "function" then
		urlToOpen = docResolver(diag)
	else
		-- fallback
		local escapedQuery = (diag.code .. " " .. diag.source):gsub(" ", "%%20")
		urlToOpen = config.ruleDocs.fallback:format(escapedQuery)
	end

	vim.ui.open(urlToOpen)
end

---@param diag vim.Diagnostic
function actions.ignoreRule(diag)
	local configForSource = require("rulebook.config").config.ignoreComments[diag.source]
	if not configForSource then
		notify(("No ignore comment configured for %q."):format(diag.source), "warn")
		return
	end
	if not validDiagObj(diag) then return end

	local indent = vim.api.nvim_get_current_line():match("^%s*")
	local ignoreComment = configForSource.comment
	if type(ignoreComment) == "function" then ignoreComment = ignoreComment(diag) end
	local ignoreLocation = configForSource.location

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

---@param diag vim.Diagnostic
function actions.yankDiagnosticCode(diag)
	if not validDiagObj(diag) then return end
	local config = require("rulebook.config").config

	local reg = config.yankDiagnosticCodeToSystemClipboard and "+" or '"'
	vim.fn.setreg(reg, diag.code)
	notify(("Diagnostic code copied: \n%s"):format(diag.code), "info")
end

---Selects a diagnostic in the current line. If one diagnostic, automatically
---selects it. If no diagnostic found, searches in the next lines.
---@param operation "lookupRule"|"ignoreRule"|"yankDiagnosticCode"
function M.selectRule(operation)
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
		actions[operation](diagsAtLine[1])
		return
	end

	-- select from multiple diagnostics
	local title
	if operation == "ignoreRule" then title = "Ignore Rule:" end
	if operation == "lookupRule" then title = "Lookup Rule:" end
	if operation == "yankDiagnosticCode" then title = "Yank Diagnostic Code:" end

	vim.ui.select(diagsAtLine, {
		prompt = title,
		kind = "rule_selection",
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
		if not diag then return end -- user aborted

		-- move cursor to location where we add the comment
		if operation == "ignoreRule" and startLine ~= lnum then
			vim.api.nvim_win_set_cursor(0, { lnum + 1, 0 })
			vim.cmd("normal! ^")
		end

		actions[operation](diag)
	end)
end

--------------------------------------------------------------------------------
return M
