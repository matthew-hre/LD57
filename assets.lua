local assets = {}

local config = require("config")

function assets.load()
    assets.playerSprite = love.graphics.newImage("assets/player.png")

    -- Create a simple particle sprite
    local particleSize = 4
    local particleCanvas = love.graphics.newCanvas(particleSize, particleSize)
    love.graphics.setCanvas(particleCanvas)
    love.graphics.clear()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("fill", 0, 0, particleSize, particleSize)
    love.graphics.setCanvas()
    assets.particleSprite = particleCanvas
    
    assets.fonts = {}
    assets.fonts.fat = love.graphics.newFont("assets/fonts/fat.ttf", 16)
    assets.fonts.fat:setFilter("nearest", "nearest")

    assets.fonts.m5x7 = love.graphics.newFont("assets/fonts/m5x7.ttf", 16)
    assets.fonts.m5x7:setFilter("nearest", "nearest")
    
    assets.shadowColor = config.visual.shadowColor
end

return assets
