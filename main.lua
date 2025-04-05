local config = require("config")
local assets = require("assets")
local player = require("player")
local camera = require("camera")

local canvas

function love.load()
    love.window.setMode(config.window.width, config.window.height, { resizable = false })
    love.window.setTitle(config.game.title)
    love.graphics.setDefaultFilter("nearest", "nearest")

    canvas = love.graphics.newCanvas(config.screen.width, config.screen.height)

    assets.load()
    player.load()
    camera.load(config)
end

function love.update(dt)
    player.update(dt)
    camera.update(player.x, player.y)
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

function love.draw()
    love.graphics.setCanvas(canvas)
    love.graphics.clear()

    love.graphics.setColor(config.visual.groundColor)
    love.graphics.rectangle("fill", 0, 0, config.screen.width, config.screen.height)

    love.graphics.push()
    love.graphics.translate(-math.floor(camera.x), -math.floor(camera.y))

    player.draw()

    love.graphics.pop()

    love.graphics.setCanvas()
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(canvas, 0, 0, 0, config.screen.scale, config.screen.scale)
end