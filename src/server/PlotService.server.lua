local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local PlotService = {}
PlotService.Plots = {}

local PLOT_SIZE = 50
local PLOT_SPACING = 10

function PlotService.Initialize()
    local container = Instance.new("Folder")
    container.Name = "Plots"
    container.Parent = Workspace

    for i = 1, 8 do
        local x = ((i - 1) % 4) * (PLOT_SIZE + PLOT_SPACING)
        local z = math.floor((i - 1) / 4) * (PLOT_SIZE + PLOT_SPACING)

        local plot = Instance.new("Part")
        plot.Name = "Plot_" .. i
        plot.Size = Vector3.new(PLOT_SIZE, 1, PLOT_SIZE)
        plot.Position = Vector3.new(x, 0.5, z)
        plot.Anchored = true
        plot.BrickColor = BrickColor.new("Grime")
        plot.Parent = container

        local ownerValue = Instance.new("ObjectValue")
        ownerValue.Name = "Owner"
        ownerValue.Parent = plot

        -- Add BillboardGui for claiming
        PlotService.CreateBillboard(plot)

        -- Add ProximityPrompt for claiming
        local prompt = Instance.new("ProximityPrompt")
        prompt.ActionText = "Claim Plot"
        prompt.ObjectText = plot.Name
        prompt.Parent = plot

        prompt.Triggered:Connect(function(player)
            PlotService.ClaimPlot(plot, player)
        end)

        table.insert(PlotService.Plots, plot)
    end
end

function PlotService.CreateBillboard(plot)
    local bgui = Instance.new("BillboardGui")
    bgui.Name = "ClaimGui"
    bgui.Size = UDim2.new(0, 200, 0, 100)
    bgui.StudsOffset = Vector3.new(0, 5, 0)
    bgui.Adornee = plot
    bgui.AlwaysOnTop = true
    bgui.Parent = plot

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 1
    frame.Parent = bgui

    local textLabel = Instance.new("TextLabel")
    textLabel.Name = "StatusLabel"
    textLabel.Size = UDim2.new(1, 0, 0, 30)
    textLabel.Position = UDim2.new(0, 0, 0.7, 0)
    textLabel.Text = "Available"
    textLabel.TextColor3 = Color3.new(1, 1, 1)
    textLabel.BackgroundTransparency = 0.5
    textLabel.BackgroundColor3 = Color3.new(0, 0, 0)
    textLabel.Parent = frame

    local imageLabel = Instance.new("ImageLabel")
    imageLabel.Name = "AvatarImage"
    imageLabel.Size = UDim2.new(0, 60, 0, 60)
    imageLabel.Position = UDim2.new(0.5, -30, 0, 0)
    imageLabel.Visible = false
    imageLabel.Parent = frame
end

function PlotService.ClaimPlot(plot, player)
    -- Check if player already has a plot
    for _, p in ipairs(PlotService.Plots) do
        if p.Owner.Value == player then
            warn(player.Name .. " already owns a plot!")
            return
        end
    end

    -- Check if plot is already owned
    if plot.Owner.Value ~= nil then
        warn("Plot already owned!")
        return
    end

    plot.Owner.Value = player
    plot.BrickColor = BrickColor.new("Bright green")

    local prompt = plot:FindFirstChildOfClass("ProximityPrompt")
    if prompt then prompt.Enabled = false end

    local bgui = plot:FindFirstChild("ClaimGui")
    if bgui then
        local label = bgui.Frame.StatusLabel
        label.Text = "Claimed by " .. player.DisplayName

        local image = bgui.Frame.AvatarImage
        local success, content = pcall(function()
            return Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
        end)

        if success then
            image.Image = content
            image.Visible = true
        end
    end

    print(player.Name .. " claimed " .. plot.Name)
end

-- Handle player leaving
Players.PlayerRemoving:Connect(function(player)
    for _, plot in ipairs(PlotService.Plots) do
        if plot.Owner.Value == player then
            plot.Owner.Value = nil
            plot.BrickColor = BrickColor.new("Grime")

            local prompt = plot:FindFirstChildOfClass("ProximityPrompt")
            if prompt then prompt.Enabled = true end

            local bgui = plot:FindFirstChild("ClaimGui")
            if bgui then
                bgui.Frame.StatusLabel.Text = "Available"
                bgui.Frame.AvatarImage.Visible = false
            end

            print("Plot released by " .. player.Name)
            break
        end
    end
end)

-- Initialize the service
PlotService.Initialize()

return PlotService
