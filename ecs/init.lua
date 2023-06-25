local path = (...):gsub(".init$", "") .. "."
local copy_path = path:gsub("ecs.$", "")

local Queue = require(path .. "queue")
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
local entity_remove_queue = Queue.new()

local function item_exists(definition_array, identifier)
    return definition_array[identifier] ~= nil
end

local function update_instance_systems(instance)
    instance.systems = {}
    for system_id, system in ipairs(systems) do
        -- Check if system is valid
        local can_use_system = true
        for i, component_identifier in ipairs(system.components) do
            if instance[component_identifier] == nil then
                can_use_system = false
                break
            end
        end

        if can_use_system then
            table.insert(instance.systems, system_id)
        end
    end
end

local function add_component_to_instance(instance, identifier, default_value)
    local component = components[identifier]

    if component == nil then
        instance[identifier] = default_value
    else
        -- Filling in the properties that were not overridden
        if type(default_value) == "table" then
            component = Copy.deep(component)
            for k, v in pairs(default_value) do
                component[k] = v
            end
        end
        instance[identifier] = component
    end
end

function ECS.create(identifier)
    local entity = entities[identifier]
    local instance = setmetatable({}, entity.mt)
    for k, v in pairs(entity.components) do
        if type(k) == "number" then
            local component = components[v]
            if type(component) == "table" then
                component = Copy.deep(component)
            end
            instance[v] = component
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

    for i, component in pairs(components) do
        if type(v) == "table" then
            if inherited[i] == nil then
                inherited[i] = component
            else
                for field, property in pairs(component) do
                    inherited[i][field] = property
                end
            end
        else
            inherited[i] = component
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

function ECS.system(type, components, callback)
    local system = {
        type = type,
        components = components,
        callback = callback,
    }
    table.insert(systems, system)
    if system_types[type] == nil then
        system_types[type] = {}
    end
    table.insert(system_types[type], #system)
end

function ECS.add(instance)
    entity_add_queue:push(instance)
end

function ECS.remove(instance)
    entity_remove_queue:push(instance)
end

function ECS.flush_queues()
    while #entity_remove_queue.items ~= 0 do
        local instance = entity_remove_queue:pop()
        for i, v in ipairs(entity_instances) do
            if v == instance then
                table.remove(entity_instances, i)
            end
        end
    end

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