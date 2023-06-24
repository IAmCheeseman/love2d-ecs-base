local Queue = {}

local function queue_get(self, index)
    return self.items[index]
end

local function queue_pop(self)
    local value = self.items[1]
    table.remove(self.items, 1)
    return value
end

local function queue_push(self, value)
    table.insert(self.items, value)
end

local queue_mt = {
    __index = queue_get,
    __len = function(t)
        return #t.items
    end,
    __ipairs = function(t)
        return ipairs(t.items)
    end
}

function Queue.new()
    return setmetatable({
        items = {},

        pop = queue_pop,
        push = queue_push,
    }, queue_mt)
end

return Queue