--- The TestReport class encapsulates the result of a test set.
-- @classmod lovecase.TestReport
-- @author Fabian Staacke
-- @copyright 2020
-- @license https://opensource.org/licenses/MIT

local TestReport = {}
TestReport.__index = TestReport

TestReport.indentSpaces = 4
TestReport.failedPrefix = "FAILED: "
TestReport.passedPrefix = "PASSED: "
TestReport.resultLine = "\n\n%s of %s tests passing"

--- Determine if the given value is an instance of the TestReport class.
-- @param value The value
-- @return True or false
function TestReport.isInstance(value)
  return type(value) == "table" and getmetatable(value) == TestReport
end

--- Add a group to the report.
-- @param groupName The group name
-- @param groupFunc A function that provides the group closure
function TestReport:addGroup(groupName, groupFunc)
  self:_writeLine(groupName)
  self._depth = self._depth + 1
  groupFunc(self)
  self._depth = self._depth - 1
end

--- Add a test result to the report.
-- @param testName The name of the test
-- @param failed True for a failed test, false otherwise
-- @param[opt] reason The error message if the test failed
function TestReport:addResult(testName, failed, reason)
  if failed then
    self:_writeLine(TestReport.failedPrefix .. testName)
    self:_writeLine(reason, self._depth + 1)
    self._failed = self._failed + 1
  else
    self:_writeLine(TestReport.passedPrefix .. testName)
    self._passed = self._passed + 1
  end
end

--- Get the test results formatted as string.
-- @return Test results as string
function TestReport:printResults()
  local report = table.concat(self._lines, "\n")
  local result = string.format(
    TestReport.resultLine,
    self._passed,
    self._passed + self._failed
  )
  return report .. result
end

--- Get an iterator over the lines of the report.
-- @return ipairs iterator
-- @usage
-- for i, line in report:lines() do
--   print(i .. ". " .. line)
-- end
function TestReport:lines(callback)
  return ipairs(self._lines)
end

--- Get a (technical) string representation of the report.
-- @treturn string
function TestReport:__tostring()
  local mt = getmetatable(self)
  local rawString = tostring(setmetatable(self, nil))
  setmetatable(self, mt)
  return string.format("<TestReport (%s)>", rawString)
end

--- Write a test line into the report.
-- @param message The message to write
-- @param[opt] depth The indentation depth (overrides default) 
function TestReport:_writeLine(message, depth)
  local indent = string.rep(" ", TestReport.indentSpaces * (depth or self._depth))
  self._lines[#self._lines + 1] = indent .. message
end

return TestReport