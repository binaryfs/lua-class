local class = require "class"

local Dog = class("Dog", class.Object)

function Dog:init(name, size)
  self._name = name
  self._size = size
end

function Dog:greet()
  print("Hello, my name is " .. self._name)
end

function Dog:getName()
  return self._name .. ' (small)'
end

function Dog:getSize()
  return self._size
end

local BigDog = class("BigDog", Dog)

function BigDog:greet()
  Dog.greet(self)
  print("And I'm big!")
end

function BigDog:getName()
  return self._name .. ' (big)'
end

function BigDog:setName(newName)
  self._name = newName
end

function BigDog:_getMissingAttribute(key)
  print("Attribute " .. key .. " is missing")
end

function BigDog:_setMissingAttribute(key, value)
  print("Add new attribute " .. key)
  rawset(self, key, value)
end

local doggo = BigDog.new("Doggo", 2)
print(doggo:greet())

doggo.name = "NewDoggo"
print(doggo.name)
print(doggo.unknown)
print(doggo.class)
print(doggo)