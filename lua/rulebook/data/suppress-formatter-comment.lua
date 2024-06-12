---@class formatterSuppressConfig
---@field ignoreBlock string used in normal mode
---@field location "prevLine"|"sameLine" where the `ignoreBlock` is inserted
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
		ignoreRange = { "# fmt: on", "# fmt: off" },
		location = "sameLine",
		ignoreBlock = "# fmt: skip",
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
		ignoreRange = { "<!-- prettier-ignore-start -->", "<!-- prettier-ignore-end -->" },
		location = "prevLine",
		docs = "https://prettier.io/docs/en/ignore.html#markdown",
	},
}

--------------------------------------------------------------------------------
return M
