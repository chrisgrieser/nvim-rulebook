-- INFO the key must be named exactly like `diagnostic.source` (case-sensitive!)
-- * string value: `%s` will be replaced with the rule id
-- * function value: will be called with the diagnostic object
-- * `false`: disable rule docs, just use the fallback
--------------------------------------------------------------------------------

---some providers save the links to the docs in the diagnostic object
---@param diag vim.Diagnostic
local function urlInDiagObj(diag) return diag.user_data.lsp.codeDescription.href end

--------------------------------------------------------------------------------
---@alias ruleTemplate string|false|fun(diag: vim.Diagnostic): string?

---@type table<string, ruleTemplate>
local M = {
	fallback = "https://www.google.com/search?q=%s",

	selene = "https://kampfkarren.github.io/selene/lints/%s.html",
	yamllint = "https://yamllint.readthedocs.io/en/stable/rules.html#module-yamllint.rules.%s",
	eslint = function(diag)
		if not diag or not diag.code then return end

		local plugin = vim.fs.dirname(tostring(diag.code))
		local rule = vim.fs.basename(tostring(diag.code))

		local pluginDocUrls = {
			["."] = "https://eslint.org/docs/latest/rules/%s",
			["@stencil-community"] = "https://github.com/stencil-community/stencil-eslint/blob/main/docs/%s.md",
			["@typescript-eslint"] = "https://typescript-eslint.io/rules/%s",
			["astro"] = "https://github.com/ota-meshi/eslint-plugin-astro/blob/main/docs/rules/%s.md",
			["compat"] = "https://github.com/amilajack/eslint-plugin-compat/blob/main/docs/rules/%s.md",
			["es-x"] = "https://github.com/eslint-community/eslint-plugin-es-x/blob/master/docs/rules/%s.md",
			["eslint-plugin"] = "https://github.com/eslint-community/eslint-plugin-eslint-plugin/blob/main/docs/rules/%s.md",
			["github"] = "https://github.com/github/eslint-plugin-github/blob/main/docs/rules/%s.md",
			["jest"] = "https://github.com/jest-community/eslint-plugin-jest/blob/main/docs/rules/%s.md",
			["jest-dom"] = "https://github.com/testing-library/eslint-plugin-jest-dom/blob/main/docs/rules/%s.md",
			["jsdoc"] = "https://github.com/gajus/eslint-plugin-jsdoc/blob/main/docs/rules/%s.md",
			["jsx-a11y"] = "https://github.com/jsx-eslint/eslint-plugin-jsx-a11y/blob/main/docs/rules/%s.md",
			["n"] = "https://github.com/eslint-community/eslint-plugin-n/blob/master/docs/rules/%s.md",
			["n/no-unsupported-features"] = "https://github.com/eslint-community/eslint-plugin-n/blob/master/docs/rules/no-unsupported-features/%s.md",
			["n/prefer-global"] = "https://github.com/eslint-community/eslint-plugin-n/blob/master/docs/rules/prefer-global/%s.md",
			["n/prefer-promises"] = "https://github.com/eslint-community/eslint-plugin-n/blob/master/docs/rules/prefer-promises/%s.md",
			["promise"] = "https://github.com/eslint-community/eslint-plugin-promise/blob/main/docs/rules/%s.md",
			["react"] = "https://github.com/jsx-eslint/eslint-plugin-react/blob/master/docs/rules/%s.md",
			["react-redux"] = "https://github.com/DianaSuvorova/eslint-plugin-react-redux/blob/master/docs/rules/%s.md",
			["security"] = "https://github.com/eslint-community/eslint-plugin-security/blob/main/docs/rules/%s.md",
			["solid"] = "https://github.com/solidjs-community/eslint-plugin-solid/blob/main/docs/%s.md",
			["svelte"] = "https://github.com/sveltejs/eslint-plugin-svelte/blob/main/docs/rules/%s.md",
			["tailwindcss"] = "https://github.com/francoismassart/eslint-plugin-tailwindcss/blob/master/docs/rules/%s.md",
			["testing_library"] = "https://github.com/testing-library/eslint-plugin-testing-library/blob/main/docs/rules/%s.md",
			["unicorn"] = "https://github.com/sindresorhus/eslint-plugin-unicorn/blob/main/docs/rules/%s.md",
			["vue"] = "https://github.com/vuejs/eslint-plugin-vue/blob/master/docs/rules/%s.md",
			["wc"] = "https://github.com/43081j/eslint-plugin-wc/tree/master/docs/rules/%s.md",
		}

		for name, url in pairs(pluginDocUrls) do
			if plugin == name then return string.format(url, rule) end
		end
	end,

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

	-- urls use rule-name, not rule-id, so this is the closest we can get
	pylint = "https://pylint.readthedocs.io/en/stable/search.html?q=%s",

	markdownlint = function(diag)
		local code = tostring(diag.code):gsub("^MD", "")
		if #code == 2 then code = "0" .. code end -- efm removes leading 0, but markdownlint needs it
		return ("https://github.com/DavidAnson/markdownlint/blob/main/doc/md%s.md"):format(code)
	end,

	swiftlint = "https://realm.github.io/SwiftLint/%s.html",

	-----------------------------------------------------------------------------

	Ruff = urlInDiagObj,
	["clang-tidy"] = urlInDiagObj,
	Pyright = urlInDiagObj,
	["ansible-lint"] = urlInDiagObj,
	basedpyright = urlInDiagObj,
	biome = urlInDiagObj,
	["quick-lint-js"] = urlInDiagObj,
}

--------------------------------------------------------------------------------

M.tsserver = M.typescript -- typescript-tools.nvim
M.ts = M.typescript -- vtsls
M.stylelintplus = M.stylelint -- stylelint-lsp
M.ltex_plus = M.LTeX -- ltex fork

--------------------------------------------------------------------------------
return M
