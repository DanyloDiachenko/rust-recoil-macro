-- ~/.hammerspoon/rifle.lua
local patterns = require("patterns")
local utils = require("utils")
local config = require("config")
local randomizer = require("randomizer")

local rifle = {}

rifle.STATE = {
    enabled = false,   
    shooting = false,    
    stepIndex = 1,      
    patternLength = 30,  
    currentPattern = {},  
    originalMousePosition = nil,
    compensationTimer = nil,
    isInGameMode = false,
}

function rifle:rawInputMouseMove(dx, dy)
    if not self.STATE.originalMousePosition then return end

    local baseTargetX = dx
    local baseTargetY = dy

    for i = 1, config.randomizer do'
        local random1 = math.random(config.randomizer.minMultiplierRandomizer, config.randomizer.maxMultiplierRandomizer)
        local random2 = math.random(config.randomizer.minMultiplierRandomizer, config.randomizer.maxMultiplierRandomizer)

        local multiplier = ((math.random(random1 + random2) / 2) / 100)

        local noiseX = math.random(config.randomizer.minXNoise, config.randomizer.maxXNoise)

        local stepDx = (baseTargetX / smoothness) * multiplier + noiseX
        local stepDy = (baseTargetY / smoothness) * multiplier

        local currentPosition = hs.mouse.absolutePosition()
        
        local event = hs.eventtap.event.newMouseEvent(
            hs.eventtap.event.types.mouseMoved,
            {x = currentPosition.x + stepDx, y = currentPosition.y + stepDy}
        )

        event:setFlags({})
        event:setProperty(hs.eventtap.event.properties.mouseEventDeltaX, math.floor(stepDx * 10))
        event:setProperty(hs.eventtap.event.properties.mouseEventDeltaY, math.floor(stepDy * 10))
        event:setProperty(hs.eventtap.event.properties.mouseEventSubtype, 0)
        event:post()

        hs.timer.usleep(math.random(config.randomizer.minMicroStepPause, config.randomizer.maxMicroStepPause))
    end

    local finalJitterX = math.random(config.randomizer.minFinalJytter, config.randomizer.maxFinalJytter)
    local finalJitterY = math.random(config.randomizer.minFinalJytter, config.randomizer.maxFinalJytter)

    hs.mouse.absolutePosition({
        x = self.STATE.originalMousePosition.x + finalJitterX,
        y = self.STATE.originalMousePosition.y + finalJitterY
    })

    hs.timer.usleep(math.random(config.randomizer.minPauseWhileShooting, config.randomizer.maxPauseWhileShooting))
end

function rifle:calculatePattern()
    local sensitivityMultiplier = config.game.sensitivity / 0.9
    local dpiMultiplier = 400 / config.game.dpi
    local resolutionMultiplier = 1440 / config.game.screenResolutionHeight
    
    local multiplier = sensitivityMultiplier * dpiMultiplier * resolutionMultiplier
    
    utils:log(string.format("[CALC] Multipliers: sensitivity=%.3f, DPI=%.3f, resolution=%.3f, total=%.3f",
        sensitivityMultiplier, dpiMultiplier, resolutionMultiplier, multiplier))
    
    local scaledPattern = {}
    
    for i, step in ipairs(patterns.assaultRifle) do
        local scaledStep = {
            dx = step.dx * multiplier,
            dy = step.dy * multiplier,
            delay = step.delay
        }
        table.insert(scaledPattern, scaledStep)
        
        if config.debug and i <= 5 then
            utils:log(string.format("[PATTERN] Step %d: dx=%.3f->%.3f, dy=%.3f->%.3f", 
                i, step.dx, scaledStep.dx, step.dy, scaledStep.dy))
        end
    end
    
    return scaledPattern
end

function rifle:init()
    print("[Rifle] Initializing RifleMacros (deterministic version)...")
    
    self.STATE.currentPattern = self:calculatePattern()
    self.STATE.patternLength = #self.STATE.currentPattern
    
    self:setupHotkeys()
    self:setupMouseDetection()
    
    print("[Rifle] Ready. Ctrl+F1 - toggle, Left Click in Rust - activation.")
    print("[Rifle] Using deterministic algorithm without randomization")
    hs.alert.show("RifleMacros ready (deterministic)", 1)
end

function rifle:setupHotkeys()
    hs.hotkey.bind({"ctrl"}, "f1", function()
        self:toggleSystem()
    end)
