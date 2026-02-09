local GameConstants = {
    MAX_UNITS_TOTAL = 20,
    COOP_LIMITS = {
        [1] = {host = 20},
        [2] = {host = 10, guest = 10},
        [3] = {host = 8, guest = 6},
        [4] = {host = 5, guest = 5}
    },
    GUEST_GOLD_BONUS_RATIO = 0.5,
    GRID_SIZE = 4, -- studs per tile

    UNIT_TYPES = {
        BASIC = {health = 50, speed = 8, goldValue = 10, name = "Basic Unit"},
        FAST = {health = 30, speed = 14, goldValue = 15, name = "Fast Unit"},
        TANK = {health = 150, speed = 5, goldValue = 25, name = "Tank Unit"},
    },

    TOWER_TYPES = {
        BASIC = {range = 15, damage = 10, fireRate = 1, name = "Basic Tower"},
        SNIPER = {range = 30, damage = 25, fireRate = 3, name = "Sniper Tower"},
        GATLING = {range = 12, damage = 2, fireRate = 0.1, name = "Gatling Tower"},
    },

    PICKUP_TYPES = {
        GOLD = {name = "Gold", amount = 50},
        HEAL = {name = "Heal", amount = 20},
        SHIELD = {name = "Shield", duration = 5},
    },

    EGG_PRICE = 100,
}

return GameConstants
