_G["lib"] = _G["lib"] or {}

local animator = {}
local vec3 = sq.math.vec3
--[[local animator_contract = {
    {0,     {-3,-3,0},  {1,-1,0} },
    {1,     {-3,3,0},   {-1,-1,0}},
    {2,     {3,-3,0},   {-1,1,0} },
    {3,     {3,3,0},    {1,1,0}  },

}--]]

function isApplication(app)
    if (app.getRender) then return true end
end

function animator:new(app, tableValue)
    local o = {}
    if (isApplication(app)) then
        o.application = app
    else
        error("you should add applicaion for animator")
    end

    o.plotter = o.application:getRender():getPlotter()
    o.track = sq.render.KeyValueTrack.new(sq.render.Interpolate.bezier)
    o.trackValue = {}

    setmetatable(o, self)
    self.__index = self
    return o
end

function animator:setFromTable(track_value)


    for i=1, #track_value do

        local position = vec3.new(track_value[i][2][1], track_value[i][2][2], track_value[i][2][3])
        local tangent = vec3.new(track_value[i][3][1], track_value[i][3][2], track_value[i][3][3])
        self.track:addKey(track_value[i][1], position, {tangent})
        self.plotter:basis(position, tangent)

        if not (i == 1) then
            --self.plotter:bezier()
        end

    end
end

function animator:onUpdate()
    sq.render.AnimatorsQueue.update()


    if self.debug then
        self.plotter:clear()
        self.plotter:basis(vec3.new(0,0,0),vec3.new(1,1,1))

        for i = 1, #p do
            self.plotter:basis(p[i],t[i])

            if not (i==4) then
                self.plotter:bezier(p[i], p[i+1], t[i], t[i+1], 20, {1,0,1,1})
            else
                self.plotter:bezier(p[i], p[1], t[i], t[1], 20, {1,0,1,1})
            end
        end
    end

end

function animator:onKeyDown(keyEvent)
    if (keyEvent.key) == keyCode.D then
        self.debug = not self.debug
        self.plotter:clear()
    end
end


_G["lib"].animator = _G["lib"].animator or animator

return animator



