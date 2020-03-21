local class = require "class"

--
-- Abstract NotExtensible class
--
-- Inherit from this class to make objects non-extensible. Adding new attributes
-- to these objects is not possible then.
--

local NotExtensible = class("NotExtensible")

function NotExtensible.new()
  error("NotExtensible is an abstract class")
end

function NotExtensible:preventExtensions()
  rawset(self, "_extensionsDisabled", true)
end

function NotExtensible:__newindex(index, value)
  if self._extensionsDisabled then
    error("Index " .. tostring(index) .. " not added: " .. tostring(self) .. " is not extensible!")
  end
  rawset(self, index, value)
end

--
-- Vector2 class
--

local Vector2 = class("Vector2", NotExtensible)

function Vector2:init(x, y)
  self.x = x or 0
  self.y = y or 0

  -- From here on it's not possible to add new attributes to the vector.
  self:preventExtensions()
  
  -- self.z = 0 -- Error!
end

return Vector2