setmetatable(_G, {
    __index = function(_, k)
        error(("Undefined variable '%s'."):format(k))
    end,
    __newindex = function(_, k, _)
        error(("Cannot set '%s' as a global, use rawset if you must set a global."):format(k))
    end
})

require "mathfunctions"
require "time"
require "transform"
require "sprite"

rawset(_G, "Ecs", require "ecs")
rawset(_G, "Vec2", require "vector")
rawset(_G, "Animation", require "animation")

