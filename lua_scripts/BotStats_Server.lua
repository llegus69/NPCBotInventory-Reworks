-- ============================================================
--  BotStats_Server.lua
--  Envia las estadisticas reales de los bots contratados
--  al cliente via AddonMessage (Eluna / AzerothCore + NPCBots)
--  v4.0 - Adaptado nativamente al sistema de Especializaciones (Specs)
-- ============================================================

local PREFIX = "BSTATS"

-- ------------------------------------------------------------
-- Diccionario de mapeo oficial de la IA de NPCBots (Valores del 1 al 30)
-- ------------------------------------------------------------
local function SpecToString(specId)
    specId = tonumber(specId) or 0
    local SPEC_MAP = {
        -- Guerrero (WARRIOR)
        [1]  = "WARRIOR_ARMS",       [2]  = "WARRIOR_FURY",       [3]  = "WARRIOR_PROT",
        -- Paladín (PALADIN)
        [4]  = "PALADIN_HOLY",       [5]  = "PALADIN_PROT",       [6]  = "PALADIN_RET",
        -- Cazador (HUNTER)
        [7]  = "HUNTER_BM",          [8]  = "HUNTER_MM",          [9]  = "HUNTER_SURV",
        -- Pícaro (ROGUE)
        [10] = "ROGUE_ASS",          [11] = "ROGUE_COMBAT",       [12] = "ROGUE_SUB",
        -- Sacerdote (PRIEST)
        [13] = "PRIEST_DISC",        [14] = "PRIEST_HOLY",        [15] = "PRIEST_SHADOW",
        -- Caballero de la Muerte (DEATHKNIGHT)
        [16] = "DK_BLOOD",           [17] = "DK_FROST",           [18] = "DK_UNHOLY",
        -- Chamán (SHAMAN)
        [19] = "SHAMAN_ELEM",        [20] = "SHAMAN_ENH",         [21] = "SHAMAN_RESTO",
        -- Mago (MAGE)
        [22] = "MAGE_ARCANE",        [23] = "MAGE_FIRE",          [24] = "MAGE_FROST",
        -- Brujo (WARLOCK)
        [25] = "WARLOCK_AFF",        [26] = "WARLOCK_DEMO",       [27] = "WARLOCK_DESTRO",
        -- Druida (DRUID)
        [28] = "DRUID_BALANCE",      [29] = "DRUID_FERAL",        [30] = "DRUID_RESTO",
    }
    return SPEC_MAP[specId] or "UNKNOWN"
end

-- ------------------------------------------------------------
-- Funcion interna para buscar el bot vivo en el grupo del jugador
-- ------------------------------------------------------------
local function FindLiveBotInGroup(player, targetEntry)
    local group = player:GetGroup()
    if not group then return nil end

    local members = group:GetMembers()
    if not members then return nil end

    for _, member in ipairs(members) do
        -- Comprobamos si el miembro del grupo es una criatura (un NPCBot)
        if member:GetTypeId() == 3 then 
            if member:GetEntry() == targetEntry and member:IsAlive() then
                return member
            end
        end
    end
    return nil
end

