local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UnitData = require(ReplicatedStorage.Shared.UnitData)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "InventoryGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 400, 0, 300)
mainFrame.Position = UDim2.new(0.5, -200, 1, -320)
mainFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.Text = "Unit Inventory"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextScaled = true
title.BackgroundTransparency = 1
title.Parent = mainFrame

local scrollingFrame = Instance.new("ScrollingFrame")
scrollingFrame.Size = UDim2.new(1, -20, 1, -60)
scrollingFrame.Position = UDim2.new(0, 10, 0, 50)
scrollingFrame.BackgroundTransparency = 1
scrollingFrame.CanvasSize = UDim2.new(0, 0, 2, 0)
scrollingFrame.Parent = mainFrame

local uiListLayout = Instance.new("UIListLayout")
uiListLayout.Padding = UDim.new(0, 5)
uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
uiListLayout.Parent = scrollingFrame

-- Example: Populate with UnitData
local index = 0
for name, data in pairs(UnitData) do
    index = index + 1
    local entry = Instance.new("Frame")
    entry.Size = UDim2.new(1, -10, 0, 60)
    entry.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    entry.BorderSizePixel = 0
    entry.Parent = scrollingFrame

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(0.4, 0, 1, 0)
    nameLabel.Text = name
    nameLabel.TextColor3 = Color3.new(1, 1, 1)
    nameLabel.TextScaled = true
    nameLabel.BackgroundTransparency = 1
    nameLabel.Parent = entry

    local statsLabel = Instance.new("TextLabel")
    statsLabel.Size = UDim2.new(0.6, 0, 1, 0)
    statsLabel.Position = UDim2.new(0.4, 0, 0, 0)
    statsLabel.Text = string.format("HP: %d | Spd: %d\nDelay: %.1fs | Val: %d", data.hp, data.speed, data.delay, data.value)
    statsLabel.TextColor3 = Color3.new(0.8, 0.8, 0.8)
    statsLabel.TextSize = 14
    statsLabel.BackgroundTransparency = 1
    statsLabel.Parent = entry
end

print("Inventory UI Initialized")
