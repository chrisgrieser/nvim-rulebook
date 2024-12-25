<!-- LTeX: enabled=false -->
# nvim-rulebook 📖
<!-- LTeX: enabled=true -->
<a href="https://dotfyle.com/plugins/chrisgrieser/nvim-rulebook"><img
alt ="badge" src="https://dotfyle.com/plugins/chrisgrieser/nvim-rulebook/shield"/></a>

Add inline-comments to ignore rules, or lookup rule documentation online.

Some LSPs provide code actions for that – this plugin adds commands for linters
and LSPs that don't.

<!-- toc -->

- [Features](#features)
- [Supported sources](#supported-sources)
	* [Rule lookup](#rule-lookup)
	* [Add ignore comment](#add-ignore-comment)
	* [Suppress formatting](#suppress-formatting)
- [Installation](#installation)
- [Configuration](#configuration)
- [Customize builtin sources](#customize-builtin-sources)
- [Limitations](#limitations)
- [API](#api)
	* [Availability of rule lookup](#availability-of-rule-lookup)
- [Credits](#credits)

<!-- tocstop -->

## Features
- Look up official rule documentation, falling back to a web search if the
  source does not have rule documentation.
- Add inline-comments to ignore rules like `// eslint disable-next-line
  some-rule`. Supports previous line, same line, and enclosing lines.
- Suppress formatting with via ignore comments of the respective formatter, such
  as `// prettier-ignore`.
- QoL: auto-select a rule if it is the only one in the current line; if the line
  has no diagnostic, search forward to the next line that does.
- Includes built-in support for various linters and formatters. No plugin
  configuration required if you only need to use built-in sources.
- Customizing built-in sources or adding your own sources is easy. PRs to add
  more built-ins are welcome.

## Supported sources
You easily add a custom source via the [plugin configuration](#configuration).
Though, please consider making a PR to add support for a source if it is
missing.

[Rule data for built-in support of linters and formatters](./lua/rulebook/data)

<!-- INFO use `just update-readme` to automatically update this section -->
<!-- auto-generated: start -->
### Rule lookup
- `LTeX`
- `Lua Diagnostics.`
- `Pyright`
- `Ruff`
- `basedpyright`
- `biome`
- `clang-tidy`
- `eslint`
- `markdownlint`
- `pylint`
- `quick-lint-js`
- `selene`
- `shellcheck`
- `stylelint`
- `stylelintplus`
- `ts`
- `tsserver`
- `typescript`
- `yamllint`

### Add ignore comment
- [LTeX](https://valentjn.github.io/ltex/advanced-usage.html)
- [Lua Diagnostics.](https://luals.github.io/wiki/annotations/#diagnostic)
- [Pyright](https://microsoft.github.io/pyright/#/comments)
- [Ruff](https://docs.astral.sh/ruff/linter/#error-suppression)
- [alex](https://github.com/get-alex/alex#control)
- [basedpyright](https://microsoft.github.io/pyright/#/comments)
- [biome](https://biomejs.dev/linter/#ignore-code)
- [clang-tidy](https://clang.llvm.org/extra/clang-tidy/#suppressing-undesired-diagnostics)
- [codespell](https://github.com/codespell-project/codespell/issues/1212#issuecomment-1721152455)
- [editorconfig-checker](https://github.com/editorconfig-checker/editorconfig-checker#excluding-lines)
- [eslint](https://eslint.org/docs/latest/use/configure/rules#using-configuration-comments-1)
- [pylint](https://pylint.readthedocs.io/en/latest/user_guide/messages/message_control.html)
- [selene](https://kampfkarren.github.io/selene/usage/filtering.html#allowingdenying-lints-for-an-entire-file)
- [shellcheck](https://www.shellcheck.net/wiki/Ignore)
- [spellwarn](https://github.com/ravibrock/spellwarn.nvim#usage)
- [stylelint](https://stylelint.io/user-guide/ignore-code/)
- [stylelintplus](https://stylelint.io/user-guide/ignore-code/)
- [ts](https://www.typescriptlang.org/)
- [tsserver](https://www.typescriptlang.org/)
- [typescript](https://www.typescriptlang.org/)
- [vale-ls](https://vale.sh/docs/topics/config/#markup-based-configuration)
- [vale](https://vale.sh/docs/topics/config/#markup-based-configuration)
- [woke](https://docs.getwoke.tech/ignore/#in-line-and-next-line-ignoring)
- [yamllint](https://yamllint.readthedocs.io/en/stable/disable_with_comments.html)
<!-- auto-generated: end -->

<!-- TODO: auto-generate this section as well? -->
### Suppress formatting
- [stylua](https://github.com/JohnnyMorganz/StyLua#ignoring-parts-of-a-file)
- [prettier](https://prettier.io/docs/en/ignore.html)
- [black](https://black.readthedocs.io/en/stable/usage_and_configuration/the_basics.html#ignoring-sections)
  / [ruff](https://docs.astral.sh/ruff/formatter/#format-suppression)
- [clang-format](https://clang.llvm.org/docs/ClangFormatStyleOptions.html#disabling-formatting-on-a-piece-of-code)

## Installation
**Requirements**
- nvim 0.10+
- Diagnostics provided by a source that supports Neovim's built-in diagnostics
  system. (nvim's built-in LSP client,
  [efm-langserver](https://github.com/mattn/efm-langserver) or
  [nvim-lint](https://github.com/mfussenegger/nvim-lint) are such sources.)

```lua
-- lazy.nvim
{ "chrisgrieser/nvim-rulebook" },

-- packer
use { "chrisgrieser/nvim-rulebook" }
```

## Usage
You can use the commands via lua functions:

```lua
vim.keymap.set("n", "<leader>ri", function() require("rulebook").ignoreRule() end)
vim.keymap.set("n", "<leader>rl", function() require("rulebook").lookupRule() end)
vim.keymap.set("n", "<leader>ry", function() require("rulebook").yankDiagnosticCode() end)
vim.keymap.set({ "n", "x" }, "<leader>rf", function() require("rulebook").suppressFormatter() end)
```

Alternatively, you can use the `:Rulebook` ex-command:

```vim
:Rulebook ignoreRule
:Rulebook lookupRule
:Rulebook yankDiagnosticCode
:Rulebook suppressFormatter
```

Note that `:Rulebook suppressFormatter` only supports normal mode. To add
formatter-ignore comments for a line range, you need to use the lua function
`require("rulebook").suppressFormatter()` from visual mode.

## Configuration
The `.setup()` call is optional. You only need to add a config when you want to
add or customize sources.

When adding your own source, you must add the exact, case-sensitive
source name, for example, `clang-tidy`, not `clang`.

```lua
require("rulebook").setup = ({
	-- if no diagnostic is found in current line, search this many lines forward
	forwSearchLines = 10,

	ignoreComments = {
		shellcheck = {
			comment = "# shellcheck disable=%s",
			location = "prevLine",
			multiRuleIgnore = true,
			multiRuleSeparator = ",",
		},
		-- ... (full list of sources with builtin support can be found in the README)

		yourCustomSource = { -- exact, case-sensitive source-name
			-- `%s` will be replaced with rule-id
			comment = "// disabling-comment %s",

			---@type "prevLine"|"sameLine"|"encloseLine"
			location = "sameLine",

			-- whether multiple rules can be ignored with one comment, defaults to `false`
			multiRuleIgnore = true,

			-- separator for multiple rule-ids, defaults to ", "
			multiRuleSeparator = ",",
		}

		-- if location is "encloseLine", needs to be a list of two strings
		anotherCustomSource = {
			comment = { 
				"// disable-rule %s", 
				"// enable-rule %s",
			},
			location = "encloseLine",
		}
	},

	ruleDocs = {
		selene = "https://kampfkarren.github.io/selene/lints/%s.html"
		-- ... (full list of supported sources can be found in the README)

		-- Search URL when no documentation definition is available for a
		-- diagnostic source. `%s` will be replaced with the diagnostic source & code.
		-- Default is the DDG "Ducky Search" (automatically opening first result).
		fallback = "https://duckduckgo.com/?q=%s+%%21ducky&kl=en-us",

		-- the value of the rule documentations accept either a string or a function
		-- * if a string, `%s` will be replaced with rule-id
		-- * if a function, takes a `:h diagnostic-structure` as argument & return a url
		yourCustomSource = "https://my-docs/%s.hthml",
		anotherCustomSource = function(diag)
			-- ...
			return url
		end,
	}

	suppressFormatter = {
		lua = {
			-- normal mode
			ignoreBlock = "-- stylua: ignore",
			location = "prevLine",

			-- visual mode
			ignoreRange = { "-- stylua: ignore start", "-- stylua: ignore start" },
		},
	}
})
```

The plugin uses
[vim.ui.select](https://neovim.io/doc/user/lua.html#vim.ui.select()), so the
appearance of the rule selection can be customized by using a UI-plugin like
[dressing.nvim](https://github.com/stevearc/dressing.nvim).

## Customize builtin sources
Built-in sources be customized by overwriting them in the configuration:

```lua
-- example: use `disable-line` instead of the default `disable-next-line` for eslint
require("rulebook").setup = {
	ignoreComments = {
		eslint = {
			comment = "// eslint-disable-line %s",
			location = "sameLine",
		},
	},
}
```

## Limitations
- The diagnostics have to contain the necessary data, [that is a diagnostic code
  and diagnostic
  source](https://neovim.io/doc/user/diagnostic.html#diagnostic-structure). Most
  LSPs and most linters configured for `nvim-lint`/`efm` do that, but some diagnostic
  sources do not (for example, `efm` with incorrectly defined `errorformat`).
  Please open an issue at the diagnostics provider to fix such
  issues.
- This plugin does not hook into `vim.lsp.buf.code_action`, but provides its own
  selector.

## API

### Availability of rule lookup
The function `require("rulebook").hasDocs(diag)`, expects a diagnostic object
and returns a boolean whether `nvim-rulebook` documentation for the respective
diagnostic available. One use case for this is to add a visual indicator if
there is a rule lookup available for a diagnostic (see
[vim.diagnostic.config](https://neovim.io/doc/user/diagnostic.html#vim.diagnostic.config())).

```lua
vim.diagnostic.config {
	virtual_text = {
		suffix = function(diag) return require("rulebook").hasDocs(diag) and "  " or "" end,
	},
}
```

## Credits
In my day job, I am a sociologist studying the social mechanisms underlying the
digital economy. For my PhD project, I investigate the governance of the app
economy and how software ecosystems manage the tension between innovation and
compatibility. If you are interested in this subject, feel free to get in touch.

I also occasionally blog about vim: [Nano Tips for Vim](https://nanotipsforvim.prose.sh)

- [Website](https://chris-grieser.de/)
- [Mastodon](https://pkm.social/@pseudometa)
- [ResearchGate](https://www.researchgate.net/profile/Christopher-Grieser)
- [LinkedIn](https://www.linkedin.com/in/christopher-grieser-ba693b17a/)

<a href='https://ko-fi.com/Y8Y86SQ91' target='_blank'><img height='36'
style='border:0px;height:36px;' src='https://cdn.ko-fi.com/cdn/kofi1.png?v=3'
border='0' alt='Buy Me a Coffee at ko-fi.com' /></a>
