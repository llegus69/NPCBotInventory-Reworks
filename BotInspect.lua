-- ============================================================
-- NPCBotInventory - BotInspect.lua
-- Ventana paperdoll: slots detectados automaticamente + stats
-- Compatible con WotLK 3.3.5
-- Autor: Lleguito | Version: 4.0 (Soporte Nativo de Specs por Base de Datos)
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

local SLOT_LAYOUT = {
    -- Columna izquierda (x negativo = izquierda del centro)
    { name = "Head",      label = "Cabeza",       x = -165, y =  200 },
    { name = "Neck",      label = "Cuello",        x = -165, y =  148 },
    { name = "Shoulder",  label = "Hombros",       x = -165, y =   96 },
    { name = "Back",      label = "Espalda",       x = -165, y =   44 },
    { name = "Chest",     label = "Pecho",         x = -165, y =   -8 },
    { name = "Shirt",     label = "Camisa",        x = -165, y =  -60 },
    { name = "Tabard",    label = "Tabardo",       x = -165, y = -112 },
    { name = "Wrist",     label = "Muñeca",        x = -165, y = -164 },
    -- Columna derecha
    { name = "Hands",     label = "Manos",         x =  153, y =  200 },
    { name = "Waist",     label = "Cintura",       x =  153, y =  148 },
    { name = "Legs",      label = "Piernas",       x =  153, y =   96 },
    { name = "Feet",      label = "Pies",          x =  153, y =   44 },
    { name = "Finger1",   label = "Anillo 1",      x =  153, y =   -8 },
    { name = "Finger2",   label = "Anillo 2",      x =  153, y =  -60 },
    { name = "Trinket1",  label = "Trink. 1",      x =  153, y = -112 },
    { name = "Trinket2",  label = "Trink. 2",      x =  153, y = -164 },
    -- Fila inferior: armas
    { name = "MainHand",  label = "Mano Ppal.",    x = -100, y = -230 },
    { name = "OffHand",   label = "Mano Sec.",     x =    0, y = -230 },
    { name = "Ranged",    label = "Distancia",     x =  100, y = -230 },
}

local SLOT_SZ = 40
local WIN_W   = 480
local WIN_H   = 660

local QUALITY_COLOR = {
    [0] = {0.62, 0.62, 0.62},
    [1] = {1,    1,    1   },
    [2] = {0.12, 1,    0   },
    [3] = {0,    0.44, 0.87},
    [4] = {0.64, 0.21, 0.93},
    [5] = {1,    0.5,  0   },
}

