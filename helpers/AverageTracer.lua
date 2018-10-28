---
--- Created by rkovrigin.
---
local timer    = sq.myTimer       or logger.fatal("can't get myTimer")
local logger   = sq.logger
local class = require("building-blocks/ExtendAndInit")

local Tracer = class()

-- @header = tracer header for printing
-- @count = how much values store
-- @timeout = timeout for trace
function Tracer:init(header, count, timeout)
    self.header = header or "[avg tracer]"
    self.count = count or 10
    self.timeout = timeout or 1
    self.values = {}
    self:start()
end

function Tracer:start()
    if (self.printHandler) then
        self:stop()
    end
    self.printHandler = timer:addHandler
    (
            self.timeout,
            function()
                logger.debug(self.header,self:getAverangeValue())
            end, true
    )
end

function Tracer:stop()
    if (self.printHandler) then
        timer:removeHandler(self.printHandler)
        self.printHandler = nil
    end
end

function Tracer:add(value)
    table.insert(self.values,value)
    while(#self.values>self.count) do
        table.remove(self.values,1)
    end
end

function Tracer:getAverangeValue()
    if (#self.values == 0) then
        return 0
    end
    local result = 0
    for i = 1, #self.values do
        result = result + self.values[i]
    end
    return result/#self.values
end

return Tracer