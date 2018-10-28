---
--- utility library for functional-style collections processing
--- Created by asemenov.
--- DateTime: 18/06/2018 16:49
---
print("[LUALIB] load ASQ library ...")

_G["lib"] = _G["lib"] or {}

local asq = {}

local nextByType = {
    ["function"] = function (source, prev)
        return source()
    end,

    ["table"] = function (source, prev)
        return next(source, prev)
    end
}

asq.comparators = {
    less = function (a, b) return a < b end,
    grater = function (a, b) return a > b end
}

--- @brief lazy evaluates key/value pairs
--- @param range table or iterator, function()
--- @param predicate bool function(k,v). True means this pair should be returned
--- @return Lua-style iterator compatible with for-in loop
function asq.filter(range, predicate)
    local k,v =  nil, nil
    local f = nextByType[type(range)]

    if not f then
        return function () return nil, nil end
    end

    return function()
        repeat
            k,v = f(range, k)
            if not k then
                return nil, nil
            end
        until predicate(k,v)

        return k,v
    end
end

function asq.map(range, fun)
    local f = nextByType[type(range)]

    if not f then
        return function () return nil, nil end
    end

    local k,v
    return function()
        k,v = f(range, k)
        if k then
            return fun(k, v)
        else
            return nil, nil
        end
    end
end

--- @brief takes N first elements
--- @param source - table or iterator function
--- @return iterator function
function asq.take(range, count)
    local remainingIters = count
    local f = nextByType[type(range)]

    if not f then
        return function () return nil, nil end
    end

    local k,v = nil
    return function()
        if remainingIters <= 0 then
            return nil, nil
        end
        remainingIters = remainingIters - 1

        k,v = f(range, k)
        return k,v
    end
end

local function internalSort(range, comparator, tuplePos)
    local f = nextByType[type(range)]
    if not f then
        return function () return nil, nil end
    end


    local pairs = {}
    for k,v in f,range do
        table.insert(pairs, {k, v})
    end


    table.sort(pairs, function(a, b)
        return comparator(a[tuplePos], b[tuplePos])
    end)

    local currentIndex = #pairs
    return function()
        if currentIndex <= 0 then
            return nil, nil
        end

        local pair = pairs[currentIndex]
        currentIndex = currentIndex - 1

        return pair[1], pair[2]
    end
end

--- @brief sorts the collection by key
--- @param range - supports both tables and iterators
--- @return iterator to sorted elements
function asq.sortByKey(range, comparator)
    return internalSort(range, comparator, 1)
end

--- @brief sorts the collection by value
--- @param range - supports both tables and iterators
--- @return iterator to sorted elements
function asq.sortByValue(range, comparator)
    return internalSort(range, comparator, 2)
end


--- @brief groups the collection by given criteria
--- @param range - table or iterator
--- @param keySelector - function (k,v) that returns grouping criteria
--- @param elementSelector - function(k,v), result will be inserted into result groups
--- @return iterator to next different group (returns key and group)
function asq.groupBy(range, keySelector, elementSelector)

    local f = nextByType[type(range)]

    if not f then
        return function () return nil, nil end
    end

    local k,v = nil, nil
    local groupingCriteria = nil

    return function()
        local prevCriteria
        local group = {}

        repeat
            prevCriteria = groupingCriteria

            if k then
                table.insert(group, elementSelector(k,v))
            end

            k,v = f(range, k)

            if k then
                groupingCriteria = keySelector(k,v)
            else
                groupingCriteria = nil
                break
            end
        until prevCriteria and (prevCriteria ~= groupingCriteria)
        return prevCriteria, group
    end
end

--- @brief copies all pairs from iterator to new table
--- @param iterator
--- @return table
function asq.toTable(iterator)
    if (type(iterator) ~= "function") then
        sq.logger.error("toTable supports only iterators")
        return nil --TODO: error?
    end

    local result = {}
    for k,v in iterator do
        result[k] = v
    end

    return result
end

function asq.count(range)
    local f = nextByType[type(range)]
    if not f then
        return function () return nil, nil end
    end

    local count = 0
    for _ in f,range do count = count + 1 end
    return count
end

function asq.foldKeys(range, fun)
    local f = nextByType[type(range)]
    if not f then
        return function () return nil, nil end
    end

    local accumulator
    local pk
    for k,_ in f,range do
        if pk then
            accumulator = fun(accumulator or pk, k)
        end
        pk = k
    end

    return accumulator
end

function asq.foldValues(range, fun)
    local f = nextByType[type(range)]
    if not f then
        return function () return nil, nil end
    end

    local accumulator
    local pv
    for _,v in f,range do
        if pv then
            accumulator = fun(accumulator or pv, v)
        end
        pv = v
    end

    return accumulator
end

function asq.allOf(range, predicate)
    local f = nextByType[type(range)]
    if not f then
        return true --like STL
    end

    for k,v in f,range do
        if not predicate(k, v) then
            return false
        end
    end

    return true
end

function asq.anyOf(range, predicate)
    local f = nextByType[type(range)]
    if not f then
        return true --like STL
    end

    for k,v in f,range do
        if predicate(k, v) then
            return true
        end
    end

    return false
end

_G["lib"].asq = _G["lib"].asq or asq

return asq