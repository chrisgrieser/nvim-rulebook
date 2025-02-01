---@class ruleIgnoreConfig
---@field comment string|string[]|fun(vim.Diagnostic): string if string, "%s" will be replaced with the rule id
---@field location "prevLine"|"sameLine"|"encloseLine" "encloseLine" is a list with two strings, one to be inserted before and one after
---@field docs string used for auto-generated docs
---@field doesNotUseCodes? boolean the linter does not use codes/rule-ids
---@field multiRuleIgnore? boolean whether multiple rules can be ignored with one comment, defaults to `false`
---@field multiRuleSeparator? string defaults to ", "

---INFO the key must be named like the exact, case-sensitive `diagnostic.source`
--------------------------------------------------------------------------------

---@type table<string, ruleIgnoreConfig>
M = {
	shellcheck = {
		comment = "# shellcheck disable=%s",
		location = "prevLine",
		docs = "https://www.shellcheck.net/wiki/Ignore",
		multiRuleIgnore = true,
		multiRuleSeparator = ",", -- with space throws this parsing error: https://www.shellcheck.net/wiki/SC1073
	},
	selene = {
		comment = "-- selene: allow(%s)",
		location = "prevLine",
		docs = "https://kampfkarren.github.io/selene/usage/filtering.html#allowingdenying-lints-for-an-entire-file",
		multiRuleIgnore = true,
	},
	["Lua Diagnostics."] = { -- Lua LSP
		comment = "---@diagnostic disable-line: %s",
		location = "sameLine", -- prevLine already available via code action
		docs = "https://luals.github.io/wiki/annotations/#diagnostic",
		multiRuleIgnore = true,
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
		multiRuleIgnore = true,
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
		multiRuleIgnore = true,
	},
	Pyright = {
		comment = "# pyright: ignore [%s]",
		location = "sameLine",
		docs = "https://microsoft.github.io/pyright/#/comments",
		multiRuleIgnore = true,
	},
	Ruff = {
		comment = "# noqa: %s",
		location = "sameLine",
		docs = "https://docs.astral.sh/ruff/linter/#error-suppression",
		multiRuleIgnore = true,
	},
	eslint = {
		comment = "// eslint-disable-next-line %s",
		location = "prevLine",
		docs = "https://eslint.org/docs/latest/use/configure/rules#using-configuration-comments-1",
		multiRuleIgnore = true,
	},
	biome = {
		-- biome works for css and js, so the comment syntax is dependent on the filetype
		comment = function(diag)
			local ignoreText = ("biome-ignore %s: <explanation>"):format(diag.code)
			return vim.bo.commentstring:format(ignoreText)
		end,
		location = "prevLine",
		docs = "https://biomejs.dev/linter/#ignore-code",
		multiRuleIgnore = false, -- apparently not supported
	},
	typescript = {
		comment = "// @ts-expect-error", -- https://typescript-eslint.io/rules/prefer-ts-expect-error/
		location = "prevLine",
		docs = "https://www.typescriptlang.org/", -- no docs found that are more specific
	},
	["editorconfig-checker"] = {
		comment = function(_) return vim.bo.commentstring:format("editorconfig-checker-disable-line") end,
		location = "sameLine",
		docs = "https://github.com/editorconfig-checker/editorconfig-checker#excluding-lines",
		doesNotUseCodes = true,
	},
	codespell = {
		comment = function(_) return vim.bo.commentstring:format("codespell-ignore") end,
		location = "sameLine",
		-- HACK uses workaround via `codespell --ignore-regex`
		docs = "https://github.com/codespell-project/codespell/issues/1212#issuecomment-1721152455",
		doesNotUseCodes = true,
	},
	["clang-tidy"] = {
		comment = "// NOLINT(%s)",
		location = "sameLine",
		docs = "https://clang.llvm.org/extra/clang-tidy/#suppressing-undesired-diagnostics",
		multiRuleIgnore = true,
	},
	alex = {
		comment = "<!-- alex ignore %s -->",
		location = "prevLine",
		docs = "https://github.com/get-alex/alex#control",
	},
	woke = {
		comment = function(diag)
			local ignoreText = "wokeignore:rule=" .. diag.code
			return vim.bo.commentstring:format(ignoreText)
		end,
		location = "sameLine",
		docs = "https://docs.getwoke.tech/ignore/#in-line-and-next-line-ignoring",
	},
	spellwarn = { -- not a linter, but a nvim plugin
		comment = function(_) return vim.bo.commentstring:format("spellwarn:disable-line") end,
		location = "sameLine",
		docs = "https://github.com/ravibrock/spellwarn.nvim#usage",
		doesNotUseCodes = true,
	},
	["ansible-lint"] = {
		comment = "# noqa: %s",
		location = "sameLine",
		docs = "https://ansible.readthedocs.io/projects/lint/usage/#muting-warnings-to-avoid-false-positives",
		multiRuleIgnore = true,
		multiRuleSeparator = " ",
	},
	markdownlint = {
		comment = function(diag)
			local code = tostring(diag.code):gsub("^MD", "")
			if #code == 2 then code = "0" .. code end -- `efm` removes leading 0, but markdownlint needs it
			return ("<!-- markdownlint-disable-next-line MD%s -->"):format(code)
		end,
		location = "prevLine",
		docs = "https://github.com/DavidAnson/markdownlint#configuration",
		multiRuleIgnore = false, -- apparently not supported
	},
}

M.tsserver = M.typescript -- typescript-tools.nvim
M.ts = M.typescript -- vtsls
M["vale-ls"] = M.vale -- lsp and linter have separate source names
M.stylelintplus = M.stylelint -- stylelint-lsp
M.basedpyright = M.Pyright -- pyright fork
M.ltex_plus = M.LTeX -- ltex fork

--------------------------------------------------------------------------------
return M
