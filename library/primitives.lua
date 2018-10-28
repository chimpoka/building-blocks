_G["lib"] = _G["lib"] or {}

local primitives = {}

function isApplication(app)
    if (app.getRender) then return true end
end

function primitives:new(app, description)
    local o = {}

    if (isApplication(app)) then
        o.application = app
    else
        error("you should add applicaion for creating new primitives")
    end

    o.defaults = {}

    o.uHl   = app:addUpdateHandler(function() o:onUpdate() end)
    o.kHdl  = app:getPlatform():addKeyDownHandler(function (evt) o:onKeyDown(evt) end)
    o.tHdl  = app:getPlatform():addTouchHandler  (function (evt) o:onTouch(evt)   end)

    setmetatable(o, self)
    self.__index = self
    return o
end

function primitives:setDefaults(desc)
    self.defaults = {}
    if not desc then desc = {} end
    self.defaults.size          = desc.size or {1,1}
    self.defaults.position      = desc.position or {0,0,0}
    self.defaults.material      = desc.material or "def::pbr"
    self.defaults.texture       = desc.texture or "def::base"
    self.defaults.filterLevel   = desc.filterLevel or sq.render.FilterLevel.Level0
    self.defaults.renderLayer   = desc.renderLayer or "default"
    self.defaults.renderOrder   = desc.renderOrder or 0
    self.defaults.blending      = desc.blending or true
end


function primitives:onUpdate()

end

function primitives:onKeyDown(event)

end

function primitives:onTouch(event)

end


function primitives:createPlane(desc)

    local planeDefaults = {}

    if not self.defaults then self:setDefaults() end

    if not desc then
        planeDefaults = self.defaults
    else
        planeDefaults.size        = desc.size        or self.defaults.size
        planeDefaults.position    = desc.position    or self.defaults.position
        planeDefaults.material    = desc.material    or self.defaults.material
        planeDefaults.texture     = desc.texture     or self.defaults.texture
        planeDefaults.filterLevel = desc.filterLevel or self.defaults.filterLevel
        planeDefaults.renderLayer = desc.renderLayer or self.defaults.renderLayer
        planeDefaults.renderOrder = desc.renderOrder or self.defaults.renderOrder
        planeDefaults.blending    = desc.blending    or self.defaults.blending
    end

    local node = sq.render.Mesh.createPlane(planeDefaults.size, 1, 1)
    node:setPosition(planeDefaults.position)
    node:setMaterial(sq.render.Material.get(planeDefaults.material))

    local tex = sq.render.Texture.get(planeDefaults.texture)
    tex:setFilterLevel(planeDefaults.filterLevel)
    node:setTexture(tex)

    node:setBlending(planeDefaults.blending)
    node:setRenderLayer(planeDefaults.renderLayer)
    node:setRenderOrder(planeDefaults.renderOrder)

    return node
end



_G["lib"].primitives = _G["lib"].primitives or primitives

return primitives