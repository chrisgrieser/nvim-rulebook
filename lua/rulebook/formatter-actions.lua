local M = {}
local u = require("rulebook.utils")
--------------------------------------------------------------------------------

function M.suppress()
	local ft = vim.bo.filetype
	local mode = vim.fn.mode()

	local ftConfig = require("rulebook.config").config.suppressFormatter[ft]
	if not ftConfig then
		u.notify(("No formatter suppression configured for %q."):format(ft), "warn")
		return
	end
	local coverage = mode == "n" and "ignoreBlock" or "ignoreRange"
	local suppressText = ftConfig[coverage]
	if not suppressText then
		u.notify(("No %q configured for %q."):format(coverage, ft), "warn")
		return
	end

	local location = type(ftConfig.location) == "function" and ftConfig.location()
		or ftConfig.location ---@cast location Rulebook.Location

	local indent = vim.api.nvim_get_current_line():match("^%s*")
	local prevLnum = vim.api.nvim_win_get_cursor(0)[1] - 1

	if mode == "n" then
		if location == "prevLine" then
			vim.api.nvim_buf_set_lines(0, prevLnum, prevLnum, false, { indent .. suppressText })
		elseif location == "sameLine" then
			local curLine = vim.api.nvim_get_current_line():gsub("%s+$", "")
			vim.api.nvim_set_current_line(curLine .. " " .. suppressText)
		elseif location == "encloseLine" then
			local nextLnum = prevLnum + 1
			-- next line first to not shift the line number
			vim.api.nvim_buf_set_lines(0, nextLnum, nextLnum, false, { indent .. suppressText[1] })
			vim.api.nvim_buf_set_lines(0, prevLnum, prevLnum, false, { indent .. suppressText[2] })
		end
	elseif mode:find("[Vv]") then
		vim.cmd.normal { mode, bang = true } -- leave visual mode, so `<>` marks are set
		local startLn = vim.api.nvim_buf_get_mark(0, "<")[1] - 1
		local endLn = vim.api.nvim_buf_get_mark(0, ">")[1]

		vim.api.nvim_buf_set_lines(0, endLn, endLn, false, { indent .. suppressText[2] })
		vim.api.nvim_buf_set_lines(0, startLn, startLn, false, { indent .. suppressText[1] })
	end
end

--------------------------------------------------------------------------------
return M
