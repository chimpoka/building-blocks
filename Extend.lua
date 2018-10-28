--
-- Created by nklimontov
-- 27/04/2018
--
local function getKeysSortedByValue(tableToSort, sortFunction)
    local keys = {}
    for key in pairs(tableToSort) do
        table.insert(keys, key)
    end

    table.sort(keys, function(a, b)
        return sortFunction(tableToSort[a], tableToSort[b])
    end)

    return keys
end

return function (...)
    local class, bases = {}, { ... }
    local by_depth ={}
    for c in pairs(bases) do
        by_depth[bases[c]] = bases[c].__depth
    end
    by_depth = getKeysSortedByValue(by_depth, function(a, b) return a < b end)
    class.__depth = 0
    -- copy base class contents into the new class
    for i, base in ipairs(by_depth) do
        local t = getmetatable(base)
        for k, v in pairs(t) do
            class[k] = v
        end
        class.__depth = math.max(((base.__depth or -1) + 1), class.__depth)
    end
    -- set the class's __index, and start filling an "is_a" table that contains this class and all of its bases
    -- so you can do an "instance of" check using my_instance.is_a[MyClass]
    class.__index, class.is_a = class, { [class] = true }

    for i, base in ipairs(bases) do
        for c in pairs(base.is_a) do
            class.is_a[c] = true
        end
        class.is_a[base] = true
    end
    -- the class's __call metamethod
    setmetatable(class, { __call = function (c, ...)
        local instance = setmetatable({}, c)

        if class.init then class.init(instance, ...) end

        return instance
    end})

    function class:new(...)
        local instance = {}
        setmetatable(instance, self)
        if instance.init then instance:init(...) end
        return instance
    end

    return class
end