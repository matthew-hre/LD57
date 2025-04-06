local config = require("config")
local camera = require("camera")

local utils = {}

function utils.tableContains(t, value)
    for _, v in ipairs(t) do
        if v == value then
            return true
        end
    end
    return false
end

local terrain = {}

terrain.tileSize = 1
terrain.width = 1024
terrain.height = 2048
terrain.tiles = {}

terrain.config = {
    emptyTopPercentage = 10,
    brushRadius = 32,
    smallCaveCount = 250,
    smallCaveMinRadius = 8,
    smallCaveMaxRadius = 24,
    blobsPerCave = 4,
    minBlobOffset = 0.4,
    maxBlobOffset = 0.8,
}

terrain.shadowBatch = nil
terrain.dirtBatch = nil
terrain.dirtQuad = nil
terrain.shadowQuad = nil
terrain.lastStartX = 0
terrain.lastStartY = 0
terrain.lastEndX = 0
terrain.lastEndY = 0
terrain.needsRebuild = true
terrain.visibleTiles = 0

function terrain.load()
    local pixelData = love.image.newImageData(1, 1)
    pixelData:setPixel(0, 0, 1, 1, 1, 1)
    local pixelTexture = love.graphics.newImage(pixelData)
    pixelTexture:setFilter("nearest", "nearest")
    
    terrain.dirtQuad = love.graphics.newQuad(0, 0, 1, 1, 1, 1)
    terrain.shadowQuad = love.graphics.newQuad(0, 0, 1, 1, 1, 1)
    
    terrain.shadowBatch = love.graphics.newSpriteBatch(pixelTexture, 10000, "dynamic")
    terrain.dirtBatch = love.graphics.newSpriteBatch(pixelTexture, 10000, "dynamic")
    
    terrain.generateTerrain()
    
    terrain.needsRebuild = true
end

function terrain.generateTerrain()
    terrain.tiles = {}
    for y = 1, terrain.height do
        terrain.tiles[y] = {}
        for x = 1, terrain.width do
            if y < terrain.height * 0.1 then
                terrain.tiles[y][x] = nil
            else
                terrain.tiles[y][x] = {type = "dirt"}
            end
        end
    end
    
    terrain.generateCaves()
end

function terrain.generateCaves()
    love.math.setRandomSeed(os.time())
    
    local terrainConfig = terrain.config
    local brushRadius = terrainConfig.brushRadius
    local emptyTopPercent = terrainConfig.emptyTopPercentage / 100
    
    local numSmallCaves = terrainConfig.smallCaveCount
    for i = 1, numSmallCaves do
        local mainX = love.math.random(0, terrain.width)
        local mainY = love.math.random(terrain.height * 0.15, terrain.height * 0.9)
        local mainRadius = love.math.random(terrainConfig.smallCaveMinRadius, terrainConfig.smallCaveMaxRadius)
        
        terrain.carveIrregularCave(mainX, mainY, mainRadius, terrainConfig.blobsPerCave, terrainConfig.maxBlobOffset)
    end
    
    terrain.needsRebuild = true
end

function terrain.carveIrregularCave(centerX, centerY, baseRadius, blobCount, maxOffset)
    terrain.carveCircle(centerX, centerY, baseRadius)
    
    for i = 1, blobCount do
        local angle = love.math.random() * math.pi * 2
        
        local minOffset = terrain.config.minBlobOffset
        local offsetDist = baseRadius * (minOffset + love.math.random() * (maxOffset - minOffset))
        
        local blobX = centerX + math.cos(angle) * offsetDist
        local blobY = centerY + math.sin(angle) * offsetDist
        
        local blobRadius = baseRadius * (0.6 + love.math.random() * 0.8)
        
        terrain.carveCircle(blobX, blobY, blobRadius)
    end
end

function terrain.carveIrregularPath(x1, y1, x2, y2, width)
    local dx = x2 - x1
    local dy = y2 - y1
    local dist = math.sqrt(dx*dx + dy*dy)
    
    if dist < 1 then return end
    
    dx = dx / dist
    dy = dy / dist
    
    local steps = math.floor(dist)
    
    for i = 0, steps do
        local t = i / steps
        local x = math.floor(x1 + dx * i)
        local y = math.floor(y1 + dy * i)
        
        local noiseAmp = width * 0.5
        local pathNoise = love.math.random(-noiseAmp, noiseAmp)
        local perpX = -dy
        local perpY = dx
        
        x = x + perpX * pathNoise
        y = y + perpY * pathNoise
        
        local pathWidth = width * (0.8 + love.math.random() * 0.4)
        terrain.carveCircle(x, y, pathWidth)
    end
end

