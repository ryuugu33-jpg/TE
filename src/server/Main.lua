local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared
local GameConstants = require(Shared.GameConstants)
local NetworkConstants = require(Shared.NetworkConstants)

local WaveManager = require(script.Parent.WaveManager)
local GridService = require(script.Parent.GridService)
local UnitService = require(script.Parent.UnitService)
local TowerService = require(script.Parent.TowerService)
local EconomyService = require(script.Parent.EconomyService)
local PickupService = require(script.Parent.PickupService)

-- Setup RemoteEvents
for _, name in pairs(NetworkConstants.REMOTES) do
    if not ReplicatedStorage:FindFirstChild(name) then
        local event = Instance.new("RemoteEvent")
        event.Name = name
        event.Parent = ReplicatedStorage
    end
end

-- Initialize Services
GridService.Initialize(20, 20)

-- Spawn some initial Towers
TowerService.SpawnTower("BASIC", Vector3.new(40, 0, 40))
TowerService.SpawnTower("SNIPER", Vector3.new(60, 0, 20))
TowerService.SpawnTower("GATLING", Vector3.new(20, 0, 60))

-- Spawn some initial Pickups
PickupService.SpawnPickup(5, 5)
PickupService.SpawnPickup(10, 10)
PickupService.SpawnPickup(15, 8)

Players.PlayerAdded:Connect(function(player)
    WaveManager.AddPlayer(player)
    EconomyService.InitializePlayer(player)
end)

Players.PlayerRemoving:Connect(function(player)
    WaveManager.RemovePlayer(player)
end)

-- Game Loop
game:GetService("RunService").Heartbeat:Connect(function(dt)
    if WaveManager.IsWaveActive then
        UnitService.Update(dt, WaveManager.CurrentPath, WaveManager.Host)
        TowerService.Update(dt, UnitService.ActiveUnits)
        PickupService.Update(UnitService.ActiveUnits)

        if #UnitService.ActiveUnits == 0 then
            WaveManager.EndWave()
        end
    end
end)

-- Handle Remotes
ReplicatedStorage:WaitForChild("DrawPath").OnServerEvent:Connect(function(player, path)
    if player == WaveManager.Host then
        if GridService.ValidatePath(path) then
            WaveManager.SetPath(path)
            print("New path validated and set by host.")
        end
    end
end)

ReplicatedStorage:WaitForChild("StartWave").OnServerEvent:Connect(function(player)
    if player == WaveManager.Host then
        WaveManager.StartWave()
    end
end)

ReplicatedStorage:WaitForChild("BuyEgg").OnServerEvent:Connect(function(player)
    -- Check unit limit
    local currentUnits = 0
    for _, u in ipairs(UnitService.ActiveUnits) do
        if u.owner == player then
            currentUnits = currentUnits + 1
        end
    end

    local limit = player:GetAttribute("UnitLimit") or 5
    if currentUnits >= limit then
        warn(player.Name .. " reached unit limit!")
        return
    end

    local unitType = EconomyService.BuyEgg(player)
    if unitType then
        UnitService.SpawnUnit(player, unitType, 1)
        print(player.Name .. " bought an egg and got a " .. unitType)
    end
end)

ReplicatedStorage:WaitForChild("MergeUnits").OnServerEvent:Connect(function(player, unitId1, unitId2)
    local u1 = UnitService.GetUnitById(unitId1)
    local u2 = UnitService.GetUnitById(unitId2)

    if u1 and u2 and u1.owner == player and u2.owner == player then
        local newUnit = UnitService.MergeUnits(player, u1, u2)
        if newUnit then
            print(player.Name .. " merged two units into a level " .. newUnit.level .. " unit")
        end
    end
end)
