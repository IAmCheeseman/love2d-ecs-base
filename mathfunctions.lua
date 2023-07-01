
rawset(_G, "lerp", function(a, b, t)
    return (b - a) * t + a
end)

rawset(_G, "clamp", function(a, min, max)
    if a > max then
        return max
    elseif a < min then
        return min
    end
    return a
end)

rawset(_G, "frac", function(a)
    return a - math.floor(a)
end)
