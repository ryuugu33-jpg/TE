local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UnitData = require(ReplicatedStorage.Shared.UnitData)
local GameConstants = require(ReplicatedStorage.Shared.GameConstants)

local InventoryService = {}
InventoryService.PlayerData = {}

function InventoryService.InitializePlayer(player)
    InventoryService.PlayerData[player] = {
        inventory = {"Soldier", "Scout", "Tanker"}, -- Starting units
        activeOrder = {"Soldier", "Scout", "Tanker"}
    }

    -- Sync initial order to staging area if they have a plot
    InventoryService.UpdateStagingArea(player)
end

function InventoryService.GetActiveOrder(player)
    local data = InventoryService.PlayerData[player]
    return data and data.activeOrder or {}
end

function InventoryService.SetOrder(player, newOrder)
    local data = InventoryService.PlayerData[player]
    if not data then return end

    -- Basic validation: check if units are in inventory
    local valid = true
    for _, unitName in ipairs(newOrder) do
        local found = false
        for _, invName in ipairs(data.inventory) do
            if invName == unitName then
                found = true
                break
            end
        end
        if not found then
            valid = false
            break
        end
    end

    if valid then
        data.activeOrder = newOrder
        InventoryService.UpdateStagingArea(player)
    end
end

function InventoryService.UpdateStagingArea(player)
    -- Find player's plot
    local plotFolder = nil
    for _, p in ipairs(workspace:WaitForChild("Plots"):GetChildren()) do
        if p:FindFirstChild("Owner") and p.Owner.Value == player then
            plotFolder = p
            break
        end
    end

    if not plotFolder then return end

    local stagingArea = plotFolder:FindFirstChild("StagingArea")
    if not stagingArea then return end

    -- Clear previous models
    local unitsFolder = stagingArea:FindFirstChild("Units")
    if not unitsFolder then
        unitsFolder = Instance.new("Folder")
        unitsFolder.Name = "Units"
        unitsFolder.Parent = stagingArea
    else
        unitsFolder:ClearAllChildren()
    end

    local order = InventoryService.GetActiveOrder(player)
    local startPos = stagingArea.Position + Vector3.new(0, 3, -GameConstants.PLOT_SIZE/2 + 20)

    for i, unitName in ipairs(order) do
        local unitInfo = UnitData[unitName]
        if unitInfo then
            -- Create a simple representation (dummy)
            local model = Instance.new("Part")
            model.Name = unitName .. "_" .. i
            model.Size = Vector3.new(4, 6, 4)
            model.Position = startPos + Vector3.new(0, 0, (i-1) * 12)
            model.Anchored = true
            model.Parent = unitsFolder

            -- Add label
            local bgui = Instance.new("BillboardGui")
            bgui.Size = UDim2.new(0, 100, 0, 50)
            bgui.StudsOffset = Vector3.new(0, 4, 0)
            bgui.AlwaysOnTop = true
            bgui.Parent = model

            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, 0, 1, 0)
            label.Text = unitName .. "\nDelay: " .. unitInfo.delay
            label.TextColor3 = Color3.new(1, 1, 1)
            label.BackgroundTransparency = 1
            label.Parent = bgui
        end
    end
end

Players.PlayerAdded:Connect(function(player)
    InventoryService.InitializePlayer(player)
end)

-- Handle existing players (in case of race condition)
for _, player in ipairs(Players:GetPlayers()) do
    InventoryService.InitializePlayer(player)
end

Players.PlayerRemoving:Connect(function(player)
    InventoryService.PlayerData[player] = nil
end)

-- Setup RemoteEvent for reordering
local reorderEvent = Instance.new("RemoteEvent")
reorderEvent.Name = "ReorderInventory"
reorderEvent.Parent = ReplicatedStorage

reorderEvent.OnServerEvent:Connect(function(player, newOrder)
    InventoryService.SetOrder(player, newOrder)
end)

return InventoryService
