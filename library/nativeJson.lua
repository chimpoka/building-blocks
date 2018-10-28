---
--- Created by asemenov.
--- DateTime: 12/07/2018 15:18
---


local jsonParser = {
    encode = function (table)
        return tostring(sq.json.toJson(table))
    end,

    decode = function (string)
        return sq.json.fromJson(sq.json.fromString(string))
    end
}

return jsonParser
