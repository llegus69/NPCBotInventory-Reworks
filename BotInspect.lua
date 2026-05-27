-- ============================================================
-- NPCBotInventory - BotInspect.lua
-- Ventana paperdoll: slots detectados automaticamente + stats
-- Compatible con WotLK 3.3.5
-- ============================================================

local NBI = NPCBotInventory

-- ============================================================
-- MAPA: equipSlot (string de GetItemInfo) -> nombre del slot
-- ============================================================
local EQUIP_SLOT_MAP = {
    INVTYPE_HEAD       = "Head",
    INVTYPE_NECK       = "Neck",
    INVTYPE_SHOULDER   = "Shoulder",
    INVTYPE_CLOAK      = "Back",
    INVTYPE_CHEST      = "Chest",
    INVTYPE_ROBE       = "Chest",
    INVTYPE_BODY       = "Shirt",
    INVTYPE_TABARD     = "Tabard",
    INVTYPE_WRIST      = "Wrist",
    INVTYPE_HAND       = "Hands",
    INVTYPE_WAIST      = "Waist",
    INVTYPE_LEGS       = "Legs",
    INVTYPE_FEET       = "Feet",
    INVTYPE_FINGER     = "Finger1",   -- el segundo anillo se gestiona abajo
    INVTYPE_TRINKET    = "Trinket1",  -- el segundo amuleto se gestiona abajo
    INVTYPE_WEAPON     = "MainHand",
    INVTYPE_2HWEAPON   = "MainHand",
    INVTYPE_WEAPONMAINHAND = "MainHand",
    INVTYPE_WEAPONOFFHAND  = "OffHand",
    INVTYPE_SHIELD     = "OffHand",
    INVTYPE_HOLDABLE   = "OffHand",
    INVTYPE_RANGED     = "Ranged",
    INVTYPE_RANGEDRIGHT = "Ranged",
    INVTYPE_THROWN     = "Ranged",
    INVTYPE_RELIC      = "Ranged",
}

-- Layout visual: posicion de cada slot en la ventana
local SLOT_LAYOUT = {
    { name = "Head",      label = "Head",        x = -120, y =  155 },
    { name = "Neck",      label = "Neck",        x = -120, y =  108 },
    { name = "Shoulder",  label = "Shoulder",    x = -120, y =   61 },
    { name = "Back",      label = "Back",        x = -120, y =   14 },
    { name = "Chest",     label = "Chest",       x = -120, y =  -33 },
    { name = "Shirt",     label = "Shirt",       x = -120, y =  -80 },
    { name = "Tabard",    label = "Tabard",      x = -120, y = -127 },
    { name = "Wrist",     label = "Wrist",       x = -120, y = -174 },
    { name = "Hands",     label = "Hands",       x =  106, y =  155 },
    { name = "Waist",     label = "Waist",       x =  106, y =  108 },
    { name = "Legs",      label = "Legs",        x =  106, y =   61 },
    { name = "Feet",      label = "Feet",        x =  106, y =   14 },
    { name = "Finger1",   label = "Ring 1",      x =  106, y =  -33 },
    { name = "Finger2",   label = "Ring 2",      x =  106, y =  -80 },
    { name = "Trinket1",  label = "Trinket 1",   x =  106, y = -127 },
    { name = "Trinket2",  label = "Trinket 2",   x =  106, y = -174 },
    { name = "MainHand",  label = "Main Hand",   x = -120, y = -221 },
    { name = "OffHand",   label = "Off Hand",    x =  106, y = -221 },
    { name = "Ranged",    label = "Ranged",      x =    3, y = -221 },
}

local SLOT_SZ  = 37
local WIN_W    = 420
local WIN_H    = 600

local QUALITY_COLOR = {
    [0] = {0.62, 0.62, 0.62},
    [1] = {1,    1,    1   },
    [2] = {0.12, 1,    0   },
    [3] = {0,    0.44, 0.87},
    [4] = {0.64, 0.21, 0.93},
    [5] = {1,    0.5,  0   },
}

