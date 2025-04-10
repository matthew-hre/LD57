local config = {
    screen = {
        width = 192,
        height = 256,
        scale = 3
    },
    
    visual = {
        shadowColor = {0, 105/255, 170/255, 1},
        groundColor = {0.847, 0.475, 0.267, 1},
        altGroundColor = {190/255, 74/255, 47/255, 1},
        gridColor = {0.557, 0.173, 0.208, 1},
        angleSnapFactor = 16
    },
    
    game = {
        title = "Ludum Dare 57",
    }
}

config.window = {
    width = config.screen.width * config.screen.scale,
    height = config.screen.height * config.screen.scale
}

return config
