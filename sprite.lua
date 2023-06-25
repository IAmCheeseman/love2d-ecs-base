local path = (...):gsub("sprite$", "")
local Ecs = require(path .. "ecs")
local Animation = require(path .. "animation")

Ecs.component("sprite", {
    path = path:gsub("%.", "/") .. "test.png",
    quad = nil,
    texture = nil,
})
Ecs.component("animation", {
    frame_count = 1,
    current_frame = 1,
    timer = 0,
    state = Animation.new(1, 1, 10),
})

Ecs.system("draw", { "sprite", "transform" }, function(ent)
    local tr = ent.transform

    if ent.sprite.texture == nil then
        ent.sprite.texture = love.graphics.newImage(ent.sprite.path)
        ent.sprite.quad = love.graphics.newQuad(
            0, 0,
            ent.sprite.texture:getWidth(), ent.sprite.texture:getHeight(),
            ent.sprite.texture:getWidth(), ent.sprite.texture:getHeight())
    end

    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(ent.sprite.texture, ent.sprite.quad, tr.position.x, tr.position.y, tr.r, tr.scale.x, tr.scale.y, tr.skew.x, tr.skew.y)
end)

Ecs.system("step", { "sprite", "animation" }, function(ent, dt)
    local anim = ent.animation
    local sprite = ent.sprite

    if sprite.texture == nil then
        return
    end

    anim.timer = anim.timer + dt

    if anim.timer >= 1 / anim.state.fps then
        anim.timer = 0
        anim.current_frame = anim.current_frame + 1
    end

    if anim.current_frame > anim.state.stop or anim.current_frame < anim.state.start then
        anim.current_frame = anim.state.start
    end

    local frame = anim.current_frame - 1

    local sprite_width, sprite_height = sprite.texture:getDimensions()
    local frame_width = sprite_width / anim.frame_count

    sprite.quad = love.graphics.newQuad(
        frame * frame_width, 0,
        frame_width, sprite_height,
        sprite_width, sprite_height)
end)