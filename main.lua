local config = require("config")
local assets = require("assets")

local player = require("player")

local canvas

function love.load()
    love.window.setMode(config.window.width, config.window.height, { resizable = false })
    love.window.setTitle(config.game.title)
    love.graphics.setDefaultFilter("nearest", "nearest")

    canvas = love.graphics.newCanvas(config.screen.width, config.screen.height)

    assets.load()
    player.load()
end

function love.update(dt)
    -- Update game logic here
end

function love.mousepressed(x, y, button)
    -- Handle mouse press events here
end

function love.draw()
    love.graphics.setCanvas(canvas)
    love.graphics.clear()

    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("fill", 0, 0, config.screen.width, config.screen.height)


    player.draw()


    love.graphics.setCanvas()
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(canvas, 0, 0, 0, config.screen.scale, config.screen.scale)
end