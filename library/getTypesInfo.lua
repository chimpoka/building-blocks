sq.logger.debug("[LUALIB] load typeInformation module ...")

_G["lib"] = _G["lib"] or {}

local typeInformation = currentServer:getTypesInformation()


function split(sep, str)
    local sep, fields = sep or ":", {}
    local pattern = string.format("([^%s]+)", sep)
    str:gsub(pattern, function(c) fields[#fields+1] = c end)
    return fields
end

local function createTypeTable(prefix, table)
    local result = ""

    for k, v in pairs(table) do
        local newPrefix = ""
        if (prefix == "") then
            result = result .. "\n" .. k .. " = {}"
            newPrefix = k
        else
            result = result .. "\n" .. prefix .. "." .. k .. " = {}"
            newPrefix = prefix .. "." .. k
        end
        result = result .. createTypeTable(newPrefix, v)
    end

    return result
end

local function getTypeName(fullName)
    local tokens = split(".", fullName)
    return tokens[#tokens]
end

local function removeDuplicates(t)
    local hash = {}
    local res = {}

    for _,v in ipairs(t) do
        if (not hash[v]) then
            res[#res+1] = v
            hash[v] = true
        end
    end
    return res
end

local function getSignatureSizeStatic(signatures)
    return #signatures
end

local function getSignatureSizeMethod(signatures)
    return #signatures - 1
end

local function createArgumentsList(overload, signatureSizeFunc, printFunc)
    local result = ""
    local nArgs = signatureSizeFunc(overload.signature)
    local argsShift = #overload.signature-nArgs
    local flag = false
    for idx=argsShift+1,#overload.signature,1 do
        result = result .. printFunc(flag, "arg" .. tostring(idx - argsShift), getTypeName(overload.signature[idx].name))
        flag = true
    end
    return result
end

local function createClassMethodBinding(className, overloads, typeGetterFunc, signatureSizeFunc, methodString)

    if (#overloads == 0) then
        return ""
    end

    local result = ""

    local firstOverload = overloads[1]
    result = result .. "--- " .. firstOverload.info .. "\n"

    for k = 2,#overloads,1 do
        local overload = overloads[k]
        result = result .. "--- " .. tostring(k) .. "). " .. overload.info .. "\n"
        result = result .. "---@ overload fun(" .. createArgumentsList(overload, signatureSizeFunc,
            function (flag, argName, typeName)
                local result = ""
                if flag then
                    result = result .. ", "
                end
                return result .. argName .. ": " .. typeName
            end
        ) .. ")"
        result = result .. ":"
        if(overload.retType) then
            result = result .. typeGetterFunc(overload.retType.name)
        else
            result = result .. "nil"
        end
        result = result .. "\n"
    end

    result = result .. createArgumentsList(firstOverload, signatureSizeFunc,
    function (flag, argName, typeName)
            return "---@ param " .. argName .. " " .. typeName .. "\n"
        end)

    result = result .. "---@ return "
    if (firstOverload.retType) then
        result = result .. typeGetterFunc(firstOverload.retType.name) .. "\n"
    else
        result = result .. "nil\n"
    end

    result = result .. "function " .. getTypeName(className) .. methodString .. "(" ..
        createArgumentsList(firstOverload, signatureSizeFunc,
        function (flag, argName, typeName)
            local result = ""
            if flag then
                result = result .. ", "
            end
            return result .. argName
        end) .. ") end"

    return result .. "\n\n"
end

function string.starts(String,Start)
    return string.sub(String,1,string.len(Start))==Start
end

local function createMethodsBinding(className, methods, typeGetterFunc)
    local result = ""
    for k, methodInfo in pairs(methods) do

        local constructors = {}
        local staticMethods = {}
        local methods = {}

        for k, overload in pairs(methodInfo.overloads) do
            -- do not add operators
            if (not  string.starts(methodInfo.name, "__")) then
                if overload.methodType == sq.MethodType.CONSTRUCTOR then
                    table.insert(constructors, overload)
                end

                if overload.methodType == sq.MethodType.STATIC then
                    table.insert(staticMethods, overload)
                end

                if overload.methodType == sq.MethodType.METHOD then
                    table.insert(methods, overload)
                end
            end
        end

        result = result .. createClassMethodBinding(className, constructors, typeGetterFunc, getSignatureSizeStatic, ".new")
        result = result .. createClassMethodBinding(className, staticMethods, typeGetterFunc, getSignatureSizeStatic,  "." .. methodInfo.name)
        result = result .. createClassMethodBinding(className, methods, typeGetterFunc, getSignatureSizeMethod,  ":" .. methodInfo.name)
    end
    return result
end

function typeInformation:createBindingHelper(tableCreatorFunc, typeGetterFunc, filter)
    local result = ""

    local classTables = {}

    for k, classInfo in pairs(self) do
        if not string.find(tostring(classInfo), "function:") then
            local className = k
            if (not  filter or filter(className)) then
                local namespaces = split(".", className)
                local currentTable = classTables
                for i, namespace in ipairs(namespaces) do
                    if (currentTable[namespace] == nil ) then
                        currentTable[namespace] = {}
                    end
                    currentTable = currentTable[namespace]
                end
            end
        end
    end

    result = result .. tableCreatorFunc("", classTables, self)

    for k, classInfo in pairs(self) do
        if not string.find(tostring(classInfo), "function:") then
            local className = k
            if (not filter or filter(className)) then
                if className ~= "" then
                    result = result .. createMethodsBinding(className, classInfo.methods, typeGetterFunc)
                end

            end
        end
    end

    return result
end

function tablelength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end

local function createTypeTable_WorkAround(prefix, table, creator)
    local result = ""

    for k, v in pairs(table) do
        local newPrefix = ""
        if (prefix == "") then
            result = result .. "\n" .. k .. " = {}"
            newPrefix = k
        else
            newPrefix = prefix .. "." .. k
            local classInfo = creator[newPrefix]
            if (classInfo and classInfo.typeInfo) then
                result = result .. "\n---@class " .. k .. " "
                if (classInfo.typeInfo.parent) then
                    result = result .. ": " .. getTypeName(classInfo.typeInfo.parent.name)
                end
                for _, propInfo in ipairs(classInfo.properties) do
                    result = result .. "\n---@field public " .. propInfo.name .. " " .. getTypeName(propInfo.typeInfo.name)
                end
            end
            result = result .. "\nlocal " .. k .. " = {}"
            local namespaces = split(".", prefix)
            result = result .. "\n" .. namespaces[#namespaces] .. "." .. k .. " = " .. k
        end
        result = result .. createTypeTable_WorkAround(newPrefix, v, creator)
    end

    return result
end

function typeInformation:printBinding(filter)
    return self:createBindingHelper(createTypeTable_WorkAround, getTypeName, filter)
end


_G["lib"].typeInformation = _G["lib"].typeInformation or typeInformation

return typeInformation