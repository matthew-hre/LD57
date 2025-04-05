local config = require("config")

local camera = {
    x = 0,
    y = 0,
    deadzoneMargin = 48,
    lerpFactor = 0.5,
    terrainWidth = 0,
    terrainHeight = 0,
    tileSize = 0
}

function camera.load(config)
    camera.config = config
    local sw = camera.config.screen.width
    local sh = camera.config.screen.height
    

    camera.x = 0
    camera.y = 0
end

function camera.setTerrainDimensions(width, height, tileSize)
    camera.terrainWidth = width
    camera.terrainHeight = height
    camera.tileSize = tileSize
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
    
    if camera.terrainWidth > 0 and camera.terrainHeight > 0 and camera.tileSize > 0 then
        camera.x = camera.clampToBounds(camera.x, camera.config.screen.width, camera.terrainWidth * camera.tileSize)
        camera.y = camera.clampToBounds(camera.y, camera.config.screen.height, camera.terrainHeight * camera.tileSize)
    end
end

function camera.clampToBounds(value, viewSize, maxSize)
    local minAllowed = 0
    local maxAllowed = maxSize - viewSize
    
    if viewSize >= maxSize then
        return (maxSize - viewSize) / 2
    end
    
    if value < minAllowed then 
        return minAllowed 
    elseif value > maxAllowed then 
        return maxAllowed 
    else 
        return value 
    end
end

function camera.drawDebug()
    love.graphics.setColor(1, 0, 0, 0.3)
    local deadzoneX = (camera.config.screen.width - camera.deadzone.width) / 2
    local deadzoneY = (camera.config.screen.height - camera.deadzone.height) / 2
    love.graphics.rectangle("fill", deadzoneX, deadzoneY, camera.deadzone.width, camera.deadzone.height)
    love.graphics.setColor(1, 1, 1, 1)
    
    if camera.terrainWidth > 0 and camera.terrainHeight > 0 and camera.tileSize > 0 then
        love.graphics.setColor(0, 1, 0, 0.3)
        love.graphics.rectangle("line", 0, 0, camera.terrainWidth * camera.tileSize, camera.terrainHeight * camera.tileSize)
        love.graphics.setColor(1, 1, 1, 1)
    end
end

return camera