end

function rifle:detectGameMode()
    local rustApp = hs.application.get("Rust") or hs.application.get("RustClient")
    if rustApp then
        local mainWindow = rustApp:mainWindow()
        if mainWindow then
            self.STATE.isInGameMode = mainWindow:isFullScreen()
            if config.debug then
                utils:log(string.format("[MODE] Fullscreen mode: %s", 
                    tostring(self.STATE.isInGameMode)))
            end
        end
    else
        self.STATE.isInGameMode = false
    end
end

function rifle:resetState()
    self.STATE.stepIndex = 1
end

function rifle:toggleSystem()
    self.STATE.enabled = not self.STATE.enabled
    local status = self.STATE.enabled and "ON" or "OFF"
    print("[Rifle] System: " .. status)
    hs.alert.show("Macros: " .. status, 1)
    
    if not self.STATE.enabled then
        self:stopShooting()
        self:resetState()
    end
end

function rifle:setupMouseDetection()
    if self.mouseEventWatcher then
        self.mouseEventWatcher:stop()
    end
    
    self.mouseEventWatcher = hs.eventtap.new(
        { hs.eventtap.event.types.leftMouseDown, 
          hs.eventtap.event.types.leftMouseUp },
        function(event)
            if not self.STATE.enabled then return false end
            if not utils:isRustActive() then return false end
            
            local eventType = event:getType()
            
            if eventType == hs.eventtap.event.types.leftMouseDown then
                if not self.STATE.shooting then
                    utils:log("Left Click in Rust - start")
                    
                    self.STATE.originalMousePosition = hs.mouse.absolutePosition()
                    
                    self:resetState()
                    
                    self:detectGameMode()
                    
                    utils:log(string.format("[START] Position: %.0f, %.0f | Mode: %s",
                        self.STATE.originalMousePosition.x, self.STATE.originalMousePosition.y,
                        self.STATE.isInGameMode and "Game" or "Menu"))
                    
                    self:startShooting()
                end
                
            elseif eventType == hs.eventtap.event.types.leftMouseUp then
                if self.STATE.shooting then
                    utils:log("Left mouse button released - stop")
                    self:stopShooting()
                end
            end
            
            return false
        end
    )
    
    self.mouseEventWatcher:start()
    utils:log("Mouse detection enabled")
end

function rifle:startShooting()
    if not self.STATE.enabled or self.STATE.shooting or not utils:isRustActive() then 
        return 
    end
    
    self.STATE.shooting = true
    self.STATE.stepIndex = 1
    
    utils:log("=== SHOOTING STARTED ===")
    utils:log(string.format("Pattern length: %d steps, method: raw input only (randomized)", 
        self.STATE.patternLength))
    
    self.compensationTimer = hs.timer.new(0.04, function()
        if not self.STATE.shooting or not utils:isRustActive() then
            if self.compensationTimer then
                self.compensationTimer:stop()
            end
            return
        end
        
        self:compensationStep()
    end)
    
    self.compensationTimer:start()
end

function rifle:compensationStep()
    if not self.STATE.shooting or not utils:isRustActive() then
        return
    end
    
    local step = self.STATE.currentPattern[self.STATE.stepIndex]
    
    if not step then
        self.STATE.stepIndex = 1
        step = self.STATE.currentPattern[1]
    end
    
    if not self.STATE.isInGameMode then
        utils:log("[COMP] Rust closed, compensation not executed")
        return
    else
        self:rawInputMouseMove(step.dx, step.dy)
    end
    
    self.STATE.stepIndex = self.STATE.stepIndex + 1
    
    if self.STATE.stepIndex > self.STATE.patternLength then
        self.STATE.stepIndex = 1
        utils:log("[COMP] Pattern completed, starting over")
    end
end

function rifle:stopShooting()
    if not self.STATE.shooting then 
        return 
    end
    
    self.STATE.shooting = false
    
    if self.compensationTimer then
        self.compensationTimer:stop()
        self.compensationTimer = nil
    end
    
    utils:log("=== SHOOTING STOPPED ===")
    utils:log(string.format("Steps completed: %d", 
        self.STATE.stepIndex - 1))
    
    if self.STATE.originalMousePosition then
        hs.mouse.absolutePosition(self.STATE.originalMousePosition)
        utils:log("[STOP] Cursor returned")
    end
    
    self:resetState()
end

return rifle