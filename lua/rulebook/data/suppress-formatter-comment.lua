---@class formatterSuppressConfig
---@field ignoreBlock string|string[] used in normal mode
---@field location "prevLine"|"sameLine"|"encloseLine" where `ignoreBlock` is inserted. "encloseLine" is a list with two strings, one to be inserted before and one after
---@field ignoreRange? string[] list of two strings (start and end), will surround the visual mode selection
---@field docs string only used for auto-generated docs
---@field formatterName string only used for auto-generated docs

---@type table<string, formatterSuppressConfig>
M = {
	lua = {
		ignoreBlock = "-- stylua: ignore",
		location = "prevLine",
		ignoreRange = { "-- stylua: ignore start", "-- stylua: ignore end" },
		docs = "https://github.com/JohnnyMorganz/StyLua#ignoring-parts-of-a-file",
		formatterName = "stylua",
	},
	python = {
		ignoreBlock = "# fmt: skip",
		location = "sameLine",
		ignoreRange = { "# fmt: on", "# fmt: off" },
		docs = "https://black.readthedocs.io/en/stable/usage_and_configuration/the_basics.html#ignoring-sections",
		formatterName = "ruff / black",
		-- the same for `ruff`: https://docs.astral.sh/ruff/formatter/#format-suppression
	},
	javascript = {
		ignoreBlock = "// prettier: ignore",
		location = "prevLine",
		ignoreRange = { "// prettier-ignore-start", "// prettier-ignore-end" },
		docs = "https://prettier.io/docs/en/ignore.html#javascript",
		formatterName = "prettier",
	},
	css = {
		ignoreBlock = "/* prettier-ignore */",
		location = "prevLine",
		ignoreRange = { "/* prettier-ignore-start */", "/* prettier-ignore-end */" },
		docs = "https://prettier.io/docs/en/ignore.html#css",
		formatterName = "prettier",
	},
	yaml = {
		ignoreBlock = "# prettier-ignore",
		location = "prevLine",
		ignoreRange = { "# prettier-ignore-start", "# prettier-ignore-end" },
		docs = "https://prettier.io/docs/en/ignore.html#yaml",
		formatterName = "prettier",
	},
	html = {
		ignoreBlock = "<!-- prettier-ignore -->",
		location = "prevLine",
		ignoreRange = { "<!-- prettier-ignore-start -->", "<!-- prettier-ignore-end -->" },
		docs = "https://prettier.io/docs/en/ignore.html#html",
		formatterName = "prettier",
	},
	markdown = {
		ignoreBlock = "<!-- prettier-ignore -->",
		location = "prevLine",
		ignoreRange = { "<!-- prettier-ignore-start -->", "<!-- prettier-ignore-end -->" },
		docs = "https://prettier.io/docs/en/ignore.html#markdown",
		formatterName = "prettier",
	},
	c = {
		ignoreBlock = { "/* clang-format off */", "/* clang-format on */" },
		location = "encloseLine",
		ignoreRange = { "/* clang-format off */", "/* clang-format on */" },
		docs = "https://clang.llvm.org/docs/ClangFormatStyleOptions.html#disabling-formatting-on-a-piece-of-code",
		formatterName = "clang-format",
	},
	cpp = {
		ignoreBlock = { "/* clang-format off */", "/* clang-format on */" },
		location = "encloseLine",
		ignoreRange = { "/* clang-format off */", "/* clang-format on */" },
		docs = "https://clang.llvm.org/docs/ClangFormatStyleOptions.html#disabling-formatting-on-a-piece-of-code",
		formatterName = "clang-format",
	},
}
--------------------------------------------------------------------------------

M.typescript = M.javascript
M.typescriptreact = M.javascript
M.javascriptreact = M.javascript
M.svelte = M.javascript
M.vue = M.javascript
M.scss = M.css

--------------------------------------------------------------------------------
return M
