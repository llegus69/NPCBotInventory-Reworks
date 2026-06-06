-- ============================================================
-- NPCBotInventory - Core.lua
-- Logica de datos: captura mensajes, guarda y carga inventarios
-- Autor: Lleguito | Version: 3.6 (Soporte de Talentos Fijo) | WotLK 3.3.5
-- ============================================================

NPCBotInventory = NPCBotInventory or {}
local NBI = NPCBotInventory

NBI.botInventories = {}
NBI.botStats       = {}
NBI.botRealStats   = {}
NBI.botRoles       = {}   -- [entry] = "Tank" / "Healer" / "DPS" / "Ranged"
NBI.botClasses     = {}   -- [entry] = "WARRIOR", "PALADIN", etc.
NBI.botEntryByName = {}   -- [botName] = entry (numero)
NBI.playerName     = nil
NBI.lastCallTime   = 0

local BSTATS_PREFIX = "BSTATS"

local REAL_STAT_KEYS = {
    "entry", "role",
    "maxhealth", "maxpower",
    "strength", "agility", "stamina", "intellect", "spirit",
    "armor", "defense",
    "resHoly", "resFire", "resNature", "resFrost", "resShadow", "resArcane",
    "blockPct", "dodgePct", "parryPct", "critPct",
    "attackPower", "spellPower", "spellPen",
    "hastePct", "hitBonusPct", "expertise", "armorPenPct",
}

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
        if stats.role then NBI.botRoles[botEntry] = stats.role end
        if stats.name then NBI.botEntryByName[stats.name] = botEntry end
        if stats.class then NBI.botClasses[botEntry] = stats.class end
    end

    if NBI.OnDataLoaded then NBI.OnDataLoaded() end
end

local function OnChatMessage(self, event, message, sender, ...)
    if event ~= "CHAT_MSG_MONSTER_WHISPER" then return end

    local currentTime = GetTime()

    if (currentTime - NBI.lastCallTime) >= 2 then
        NBI.botInventories[sender] = {}
        NBI.botStats[sender]       = ""
    end

    local guid = select(10, ...) 
    if guid and type(guid) == "string" then
        local high = string.sub(guid, 1, 5)
        if high == "0xF13" or high == "0xF15" then
            local entry = tonumber(string.sub(guid, 7, 12), 16)
            if entry then
                NBI.botEntryByName[sender] = entry
            end
        end
    end

    local key, val = message:match("^([%a][%a%s]-)%s*[:%s]%s*([%d%.]+%%?)%s*$")
    if key and val then
        NBI.botStats[sender] = (NBI.botStats[sender] or "") .. key .. ": " .. val .. "\n"
        NBIStatsDB[NBI.playerName] = NBIStatsDB[NBI.playerName] or {}
        NBIStatsDB[NBI.playerName][sender] = NBI.botStats[sender]
        NBI.lastCallTime = currentTime
        return
    end

    local link = string.match(message, "|H(.*)|h%[(.-)%]|h")
    if link then
        NBI.botInventories[sender] = NBI.botInventories[sender] or {}
        table.insert(NBI.botInventories[sender], link)
        BotInventoryDB[NBI.playerName] = BotInventoryDB[NBI.playerName] or {}
        BotInventoryDB[NBI.playerName][sender] = NBI.botInventories[sender]
        if NBI.OnBotDataUpdated then NBI.OnBotDataUpdated(sender) end
    end

    NBI.lastCallTime = currentTime
end

local function OnAddonMessage(self, event, prefix, msg, channel, sender)
    if prefix ~= BSTATS_PREFIX then return end

    if msg == "END" then
        if NBI.OnRealStatsUpdated then NBI.OnRealStatsUpdated() end
        return
    end

    if msg == "NOBOT" or msg == "NOSTATS" then return end

    local cmd = msg:match("^(%a+);")
    if cmd ~= "STAT" then return end

    local values = {}
    for v in msg:gmatch("[^;]+") do table.insert(values, v) end
    if #values < 3 then return end

    local entry = tonumber(values[2])
    if not entry then return end

    local role = values[3] or "DPS"
    NBI.botRoles[entry] = role

    local stats = { role = role }
    for i = 3, #REAL_STAT_KEYS do
        local key = REAL_STAT_KEYS[i]
        local raw = values[i + 1]
        stats[key] = tonumber(raw) or 0
    end

    -- Mapeos de Clase (Posición 30) y Nombre real (Posición 31)
    local botClass = values[30]
    local botName = values[31]

    if botClass and botClass ~= "UNKNOWN" then
        NBI.botClasses[entry] = botClass
        stats.class = botClass
    end

    if botName then
        NBI.botEntryByName[botName] = entry
        stats.name = botName
    end

    NBI.botRealStats[entry] = stats

    NBIRealStatsDB = NBIRealStatsDB or {}
    NBIRealStatsDB[NBI.playerName] = NBIRealStatsDB[NBI.playerName] or {}
    NBIRealStatsDB[NBI.playerName][entry] = stats
end

function NBI.RequestRealStats()
    if IsLoggedIn() then
        SendAddonMessage(BSTATS_PREFIX, "REQUEST", "WHISPER", UnitName("player"))
    end
end

function NBI.ClearAll()
    if BotInventoryDB[NBI.playerName] then wipe(BotInventoryDB[NBI.playerName]) end
    if NBIStatsDB[NBI.playerName] then wipe(NBIStatsDB[NBI.playerName]) end
    if NBIRealStatsDB and NBIRealStatsDB[NBI.playerName] then wipe(NBIRealStatsDB[NBI.playerName]) end
    
    wipe(NBI.botInventories)
    wipe(NBI.botStats)
    wipe(NBI.botRealStats)
    wipe(NBI.botRoles)
    wipe(NBI.botClasses)
    wipe(NBI.botEntryByName)
    
    if NBI.OnDataCleared then NBI.OnDataCleared() end
    print("|cff00ff96[NPCBotInventory]|r Inventarios y stats borrados.")
end

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