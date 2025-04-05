local particle = {}

local assets = require("assets")
local config = require("config")

particle.config = {
    defaultScale = 0.5,
    defaultScaleDecay = 0.5,
    defaultRotation = 0,
    defaultVelocity = {x = 0, y = 0},
    defaultColor = {1, 1, 1, 1},
    defaultShadowOffset = 2
}

particle.active = {}

function particle.load()
    particle.shadowColor = assets.shadowColor
    particle.shadowOffset = config.visual.shadowOffset or particle.config.defaultShadowOffset
end

function particle.create(x, y, sprite, options)
    options = options or {}
    
    local p = {}
    p.x = x
    p.y = y
    p.sprite = sprite
    p.scale = options.scale or particle.config.defaultScale
    p.scaleDecay = options.scaleDecay or particle.config.defaultScaleDecay
    p.angle = options.angle or 0
    p.rotation = options.rotation or particle.config.defaultRotation
    p.vx = options.vx or particle.config.defaultVelocity.x
    p.vy = options.vy or particle.config.defaultVelocity.y
    p.shadowOffset = options.shadowOffset or particle.shadowOffset
    p.color = options.color or particle.config.defaultColor
    
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
    for _, p in ipairs(particle.active) do
        local px = math.floor(p.x)
        local py = math.floor(p.y)
        local ox = p.sprite:getWidth() / 2
        local oy = p.sprite:getHeight() / 2
        
        -- Make sure shadowOffset exists on the particle
        local shadowOffset = p.shadowOffset or particle.config.defaultShadowOffset
        
        love.graphics.setColor(particle.shadowColor)
        love.graphics.draw(
            p.sprite, 
            px + shadowOffset * p.scale, 
            py + shadowOffset * p.scale, 
            p.angle, 
            p.scale, 
            p.scale, 
            ox, 
            oy
        )
        
        love.graphics.setColor(p.color)
        love.graphics.draw(
            p.sprite, 
            px, 
            py, 
            p.angle, 
            p.scale, 
            p.scale, 
            ox, 
            oy
        )
    end
end

return particle
