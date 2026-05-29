-- ============================================================
-- NPCBotInventory - BotInspect.lua
-- Ventana paperdoll: slots detectados automaticamente + stats
-- Compatible con WotLK 3.3.5
-- ============================================================

local NBI = NPCBotInventory

local EQUIP_SLOT_MAP = {
    INVTYPE_HEAD           = "Head",
    INVTYPE_NECK           = "Neck",
    INVTYPE_SHOULDER       = "Shoulder",
    INVTYPE_CLOAK          = "Back",
    INVTYPE_CHEST          = "Chest",
    INVTYPE_ROBE           = "Chest",
    INVTYPE_BODY           = "Shirt",
    INVTYPE_TABARD         = "Tabard",
    INVTYPE_WRIST          = "Wrist",
    INVTYPE_HAND           = "Hands",
    INVTYPE_WAIST          = "Waist",
    INVTYPE_LEGS           = "Legs",
    INVTYPE_FEET           = "Feet",
    INVTYPE_FINGER         = "Finger1",
    INVTYPE_TRINKET        = "Trinket1",
    INVTYPE_WEAPON         = "MainHand",
    INVTYPE_2HWEAPON       = "MainHand",
    INVTYPE_WEAPONMAINHAND = "MainHand",
    INVTYPE_WEAPONOFFHAND  = "OffHand",
    INVTYPE_SHIELD         = "OffHand",
    INVTYPE_HOLDABLE       = "OffHand",
    INVTYPE_RANGED         = "Ranged",
    INVTYPE_RANGEDRIGHT    = "Ranged",
    INVTYPE_THROWN         = "Ranged",
    INVTYPE_RELIC          = "Ranged",
}

-- Distribución de casillas estilo Armería
local SLOT_LAYOUT = {
    -- Columna Izquierda
    { name = "Head",      label = "Cabeza",      x = -330, y =  180 },
    { name = "Neck",      label = "Cuello",      x = -330, y =  135 },
    { name = "Shoulder",  label = "Hombros",     x = -330, y =   90 },
    { name = "Back",      label = "Espalda",     x = -330, y =   45 },
    { name = "Chest",     label = "Pecho",       x = -330, y =    0 },
    { name = "Shirt",     label = "Camisa",      x = -330, y =  -45 },
    { name = "Tabard",    label = "Tabardo",     x = -330, y =  -90 },
    { name = "Wrist",     label = "Muñeca",      x = -330, y = -135 },
    
    -- Columna Derecha
    { name = "Hands",     label = "Manos",       x = -70,  y =  180 },
    { name = "Waist",     label = "Cintura",     x = -70,  y =  135 },
    { name = "Legs",      label = "Piernas",     x = -70,  y =   90 },
    { name = "Feet",      label = "Pies",        x = -70,  y =   45 },
    { name = "Finger1",   label = "Anillo 1",    x = -70,  y =    0 },
    { name = "Finger2",   label = "Anillo 2",    x = -70,  y =  -45 },
    { name = "Trinket1",  label = "Abalorio 1",  x = -70,  y =  -90 },
    { name = "Trinket2",  label = "Abalorio 2",  x = -70,  y = -135 },
    
    -- Armas (Alineadas horizontalmente en la misma línea bajo el modelo)
    { name = "MainHand",  label = "Principal",   x = -260, y = -200 },
    { name = "OffHand",   label = "Secundaria",  x = -200, y = -200 },
    { name = "Ranged",    label = "Rango",       x = -140, y = -200 },
}

local SLOT_SZ = 37
local WIN_W   = 760 
local WIN_H   = 550

local QUALITY_COLOR = {
    [0] = {0.62, 0.62, 0.62},
    [1] = {1,    1,    1   },
    [2] = {0.12, 1,    0   },
    [3] = {0,    0.44, 0.87},
    [4] = {0.64, 0.21, 0.93},
    [5] = {1,    0.5,  0   },
}

