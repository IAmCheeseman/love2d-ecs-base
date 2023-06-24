local Vec2 = {}

local function vector_length(v)
    return math.sqrt(v.x^2 + v.y^2)
end

local function vector_normalized(v)
    local length = v:length()
    if length == 0 then
        return Vec2.new()
    end
    return Vec2.new(v.x / length, v.y / length)
end

local function vector_dot(v, o)
    return v.x * o.x + v.y * o.y
end

local function vector_direction_to(v, o)
    return (v - o):normalized()
end

local function vector_distance_to(v, o)
    return (v - o):length()
end

local function vector_manhattan_distance_to(v, o)
    return Vec2.new(math.abs(v.x - o.x) + math.abs(v.y - o.y))
end

local function vector_angle(v)
    local angle = math.atan2(v.y, v.x)
    return angle
end

local function vector_angle_to(v, o)
    return (v - o):angle()
end

local function vector_rotated(v, by)
    local rotation = v:angle() + by
    local length = v:length()

    return Vec2.new(math.sin(rotation) * length, math.cos(rotation) * length)
end

local function vector_lerp(a, b, t)
    return Vec2.new(lerp(a.x, b.x, t), lerp(a.y, b.y, t))
end

local function vector_copy(v)
    return Vec2.new(v.x, v.y)
end

local vector_mt = {
    __add = function(l, r)
        return Vec2.new(l.x + r.x, l.y + r.y)
    end,
    __sub = function(l, r)
        return Vec2.new(l.x - r.x, l.y - r.y)
    end,
    __mul = function(l, r)
        if type(r) == "table" then
            return Vec2.new(l.x * r.x, l.y * r.y)
        else
            return Vec2.new(l.x * r, l.y * r)
        end
    end,
    __div = function(l, r)
        if type(r) == "table" then
            return Vec2.new(l.x / r.x, l.y / r.y)
        else
            return Vec2.new(l.x / r, l.y / r)
        end
    end,
    __unm = function(r)
        return r * -1
    end,
    __tostring = function(v)
        return ("(%d, %d)"):format(v.x, v.y)
    end
}

function Vec2.new(x, y)
    x = x or 0
    y = y or 0

    return setmetatable({
        x = x,
        y = y,

        length = vector_length,
        normalized = vector_normalized,
        dot = vector_dot,
        direction_to = vector_direction_to,
        distance_to = vector_distance_to,
        manhattan_distance_to = vector_manhattan_distance_to,
        angle = vector_angle,
        angle_to = vector_angle_to,
        rotated = vector_rotated,
        lerp = vector_lerp,
        copy = vector_copy,
    }, vector_mt)
end

return Vec2