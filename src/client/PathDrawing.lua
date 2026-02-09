local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local NetworkConstants = require(ReplicatedStorage.Shared.NetworkConstants)
local GameConstants = require(ReplicatedStorage.Shared.GameConstants)

local PathDrawing = {}
PathDrawing.CurrentPath = {}
PathDrawing.IsDrawing = false

local player = Players.LocalPlayer
local mouse = player:GetMouse()

function PathDrawing.StartDrawing()
    if player:GetAttribute("IsHost") then
        PathDrawing.IsDrawing = true
        PathDrawing.CurrentPath = {}
        print("Started drawing path...")
    end
end

function PathDrawing.AddPoint(x, y)
    if not PathDrawing.IsDrawing then return end

    -- Prevent duplicates
    if #PathDrawing.CurrentPath > 0 then
        local last = PathDrawing.CurrentPath[#PathDrawing.CurrentPath]
        if last.x == x and last.y == y then return end

        -- Adjacency check
        local dx = math.abs(last.x - x)
        local dy = math.abs(last.y - y)
        if (dx == 1 and dy == 0) or (dx == 0 and dy == 1) then
            table.insert(PathDrawing.CurrentPath, {x = x, y = y})
            PathDrawing.VisualizePoint(x, y)
        end
    else
        -- First point must be at start line
        if x == 1 then
            table.insert(PathDrawing.CurrentPath, {x = x, y = y})
            PathDrawing.VisualizePoint(x, y)
        end
    end
end

function PathDrawing.VisualizePoint(x, y)
    local part = Instance.new("Part")
    part.Size = Vector3.new(GameConstants.GRID_SIZE, 0.2, GameConstants.GRID_SIZE)
    part.Position = Vector3.new(x * GameConstants.GRID_SIZE, 0.1, y * GameConstants.GRID_SIZE)
    part.Anchored = true
    part.CanCollide = false
    part.BrickColor = BrickColor.new("Lime green")
    part.Transparency = 0.5
    part.Parent = workspace
end

function PathDrawing.FinishDrawing()
    if not PathDrawing.IsDrawing then return end
    PathDrawing.IsDrawing = false
    print("Finished drawing path. Nodes:", #PathDrawing.CurrentPath)

    local remote = ReplicatedStorage:WaitForChild(NetworkConstants.REMOTES.DRAW_PATH)
    remote:FireServer(PathDrawing.CurrentPath)
end

-- Input Listeners
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        PathDrawing.StartDrawing()
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        PathDrawing.FinishDrawing()
    end
end)

game:GetService("RunService").RenderStepped:Connect(function()
    if PathDrawing.IsDrawing then
        -- Convert mouse position to grid
        local pos = mouse.Hit.p
        local x = math.round(pos.X / GameConstants.GRID_SIZE)
        local y = math.round(pos.Z / GameConstants.GRID_SIZE)
        PathDrawing.AddPoint(x, y)
    end
end)

return PathDrawing
