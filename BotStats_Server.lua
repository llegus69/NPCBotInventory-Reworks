-- ============================================================
--  BotStats_Server.lua
--  Envia las estadisticas reales de los bots contratados
--  al cliente via AddonMessage (Eluna / AzerothCore + NPCBots)
-- ============================================================
-- PREFIJO: debe coincidir con el que use tu addon cliente
local PREFIX = "BSTATS"

-- ------------------------------------------------------------
-- Funcion principal: consulta y envia stats de todos los bots
-- del jugador que hace la peticion
-- ------------------------------------------------------------
local function SendBotStats(player)
    local guidLow = player:GetGUIDLow()

    -- 1) Obtener los entries de los bots contratados por este jugador
    local botQuery = CharDBQuery(
        "SELECT entry FROM characters_npcbot WHERE owner = " .. guidLow
    )

    if not botQuery then
        -- Sin bots: notificar al cliente y salir
        player:SendAddonMessage(PREFIX, "NOBOT", 7, player)
        return
    end

    local botEntries = {}
    repeat
        table.insert(botEntries, botQuery:GetUInt32(0))
    until not botQuery:NextRow()

    if #botEntries == 0 then
        player:SendAddonMessage(PREFIX, "NOBOT", 7, player)
        return
    end

    local entryList = table.concat(botEntries, ",")

    -- 2) Consultar la tabla de estadisticas reales
    --    characters_npcbot_stats se actualiza en tiempo real por el modulo NPCBots
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
        -- La tabla existe pero no hay filas aun (bot recien contratado)
        player:SendAddonMessage(PREFIX, "NOSTATS", 7, player)
        return
    end

    -- 3) Enviar una linea por bot con el formato:
    --    STAT;<entry>;<hp>;<mp>;<str>;<agi>;<sta>;<int>;<spi>;<armor>;<def>;
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

        local msg = string.format(
            "STAT;%d;%d;%d;%d;%d;%d;%d;%d;%d;%d;%d;%d;%d;%d;%d;%d;%.2f;%.2f;%.2f;%.2f;%d;%d;%d;%.2f;%.2f;%d;%.2f",
            e, hp, mp, str, agi, sta, int_, spi, arm, def,
            rHoly, rFire, rNat, rFro, rSha, rArc,
            block, dodge, parry, crit,
            ap, sp, spen, haste, hit, exp, arpen
        )

        player:SendAddonMessage(PREFIX, msg, 7, player)

    until not statsQuery:NextRow()

    -- 4) Señal de fin de transmision para que el cliente sepa que ya llego todo
    player:SendAddonMessage(PREFIX, "END", 7, player)
end

-- ------------------------------------------------------------
-- Manejador de mensajes addon entrantes desde el cliente
-- El addon debe enviar: PREFIX + "REQUEST" para pedir las stats
-- ------------------------------------------------------------
local function OnAddonMessage(event, sender, msgType, prefix, msg, target)
    if prefix ~= PREFIX then return end

    if msg == "REQUEST" then
        SendBotStats(sender)
        return false  -- Consumir el evento
    end
end

-- ------------------------------------------------------------
-- Comando de chat alternativo: .bstats  (util para pruebas)
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
-- Evento 30 = ADDON_EVENT_ON_MESSAGE (mensaje addon del cliente)
-- Evento 42 = PLAYER_EVENT_ON_COMMAND (comando de chat)
-- ------------------------------------------------------------
RegisterServerEvent(30, OnAddonMessage)
RegisterPlayerEvent(42, OnCommand)
