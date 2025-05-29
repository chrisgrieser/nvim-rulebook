<!-- LTeX: enabled=false -->
# nvim-rulebook 📖
<!-- LTeX: enabled=true -->
<a href="https://dotfyle.com/plugins/chrisgrieser/nvim-rulebook"><img
alt ="badge" src="https://dotfyle.com/plugins/chrisgrieser/nvim-rulebook/shield"/></a>

Add inline-comments to ignore rules or suppress formatters. Lookup rule
documentation online. Built-in configuration for 35+ linters and LSPs.

## Table of contents

<!-- toc -->

- [Features](#features)
- [Supported sources](#supported-sources)
	* [Rule lookup](#rule-lookup)
	* [Add ignore comment](#add-ignore-comment)
	* [Suppress formatting](#suppress-formatting)
- [Installation](#installation)
- [Usage](#usage)
- [Configuration](#configuration)
	* [Base configuration](#base-configuration)
	* [Customize built-in sources](#customize-built-in-sources)
- [FAQ](#faq)
	* [How to directly ask an LLM about a rule](#how-to-directly-ask-an-llm-about-a-rule)
	* [How to configure diagnostic providers](#how-to-configure-diagnostic-providers)
	* [How to display the availability of rule lookup](#how-to-display-the-availability-of-rule-lookup)
- [Credits](#credits)

<!-- tocstop -->

## Features
- Look up official rule documentation, falling back to a customizable web search
  if the source does not have rule documentation.
- Add inline-comments to ignore rules like `// eslint disable-next-line
  some-rule`. Supports previous line, same line, and enclosing lines.
- Suppress formatting with via ignore comments of the respective formatter, such
  as `// prettier-ignore`.
- Quality-of-life: auto-select a rule if it is the only one in the current line;
  if the line has no diagnostic, search forward to the next line that does.
- Includes built-in support for dozens of linters and formatters. Thus, zero
  plugin configuration is required if you only use common tooling.
- Customizing built-in sources or adding your own sources is easy. PRs to add
  more built-ins are welcome.

## Supported sources
You easily add a custom source via the [plugin configuration](#configuration).
Please consider making a PR to add support for a source if it is missing.

[Rule data for built-in support of linters and formatters](./lua/rulebook/data)

<!-- INFO use `just update-readme` to automatically update this section -->
<!-- auto-generated: start -->
### Rule lookup
- `ansible-lint`
- `basedpyright`
- `biome`
- `clang-tidy`
- `eslint`
- `ltex_plus`
- `LTeX`
- `Lua Diagnostics.`
- `markdownlint`
- `pylint`
- `Pyright`
- `quick-lint-js`
- `Ruff`
- `selene`
- `shellcheck`
- `stylelint`
- `stylelintplus`
- `swiftlint`
- `ts`
- `tsserver`
- `typescript`
- `yamllint`

### Add ignore comment
- [alex](https://github.com/get-alex/alex#control)
- [ansible-lint](https://ansible.readthedocs.io/projects/lint/usage/#muting-warnings-to-avoid-false-positives)
- [ast-grep](https://ast-grep.github.io/guide/project/severity.html#ignore-linting-error)
- [basedpyright](https://microsoft.github.io/pyright/#/comments)
- [biome](https://biomejs.dev/linter/#ignore-code)
- [clang-tidy](https://clang.llvm.org/extra/clang-tidy/#suppressing-undesired-diagnostics)
- [clippy](https://doc.rust-lang.org/reference/attributes/diagnostics.html#r-attributes.diagnostics.expect)
- [codespell](https://github.com/codespell-project/codespell/issues/1212#issuecomment-1721152455)
  (requires setting `--ignore-regex` to `codespell-ignore`)
- [cspell](https://github.com/streetsidesoftware/cspell/blob/main/packages/cspell/README.md#enable--disable-checking-sections-of-code)
- [editorconfig-checker](https://github.com/editorconfig-checker/editorconfig-checker#excluding-lines)
- [EmmyLua](https://github.com/EmmyLuaLs/emmylua-analyzer-rust/blob/main/docs/features/features_EN.md#code-checks)
- [eslint](https://eslint.org/docs/latest/use/configure/rules#using-configuration-comments-1)
- [Harper](https://writewithharper.com/docs/integrations/language-server#Ignore-Comments)
- [LTeX](https://valentjn.github.io/ltex/advanced-usage.html)
- [ltex_plus](https://valentjn.github.io/ltex/advanced-usage.html)
- [Lua Diagnostics.](https://luals.github.io/wiki/annotations/#diagnostic)
- [markdownlint](https://github.com/DavidAnson/markdownlint#configuration)
- [pylint](https://pylint.readthedocs.io/en/latest/user_guide/messages/message_control.html)
- [Pyright](https://microsoft.github.io/pyright/#/comments)
- [Ruff](https://docs.astral.sh/ruff/linter/#error-suppression)
- [rust-analyzer](https://doc.rust-lang.org/reference/attributes/diagnostics.html#r-attributes.diagnostics.expect)
- [selene](https://kampfkarren.github.io/selene/usage/filtering.html#allowingdenying-lints-for-an-entire-file)
- [shellcheck](https://www.shellcheck.net/wiki/Ignore)
- [spellwarn](https://github.com/ravibrock/spellwarn.nvim#usage)
- [stylelint](https://stylelint.io/user-guide/ignore-code/)
- [stylelintplus](https://stylelint.io/user-guide/ignore-code/)
- [swiftlint](https://realm.github.io/SwiftLint/#Disable-rules-in-code)
- [ts](https://www.typescriptlang.org/)
- [tsserver](https://www.typescriptlang.org/)
- [ty](https://github.com/astral-sh/ty/blob/main/docs/README.md#ty-suppression-comments)
- [typescript](https://www.typescriptlang.org/)
- [typos](https://github.com/crate-ci/typos/issues/316#issuecomment-2886204780)
  (requires setting `default.extend-ignore-re` to `typos: ignore-next-line`)
- [vale-ls](https://vale.sh/docs/topics/config/#markup-based-configuration)
- [vale](https://vale.sh/docs/topics/config/#markup-based-configuration)
- [woke](https://docs.getwoke.tech/ignore/#in-line-and-next-line-ignoring)
- [yamllint](https://yamllint.readthedocs.io/en/stable/disable_with_comments.html)
<!-- auto-generated: end -->

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

### Base configuration
The `.setup()` call is optional. You only need to add a config when you want to
add or customize sources.

When adding your own source, you must add the exact, case-sensitive
source name (for example, `clang-tidy`, not `clang`).

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
		-- diagnostic source. `%s` will be replaced with the diagnostic source and 
		-- the code/message.
		fallback = "https://www.google.com/search?q=%s",

		-- the value of the rule documentations accept either a string or a function
		-- * if a string, `%s` will be replaced with rule-id (or the message, if missing)
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
			ignoreRange = { "-- stylua: ignore start", "-- stylua: ignore end" },
		},
	}
})
```

The plugin uses
[vim.ui.select](https://neovim.io/doc/user/lua.html#vim.ui.select()), so the
appearance of the rule selection can be customized by using a UI plugin like
[snacks.nvim](https://github.com/folke/snacks.nvim).

### Customize built-in sources
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

## FAQ

### How to directly ask an LLM about a rule
Use a URL that opens a chat with the LLM as fallback.

For `fallback`, the `%s` placeholder will be replaced with the diagnostic source
and the quoted code (or message, if no code is available), both URL-encoded.

```lua
require("rulebook").setup = ({
	ruleDocs = {
		fallback = "https://chatgpt.com/?q=Explain%20the%20following%20diagnostic%20error%3A%20%s"

		-- To use the fallback instead of the builtin rule docs, overwrite it
		-- with `false`. (For all other sources, `%s` will be replaced with just
		-- the diagnostic code.)
		typescript = false,
	}
})
```

### How to configure diagnostic providers
This plugin requires that the diagnostic providers (the LSP or a linter
integration tool like [nvim-lint](https://github.com/mfussenegger/nvim-lint)
or [efm-langserver](https://github.com/mattn/efm-langserver)) provide the
**source and code for the diagnostic**.
- Make sure that the **source** is named the same in the diagnostic source and in
  the `nvim-rulebook` config, including casing.
- For `nvim-lint`, most linters should already be configured out of the box.
- For `efm-langserver`, you have to set `lintSource` for the source name, and
  correctly configure the
  [errorformat](https://neovim.io/doc/user/quickfix.html#errorformat). Other
  than `%l` & `%c` (line number & column), this requires `%n` which `efm
  langserver` uses to fill in the diagnostic code. You can also use
  [efmls-configs-nvim](https://github.com/creativenull/efmls-configs-nvim) to
  configure those linters for you.

> [!IMPORTANT]
> Note that vim's `errorformat` only matches numbers for `%n`, which means it is
> not possible to parse diagnostic codes that consist of letters. One such case
> is the linter `selene`. To use those linters with `nvim-rulebook` you need to
> use `nvim-lint` which allows more flexible parsing.

```lua
-- example: configuring efm langserver for `markdownlint`
require("nvim-lspconfig").efm.setup({
	filetypes = { "markdown" },
	settings = { 
		languages = {
			markdown = {
				{
					lintSource = "markdownlint",
					lintCommand = "markdownlint $'{INPUT}'",
					lintStdin = false,
					lintIgnoreExitCode = true,
					lintFormats = { 
						"%f:%l:%c MD%n/%m", 
						"%f:%l MD%n/%m"
					},
				},
			},
		},
	},
}
```

### How to display the availability of rule lookup
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

- [Website](https://chris-grieser.de/)
- [Mastodon](https://pkm.social/@pseudometa)
- [ResearchGate](https://www.researchgate.net/profile/Christopher-Grieser)
- [LinkedIn](https://www.linkedin.com/in/christopher-grieser-ba693b17a/)

<a href='https://ko-fi.com/Y8Y86SQ91' target='_blank'><img height='36'
style='border:0px;height:36px;' src='https://cdn.ko-fi.com/cdn/kofi1.png?v=3'
border='0' alt='Buy Me a Coffee at ko-fi.com' /></a>
