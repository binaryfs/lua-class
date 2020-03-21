local lovecase = require "lovecase"
local class = require "class"

local test = lovecase.newTestSet("class")

test:group("new()", function(test)
  test:run("should return a new class", function()
    local A = class("A")
    test:assertEqual(type(A.new), "function", "Missing constructor")
  end)

  test:run("should handle single inheritance", function()
    local Base = class("Base")
    Base.StaticValue = 123
    function Base:speak()
      return "Hello"
    end
    local Child = class("Child", Base)
    test:assertEqual(Child.new():speak(), "Hello")
    test:assertEqual(Child.new().StaticValue, 123)
  end)

  test:run("should handle multiple inheritance", function()
    local Base1 = class("Base1")
    function Base1:speak()
      return "Hello Birds"
    end
    function Base1:fly()
      return "Flying"
    end

    local Base2 = class("Base2")
    function Base2:speak()
      return "Hello Walkers"
    end

    local Child1 = class("Child1", Base1, Base2)
    test:assertEqual(Child1.new():speak(), "Hello Birds")
    test:assertEqual(Child1.new():fly(), "Flying")

    local Child2 = class("Child2", Base2, Base1)
    test:assertEqual(Child2.new():speak(), "Hello Walkers")
    test:assertEqual(Child2.new():fly(), "Flying")
  end)

  test:run("should require a name", function()
    test:assertError(function()
      local NamelessClass = class()
    end)
  end)
end)

test:group("typeOf()", function(test)
  local Base = class("Base")
  local Child = class("Child", Base)
  test:run("should return the type of class instances", function()
    test:assertEqual(class.typeOf(Base.new()), "Base")
    test:assertEqual(class.typeOf(Child.new()), "Child")
  end)

  test:run("should return the type of classes", function()
    test:assertEqual(class.typeOf(Base), "Base")
    test:assertEqual(class.typeOf(Child), "Child")
  end)

  test:run("should return the type of primitive values", function()
    test:assertEqual(class.typeOf("Foo"), "string")
    test:assertEqual(class.typeOf({}), "table")
  end)
end)

test:group("isInstance()", function(test)
  local Base = class("Base")
  local Child = class("Child", Base)

  test:run("should return true for class instances", function()
    test:assertTrue(class.isInstance(Base.new()), "Base instance expected")
    test:assertTrue(class.isInstance(Child.new()), "Child instance expected")
  end)

  test:run("should return false for all other values", function()
    test:assertFalse(class.isInstance(Base), "Class should not be an instance")
    test:assertFalse(class.isInstance(123), "Number should not be an instance")
    test:assertFalse(class.isInstance({}), "Table should not be an instance")
  end)
end)

test:group("isClass()", function(test)
  local Base = class("Base")
  local Child = class("Child", Base)

  test:run("should return true for classes", function()
    test:assertTrue(class.isClass(Base), "Base should be a class")
    test:assertTrue(class.isClass(Child), "Child should be a class")
  end)

  test:run("should return false for all other values", function()
    test:assertFalse(class.isClass(Base.new()), "Instance should not be a class")
    test:assertFalse(class.isClass(123), "Number should not be a class")
    test:assertFalse(class.isClass({}), "Table should not be a class")
  end)
end)

test:group("inherits()", function(test)
  local Base = class("Base")
  local Child = class("Child", Base)
  
  test:run("should return true for instances of a given type", function()
    local base = Base.new()
    local child = Child.new()
    test:assertTrue(class.inherits(base, Base), "Base instance should inherit from Base")
    test:assertTrue(class.inherits(base, "Base"), "Base instance should inherit from Base #2")
    test:assertTrue(class.inherits(child, Child), "Child instance should inherit from Child")
    test:assertTrue(class.inherits(child, "Child"), "Child instance should inherit from Child #2")
    test:assertTrue(class.inherits(child, Base), "Child instance should inherit from Base")
    test:assertTrue(class.inherits(child, "Base"), "Child instance should inherit from Base #2")
  end)
end)

return test