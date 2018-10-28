sq.logger.debug("[LUALIB] load audio module ...")

_G["lib"] = _G["lib"] or {}

local app = sq.myApplication or sq.logger.fatal("can't get myApplication instance!")
local audio = {}

function audio:new(description)
    local o = {}

    o.application = app

    o.service = o.application:getPlatform():getAudioService()
    o.timer = sq.common.Timer.instance()
    o.handlers = {}
    o.sounds = {}

    setmetatable(o, self)
    self.__index = self
    return o
end

function audio:addSound(soundFile, loopCount)
    local newSoundHdl = self.service:play(soundFile)

    if loopCount then
        if loopCount == 0 then
            newSoundHdl:setIsLooped(true)
        elseif loopCount > 1 then
            local soundLoopHolder = newSoundHdl:addHandler
            (
                function()
                    if loopCount > 1 then
                        newSoundHdl:play()
                        loopCount = loopCount - 1
                    else
                        self.timer:addHandler(1, function() self.newSoundHdl:removeHandler(soundLoopHolder) end, false)
                    end
                end
            )
            table.insert(self.handlers, soundLoopHolder)
        end
    end

    table.insert(self.sounds, newSoundHdl)

    return newSoundHdl
end

function audio:ducking(soundFile, fadeTime, fadeDelta)
    local fTime = fadeTime or 3
    local fDelta = fadeDelta or 0.3

    local volumes = {}
    for k, sound in ipairs(self.sounds) do
        self:fade(sound, fTime, -fDelta)
        volumes[sound] = sound:getVolume()
    end
    lib.utils.dump(volumes)
    -- local duckingSound = self:addSound(soundFile, 1)
    -- local finishDuckHdl = duckingSound:addHandler
    -- (
    local finishDuckHdl =
        function()
            for soundHndl, volume in pairs(volumes) do
                local delta = volume - soundHndl:getVolume()
                self:fade(soundHndl, fTime, delta)
            end
        end
    -- )

    local duckingSound = self.service:play(soundFile, finishDuckHdl)
    return duckingSound
end

function audio:fade(soundHdl, fadeTime, deltaVolume, callbackFunc)
    local fTime = fadeTime or 3
    local fDelta = deltaVolume or 0.3

    local fadeSpeed = fDelta / fTime
    local fadingInHolder = self.application:addUpdateHandler
    (
        function()
            local delta = self.timer:getDeltaTime()
            if fadeTime > 0 then
                soundHdl:setVolume(soundHdl:getVolume() + fadeSpeed * delta)
                fadeTime = fadeTime - delta
            end
        end
    )
    local fadeTimeHdl = self.timer:addHandler(fadeTime+0.1, function()
                                                                self.application:removeUpdateHandler(fadingInHolder)
                                                                if callbackFunc then callbackFunc() end
                                                            end, false)
end

_G["lib"].audio = _G["lib"].audio or audio

return audio
