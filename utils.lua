-- ~/.hammerspoon/utils.lua
local config = require("config")

local utils = {}

function utils:isRustActive()
    local app = hs.application.frontmostApplication()
    return app and (app:name() == "Rust" or string.find(app:name() or "", "RustClient"))
end

function utils:log(msg)
    if not config.debug or not utils:isRustActive() then
        return
    end

    print("[Rifle] " .. msg)
end

return utils