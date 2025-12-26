-- ~/.hammerspoon/config.lua

local config = {
    debug = true,

    game = {
        sensitivity = 0.6,          
        fov = 90, 
        dpi = 800,      
        screenResolutionHeight = 1600
    },

    randomizer = {
        smoothness = 2, --[[ How many parts step will be divided, 2 or 3 are enough ]]

        minMultiplierRandomizer = 90,
        maxMultiplierRandomizer = 110,

        minXNoise = -50,
        maxXNoise = 50,

        minMicroStepPause = 400,
        maxMicroStepPause = 700,

        minFinalJytter = -2,
        maxFinalJytter = 2,

        minPauseWhileShooting = 1500,
        maxPauseWhileShooting = 3000,
    }
}

return config