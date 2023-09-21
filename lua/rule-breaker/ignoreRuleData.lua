---@class ruleIgnoreConfig
---@field comment string|string[] with %s for the rule id
---@field location "sameLine"|"nextLine"|"encloseLine"

-- INFO "encloseLine" is a list with two strings, one to be inserted before and
-- one to be inserted after. (nextLine or sameLine comments are obviously
-- preferred, but some linters to do support that.)

---@type table<string, ruleIgnoreConfig>
local data = {
	shellcheck = {
		comment = "# shellcheck disable=%s",
		location = "nextLine",
	},
	selene = {
		comment = "-- selene: allow(%s)",
		location = "nextLine",
	},
	vale = {
		comment = { "<!-- vale %s = NO -->", "<!-- vale %s = YES -->" },
		location = "encloseLine",
	},
	yamllint = {
		comment = "# yamllint disable-line rule:%s",
		location = "nextLine",
	},
	stylelint = {
		comment = "/* stylelint-disable-next-line %s */",
		location = "nextLine",
	},
}

--------------------------------------------------------------------------------

return data
