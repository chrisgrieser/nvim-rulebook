local M = {}
local notify = require("rulebook.utils").notify
--------------------------------------------------------------------------------

---@param config ruleIgnoreConfig|formatterSuppressConfig
---@param commentKeyName string
---@return string errorMsg
local function validateIgnoreComment(config, commentKeyName)
	local comment = config[commentKeyName]
	local location = config.location
	local comType = type(comment)
	local errorMsg
	if not (vim.tbl_contains({ "prevLine", "sameLine", "encloseLine" }, location)) then
		errorMsg = "`location` must be one of `prevLine`, `sameLine` or `encloseLine`."
	elseif location == "encloseLine" and comType ~= "table" and #comment ~= 2 then
		errorMsg = "`encloseLine` requires 'comment' to be a list of two strings."
	elseif location ~= "encloseLine" and comType ~= "string" and comType ~= "function" then
		errorMsg = ("`%s` requires `%s` to be a string or function"):format(location, commentKeyName)
	end
	if location == "encloseLine" and config.multiRuleIgnore then
		errorMsg = "`encloseLine` does not support `multiRuleIgnore`."
	end
	return errorMsg
end

--------------------------------------------------------------------------------

---@class rulebook.config
---@field ignoreComments table<string, ruleIgnoreConfig>
---@field ruleDocs table<string, string|function>
---@field suppressFormatter table<string, formatterSuppressConfig>
---@field forwSearchLines number

---@type rulebook.config
local defaultConfig = {
	ignoreComments = require("rulebook.data.add-ignore-rule-comment"),
	ruleDocs = require("rulebook.data.rule-docs"),
	suppressFormatter = require("rulebook.data.suppress-formatter-comment"),
	forwSearchLines = 10,
}

-- if user does not call setup, use default
M.config = defaultConfig

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
	for ftName, ftConfig in pairs(M.config.suppressFormatter) do
		local errorMsg = validateIgnoreComment(ftConfig, "ignoreBlock")
		if errorMsg then
			notify(("Suppress formatter config for %q: %s"):format(ftName, errorMsg), "error")
		end
	end
end

--------------------------------------------------------------------------------
return M
