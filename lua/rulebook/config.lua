local M = {}
local notify = require("rulebook.utils").notify
--------------------------------------------------------------------------------

---@param config Rulebook.RuleIgnoreConfig|Rulebook.FormatterSuppressConfig
---@param commentKey string
---@return string|nil errorMsg
local function validateIgnoreComment(config, commentKey)
	local comment = config[commentKey]
	local location = config.location
	local comType = type(comment)

	---@type Rulebook.Location[]
	local validLocations = { "prevLine", "sameLine", "encloseLine", "inlineBeforeDiagnostic" }
	local errorMsg
	if not (vim.list_contains(validLocations, location) or type(location) == "function") then
		errorMsg = "`location` must be `prevLine`, `sameLine`, `encloseLine`, "
			.. "`inlineBeforeDiagnostic`, or a function returning one of those."
	end
	if commentKey == "ignoreBlock" and location == "inlineBeforeDiagnostic" then
		errorMsg = "`suppressFormatter` does not support `inlineBeforeDiagnostic`."
	end
	if location == "encloseLine" then
		if comType == "table" and #comment ~= 2 then
			errorMsg = "`encloseLine` requires `comment` to be a list of two strings."
		end
		if config.multiRuleIgnore then
			errorMsg = "`encloseLine` does not support `multiRuleIgnore`."
		end
	end
	return errorMsg
end

--------------------------------------------------------------------------------

---@class Rulebook.Config
---@field forwSearchLines number
---@field ignoreComments table<string, Rulebook.RuleIgnoreConfig>
---@field ruleDocs table<string, Rulebook.RuleDocsTemplate>
---@field suppressFormatter table<string, Rulebook.FormatterSuppressConfig>
---@field prettifyError table<string, Rulebook.ErrorPrettifierFunc>

---@type Rulebook.Config
local defaultConfig = {
	forwSearchLines = 10,
	ignoreComments = require("rulebook.data.add-ignore-rule-comment"),
	ruleDocs = require("rulebook.data.rule-docs"),
	suppressFormatter = require("rulebook.data.suppress-formatter-comment"),
	prettifyError = require("rulebook.data.prettify-error"),
}
M.config = defaultConfig -- if user does not call setup, use default

--------------------------------------------------------------------------------

---@param userConfig? table
function M.setup(userConfig)
	M.config = vim.tbl_deep_extend("force", M.config, userConfig or {})

	-- VALIDATE
	for linterName, linterConfig in pairs(M.config.ignoreComments) do
		local errorMsg = validateIgnoreComment(linterConfig, "comment")
		if errorMsg then
			notify(("Ignore comment config for %q: %s"):format(linterName, errorMsg), "error")
		end
	end
	for fmtName, fmtConfig in pairs(M.config.suppressFormatter) do
		local errorMsg = validateIgnoreComment(fmtConfig, "ignoreBlock")
		if errorMsg then
			notify(("Suppress formatter config for %q: %s"):format(fmtName, errorMsg), "error")
		end
	end
end

--------------------------------------------------------------------------------
return M
