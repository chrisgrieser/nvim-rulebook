-- INFO the key must be named exactly like diagnostic.source (case-sensitive!)
-- - string value: "%s" will be replaced with the rule id
-- - function value it will be called with the diagnostic object

---@type table<string, string|function>
local M = {
	fallback = "https://duckduckgo.com/?q=%s+%%21ducky&kl=en-us", -- when no docs found for source
	selene = "https://kampfkarren.github.io/selene/lints/%s.html",
	yamllint = "https://yamllint.readthedocs.io/en/stable/rules.html#module-yamllint.rules.%s",
	eslint = "https://eslint.org/docs/latest/rules/%s",
	stylelint = "https://stylelint.io/user-guide/rules/%s",
	LTeX = "https://community.languagetool.org/rule/show/%s?lang=en",
	["Lua Diagnostics."] = "https://luals.github.io/wiki/diagnostics/#%s", -- lua_ls

	biome = function(diag)
		-- biome codes are "lint/topic/rule-id", but the website only requires "rule-id"
		-- also, the rule ids are camelCase, while the website requires kebab-case
		local shortCode = diag.code:match(".*/(.-)$")
		local shortCodeKebabCase = shortCode:gsub("(%u)", "-%1"):lower()
		return "https://biomejs.dev/linter/rules/" .. shortCodeKebabCase
	end,

	shellcheck =  function (diag)
		-- sometimes, the code is `SC1234`, sometimes it is `1234`
		local code = diag.code:gsub("^SC", "")
		return "https://www.shellcheck.net/wiki/SC" .. code
	end,

	-----------------------------------------------------------------------------

	-- urls use rule-name, not rule-id, so this is the closest we can get
	pylint = "https://pylint.readthedocs.io/en/stable/search.html?q=%s",
	ruff = "https://docs.astral.sh/ruff/rules/",

	-- no reliable linking possible, so the website itself is best we can do
	markdownlint = "https://github.com/markdownlint/markdownlint/blob/main/docs/RULES.md",
}

--------------------------------------------------------------------------------
return M
