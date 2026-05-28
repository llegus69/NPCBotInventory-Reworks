-- ============================================================
--  BotStats_Server.lua
--  Envia las estadisticas reales de los bots contratados y rol.
--  Eluna / AzerothCore + NPCBots
-- ============================================================

local PREFIX = "BSTATS"

-- ------------------------------------------------------------
-- Conversion de bitmask de roles a texto legible
-- Valores de characters_npcbot.roles:
--   0 = DPS (sin flag especial)
--   1 = Tank
--   2 = Healer
--   4 = Ranged DPS
-- ------------------------------------------------------------
local function RoleToString(roleMask)
    roleMask = roleMask or 0
    if roleMask == 0 then return "DPS"    end
    if roleMask == 1 then return "Tank"   end
    if roleMask == 2 then return "Healer" end
    if roleMask == 4 then return "Ranged" end

    -- Combinaciones usando matemáticas puras (compatible con todas las versiones de Lua)
    local parts = {}
    if roleMask % 2 >= 1 then table.insert(parts, "Tank") end
    if math.floor(roleMask / 2) % 2 >= 1 then table.insert(parts, "Healer") end
    if math.floor(roleMask / 4) % 2 >= 1 then table.insert(parts, "Ranged") end
    
    if #parts > 0 then return table.concat(parts, "+") end
    return "DPS"
end

-- ------------------------------------------------------------
-- Funcion principal
-- ------------------------------------------------------------
local function SendBotStats(player)
    local guidLow = player:GetGUIDLow()

    -- 1) Obtener entries, nombres y roles de los bots del jugador
    local botQuery = CharDBQuery(
        "SELECT entry, roles FROM characters_npcbot WHERE owner = " .. guidLow
    )

    if not botQuery then
        player:SendAddonMessage(PREFIX, "NOBOT", 7, player)
        return
    end

    -- Construir mapa entry -> role string
    local botEntries = {}
    local botRoles   = {}
    repeat
        local entry = botQuery:GetUInt32(0)
        local roles = botQuery:GetUInt32(1)
        table.insert(botEntries, entry)
        botRoles[entry] = RoleToString(roles)
    until not botQuery:NextRow()

    if #botEntries == 0 then
        player:SendAddonMessage(PREFIX, "NOBOT", 7, player)
        return
    end

    local entryList = table.concat(botEntries, ",")

    -- 2) Consultar estadisticas reales desde characters_npcbot_stats
    local statsQuery = CharDBQuery([[
        SELECT
            entry,
            maxhealth,
            maxpower,
            strength,
            agility,
            stamina,
            intellect,
            spirit,
            armor,
            defense,
            resHoly,
            resFire,
            resNature,
            resFrost,
            resShadow,
            resArcane,
            blockPct,
            dodgePct,
            parryPct,
            critPct,
            attackPower,
            spellPower,
            spellPen,
            hastePct,
            hitBonusPct,
            expertise,
            armorPenPct
        FROM characters_npcbot_stats
        WHERE entry IN (]] .. entryList .. [[)
    ]])

    if not statsQuery then
        player:SendAddonMessage(PREFIX, "NOSTATS", 7, player)
        return
    end

    -- 3) Enviar una linea por bot con el formato:
    --    STAT;<entry>;<role>;<hp>;<mp>;<str>;<agi>;<sta>;<int>;<spi>;<armor>;<def>;
    --         <rHoly>;<rFire>;<rNat>;<rFro>;<rSha>;<rArc>;
    --         <block%>;<dodge%>;<parry%>;<crit%>;
    --         <ap>;<sp>;<spellPen>;<haste%>;<hit%>;<expertise>;<arpen%>
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

        -- Obtener el rol del mapa (fallback a DPS si no se encuentra)
        local role = botRoles[e] or "DPS"

        local msg = string.format(
            "STAT;%d;%s;%d;%d;%d;%d;%d;%d;%d;%d;%d;%d;%d;%d;%d;%d;%d;%.2f;%.2f;%.2f;%.2f;%d;%d;%d;%.2f;%.2f;%d;%.2f",
            e, role, hp, mp, str, agi, sta, int_, spi, arm, def,
            rHoly, rFire, rNat, rFro, rSha, rArc,
            block, dodge, parry, crit,
            ap, sp, spen, haste, hit, exp, arpen
        )

        player:SendAddonMessage(PREFIX, msg, 7, player)

    until not statsQuery:NextRow()

    -- 4) Fin de transmision
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
-- Comando de chat alternativo: .bstats (util para pruebas)
-- ------------------------------------------------------------
local function OnCommand(event, player, command, chatHandler)
    local cmd = command:match("^(%S+)")
    if not cmd then return end

    if cmd:lower() == "bstats" then
        SendBotStats(player)
        return false
    end
end

-- ------------------------------------------------------------
-- Registro de eventos
-- ------------------------------------------------------------
RegisterServerEvent(30, OnAddonMessage)
RegisterPlayerEvent(42, OnCommand)
