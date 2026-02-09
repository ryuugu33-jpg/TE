local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConstants = require(ReplicatedStorage.Shared.GameConstants)
local InventoryService = require(script.Parent.InventoryService)

local PlotService = {}
PlotService.Plots = {}

function PlotService.Initialize()
    local container = Instance.new("Folder")
    container.Name = "Plots"
    container.Parent = Workspace

    for i = 1, 8 do
        local x = ((i - 1) % 4) * (GameConstants.PLOT_SIZE + GameConstants.PLOT_SPACING)
        local z = math.floor((i - 1) / 4) * (GameConstants.PLOT_SIZE + GameConstants.PLOT_SPACING)

        local plotFolder = Instance.new("Folder")
        plotFolder.Name = "Plot_" .. i
        plotFolder.Parent = container

        local base = Instance.new("Part")
        base.Name = "Base"
        base.Size = Vector3.new(GameConstants.PLOT_SIZE, 1, GameConstants.PLOT_SIZE)
        base.Position = Vector3.new(x, 0.5, z)
        base.Anchored = true
        base.BrickColor = BrickColor.new("Grime")
        base.Parent = plotFolder

        local ownerValue = Instance.new("ObjectValue")
        ownerValue.Name = "Owner"
        ownerValue.Parent = plotFolder

        -- Staging Area for units
        local staging = Instance.new("Part")
        staging.Name = "StagingArea"
        staging.Size = Vector3.new(30, 1, GameConstants.PLOT_SIZE)
        staging.Position = base.Position + Vector3.new(-(GameConstants.PLOT_SIZE/2 + 20), 0, 0)
        staging.Anchored = true
        staging.BrickColor = BrickColor.new("Dark stone grey")
        staging.Parent = plotFolder

        -- Billboard at the front
        PlotService.CreateBillboard(plotFolder, base)

        -- Claim Prompt
        local promptPart = Instance.new("Part")
        promptPart.Name = "ClaimPart"
        promptPart.Size = Vector3.new(5, 5, 5)
        promptPart.Position = base.Position + Vector3.new(0, 3, GameConstants.PLOT_SIZE/2 + 5)
        promptPart.Anchored = true
        promptPart.Transparency = 1
        promptPart.CanCollide = false
        promptPart.Parent = plotFolder

        local prompt = Instance.new("ProximityPrompt")
        prompt.ActionText = "Claim Plot"
        prompt.ObjectText = "Plot " .. i
        prompt.Parent = promptPart

        prompt.Triggered:Connect(function(player)
            PlotService.ClaimPlot(plotFolder, player)
        end)

        table.insert(PlotService.Plots, plotFolder)
    end
end

function PlotService.CreateBillboard(plotFolder, base)
    local bgui = Instance.new("BillboardGui")
    bgui.Name = "ClaimGui"
    bgui.Size = UDim2.new(0, 250, 0, 120)
    -- Position in front of the plot
    bgui.Adornee = base
    bgui.StudsOffset = Vector3.new(0, 8, GameConstants.PLOT_SIZE/2 + 2)
    bgui.AlwaysOnTop = true
    bgui.Parent = plotFolder

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 1
    frame.Parent = bgui

    local textLabel = Instance.new("TextLabel")
    textLabel.Name = "StatusLabel"
    textLabel.Size = UDim2.new(1, 0, 0.4, 0)
    textLabel.Position = UDim2.new(0, 0, 0.6, 0)
    textLabel.Text = "Available"
    textLabel.TextScaled = true
    textLabel.TextColor3 = Color3.new(1, 1, 1)
    textLabel.BackgroundTransparency = 0.5
    textLabel.BackgroundColor3 = Color3.new(0, 0, 0)
    textLabel.Parent = frame

    local imageLabel = Instance.new("ImageLabel")
    imageLabel.Name = "AvatarImage"
    imageLabel.Size = UDim2.new(0, 70, 0, 70)
    imageLabel.Position = UDim2.new(0.5, -35, 0, 0)
    imageLabel.Visible = false
    imageLabel.Parent = frame
end

function PlotService.GenerateGrid(plotFolder)
    local base = plotFolder.Base
    local gridFolder = Instance.new("Folder")
    gridFolder.Name = "Grid"
    gridFolder.Parent = plotFolder

    local startX = base.Position.X - (GameConstants.PLOT_SIZE/2) + (GameConstants.TILE_SIZE/2)
    local startZ = base.Position.Z - (GameConstants.PLOT_SIZE/2) + (GameConstants.TILE_SIZE/2)

    for r = 1, GameConstants.GRID_ROWS do
        for c = 1, GameConstants.GRID_COLS do
            local tileType = "WALL" -- Default
            if r == 1 and c == 1 then
                tileType = "START"
            elseif r == GameConstants.GRID_ROWS and c == GameConstants.GRID_COLS then
                tileType = "EXIT"
            end

            local config = GameConstants.TILE_TYPES[tileType]
            local tile = Instance.new("Part")
            tile.Name = "Tile_" .. r .. "_" .. c
            tile.Size = Vector3.new(GameConstants.TILE_SIZE - 0.1, config.height, GameConstants.TILE_SIZE - 0.1)
            tile.Position = Vector3.new(startX + (c-1) * GameConstants.TILE_SIZE, 1.0 + config.height/2, startZ + (r-1) * GameConstants.TILE_SIZE)
            tile.Anchored = true
            tile.Color = config.color
            tile.Parent = gridFolder

            local typeAttr = Instance.new("StringValue")
            typeAttr.Name = "Type"
            typeAttr.Value = tileType
            typeAttr.Parent = tile
        end
    end
end

function PlotService.ClaimPlot(plotFolder, player)
    -- Check if player already has a plot
    for _, p in ipairs(PlotService.Plots) do
        if p.Owner.Value == player then
            warn(player.Name .. " already owns a plot!")
            return
        end
    end

    if plotFolder.Owner.Value ~= nil then return end

    plotFolder.Owner.Value = player

    local promptPart = plotFolder:FindFirstChild("ClaimPart")
    if promptPart then
        local prompt = promptPart:FindFirstChildOfClass("ProximityPrompt")
        if prompt then prompt.Enabled = false end
    end

    local bgui = plotFolder:FindFirstChild("ClaimGui")
    if bgui then
        bgui.Frame.StatusLabel.Text = "Claimed by " .. player.DisplayName
        local image = bgui.Frame.AvatarImage
        local success, content = pcall(function()
            return Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
        end)
        if success then
            image.Image = content
            image.Visible = true
        end
    end

    PlotService.GenerateGrid(plotFolder)
    InventoryService.UpdateStagingArea(player)
    print(player.Name .. " claimed and initialized grid for " .. plotFolder.Name)
end

-- Handle player leaving
Players.PlayerRemoving:Connect(function(player)
    for _, plotFolder in ipairs(PlotService.Plots) do
        if plotFolder.Owner.Value == player then
            plotFolder.Owner.Value = nil
            local grid = plotFolder:FindFirstChild("Grid")
            if grid then grid:Destroy() end

            local promptPart = plotFolder:FindFirstChild("ClaimPart")
            if promptPart then
                local prompt = promptPart:FindFirstChildOfClass("ProximityPrompt")
                if prompt then prompt.Enabled = true end
            end

            local bgui = plotFolder:FindFirstChild("ClaimGui")
            if bgui then
                bgui.Frame.StatusLabel.Text = "Available"
                bgui.Frame.AvatarImage.Visible = false
            end
            break
        end
    end
end)

PlotService.Initialize()

return PlotService
