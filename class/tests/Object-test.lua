local lovecase = require "lovecase"
local class = require "class"

local test = lovecase.newTestSet("Object")

test:group("Properties", function(test)
  local Base = class("Base", class.Object)

  function Base:init(value)
    self._value = value
  end

  function Base:getValue()
    return self._value
  end

  function Base:setValue(value)
    self._value = value
  end

  test:run("should be created from getter/setter methods", function()
    local base = Base.new("foo")
    test:assertEqual(base.value, base._value)
    base.value = "bar"
    test:assertEqual(base.value, base._value)
  end)

  test:run("should be inherited", function()
    local Child = class("Child", Base)

    local child = Child.new("foo")
    test:assertEqual(child.value, child._value)
    child.value = "bar"
    test:assertEqual(child.value, child._value)
  end)

  test:run("should be overridable", function()
    local Child = class("Child", Base)

    function Child:getValue()
      return tonumber(self._value)
    end
  
    function Child:setValue(value)
      self._value = self._value .. value
    end

    local child = Child.new("12")
    child.value = "3"
    test:assertEqual(child.value, 123)
  end)

  test:run("can be read-only", function()
    local Reader = class("Reader", class.Object)

    function Reader:init(value)
      self._value = value
    end

    function Reader:getValue()
      return self._value
    end

    local reader = Reader.new("foo")
    test:assertEqual(reader.value, "foo")
    test:assertError(function()
      reader.value = "bar"
    end)
  end)

  test:run("can be write-only", function()
    local Writer = class("Writer", class.Object)

    function Writer:setValue(value)
      self._value = value
    end

    local writer = Writer.new()
    writer.value = "foo"
    test:assertEqual(writer._value, "foo")
    test:assertError(function()
      local value = writer.value
    end)
  end)
end)

test:group("_getMissingAttribute", function(test)
  test:run("should be called when no matching attribute is found", function()
    local Foo = class("Foo", class.Object)

    function Foo:init()
      self.bar = 123
    end

    function Foo:_getMissingAttribute(key)
      return "nothing"
    end

    local foo = Foo.new()
    test:assertEqual(foo.bar, 123)
    test:assertEqual(foo.hello, "nothing")
  end)
end)

test:group("_setMissingAttribute", function(test)
  test:run("should be called when no matching attribute is found", function()
    local Foo = class("Foo", class.Object)

    function Foo:init()
      rawset(self, "bar", 123)
      rawset(self, "fails", 0)
    end

    function Foo:_setMissingAttribute(key)
      self.fails = self.fails + 1
    end

    local foo = Foo.new()
    foo.hello = "hello"
    foo.world = "world"
    foo.bar = "bar"
    test:assertEqual(foo.fails, 2)
  end)
end)

return test