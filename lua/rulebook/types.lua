---@class diagnostic nvim diagnostic https://neovim.io/doc/user/diagnostic.html#diagnostic-structure
---@field message string
---@field source? number -- linter of LSP name
---@field code? string -- rule id
---@field bufnr number

---@class ruleIgnoreConfig
---@field comment string|string[]|function "%s" will be replaced with the rule id
---@field location "prevLine"|"sameLine"|"encloseLine"
---@field docs string used for auto-generated docs
