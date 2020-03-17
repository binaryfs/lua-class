--- Base class that implements C#-like properties.
-- Properties are generated from (camel-cased) getter and setter methods automatically.
--
-- @classmod class.Object
-- @author Fabian Staacke
-- @copyright 2020
-- @license https://opensource.org/licenses/MIT

local BASE = (...):gsub("%.Object$", "")
local factory = require(BASE .. ".factory")
local BaseObject = require(BASE .. ".BaseObject")

local Object = factory("Object", BaseObject)

--- Custom __newindex class metamethod that automatically creates properties from
-- get* and set* methods that get added to a class.
--
-- If a method "getMyValue" is declared, this metamethod creates a property named
-- "myValue" from it with a corresponding getter function.
getmetatable(Object).__newindex = function(self, index, value)
  if type(index) == "string" then
    local prefix = index:sub(1, 4)
    if prefix:match("get%u") or prefix:match("set%u") then
      local property = string.gsub(index:sub(4), "^%u", string.lower)
      if index:sub(1, 3) == "get" then
        self._propGetters[property] = index
        self._propSetters[property] = self._propSetters[property] or false
      else
        self._propSetters[property] = index
        self._propGetters[property] = self._propGetters[property] or false
      end
    end
  end
  rawset(self, index, value)
end

--- This method is called when an attribute is accessed that does not exist in the
-- object or its class.
--
-- @param key The attribute key
-- @return The value that should be returned instead
Object._getMissingAttribute = rawget

--- This method is called if a value is assigned to an attribute that exists neither
-- in the object nor in its class.
--
-- @param key The attribute key
-- @param value The value to set
Object._setMissingAttribute = rawset

--- Custom __index metamethod that implements property getters.
-- @param index The index that is looked for
function Object:__index(index)
  local mt = getmetatable(self)

  -- First try to find the index in the class.
  local value = mt[index]
  if value ~= nil then
    return value
  end

  -- Next try to find a property getter with that name.
  local getter = mt._propGetters[index]
  if getter then
    return mt[getter](self)
  elseif getter == false then
    error("Property " .. index .. " is write-only")
  end

  return self:_getMissingAttribute(index)
end

--- Custom __newindex metamethod that implements property setters.
-- @param index The index that is looked for
-- @param value The value to set
function Object:__newindex(index, value)
  local mt = getmetatable(self)

  -- Try to find a property setter with that name.
  local setter = mt._propSetters[index]
  if setter then
    mt[setter](self, value)
    return
  elseif setter == false then
    error("Property " .. index .. " is read-only")
  end

  self:_setMissingAttribute(index, value)
end

return Object