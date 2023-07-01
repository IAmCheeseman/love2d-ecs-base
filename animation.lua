local Animation = {}
asjdhasj
function Animation.new(start, stop, fps)
    return {
        start = start,
        stop = stop,
        fps = fps,
    }
end

return Animation
