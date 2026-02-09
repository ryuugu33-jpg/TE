local GameConstants = {
    PLOT_SIZE = 160, -- 16x10 grid of 10-stud tiles?
    GRID_ROWS = 16,
    GRID_COLS = 16,
    TILE_SIZE = 10,
    PLOT_SPACING = 40,

    TILE_TYPES = {
        PATH = {name = "Path", color = Color3.fromRGB(163, 162, 165), height = 0.5},
        WALL = {name = "Wall", color = Color3.fromRGB(108, 88, 75), height = 5},
        START = {name = "Start", color = Color3.fromRGB(75, 151, 75), height = 0.6},
        EXIT = {name = "Exit", color = Color3.fromRGB(196, 40, 28), height = 0.6}
    }
}

return GameConstants
