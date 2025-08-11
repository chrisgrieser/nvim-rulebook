---@alias Rulebook.ErrorPrettifierFunc fun(vim.Diagnostic): string[]
---@type table<string, Rulebook.ErrorPrettifierFunc>

local M = {
	typescript = function(diag) ---@param diag vim.Diagnostic
		-- pretty-print the message in markdown
		local msg = diag
			.message
			:gsub("'({.-}%[?]?)'", "\n```ts\n%1\n```\n") -- types to codeblocks
			:gsub("'", "`") -- single term to inline code
			:gsub("\n +", "\n") -- remove indents
			:gsub("\nType", "\n\nType") -- padding
		local lines = vim.split(msg, "\n")

		-- format codeblocks, if `prettier` or `biome` is available
		local u = require("rulebook.utils")
		local fmtArgs
		if vim.fn.executable("biome") == 1 then
			fmtArgs = { "biome", "format", "--stdin-file-path=stdin.ts" }
		elseif vim.fn.executable("prettier") == 1 then
			fmtArgs = { "prettier", "--stdin-filepath=stdin.ts" }
		end
		if fmtArgs then
			lines = vim.iter(lines):fold({}, function(acc, line)
				local lineIsCodeBlock = line:find("^{.-}%[?]?$") ~= nil
				if lineIsCodeBlock then
					line = "type dummy = " .. line
					local out = vim.system(fmtArgs, { stdin = line }):wait()
					if not (out.stdout and out.code == 0) then
						u.notify("Formatter failed. " .. out.stderr, "warn")
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
		end

		return lines
	end,
}

--------------------------------------------------------------------------------
return M
