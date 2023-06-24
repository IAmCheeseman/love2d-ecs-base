local SparseSet = {}

local function sparse_set_add(self, index)
    table.insert(self.dense, index)
    self.sparse[index] = #self.dense
end

local function sparse_set_remove(self, index)
    local index = self.sparse[index]
    local new_index = self.dense[#self.dense]

    self.dense[index] = new_index
    self.sparse[new_index] = index
    
    table.remove(self.dense, #self.dense)
    self.sparse[index] = nil
end

local function sparse_set_has(self, index)
    return self.sparse[index] ~= nil
end

local sparse_set_mt = {
    __index = function(t, index)
        return self.dense[self.sparse[index]]
    end,
    __len = function(t)
        return #t.dense
    end,
    __ipairs = function(t)
        return ipairs(self.dense)
    end
}

function SparseSet.new()
    return setmetatable({
        sparse = {},
        dense = {},

        add = sparse_set_add,
        remove = sparse_set_remove,
        has = sparse_set_has,
    }, sparse_set_mt)
end