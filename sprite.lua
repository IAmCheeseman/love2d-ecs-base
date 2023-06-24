local path = (...):gsub("sprite$", "")
local ECS = require(path .. "ecs")

ECS.component("sprite", {
    path = path:gsub("%.", "/") .. "test.png",
    quad = nil,
    texture = nil,
})
ECS.component("animation", {
    frame_count = 1,
    current_frame = 1,
    fps = 10,
    timer = 0,
})

ECS.system("draw", "draw_sprite", { "sprite", "transform" }, function(ent)
    local tr = ent.transform

    if ent.sprite.texture == nil then
        ent.sprite.texture = love.graphics.newImage(ent.sprite.path)
        ent.sprite.quad = love.graphics.newQuad(
            0, 0,
            ent.sprite.texture:getWidth(), ent.sprite.texture:getHeight(),
            ent.sprite.texture:getWidth(), ent.sprite.texture:getHeight())
    end

    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(ent.sprite.texture, ent.sprite.quad, tr.x, tr.y, tr.r, tr.scale_x, tr.scale_y, tr.skew_x, tr.skew_y)
end)

ECS.system("step", "animate", { "sprite", "animation" }, function(ent, dt)
    local anim = ent.animation
    local sprite = ent.sprite

    if sprite.texture == nil then
        return
    end

    anim.timer = anim.timer + dt

    if anim.timer >= 1 / anim.fps then
        anim.timer = 0
        anim.current_frame = anim.current_frame + 1
        if anim.current_frame > anim.frame_count then
            anim.current_frame = 1
        end
    end

    local frame = anim.current_frame - 1

    local sprite_width, sprite_height = sprite.texture:getDimensions()
    local frame_width = sprite_width / anim.frame_count

    sprite.quad = love.graphics.newQuad(
        frame * frame_width, 0,
        frame_width, sprite_height,
        sprite_width, sprite_height)
end)