-- A simple rectangle class that shows how properties work.
--
-- To enable properties for a class, the class has to be derived from class.Object.
-- Properties are generated automatically when a getter or setter method is
-- defined or when such a method is inherited from a base class.
--
-- Examples:
--
-- foo:setValue(123) -- Use the setter
-- foo.value = 123   -- Use the property
-- value = foo:getValue() -- Use the getter
-- value = foo.value      -- use the property

local class = require "class"

local Rectangle = class("Rectangle", class.Object)

function Rectangle:init(left, top, width, height)
  self.left = left or 0
  self.top = top or 0
  self.width = width or 0
  self.height = height or 0
end

-- Generates a property named "right".
function Rectangle:getRight()
  return self.left + self.width
end

function Rectangle:setRight(right)
  self.left = right - self.width
end

-- Generates a property named "bottom".
function Rectangle:getBottom()
  return self.top + self.height
end

function Rectangle:setBottom(bottom)
  self.top = bottom - self.height
end

-- Generates a property named "area" that can only be read because no setter is present.
function Rectangle:getArea()
  return self.width * self.height
end

return Rectangle