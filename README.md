<!-- LTeX: enabled=false -->
# nvim-rulebook <!-- LTeX: enabled=true -->
<!-- TODO uncomment shields when available in dotfyle.com -->
<!-- <a href="https://dotfyle.com/plugins/chrisgrieser/nvim-rulebook"><img src="https://dotfyle.com/plugins/chrisgrieser/nvim-rulebook/shield" /></a> -->

Add inline-comments to rules. Lookup rule documentation online.

Some LSPs provide code actions for to do that – this plugin adds commands for linters and LSPs that don't. 

<!--toc:start-->
- [Features](#features)
- [Supported Sources](#supported-sources)
	- [For adding ignore comments](#for-adding-ignore-comments)
	- [For looking up rule documentation](#for-looking-up-rule-documentation)
- [Installation](#installation)
- [Configuration](#configuration)
- [Limitations](#limitations)
- [Credits](#credits)
<!--toc:end-->

## Features
- Add inline-comments that ignore diagnostic rules.
- Location of the ignore comment, like next line or previous line, is configurable.
- Perform a web search for a diagnostic rule.
- Requires diagnostics provided by a source that supports neovim's builtin diagnostics system (`vim.diagnostic`). nvim's builtin LSP client and [nvim-lint](https://github.com/mfussenegger/nvim-lint) are such sources.

## Supported Sources
You easily add a custom source via the [plugin configuration](#configuration). However, please consider making a PR to add support for a linter if it is missing.

[Ignore Rule Data for the supported linters](./lua/rulebook/ignoreRuleData.lua)

### For adding ignore comments
<!-- TODO: auto-generate this list -->
- selene
- shellcheck
- vale
- yamllint
- stylelint
- LTeX
- typescript
- pylint

### For looking up rule documentation
- selene
- shellcheck
- pylint

## Installation

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

```lua
defaultConfig = {
	ignoreRuleComments = {
		selene = {
			comment = "-- selene: allow(%s)",
			location = "prevLine",
		},
		-- ... (full list of supported sources can be found in the README)

		yourCustomSource = {
			-- %s will be replaced with rule-id
			-- if location is "encloseLine", needs to be a list of two strings
			comment = "// disabling-comment %s",

			-- "prevLine"|"sameLine"|"encloseLine"
			location = "prevLine",
		}
	},

	-- %s will be replaced with rule-id
	ruleDocumentations = {
		selene = "https://kampfkarren.github.io/selene/lints/%s.html"
		-- ... (full list of supported sources can be found in the README)

		yourCustomSource = "https://my-docs/%s.hthml"

		-- Search URL when no documentation definition is available for a
		-- diagnostic source. "%s" will be replaced with the diagnostic source & code.
		-- Default is the DDG "Ducky Search" (automatically opening first result).
		fallback = "https://duckduckgo.com/?q=%s+%21ducky&kl=en-us",
	}
}
```

> [!NOTE]
> The plugin uses `vim.ui.select()`, so the appearance of the rule selection can be customized by using a ui-plugin like [dressing.nvim](https://github.com/stevearc/dressing.nvim).

## Limitations
- The diagnostics have to contain the necessary data, [that is a diagnostic code and diagnostic source](https://neovim.io/doc/user/diagnostic.html#diagnostic-structure). Most LSPs and most linters configured for `nvim-lint` do that, but some diagnostic sources do not (for example `efm-langserver` with incorrectly defined errorformat). Please open an issue at the diagnostics provider to fix.
- This plugin does *not* hook into `vim.lsp.buf.code_action`, but provides its own independent selector.
- As opposed to [null-ls](https://github.com/jose-elias-alvarez/null-ls.nvim)'s code action feature, this plugin does not support arbitrary code actions, but only actions based on a diagnostic.

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
