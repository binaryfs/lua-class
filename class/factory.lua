--- Internal factory for creating new classes.
-- @module class.factory
-- @author Fabian Staacke
-- @copyright 2020
-- @license https://opensource.org/licenses/MIT

--- Parent keys excluded from inheritance.
-- @local
local ignoredParentKeys = {
  _parentClasses = true,
  _propGetters = true,
  _propSetters = true
}

--- Inherit methods and attributes from a parent class to a child class.
-- @param child The child class
-- @param parent The parent class
-- @raise if parent is not a table
-- @local
local function inherit(child, parent)
  assert(type(parent) == "table", "Parent must be a table")

  child._parentClasses[parent] = true
  child._parentClasses[parent._typename] = true

  for grandparent in pairs(parent._parentClasses) do
    child._parentClasses[grandparent] = true
  end

  for key, value in pairs(parent._propGetters) do
    child._propGetters[key] = child._propGetters[key] or value 
  end

  for key, value in pairs(parent._propSetters) do
    child._propSetters[key] = child._propSetters[key] or value 
  end

  for key, value in pairs(getmetatable(parent)) do
    getmetatable(child)[key] = value
  end
  
  for key, value in pairs(parent) do
    if not ignoredParentKeys[key] then
      -- Do not use rawset here, so that __newindex is still invoked.
      -- This is required to generate property getters and setters.
      child[key] = value
    end
  end
end

--- The default __tostring metamethod for classes.
-- @param self The calling class
-- @local
local function classToString(self)
  local mt = getmetatable(self)
  local rawString = tostring(setmetatable(self, nil))
  setmetatable(self, mt)
  return string.format("<Class %s (%s)>", self._typename, rawString)
end

--- Create a new class.
--
-- @param typename The type name of the new class as a string
-- @param[opt] ... Optional base classes. Defaults to class.SimpleObject.
--
-- @return The created class
-- @raise if no typename was specified
return function(typename, ...)
  if type(typename) ~= "string" or typename == "" then
    error("Please name your class")
  end

  local parents = {...}
  local newClass = setmetatable({
    -- Inherited classes and typenames.
    _parentClasses = {},
    -- Property getters and setters.
    _propGetters = {},
    _propSetters = {}
  }, {
    __tostring = classToString
  })

  -- Inherit parent classes in reverse order (from right to left).
  for i = #parents, 1, -1 do
    inherit(newClass, parents[i])
  end

  rawset(newClass, "__index", rawget(newClass, "__index") or newClass)
  rawset(newClass, "_class", newClass)
  rawset(newClass, "_typename", typename)
  
  -- Define the constructor.
  rawset(newClass, "new", function(...)
    if (...) == newClass then
      error(newClass._typename .. " constructor was called with : operator")
    end
    local instance = setmetatable({}, newClass);
    instance:init(...)
    return instance
  end)
  
  return newClass
end