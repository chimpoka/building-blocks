---
--- Created by rkovrigin.
---

local class = require("building-blocks/ExtendAndInit")
local app      = sq.myApplication or logger.fatal("can't get myApplication instance!")

local RenderOnce = class()

function RenderOnce:init(camera)
    self.camera = camera
    self.updateHandler = app:addUpdateHandler(function(dt) self:onComplete(dt) end)
    self.count = 1;
end

--[[    Need skip 1 uodate before stop render   ]]
function RenderOnce:onComplete(dt)
    self.count = self.count - 1
    if ( self.count < 0 ) then
        print("render once complete for ",self.camera)
        self.camera:setEnabled(false)
        app:removeUpdateHandler(self.updateHandler)
        self.updateHandler = nil

    end
end

return RenderOnce