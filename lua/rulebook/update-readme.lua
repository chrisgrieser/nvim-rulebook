-- INFO has to be run from lua subdirectory when called via `nvim -l`
-- `cd lua && nvim -l rulebook/update-readme.lua`
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

--------------------------------------------------------------------------------

-- remove old lines
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

-- insert new lines
local ruleDocsSources = {}
local ignoreCommentSources = {}

local ruleDocs = require("rulebook.rule-data").ruleDocs
for source, docUrl in pairs(ruleDocs) do
	if source ~= "fallback" then
		local newLine = ("- `%s`"):format(source)
		-- add link to footnote explaining limitation
		if type(docUrl) == "string" and not docUrl:find("%%s") then newLine = newLine .. " \\*" end
		table.insert(ruleDocsSources, newLine)
	end
end
table.sort(ruleDocsSources)

local ignoreComments = require("rulebook.rule-data").ignoreComments
for source, data in pairs(ignoreComments) do
	local newLine = ("- [%s](%s)"):format(source, data.docs)
	table.insert(ignoreCommentSources, newLine)
end
table.sort(ignoreCommentSources)

-- write new file
local newContent = table.concat(beforePart, "\n")
	.. "\n"
	.. "### Rule Lookup\n"
	.. table.concat(ruleDocsSources, "\n")
	.. "\n\n"
	.. "*\\* These sources do not support opening the exact rule site and therefore fall back to an index page which contains the rule. The code is copied to the clipboard for easier selection of the rule at the site.*"
	.. "\n\n"
	.. "### Add Ignore Comment\n"
	.. table.concat(ignoreCommentSources, "\n")
	.. "\n"
	.. table.concat(afterPart, "\n")
writeToFile(readmePath, newContent)
