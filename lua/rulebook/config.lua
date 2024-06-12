local M = {}
local notify = require("rulebook.utils").notify
--------------------------------------------------------------------------------

---@class pluginConfig for this plugin
---@field ignoreComments table<string, ruleIgnoreConfig>
---@field ruleDocs table<string, string|function>
---@field forwSearchLines number

---@type pluginConfig
local defaultConfig = {
	ignoreComments = require("rulebook.data.add-ignore-rule-comment"),
	ruleDocs = require("rulebook.data.rule-docs"),
	forwSearchLines = 10,
	suppressFormatter = require("rulebook.data.suppress-formatter-comment"),
	yankDiagnosticCodeToSystemClipboard = true,
}

-- if user does not call setup, use default
M.config = defaultConfig

---@param userConfig? table
function M.setup(userConfig)
	M.config = vim.tbl_deep_extend("force", M.config, userConfig or {})

	-- VALIDATE
	for name, linter in pairs(M.config.ignoreComments) do
		local comType = type(linter.comment)
		local errorMsg
		if not (vim.tbl_contains({ "prevLine", "sameLine", "encloseLine" }, linter.location)) then
			errorMsg = "'location' must be one of 'prevLine', 'sameLine' or 'encloseLine'"
		elseif linter.location == "encloseLine" and comType ~= "table" and #linter.comment ~= 2 then
			errorMsg = "'encloseLine' requires 'comment' to be a list of two strings"
		elseif linter.location ~= "encloseLine" and comType ~= "string" and comType ~= "function" then
			errorMsg = ('%q requires "comment" to be a string or function'):format(linter.location)
		end
		if errorMsg then notify(("Config for %q: "):format(name) .. errorMsg, "error") end
	end
end

--------------------------------------------------------------------------------
return M
