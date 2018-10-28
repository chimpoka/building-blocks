--
-- Created by nklimontov
-- 26/04/2018
--
local asq = require("building-blocks/library/asq")

return function (...)
    local class, bases = {}, { ... }
    class.__depth = 0

    local depthComparator = function(a, b) return (a.__depth or 0) < (b.__depth or 0) end

    -- copy base class contents into the new class
    for _, base in asq.sortByValue(bases, depthComparator) do
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

        local inits = asq.toTable(asq.map(asq.filter(class.is_a, function (x) return x.init end), function (k,v) return k.init, k.__depth end))
        for k,v in asq.sortByValue(inits, asq.comparators.grater) do
            k(instance, ...)
        end

        return instance
    end})

    function class:new(...)
        return class(...)
    end

    return class
end