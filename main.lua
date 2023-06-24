local ECS = require "ecs"
require "time"

ECS.component("pos", {
    x = 0,
    y = 0,
})

ECS.component("circle", 32)
ECS.component("color", {
    r = 1,
    g = 1,
    b = 1,
    a = 1,
})
ECS.component("time", 0)

ECS.system("step", "inc_time", { "time" }, function(ent, dt)
    ent.time = ent.time + dt
end)

ECS.system("step", "spin", { "pos", "time" }, function(ent, dt)
    ent.pos.x = math.cos(ent.time * 5) * 32 + 64
    ent.pos.y = math.sin(ent.time * 5) * 32 + 64
end)

ECS.system("draw", "draw_circle", { "pos", "circle", "color" }, function(ent)
    love.graphics.setColor(ent.color.r, ent.color.g, ent.color.b)
    love.graphics.circle("fill", ent.pos.x, ent.pos.y, ent.circle)
end)

ECS.entity("player", { 
    ["circle"] = 5,
    "time",
    "timer",
    "pos",
    ["color"] = {
        r = 1,
        g = 0,
        b = 0,
    },

    create = function(self)
        self.timer:create("color_swap", 1, function(self)
            if self.color.r == 1 then
                self.color.r = 0
            else
                self.color.r = 1
            end
            self.timer.color_swap:start()
        end)
        self.timer.color_swap:start()
    end,
    step = function(self, dt)
        print(self.time)
    end,
    draw = function(self)
        love.graphics.setColor(0, 0, 1)
        love.graphics.circle("fill", self.pos.x, self.pos.y, self.circle * 2)
    end
})

local player = ECS.create("player")
ECS.add(player)

function love.update(dt)
    ECS.update()
    ECS.run("step", dt)
end

function love.draw()
    ECS.run("draw")
end