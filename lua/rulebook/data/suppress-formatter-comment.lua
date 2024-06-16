---@class formatterSuppressConfig
---@field ignoreBlock string|string[] used in normal mode
---@field location "prevLine"|"sameLine"|"encloseLine" where `ignoreBlock` is inserted. "encloseLine" is a list with two strings, one to be inserted before and one after
---@field ignoreRange? string[] list of two strings (start and end), will surround the visual mode selection
---@field docs string used for auto-generated docs

---@type table<string, formatterSuppressConfig>
M = {
	lua = {
		ignoreBlock = "-- stylua: ignore",
		location = "prevLine",
		ignoreRange = { "-- stylua: ignore start", "-- stylua: ignore end" },
		docs = "https://github.com/JohnnyMorganz/StyLua#ignoring-parts-of-a-file",
	},
	python = {
		ignoreBlock = "# fmt: skip",
		location = "sameLine",
		ignoreRange = { "# fmt: on", "# fmt: off" },
		docs = "https://black.readthedocs.io/en/stable/usage_and_configuration/the_basics.html#ignoring-sections",
		-- the same for `ruff`: https://docs.astral.sh/ruff/formatter/#format-suppression
	},
	javascript = {
		ignoreBlock = "// prettier: ignore",
		location = "prevLine",
		docs = "https://prettier.io/docs/en/ignore.html#javascript",
	},
	typescript = {
		ignoreBlock = "// prettier: ignore",
		location = "prevLine",
		docs = "https://prettier.io/docs/en/ignore.html#javascript",
	},
	javascriptreact = {
		ignoreBlock = "{/* prettier-ignore */}",
		location = "prevLine",
		docs = "https://prettier.io/docs/en/ignore.html#jsx",
	},
	css = {
		ignoreBlock = "/* prettier-ignore */",
		location = "prevLine",
		docs = "https://prettier.io/docs/en/ignore.html#css",
	},
	yaml = {
		ignoreBlock = "# prettier-ignore",
		location = "prevLine",
		docs = "https://prettier.io/docs/en/ignore.html#yaml",
	},
	html = {
		ignoreBlock = "<!-- prettier-ignore -->",
		location = "prevLine",
		docs = "https://prettier.io/docs/en/ignore.html#html",
	},
	markdown = {
		ignoreBlock = "<!-- prettier-ignore -->",
		location = "prevLine",
		ignoreRange = { "<!-- prettier-ignore-start -->", "<!-- prettier-ignore-end -->" },
		docs = "https://prettier.io/docs/en/ignore.html#markdown",
	},
}

--------------------------------------------------------------------------------
return M
