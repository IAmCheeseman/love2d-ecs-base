
function lerp(a, b, t)
    return (b - a) * t + a
end

function clamp(a, min, max)
    if a > max then
        return max
    elseif a < min then
        return min
    end
    return a
end

function frac(a)
    return a - math.floor(a)
end