-- Diccionario maestro indexado por la especialización real enviada desde el servidor
local SPEC_INFO = {
    -- Guerrero
    WARRIOR_ARMS   = { name = "Armas",        role = "Daño C-C", color = {0.9, 0.2, 0.2}, icon = "Interface\\Icons\\Ability_Warrior_Savageblow"       },
    WARRIOR_FURY   = { name = "Furia",        role = "Daño C-C", color = {0.9, 0.2, 0.2}, icon = "Interface\\Icons\\Ability_Warrior_Innerrage"         },
    WARRIOR_PROT   = { name = "Protección",   role = "Tanque",   color = {0.4, 0.7, 1.0}, icon = "Interface\\Icons\\Ability_Warrior_Defensivestance"   },
    -- Paladín
    PALADIN_HOLY   = { name = "Sagrado",      role = "Sanador",  color = {0.2, 0.9, 0.4}, icon = "Interface\\Icons\\Spell_Holy_HolyBolt"               },
    PALADIN_PROT   = { name = "Protección",   role = "Tanque",   color = {0.4, 0.7, 1.0}, icon = "Interface\\Icons\\Ability_Paladin_Shieldofvengeance"  },
    PALADIN_RET    = { name = "Reprensión",   role = "Daño C-C", color = {0.9, 0.2, 0.2}, icon = "Interface\\Icons\\Spell_Holy_AuraofLight"            },
    -- Cazador
    HUNTER_BM      = { name = "Bestias",      role = "Rango",    color = {1.0, 0.6, 0.1}, icon = "Interface\\Icons\\Ability_Hunter_BeastTraining"      },
    HUNTER_MM      = { name = "Puntería",     role = "Rango",    color = {1.0, 0.6, 0.1}, icon = "Interface\\Icons\\Ability_Hunter_FocusedAim"         },
    HUNTER_SURV    = { name = "Supervivencia",role = "Rango",    color = {1.0, 0.6, 0.1}, icon = "Interface\\Icons\\Ability_Hunter_Camouflage"         },
    -- Pícaro
    ROGUE_ASS      = { name = "Asesinato",    role = "Daño C-C", color = {0.9, 0.2, 0.2}, icon = "Interface\\Icons\\Ability_Rogue_Eviscerate"          },
    ROGUE_COMBAT   = { name = "Combate",      role = "Daño C-C", color = {0.9, 0.2, 0.2}, icon = "Interface\\Icons\\Ability_Backstab"                  },
    ROGUE_SUB      = { name = "Sutileza",     role = "Daño C-C", color = {0.9, 0.2, 0.2}, icon = "Interface\\Icons\\Ability_Stealth"                   },
    -- Sacerdote
    PRIEST_DISC    = { name = "Disciplina",   role = "Sanador",  color = {0.2, 0.9, 0.4}, icon = "Interface\\Icons\\Spell_Holy_WordFortitude"           },
    PRIEST_HOLY    = { name = "Sagrado",      role = "Sanador",  color = {0.2, 0.9, 0.4}, icon = "Interface\\Icons\\Spell_Holy_GuardianSpirit"          },
    PRIEST_SHADOW  = { name = "Sombra",       role = "Rango",    color = {1.0, 0.6, 0.1}, icon = "Interface\\Icons\\Spell_Shadow_ShadowWordPain"        },
    -- Caballero de la Muerte
    DK_BLOOD       = { name = "Sangre",       role = "Tanque",   color = {0.4, 0.7, 1.0}, icon = "Interface\\Icons\\Spell_Deathknight_Bloodpresence"   },
    DK_FROST       = { name = "Escarcha",     role = "Daño C-C", color = {0.9, 0.2, 0.2}, icon = "Interface\\Icons\\Spell_Deathknight_Frostpresence"   },
    DK_UNHOLY      = { name = "Profano",      role = "Daño C-C", color = {0.9, 0.2, 0.2}, icon = "Interface\\Icons\\Spell_Deathknight_Unholypresence"  },
    -- Chamán
    SHAMAN_ELEM    = { name = "Elemental",    role = "Rango",    color = {1.0, 0.6, 0.1}, icon = "Interface\\Icons\\Spell_Nature_Lightning"             },
    SHAMAN_ENH     = { name = "Mejora",       role = "Daño C-C", color = {0.9, 0.2, 0.2}, icon = "Interface\\Icons\\Spell_Nature_LightningShield"       },
    SHAMAN_RESTO   = { name = "Restauración", role = "Sanador",  color = {0.2, 0.9, 0.4}, icon = "Interface\\Icons\\Spell_Nature_MagicImmunity"         },
    -- Mago
    MAGE_ARCANE    = { name = "Arcano",       role = "Rango",    color = {1.0, 0.6, 0.1}, icon = "Interface\\Icons\\Spell_Holy_MagicalSentry"           },
    MAGE_FIRE      = { name = "Fuego",        role = "Rango",    color = {1.0, 0.6, 0.1}, icon = "Interface\\Icons\\Spell_Fire_FireBolt02"              },
    MAGE_FROST     = { name = "Escarcha",     role = "Rango",    color = {1.0, 0.6, 0.1}, icon = "Interface\\Icons\\Spell_Frost_FrostBolt02"            },
    -- Brujo
    WARLOCK_AFF    = { name = "Aflicción",    role = "Rango",    color = {1.0, 0.6, 0.1}, icon = "Interface\\Icons\\Spell_Shadow_DeathCoil"             },
    WARLOCK_DEMO   = { name = "Demonología",  role = "Rango",    color = {1.0, 0.6, 0.1}, icon = "Interface\\Icons\\Spell_Shadow_Metamorphosis"         },
    WARLOCK_DESTRO = { name = "Destrucción",  role = "Rango",    color = {1.0, 0.6, 0.1}, icon = "Interface\\Icons\\Spell_Shadow_RainOfFire"            },
    -- Druida
    DRUID_BALANCE  = { name = "Equilibrio",   role = "Rango",    color = {1.0, 0.6, 0.1}, icon = "Interface\\Icons\\Spell_Nature_StarFall"              },
    DRUID_FERAL    = { name = "Feral",        role = "Feral",    color = {0.9, 0.5, 0.1}, icon = "Interface\\Icons\\Ability_Druid_CatForm"              },
    DRUID_RESTO    = { name = "Restauración", role = "Sanador",  color = {0.2, 0.9, 0.4}, icon = "Interface\\Icons\\Spell_Nature_HealingTouch"          },
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

local inspectHeader = CreateFrame("Frame", nil, inspectFrame)
inspectHeader:SetPoint("TOPLEFT",  inspectFrame, "TOPLEFT",  0, 0)
inspectHeader:SetPoint("TOPRIGHT", inspectFrame, "TOPRIGHT", 0, 0)
inspectHeader:SetHeight(64)
inspectHeader:SetBackdrop({ bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background" })
inspectHeader:SetBackdropColor(0.08, 0.07, 0.03, 1)

-- Avatar 2D en el header (izquierda) — retrato 2D real con SetPortraitTexture
local headerAvatarBorder = CreateFrame("Frame", nil, inspectHeader)
headerAvatarBorder:SetSize(48, 48)
headerAvatarBorder:SetPoint("LEFT", inspectHeader, "LEFT", 10, 0)
headerAvatarBorder:SetBackdrop({
    bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 8, edgeSize = 8,
    insets = { left = 1, right = 1, top = 1, bottom = 1 },
})
headerAvatarBorder:SetBackdropColor(0.05, 0.05, 0.1, 1)
headerAvatarBorder:SetBackdropBorderColor(0.5, 0.42, 0.1, 0.8)

-- Textura de retrato 2D (se rellena con SetPortraitTexture en OpenInspect)
local headerPortrait = headerAvatarBorder:CreateTexture(nil, "ARTWORK")
headerPortrait:SetSize(42, 42)
headerPortrait:SetPoint("CENTER", headerAvatarBorder, "CENTER", 0, 0)
headerPortrait:SetTexture("Interface\\Icons\\INV_Misc_Statue_02")
headerPortrait:SetTexCoord(0.08, 0.92, 0.08, 0.92)
headerPortrait:SetAlpha(0.4)

-- Icono de clase — Frame propio con FrameLevel superior al del avatar border
-- Así queda visible ENCIMA del retrato 2D
local headerClassFrame = CreateFrame("Frame", nil, inspectHeader)
headerClassFrame:SetSize(20, 20)
headerClassFrame:SetPoint("BOTTOMRIGHT", headerAvatarBorder, "BOTTOMRIGHT", 5, -5)
headerClassFrame:SetFrameLevel(headerAvatarBorder:GetFrameLevel() + 10)

local headerClassIcon = headerClassFrame:CreateTexture(nil, "OVERLAY")
headerClassIcon:SetAllPoints()
headerClassIcon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
headerClassIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

-- Icono de talento/spec — a la derecha del icono de clase
local headerTalentFrame = CreateFrame("Frame", nil, inspectHeader)
headerTalentFrame:SetSize(26, 26)
headerTalentFrame:SetPoint("LEFT", headerClassFrame, "RIGHT", 4, 0)
headerTalentFrame:SetFrameLevel(headerAvatarBorder:GetFrameLevel() + 10)
headerTalentFrame:SetBackdrop({
    bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 8, edgeSize = 8,
    insets = { left = 1, right = 1, top = 1, bottom = 1 },
})
headerTalentFrame:SetBackdropColor(0.05, 0.05, 0.1, 1)
headerTalentFrame:SetBackdropBorderColor(0.5, 0.42, 0.1, 0.7)

local headerTalentIcon = headerTalentFrame:CreateTexture(nil, "OVERLAY")
headerTalentIcon:SetPoint("TOPLEFT",     headerTalentFrame, "TOPLEFT",     2, -2)
headerTalentIcon:SetPoint("BOTTOMRIGHT", headerTalentFrame, "BOTTOMRIGHT", -2,  2)
headerTalentIcon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
headerTalentIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

-- Título centrado
local inspectTitle = inspectHeader:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
inspectTitle:SetPoint("CENTER", inspectHeader, "CENTER", 20, 8)
inspectTitle:SetTextColor(1, 0.82, 0, 1)
inspectTitle:SetText("NPCBot Inventory Inspector")

local inspectSubTitle = inspectHeader:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
inspectSubTitle:SetPoint("TOP", inspectTitle, "BOTTOM", 0, -2)
inspectSubTitle:SetTextColor(0.8, 0.8, 0.8, 1)
inspectSubTitle:SetText("")

-- Guardar referencias al portrait y class icon del header para actualizarlos en OpenInspect
inspectFrame.headerPortrait   = headerPortrait
inspectFrame.headerClassIcon  = headerClassIcon
inspectFrame.headerTalentIcon = headerTalentIcon

local sep = inspectFrame:CreateTexture(nil, "ARTWORK")
sep:SetHeight(1)
sep:SetPoint("TOPLEFT",  inspectFrame, "TOPLEFT",  10, -64)
sep:SetPoint("TOPRIGHT", inspectFrame, "TOPRIGHT", -10, -64)
sep:SetTexture(0.5, 0.42, 0.1, 0.6)

local inspectClose = CreateFrame("Button", nil, inspectFrame, "UIPanelCloseButton")
inspectClose:SetPoint("TOPRIGHT", inspectFrame, "TOPRIGHT", 2, 2)
inspectClose:SetScript("OnClick", function() inspectFrame:Hide() end)

-- Botón ? en el paperdoll (junto al botón de cerrar)
-- helpPanel y MakeHelpButton se definen en UI.lua; usamos un botón simple aquí
-- que llama a ToggleHelp si está disponible
local pdHelpBtn = CreateFrame("Button", nil, inspectFrame)
pdHelpBtn:SetSize(22, 22)
pdHelpBtn:SetPoint("TOPRIGHT", inspectClose, "TOPLEFT", -2, -5)
pdHelpBtn:SetFrameLevel(inspectFrame:GetFrameLevel() + 5)
pdHelpBtn:SetBackdrop({
    bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 8, edgeSize = 10,
    insets = { left = 2, right = 2, top = 2, bottom = 2 },
})
pdHelpBtn:SetBackdropColor(0.08, 0.07, 0.03, 1)
pdHelpBtn:SetBackdropBorderColor(0.5, 0.42, 0.1, 0.8)
local pdHelpLbl = pdHelpBtn:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
pdHelpLbl:SetPoint("CENTER", pdHelpBtn, "CENTER", 0, 0)
pdHelpLbl:SetText("|cffFFD700?|r")
local pdHelpHL = pdHelpBtn:CreateTexture(nil, "HIGHLIGHT")
pdHelpHL:SetAllPoints()
pdHelpHL:SetTexture("Interface\\Buttons\\ButtonHilight-Square")
pdHelpHL:SetBlendMode("ADD")
pdHelpBtn:SetScript("OnClick", function()
    local hp = NBI_HelpPanel or _G["NBI_HelpPanel"]
    if hp then
        if hp:IsShown() then
            hp:Hide()
        else
            hp:ClearAllPoints()
            hp:SetPoint("TOPRIGHT", inspectFrame, "TOPLEFT", -6, 0)
            hp:Show()
        end
    end
end)
pdHelpBtn:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    GameTooltip:SetText("Ayuda / Help")
    GameTooltip:Show()
end)
pdHelpBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)

local creditsLabel = inspectFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
creditsLabel:SetPoint("BOTTOM", inspectFrame, "BOTTOM", 0, 8)
creditsLabel:SetTextColor(0.4, 0.4, 0.4, 1)
creditsLabel:SetText("Creado por Lleguito")

local centerBg = CreateFrame("Frame", nil, inspectFrame)
centerBg:SetSize(190, 380)
centerBg:SetPoint("CENTER", inspectFrame, "CENTER", -7, 0)
centerBg:SetBackdrop({
    bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 12,
    insets = { left = 3, right = 3, top = 3, bottom = 3 },
})
centerBg:SetBackdropColor(0.05, 0.05, 0.1, 0.5)
centerBg:SetBackdropBorderColor(0.3, 0.25, 0.1, 0.6)

local portraitModel = CreateFrame("PlayerModel", "NBI_PortraitModel", centerBg)
portraitModel:SetSize(178, 330)
portraitModel:SetPoint("TOP", centerBg, "TOP", 0, -6)
portraitModel:SetBackdrop({
    bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 8, edgeSize = 8,
    insets = { left = 2, right = 2, top = 2, bottom = 2 },
})
portraitModel:SetBackdropColor(0.05, 0.05, 0.1, 0.8)
portraitModel:SetBackdropBorderColor(0.4, 0.35, 0.1, 0.8)

local portraitPlaceholder = centerBg:CreateTexture(nil, "ARTWORK")
portraitPlaceholder:SetSize(80, 80)
portraitPlaceholder:SetPoint("CENTER", portraitModel, "CENTER", 0, 0)
portraitPlaceholder:SetTexture("Interface\\CHARACTERFRAME\\TempPortraitAlphaMask")
portraitPlaceholder:SetAlpha(0.3)

local statsBtn = CreateFrame("Button", nil, centerBg, "UIPanelButtonTemplate")
statsBtn:SetSize(110, 22)
statsBtn:SetPoint("TOP", portraitModel, "BOTTOM", 0, -6)
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

local statsScroll = CreateFrame("ScrollFrame", "NBI_StatsScroll", statsWin, "UIPanelScrollFrameTemplate")
statsScroll:SetPoint("TOPLEFT",     statsWin, "TOPLEFT",     10, -42)
statsScroll:SetPoint("BOTTOMRIGHT", statsWin, "BOTTOMRIGHT", -28, 38)

local statsContent = CreateFrame("Frame", nil, statsScroll)
statsContent:SetSize(STATS_WIN_W - 38, 10)
statsScroll:SetScrollChild(statsContent)

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
    statsWinTitle:SetText(botName .. " - Stats")
    statsWin.currentBot = botName

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

function NBI.OpenStatsWindow(botName)
    local entry = NBI.botEntryByName and NBI.botEntryByName[botName]
    if not entry then
        local unitId = FindBotUnitId(botName)
    end
    entry = NBI.botEntryByName and NBI.botEntryByName[botName]

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

    if not statsWin:IsShown() then
        statsWin:ClearAllPoints()
        statsWin:SetPoint("LEFT", inspectFrame, "RIGHT", 6, 0)
        statsWin:Show()
    end
    statsWin:Raise()

    if not realStats then
        statsWinTitle:SetText("Cargando...")
        NBI.RequestRealStats()
    end
end

function NBI.OpenInspect(botName)
    local inventory = NBI.botInventories[botName]

    if not inventory then
        print("|cffFFD700[NPCBotInventory]|r No data for: " .. botName)
        return
    end

    inspectFrame.currentBot = botName

    local unitId = FindBotUnitId(botName)
    inspectTitle:SetText("NPCBot Inventory Inspector")

    -- ── Actualizar header: avatar 2D + icono de clase + icono de talento ─
    local hPort   = inspectFrame.headerPortrait
    local hClass  = inspectFrame.headerClassIcon
    local hTalent = inspectFrame.headerTalentIcon

    if unitId then
        SetPortraitTexture(hPort, unitId)
        hPort:SetAlpha(1)
    else
        hPort:SetTexture("Interface\\Icons\\INV_Misc_Statue_02")
        hPort:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        hPort:SetAlpha(0.4)
    end

    -- Icono de clase en header
    local CLASS_ICON_COORDS_LOCAL = {
        WARRIOR     = {0,    0.25,  0,    0.25},
        MAGE        = {0.25, 0.5,   0,    0.25},
        ROGUE       = {0.5,  0.75,  0,    0.25},
        DRUID       = {0.75, 1,     0,    0.25},
        HUNTER      = {0,    0.25,  0.25, 0.5 },
        SHAMAN      = {0.25, 0.5,   0.25, 0.5 },
        PRIEST      = {0.5,  0.75,  0.25, 0.5 },
        WARLOCK     = {0.75, 1,     0.25, 0.5 },
        PALADIN     = {0,    0.25,  0.5,  0.75},
        DEATHKNIGHT = {0.25, 0.5,   0.5,  0.75},
    }
    local entry = NBI.botEntryByName and NBI.botEntryByName[botName]
    local botClass = entry and NBI.botClasses and NBI.botClasses[entry]
    if not botClass and unitId then
        _, botClass = UnitClass(unitId)
    end
    local coords = botClass and CLASS_ICON_COORDS_LOCAL[botClass]
    if coords then
        hClass:SetTexture("Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes")
        hClass:SetTexCoord(coords[1], coords[2], coords[3], coords[4])
    else
        hClass:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
        hClass:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    end

    -- Icono de talento/spec
    local botSpec = entry and NBI.botRoles and NBI.botRoles[entry]
    local specInfo = botSpec and SPEC_INFO[botSpec]
    if specInfo and specInfo.icon then
        hTalent:SetTexture(specInfo.icon)
        hTalent:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        hTalent:SetAlpha(1)
    else
        hTalent:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
        hTalent:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        hTalent:SetAlpha(0.5)
    end

    local gs = ""
    local statsText = NBI.botStats and NBI.botStats[botName]
    if statsText then
        local gsVal = statsText:match("GS%s*:%s*(%d+)")
        if gsVal then gs = "GS: " .. gsVal end
    end

    -- Lectura directa de la cadena de texto de la Spec enviada por el Servidor
    local roleText = ""
    if entry then
        local botSpec = NBI.botRoles[entry] -- Aquí Eluna ahora almacena strings tipo "DRUID_RESTO"
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

    inspectFrame:Show()
    inspectFrame:Raise()
end

function NBI.OnRealStatsUpdated()
    if statsWin:IsShown() and statsWin.currentBot then
        NBI.OpenStatsWindow(statsWin.currentBot)
    end
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

print("|cffFFD700[NPCBotInventory]|r BotInspect loaded. /botinv inspect <name>")