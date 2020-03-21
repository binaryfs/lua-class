love.filesystem.setRequirePath(
  "libs/?.lua;libs/?/init.lua;" .. love.filesystem.getRequirePath()
)

local lovecase = require "lovecase"
local report = lovecase.runAllTestFiles("class/tests")
print(report:printResults())