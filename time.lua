local path = (...):gsub("time$", "")
local ECS = require(path .. "ecs")

local function timer_start(self, time)
    self.total_time = time or self.total_time
    self.time_left = self.total_time
end

local function timer_is_over(self)
    return self.time_left <= 0
end

local function create_timer(self, name, time, callback)
    self[name] = {
        time_left = 0,
        total_time = time,
        callback = callback,

        start = timer_start,
        is_over = timer_is_over,
    }
end

ECS.component("timer", {
    create = create_timer,
})

ECS.system("step", "timer", { "timer" }, function(ent, dt)
    local timer = ent.timer

    for k, v in pairs(timer) do
        if type(v) == "table" and not v:is_over() then
            v.time_left = v.time_left - dt

            if v:is_over() then
                v.callback(ent)
            end
        end
    end
end)