-- ~/.hammerspoon/rifle_macros.lua
local rifle = {}

rifle.CONFIG = {
    debug = true,
    
    sensitivity = 0.6,          
    fov = 90, 
    dpi = 800, --[[ or 1500 ]]
    screenResolutionHeight = 1600,           
    
    basePattern = {
        {dx = 1,  dy = 10,  delay = 31}, 
        {dx = 1,  dy = 10,  delay = 31}, 
        {dx = 1,  dy = 10,  delay = 31}, 
        {dx = 1,  dy = 10,  delay = 31}, 
        {dx = 1,  dy = 10,  delay = 31}, 
        {dx = 1,  dy = 10,  delay = 31}, 
        {dx = 1,  dy = 10,  delay = 31},    
        {dx = 1,  dy = 10,  delay = 31},  
        {dx = 1,  dy = 10,  delay = 31},    
        {dx = 1,  dy = 10,  delay = 31},   
        {dx = 1,  dy = 10,  delay = 31},  
        {dx = 1,  dy = 10,  delay = 31},   
        {dx = 1,  dy = 10,  delay = 31},    
        {dx = 1,  dy = 10,  delay = 31},     
        {dx = 1,  dy = 10,  delay = 31},    
        {dx = 1,  dy = 10,  delay = 31},    
        {dx = 1,  dy = 10,  delay = 31},  
        {dx = 1,  dy = 10,  delay = 31},  
        {dx = 1,  dy = 10,  delay = 31},  
        {dx = 1,  dy = 10,  delay = 31},
        {dx = 1,  dy = 10,  delay = 31},  
        {dx = 1,  dy = 10,  delay = 31},   
        {dx = 1,  dy = 10,  delay = 31},   
        {dx = 1,  dy = 10,  delay = 31},   
        {dx = 1,  dy = 10,  delay = 31},  
        {dx = 1,  dy = 10,  delay = 31},    
        {dx = 1,  dy = 10,  delay = 31},    
        {dx = 1,  dy = 10,  delay = 31},    
        {dx = 1,  dy = 10,  delay = 31},    
        {dx = 1,  dy = 10,  delay = 31},    
        {dx = 1,  dy = 10,  delay = 31},    
        {dx = 1,  dy = 10,  delay = 31},    
        {dx = 1,  dy = 10,  delay = 31}, 
        {dx = 1,  dy = 10,  delay = 31}, 
        {dx = 1,  dy = 10,  delay = 31}, 
        {dx = 1,  dy = 10,  delay = 31}, 
        {dx = 1,  dy = 10,  delay = 31}, 
        {dx = 1,  dy = 10,  delay = 31}, 
        {dx = 1,  dy = 10,  delay = 31}, 
        {dx = 1,  dy = 10,  delay = 31}, 
        {dx = 1,  dy = 10,  delay = 31}, 
        {dx = 1,  dy = 10,  delay = 31}, 
        {dx = 1,  dy = 10,  delay = 31}, 
        {dx = 1,  dy = 10,  delay = 31}, 
        {dx = 1,  dy = 10,  delay = 31}, 
        {dx = 1,  dy = 10,  delay = 31}, 
        {dx = 1,  dy = 10,  delay = 31}, 
        {dx = 1,  dy = 10,  delay = 31}, 
        {dx = 1,  dy = 10,  delay = 31}, 
        {dx = 1,  dy = 10,  delay = 31}, 
        {dx = 1,  dy = 10,  delay = 31}, 
        {dx = 1,  dy = 10,  delay = 31}, 
        {dx = 1,  dy = 10,  delay = 31}, 
        {dx = 1,  dy = 10,  delay = 31}, 
        {dx = 1,  dy = 10,  delay = 31}, 
        {dx = 1,  dy = 10,  delay = 31}, 
        {dx = 1,  dy = 10,  delay = 31}, 
        {dx = 1,  dy = 10,  delay = 31}, 
        {dx = 1,  dy = 10,  delay = 31}, 
        {dx = 1,  dy = 10,  delay = 31}, 
        {dx = 1,  dy = 10,  delay = 31}, 
        {dx = 1,  dy = 10,  delay = 31}, 
        {dx = 1,  dy = 10,  delay = 31}, 
        {dx = 1,  dy = 10,  delay = 31}, 
        {dx = 1,  dy = 10,  delay = 31}, 
        {dx = 1,  dy = 10,  delay = 31}, 
        {dx = 1,  dy = 10,  delay = 31}, 
        {dx = 1,  dy = 10,  delay = 31}, 
        {dx = 1,  dy = 10,  delay = 31}, 
        {dx = 1,  dy = 10,  delay = 31}, 
        {dx = 1,  dy = 10,  delay = 31}, 
        {dx = 1,  dy = 10,  delay = 31}, 
        {dx = 1,  dy = 10,  delay = 31}, 
        {dx = 1,  dy = 10,  delay = 31}, 
        {dx = 1,  dy = 10,  delay = 31}, 
        {dx = 1,  dy = 10,  delay = 31}, 
    },
    
    activationSequence = {
        --[[ {dx = 1,  dy = 0}, 
        {dx = 0,  dy = 1}, 
        {dx = -1, dy = 0}, 
        {dx = 0,  dy = -1} ]]
    },
    
    calibrationSequence = {
        --[[ {dx = 0,  dy = 0,  delay = 20},   
        {dx = 1,  dy = 0,  delay = 20},   
        {dx = -1, dy = 0,  delay = 20},   
        {dx = 0,  dy = 1,  delay = 20},   
        {dx = 0,  dy = -1, delay = 20},   
        {dx = 0,  dy = 0,  delay = 20}  ]]
    }
}