-- ============================================================
-- HELPER
-- ============================================================
local function GoldBorder(frame)
    frame:SetBackdrop({
        bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 8, edgeSize = 10,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    frame:SetBackdropColor(0.08, 0.08, 0.1, 1)
    frame:SetBackdropBorderColor(0.5, 0.42, 0.1, 1)
end

-- ============================================================
-- VENTANA PRINCIPAL
-- ============================================================
local inspectFrame = CreateFrame("Frame", "NBI_InspectFrame", UIParent)
inspectFrame:SetSize(WIN_W, WIN_H)
inspectFrame:SetPoint("CENTER")
inspectFrame:SetFrameStrata("DIALOG")
inspectFrame:SetMovable(true)
inspectFrame:EnableMouse(true)
inspectFrame:RegisterForDrag("LeftButton")
inspectFrame:SetScript("OnDragStart", inspectFrame.StartMoving)
inspectFrame:SetScript("OnDragStop",  inspectFrame.StopMovingOrSizing)
inspectFrame:SetBackdrop({
    bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 32,
    insets = { left = 8, right = 8, top = 8, bottom = 8 },
})
inspectFrame:SetBackdropColor(0.05, 0.05, 0.08, 0.98)
inspectFrame:SetBackdropBorderColor(0.4, 0.35, 0.1, 1)
inspectFrame:Hide()

-- Cabecera
local inspectHeader = CreateFrame("Frame", nil, inspectFrame)
inspectHeader:SetPoint("TOPLEFT",  inspectFrame, "TOPLEFT",  0, 0)
inspectHeader:SetPoint("TOPRIGHT", inspectFrame, "TOPRIGHT", 0, 0)
inspectHeader:SetHeight(38)
inspectHeader:SetBackdrop({ bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background" })
inspectHeader:SetBackdropColor(0.08, 0.07, 0.03, 1)

local inspectTitle = inspectHeader:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
inspectTitle:SetPoint("CENTER", inspectHeader, "CENTER", 0, 0)
inspectTitle:SetTextColor(1, 0.82, 0, 1)
inspectTitle:SetText("Bot Inspect")

local sep = inspectFrame:CreateTexture(nil, "ARTWORK")
sep:SetHeight(1)
sep:SetPoint("TOPLEFT",  inspectFrame, "TOPLEFT",  10, -38)
sep:SetPoint("TOPRIGHT", inspectFrame, "TOPRIGHT", -10, -38)
sep:SetTexture(0.5, 0.42, 0.1, 0.6)

local inspectClose = CreateFrame("Button", nil, inspectFrame, "UIPanelCloseButton")
inspectClose:SetPoint("TOPRIGHT", inspectFrame, "TOPRIGHT", 2, 2)
inspectClose:SetScript("OnClick", function() inspectFrame:Hide() end)

-- Creditos en la parte inferior
local creditsLabel = inspectFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
creditsLabel:SetPoint("BOTTOM", inspectFrame, "BOTTOM", 0, 8)
creditsLabel:SetTextColor(0.4, 0.4, 0.4, 1)
creditsLabel:SetText("Creado por Lleguito")

-- Fondo central decorativo
local centerBg = CreateFrame("Frame", nil, inspectFrame)
centerBg:SetSize(140, 360)
centerBg:SetPoint("CENTER", inspectFrame, "CENTER", -7, -15)
centerBg:SetBackdrop({
    bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 12,
    insets = { left = 3, right = 3, top = 3, bottom = 3 },
})
centerBg:SetBackdropColor(0.05, 0.05, 0.1, 0.5)
centerBg:SetBackdropBorderColor(0.3, 0.25, 0.1, 0.6)

local botNameLabel = centerBg:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
botNameLabel:SetPoint("TOP", centerBg, "TOP", 0, -10)
botNameLabel:SetTextColor(1, 0.82, 0, 1)
botNameLabel:SetText("")

local botGSLabel = centerBg:CreateFontString(nil, "OVERLAY", "GameFontNormal")
botGSLabel:SetPoint("TOP", botNameLabel, "BOTTOM", 0, -4)
botGSLabel:SetTextColor(0.2, 0.9, 0.4, 1)
botGSLabel:SetText("")

local botTypeLabel = centerBg:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
botTypeLabel:SetPoint("TOP", botGSLabel, "BOTTOM", 0, -4)
botTypeLabel:SetTextColor(0.5, 0.5, 0.5, 1)
botTypeLabel:SetText("NPCBot")

-- ============================================================
-- RETRATO DEL BOT: busca el bot por nombre entre party1-party4
-- Si esta en el grupo muestra su retrato 3D, si no un icono
-- ============================================================
local portraitModel = CreateFrame("PlayerModel", "NBI_PortraitModel", centerBg)
portraitModel:SetSize(110, 180)
portraitModel:SetPoint("TOP", botTypeLabel, "BOTTOM", 0, -8)
portraitModel:SetBackdrop({
    bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 8, edgeSize = 8,
    insets = { left = 2, right = 2, top = 2, bottom = 2 },
})
portraitModel:SetBackdropColor(0.05, 0.05, 0.1, 0.8)
portraitModel:SetBackdropBorderColor(0.4, 0.35, 0.1, 0.8)

-- Placeholder cuando el bot no esta en el grupo
local portraitPlaceholder = centerBg:CreateTexture(nil, "ARTWORK")
portraitPlaceholder:SetSize(64, 64)
portraitPlaceholder:SetPoint("CENTER", portraitModel, "CENTER", 0, 0)
portraitPlaceholder:SetTexture("Interface\\CHARACTERFRAME\\TempPortraitAlphaMask")
portraitPlaceholder:SetAlpha(0.3)

local portraitLabel = centerBg:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
portraitLabel:SetPoint("TOP", portraitModel, "BOTTOM", 0, -4)
portraitLabel:SetTextColor(0.45, 0.45, 0.45, 1)
portraitLabel:SetText("Not in party")

-- Boton "Stats" debajo del label de grupo
local statsBtn = CreateFrame("Button", nil, centerBg, "UIPanelButtonTemplate")
statsBtn:SetSize(90, 22)
statsBtn:SetPoint("TOP", portraitLabel, "BOTTOM", 0, -6)
statsBtn:SetText("Stats")
statsBtn:SetScript("OnClick", function()
    if inspectFrame.currentBot then
        NBI.OpenStatsWindow(inspectFrame.currentBot)
    end
end)
statsBtn:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText("Ver estadisticas reales del bot")
    GameTooltip:Show()
end)
statsBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)

-- ============================================================
-- FUNCION: busca el unitId del bot por nombre entre los miembros del grupo
local function FindBotUnitId(botName)
    for i = 1, 4 do
        local unit = "party" .. i
        if UnitExists(unit) then
            local name = UnitName(unit)
            if name and name == botName then
                return unit
            end
        end
    end
    -- Comprobar tambien "player" por si acaso
    if UnitName("player") == botName then
        return "player"
    end
    return nil
end

inspectFrame.portraitModel = portraitModel
inspectFrame.FindBotUnitId = FindBotUnitId

-- ============================================================
-- SLOTS DE EQUIPO
-- ============================================================
inspectFrame.slotFrames = {}

for _, slotInfo in ipairs(SLOT_LAYOUT) do
    local sf = CreateFrame("Button", "NBI_Slot_" .. slotInfo.name, inspectFrame)
    sf:SetSize(SLOT_SZ, SLOT_SZ)
    sf:SetPoint("CENTER", inspectFrame, "CENTER", slotInfo.x, slotInfo.y - 10)
    GoldBorder(sf)

    local icon = sf:CreateTexture(nil, "ARTWORK")
    icon:SetPoint("TOPLEFT",     sf, "TOPLEFT",     3, -3)
    icon:SetPoint("BOTTOMRIGHT", sf, "BOTTOMRIGHT", -3,  3)
    icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    icon:SetTexture("Interface\\PaperDollInfoFrame\\UI-PaperDoll-Slot-" .. slotInfo.name)

    local qbar = sf:CreateTexture(nil, "OVERLAY")
    qbar:SetHeight(3)
    qbar:SetPoint("BOTTOMLEFT",  sf, "BOTTOMLEFT",  2, 1)
    qbar:SetPoint("BOTTOMRIGHT", sf, "BOTTOMRIGHT", -2, 1)
    qbar:SetTexture(0.4, 0.4, 0.4, 0)

    local lbl = inspectFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    lbl:SetPoint("TOP", sf, "BOTTOM", 0, -1)
    lbl:SetTextColor(0.45, 0.45, 0.45, 1)
    lbl:SetText(slotInfo.label)

    sf.icon      = icon
    sf.qbar      = qbar
    sf.slotLabel = lbl
    sf.link      = nil
    sf.slotName  = slotInfo.name

    sf:SetScript("OnEnter", function(self)
        if self.link then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetHyperlink(self.link)
            GameTooltip:Show()
        end
    end)
    sf:SetScript("OnLeave", function() GameTooltip:Hide() end)

    inspectFrame.slotFrames[slotInfo.name] = sf
end

-- ============================================================
-- VENTANA DE ESTADISTICAS (secundaria, bajo demanda)
-- ============================================================
local STATS_WIN_W = 220
local STATS_WIN_H = 520

local statsWin = CreateFrame("Frame", "NBI_StatsWindow", UIParent)
statsWin:SetSize(STATS_WIN_W, STATS_WIN_H)
statsWin:SetPoint("LEFT", inspectFrame, "RIGHT", 6, 0)
statsWin:SetFrameStrata("DIALOG")
statsWin:SetMovable(true)
statsWin:EnableMouse(true)
statsWin:RegisterForDrag("LeftButton")
statsWin:SetScript("OnDragStart", statsWin.StartMoving)
statsWin:SetScript("OnDragStop",  statsWin.StopMovingOrSizing)
statsWin:SetBackdrop({
    bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 32,
    insets = { left = 8, right = 8, top = 8, bottom = 8 },
})
statsWin:SetBackdropColor(0.05, 0.05, 0.08, 0.98)
statsWin:SetBackdropBorderColor(0.4, 0.35, 0.1, 1)
statsWin:Hide()

-- Cabecera
local statsWinHeader = CreateFrame("Frame", nil, statsWin)
statsWinHeader:SetPoint("TOPLEFT",  statsWin, "TOPLEFT",  0, 0)
statsWinHeader:SetPoint("TOPRIGHT", statsWin, "TOPRIGHT", 0, 0)
statsWinHeader:SetHeight(34)
statsWinHeader:SetBackdrop({ bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background" })
statsWinHeader:SetBackdropColor(0.08, 0.07, 0.03, 1)

local statsWinTitle = statsWinHeader:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
statsWinTitle:SetPoint("CENTER", statsWinHeader, "CENTER", 0, 0)
statsWinTitle:SetTextColor(1, 0.82, 0, 1)
statsWinTitle:SetText("Stats")

local statsWinSep = statsWin:CreateTexture(nil, "ARTWORK")
statsWinSep:SetHeight(1)
statsWinSep:SetPoint("TOPLEFT",  statsWin, "TOPLEFT",  10, -34)
statsWinSep:SetPoint("TOPRIGHT", statsWin, "TOPRIGHT", -10, -34)
statsWinSep:SetTexture(0.5, 0.42, 0.1, 0.6)

local statsWinClose = CreateFrame("Button", nil, statsWin, "UIPanelCloseButton")
statsWinClose:SetPoint("TOPRIGHT", statsWin, "TOPRIGHT", 2, 2)
statsWinClose:SetScript("OnClick", function() statsWin:Hide() end)

-- Boton "Actualizar" dentro de la ventana de stats
local statsRefreshBtn = CreateFrame("Button", nil, statsWin, "UIPanelButtonTemplate")
statsRefreshBtn:SetSize(STATS_WIN_W - 24, 22)
statsRefreshBtn:SetPoint("BOTTOM", statsWin, "BOTTOM", 0, 10)
statsRefreshBtn:SetText("Actualizar")
statsRefreshBtn:SetScript("OnClick", function()
    if statsWin.currentBot then
        statsWinTitle:SetText("Cargando...")
        NBI.RequestRealStats()
    end
end)

-- ScrollFrame para las filas de stats
local statsScroll = CreateFrame("ScrollFrame", "NBI_StatsScroll", statsWin, "UIPanelScrollFrameTemplate")
statsScroll:SetPoint("TOPLEFT",     statsWin, "TOPLEFT",     10, -42)
statsScroll:SetPoint("BOTTOMRIGHT", statsWin, "BOTTOMRIGHT", -28, 38)

local statsContent = CreateFrame("Frame", nil, statsScroll)
statsContent:SetSize(STATS_WIN_W - 38, 10)
statsScroll:SetScrollChild(statsContent)

-- Pool de filas de stats (se crean una vez, se reaprovechan)
local statRows = {}
local function GetStatRow(index)
    if not statRows[index] then
        local row = CreateFrame("Frame", nil, statsContent)
        row:SetSize(STATS_WIN_W - 42, 16)
        row:SetPoint("TOPLEFT", statsContent, "TOPLEFT", 2, -2 - (index - 1) * 18)

        local keyLbl = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        keyLbl:SetPoint("LEFT",  row, "LEFT", 2, 0)
        keyLbl:SetPoint("RIGHT", row, "RIGHT", -50, 0)
        keyLbl:SetTextColor(0.75, 0.75, 0.75, 1)
        keyLbl:SetJustifyH("LEFT")
        keyLbl:SetWordWrap(false)

        local valLbl = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        valLbl:SetPoint("RIGHT", row, "RIGHT", -4, 0)
        valLbl:SetJustifyH("RIGHT")

        -- Separador de seccion (se muestra solo cuando es cabecera)
        local secTex = row:CreateTexture(nil, "ARTWORK")
        secTex:SetHeight(1)
        secTex:SetPoint("TOPLEFT",  row, "TOPLEFT",  0, 0)
        secTex:SetPoint("TOPRIGHT", row, "TOPRIGHT", 0, 0)
        secTex:SetTexture(0.5, 0.42, 0.1, 0.4)
        secTex:Hide()

        row.key    = keyLbl
        row.val    = valLbl
        row.secTex = secTex
        statRows[index] = row
    end
    return statRows[index]
end

-- Definicion completa de stats a mostrar, con separadores de seccion
local REAL_STAT_DISPLAY = {
    { section = "Base" },
    { key = "maxhealth",   label = "Max Health",   color = {0.3,  1,    0.3 } },
    { key = "maxpower",    label = "Max Power",     color = {0.3,  0.6,  1   } },
    { key = "strength",    label = "Strength",      color = {1,    0.82, 0   } },
    { key = "agility",     label = "Agility",       color = {1,    0.82, 0   } },
    { key = "stamina",     label = "Stamina",       color = {1,    0.82, 0   } },
    { key = "intellect",   label = "Intellect",     color = {1,    0.82, 0   } },
    { key = "spirit",      label = "Spirit",        color = {1,    0.82, 0   } },
    { section = "Offence" },
    { key = "attackPower", label = "Attack Power",  color = {0.9,  0.5,  0.1 } },
    { key = "spellPower",  label = "Spell Power",   color = {0.5,  0.5,  1   } },
    { key = "spellPen",    label = "Spell Pen",     color = {0.5,  0.5,  1   } },
    { key = "critPct",     label = "Crit",          color = {0.2,  0.9,  0.4 }, fmt = "%.2f%%" },
    { key = "hastePct",    label = "Haste",         color = {0.2,  0.9,  0.4 }, fmt = "%.2f%%" },
    { key = "hitBonusPct", label = "Hit",           color = {0.2,  0.9,  0.4 }, fmt = "%.2f%%" },
    { key = "expertise",   label = "Expertise",     color = {0.2,  0.9,  0.4 } },
    { key = "armorPenPct", label = "Armor Pen",     color = {0.8,  0.8,  0.8 }, fmt = "%.2f%%" },
    { section = "Defence" },
    { key = "armor",       label = "Armor",         color = {0.6,  0.6,  0.8 } },
    { key = "defense",     label = "Defense",       color = {0.4,  0.7,  1   } },
    { key = "dodgePct",    label = "Dodge",         color = {0.4,  0.7,  1   }, fmt = "%.2f%%" },
    { key = "parryPct",    label = "Parry",         color = {0.4,  0.7,  1   }, fmt = "%.2f%%" },
    { key = "blockPct",    label = "Block",         color = {0.4,  0.7,  1   }, fmt = "%.2f%%" },
    { section = "Resistances" },
    { key = "resHoly",     label = "Holy",          color = {1,    1,    0.6 } },
    { key = "resFire",     label = "Fire",          color = {1,    0.4,  0.1 } },
    { key = "resNature",   label = "Nature",        color = {0.3,  0.9,  0.2 } },
    { key = "resFrost",    label = "Frost",         color = {0.5,  0.8,  1   } },
    { key = "resShadow",   label = "Shadow",        color = {0.7,  0.3,  0.9 } },
    { key = "resArcane",   label = "Arcane",        color = {0.9,  0.3,  0.9 } },
}

local function PopulateStatsWindow(botName, realStats)
    statsWinTitle:SetText(botName .. " — Stats")
    statsWin.currentBot = botName

    local rowIndex = 1
    -- Ocultar filas sobrantes del uso anterior
    for _, row in ipairs(statRows) do
        row:Hide()
        row.secTex:Hide()
    end

    for _, entry in ipairs(REAL_STAT_DISPLAY) do
        if entry.section then
            -- Fila de cabecera de seccion
            local row = GetStatRow(rowIndex)
            row.key:SetText(entry.section)
            row.key:SetTextColor(1, 0.82, 0, 1)
            row.val:SetText("")
            if rowIndex > 1 then row.secTex:Show() end
            row:Show()
            rowIndex = rowIndex + 1
        else
            local val = realStats and realStats[entry.key]
            if val and val ~= 0 then
                local row = GetStatRow(rowIndex)
                row.key:SetText(entry.label)
                row.key:SetTextColor(0.75, 0.75, 0.75, 1)
                row.secTex:Hide()
                local displayVal = entry.fmt and string.format(entry.fmt, val) or tostring(val)
                local c = entry.color
                row.val:SetText(displayVal)
                row.val:SetTextColor(c[1], c[2], c[3])
                row:Show()
                rowIndex = rowIndex + 1
            end
        end
    end

    statsContent:SetHeight(math.max((rowIndex - 1) * 18 + 4, 10))
end

-- Funcion publica para abrir la ventana de stats
function NBI.OpenStatsWindow(botName)
    local entry = NBI.botEntryByName and NBI.botEntryByName[botName]
    local realStats = nil
    if entry then
        realStats = NBI.botRealStats[entry]
    else
        -- Fallback si solo hay un bot
        local count = 0
        for _ in pairs(NBI.botRealStats) do count = count + 1 end
        if count == 1 then
            for _, s in pairs(NBI.botRealStats) do realStats = s break end
        end
    end

    PopulateStatsWindow(botName, realStats)

    if not statsWin:IsShown() then
        statsWin:ClearAllPoints()
        statsWin:SetPoint("LEFT", inspectFrame, "RIGHT", 6, 0)
        statsWin:Show()
    end
    statsWin:Raise()

    -- Si no hay datos todavia, solicitarlos al servidor
    if not realStats then
        statsWinTitle:SetText("Cargando...")
        NBI.RequestRealStats()
    end
end

-- ============================================================
-- FUNCION PRINCIPAL
-- ============================================================
function NBI.OpenInspect(botName)
    local inventory = NBI.botInventories[botName]

    if not inventory then
        print("|cffFFD700[NPCBotInventory]|r No data for: " .. botName)
        return
    end

    -- Guardar el bot activo (usado por el boton Stats y por OnRealStatsUpdated)
    inspectFrame.currentBot = botName

    inspectTitle:SetText(botName)
    botNameLabel:SetText(botName)
    botGSLabel:SetText("")
    botTypeLabel:SetText("NPCBot")

    -- Buscar el bot en el grupo y cargar su retrato
    local unitId = FindBotUnitId(botName)
    if unitId then
        portraitModel:SetUnit(unitId)
        portraitPlaceholder:SetAlpha(0)
        portraitLabel:SetText(unitId)
    else
        portraitModel:ClearModel()
        portraitPlaceholder:SetAlpha(0.3)
        portraitLabel:SetText("Not in party")
    end

    -- Limpiar slots
    for _, sf in pairs(inspectFrame.slotFrames) do
        sf.icon:SetTexture("Interface\\PaperDollInfoFrame\\UI-PaperDoll-Slot-" .. sf.slotName)
        sf.icon:SetTexCoord(0, 1, 0, 1)
        sf.qbar:SetTexture(0.4, 0.4, 0.4, 0)
        sf.link = nil
        sf:SetBackdropBorderColor(0.5, 0.42, 0.1, 1)
    end

    -- Rellenar slots detectando el tipo de cada item automaticamente
    if inventory then
        for _, link in ipairs(inventory) do
            local _, _, _, _, _, _, _, _, equipSlot, texture = GetItemInfo(link)

            if not equipSlot then
                local itemID = link:match("item:(%d+)")
                if itemID then GetItemInfo(tonumber(itemID)) end
            end

            if equipSlot and equipSlot ~= "" then
                local slotName = EQUIP_SLOT_MAP[equipSlot]

                if slotName == "Finger1" and inspectFrame.slotFrames["Finger1"].link then
                    slotName = "Finger2"
                end
                if slotName == "Trinket1" and inspectFrame.slotFrames["Trinket1"].link then
                    slotName = "Trinket2"
                end

                if slotName then
                    local sf = inspectFrame.slotFrames[slotName]
                    if sf and not sf.link then
                        if texture then
                            sf.icon:SetTexture(texture)
                            sf.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
                        end
                        sf.link = link

                        local _, _, quality = GetItemInfo(link)
                        if quality and QUALITY_COLOR[quality] then
                            local qc = QUALITY_COLOR[quality]
                            sf:SetBackdropBorderColor(qc[1], qc[2], qc[3], 1)
                            sf.qbar:SetTexture(qc[1], qc[2], qc[3], 0.9)
                        end
                    end
                end
            end
        end
    end

    inspectFrame:Show()
    inspectFrame:Raise()
end

-- ============================================================
-- SLASH COMMAND
-- ============================================================

-- Callback: cuando llegan stats reales del servidor, refrescar la ventana de stats si esta abierta
function NBI.OnRealStatsUpdated()
    if statsWin:IsShown() and statsWin.currentBot then
        NBI.OpenStatsWindow(statsWin.currentBot)
    end
end
local origSlash = SlashCmdList["NBOTINV"]
SlashCmdList["NBOTINV"] = function(msg)
    msg = msg:trim()
    local botName = msg:match("^inspect%s+(.+)$")
    if botName then
        NBI.OpenInspect(botName)
        return
    end
    origSlash(msg)
end

print("|cffFFD700[NPCBotInventory]|r BotInspect loaded. /botinv inspect <name>")