-- ------------------------------------------------------------
-- Funcion principal
-- ------------------------------------------------------------
local function SendBotStats(player)
    local guidLow = player:GetGUIDLow()

    -- 1) Obtener entries y la columna 'spec' real de los bots en lugar de la máscara de bits obsoleta
    local botQuery = CharDBQuery(
        "SELECT entry, spec FROM characters_npcbot WHERE owner = " .. guidLow
    )

    if not botQuery then
        player:SendAddonMessage(PREFIX, "NOBOT", 7, player)
        return
    end

    local botEntries = {}
    local botSpecs   = {}
    repeat
        local entry = botQuery:GetUInt32(0)
        local spec  = botQuery:GetUInt32(1)
        table.insert(botEntries, entry)
        botSpecs[entry] = SpecToString(spec) -- Guardamos directamente el string identificador (Ej: "DRUID_RESTO")
    until not botQuery:NextRow()

    if #botEntries == 0 then
        player:SendAddonMessage(PREFIX, "NOBOT", 7, player)
        return
    end

    local entryList = table.concat(botEntries, ",")

    -- 2) Consultar estadisticas base desde la base de datos
    local statsQuery = CharDBQuery([[
        SELECT
            entry, maxhealth, maxpower, strength, agility, stamina, intellect, spirit,
            armor, defense, resHoly, resFire, resNature, resFrost, resShadow, resArcane,
            blockPct, dodgePct, parryPct, critPct, attackPower, spellPower, spellPen,
            hastePct, hitBonusPct, expertise, armorPenPct
        FROM characters_npcbot_stats
        WHERE entry IN (]] .. entryList .. [[)
    ]])

    if not statsQuery then
        player:SendAddonMessage(PREFIX, "NOSTATS", 7, player)
        return
    end

    -- 3) Procesar y enviar datos
    repeat
        local e      = statsQuery:GetUInt32(0)  or 0
        local hp     = statsQuery:GetUInt32(1)  or 0
        local mp     = statsQuery:GetUInt32(2)  or 0
        local str    = statsQuery:GetUInt32(3)  or 0
        local agi    = statsQuery:GetUInt32(4)  or 0
        local sta    = statsQuery:GetUInt32(5)  or 0
        local int_   = statsQuery:GetUInt32(6)  or 0
        local spi    = statsQuery:GetUInt32(7)  or 0
        local arm    = statsQuery:GetUInt32(8)  or 0
        local def    = statsQuery:GetUInt32(9)  or 0
        local rHoly  = statsQuery:GetUInt32(10) or 0
        local rFire  = statsQuery:GetUInt32(11) or 0
        local rNat   = statsQuery:GetUInt32(12) or 0
        local rFro   = statsQuery:GetUInt32(13) or 0
        local rSha   = statsQuery:GetUInt32(14) or 0
        local rArc   = statsQuery:GetUInt32(15) or 0
        local block  = statsQuery:GetFloat(16)  or 0.0
        local dodge  = statsQuery:GetFloat(17)  or 0.0
        local parry  = statsQuery:GetFloat(18)  or 0.0
        local crit   = statsQuery:GetFloat(19)  or 0.0
        local ap     = statsQuery:GetUInt32(20) or 0
        local sp     = statsQuery:GetUInt32(21) or 0
        local spen   = statsQuery:GetUInt32(22) or 0
        local haste  = statsQuery:GetFloat(23)  or 0.0
        local hit    = statsQuery:GetFloat(24)  or 0.0
        local exp    = statsQuery:GetUInt32(25) or 0
        local arpen  = statsQuery:GetFloat(26)  or 0.0

        -- Buscar el bot usando el nuevo escáner de grupo seguro
        local liveBot = FindLiveBotInGroup(player, e)
        if liveBot then
            hp   = liveBot:GetMaxHealth()
            mp   = liveBot:GetMaxPower(liveBot:GetPowerType())
            str  = liveBot:GetStat(0)
            agi  = liveBot:GetStat(1)
            sta  = liveBot:GetStat(2)
            int_ = liveBot:GetStat(3)
            spi  = liveBot:GetStat(4)
            arm  = liveBot:GetArmor()
        end

        local currentSpec = botSpecs[e] or "UNKNOWN"

        local msg = string.format(
            "STAT;%d;%s;%d;%d;%d;%d;%d;%d;%d;%d;%d;%d;%d;%d;%d;%d;%d;%.2f;%.2f;%.2f;%.2f;%d;%d;%d;%.2f;%.2f;%d;%.2f",
            e, currentSpec, hp, mp, str, agi, sta, int_, spi, arm, def,
            rHoly, rFire, rNat, rFro, rSha, rArc,
            block, dodge, parry, crit,
            ap, sp, spen, haste, hit, exp, arpen
        )

        player:SendAddonMessage(PREFIX, msg, 7, player)

    until not statsQuery:NextRow()

    player:SendAddonMessage(PREFIX, "END", 7, player)
end

-- ------------------------------------------------------------
-- Manejador de mensajes addon entrantes desde el cliente
-- ------------------------------------------------------------
local function OnAddonMessage(event, sender, msgType, prefix, msg, target)
    if prefix ~= PREFIX then return end

    if msg == "REQUEST" then
        SendBotStats(sender)
        return false
    end
end

-- ------------------------------------------------------------
-- Comando de chat alternativo: .bstats
-- ------------------------------------------------------------
local function OnCommand(event, player, command, chatHandler)
    local cmd = command:match("^(%S+)")
    if not cmd then return end

    if cmd:lower() == "bstats" then
        SendBotStats(player)
        return false
    end
end

RegisterServerEvent(30, OnAddonMessage)
RegisterPlayerEvent(42, OnCommand)