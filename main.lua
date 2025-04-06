local config = require("config")
local assets = require("assets")
local particle = require("particle")
local terrain = require("terrain")
local player = require("player")
local camera = require("camera")

local canvas
local debugMode = false
local gridSize = 32
local debugFont
local fpsHistory = {}
local maxFpsHistory = 60
local performanceMetrics = {
    frameTime = 0,
    updateTime = 0,
    drawTime = 0
}

function love.load()
    if jit then
        jit.on()
    end
    
    love.window.setMode(config.window.width, config.window.height, { resizable = false })
    love.window.setTitle(config.game.title)
    love.graphics.setDefaultFilter("nearest", "nearest")
    canvas = love.graphics.newCanvas(config.screen.width, config.screen.height)
    assets.load()
    particle.load()
    
    camera.load(config)
    
    terrain.load()
    
    camera.setTerrainDimensions(terrain.width, terrain.height, terrain.tileSize)
    
    player.load()
    
    camera.x = player.x - config.screen.width / 2
    camera.y = player.y - config.screen.height / 2
    
    debugFont = assets.fonts.m5x7
    
    for i=1, maxFpsHistory do
        fpsHistory[i] = 0
    end
end

function love.update(dt)
    local updateStartTime = love.timer.getTime()
    
    player.update(dt)
    camera.update(player.x, player.y)
    particle.update(dt)
    
    if #fpsHistory >= maxFpsHistory then
        table.remove(fpsHistory, 1)
    end
    table.insert(fpsHistory, 1/dt)
    
    performanceMetrics.updateTime = love.timer.getTime() - updateStartTime
    performanceMetrics.frameTime = dt
end

function love.keypressed(key)
    if key == "f1" then
        debugMode = not debugMode
    end
end

function love.mousepressed(x, y, button)
    if button == 1 then
        player.mouseDown = true
    end
end

function love.mousereleased(x, y, button)
    if button == 1 then
        player.mouseDown = false
    end
end

function drawGrid()
    love.graphics.setColor(config.visual.gridColor)
    
    local startX = math.floor(camera.x / gridSize) * gridSize
    local startY = math.floor(camera.y / gridSize) * gridSize
    local endX = camera.x + config.screen.width
    local endY = camera.y + config.screen.height
    
    for x = startX, endX, gridSize do
        love.graphics.line(x, startY, x, endY)
    end
    
    for y = startY, endY, gridSize do
        love.graphics.line(startX, y, endX, y)
    end
end

function drawDebugInfo()
    love.graphics.setFont(debugFont)
    
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 5, 5, 130, 115)
    love.graphics.setColor(0, 1, 0, 1)
    
    local currentFPS = love.timer.getFPS()
    local fpsColor = currentFPS >= 58 and {0, 1, 0, 1} or 
                     currentFPS >= 30 and {1, 1, 0, 1} or 
                     {1, 0, 0, 1}
    love.graphics.setColor(unpack(fpsColor))
    love.graphics.print("FPS: " .. math.floor(currentFPS), 10, 10)
    
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print(string.format("Frame: %.2fms", performanceMetrics.frameTime * 1000), 10, 25)
    love.graphics.print(string.format("Update: %.2fms", performanceMetrics.updateTime * 1000), 10, 40)
    love.graphics.print(string.format("Draw: %.2fms", performanceMetrics.drawTime * 1000), 10, 55)
    
    love.graphics.print("Visible Tiles: " .. terrain.getVisibleTileCount(), 10, 70)
    love.graphics.print("Total Size: " .. terrain.width .. "x" .. terrain.height, 10, 85)
    
    local particleStats = particle.getStats()
    love.graphics.print("Particles: " .. particleStats.visible .. "/" .. particleStats.total, 10, 100)
    
    love.graphics.setColor(1, 1, 1, 1)
    
    camera.drawDebug()
end

function love.draw()
    local drawStartTime = love.timer.getTime()
    
    love.graphics.setCanvas(canvas)
    love.graphics.clear()
    
    love.graphics.push()
    love.graphics.translate(-math.floor(camera.x), -math.floor(camera.y))
    
    terrain.draw()
    
    if debugMode then
        drawGrid()
    end
    
    particle.draw()
    player.draw(debugMode)
    
    love.graphics.pop()
    
    if debugMode then
        drawDebugInfo()
    end
    
    love.graphics.setCanvas()
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(canvas, 0, 0, 0, config.screen.scale, config.screen.scale)
    
    performanceMetrics.drawTime = love.timer.getTime() - drawStartTime
end