rifle.STATE = {
    enabled = false,   
    shooting = false,    
    stepIndex = 1,      
    patternLength = 30,  
    currentPattern = {},  
    originalMousePosition = nil,
    compensationTimer = nil,
    isInGameMode = false,
    rawInputActivated = false,
    activationTimer = nil,
    activationCounter = 0,
    currentMethod = 1,
    calibrationStep = 1
}

local function isRustActive()
    local app = hs.application.frontmostApplication()
    return app and (app:name() == "Rust" or string.find(app:name() or "", "RustClient"))
end

function rifle:log(msg)
    if self.CONFIG.debug and isRustActive() then
        print("[Rifle] " .. msg)
    end
end

function rifle:activateRawInput()
    if not self.STATE.originalMousePosition then return end
    
    self:log("[ACTIVATE] Standard raw input activation")
    
    local currentPos = hs.mouse.absolutePosition()
    
    for i, move in ipairs(self.CONFIG.activationSequence) do
        if not self.STATE.shooting then break end
        
        local event = hs.eventtap.event.newMouseEvent(
            hs.eventtap.event.types.mouseMoved,
            {x = currentPos.x + move.dx, y = currentPos.y + move.dy}
        )
        
        event:setFlags({})
        event:setProperty(hs.eventtap.event.properties.mouseEventDeltaX, move.dx)
        event:setProperty(hs.eventtap.event.properties.mouseEventDeltaY, move.dy)
        
        event:post()
        hs.timer.usleep(5000)
        hs.mouse.absolutePosition(currentPos)
        hs.timer.usleep(5000)
    end
    
    self.STATE.rawInputActivated = true
    self.STATE.activationCounter = self.STATE.activationCounter + 1
    
    self:log(string.format("[ACTIVATE] Raw input activated (activations: %d)", 
        self.STATE.activationCounter))
end

function rifle:rawInputMouseMove(dx, dy)
    if not self.STATE.originalMousePosition then return end
    
    local currentPos = hs.mouse.absolutePosition()
    
    local event = hs.eventtap.event.newMouseEvent(
        hs.eventtap.event.types.mouseMoved,
        {x = currentPos.x + dx, y = currentPos.y + dy}
    )
    
    event:setFlags({})
    event:setProperty(hs.eventtap.event.properties.mouseEventDeltaX, math.floor(dx * 10))
    event:setProperty(hs.eventtap.event.properties.mouseEventDeltaY, math.floor(dy * 10))
    event:setProperty(hs.eventtap.event.properties.mouseEventSubtype, 0)
    
    event:post()
    hs.timer.usleep(1000)
    
    hs.mouse.absolutePosition({
        x = currentPos.x + (dx * 0.01),
        y = currentPos.y + (dy * 0.01)
    })
    
    hs.timer.usleep(2000)
    hs.mouse.absolutePosition(self.STATE.originalMousePosition)
    
    if self.CONFIG.debug and isRustActive() then
        self:log(string.format("[RAW] Step %d: dx=%.2f, dy=%.2f", 
            self.STATE.stepIndex, dx, dy))
    end
end

function rifle:lowLevelMouseMove(dx, dy)
    if not self.STATE.originalMousePosition then return end
    
    local currentPos = hs.mouse.absolutePosition()
    
    local enhancedDx = dx * 0.05
    local enhancedDy = dy * 0.05
    
    local event = hs.eventtap.event.newEvent()
    event:setType(hs.eventtap.event.types.mouseMoved)
    event:location({x = currentPos.x, y = currentPos.y})
    
    event:setProperty(hs.eventtap.event.properties.mouseEventDeltaX, math.floor(enhancedDx))
    event:setProperty(hs.eventtap.event.properties.mouseEventDeltaY, math.floor(enhancedDy))
    event:setFlags({})
    
    event:post()
    
    hs.timer.usleep(2000)
    
    hs.mouse.absolutePosition({
        x = currentPos.x + (dx * 0.02),
        y = currentPos.y + (dy * 0.02)
    })
    
    hs.timer.usleep(2000)
    hs.mouse.absolutePosition(self.STATE.originalMousePosition)
    
    if self.CONFIG.debug and isRustActive() then
        self:log(string.format("[LOW] Step %d: dx=%.2f, dy=%.2f", 
            self.STATE.stepIndex, dx, dy))
    end
