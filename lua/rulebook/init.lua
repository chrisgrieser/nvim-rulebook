local version = vim.version()
if version.major == 0 and version.minor < 10 then
	vim.notify("nvim-rulebook requires at least nvim 0.10.", vim.log.levels.WARN)
	return
end

local M = {}
--------------------------------------------------------------------------------

---@param userConfig? table
function M.setup(userConfig) require("rulebook.config").setup(userConfig) end

function M.lookupRule() require("rulebook.diagnostic-actions").selectRule("lookupRule") end
function M.ignoreRule() require("rulebook.diagnostic-actions").selectRule("ignoreRule") end
function M.yankDiagnosticCode() require("rulebook.diagnostic-actions").selectRule("yankDiagnosticCode") end

function M.suppressFormatter() require("rulebook.formatter-actions").suppress() end

--------------------------------------------------------------------------------
-- API

---Utility for diagnostic formatting config (vim.diagnostic.config), that
---returns whether nvim-rulebook has documentation for the diagnostic that can
---be opened via `lookupRule`
---@param diag vim.Diagnostic
---@return boolean hasDocs
function M.hasDocs(diag)
	local config = require("rulebook.config").config
	local hasDocumentations = config.ruleDocs[diag.source] ~= nil
	return hasDocumentations
end

--------------------------------------------------------------------------------

return M
