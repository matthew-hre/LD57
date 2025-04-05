local config = require("config")
local assets = require("assets")
local particle = require("particle")
local terrain = require("terrain")
local player = require("player")
local camera = require("camera")

local canvas
local debugMode = false
local gridSize = 32

function love.load()
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
end

function love.update(dt)
    player.update(dt)
    camera.update(player.x, player.y)
    particle.update(dt)
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

function love.draw()
    love.graphics.setCanvas(canvas)
    love.graphics.clear()

    love.graphics.setColor(config.visual.groundColor)
    love.graphics.rectangle("fill", 0, 0, config.screen.width, config.screen.height)

    love.graphics.push()
    love.graphics.translate(-math.floor(camera.x), -math.floor(camera.y))
    
    terrain.draw()
    
    if debugMode then
        drawGrid()
    end
    
    particle.draw()
    player.draw()

    love.graphics.pop()

    if debugMode then
        camera.drawDebug()
    end

    love.graphics.setCanvas()
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(canvas, 0, 0, 0, config.screen.scale, config.screen.scale)
end