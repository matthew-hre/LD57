local particle = {}
local assets = require("assets")
local config = require("config")
local camera = require("camera")

particle.config = {
    defaultScale = 0.5,
    defaultScaleDecay = 0.5,
    defaultRotation = 0,
    defaultVelocity = {x = 0, y = 0},
    defaultColor = {1, 1, 1, 1},
    defaultShadowOffset = 2,
    maxParticles = 1000
}

particle.active = {}
particle.spriteBatches = {}
particle.visibleCount = 0

function particle.load()
    particle.shadowColor = assets.shadowColor
    particle.shadowOffset = config.visual.shadowOffset or particle.config.defaultShadowOffset
    particle.spriteBatches = {}
end

function particle.create(x, y, sprite, options)
    if #particle.active >= particle.config.maxParticles then
        table.remove(particle.active, 1)
    end
    
    options = options or {}
    
    local p = {
        x = x,
        y = y,
        sprite = sprite,
        scale = options.scale or particle.config.defaultScale,
        scaleDecay = options.scaleDecay or particle.config.defaultScaleDecay,
        angle = options.angle or 0,
        rotation = options.rotation or particle.config.defaultRotation,
        vx = options.vx or particle.config.defaultVelocity.x,
        vy = options.vy or particle.config.defaultVelocity.y,
        shadowOffset = options.shadowOffset or particle.shadowOffset,
        color = options.color or particle.config.defaultColor,
        spriteKey = tostring(sprite)
    }
    
    if not particle.spriteBatches[p.spriteKey] then
        particle.spriteBatches[p.spriteKey] = {
            main = love.graphics.newSpriteBatch(sprite, 100, "dynamic"),
            shadow = love.graphics.newSpriteBatch(sprite, 100, "dynamic")
        }
    end
    
    table.insert(particle.active, p)
    return p
end

function particle.update(dt)
    for i = #particle.active, 1, -1 do
        local p = particle.active[i]
        
        p.x = p.x + p.vx * dt
        p.y = p.y + p.vy * dt
        
        if p.rotation ~= 0 then
            p.angle = p.angle + p.rotation * dt
        end
        
        p.scale = p.scale - p.scaleDecay * dt
        
        if p.scale <= 0 then
            table.remove(particle.active, i)
        end
    end
end

function particle.draw()
    particle.visibleCount = 0
    
    for _, batchInfo in pairs(particle.spriteBatches) do
        batchInfo.main:clear()
        batchInfo.shadow:clear()
    end
    
    local minX = camera.x - 10
    local minY = camera.y - 10
    local maxX = camera.x + config.screen.width + 10
    local maxY = camera.y + config.screen.height + 10
    
    for _, p in ipairs(particle.active) do
        if p.x + p.sprite:getWidth() * p.scale >= minX and 
           p.x - p.sprite:getWidth() * p.scale <= maxX and 
           p.y + p.sprite:getHeight() * p.scale >= minY and 
           p.y - p.sprite:getHeight() * p.scale <= maxY then
            
            local px = math.floor(p.x)
            local py = math.floor(p.y)
            local ox = p.sprite:getWidth() / 2
            local oy = p.sprite:getHeight() / 2
            local shadowOffset = p.shadowOffset or particle.config.defaultShadowOffset
            
            particle.spriteBatches[p.spriteKey].shadow:setColor(particle.shadowColor)
            particle.spriteBatches[p.spriteKey].shadow:add(
                px + shadowOffset * p.scale, 
                py + shadowOffset * p.scale, 
                p.angle, 
                p.scale, 
                p.scale, 
                ox, 
                oy
            )
            
            particle.spriteBatches[p.spriteKey].main:setColor(p.color)
            particle.spriteBatches[p.spriteKey].main:add(
                px, 
                py, 
                p.angle, 
                p.scale, 
                p.scale, 
                ox, 
                oy
            )
            
            particle.visibleCount = particle.visibleCount + 1
        end
    end
    
    for _, batchInfo in pairs(particle.spriteBatches) do
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(batchInfo.shadow)
        
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(batchInfo.main)
    end
end

function particle.getStats()
    return {
        total = #particle.active,
        visible = particle.visibleCount,
        batches = #particle.spriteBatches
    }
end

return particle
