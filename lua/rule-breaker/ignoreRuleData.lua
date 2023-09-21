---@class ruleIgnoreConfig
---@field comment string|string[] with %s for the rule id
---@field location "sameLine"|"prevLine"|"encloseLine"
---@field docs string

-- INFO "encloseLine" is a list with two strings, one to be inserted before and
-- one to be inserted after. (prevLine or sameLine comments are obviously
-- preferred, but some linters to do support that.)

---@type table<string, ruleIgnoreConfig>
local data = {
	shellcheck = {
		comment = "# shellcheck disable=%s",
		location = "prevLine",
		docs = "https://www.shellcheck.net/wiki/Ignore",
	},
	selene = {
		comment = "-- selene: allow(%s)",
		location = "prevLine",
		docs = "https://kampfkarren.github.io/selene/usage/filtering.html#allowingdenying-lints-for-an-entire-file",
	},
	yamllint = {
		comment = "# yamllint disable-line rule:%s",
		location = "prevLine",
		docs = "https://yamllint.readthedocs.io/en/stable/disable_with_comments.html",
	},
	stylelint = {
		comment = "/* stylelint-disable-next-line %s */",
		location = "prevLine",
		docs = "https://stylelint.io/user-guide/ignore-code/",
	},
	LTeX = {
		-- ltex does not allow disabling individual rules, so it has to be
		-- enabled/disables completely
		comment = { "<!-- LTeX: enabled=false -->", "<!-- LTeX: enabled=true -->" },
		location = "encloseLine",
		docs = "https://valentjn.github.io/ltex/advanced-usage.html",
	},
	vale = {
		comment = { "<!-- vale %s = NO -->", "<!-- vale %s = YES -->" },
		location = "encloseLine",
		docs = "https://vale.sh/docs/topics/config/#markup-based-configuration",
	},
}

--------------------------------------------------------------------------------

return data
