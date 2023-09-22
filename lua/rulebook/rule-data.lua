local M = {}
--------------------------------------------------------------------------------

---@class ruleIgnoreConfig
---@field comment string|string[] "%s" will be replaced with the rule id
---@field location "sameLine"|"prevLine"|"encloseLine"
---@field docs? string used for auto-generated docs

-- INFO "encloseLine" is a list with two strings, one to be inserted before and
-- one to be inserted after. (prevLine or sameLine comments are obviously
-- preferred, but some linters to do support that.)

---INFO the key must be named exactly like diagnostic.source (case-sensitive!) 
---@type table<string, ruleIgnoreConfig>
M.ignoreComments = {
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
		comment = { "<!-- LTeX: enabled=false -->", "<!-- LTeX: enabled=true -->" },
		location = "encloseLine",
		docs = "https://valentjn.github.io/ltex/advanced-usage.html",
	},
	vale = {
		comment = { "<!-- vale %s = NO -->", "<!-- vale %s = YES -->" },
		location = "encloseLine",
		docs = "https://vale.sh/docs/topics/config/#markup-based-configuration",
	},
	pylint = {
		comment = "# pylint: disable=%s",
		location = "sameLine",
		docs = "https://pylint.readthedocs.io/en/latest/user_guide/messages/message_control.html",
	},
	Pyright = {
		comment = "# pyright: ignore %s",
		location = "sameLine",
		docs = "https://microsoft.github.io/pyright/#/comments",
	},
	eslint = {
		comment = "// eslint-disable-line %s",
		location = "sameLine",
		docs = "https://eslint.org/docs/latest/use/configure/rules#using-configuration-comments-1",
	},
	biome = {
		comment = "// biome-ignore %s: <explanation>",
		location = "sameLine",
		docs = "https://biomejs.dev/linter/#ignoring-code",
	},
	typescript = { -- tsserver
		comment = "// @ts-ignore",
		location = "prevLine",
		docs = "https://www.typescriptlang.org/", -- no docs found that are more specific
	},
}

--------------------------------------------------------------------------------

---INFO the key must be named exactly like diagnostic.source (case-sensitive!) 
-- "%s" will be replaced with the rule id
---@type table<string, string>
M.ruleDocs = {
	selene = "https://kampfkarren.github.io/selene/lints/%s.html",
	shellcheck = "https://www.shellcheck.net/wiki/SC%s",
	yamllint = "https://yamllint.readthedocs.io/en/stable/rules.html#module-yamllint.rules.%s",

	stylelint = "https://stylelint.io/user-guide/rules/%s",
	biome = "https://biomejs.dev/linter/rules/%s",
	eslint = "https://eslint.org/docs/latest/rules/%s",

	-- source name for lua_ls
	["Lua Diagnostics"] = "https://luals.github.io/wiki/diagnostics/#%s", 

	-- urls unfortunately use the rule-name, not the rule-id :/
	pylint = "https://pylint.readthedocs.io/en/stable/search.html?q=%s",

	-- INFO used when no docs found for the diagnostics source
	fallback = "https://duckduckgo.com/?q=%s+%21ducky&kl=en-us"
}

--------------------------------------------------------------------------------
return M
