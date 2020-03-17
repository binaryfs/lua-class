--- Lua classes with multiple inheritance and properties.
-- @module class
-- @author Fabian Staacke
-- @copyright 2020
-- @license https://opensource.org/licenses/MIT

local BASE = (...):gsub("%.init$", "")
local factory = require(BASE .. ".factory")

local class = {
  _NAME = "class",
  _DESCRIPTION = "Lua classes with multiple inheritance and properties",
  _VERSION = "0.6.0",
  _URL = "https://github.com/binaryfs/lua-class",
  _LICENSE = "MIT License",
  _COPYRIGHT = "Copyright (c) 2020 Fabian Staacke",

  BaseObject = require(BASE .. ".BaseObject"),
  Object = require(BASE .. ".Object")
}

--- Create a new class.
--
-- @param typename The type name of the new class as a string
-- @param[opt] ... Optional base classes that are inherited one after another
--   from right to left. The specified classes override existing methods and
--   attributes with their own ones. Thus, the classes at the beginning of the
--   arguments list have more weight than those that come after. Defaults to
--   class.SimpleObject if no base class is specified explicitly.
--
-- @return The created class
-- @raise if no typename was specified
--
-- @usage
-- local MyClass = class("MyClass", MyBaseClass)
function class.new(name, ...)
  if (...) then
    return factory(name, ...)
  end
  return factory(name, class.BaseObject)
end

--- Get the type of the specified value.
--
-- If the value is a class or instance, its typename is returned. Otherwise the
-- value's data type determined by the type() function is returned.
--
-- @param value The value
-- @return The type as a string
function class.typeOf(value)
  if class.isInstance(value) then
    return getmetatable(value)._typename
  end
  if class.isClass(value) then
    return value._typename
  end
  return type(value)
end

--- Determine if the given value is an instance of a class.
--
-- @param value The value
-- @return True if the value is an instance, false otherwise
--
-- @usage
-- class.isInstance(Bird.new()) --> true
-- class.isInstance(Bird) --> false
function class.isInstance(value)
  return type(value) == "table" and class.isClass(getmetatable(value))
end

--- Determine if the given value is a class.
--
-- @param value The value
-- @return True if the value is a class, false otherwise
--
-- @usage
-- class.isClass(class("MyClass")) --> true
-- class.isClass(123) --> false
function class.isClass(value)
  return type(value) == "table" and rawget(value, "_class") ~= nil
end

--- Determine if the given class or instance is derived from a certain type.
--
-- @param value The class or instance to check
-- @param datatype The type (might be a typename or a class)
--
-- @return True if the value is derived from the given type, false otherwise.
--
-- @usage
-- class.inherits("Hello World", SomeClass) --> false
function class.inherits(value, datatype)
  return type(value) == "table" and (value._typename == datatype or
    value._class == datatype or value._parentClasses[datatype] ~= nil)
end

return setmetatable(class, {
  __call = function(self, name, ...)
    return self.new(name, ...)
  end
})