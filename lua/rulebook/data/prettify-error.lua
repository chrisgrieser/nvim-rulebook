---@alias Rulebook.ErrorPrettifierFunc fun(vim.Diagnostic): string[]

---@type table<string, Rulebook.ErrorPrettifierFunc>
local M = {}

--------------------------------------------------------------------------------

M.typescript = function(diag) ---@param diag vim.Diagnostic
	-- pretty-print the message in markdown
	local msg = diag
		.message
		:gsub("'({.-}%[?]?)'", "\n```typescript\n%1\n```\n") -- types to codeblocks
		:gsub("'", "`") -- single quote to inline code
		:gsub("\n +", "\n") -- remove indent
		:gsub("\nType", "\n\nType") -- add line break for padding
	local lines = vim.split(msg, "\n")

	-- determine args for formatter, abort if no formatter is available
	local fmtArgs
	if vim.fn.executable("biome") == 1 then
		fmtArgs = { "biome", "format", "--stdin-file-path=stdin.ts" }
	elseif vim.fn.executable("prettier") == 1 then
		fmtArgs = { "prettier", "--stdin-filepath=stdin.ts" }
	end
	if not fmtArgs then return lines end -- no formatter

	-- pretty-format each codeblock
	lines = vim.iter(lines):fold({}, function(acc, line)
		local lineIsCodeBlock = line:find("^{.-}%[?]?$") ~= nil
		if lineIsCodeBlock then
			line = "type dummy = " .. line -- needed for formatters to work
			local out = vim.system(fmtArgs, { stdin = line }):wait()
			if not (out.stdout and out.code == 0) then
				require("rulebook.utils").notify("Formatter failed. " .. out.stderr, "warn")
				table.insert(acc, line)
				return acc
			end
			local formatted = vim.trim(out.stdout:gsub("^type dummy = ", ""))
			vim.list_extend(acc, vim.split(formatted, "\n"))
		else
			table.insert(acc, line)
		end
		return acc
	end)

	return lines
end

--------------------------------------------------------------------------------

-- TOOLS THAT INHERIT THE CONFIGURATION OF OTHER TOOLS
M.tsserver = M.typescript -- typescript-tools.nvim
M.ts = M.typescript -- vtsls

--------------------------------------------------------------------------------
return M
