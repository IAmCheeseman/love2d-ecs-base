local path = (...):gsub("transform$", "")
local ECS = require(path .. "ecs")
local Vec2 = require(path .. "vector")

ECS.component("transform", {
    position = Vec2.new(),
    scale = Vec2.new(1, 1),
    skew = Vec2.new(),
    rotation = 0
})