-- Multiple inheritance example.

local class = require "class"

--
-- Abstract Node class
--

local Node = class("Node")

function Node.new()
  error("Node is an abstract class")
end

function Node:init()
  self._parent = false
  self._children = {}
end

function Node:addChild(child)
  if not class.inherits(child, Node) then
    error("Node instance expected")
  end
  if child._parent then
    child._parent:removeChild(child)
  end
  table.insert(self._children, child)
  child._parent = self
end

function Node:removeChild(child)
  for i = 0, #self._children do
    if self._children[i] == child then
      table.remove(self._children, i)
      return
    end
  end
end

--
-- Abstract Taggable class
--

local Taggable = class("Taggable")

function Taggable.new()
  error("Taggable is an abstract class")
end

function Taggable:init()
  self._tags = {}
end

function Taggable:addTag(tag)
  self._tags[tag] = true
end

function Taggable:removeTag(tag)
  self._tags[tag] = nil
end

function Taggable:hasTag(tag)
  return self._tags[tag] == true
end

--
-- Entity class
--

local Entity = class("Entity", Node, Taggable)

function Entity:init()
  Node.init(self)
  Taggable.init(self)
end

return Entity