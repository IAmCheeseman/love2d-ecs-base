local path = (...):gsub(".init$", "") .. "."
local copy_path = path:gsub("ecs.$", "")

local Queue = require(path .. "queue")
local Copy = require(copy_path .. "copy")

local Ecs = {

}

-- Entities hold all the systems they own
-- When we process an entity, we call all the systems
-- We just hold the system's id, so it doesn't take up more memory 

local entities = {} -- Holds all the entities
local components = {} -- Holds all the components
local systems = {} -- Holds all the systems
local tags = {}
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
    local component = nil
    if components[identifier] then
        component = components[identifier].value
    end

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

        if components[identifier].init then
            components[identifier].init(component)
        end
    end
end

function Ecs.create(identifier)
    local entity = entities[identifier]
    local instance = setmetatable({}, entity.mt)
    for k, v in pairs(entity.components) do
        if type(k) == "number" then
            local component = components[v].value
            if type(component) == "table" then
                component = Copy.deep(component)
            end
            instance[v] = component

            if components[v].init then
                components[v].init(instance[v])
            end
        else
            add_component_to_instance(instance, k, v)
        end
    end

    update_instance_systems(instance)
    return instance
end

function Ecs.entity(identifier, components)
    local entity = {
        type = identifier,
        components = components,
    }

    entity.mt = {
        __index = entity
    }
    
    entities[identifier] = entity
end

function Ecs.inherited_entity(identifier, super_identifier, components)
    local inherited = Copy.deep(entities[super_identifier].components)

    for i, component in pairs(components) do
        if type(component) == "table" then
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

function Ecs.component(identifier, value, init)
    components[identifier] = {
        value = value,
        init = init
    }
end

function Ecs.system(type, components, callback)
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

function Ecs.add(instance)
    entity_add_queue:push(instance)
end

function Ecs.remove(instance)
    entity_remove_queue:push(instance)
end

function Ecs.flush_queues()
    local to_remove = {}
    for i, v in ipairs(entity_instances) do
        if entity_remove_queue:has(v) then
            entity_remove_queue:pop()
            table.insert(to_remove, i)
        end
    end
    while #entity_remove_queue.items ~= 0 do
        entity_remove_queue:pop() -- clearly inaccessible 
    end

    for _, v in ipairs(to_remove) do
        local last = entity_instances[#entity_instances]
        entity_instances[v] = last
        entity_instances[#entity_instances] = nil
    end

    while #entity_add_queue.items ~= 0 do
        local instance = entity_add_queue:pop()
        table.insert(entity_instances, instance)
        if instance.create then
            instance:create()
        end
    end
end

function Ecs.run(system_type, ...)
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

return Ecs