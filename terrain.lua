-- terrain.lua
local config = require("config")

local terrain = {}

terrain.tileSize = 2
terrain.width = 256
terrain.height = 512
terrain.tiles = {}

function terrain.load()
    for y = 1, terrain.height do
        terrain.tiles[y] = {}
        for x = 1, terrain.width do
            terrain.tiles[y][x] = "dirt"
        end
    end
end

function terrain.worldToTile(x, y)
    -- Ensure values right at the edge are included by using math.max to prevent negative indices
    -- and clamping the result to be within bounds
    local tx = math.max(1, math.min(terrain.width, math.floor(x / terrain.tileSize) + 1))
    local ty = math.max(1, math.min(terrain.height, math.floor(y / terrain.tileSize) + 1))
    return tx, ty
end

function terrain.digAt(x, y)
    local tx, ty = terrain.worldToTile(x, y)
    if tx >= 1 and tx <= terrain.width and ty >= 1 and ty <= terrain.height then
        if terrain.tiles[ty] and terrain.tiles[ty][tx] == "dirt" then
            terrain.tiles[ty][tx] = nil
        end
    end
end

function terrain.digCircle(cx, cy, radius)
    local rTiles = math.ceil(radius / terrain.tileSize)
    local centerX, centerY = terrain.worldToTile(cx, cy)

    for ty = centerY - rTiles, centerY + rTiles do
        for tx = centerX - rTiles, centerX + rTiles do
            -- Skip tiles outside bounds
            if tx >= 1 and tx <= terrain.width and ty >= 1 and ty <= terrain.height then
                local wx = (tx - 0.5) * terrain.tileSize
                local wy = (ty - 0.5) * terrain.tileSize
                local dist = math.sqrt((wx - cx)^2 + (wy - cy)^2)

                local jitter = (love.math.random() * 2) + 1

                if dist <= radius - jitter then
                    if terrain.tiles[ty] and terrain.tiles[ty][tx] == "dirt" then
                        terrain.tiles[ty][tx] = nil
                    end
                end
            end
        end
    end
end

function terrain.draw()
    love.graphics.setColor(config.visual.altGroundColor)
    love.graphics.rectangle("fill", 0, 0, terrain.width * terrain.tileSize, terrain.height * terrain.tileSize)

    -- Render only the tiles that exist (dirt)
    for y = 1, terrain.height do
        for x = 1, terrain.width do
            if terrain.tiles[y][x] == "dirt" then
                local px = (x - 1) * terrain.tileSize
                local py = (y - 1) * terrain.tileSize

                -- Shadow
                love.graphics.setColor(config.visual.gridColor)
                love.graphics.rectangle("fill", px + 2, py + 2, terrain.tileSize, terrain.tileSize)

                -- Foreground dirt
                love.graphics.setColor(config.visual.groundColor)
                love.graphics.rectangle("fill", px, py, terrain.tileSize, terrain.tileSize)
            end
        end
    end
end

return terrain
