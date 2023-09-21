---@class ruleIgnoreConfig
---@field comment string|string[] with %s for the rule id
---@field type "sameLine"|"nextLine"|"enclose"

---@type table<string, ruleIgnoreConfig>
local data = {
	shellcheck = {
		comment = "# shellcheck disable=%s",
		type = "nextLine",
	},
	selene = {
		comment = "-- selene: allow(%s)",
		type = "nextLine",
	},
	vale = {
		comment = { "<!-- vale %s = NO -->", "<!-- vale %s = YES -->" },
		type = "enclose",
	},
	yamllint = {
		comment = "# yamllint disable-line rule:%s",
		type = "nextLine",
	},
	stylelint = {
		comment = "/* stylelint-disable-next-line %s */",
		type = "nextLine",
	},
}

return data
