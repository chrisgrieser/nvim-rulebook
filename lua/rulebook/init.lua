local version = vim.version()
if version.major == 0 and version.minor < 10 then
	vim.notify("nvim-rulebook requires at least nvim 0.10.", vim.log.levels.WARN)
	return
end
--------------------------------------------------------------------------------

local M = {}

---@param userConfig? Rulebook.Config
function M.setup(userConfig) require("rulebook.config").setup(userConfig) end

-- redirect to from the `require("rulebook")` to the correct module
setmetatable(M, {
	__index = function(_, key)
		return function()
			if key == "suppressFormatter" then
				return require("rulebook.formatter-actions").suppress()
			else
				require("rulebook.diagnostic-actions")[key]()
			end
		end
	end,
})

---API: Utility for diagnostic formatting config (vim.diagnostic.config), that
---returns whether nvim-rulebook has documentation for the diagnostic that can
---be opened via `lookupRule`
---@param diag vim.Diagnostic
---@return boolean hasDocs
function M.hasDocs(diag)
	local config = require("rulebook.config").config
	return config.ruleDocs[diag.source] ~= nil
end

--------------------------------------------------------------------------------

return M
