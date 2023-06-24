local Copy = {}

function Copy.deep(t)
    local copy = {}
    for i, v in pairs(t) do
        if type(v) == "table" then
            copy[i] = Copy.deep(v)
            local mt = getmetatable(v)
            if mt then
                setmetatable(copy[i], mt)
            end
        else
            copy[i] = v
        end
    end
    return copy
end

function Copy.shallow(t)
    local copy = {}
    for i, v in pairs(t) do
        copy[i] = v
    end
    return copy
end

return Copy