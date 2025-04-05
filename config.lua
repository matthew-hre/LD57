local config = {
    screen = {
        width = 192,
        height = 256,
        scale = 4
    },
    
    visual = {
        shadowColor = {0, 105/255, 170/255, 1},
        groundColor = {0.847, 0.475, 0.267, 1},
        angleSnapFactor = 16
    },
    
    game = {
        title = "Ludum Dare 57",
    },
}

config.window = {
    width = config.screen.width * config.screen.scale,
    height = config.screen.height * config.screen.scale
}

return config
