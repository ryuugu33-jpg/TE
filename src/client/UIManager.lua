local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local NetworkConstants = require(ReplicatedStorage.Shared.NetworkConstants)

local UIManager = {}
local player = Players.LocalPlayer

function UIManager.Initialize()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "TowerEscapeUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = player:WaitForChild("PlayerGui")

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 200, 0, 190)
    frame.Position = UDim2.new(1, -210, 1, -200)
    frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    frame.Parent = screenGui

    local goldLabel = Instance.new("TextLabel")
    goldLabel.Name = "GoldLabel"
    goldLabel.Size = UDim2.new(1, 0, 0, 30)
    goldLabel.Text = "Gold: " .. (player:GetAttribute("Gold") or 0)
    goldLabel.TextColor3 = Color3.new(1, 1, 1)
    goldLabel.BackgroundTransparency = 1
    goldLabel.Parent = frame

    -- Listen for Gold changes
    player:GetAttributeChangedSignal("Gold"):Connect(function()
        goldLabel.Text = "Gold: " .. player:GetAttribute("Gold")
    end)

    local buyEggButton = Instance.new("TextButton")
    buyEggButton.Name = "BuyEggButton"
    buyEggButton.Size = UDim2.new(1, -20, 0, 40)
    buyEggButton.Position = UDim2.new(0, 10, 0, 40)
    buyEggButton.Text = "Buy Egg (100)"
    buyEggButton.Parent = frame

    buyEggButton.MouseButton1Click:Connect(function()
        UIManager.OnBuyEggClicked()
    end)

    local mergeButton = Instance.new("TextButton")
    mergeButton.Name = "MergeButton"
    mergeButton.Size = UDim2.new(1, -20, 0, 40)
    mergeButton.Position = UDim2.new(0, 10, 0, 90)
    mergeButton.Text = "Merge Units"
    mergeButton.Parent = frame

    mergeButton.MouseButton1Click:Connect(function()
        UIManager.OnMergeAllClicked()
    end)

    local startWaveButton = Instance.new("TextButton")
    startWaveButton.Name = "StartWaveButton"
    startWaveButton.Size = UDim2.new(1, -20, 0, 40)
    startWaveButton.Position = UDim2.new(0, 10, 0, 140)
    startWaveButton.Text = "Start Wave (Host Only)"
    startWaveButton.Parent = frame

    startWaveButton.MouseButton1Click:Connect(function()
        UIManager.OnStartWaveClicked()
    end)

    print("UI Initialized for", player.Name)
end

function UIManager.OnBuyEggClicked()
    local remote = ReplicatedStorage:WaitForChild(NetworkConstants.REMOTES.BUY_EGG)
    remote:FireServer()
end

function UIManager.OnMergeAllClicked()
    -- Simple merge all logic for the UI
    local remote = ReplicatedStorage:WaitForChild(NetworkConstants.REMOTES.MERGE_UNITS)
    remote:FireServer() -- Server will handle finding pairs
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
