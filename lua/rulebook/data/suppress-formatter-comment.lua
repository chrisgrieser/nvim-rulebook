---@class Rulebook.FormatterSuppressConfig
---@field ignoreBlock string|string[] used in normal mode
---@field location Rulebook.Location|fun(): Rulebook.Location
---@field ignoreRange? string[] list of two strings (start and end), will surround the visual mode selection
---@field docs string used for auto-generated docs
---@field formatterName string used for auto-generated docs

--------------------------------------------------------------------------------

---INFO the key must exactly match the `vim.bo.filetype`
---@type table<string, Rulebook.FormatterSuppressConfig>
local M = {
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
		-- the same for `ruff`: https://docs.astral.sh/ruff/formatter/#format-suppression
		docs = "https://black.readthedocs.io/en/stable/usage_and_configuration/the_basics.html#ignoring-sections",
		formatterName = "ruff / black",
	},
	javascript = {
		ignoreBlock = "// prettier: ignore",
		location = "prevLine",
		ignoreRange = { "// prettier-ignore-start", "// prettier-ignore-end" },
		docs = "https://prettier.io/docs/ignore.html",
		formatterName = "prettier",
	},
	css = {
		ignoreBlock = "/* prettier-ignore */",
		location = "prevLine",
		ignoreRange = { "/* prettier-ignore-start */", "/* prettier-ignore-end */" },
		docs = "https://prettier.io/docs/ignore.html",
		formatterName = "prettier",
	},
	yaml = {
		ignoreBlock = "# prettier-ignore",
		location = "prevLine",
		ignoreRange = { "# prettier-ignore-start", "# prettier-ignore-end" },
		docs = "https://prettier.io/docs/ignore.html",
		formatterName = "prettier",
	},
	html = {
		ignoreBlock = "<!-- prettier-ignore -->",
		location = "prevLine",
		ignoreRange = { "<!-- prettier-ignore-start -->", "<!-- prettier-ignore-end -->" },
		docs = "https://prettier.io/docs/ignore.html",
		formatterName = "prettier",
	},
	markdown = {
		ignoreBlock = "<!-- prettier-ignore -->",
		location = "prevLine",
		ignoreRange = { "<!-- prettier-ignore-start -->", "<!-- prettier-ignore-end -->" },
		docs = "https://prettier.io/docs/ignore.html",
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
