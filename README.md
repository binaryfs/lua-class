# lua-class
Streightforward classes in Lua with multiple inheritance and C#-like properties.

## Installation

**Requirements**

* Lua 5.1+ or LuaJIT 2.0.x
* For unit tests only: [lovecase](https://github.com/binaryfs/lua-lovecase) (already included in lua-class)

**Integration**

Copy the folder "class" to a location from where it can be included into your Lua code (via `require`). If you would like to run the unit tests as well, you also have to include "libs/lovecase" into your project.

## Quick Guide

### Defining a simple class

```lua
local class = require "class"
local Circle = class("Circle")

function Circle:init(x, y, radius)
  self._x = assert(x, "x required")
  self._y = assert(y, "y required")
  self._radius = assert(radius, "radius required")
end

function Circle:getPosition()
  return self._x, self._y
end

function Circle:getRadius()
  return self._radius
end

function Circle:getArea()
  return math.pi * self._radius ^ 2
end

function Circle:containsPoint(px, py)
  return (self._x - px) ^ 2 + (self._y - py) ^ 2 <= self._radius ^ 2
end

```

### Instantiating the class

```lua
local circle = Circle.new(5, 5, 20)
circle:containsPoint(15, 0) --> true
circle:getArea() --> 1256.637...
```

### Using single inheritance

```lua
--
-- Abstract Shape class
--

local Shape = class("Shape")

-- Override the Shape constructor.
function Shape.new()
  error("Shape is abstract")
end

function Shape:init(x, y)
  self._x = assert(x, "x required")
  self._y = assert(y, "y required")
end

function Shape:getPosition()
  return self._x, self._y
end

-- Abstract method.
function Shape:getArea()
  error("Shape:getArea is not implemented")
end

--
-- Derived Circle class
--

local Circle = class("Circle", Shape)

function Circle:init(x, y, radius)
  Shape.init(self, x, y) -- Call the Shape initializer.
  self._radius = assert(radius, "radius required")
end

function Circle:getArea()
  return math.pi * self._radius ^ 2
end

--[[Extraneous code omitted]]
```

### Using multiple inheritance

```lua
--
-- Abstract Colored class
--

local Colored = class("Colored")

-- Define a class attribute for valid colors.
Colored.colors = {
  red = "red",
  green = "green",
  blue = "blue"
}

function Colored:init(color)
  -- Note: Instead of "Colored.colors" you can also use "self.colors" here,
  -- because instances can access class attributes directly.
  self._color = assert(Colored.colors[color], "Invalid color: " .. tostring(color))
end

function Colored:getColor()
  return self._color
end

--
-- Derived Circle class
--

local Circle = class("Circle", Shape, Colored)

function Circle:init(x, y, radius, color)
  Shape.init(self, x, y)
  Colored.init(self, color or "red")
  self._radius = assert(radius, "radius required")
end

--[[Extraneous code omitted]]
```

### Using properties


```lua
-- In order to use properties we have to derive from class.Object explicitly.
local Shape = class("Shape", class.Object)

function Shape:setPosition(x, y)
  self._x = y and x or x.x
  self._y = y or x.y
end

--[[Extraneous code omitted]]

local Circle = class("Circle", Shape, Colored)

--[[Extraneous code omitted]]

local circle = Circle.new(5, 5, 20, "blue")

circle:setPosition(10, 10) -- Use the setter
circle.position = {15, 15} -- Use the property

radius = circle:getRadius() -- Use the getter
radius = circle.radius -- Use the property

circle:getColor() --> "blue"
circle.color --> "blue"

area = circle.area -- This works.
circle.area = 100  -- This doesn't: Error! Property "area" is read-only.
```

## License

MIT License (see LICENSE file in project root)