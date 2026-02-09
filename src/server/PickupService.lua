local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local GameConstants = require(ReplicatedStorage.Shared.GameConstants)
local EconomyService = require(script.Parent.EconomyService)

local PickupService = {}
PickupService.ActivePickups = {}

function PickupService.SpawnPickup(x, y)
    local types = {"GOLD", "HEAL", "SHIELD"}
    local randomType = types[math.random(1, #types)]
    local stats = GameConstants.PICKUP_TYPES[randomType]

    local position = Vector3.new(x * GameConstants.GRID_SIZE, 1, y * GameConstants.GRID_SIZE)

    -- Create Physical Part
    local part = Instance.new("Part")
    part.Name = "Pickup_" .. randomType
    part.Size = Vector3.new(2, 2, 2)
    part.Position = position
    part.Parent = Workspace
    part.Anchored = true
    part.CanCollide = false
    part.BrickColor = BrickColor.new(randomType == "GOLD" and "Bright yellow" or (randomType == "HEAL" and "Bright red" or "Bright blue"))

    local pickup = {
        instance = part,
        pickupType = randomType,
        stats = stats,
        position = position,
        isCollected = false
    }

    table.insert(PickupService.ActivePickups, pickup)
end

function PickupService.Update(units)
    for i = #PickupService.ActivePickups, 1, -1 do
        local pickup = PickupService.ActivePickups[i]

        for _, unit in ipairs(units) do
            local dist = (unit.position - pickup.position).Magnitude
            if dist < 3 then -- Collection radius
                PickupService.ActivatePickup(pickup, unit)
                if pickup.instance then pickup.instance:Destroy() end
                table.remove(PickupService.ActivePickups, i)
                break
            end
        end
    end
end

function PickupService.ActivatePickup(pickup, unit)
    if pickup.pickupType == "GOLD" then
        EconomyService.AddGold(unit.owner, pickup.stats.amount)
        print(unit.owner.Name .. " collected Gold pickup!")
    elseif pickup.pickupType == "HEAL" then
        unit.health = math.min(unit.maxHealth, unit.health + pickup.stats.amount)
        print(unit.owner.Name .. "'s unit healed!")
    elseif pickup.pickupType == "SHIELD" then
        unit.hasShield = true
        unit.shieldTime = os.clock() + pickup.stats.duration
        print(unit.owner.Name .. "'s unit shielded!")
    end
end

return PickupService
