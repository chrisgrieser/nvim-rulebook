---"encloseLine" is a list with two strings, one to be inserted before and one after
---@alias Rulebook.Location "prevLine"|"sameLine"|"encloseLine"|"inlineBeforeDiagnostic"

---@class Rulebook.RuleIgnoreConfig
---@field comment string|string[]|fun(vim.Diagnostic): string if string, "%s" is replaced with rule-id
---@field location Rulebook.Location|fun(vim.Diagnostic): Rulebook.Location
---@field docs string used for auto-generated docs
---@field info? string used for auto-generated docs
---@field doesNotUseCodes? boolean linter does not use codes/rule-ids
---@field multiRuleIgnore boolean whether multiple rules can be ignored with one comment, defaults to `false`
---@field multiRuleSeparator? string defaults to ", " (with space)

--------------------------------------------------------------------------------

---INFO the key must exactly match `diagnostic.source` (case-sensitive)
---@type table<string, Rulebook.RuleIgnoreConfig>
local M = {
	clippy = {
		comment = "#[expect(%s)]",
		location = "prevLine",
		multiRuleIgnore = true,
		multiRuleSeparator = ", ",
		docs = "https://doc.rust-lang.org/reference/attributes/diagnostics.html#r-attributes.diagnostics.expect",
	},
	["ast-grep"] = {
		comment = function(diag) return vim.bo.commentstring:format("ast-grep-ignore: " .. diag.code) end,
		location = "prevLine",
		docs = "https://ast-grep.github.io/guide/project/severity.html#ignore-linting-error",
		multiRuleIgnore = true,
		multiRuleSeparator = ",", -- no space
	},
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
	["Lua Diagnostics."] = { -- Lua LSP, SIC source name has a trailing `.`
		comment = "---@diagnostic disable-line: %s",
		location = "sameLine", -- prevLine already available via code action
		docs = "https://luals.github.io/wiki/annotations/#diagnostic",
		info = "(source name for `lua_ls`)",
		multiRuleIgnore = true,
	},
	EmmyLua = {
		comment = "---@diagnostic disable-line: %s", -- uses same syntax as `lua_ls`
		location = "sameLine", -- prevLine already available via code action
		docs = "https://github.com/EmmyLuaLs/emmylua-analyzer-rust/blob/main/docs/features/features_EN.md#code-checks",
		multiRuleIgnore = true,
	},
	yamllint = {
		comment = "# yamllint disable-line rule:%s",
		location = "prevLine",
		docs = "https://yamllint.readthedocs.io/en/stable/disable_with_comments.html",
		multiRuleIgnore = false,
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
		multiRuleIgnore = false,
	},
	vale = {
		comment = { "<!-- vale %s = NO -->", "<!-- vale %s = YES -->" },
		location = "encloseLine",
		docs = "https://vale.sh/docs/topics/config/#markup-based-configuration",
		multiRuleIgnore = false,
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
		comment = function(diag)
			local ignoreText = ("biome-ignore %s: explanation"):format(diag.code)
			return vim.bo.commentstring:format(ignoreText)
		end,
		location = "prevLine",
		docs = "https://biomejs.dev/analyzer/suppressions/#suppression-syntax",
		multiRuleIgnore = false,
	},
	typescript = {
		comment = "// @ts-expect-error",
		location = "prevLine",
		docs = "https://typescript-eslint.io/rules/prefer-ts-expect-error/",
		multiRuleIgnore = false,
	},
	["editorconfig-checker"] = {
		comment = function(_) return vim.bo.commentstring:format("editorconfig-checker-disable-line") end,
		location = "sameLine",
		docs = "https://github.com/editorconfig-checker/editorconfig-checker#excluding-lines",
		doesNotUseCodes = true,
		multiRuleIgnore = false,
	},
	codespell = {
		comment = function(_) return vim.bo.commentstring:format("codespell-ignore") end,
		location = "sameLine",
		docs = "https://github.com/codespell-project/codespell/issues/1212#issuecomment-1721152455",
		info = '(requires setting `--ignore-regex` to `ignore-regex=".*codespell-ignore$"`)',
		doesNotUseCodes = true,
		multiRuleIgnore = false,
	},
	typos = {
		comment = function(_) return vim.bo.commentstring:format("typos: ignore-line") end,
		location = "sameLine",
		docs = "https://github.com/crate-ci/typos/issues/316#issuecomment-2886204780",
		info = '(requires setting\n  `[default] extend-ignore-re = ["[^\\\\n]*typos: ignore-line[^\\\\n]*\\\\n"]`)',
		doesNotUseCodes = true,
		multiRuleIgnore = false,
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
		multiRuleIgnore = false,
	},
	woke = {
		comment = function(diag) return vim.bo.commentstring:format("wokeignore:rule=" .. diag.code) end,
		location = "sameLine",
		docs = "https://docs.getwoke.tech/ignore/#in-line-and-next-line-ignoring",
		multiRuleIgnore = false,
	},
	spellwarn = { -- not a linter, but a nvim plugin
		comment = function(_) return vim.bo.commentstring:format("spellwarn:disable-line") end,
		location = "sameLine",
		docs = "https://github.com/ravibrock/spellwarn.nvim#usage",
		doesNotUseCodes = true,
		multiRuleIgnore = false,
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
			local commentTemplate = "<!-- markdownlint-disable-next-line %s -->"
			local commentWithNumber = commentTemplate:format("MD" .. code)

			-- if possible, prefer rule alias instead of rule number for readability
			if vim.fn.executable("curl") == 0 then return commentWithNumber end
			-- stylua: ignore
			local url = ("https://raw.githubusercontent.com/DavidAnson/markdownlint/refs/heads/main/doc/md%s.md"):format(code)
			local out = vim.system({ "curl", url }):wait()
			if out.code ~= 0 then return commentWithNumber end
			local _, _, ruleAlias = out.stdout:find("Aliases: `([%w-]+)`")
			if not ruleAlias then return commentWithNumber end
			return commentTemplate:format(ruleAlias)
		end,
		location = "prevLine",
		docs = "https://github.com/DavidAnson/markdownlint#configuration",
		multiRuleIgnore = false,
	},
	rumdl = {
		comment = "<!-- rumdl-disable-line %s -->",
		location = "sameLine",
		docs = "https://github.com/rvben/rumdl/blob/main/docs/inline-configuration.md",
		multiRuleIgnore = true,
		multiRuleSeparator = " ",
	},
	swiftlint = {
		comment = "// swiftlint:disable:next %s",
		location = "prevLine",
		docs = "https://realm.github.io/SwiftLint/#Disable-rules-in-code",
		multiRuleIgnore = true,
		multiRuleSeparator = " ",
	},
	Harper = {
		comment = function() return vim.bo.commentstring:format("harper: ignore") end,
		location = function(diag)
			-- in markdown, harper only works properly with ignore directions in the same line
			local ft = vim.bo[diag.bufnr or 0].filetype
			return ft == "markdown" and "inlineBeforeDiagnostic" or "prevLine"
		end,
		docs = "https://writewithharper.com/docs/integrations/language-server#Ignore-Comments",
		multiRuleIgnore = false,
		doesNotUseCodes = true,
	},
	cspell = {
		comment = function() return vim.bo.commentstring:format("cspell:disable-next-line") end,
		location = "prevLine",
		docs = "https://github.com/streetsidesoftware/cspell/blob/main/packages/cspell/README.md#enable--disable-checking-sections-of-code",
		multiRuleIgnore = false,
		doesNotUseCodes = true,
	},
	ty = {
		comment = "# ty: ignore[%s]",
		docs = "https://github.com/astral-sh/ty/blob/main/docs/README.md#ty-suppression-comments",
		location = "sameLine",
		multiRuleIgnore = true,
		multiRuleSeparator = ", ",
	},
	mypy = {
		comment = "# type: ignore[%s]",
		docs = "https://mypy.readthedocs.io/en/stable/error_codes.html#silencing-errors-based-on-error-codes",
		location = "sameLine",
		multiRuleIgnore = true,
		multiRuleSeparator = ", ",
	},
	Pyrefly = {
		comment = "# pyrefly: ignore",
		docs = "https://pyrefly.org/en/docs/error-suppressions/",
		location = "sameLine",
		multiRuleIgnore = false,
	},
	Tombi = {
		comment = "# tombi: lint.rules.%s.disabled = true",
		docs = "https://tombi-toml.github.io/tombi/docs/comment-directive/",
		location = "prevLine",
		multiRuleIgnore = false,
	},
}

--------------------------------------------------------------------------------

-- TOOLS THAT INHERIT THE CONFIGURATION OF OTHER TOOLS
M.tsserver = M.typescript -- typescript-tools.nvim
M.ts = M.typescript -- vtsls
M["vale-ls"] = M.vale -- lsp and linter have separate source names
M.stylelintplus = M.stylelint -- stylelint-lsp
M.basedpyright = M.Pyright -- pyright fork
M.ltex_plus = M.LTeX -- ltex fork
M["rust-analyzer"] = M.clippy -- they use the same Rust attribute syntax
M["markdownlint-cli2"] = M.markdownlint

--------------------------------------------------------------------------------
return M
