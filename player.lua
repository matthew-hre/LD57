local player = {}

local config = require("config")
local assets = require("assets")

player.config = {
    startX = config.screen.width / 2,
    startY = 32,
    
    speed = 100,
    maxSpeed = 200,
    acceleration = 400,
    deceleration = 200,

    turningRadius = 0.5,

    shadowOffset = 2,
}

function player.load()
    player.sprite = assets.playerSprite
    player.shadowColor = assets.shadowColor
    player.x = player.config.startX
    player.y = player.config.startY
    player.speed = player.config.speed
    player.maxSpeed = player.config.maxSpeed
    player.acceleration = player.config.acceleration
    player.deceleration = player.config.deceleration
    
    player.angle = 0
    player.angleOffset = 0
    player.angleSnapFactor = config.visual.angleSnapFactor
end

function player.draw()
    local px = math.floor(player.x)
    local py = math.floor(player.y)
    local ox = player.sprite:getWidth() / 2
    local oy = player.sprite:getHeight() / 2
    
    local angle = math.floor(player.angle * player.angleSnapFactor) / player.angleSnapFactor

    love.graphics.setColor(player.shadowColor)
    love.graphics.draw(
        player.sprite, 
        px + player.config.shadowOffset, 
        py + player.config.shadowOffset, 
        angle, 1, 1, ox, oy
    )

    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(player.sprite, px, py, angle, 1, 1, ox, oy)
end

return player