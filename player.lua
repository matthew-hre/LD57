local player = {}

local config = require("config")
local assets = require("assets")
local camera = require("camera")
local particle = require("particle")

player.config = {
    startX = config.screen.width / 2,
    startY = 32,
    
    speed = 100,
    maxSpeed = 200,
    acceleration = 400,
    deceleration = 200,

    turningRadius = 0.5,

    shadowOffset = 2,
    
    particleSpawnRate = 0.05,
    exhaustParticleSpeed = 40,
    topParticleSpeed = 20,
    particleScale = 0.7,
    particleScaleDecay = 1.5,
}

function player.load()
    player.sprite = assets.playerSprite
    player.particleSprite = assets.particleSprite
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
    
    -- Particle timing
    player.particleTimer = 0
    player.width = player.sprite:getWidth()
    player.height = player.sprite:getHeight()
end

function player.update(dt)
    local mx, my = love.mouse.getPosition()
    mx = mx / config.screen.scale + camera.x
    my = my / config.screen.scale + camera.y

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
        
        -- Spawn particles when moving
        player.particleTimer = player.particleTimer - dt
        if player.particleTimer <= 0 then
            player.spawnParticles(speed)
            player.particleTimer = player.config.particleSpawnRate
        end
    end
end

function player.spawnParticles(speed)
    local halfWidth = player.width / 2
    local halfHeight = player.height / 2
    local speedRatio = speed / player.maxSpeed
    
    local angleOffset = math.pi / 4
    
    local leftCornerAngle = player.angle + math.pi + angleOffset
    local leftCornerX = player.x + math.cos(leftCornerAngle) * halfWidth * 0.8
    local leftCornerY = player.y + math.sin(leftCornerAngle) * halfHeight * 0.8
    
    local rightCornerAngle = player.angle + math.pi - angleOffset
    local rightCornerX = player.x + math.cos(rightCornerAngle) * halfWidth * 0.8
    local rightCornerY = player.y + math.sin(rightCornerAngle) * halfHeight * 0.8
    
    local topCenterAngle = player.angle - math.pi/2
    local topCenterX = player.x + math.cos(topCenterAngle) * halfHeight * 0.5
    local topCenterY = player.y + math.sin(topCenterAngle) * halfHeight * 0.5
    
    local exhaustSpeed = player.config.exhaustParticleSpeed * speedRatio
    
    local particleAngle = player.angle + math.pi  -- Opposite of movement direction
    particle.create(leftCornerX, leftCornerY, player.particleSprite, {
        vx = -player.vx * 0.2 + math.cos(particleAngle) * exhaustSpeed,
        vy = -player.vy * 0.2 + math.sin(particleAngle) * exhaustSpeed,
        scale = player.config.particleScale * (0.7 + 0.3 * speedRatio),
        scaleDecay = player.config.particleScaleDecay,
        color = config.visual.altGroundColor
    })
    
    -- Right back corner particle
    particle.create(rightCornerX, rightCornerY, player.particleSprite, {
        vx = -player.vx * 0.2 + math.cos(particleAngle) * exhaustSpeed,
        vy = -player.vy * 0.2 + math.sin(particleAngle) * exhaustSpeed,
        scale = player.config.particleScale * (0.7 + 0.3 * speedRatio),
        scaleDecay = player.config.particleScaleDecay,
        color = config.visual.altGroundColor
    })
    
    -- Spawn particles from top center (spray in all directions)
    local topParticleSpeed = player.config.topParticleSpeed * speedRatio
    local randomAngle = math.random() * math.pi * 2  -- Random direction (0-360 degrees)
    particle.create(topCenterX, topCenterY, player.particleSprite, {
        vx = math.cos(randomAngle) * topParticleSpeed,
        vy = math.sin(randomAngle) * topParticleSpeed,
        scale = player.config.particleScale * 0.6 * speedRatio,
        scaleDecay = player.config.particleScaleDecay,
        color = config.visual.altGroundColor
    })
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