local config = require("config")

local camera = {
    x = 0,
    y = 0,
    deadzoneMargin = 32,
    lerpFactor = 0.05
}

function camera.load(config)
    camera.config = config
    local sw = camera.config.screen.width
    local sh = camera.config.screen.height
    camera.x = camera.config.screen.width / 2 - sw / 2
    camera.y = 32 - sh / 2
end

function camera.update(px, py)
    local sw = camera.config.screen.width
    local sh = camera.config.screen.height

    local deadzoneWidth = config.screen.width - camera.deadzoneMargin * 2
    local deadzoneHeight = config.screen.height - camera.deadzoneMargin * 2
    camera.deadzone = {
        width = deadzoneWidth,
        height = deadzoneHeight
    }
    
    local left = camera.x + (sw - camera.deadzone.width) / 2
    local right = left + camera.deadzone.width
    local top = camera.y + (sh - camera.deadzone.height) / 2
    local bottom = top + camera.deadzone.height
    
    local targetX = camera.x
    local targetY = camera.y
    
    if px < left then
        targetX = camera.x + (px - left)
    elseif px > right then
        targetX = camera.x + (px - right)
    end
    
    if py < top then
        targetY = camera.y + (py - top)
    elseif py > bottom then
        targetY = camera.y + (py - bottom)
    end
    
    camera.x = camera.x + (targetX - camera.x) * camera.lerpFactor
    camera.y = camera.y + (targetY - camera.y) * camera.lerpFactor
end

function camera.drawDebug()
    love.graphics.setColor(1, 0, 0, 0.3)
    local deadzoneX = (camera.config.screen.width - camera.deadzone.width) / 2
    local deadzoneY = (camera.config.screen.height - camera.deadzone.height) / 2
    love.graphics.rectangle("fill", deadzoneX, deadzoneY, camera.deadzone.width, camera.deadzone.height)
    love.graphics.setColor(1, 1, 1, 1)
end

return camera
