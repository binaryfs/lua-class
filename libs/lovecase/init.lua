--- Lightweight unit testing module that integrates well into the LÖVE framework.
-- @module lovecase
-- @author Fabian Staacke
-- @copyright 2020
-- @license https://opensource.org/licenses/MIT

local BASE = (...):gsub("%.init$", "")
local TestSet = require(BASE .. ".TestSet")
local TestReport = require(BASE .. ".TestReport")

local lovecase = {
  _NAME = "lovecase",
  _DESCRIPTION = "Lightweight unit testing module that integrates well into the LÖVE framework",
  _VERSION = "1.0.0",
  _URL = "https://github.com/binaryfs/lua-lovecase",
  _LICENSE = "MIT License",
  _COPYRIGHT = "Copyright (c) 2020 Fabian Staacke",

  --- The pattern that is used to detect test files if no custom pattern is specified.
  defaultTestFilePattern = "%-test%.lua$"
}

--- Create a new test set.
-- @param name The name of the test set
-- @return The new test set
-- @raise The name is required
function lovecase.newTestSet(name)
  assert(type(name) == "string", "Please name your TestSet")

  local instance = setmetatable({
    _groupStack = {},
    _typeChecks = {},
    _equalityChecks = {}
  }, TestSet)

  instance:_pushGroup(name)
  return instance
end

--- Create a new test report.
-- @return The new report
function lovecase.newTestReport()
  return setmetatable({
    _lines = {},
    _depth = 0,
    _failed = 0,
    _passed = 0
  }, TestReport)
end

--- Run the specified unit test file.
--
-- @param filepath The path to the unit test file
-- @param[opt] report The report that should receive the test results. If none is given,
--   a new report ist created internally.
--
-- @return A report with the test results
--
-- @raise report is not an instance of TestReport
-- @raise filepath could not be loaded
-- @raise test file did not return a TestSet instance
function lovecase.runTestFile(filepath, report)
  if report and not TestReport.isInstance(report) then
    error("TestReport object expected, got: " .. type(report))
  end

  local chunk, err = love.filesystem.load(filepath)
  if err then
    error(err)
  end

  local test = chunk()
  if not TestSet.isInstance(test) then
    error("Loaded file did not return a TestSet: " .. filepath)
  end

  return test:writeReport(report or lovecase.newTestReport())
end

--- Run all unit test files from the specified directory.
--
-- @param path The directory path
-- @param[opt=false] Search for test files recursively
-- @param[opt] The pattern for detecting test files. Set to false to use the default pattern.
--   The default pattern searches for files that end with "-test.lua".
-- @param[opt] report The report that should receive the test results. If none is given,
--   a new report ist created internally.
--
-- @return A report with the test results
function lovecase.runAllTestFiles(path, recursive, pattern, report)
  pattern = pattern or lovecase.defaultTestFilePattern
  report = report or lovecase.newTestReport()
  local items = love.filesystem.getDirectoryItems(path)

  for _, item in ipairs(items) do
    local itemPath = path:gsub("[/\\]$", "") .. "/" .. item
    local info = love.filesystem.getInfo(itemPath)

    if info.type == "file" and string.match(item, pattern) then
      lovecase.runTestFile(itemPath, report)
    elseif recursive and info.type == "directory" then
      lovecase.runAllTestFiles(itemPath, true, pattern, report)
    end
  end

  return report
end

return lovecase