local SPEC_INFO = {
    WARRIOR_ARMS   = { name = "Armas",        role = "Daño C-C", color = {0.9, 0.2, 0.2} },
    WARRIOR_FURY   = { name = "Furia",        role = "Daño C-C", color = {0.9, 0.2, 0.2} },
    WARRIOR_PROT   = { name = "Protección",   role = "Tanque",   color = {0.4, 0.7, 1.0} },
    PALADIN_HOLY   = { name = "Sagrado",      role = "Sanador",  color = {0.2, 0.9, 0.4} },
    PALADIN_PROT   = { name = "Protección",   role = "Tanque",   color = {0.4, 0.7, 1.0} },
    PALADIN_RET    = { name = "Reprensión",   role = "Daño C-C", color = {0.9, 0.2, 0.2} },
    HUNTER_BM      = { name = "Bestias",      role = "Rango",    color = {1.0, 0.6, 0.1} },
    HUNTER_MM      = { name = "Puntería",     role = "Rango",    color = {1.0, 0.6, 0.1} },
    HUNTER_SURV    = { name = "Supervivencia",role = "Rango",    color = {1.0, 0.6, 0.1} },
    ROGUE_ASS      = { name = "Asesinato",    role = "Daño C-C", color = {0.9, 0.2, 0.2} },
    ROGUE_COMBAT   = { name = "Combate",      role = "Daño C-C", color = {0.9, 0.2, 0.2} },
    ROGUE_SUB      = { name = "Sutileza",     role = "Daño C-C", color = {0.9, 0.2, 0.2} },
    PRIEST_DISC    = { name = "Disciplina",   role = "Sanador",  color = {0.2, 0.9, 0.4} },
    PRIEST_HOLY    = { name = "Sagrado",      role = "Sanador",  color = {0.2, 0.9, 0.4} },
    PRIEST_SHADOW  = { name = "Sombra",       role = "Rango",    color = {1.0, 0.6, 0.1} },
    DK_BLOOD       = { name = "Sangre",       role = "Tanque",   color = {0.4, 0.7, 1.0} },
    DK_FROST       = { name = "Escarcha",     role = "Daño C-C", color = {0.9, 0.2, 0.2} },
    DK_UNHOLY      = { name = "Profano",      role = "Daño C-C", color = {0.9, 0.2, 0.2} },
    SHAMAN_ELEM    = { name = "Elemental",    role = "Rango",    color = {1.0, 0.6, 0.1} },
    SHAMAN_ENH     = { name = "Mejora",       role = "Daño C-C", color = {0.9, 0.2, 0.2} },
    SHAMAN_RESTO   = { name = "Restauración", role = "Sanador",  color = {0.2, 0.9, 0.4} },
    MAGE_ARCANE    = { name = "Arcano",       role = "Rango",    color = {1.0, 0.6, 0.1} },
    MAGE_FIRE      = { name = "Fuego",        role = "Rango",    color = {1.0, 0.6, 0.1} },
    MAGE_FROST     = { name = "Escarcha",     role = "Rango",    color = {1.0, 0.6, 0.1} },
    WARLOCK_AFF    = { name = "Aflicción",    role = "Rango",    color = {1.0, 0.6, 0.1} },
    WARLOCK_DEMO   = { name = "Demonología",  role = "Rango",    color = {1.0, 0.6, 0.1} },
    WARLOCK_DESTRO = { name = "Destrucción",  role = "Rango",    color = {1.0, 0.6, 0.1} },
    DRUID_BALANCE  = { name = "Equilibrio",   role = "Rango",    color = {1.0, 0.6, 0.1} },
    DRUID_FERAL    = { name = "Feral",        role = "Feral",    color = {0.9, 0.5, 0.1} },
    DRUID_RESTO    = { name = "Restauración", role = "Sanador",  color = {0.2, 0.9, 0.4} },
}

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

local inspectFrame = CreateFrame("Frame", "NBI_InspectFrame", UIParent)
inspectFrame:SetSize(WIN_W, WIN_H)
inspectFrame:SetPoint("CENTER")
inspectFrame:SetFrameStrata("DIALOG")
inspectFrame:SetMovable(true)
inspectFrame:EnableMouse(true)
inspectFrame:RegisterForDrag("LeftButton")
inspectFrame:SetScript("OnDragStart", function(self) self:StartMoving() end)
inspectFrame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
inspectFrame:SetBackdrop({
    bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 32,
    insets = { left = 8, right = 8, top = 8, bottom = 8 },
})
inspectFrame:SetBackdropColor(0.05, 0.05, 0.08, 0.98)
inspectFrame:SetBackdropBorderColor(0.4, 0.35, 0.1, 1)
inspectFrame:Hide()

