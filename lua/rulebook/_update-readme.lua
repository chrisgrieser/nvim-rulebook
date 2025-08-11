-- INFO has to be run from lua subdirectory when called via `nvim -l`
-- `cd lua && nvim -l rulebook/_update-readme.lua`
-- (it is not indented to be used for other purposes)
--------------------------------------------------------------------------------

-- CONFIG
local readmePath = "../README.md" -- relative to lua directory
local markerStart = "<!-- auto-generated: start -->"
local markerEnd = "<!-- auto-generated: end -->"

--------------------------------------------------------------------------------

---@param str string
---@param filePath string line(s) to add
---@return string|nil nil on error
local function writeToFile(filePath, str)
	local file, _ = io.open(filePath, "w")
	if not file then return end
	file:write(str .. "\n")
	file:close()
end

-- default sorting puts all uppercase letters before lowercase ones
---@param list table mutates the list
local function sortAlphabeticallyCaseInsensitive(list)
	table.sort(list, function(a, b) return string.lower(a) < string.lower(b) end)
end

--------------------------------------------------------------------------------

-- REMOVE OLD LINES
local beforePart, afterPart = {}, {}
local removeActive = nil
for line in io.lines(readmePath) do
	if removeActive == nil then table.insert(beforePart, line) end
	if removeActive == false then table.insert(afterPart, line) end
	if line == markerStart then
		removeActive = true
	elseif line == markerEnd then
		table.insert(afterPart, line)
		removeActive = false
	end
end

--------------------------------------------------------------------------------

-- INSERT NEW LINES
local ruleDocsLines = {}

-- RULE LOOKUP
for source, _ in pairs(require("rulebook.data.rule-docs")) do
	if source ~= "fallback" then
		local newLine = ("- `%s`"):format(source)
		table.insert(ruleDocsLines, newLine)
	end
end
sortAlphabeticallyCaseInsensitive(ruleDocsLines)

-- IGNORE COMMENT
local ignoreCommentLines = {}
for source, data in pairs(require("rulebook.data.add-ignore-rule-comment")) do
	local newLine = ("- [%s](%s)"):format(source, data.docs)
	if data.info then newLine = newLine .. ("\n  %s"):format(data.info) end
	table.insert(ignoreCommentLines, newLine)
end
sortAlphabeticallyCaseInsensitive(ignoreCommentLines)

-- FORMATTER SUPPRESSION
-- formatter-data is organized by filetype, for the README, we want to organize
-- the info by tool instead though.
local formatterLines = {}
local toolInfo = {}
for filetype, tool in pairs(require("rulebook.data.suppress-formatter-comment")) do
	if not toolInfo[tool.formatterName] then
		toolInfo[tool.formatterName] = {
			filetypes = {},
			docs = tool.docs,
		}
	end
	table.insert(toolInfo[tool.formatterName].filetypes, filetype)
end
for toolName, tool in pairs(toolInfo) do
	sortAlphabeticallyCaseInsensitive(tool.filetypes)
	local ftStr = vim.iter(tool.filetypes)
		:map(function(ft) return ("`%s`"):format(ft) end)
		:join(", ")

	-- respect max-line-length for markdownlint
	local maxLineLen = 80
	maxLineLen = maxLineLen - 2 -- 2 spaces indent
	if #ftStr > maxLineLen then
		ftStr = vim.trim(ftStr:sub(1, maxLineLen)) .. "\n  " .. ftStr:sub(maxLineLen + 1, -1)
	end

	local newEntry = ("- [%s](%s):\n  %s"):format(toolName, tool.docs, ftStr)
	table.insert(formatterLines, newEntry)
end
sortAlphabeticallyCaseInsensitive(formatterLines)

--------------------------------------------------------------------------------

-- WRITE NEW FILE
local newContent = {
	table.concat(beforePart, "\n"),
	"### Rule lookup",
	table.concat(ruleDocsLines, "\n"),
	"",
	"### Add ignore comment",
	table.concat(ignoreCommentLines, "\n"),
	"",
	"### Suppress formatting",
	table.concat(formatterLines, "\n"),
	table.concat(afterPart, "\n"),
}
writeToFile(readmePath, table.concat(newContent, "\n"))
