local player = {}

local config = require("config")
local assets = require("assets")
local camera = require("camera")

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

    player.vx = 0
    player.vy = 0
    player.mouseDown = false
    player.targetAngle = 0
end

function player.update(dt)
    local mx, my = love.mouse.getPosition()
    mx = mx / config.screen.scale
    my = my / config.screen.scale

    local dx = mx - player.x
    local dy = my - player.y
    local distance = math.sqrt(dx * dx + dy * dy)

    if player.mouseDown and distance > 4 then
        local dirX = dx / distance
        local dirY = dy / distance

        player.vx = player.vx + dirX * player.acceleration * dt
        player.vy = player.vy + dirY * player.acceleration * dt
    else
        -- Apply drag
        if not player.mouseDown then
            local speed = math.sqrt(player.vx * player.vx + player.vy * player.vy)
            if speed > 0 then
                local decelAmount = player.deceleration * dt
                local newSpeed = speed - decelAmount
                if newSpeed < 0 then newSpeed = 0 end
                local scale = newSpeed / speed
                player.vx = player.vx * scale
                player.vy = player.vy * scale
            end
        end
    end

    -- Clamp speed
    local speed = math.sqrt(player.vx * player.vx + player.vy * player.vy)
    if speed > player.maxSpeed then
        local scale = player.maxSpeed / speed
        player.vx = player.vx * scale
        player.vy = player.vy * scale
    end

    player.x = player.x + player.vx * dt
    player.y = player.y + player.vy * dt

    -- Face movement direction if moving
    if speed > 1 then
        player.angle = math.atan2(player.vy, player.vx)
    end
end


function player.draw()
    local px = math.floor(player.x - camera.x)
    local py = math.floor(player.y - camera.y)    
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