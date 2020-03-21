--- The TestSet class represents a collection of test cases.
-- @classmod lovecase.TestSet
-- @author Fabian Staacke
-- @copyright 2020
-- @license https://opensource.org/licenses/MIT

local TestSet = {}
TestSet.__index = TestSet

--- Determine if the given value is an instance of the TestSet class.
-- @param value The value
-- @return True or false
function TestSet.isInstance(value)
  return type(value) == "table" and getmetatable(value) == TestSet
end

--- Add a custom equality function for a given type.
--
-- @param typename The type identifier
-- @param func The equality function. The function expects the two values to be compared
--   as arguments and should return true if the values are considered equal.
function TestSet:addEqualityCheck(typeId, func)
  assert(type(func) == "function", "Function expected")
  self._equalityChecks[typeId] = func
end

--- Add a custom type checking function to determine the type of custom objects.
--
-- @param func The type checking function. The function expects the value whose type is
--   to be determined and should return the type identifier if successful and false otherwise.
function TestSet:addTypeCheck(func)
  assert(type(func) == "function", "Function expected")
  table.insert(self._typeChecks, func)
end

--- Add a named test group.
--
-- @param groupName The group name
-- @param groupFunc A function that contains the grouped test cases. The function expects
--   the TestSet instance as its only argument and doesn't return anything.
function TestSet:group(groupName, groupFunc)
  assert(type(groupName) == "string", "Name your test group")
  assert(type(groupFunc) == "function", "Provide a group function")

  self:_pushGroup(groupName)
  groupFunc(self)
  self:_popGroup()
end

--- Run the specified test.
--
-- @param testName The name of the test
-- @param testFunc A function that provides the test. The function expects the TestCase
--   instance as its only argument and doesn't return anything.
function TestSet:run(testName, testFunc)
  assert(type(testName) == "string", "Name your test")
  assert(type(testFunc) == "function", "Provide a test function")

  local passed, message = pcall(testFunc, self)
  -- Add the test result to the current group.
  table.insert(self:_peekGroup(), {
    name = testName,
    failed = not passed,
    error = message
  })
end

--- Assert that the given value is true.
--
-- @param value The value
-- @param[opt] message Error message if the assertion fails
--
-- @raise if the assertion fails
function TestSet:assertTrue(value, message)
  self:assertEqual(value, true, message)
end

--- Assert that the given value is false.
--
-- @param value The value
-- @param[opt] message Error message if the assertion fails
--
-- @raise if the assertion fails
function TestSet:assertFalse(value, message)
  self:assertEqual(value, false, message)
end

--- Assert that a given value is equal to an expected value.
--
-- @param actual The actual value
-- @param expected The expected value
-- @param[opt] message Error message if the assertion fails
--
-- @raise if the assertion fails
function TestSet:assertEqual(actual, expected, message)
  if not self:_valuesEqual(actual, expected) then
    error(string.format(message or "Value was expected to be %s but was %s", expected, actual), 0)
  end
end

--- Assert that a given value is not equal to another value.
--
-- @param actual The actual value
-- @param unexpected The other value
-- @param[opt] message Error message if the assertion fails
--
-- @raise if the assertion fails
function TestSet:assertNotEqual(actual, unexpected, message)
  if self:_valuesEqual(actual, unexpected) then
    error(string.format(message or "Value was not expected to be %s", unexpected), 0)
  end
end

--- Assert that the given function throws an error when called.
--
-- @param func The function
-- @param[opt] message Error message if the assertion fails
--
-- @raise if the assertion fails
function TestSet:assertError(func, message)
  if pcall(func) then
    error(message or "The function was expected to throw an error")
  end
end

--- Write the test results into the given report.
-- @param report The report (a TestReport instance)
-- @return The report
function TestSet:writeReport(report)
  self:_writeReport(report, self._groupStack[1])
  return report
end

--- Get a string representation of the test set.
-- @treturn string
function TestSet:__tostring()
  local mt = getmetatable(self)
  local rawString = tostring(setmetatable(self, nil))
  setmetatable(self, mt)
  return string.format("<TestSet '%s' (%s)>", self._groupStack[1].name, rawString)
end

--- Internal function to write a report.
-- @param report The report (a TestReport instance)
-- @param group The current test group to write into the report
function TestSet:_writeReport(report, group)
  report:addGroup(group.name, function(report)
    for _, test in ipairs(group) do
      report:addResult(test.name, test.failed, test.error)
    end
    for _, subgroup in ipairs(group.subgroups) do
      self:_writeReport(report, subgroup)
    end
  end)
end

--- Test if two given values are equal.
--
-- The equality operator == is used to compare the values. If both values
-- have the same type and there is an equality function available
-- for this type, the equality function is used instead. 
--
-- @param value1 The first value
-- @param value2 The second value
-- @return true if the values are considered equal, false otherwise.
function TestSet:_valuesEqual(value1, value2)
  local type1 = self:_determineType(value1)
  if type1 == self:_determineType(value2) then
    local equalityCheck = self._equalityChecks[type1]
    if equalityCheck then
      return equalityCheck(value1, value2)
    end
  end
  return value1 == value2
end

--- Determine the type of the given value.
--
-- If none of the registered type checks can determine the type, the type()
-- function of Lua is used as a fallback.
--
-- @param value The value
-- @return The value's type
function TestSet:_determineType(value)
  for _, typeCheck in ipairs(self._typeChecks) do
    local result = typeCheck(value)
    if result then
      return result
    end
  end
  return type(value)
end

--- Push a new group onto the stack.
-- @param groupName The name of the group
function TestSet:_pushGroup(groupName)
  local newGroup = {
    name = groupName,
    subgroups = {}
  }
  
  if #self._groupStack > 0 then
    table.insert(self:_peekGroup().subgroups, newGroup)
  end

  self._groupStack[#self._groupStack + 1] = newGroup
end

--- Remove the topmost group from the stack.
function TestSet:_popGroup()
  assert(table.remove(self._groupStack), "Cannot pop empty stack")
end

--- Get the topmost group from the stack.
-- @return The topmost group
function TestSet:_peekGroup()
  return self._groupStack[#self._groupStack]
end

return TestSet