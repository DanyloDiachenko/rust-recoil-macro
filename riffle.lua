-- ~/.hammerspoon/rifle.lua
local patterns = require("patterns.lua")
local utils = require("utils.lua")
local config = require("config.lua")

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
    
    local currentPosition = hs.mouse.absolutePosition()
    
    local event = hs.eventtap.event.newMouseEvent(
        hs.eventtap.event.types.mouseMoved,
        {x = currentPosition.x + dx, y = currentPosition.y + dy}
    )
    
    event:setFlags({})
    event:setProperty(hs.eventtap.event.properties.mouseEventDeltaX, math.floor(dx * 10))
    event:setProperty(hs.eventtap.event.properties.mouseEventDeltaY, math.floor(dy * 10))
    event:setProperty(hs.eventtap.event.properties.mouseEventSubtype, 0)
    
    event:post()
    hs.timer.usleep(1000)
    
    hs.mouse.absolutePosition({
        x = currentPosition.x + (dx * 0.01),
        y = currentPosition.y + (dy * 0.01)
    })
    
    hs.timer.usleep(2000)
    hs.mouse.absolutePosition(self.STATE.originalMousePosition)
    
    if config.debug and utils:isRustActive() then
        self:log(string.format("[RAW] Step %d: dx=%.2f, dy=%.2f", 
            self.STATE.stepIndex, dx, dy))
    end
end

function rifle:standardMouseMove(dx, dy)
    if not self.STATE.originalMousePosition then
        return
    end
    
    self:rawInputMouseMove(dx, dy)
end

function rifle:calculatePattern()
    local sensitivityMultiplier = config.game.sensitivity / 0.9
    local dpiMultiplier = 400 / config.game.dpi
    local resolutionMultiplier = 1440 / config.game.screenResolutionHeight
    
    local multiplier = sensitivityMultiplier * dpiMultiplier * resolutionMultiplier
    
    self:log(string.format("[CALC] Multipliers: sensivity=%.3f, DPI=%.3f, resolution=%.3f, total=%.3f",
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
            self:log(string.format("[PATTERN] Step %d: dx=%.3f->%.3f, dy=%.3f->%.3f", 
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
                self:log(string.format("[MODE] Fullscreen mode: %s", 
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
            if not isRustActive() then return false end
            
            local eventType = event:getType()
            
            if eventType == hs.eventtap.event.types.leftMouseDown then
                if not self.STATE.shooting then
                    self:log("Left Click in Rust - start")
                    
                    self.STATE.originalMousePosition = hs.mouse.absolutePosition()
                    
                    self:resetState()
                    
                    self:detectGameMode()
                    
                    self:log(string.format("[START] Position: %.0f, %.0f | Mode: %s",
                        self.STATE.originalMousePosition.x, self.STATE.originalMousePosition.y,
                        self.STATE.isInGameMode and "Game" or "Menu"))
                    
                    self:startShooting()
                end
                
            elseif eventType == hs.eventtap.event.types.leftMouseUp then
                if self.STATE.shooting then
                    self:log("Left mouse button released - stop")
                    self:stopShooting()
                end
            end
            
            return false
        end
    )
    
    self.mouseEventWatcher:start()
    self:log("Mouse detection enabled")
end

function rifle:startShooting()
    if not self.STATE.enabled or self.STATE.shooting or not isRustActive() then 
        return 
    end
    
    self.STATE.shooting = true
    self.STATE.stepIndex = 1
    
    self:log("=== SHOOTING STARTED ===")
    self:log(string.format("Pattern length: %d steps, method: alternating", 
        self.STATE.patternLength))
    
    self.compensationTimer = hs.timer.new(0.04, function()
        if not self.STATE.shooting or not isRustActive() then
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
    if not self.STATE.shooting or not isRustActive() then
        return
    end
    
    local step = self.STATE.currentPattern[self.STATE.stepIndex]
    
    if not step then
        self.STATE.stepIndex = 1
        step = self.STATE.currentPattern[1]
    end
    
    if not self.STATE.isInGameMode then
        self:log("[COMP] Rust closed, compensation not executed")
        return
    else
        self:standardMouseMove(step.dx, step.dy)
    end
    
    self.STATE.stepIndex = self.STATE.stepIndex + 1
    
    if self.STATE.stepIndex > self.STATE.patternLength then
        self.STATE.stepIndex = 1
        self:log("[COMP] Pattern completed, starting over")
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
    
    self:log("=== SHOOTING STOPPED ===")
    self:log(string.format("Steps completed: %d", 
        self.STATE.stepIndex - 1))
    
    if self.STATE.originalMousePosition then
        hs.mouse.absolutePosition(self.STATE.originalMousePosition)
        self:log("[STOP] Cursor returned")
    end
    
    self:resetState()
end

return rifle