local inspectHeader = CreateFrame("Frame", nil, inspectFrame)
inspectHeader:SetPoint("TOPLEFT",  inspectFrame, "TOPLEFT",  0, 0)
inspectHeader:SetPoint("TOPRIGHT", inspectFrame, "TOPRIGHT", 0, 0)
inspectHeader:SetHeight(52)
inspectHeader:SetBackdrop({ bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background" })
inspectHeader:SetBackdropColor(0.08, 0.07, 0.03, 1)

local inspectTitle = inspectHeader:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
inspectTitle:SetPoint("TOP", inspectHeader, "TOP", 0, -6)
inspectTitle:SetTextColor(1, 0.82, 0, 1)
inspectTitle:SetText("NPCBot Armory")

local inspectSubTitle = inspectHeader:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
inspectSubTitle:SetPoint("TOP", inspectTitle, "BOTTOM", 0, -2)
inspectSubTitle:SetTextColor(0.8, 0.8, 0.8, 1)
inspectSubTitle:SetText("")

local sep = inspectFrame:CreateTexture(nil, "ARTWORK")
sep:SetHeight(1)
sep:SetPoint("TOPLEFT",  inspectFrame, "TOPLEFT",  10, -52)
sep:SetPoint("TOPRIGHT", inspectFrame, "TOPRIGHT", -10, -52)
sep:SetTexture(0.5, 0.42, 0.1, 0.6)

local inspectClose = CreateFrame("Button", nil, inspectFrame, "UIPanelCloseButton")
inspectClose:SetPoint("TOPRIGHT", inspectFrame, "TOPRIGHT", 2, 2)
inspectClose:SetScript("OnClick", function() inspectFrame:Hide() end)

-- Panel del modelo de personaje (Centrado en la parte izquierda)
local centerBg = CreateFrame("Frame", nil, inspectFrame)
centerBg:SetSize(200, 380)
centerBg:SetPoint("CENTER", inspectFrame, "CENTER", -200, 20)
centerBg:SetBackdrop({
    bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 12,
    insets = { left = 3, right = 3, top = 3, bottom = 3 },
})
centerBg:SetBackdropColor(0.05, 0.05, 0.1, 0.5)
centerBg:SetBackdropBorderColor(0.3, 0.25, 0.1, 0.6)

local portraitModel = CreateFrame("PlayerModel", "NBI_PortraitModel", centerBg)
portraitModel:SetSize(186, 366)
portraitModel:SetPoint("CENTER", centerBg, "CENTER", 0, 0)

local portraitPlaceholder = centerBg:CreateTexture(nil, "ARTWORK")
portraitPlaceholder:SetSize(80, 80)
portraitPlaceholder:SetPoint("CENTER", portraitModel, "CENTER", 0, 0)
portraitPlaceholder:SetTexture("Interface\\CHARACTERFRAME\\TempPortraitAlphaMask")
portraitPlaceholder:SetAlpha(0.3)

local function FindBotUnitId(botName)
    for i = 1, 4 do
        local unit = "party" .. i
        if UnitExists(unit) then
            local name = UnitName(unit)
            if name and name == botName then
                local guid = UnitGUID(unit)
                if guid then
                    local high = string.sub(guid, 1, 5)
                    if high == "0xF13" or high == "0xF15" then
                        local entry = tonumber(string.sub(guid, 7, 12), 16)
                        if entry then
                            NBI.botEntryByName[botName] = entry
                            local _, botClass = UnitClass(unit)
                            if botClass then
                                NBI.botClasses[entry] = botClass
                                if NBI.botRealStats[entry] then
                                    NBI.botRealStats[entry].class = botClass
                                    if NBIRealStatsDB and NBIRealStatsDB[NBI.playerName] and NBIRealStatsDB[NBI.playerName][entry] then
                                        NBIRealStatsDB[NBI.playerName][entry].class = botClass
                                    end
                                end
                            end
                        end
                    end
                end
                return unit
            end
        end
    end
    if UnitName("player") == botName then return "player" end
    return nil
end

inspectFrame.portraitModel = portraitModel
inspectFrame.FindBotUnitId = FindBotUnitId
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

-- ==========================================
-- STATS PANEL (Incrustado a la derecha)
-- ==========================================
local statsWin = CreateFrame("Frame", "NBI_StatsWindow", inspectFrame)
statsWin:SetPoint("TOPLEFT", inspectFrame, "TOP", 20, -60)
statsWin:SetPoint("BOTTOMRIGHT", inspectFrame, "BOTTOMRIGHT", -20, 20)
statsWin:SetBackdrop({
    bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 12,
    insets = { left = 3, right = 3, top = 3, bottom = 3 },
})
statsWin:SetBackdropColor(0.05, 0.05, 0.1, 0.5)
statsWin:SetBackdropBorderColor(0.3, 0.25, 0.1, 0.6)

local statsWinHeader = CreateFrame("Frame", nil, statsWin)
statsWinHeader:SetPoint("TOPLEFT",  statsWin, "TOPLEFT",  0, 0)
statsWinHeader:SetPoint("TOPRIGHT", statsWin, "TOPRIGHT", 0, 0)
statsWinHeader:SetHeight(34)

local statsWinTitle = statsWinHeader:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
statsWinTitle:SetPoint("CENTER", statsWinHeader, "CENTER", 0, 0)
statsWinTitle:SetTextColor(1, 0.82, 0, 1)
statsWinTitle:SetText("Estadísticas del Bot")

local statsWinSep = statsWin:CreateTexture(nil, "ARTWORK")
statsWinSep:SetHeight(1)
statsWinSep:SetPoint("TOPLEFT",  statsWin, "TOPLEFT",  10, -34)
statsWinSep:SetPoint("TOPRIGHT", statsWin, "TOPRIGHT", -10, -34)
statsWinSep:SetTexture(0.5, 0.42, 0.1, 0.6)

local statsRefreshBtn = CreateFrame("Button", nil, statsWin, "UIPanelButtonTemplate")
statsRefreshBtn:SetSize(120, 22)
statsRefreshBtn:SetPoint("BOTTOM", statsWin, "BOTTOM", 0, 10)
statsRefreshBtn:SetText("Actualizar Stats")
statsRefreshBtn:SetScript("OnClick", function()
    if inspectFrame.currentBot then
        statsWinTitle:SetText("Cargando...")
        NBI.RequestRealStats()
    end
end)

local statsScroll = CreateFrame("ScrollFrame", "NBI_StatsScroll", statsWin, "UIPanelScrollFrameTemplate")
statsScroll:SetPoint("TOPLEFT",     statsWin, "TOPLEFT",     10, -42)
statsScroll:SetPoint("BOTTOMRIGHT", statsWin, "BOTTOMRIGHT", -28, 38)

local statsContent = CreateFrame("Frame", nil, statsScroll)
statsContent:SetSize(300, 10)
statsScroll:SetScrollChild(statsContent)

local statRows = {}
local function GetStatRow(index)
    if not statRows[index] then
        local row = CreateFrame("Frame", nil, statsContent)
        row:SetSize(300, 16)
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

local REAL_STAT_DISPLAY = {
    { section = "Estadísticas Base" },
    { key = "maxhealth",   label = "Salud Máxima",    color = {0.3,  1,    0.3 } },
    { key = "maxpower",    label = "Maná/Energía",    color = {0.3,  0.6,  1   } },
    { key = "strength",    label = "Fuerza",          color = {1,    0.82, 0   } },
    { key = "agility",     label = "Agilidad",        color = {1,    0.82, 0   } },
    { key = "stamina",     label = "Aguante",         color = {1,    0.82, 0   } },
    { key = "intellect",   label = "Intelecto",       color = {1,    0.82, 0   } },
    { key = "spirit",      label = "Espíritu",        color = {1,    0.82, 0   } },
    { section = "Estadísticas de Combate" },
    { key = "attackPower", label = "Poder de Ataque", color = {0.9,  0.5,  0.1 } },
    { key = "spellPower",  label = "Poder con Hechizos", color = {0.5,  0.5,  1   } },
    { key = "spellPen",    label = "Penetración de Hechizo", color = {0.5,  0.5,  1   } },
    { key = "critPct",     label = "Prob. de Crítico",color = {0.2,  0.9,  0.4 }, fmt = "%.2f%%" },
    { key = "hastePct",    label = "Celeridad",       color = {0.2,  0.9,  0.4 }, fmt = "%.2f%%" },
    { key = "hitBonusPct", label = "Prob. de Golpe",  color = {0.2,  0.9,  0.4 }, fmt = "%.2f%%" },
    { key = "expertise",   label = "Pericia",         color = {0.2,  0.9,  0.4 } },
    { key = "armorPenPct", label = "Penetración de Armadura", color = {0.8,  0.8,  0.8 }, fmt = "%.2f%%" },
    { section = "Defensa" },
    { key = "armor",       label = "Armadura",        color = {0.6,  0.6,  0.8 } },
    { key = "defense",     label = "Índice de Defensa", color = {0.4,  0.7,  1   } },
    { key = "dodgePct",    label = "Esquivar",        color = {0.4,  0.7,  1   }, fmt = "%.2f%%" },
    { key = "parryPct",    label = "Parar",           color = {0.4,  0.7,  1   }, fmt = "%.2f%%" },
    { key = "blockPct",    label = "Bloquear",        color = {0.4,  0.7,  1   }, fmt = "%.2f%%" },
    { section = "Resistencias" },
    { key = "resHoly",     label = "Sagrado",         color = {1,    1,    0.6 } },
    { key = "resFire",     label = "Fuego",           color = {1,    0.4,  0.1 } },
    { key = "resNature",   label = "Naturaleza",      color = {0.3,  0.9,  0.2 } },
    { key = "resFrost",    label = "Escarcha",        color = {0.5,  0.8,  1   } },
    { key = "resShadow",   label = "Sombras",         color = {0.7,  0.3,  0.9 } },
    { key = "resArcane",   label = "Arcano",          color = {0.9,  0.3,  0.9 } },
}

local function PopulateStatsWindow(botName, realStats)
    statsWinTitle:SetText(botName .. " - Stats")

    for _, row in ipairs(statRows) do
        row:Hide()
        row.secTex:Hide()
    end

    local rowIndex = 1
    for _, entry in ipairs(REAL_STAT_DISPLAY) do
        if entry.section then
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

function NBI.OpenInspect(botName)
    local inventory = NBI.botInventories[botName]

    if not inventory then
        print("|cffFFD700[NPCBotInventory]|r No hay datos para: " .. botName)
        return
    end

    inspectFrame.currentBot = botName
    local unitId = FindBotUnitId(botName)

    local gs = ""
    local statsText = NBI.botStats and NBI.botStats[botName]
    if statsText then
        local gsVal = statsText:match("GS%s*:%s*(%d+)")
        if gsVal then gs = "GS: " .. gsVal end
    end

    local roleText = ""
    local entry = NBI.botEntryByName and NBI.botEntryByName[botName]
    if entry then
        local botSpec = NBI.botRoles[entry]
        local info = SPEC_INFO[botSpec]

        if info then
            local rc = info.color
            roleText = string.format("|cff%02x%02x%02x%s (%s)|r",
                rc[1]*255, rc[2]*255, rc[3]*255, info.name, info.role)
        else
            roleText = "|cff888888Sin Spec|r"
        end
    end

    local parts = { "|cffFFD700" .. botName .. "|r" }
    if roleText ~= "" then table.insert(parts, roleText) end
    if gs ~= ""       then table.insert(parts, "|cff33ff66" .. gs .. "|r") end
    inspectSubTitle:SetText(table.concat(parts, "  |  "))

    if unitId then
        portraitModel:SetUnit(unitId)
        portraitPlaceholder:SetAlpha(0)
    else
        portraitModel:ClearModel()
        portraitPlaceholder:SetAlpha(0.3)
    end

    for _, sf in pairs(inspectFrame.slotFrames) do
        sf.icon:SetTexture("Interface\\PaperDollInfoFrame\\UI-PaperDoll-Slot-" .. sf.slotName)
        sf.icon:SetTexCoord(0, 1, 0, 1)
        sf.qbar:SetTexture(0.4, 0.4, 0.4, 0)
        sf.link = nil
        sf:SetBackdropBorderColor(0.5, 0.42, 0.1, 1)
    end

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

    -- Cargar Estadísticas Embebidas
    local realStats = nil
    if entry then
        realStats = NBI.botRealStats[entry]
    else
        local count = 0
        for _ in pairs(NBI.botRealStats) do count = count + 1 end
        if count == 1 then
            for _, s in pairs(NBI.botRealStats) do realStats = s break end
        end
    end
    PopulateStatsWindow(botName, realStats)
    if not realStats then
        statsWinTitle:SetText("Cargando Stats...")
        NBI.RequestRealStats()
    end

    inspectFrame:Show()
    inspectFrame:Raise()

    -- Forzar a acoplar la lista de bots (UI.lua) en la derecha
    if NBI_ListPanel then
        NBI_ListPanel:ClearAllPoints()
        NBI_ListPanel:SetPoint("TOPLEFT", inspectFrame, "TOPRIGHT", -2, 0)
        NBI_ListPanel:Show()
    end
end

function NBI.OnRealStatsUpdated()
    if inspectFrame:IsShown() and inspectFrame.currentBot then
        NBI.OpenInspect(inspectFrame.currentBot)
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

print("|cffFFD700[NPCBotInventory]|r BotInspect cargado con éxito. /botinv inspect <nombre>")
