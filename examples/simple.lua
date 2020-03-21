-- Simple 2D vector class.

local class = require "class"

local Vector2 = class("Vector2")

function Vector.newWithAngle(angle, magnitude)
  local magnitude = magnitude or 1
  return Vector2.new(math.cos(angle) * magnitude, math.sin(angle) * magnitude)
end

function Vector2:init(x, y)
  self.x = x or 0
  self.y = y or 0
  return self
end

function Vector2:add(other)
  self.x = self.x + other.x
  self.y = self.y + other.y
  return self
end

function Vector2:substract(other)
  self.x = self.x - other.x
  self.y = self.y - other.y
  return self
end

function Vector2:multiply(other)
  self.x = self.x * other.x
  self.y = self.y * other.y
  return self
end

function Vector2:scale(scalar)
  self.x = self.x * scalar
  self.y = self.y * scalar
  return self
end

function Vector2:magnitude()
  return math.sqrt(self.x ^ 2 + self.y ^ 2)
end

function Vector2:dot(other)
  return self.x * other.x + self.y * other.y
end

function Vector2:normalize()
  local magnitude = self:magnitude()

  if magnitude > 0 then
    self.x = self.x / magnitude
    self.y = self.y / magnitude
  end

  return self
end

function Vector2:__add(other)
  return Vector2.new(self.x + other.x, self.y + other.y)
end

function Vector2:__sub(other)
  return Vector2.new(self.x - other.x, self.y - other.y)
end

return Vector2