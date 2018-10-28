sq.logger.debug("[LUALIB] load FSM module ...")

local app = sq.myApplication or sq.logger.fatal("can't get myApplication instance!")

_G["lib"] = _G["lib"] or {}

local fsm = {}
local dummy = function() end

function fsm:new(description)
    local o = {}

    o.updHdl = app:addUpdateHandler(function() o:onUpdate() end)
    o.kHdl  = app:getPlatform():addKeyHandler(function (evt) o:onKey(evt) end)
    o.tHdl  = app:getPlatform():addTouchHandler  (function (evt) o:onTouch(evt)   end)

    local dict   = {}
    local states = {}
    for _state, _description in pairs(description) do
        table.insert(states,_state)
        for evt,nextState in pairs(_description) do
            dict[evt]=nextState
        end
    end
    o.STATES   = states
    o.eventDic = dict
    o.curState = nil

    setmetatable(o, self)
    self.__index = self
    return o
end

function fsm:sentEvent(evt)
    sq.logger.debug("send event " .. evt)
    if (self.eventDic[evt]) then
        self:setState(self.eventDic[evt])
    else
        error("you tried to send wrong event")
    end
end

function fsm:setState(s)
    if self.curState and self.curState.onLeave then self.curState:onLeave() end
    if self.STATES[s] then
        self.curState = self.STATES[s]
        sq.logger.debug("state "..s.." was set")
    else
        error("there isn't state with name "..s)
    end
    if (self.curState.onEnter) then self.curState:onEnter() end
end

function fsm:onUpdate()
    if self.curState and self.curState.onUpdate then
        self.curState.onUpdate()
    end
end

function fsm:onKey(event)
    if self.curState and self.curState.onKey then
        self.curState.onKey(event)
    end
end

function fsm:onTouch(event)
    if self.curState and self.curState.onTouch then
        self.curState.onTouch(event)
    end
end

_G["lib"].fsm = _G["lib"].fsm or fsm

return fsm
