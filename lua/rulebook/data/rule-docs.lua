-- INFO the key must be named exactly like diagnostic.source (case-sensitive!)
-- - string value: "%s" will be replaced with the rule id
-- - function value: will be called with the diagnostic object
--------------------------------------------------------------------------------

---@type table<string, string|function>
local M = {
	fallback = "https://duckduckgo.com/?q=%s+%%21ducky&kl=en-us",

	selene = "https://kampfkarren.github.io/selene/lints/%s.html",
	yamllint = "https://yamllint.readthedocs.io/en/stable/rules.html#module-yamllint.rules.%s",
	eslint = "https://eslint.org/docs/latest/rules/%s",
	stylelint = "https://stylelint.io/user-guide/rules/%s",
	LTeX = "https://community.languagetool.org/rule/show/%s?lang=en",
	["Lua Diagnostics."] = "https://luals.github.io/wiki/diagnostics/#%s", -- lua_ls
	shellcheck = function(diag)
		-- depending on provider, the code is `SC1234` or `1234`
		local code = type(diag.code) == "string" and diag.code:gsub("^SC", "") or tostring(diag.code)
		return "https://www.shellcheck.net/wiki/SC" .. code
	end,

	-- typescript has no official docs, therefore using community docs, even
	-- though they, too, are not complete.
	typescript = "https://tswhy.deno.dev/ts%s",

	-- website links saved directly in diagnostic object
	Ruff = function(diag) return diag.user_data.lsp.codeDescription.href end,
	["clang-tidy"] = function(diag) return diag.user_data.lsp.codeDescription.href end,
	Pyright = function(diag) return diag.user_data.lsp.codeDescription.href end,
	biome = function(diag) return diag.user_data.lsp.codeDescription.href end,
	["quick-lint-js"] = function(diag) return diag.user_data.lsp.codeDescription.href end,
	-----------------------------------------------------------------------------

	-- urls use rule-name, not rule-id, so this is the closest we can get
	pylint = "https://pylint.readthedocs.io/en/stable/search.html?q=%s",

	-- no reliable linking possible, so the website itself is best we can do
	markdownlint = "https://github.com/markdownlint/markdownlint/blob/main/docs/RULES.md",
}

--------------------------------------------------------------------------------

M.tsserver = M.typescript -- typescript-tools.nvim
M.stylelintplus = M.stylelint -- stylelint-lsp

--------------------------------------------------------------------------------
return M
