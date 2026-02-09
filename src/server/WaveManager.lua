local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameConstants = require(ReplicatedStorage.Shared.GameConstants)

local WaveManager = {}
WaveManager.Players = {}
WaveManager.Host = nil
WaveManager.CurrentWave = 0
WaveManager.IsWaveActive = false
WaveManager.CurrentPath = nil

function WaveManager.AddPlayer(player)
    if #WaveManager.Players == 0 then
        WaveManager.Host = player
        player:SetAttribute("IsHost", true)
    else
        player:SetAttribute("IsHost", false)
    end
    table.insert(WaveManager.Players, player)
    WaveManager.UpdateLimits()
end

function WaveManager.RemovePlayer(player)
    for i, p in ipairs(WaveManager.Players) do
        if p == player then
            table.remove(WaveManager.Players, i)
            break
        end
    end

    if WaveManager.Host == player then
        WaveManager.Host = WaveManager.Players[1]
        if WaveManager.Host then
            WaveManager.Host:SetAttribute("IsHost", true)
        end
    end
    WaveManager.UpdateLimits()
end

function WaveManager.UpdateLimits()
    local playerCount = #WaveManager.Players
    if playerCount == 0 then return end

    local limits = GameConstants.COOP_LIMITS[playerCount] or GameConstants.COOP_LIMITS[4]

    for _, player in ipairs(WaveManager.Players) do
        local limit = (player == WaveManager.Host) and limits.host or limits.guest
        player:SetAttribute("UnitLimit", limit)
    end
end

function WaveManager.SetPath(path)
    WaveManager.CurrentPath = path
end

function WaveManager.StartWave()
    if WaveManager.IsWaveActive then return end
    if not WaveManager.CurrentPath then return end

    WaveManager.IsWaveActive = true
    WaveManager.CurrentWave = WaveManager.CurrentWave + 1
    -- Notify clients
end

function WaveManager.EndWave()
    WaveManager.IsWaveActive = false
end

return WaveManager
