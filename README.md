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
- [Supported Sources](#supported-sources)
	* [Rule Lookup](#rule-lookup)
	* [Add Ignore Comment](#add-ignore-comment)
- [Installation](#installation)
- [Configuration](#configuration)
- [Customize Built-in Sources](#customize-built-in-sources)
- [Limitations](#limitations)
- [API](#api)
	* [Availability of Rule Lookup](#availability-of-rule-lookup)
- [Credits](#credits)

<!-- tocstop -->

## Features
- Look up official rule documentation, falling back to a web search if the
  source does not have rule documentation.
- Add inline-comments to ignore rules like `// eslint disable-next-line
  some-rule`. Supports previous line, same line, and enclosing lines.
- QoL: auto-select a rule if it is the only one in the current line; if the line
  has no diagnostic, search forward up to the next line that does.
- Includes built-in support for various linters. Zero plugin configuration
  required if you only need to use built-in sources.
- Customizing built-in sources or adding your own sources is easy. PRs to add
  more built-ins are welcome.

## Supported Sources
You easily add a custom source via the [plugin configuration](#configuration).
Though, please consider making a PR to add support for a source if it is
missing.

[Rule Data for the supported linters](./lua/rulebook/data)

<!-- INFO use `make update_readme` to automatically update this section -->
<!-- auto-generated: start -->
### Rule Lookup
- `LTeX`
- `Lua Diagnostics.`
- `Pyright`
- `Ruff`
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

### Add Ignore Comment
- [LTeX](https://valentjn.github.io/ltex/advanced-usage.html)
- [Lua Diagnostics.](https://luals.github.io/wiki/annotations/#diagnostic)
- [Pyright](https://microsoft.github.io/pyright/#/comments)
- [Ruff](https://docs.astral.sh/ruff/linter/#error-suppression)
- [alex](https://github.com/get-alex/alex#control)
- [biome](https://biomejs.dev/linter/#ignoring-code)
- [clang-tidy](https://clang.llvm.org/extra/clang-tidy/#suppressing-undesired-diagnostics)
- [codespell](https://github.com/codespell-project/codespell/issues/1212#issuecomment-1721152455)
- [editorconfig-checker](https://github.com/editorconfig-checker/editorconfig-checker#excluding-lines)
- [eslint](https://eslint.org/docs/latest/use/configure/rules#using-configuration-comments-1)
- [pylint](https://pylint.readthedocs.io/en/latest/user_guide/messages/message_control.html)
- [selene](https://kampfkarren.github.io/selene/usage/filtering.html#allowingdenying-lints-for-an-entire-file)
- [shellcheck](https://www.shellcheck.net/wiki/Ignore)
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

## Installation
This plugin requires diagnostics provided by a source that supports Neovim's
built-in diagnostics system. (nvim's built-in LSP client or
[nvim-lint](https://github.com/mfussenegger/nvim-lint) are such sources.)

```lua
-- lazy.nvim
{
	"chrisgrieser/nvim-rulebook",
	keys = {
		{ "<leader>ri", function() require("rulebook").ignoreRule() end },
		{ "<leader>rl", function() require("rulebook").lookupRule() end },
		{ "<leader>ry", function() require("rulebook").yankDiagnosticCode() end },
	}
},
```

```lua
-- packer
use { "chrisgrieser/nvim-rulebook" }

-- in your config
vim.keymap.set("n", "<leader>ri", function() require("rulebook").ignoreRule() end)
vim.keymap.set("n", "<leader>rl", function() require("rulebook").lookupRule() end)
vim.keymap.set("n", "<leader>ry", function() require("rulebook").yankDiagnosticCode() end)
```

## Configuration
The configuration is optional. You only need to add a config when you want to
customize a source or add custom sources.

When adding your own source, you must add the *exact*, case-sensitive
source-name. (for example, `clang-tidy`, not `clang`).

```lua
require("rulebook").setup = ({
	ignoreComments = {
		selene = {
			comment = "-- selene: allow(%s)",
			location = "prevLine",
		},
		-- ... (full list of supported sources can be found in the README)

		yourCustomSource = { -- exact, case-sensitive source-name
			comment = "// disabling-comment %s", -- %s will be replaced with rule-id
			location = "prevLine", -- "prevLine"|"sameLine"|"encloseLine"
		}

		-- if location is "encloseLine", needs to be a list of two strings
		anotherCustomSource = {
			comment = { "// disable-rule %s", "// enable-rule %s" },
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
		-- if a string, `%s` will be replaced with rule-id
		-- if a function, takes a `:h diagnostic-structure` as argument and must 
		-- return a url
		yourCustomSource = "https://my-docs/%s.hthml",
		anotherCustomSource = function(diag)
			-- ...
			return url
		end,
	}

	-- if no diagnostic is found in current line, search this many lines forward
	forwSearchLines = 10,

	-- whether to yank to `+` or `"`
	yankDiagnosticCodeToSystemClipboard = true,
})
```

The plugin uses
[vim.ui.select](https://neovim.io/doc/user/lua.html#vim.ui.select()), so the
appearance of the rule selection can be customized by using a UI-plugin like
[dressing.nvim](https://github.com/stevearc/dressing.nvim).

## Customize Built-in Sources
Built-in sources be customized by overwriting them in the configuration:

```lua
-- use `disable-line` instead of the default `disable-next-line` for eslint
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
  LSPs, and most linters configured for `nvim-lint` do that, but some diagnostic
  sources do not (for example `efm-langserver` with incorrectly defined
  `errorformat`). Please open an issue at the diagnostics provider to fix such
  issues.
- This plugin does not hook into `vim.lsp.buf.code_action`, but provides its own
  selector.

## API

### Availability of Rule Lookup
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
<!-- vale Google.FirstPerson = NO -->
**About Me**  
In my day job, I am a sociologist studying the social mechanisms underlying the
digital economy. For my PhD project, I investigate the governance of the app
economy and how software ecosystems manage the tension between innovation and
compatibility. If you are interested in this subject, feel free to get in touch.

**Blog**  
I also occasionally blog about vim: [Nano Tips for Vim](https://nanotipsforvim.prose.sh)

**Profiles**  
- [reddit](https://www.reddit.com/user/pseudometapseudo)
- [Discord](https://discordapp.com/users/462774483044794368/)
- [Academic Website](https://chris-grieser.de/)
- [Twitter](https://twitter.com/pseudo_meta)
- [Mastodon](https://pkm.social/@pseudometa)
- [ResearchGate](https://www.researchgate.net/profile/Christopher-Grieser)
- [LinkedIn](https://www.linkedin.com/in/christopher-grieser-ba693b17a/)

<a href='https://ko-fi.com/Y8Y86SQ91' target='_blank'><img
	height='36'
	style='border:0px;height:36px;'
	src='https://cdn.ko-fi.com/cdn/kofi1.png?v=3'
	border='0'
	alt='Buy Me a Coffee at ko-fi.com'
/></a>
