--- BaseObject is the parent class of all other classes.
-- @classmod class.BaseObject
-- @author Fabian Staacke
-- @copyright 2020
-- @license https://opensource.org/licenses/MIT

local BASE = (...):gsub("%.BaseObject$", "")
local factory = require(BASE .. ".factory")

local BaseObject = factory("BaseObject")

--- Initialize the object.
--
-- This method is called by the constructor automatically. It should
-- be overridden by derived child classes in order to initialize
-- instances with custom attributes.
--
-- @param[opt] ... The arguments that were passed to the constructor
function BaseObject:init(...)
end

--- Get the object's class.
-- @return The class table
function BaseObject:getClass()
  return getmetatable(self)
end

--- Call the original __tostring metamethod of the object.
-- @return A string representation of the object
function BaseObject:rawToString()
  local mt = getmetatable(self)
  local rawString = tostring(setmetatable(self, nil))
  setmetatable(self, mt)
  return rawString
end

--- Convert the object into a string.
-- @return A string representation of the object
function BaseObject:__tostring()
  return string.format("<Instance of %s (%s)>", self._typename, self:rawToString())
end

return BaseObject