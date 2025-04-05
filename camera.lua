local camera = {
    x = 0,
    y = 0,
    lerpFactor = 0.1  -- Controls how quickly the camera moves (0.1 = 10% of the distance per frame)
}

-- Helper function for linear interpolation
local function lerp(a, b, t)
    return a + (b - a) * t
end

function camera.load(config)
    camera.config = config
end

function camera.update(px, py)
    local sw = camera.config.screen.width
    local sh = camera.config.screen.height
    
    -- Calculate target position (center on player)
    local targetX = px - sw / 2
    local targetY = py - sh / 2
    
    -- Smoothly lerp to the target position
    camera.x = lerp(camera.x, targetX, camera.lerpFactor)
    camera.y = lerp(camera.y, targetY, camera.lerpFactor)
end

return camera
