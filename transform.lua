local path = (...):gsub("transform$", "")
local ECS = require(path .. "ecs")

ECS.component("transform", {
    x = 0,
    y = 0,
    scale_x = 1,
    scale_y = 1,
    skew_x = 0,
    skew_y = 0,
    rotation = 0
})