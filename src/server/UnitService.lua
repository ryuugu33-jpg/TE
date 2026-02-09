local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local GameConstants = require(ReplicatedStorage.Shared.GameConstants)
local EconomyService = require(script.Parent.EconomyService)

local UnitService = {}
UnitService.ActiveUnits = {}
UnitService.UnitCounter = 0

function UnitService.SpawnUnit(player, unitType, level)
    level = level or 1
    local stats = GameConstants.UNIT_TYPES[unitType] or GameConstants.UNIT_TYPES.BASIC

    UnitService.UnitCounter = UnitService.UnitCounter + 1
    local unitId = "Unit_" .. UnitService.UnitCounter

    -- Create Physical Part
    local part = Instance.new("Part")
    part.Name = unitId
    part.Size = Vector3.new(2, 2, 2)
    part.Position = Vector3.new(0, 5, 0)
    part.Parent = Workspace
    part.Anchored = true
    part.CanCollide = false

    local unit = {
        id = unitId,
        instance = part,
        owner = player,
        unitType = unitType,
        level = level,
        health = stats.health * level,
        maxHealth = stats.health * level,
        speed = stats.speed,
        goldValue = stats.goldValue * level,
        position = part.Position,
        pathIndex = 1,
        isDead = false,
        hasReachedExit = false
    }

    function unit:TakeDamage(amount)
        if self.hasShield and os.clock() < self.shieldTime then
            return -- Immune
        end
        self.health = self.health - amount
        if self.health <= 0 then
            self.isDead = true
        end
    end

    function unit:Destroy()
        if self.instance then
            self.instance:Destroy()
        end
    end

    table.insert(UnitService.ActiveUnits, unit)
    return unit
end

function UnitService.Update(dt, path, host)
    if not path or #path == 0 then return end

    for i = #UnitService.ActiveUnits, 1, -1 do
        local unit = UnitService.ActiveUnits[i]

        if unit.isDead then
            unit:Destroy()
            table.remove(UnitService.ActiveUnits, i)
        elseif unit.hasReachedExit then
            EconomyService.HandleUnitExit(unit, host)
            unit:Destroy()
            table.remove(UnitService.ActiveUnits, i)
        else
            -- Move along path
            local targetNode = path[unit.pathIndex]
            if targetNode then
                local targetPos = Vector3.new(targetNode.x * GameConstants.GRID_SIZE, 3, targetNode.y * GameConstants.GRID_SIZE)
                local direction = (targetPos - unit.position).Unit
                local distance = (targetPos - unit.position).Magnitude

                local moveDist = unit.speed * dt
                if moveDist >= distance then
                    unit.position = targetPos
                    unit.pathIndex = unit.pathIndex + 1
                    if unit.pathIndex > #path then
                        unit.hasReachedExit = true
                    end
                else
                    unit.position = unit.position + direction * moveDist
                end

                -- Update physical part
                if unit.instance then
                    unit.instance.Position = unit.position
                end
            end
        end
    end
end

function UnitService.GetUnitById(id)
    for _, unit in ipairs(UnitService.ActiveUnits) do
        if unit.id == id then
            return unit
        end
    end
    return nil
end

function UnitService.MergeUnits(player, u1, u2)
    if u1 == u2 then return nil end
    if u1.unitType == u2.unitType and u1.level == u2.level then
        local newLevel = u1.level + 1

        -- Remove old units
        for i = #UnitService.ActiveUnits, 1, -1 do
            local u = UnitService.ActiveUnits[i]
            if u == u1 or u == u2 then
                u:Destroy()
                table.remove(UnitService.ActiveUnits, i)
            end
        end

        return UnitService.SpawnUnit(player, u1.unitType, newLevel)
    end
    return nil
end

return UnitService
