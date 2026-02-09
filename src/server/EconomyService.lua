local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameConstants = require(ReplicatedStorage.Shared.GameConstants)

local EconomyService = {}
EconomyService.PlayerData = {}

function EconomyService.InitializePlayer(player)
    EconomyService.PlayerData[player] = {
        gold = 200, -- Starting gold
        units = {}
    }
    player:SetAttribute("Gold", 200)
end

function EconomyService.AddGold(player, amount)
    if EconomyService.PlayerData[player] then
        EconomyService.PlayerData[player].gold = EconomyService.PlayerData[player].gold + amount
        player:SetAttribute("Gold", EconomyService.PlayerData[player].gold)
    end
end

function EconomyService.HandleUnitExit(unit, host)
    local owner = unit.owner
    local value = unit.goldValue

    -- Owner gets 100%
    EconomyService.AddGold(owner, value)

    -- If guest's unit reached exit, host gets bonus
    if owner ~= host then
        local bonus = math.floor(value * GameConstants.GUEST_GOLD_BONUS_RATIO)
        EconomyService.AddGold(host, bonus)
    end
end

function EconomyService.BuyEgg(player)
    local data = EconomyService.PlayerData[player]
    if not data then return false end

    if data.gold >= GameConstants.EGG_PRICE then
        data.gold = data.gold - GameConstants.EGG_PRICE
        player:SetAttribute("Gold", data.gold)

        -- Drop a random unit
        local unitTypes = {"BASIC", "FAST", "TANK"}
        local randomType = unitTypes[math.random(1, #unitTypes)]
        return randomType
    end
    return false
end

return EconomyService
