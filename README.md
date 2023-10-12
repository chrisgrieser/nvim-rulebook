<!-- LTeX: enabled=false -->
# nvim-rulebook 📖 
<!-- LTeX: enabled=true -->
<a href="https://dotfyle.com/plugins/chrisgrieser/nvim-rulebook"><img src="https://dotfyle.com/plugins/chrisgrieser/nvim-rulebook/shield" /></a>

Add inline-comments to ignore rules, or lookup rule documentation online.

Some LSPs provide code actions for that – this plugin adds commands for linters and LSPs that don't.

<!-- toc -->

- [Features](#features)
- [Supported Sources](#supported-sources)
	* [Rule Lookup](#rule-lookup)
	* [Add Ignore Comment](#add-ignore-comment)
- [Installation](#installation)
- [Configuration](#configuration)
- [Customize Built-in Sources](#customize-built-in-sources)
- [Limitations](#limitations)
- [Credits](#credits)

<!-- tocstop -->

## Features
- Look up official rule documentation, falling back to a web search if the source does not have rule documentation.
- Add inline-comments to ignore rules like `// eslint disable-next-line some-rule`. Supports previous line, same line, and enclosing lines.
- QoL: auto-select a rule if it is the only one in the current line; if the line has no diagnostic, search forward up to the next line that does.
- Includes built-in support for various linters. Zero plugin configuration required if you only need to use built-in sources.
- Customizing built-in sources or adding your own sources is easy. PRs to add more built-ins are welcome.

## Supported Sources
You easily add a custom source via the [plugin configuration](#configuration). Though, please consider making a PR to add support for a source if it is missing.

[Rule Data for the supported linters](./lua/rulebook/data)

<!-- INFO use `make update_readme` to automatically update this section -->
<!-- auto-generated: start -->
### Rule Lookup
- `LTeX`
- `Lua Diagnostics.`
- `biome`
- `eslint`
- `markdownlint` \*
- `pylint`
- `ruff` \*
- `selene`
- `shellcheck`
- `stylelint`
- `yamllint`

*\* These sources do not support opening the exact rule site and therefore fall back to an index page which contains the rule. The code is copied to the clipboard for easier selection of the rule at the site.*

### Add Ignore Comment
- [LTeX](https://valentjn.github.io/ltex/advanced-usage.html)
- [Pyright](https://microsoft.github.io/pyright/#/comments)
- [biome](https://biomejs.dev/linter/#ignoring-code)
- [codespell](https://github.com/codespell-project/codespell/issues/1212#issuecomment-1721152455)
- [editorconfig-checker](https://github.com/editorconfig-checker/editorconfig-checker#excluding-lines)
- [eslint](https://eslint.org/docs/latest/use/configure/rules#using-configuration-comments-1)
- [pylint](https://pylint.readthedocs.io/en/latest/user_guide/messages/message_control.html)
- [selene](https://kampfkarren.github.io/selene/usage/filtering.html#allowingdenying-lints-for-an-entire-file)
- [shellcheck](https://www.shellcheck.net/wiki/Ignore)
- [stylelint](https://stylelint.io/user-guide/ignore-code/)
- [typescript](https://www.typescriptlang.org/)
- [vale](https://vale.sh/docs/topics/config/#markup-based-configuration)
- [yamllint](https://yamllint.readthedocs.io/en/stable/disable_with_comments.html)
<!-- auto-generated: end -->

## Installation
This plugin requires diagnostics provided by a source that supports neovim's built-in diagnostics system. (nvim's built-in LSP client or [nvim-lint](https://github.com/mfussenegger/nvim-lint) are such sources.)

```lua
-- lazy.nvim
{
	"chrisgrieser/nvim-rulebook",
	keys = {
		{ "<leader>i", function() require("rulebook").ignoreRule() end },
		{ "<leader>l", function() require("rulebook").lookupRule() end },
	}
},
```

```lua
-- packer
use { "chrisgrieser/nvim-rulebook" }

-- in your config
vim.keymap.set("n", "<leader>i", function() require("rulebook").ignoreRule() end)
vim.keymap.set("n", "<leader>l", function() require("rulebook").lookupRule() end)
```

## Configuration
The configuration is optional, the plugin works fine out of the box. You only need to add a config when you want to customize a source or add custom sources.

```lua
require("rulebook").setup = ({
	ignoreComments = {
		selene = {
			comment = "-- selene: allow(%s)",
			location = "prevLine",
		},
		-- ... (full list of supported sources can be found in the README)

		yourCustomSource = {
			-- %s will be replaced with rule-id
			comment = "// disabling-comment %s",

			-- "prevLine"|"sameLine"|"encloseLine"
			location = "prevLine",
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
		-- diagnostic source. "%s" will be replaced with the diagnostic source & code.
		-- Default is the DDG "Ducky Search" (automatically opening first result).
		fallback = "https://duckduckgo.com/?q=%s+%%21ducky&kl=en-us",

		-- the value of the rule documentations accept either a string or a function
		-- if a string, %s will be replaced with rule-id
		-- if a function, takes a diagnostic object as argument must return a url
		yourCustomSource = "https://my-docs/%s.hthml",
		anotherCustomSource = function(diag)
			-- ...
			return url
		end,
	}

	-- If no diagnostic is found, in current line, search this meany lines 
	-- forward for diagnostics before aborting.
	forwSearchLines = 10,
})
```

The plugin uses [vim.ui.select](https://neovim.io/doc/user/lua.html#vim.ui.select()), so the appearance of the rule selection can be customized by using a UI-plugin like [dressing.nvim](https://github.com/stevearc/dressing.nvim).

## Customize Built-in Sources
Built-in sources be customized by overwriting them in the configuration:

```lua
-- use `disable-line` instead of the default `disable-next-line` for eslint
defaultConfig = {
	ignoreComments = {
		eslint = {
			comment = "// eslint-disable-line %s",
			location = "sameLine",
		} 
	}
}
```

## Limitations
- The diagnostics have to contain the necessary data, [that is a diagnostic code and diagnostic source](https://neovim.io/doc/user/diagnostic.html#diagnostic-structure). Most LSPs and most linters configured for `nvim-lint` do that, but some diagnostic sources do not (for example `efm-langserver` with incorrectly defined `errorformat`). Please open an issue at the diagnostics provider to fix.
- This plugin does *not* hook into `vim.lsp.buf.code_action`, but provides its own selector.

## Credits
<!-- vale Google.FirstPerson = NO -->
__About Me__  
In my day job, I am a sociologist studying the social mechanisms underlying the digital economy. For my PhD project, I investigate the governance of the app economy and how software ecosystems manage the tension between innovation and compatibility. If you are interested in this subject, feel free to get in touch.

__Blog__  
I also occasionally blog about vim: [Nano Tips for Vim](https://nanotipsforvim.prose.sh)

__Profiles__  
- [reddit](https://www.reddit.com/user/pseudometapseudo)
- [Discord](https://discordapp.com/users/462774483044794368/)
- [Academic Website](https://chris-grieser.de/)
- [Twitter](https://twitter.com/pseudo_meta)
- [Mastodon](https://pkm.social/@pseudometa)
- [ResearchGate](https://www.researchgate.net/profile/Christopher-Grieser)
- [LinkedIn](https://www.linkedin.com/in/christopher-grieser-ba693b17a/)

__Buy Me a Coffee__
<br>
<a href='https://ko-fi.com/Y8Y86SQ91' target='_blank'><img height='36' style='border:0px;height:36px;' src='https://cdn.ko-fi.com/cdn/kofi1.png?v=3' border='0' alt='Buy Me a Coffee at ko-fi.com' /></a>
