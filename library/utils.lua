_G["lib"] = _G["lib"] or {}

sq.logger.debug("[LUALIB] load utils module ...")

local utils = {}

function table.empty (self)
    for _, _ in pairs(self) do
        return false
    end
    return true
end

function utils.dump(s, l, i)
    l = (l) or 300; i = i or "";
    if (l<1) then
        sq.logger.error ("utils.dump item limit reached.");
        return l-1
    end;
    local ts = type(s);
    if (ts ~= "table") then
        sq.logger.debug(i,tostring(ts),s); return l-1
    end
    if s.empty then sq.logger.debug('empty')
    else
        sq.logger.debug (i,ts);
        for k,v in pairs(s) do
            l = utils.dump(v, l, i.."\t["..tostring(k).."]");
            if (l < 0) then break end
        end
    end
    return l
end


function utils.classInfo(cls)
    local cname = 'clz'
    print(cname..' methods:') lib.utils.dump(cls.__methods__)
    print(cname..' getters:') lib.utils.dump(cls.__getters__)
    print(cname..' setters:') lib.utils.dump(cls.__setters__)
end


function utils.deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[utils.deepcopy(orig_key)] = utils.deepcopy(orig_value)
        end
        setmetatable(copy, utils.deepcopy(getmetatable(orig)))
    else
        copy = orig
    end
    return copy
end

function utils.merge(a, b)
    local result = {}
    for k,v in pairs(a) do result[k] = v end
    for k,v in pairs(b) do result[k] = v end
    return result
end

function invoke(lambda)
    if lambda and type(lambda) == "function" then
        lambda()
    end
end

function utils.vecToStr(vec)
    local vecStr = ""
    if (vec == nil) then
        return "[nil]"
    end
    if vec.x then vecStr = vecStr.."x = "..vec.x end
    if vec.y then vecStr = vecStr..", y = "..vec.y end
    if vec.z then vecStr = vecStr..", z = "..vec.z end
    if vec.w then vecStr = vecStr..", w = "..vec.w end
    return vecStr
end

_G["lib"].utils = _G["lib"].utils or utils

return utils
