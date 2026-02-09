local GridService = {}
GridService.Grid = {}
GridService.Exits = {}
GridService.Width = 20
GridService.Height = 20

function GridService.Initialize(width, height)
    GridService.Width = width or 20
    GridService.Height = height or 20
    for x = 1, GridService.Width do
        GridService.Grid[x] = {}
        for y = 1, GridService.Height do
            GridService.Grid[x][y] = {occupied = false}
        end
    end
    -- Add some default exits
    table.insert(GridService.Exits, {x = GridService.Width, y = math.floor(GridService.Height/2)})
end

function GridService.ValidatePath(path)
    -- A path is valid if it starts at a spawn point (e.g., x=1) and ends at an exit
    if #path < 2 then return false end

    local startNode = path[1]
    local endNode = path[#path]

    local isAtExit = false
    for _, exit in ipairs(GridService.Exits) do
        if exit.x == endNode.x and exit.y == endNode.y then
            isAtExit = true
            break
        end
    end

    return isAtExit
end

return GridService
