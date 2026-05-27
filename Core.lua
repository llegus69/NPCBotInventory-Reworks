-- ============================================================
-- NPCBotInventory - Core.lua
-- Logica de datos: captura mensajes, guarda y carga inventarios
-- Autor: Lleguito | Version: 3.0 | WotLK 3.3.5
-- ============================================================

NPCBotInventory = NPCBotInventory or {}
local NBI = NPCBotInventory

NBI.botInventories = {}
NBI.botStats       = {}
NBI.botRealStats   = {}   -- stats reales enviadas por el servidor via AddonMessage
NBI.playerName     = nil
NBI.lastCallTime   = 0

-- Prefijo del servidor (debe coincidir con BotStats_Server.lua)
local BSTATS_PREFIX = "BSTATS"

-- Claves de las stats en el orden del mensaje S; del servidor
local REAL_STAT_KEYS = {
    "entry", "maxhealth", "maxpower",
    "strength", "agility", "stamina", "intellect", "spirit",
    "armor", "defense",
    "resHoly", "resFire", "resNature", "resFrost", "resShadow", "resArcane",
    "blockPct", "dodgePct", "parryPct", "critPct",
    "attackPower", "spellPower", "spellPen",
    "hastePct", "hitBonusPct", "expertise", "armorPenPct",
}

-- ============================================================
-- CARGA de SavedVariables al iniciar
-- ============================================================
local function OnAddonLoaded(addonName)
    if addonName ~= "NPCBotInventory" then return end

    NBI.playerName = UnitName("player")

    BotInventoryDB = BotInventoryDB or {}
    BotInventoryDB[NBI.playerName] = BotInventoryDB[NBI.playerName] or {}
    for botName, inventory in pairs(BotInventoryDB[NBI.playerName]) do
        NBI.botInventories[botName] = inventory
    end

    NBIStatsDB = NBIStatsDB or {}
    NBIStatsDB[NBI.playerName] = NBIStatsDB[NBI.playerName] or {}
    for botName, stats in pairs(NBIStatsDB[NBI.playerName]) do
        NBI.botStats[botName] = stats
    end

    NBIRealStatsDB = NBIRealStatsDB or {}
    NBIRealStatsDB[NBI.playerName] = NBIRealStatsDB[NBI.playerName] or {}
    for botEntry, stats in pairs(NBIRealStatsDB[NBI.playerName]) do
        NBI.botRealStats[botEntry] = stats
    end

    if NBI.OnDataLoaded then
        NBI.OnDataLoaded()
    end
end

-- ============================================================
-- CAPTURA de CHAT_MSG_MONSTER_WHISPER
-- Los bots envian items como links y stats como "GS: 4045"
-- ============================================================
local function OnChatMessage(self, event, message, sender)
    if event ~= "CHAT_MSG_MONSTER_WHISPER" then return end

    local currentTime = GetTime()

    -- Nueva sesion de consulta si han pasado mas de 2 segundos
    if (currentTime - NBI.lastCallTime) >= 2 then
        NBI.botInventories[sender] = {}
        NBI.botStats[sender]       = ""
    end

    -- 1. Intentar parsear como stat: "GS: 4045" o "Strength: 450"
    local key, val = message:match("^([%a][%a%s]-)%s*[:%s]%s*([%d%.]+%%?)%s*$")
    if key and val then
        NBI.botStats[sender] = (NBI.botStats[sender] or "") .. key .. ": " .. val .. "\n"

        NBIStatsDB[NBI.playerName] = NBIStatsDB[NBI.playerName] or {}
        NBIStatsDB[NBI.playerName][sender] = NBI.botStats[sender]

        NBI.lastCallTime = currentTime
        return
    end

    -- 2. Intentar parsear como item link
    local link = string.match(message, "|H(.*)|h%[(.-)%]|h")
    if link then
        NBI.botInventories[sender] = NBI.botInventories[sender] or {}
        table.insert(NBI.botInventories[sender], link)

        BotInventoryDB[NBI.playerName] = BotInventoryDB[NBI.playerName] or {}
        BotInventoryDB[NBI.playerName][sender] = NBI.botInventories[sender]

        if NBI.OnBotDataUpdated then
            NBI.OnBotDataUpdated(sender)
        end
    end

    NBI.lastCallTime = currentTime
end

-- ============================================================
-- Borrar todos los inventarios y stats
-- ============================================================
function NBI.ClearAll()
    if BotInventoryDB[NBI.playerName] then
        wipe(BotInventoryDB[NBI.playerName])
    end
    if NBIStatsDB[NBI.playerName] then
        wipe(NBIStatsDB[NBI.playerName])
    end
    if NBIRealStatsDB and NBIRealStatsDB[NBI.playerName] then
        wipe(NBIRealStatsDB[NBI.playerName])
    end
    wipe(NBI.botInventories)
    wipe(NBI.botStats)
    wipe(NBI.botRealStats)
    if NBI.OnDataCleared then
        NBI.OnDataCleared()
    end
    print("|cff00ff96[NPCBotInventory]|r Inventarios y stats borrados.")
end

-- ============================================================
-- CAPTURA de mensajes addon del servidor (stats reales)
-- El servidor envia mensajes con prefijo BSTATS
-- ============================================================
local function OnAddonMessage(self, event, prefix, msg, channel, sender)
    if prefix ~= BSTATS_PREFIX then return end

    if msg == "END" then
        -- El servidor termino de enviar. Notificar a la UI.
        if NBI.OnRealStatsUpdated then
            NBI.OnRealStatsUpdated()
        end
        return
    end

    if msg == "NOBOT" or msg == "NOSTATS" then return end

    -- Parsear linea: STAT;<entry>;<hp>;<mp>;...
    local cmd = msg:match("^(%a+);")
    if cmd ~= "STAT" then return end

    local values = {}
    for v in msg:gmatch("[^;]+") do
        table.insert(values, v)
    end
    -- values[1] = "STAT", values[2] = entry, values[3]... = stats
    if #values < 2 then return end

    local entry = tonumber(values[2])
    if not entry then return end

    local stats = {}
    for i, key in ipairs(REAL_STAT_KEYS) do
        local raw = values[i + 1]  -- +1 porque values[1]="STAT"
        stats[key] = tonumber(raw) or 0
    end

    -- Guardar indexado por entry (numero) para busqueda rapida
    NBI.botRealStats[entry] = stats

    -- Persistir en SavedVariables
    NBIRealStatsDB = NBIRealStatsDB or {}
    NBIRealStatsDB[NBI.playerName] = NBIRealStatsDB[NBI.playerName] or {}
    NBIRealStatsDB[NBI.playerName][entry] = stats
end

-- ============================================================
-- Solicitar stats al servidor
-- Llama esto cuando quieras refrescar (al abrir el inspect, etc.)
-- ============================================================
function NBI.RequestRealStats()
    if IsLoggedIn() then
        SendAddonMessage(BSTATS_PREFIX, "REQUEST", "WHISPER", UnitName("player"))
    end
end

-- ============================================================
-- EVENTOS
-- ============================================================
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("CHAT_MSG_MONSTER_WHISPER")
eventFrame:RegisterEvent("CHAT_MSG_ADDON")
eventFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        OnAddonLoaded(...)
    elseif event == "CHAT_MSG_MONSTER_WHISPER" then
        OnChatMessage(self, event, ...)
    elseif event == "CHAT_MSG_ADDON" then
        OnAddonMessage(self, event, ...)
    end
end)