end

function rifle:standardMouseMove(dx, dy)
    if not self.STATE.originalMousePosition then return end
    
    local methodToUse = (self.STATE.stepIndex % 2) + 1
    
    if methodToUse == 1 then
        self:rawInputMouseMove(dx, dy)
    else
        self:lowLevelMouseMove(dx, dy)
    end
    
    self.STATE.currentMethod = methodToUse
end

function rifle:performCalibration()
    if not self.STATE.originalMousePosition then return end
    
    self:log("[CALIBRATION] Standard calibration started")
    
    local startPos = self.STATE.originalMousePosition
    
    for i, calib in ipairs(self.CONFIG.calibrationSequence) do
        if not self.STATE.shooting then break end
        
        self.STATE.calibrationStep = i
        
        hs.mouse.absolutePosition({
            x = startPos.x + calib.dx,
            y = startPos.y + calib.dy
        })
        
        hs.timer.usleep(calib.delay * 1000)
        
        hs.mouse.absolutePosition(startPos)
        
        if self.CONFIG.debug then
            self:log(string.format("[CALIB] Step %d/%d: dx=%d, dy=%d", 
                i, #self.CONFIG.calibrationSequence, calib.dx, calib.dy))
        end
    end
    
    hs.mouse.absolutePosition(self.STATE.originalMousePosition)
    hs.timer.usleep(20000)
    
    self:log("[CALIBRATION] Calibration completed")
    self.STATE.calibrationStep = 1
end

function rifle:startActivationTimer()
    if self.STATE.activationTimer then
        self.STATE.activationTimer:stop()
    end
    
    self.STATE.activationTimer = hs.timer.new(1.5, function()
        if self.STATE.shooting and self.STATE.isInGameMode then
            self:activateRawInput()
        end
    end)
    
    self.STATE.activationTimer:start()
    self:log("[TIMER] Activation timer started (interval: 1.5s)")
end

function rifle:stopActivationTimer()
    if self.STATE.activationTimer then
        self.STATE.activationTimer:stop()
        self.STATE.activationTimer = nil
    end
    
    self.STATE.rawInputActivated = false
    self.STATE.activationCounter = 0
end

function rifle:calculatePattern()
    local sensitivityMultiplier = rifle.CONFIG.sensitivity / 0.9
    local dpiMultiplier = 400 / rifle.CONFIG.dpi
    local resolutionMultiplier = 1440 / rifle.CONFIG.screenResolutionHeight
    
    local multiplier = sensitivityMultiplier * dpiMultiplier * resolutionMultiplier
    
    self:log(string.format("[CALC] Multipliers: sensivity=%.3f, DPI=%.3f, resolution=%.3f, total=%.3f",
        sensitivityMultiplier, dpiMultiplier, resolutionMultiplier, multiplier))
    
    local scaledPattern = {}
    
    for i, step in ipairs(self.CONFIG.basePattern) do
        local scaledStep = {
            dx = step.dx * multiplier,
            dy = step.dy * multiplier,
            delay = step.delay
        }
        table.insert(scaledPattern, scaledStep)
        
        if self.CONFIG.debug and i <= 5 then
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
            if self.CONFIG.debug then
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
    self.STATE.currentMethod = 1
    self.STATE.calibrationStep = 1
    self:stopActivationTimer()
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
    self.STATE.currentMethod = 1
    
    self:log("=== SHOOTING STARTED ===")
    self:log(string.format("Pattern length: %d steps, method: alternating", 
        self.STATE.patternLength))
    
    self:performCalibration()
    
    if self.STATE.isInGameMode then
        self:startActivationTimer()
        
        hs.timer.doAfter(0.1, function()
            if self.STATE.shooting then
                self:activateRawInput()
            end
        end)
    end
    
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
    if not self.STATE.shooting or not isRustActive() then return end
    
    local step = self.STATE.currentPattern[self.STATE.stepIndex]
    
    if not step then
        self.STATE.stepIndex = 1
        step = self.STATE.currentPattern[1]
    end
    
    if self.STATE.isInGameMode then
        self:standardMouseMove(step.dx, step.dy)
    else
        self:log("[COMP] Rust closed, compensation not executed")
        return
    end
    
    self.STATE.stepIndex = self.STATE.stepIndex + 1
    
    if self.STATE.stepIndex > self.STATE.patternLength then
        self.STATE.stepIndex = 1
        self.STATE.currentMethod = 1
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
    
    self:stopActivationTimer()
    
    self:log("=== SHOOTING STOPPED ===")
    self:log(string.format("Steps completed: %d, activations: %d", 
        self.STATE.stepIndex - 1, self.STATE.activationCounter))
    
    if self.STATE.originalMousePosition then
        hs.mouse.absolutePosition(self.STATE.originalMousePosition)
        self:log("[STOP] Cursor returned")
    end
    
    self:resetState()
end

return rifle