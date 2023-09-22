-- INFO has to be run from lua subdirectory when called via `nvim -l`
-- `cd lua && nvim -l rulebook/update-readme.lua`

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

---read the full file
---@param filePath string
---@nodiscard
---@return string|nil nil on error
local function readFile(filePath)
	local file, _ = io.open(filePath, "r")
	if not file then return end
	local content = file:read("*a")
	file:close()
	return content
end

--------------------------------------------------------------------------------

local readmeContent = assert(readFile(readmePath), "README.md not found")

-- remove old lines
local beforePart, afterPart = {}, {}
local removeActive = nil
for line in readmeContent:gmatch("(.-)[\r\n]") do
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
local linesToInsert = {}

table.insert(linesToInsert, "### Rule Lookup")
local ruleDocs = require("rulebook.rule-data").ruleDocs
for source, _ in pairs(ruleDocs) do
	if source ~= "fallback" then
		local newLine = ("- `%s`"):format(source)
		table.insert(linesToInsert, newLine)
	end
end

table.insert(linesToInsert, "")
table.insert(linesToInsert, "### Add Ignore Comments")
local ignoreComments = require("rulebook.rule-data").ignoreComments
for source, data in pairs(ignoreComments) do
	local newLine = ("- [%s](%s)"):format(source, data.docs)
	table.insert(linesToInsert, newLine)
end

-- write new file
local newContent = table.concat(beforePart, "\n")
	.. "\n"
	.. table.concat(linesToInsert, "\n")
	.. "\n"
	.. table.concat(afterPart, "\n")
writeToFile(readmePath, newContent)
