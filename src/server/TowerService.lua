local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local GameConstants = require(ReplicatedStorage.Shared.GameConstants)
-- We need CurrentWave from WaveManager, but it might cause circular dependency if we require it.
-- Better to pass the wave number or store it in a shared attribute on Workspace.

local TowerService = {}
TowerService.Towers = {}

function TowerService.SpawnTower(towerType, position)
    local stats = GameConstants.TOWER_TYPES[towerType] or GameConstants.TOWER_TYPES.BASIC

    -- Create Physical Part
    local part = Instance.new("Part")
    part.Name = stats.name
    part.Size = Vector3.new(4, 10, 4)
    part.Position = position + Vector3.new(0, 5, 0)
    part.Parent = Workspace
    part.Anchored = true
    part.BrickColor = BrickColor.new("Bright red")

    local tower = {
        instance = part,
        stats = stats,
        position = position,
        lastFired = 0
    }
    table.insert(TowerService.Towers, tower)
end

function TowerService.Update(dt, units, waveNumber)
    local currentTime = os.clock()
    local damageMultiplier = 1 + (waveNumber - 1) * 0.2 -- 20% increase per wave

    for _, tower in ipairs(TowerService.Towers) do
        if currentTime - tower.lastFired >= tower.stats.fireRate then
            local target = TowerService.FindTarget(tower, units)
            if target then
                local damage = tower.stats.damage * damageMultiplier
                TowerService.Attack(tower, target, damage)
                tower.lastFired = currentTime
            end
        end
    end
end

function TowerService.FindTarget(tower, units)
    local closestUnit = nil
    local minDistance = tower.stats.range

    for _, unit in ipairs(units) do
        local dist = (tower.position - unit.position).Magnitude
        if dist < minDistance then
            minDistance = dist
            closestUnit = unit
        end
    end

    return closestUnit
end

function TowerService.Attack(tower, unit, damage)
    -- Deal damage to unit
    if unit.TakeDamage then
        unit:TakeDamage(damage)

        -- Visual effect (simplified)
        local beam = Instance.new("Part")
        beam.Anchored = true
        beam.CanCollide = false
        beam.Transparency = 0.5
        beam.BrickColor = BrickColor.new("Neon orange")
        beam.Size = Vector3.new(0.5, 0.5, (tower.position - unit.position).Magnitude)
        beam.CFrame = CFrame.lookAt(tower.position + Vector3.new(0, 5, 0), unit.position) * CFrame.new(0, 0, -beam.Size.Z/2)
        beam.Parent = Workspace
        game:GetService("Debris"):AddItem(beam, 0.1)
    end
end

return TowerService
