local M = {}
local notify = require("rulebook.utils").notify
--------------------------------------------------------------------------------

---checks whether rule has id and source, as prescribed in nvim diagnostic structure
---@param diag vim.Diagnostic
---@return boolean whether rule is valid
---@nodiscard
local function validDiagObj(diag)
	local config = require("rulebook.config").config
	local sourcesWithNoCodes = vim.iter(config.ignoreComments)
		:filter(function(_, conf) return conf.doesNotUseCodes end)
		:map(function(linter, _) return linter end)
		:totable()
	if vim.tbl_contains(sourcesWithNoCodes, diag.source) then return true end

	local issuePlea =
		"\nIf you are using efm or nvim-lint, please check your linter config. Otherwise open an issue at the diagnostic source or the diagnostic provider."
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

---@param diag vim.Diagnostic
function M.lookupRule(diag)
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
function M.ignoreRule(diag)
	if not validDiagObj(diag) then return end
	local config = require("rulebook.config").config

	local indent = vim.api.nvim_get_current_line():match("^%s*")
	local ignoreComment = config.ignoreComments[diag.source].comment
	if type(ignoreComment) == "function" then ignoreComment = ignoreComment(diag) end
	local ignoreLocation = config.ignoreComments[diag.source].location

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
function M.yankDiagnosticCode(diag)
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
	local operationIsIgnore = operation == "ignoreRule"
	local lnum = vim.api.nvim_win_get_cursor(0)[1] - 1
	local startLine = lnum
	local lastLine = vim.api.nvim_buf_line_count(0)
	local diagsAtLine

	-- loop through lines until we find a line with diagnostics
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

		-- GUARD
		if lnum > lastLine or lnum > startLine + config.forwSearchLines then
			local msg = ("No supported diagnostics found in the next %s lines."):format(
				config.forwSearchLines
			)
			notify(msg, "warn")
			return
		end
	end

	-- remove duplicate rules
	local uniqueRule = {}
	for _, diag in ipairs(diagsAtLine) do
		uniqueRule[diag.source .. (diag.code or diag.message)] = diag
	end
	diagsAtLine = vim.tbl_values(uniqueRule)

	-- autoselect if only one diagnostic
	if #diagsAtLine == 1 then
		M[operation](diagsAtLine[1])
		return
	end

	-- select from multiple diagnostics
	local title
	if operationIsIgnore then title = "Ignore Rule:" end
	if operation == "lookupRule" then title = "Lookup Rule:" end
	if operation == "yankDiagnosticCode" then title = "Yank Diagnostic Code:" end

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

		M[operation](diag)
	end)
end

--------------------------------------------------------------------------------
return M