function terrain.carveCircle(centerX, centerY, radius)
    local cx = math.floor(centerX)
    local cy = math.floor(centerY)
    local r = math.floor(radius)
    
    local startX = math.max(1, cx - r)
    local endX = math.min(terrain.width, cx + r)
    local startY = math.max(1, cy - r)
    local endY = math.min(terrain.height, cy + r)
    
    local r2 = r * r
    
    for y = startY, endY do
        for x = startX, endX do
            local dx = x - cx
            local dy = y - cy
            if dx*dx + dy*dy <= r2 then
                terrain.tiles[y][x] = nil
            end
        end
    end
end

function terrain.carvePath(x1, y1, x2, y2, width)
    local dx = x2 - x1
    local dy = y2 - y1
    local dist = math.sqrt(dx*dx + dy*dy)
    
    if dist < 1 then return end
    
    dx = dx / dist
    dy = dy / dist
    
    local steps = math.floor(dist)
    
    for i = 0, steps do
        local x = math.floor(x1 + dx * i)
        local y = math.floor(y1 + dy * i)
        
        local pathWidth = width * (0.8 + love.math.random() * 0.4)
        terrain.carveCircle(x, y, pathWidth)
    end
end

function terrain.worldToTile(x, y)
    local tx = math.max(1, math.min(terrain.width, math.floor(x / terrain.tileSize) + 1))
    local ty = math.max(1, math.min(terrain.height, math.floor(y / terrain.tileSize) + 1))
    return tx, ty
end

function terrain.digAt(x, y)
    local tx, ty = terrain.worldToTile(x, y)
    if tx >= 1 and tx <= terrain.width and ty >= 1 and ty <= terrain.height then
        if terrain.tiles[ty] and terrain.tiles[ty][tx] then
            local minedTile = terrain.tiles[ty][tx]
            terrain.tiles[ty][tx] = nil
            terrain.needsRebuild = true
            return minedTile
        end
    end
    return nil
end

function terrain.digCircle(cx, cy, radius)
    local rTiles = math.ceil(radius / terrain.tileSize)
    local centerX, centerY = terrain.worldToTile(cx, cy)
    local changed = false

    for ty = centerY - rTiles, centerY + rTiles do
        for tx = centerX - rTiles, centerX + rTiles do
            if tx >= 1 and tx <= terrain.width and ty >= 1 and ty <= terrain.height then
                local wx = (tx - 0.5) * terrain.tileSize
                local wy = (ty - 0.5) * terrain.tileSize
                local dist = math.sqrt((wx - cx)^2 + (wy - cy)^2)

                local jitter = (love.math.random() * 2) + 1

                if dist <= radius - jitter then
                    if terrain.tiles[ty] and terrain.tiles[ty][tx] then
                        terrain.tiles[ty][tx] = nil
                        changed = true
                    end
                end
            end
        end
    end
    
    if changed then
        terrain.needsRebuild = true
    end
end

function terrain.rebuildBatches(startX, startY, endX, endY)
    terrain.shadowBatch:clear()
    terrain.dirtBatch:clear()
    
    terrain.visibleTiles = 0
    
    startX = math.max(1, startX - 10)
    startY = math.max(1, startY - 10)
    endX = math.min(terrain.width, endX + 10)
    endY = math.min(terrain.height, endY + 10)
    
    terrain.lastStartX = startX
    terrain.lastStartY = startY
    terrain.lastEndX = endX
    terrain.lastEndY = endY
    
    for y = startY, endY do
        local row = terrain.tiles[y]
        if row then
            for x = startX, endX do
                if row[x] then
                    local px = (x - 1) * terrain.tileSize
                    local py = (y - 1) * terrain.tileSize
                    
                    terrain.shadowBatch:add(terrain.shadowQuad, px + 2, py + 2, 0, terrain.tileSize, terrain.tileSize)
                    
                    terrain.dirtBatch:add(terrain.dirtQuad, px, py, 0, terrain.tileSize, terrain.tileSize)
                    
                    terrain.visibleTiles = terrain.visibleTiles + 1
                end
            end
        end
    end
    
    terrain.needsRebuild = false
end

function terrain.draw()
    local startX, startY = terrain.worldToTile(camera.x, camera.y)
    local endX, endY = terrain.worldToTile(camera.x + config.screen.width, 
                                          camera.y + config.screen.height)
    
    love.graphics.setColor(config.visual.altGroundColor)
    love.graphics.rectangle("fill", camera.x, camera.y, config.screen.width, config.screen.height)
    
    if terrain.needsRebuild or 
       math.abs(startX - terrain.lastStartX) > 5 or 
       math.abs(startY - terrain.lastStartY) > 5 or
       math.abs(endX - terrain.lastEndX) > 5 or
       math.abs(endY - terrain.lastEndY) > 5 then
        terrain.rebuildBatches(startX, startY, endX, endY)
    end
    
    love.graphics.setColor(config.visual.gridColor)
    love.graphics.draw(terrain.shadowBatch)
    
    love.graphics.setColor(config.visual.groundColor)
    love.graphics.draw(terrain.dirtBatch)
end

function terrain.getVisibleTileCount()
    return terrain.visibleTiles
end

return terrain
