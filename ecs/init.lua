local path = (...):gsub(".init$", "") .. "."
local copy_path = path:gsub("ecs.$", "")

local Queue = require(path .. "queue")
local SparseSet = require(path .. "sparseset")
local Copy = require(copy_path .. "copy")

local ECS = {

}

-- Entities hold all the systems they own
-- When we process an entity, we call all the systems
-- We just hold the system's id, so it doesn't take up more memory 

local entities = {} -- Holds all the entities
local components = {} -- Holds all the components
local systems = {} -- Holds all the systems
local system_types = {}

local entity_instances = {}
local entity_add_queue = Queue.new()

local function item_exists(definition_array, identifier)
    return definition_array[identifier] ~= nil
end

local function update_instance_systems(instance)
    instance.systems = {}
    for system_identifier, system in pairs(systems) do
        local can_use_system = true
        for i, component_identifier in ipairs(system.components) do
            if instance[component_identifier] == nil then
                can_use_system = false
                break
            end
        end

        if can_use_system then
            table.insert(instance.systems, system_identifier)
        end
    end

    print("--- " .. instance.type .. " components:")
    for i, v in ipairs(instance.systems) do
        print(v)
    end
end

local function add_component_to_instance(instance, identifier, default_value)
    local component = components[identifier]

    if default_value == nil then
        instance[identifier] = (type(component) ~= "table" and component or Copy.deep(component))
    else
        if type(default_value) == "table" then
            for k, v in pairs(Copy.deep(component)) do
                if default_value[k] == nil then
                    default_value[k] = v
                end
            end
        end
        instance[identifier] = default_value
    end
end

function ECS.create(identifier)
    local entity = entities[identifier]
    local instance = setmetatable({}, entity.mt)
    for k, v in pairs(entity.components) do
        if type(k) == "number" then
            if type(v) == "table" then
                instance[v] = Copy.deep(components[v])
            else
                instance[v] = components[v]
            end
        else
            add_component_to_instance(instance, k, v)
        end
    end

    update_instance_systems(instance)
    return instance
end

function ECS.entity(identifier, components)
    local entity = {
        type = identifier,
        components = components,
    }

    entity.mt = {
        __index = entity
    }
    
    entities[identifier] = entity
end

function ECS.inherited_entity(identifier, super_identifier, components)
    local inherited = Copy.deep(entities[super_identifier].components)

    for i, v in pairs(components) do
        if type(v) == "table" then
            if inherited[i] == nil then
                inherited[i] = v
            else
                for ii, vv in pairs(v) do
                    inherited[i][ii] = vv
                end
            end
        else
            inherited[i] = v
        end
    end
    
    local entity = {
        type = identifier,
        components = inherited,
    }

    entity.mt = {
        __index = entity
    }
    
    entities[identifier] = entity
end

function ECS.component(identifier, value)
    components[identifier] = value
end

function ECS.system(type, identifier, components, callback)
    local system = {
        type = type,
        components = components,
        callback = callback,
    }
    systems[identifier] = system
    if system_types[type] == nil then
        system_types[type] = {}
    end
    table.insert(system_types[type], identifier)
end

function ECS.add(instance)
    entity_add_queue:push(instance)
end

function ECS.update()
    while #entity_add_queue.items ~= 0 do
        local instance = entity_add_queue:pop()
        table.insert(entity_instances, instance)
        if instance.create then
            instance:create()
        end
    end
end

function ECS.run(system_type, ...)
    for _, instance in ipairs(entity_instances) do
        if instance[system_type] ~= nil then
            instance[system_type](instance, ...)
        end

        for _, system_identifier in ipairs(instance.systems) do
            local system = systems[system_identifier]
            if system.type == system_type then
                system.callback(instance, ...)
            end
        end
    end
end

return ECS