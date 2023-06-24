local path = (...):gsub("transform$", "")
local ECS = require(path .. "ecs")
local Vector = require(path .. "vector")

ECS.component("transform", {
    position = Vector.new(),
    scale = Vector.new(1, 1),
    skew = Vector.new(),
    rotation = 0
})