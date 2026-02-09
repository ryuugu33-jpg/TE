local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local NetworkConstants = require(ReplicatedStorage.Shared.NetworkConstants)

local UIManager = {}
local player = Players.LocalPlayer

function UIManager.Initialize()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "TowerEscapeUI"
    screenGui.Parent = player:WaitForChild("PlayerGui")

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 200, 0, 150)
    frame.Position = UDim2.new(1, -210, 1, -160)
    frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    frame.Parent = screenGui

    local goldLabel = Instance.new("TextLabel")
    goldLabel.Name = "GoldLabel"
    goldLabel.Size = UDim2.new(1, 0, 0, 30)
    goldLabel.Text = "Gold: 0"
    goldLabel.TextColor3 = Color3.new(1, 1, 1)
    goldLabel.BackgroundTransparency = 1
    goldLabel.Parent = frame

    local buyEggButton = Instance.new("TextButton")
    buyEggButton.Name = "BuyEggButton"
    buyEggButton.Size = UDim2.new(1, -20, 0, 40)
    buyEggButton.Position = UDim2.new(0, 10, 0, 40)
    buyEggButton.Text = "Buy Egg (100)"
    buyEggButton.Parent = frame

    buyEggButton.MouseButton1Click:Connect(function()
        UIManager.OnBuyEggClicked()
    end)

    local startWaveButton = Instance.new("TextButton")
    startWaveButton.Name = "StartWaveButton"
    startWaveButton.Size = UDim2.new(1, -20, 0, 40)
    startWaveButton.Position = UDim2.new(0, 10, 0, 90)
    startWaveButton.Text = "Start Wave (Host Only)"
    startWaveButton.Parent = frame

    startWaveButton.MouseButton1Click:Connect(function()
        UIManager.OnStartWaveClicked()
    end)

    print("UI Programmatically Initialized for", player.Name)
end

function UIManager.UpdateGold(amount)
    local label = player.PlayerGui.TowerEscapeUI.Frame.GoldLabel
    label.Text = "Gold: " .. amount
end

function UIManager.OnBuyEggClicked()
    local remote = ReplicatedStorage:WaitForChild(NetworkConstants.REMOTES.BUY_EGG)
    remote:FireServer()
end

function UIManager.OnStartWaveClicked()
    if player:GetAttribute("IsHost") then
        local remote = ReplicatedStorage:WaitForChild(NetworkConstants.REMOTES.START_WAVE)
        remote:FireServer()
    else
        warn("Only host can start wave")
    end
end

return UIManager
