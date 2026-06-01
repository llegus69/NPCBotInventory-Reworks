-- ============================================================
-- NPCBotInventory - BotInspect.lua
-- Ventana paperdoll unificada: slots automáticos + stats integradas
-- Compatible con WotLK 3.3.5
-- Autor: Lleguito | Version: 5.1 (Fix de Textos y Limpieza de Botón Redundante)
-- ============================================================

local NBI = NPCBotInventory

-- ============================================================
-- SISTEMA DE IDIOMAS / LANGUAGE SYSTEM
-- ============================================================
local LANG = "ES"  -- Idioma por defecto / Default language

local L = {}

-- Etiquetas de slots / Slot labels
L["ES"] = {
    -- Slots
    Head      = "Cabeza",
    Neck      = "Cuello",
    Shoulder  = "Hombros",
    Back      = "Espalda",
    Chest     = "Pecho",
    Shirt     = "Camisa",
    Tabard    = "Tabardo",
    Wrist     = "Muñecas",
    Hands     = "Manos",
    Waist     = "Cintura",
    Legs      = "Piernas",
    Feet      = "Pies",
    Ring1     = "Anillo 1",
    Ring2     = "Anillo 2",
    Trinket1  = "Reliq. 1",
    Trinket2  = "Reliq. 2",
    MainHand  = "Mano Ppal.",
    OffHand   = "Mano Sec.",
    Ranged    = "A Distancia",
    -- Stats sections
    Base      = "Base",
    Attack    = "Ataque",
    Defense   = "Defensa",
    Resist    = "Resistencias",
    -- Stat labels
    maxhealth   = "Vida Máx",
    maxpower    = "Maná/Energía",
    strength    = "Fuerza",
    agility     = "Agilidad",
    stamina     = "Aguante",
    intellect   = "Intelecto",
    spirit      = "Espíritu",
    attackPower = "Poder Ataque",
    spellPower  = "Poder Hechizo",
    spellPen    = "Pen. Hechizo",
    critPct     = "Crítico",
    hastePct    = "Celeridad",
    hitBonusPct = "Golpe",
    expertise   = "Pericia",
    armorPenPct = "Pen. Armadura",
    armor       = "Armadura",
    defense     = "Defensa",
    dodgePct    = "Esquive",
    parryPct    = "Parada",
    blockPct    = "Bloqueo",
    resHoly     = "Sagrado",
    resFire     = "Fuego",
    resNature   = "Naturaleza",
    resFrost    = "Escarcha",
    resShadow   = "Sombras",
    resArcane   = "Arcano",
    -- UI
    refresh_btn = "Actualizar Stats",
    no_spec     = "Sin Spec",
    title       = "NPCBot Inventory Inspector",
    credits     = "Creado por Lleguito",
    loaded_msg  = "BotInspect unificado cargado. /botinv inspect <nombre>",
    lang_btn    = "EN",
    lang_tooltip= "Cambiar a Inglés",
}

L["EN"] = {
    -- Slots
    Head      = "Head",
    Neck      = "Neck",
    Shoulder  = "Shoulder",
    Back      = "Back",
    Chest     = "Chest",
    Shirt     = "Shirt",
    Tabard    = "Tabard",
    Wrist     = "Wrist",
    Hands     = "Hands",
    Waist     = "Waist",
    Legs      = "Legs",
    Feet      = "Feet",
    Ring1     = "Ring 1",
    Ring2     = "Ring 2",
    Trinket1  = "Trinket 1",
    Trinket2  = "Trinket 2",
    MainHand  = "Main Hand",
    OffHand   = "Off Hand",
    Ranged    = "Ranged",
    -- Stats sections
    Base      = "Base",
    Attack    = "Attack",
    Defense   = "Defense",
    Resist    = "Resistances",
    -- Stat labels
    maxhealth   = "Max Health",
    maxpower    = "Mana/Energy",
    strength    = "Strength",
    agility     = "Agility",
    stamina     = "Stamina",
    intellect   = "Intellect",
    spirit      = "Spirit",
    attackPower = "Attack Power",
    spellPower  = "Spell Power",
    spellPen    = "Spell Pen.",
    critPct     = "Critical",
    hastePct    = "Haste",
    hitBonusPct = "Hit",
    expertise   = "Expertise",
    armorPenPct = "Armor Pen.",
    armor       = "Armor",
    defense     = "Defense",
    dodgePct    = "Dodge",
    parryPct    = "Parry",
    blockPct    = "Block",
    resHoly     = "Holy",
    resFire     = "Fire",
    resNature   = "Nature",
    resFrost    = "Frost",
    resShadow   = "Shadow",
    resArcane   = "Arcane",
    -- UI
    refresh_btn = "Refresh Stats",
    no_spec     = "No Spec",
    title       = "NPCBot Inventory Inspector",
    credits     = "Created by Lleguito",
    loaded_msg  = "BotInspect loaded. /botinv inspect <name>",
    lang_btn    = "ES",
    lang_tooltip= "Switch to Spanish",
}

local function T(key)
    return L[LANG][key] or key
end

-- Tabla de iconos de spec (coordenadas del atlas de specs de WotLK)
-- Interface\Icons\Spell_* / Interface\WorldStateFrame\Icons-Classes
-- Usamos los iconos de habilidades representativos de cada spec
local SPEC_ICONS = {
    WARRIOR_ARMS   = "Interface\\Icons\\Ability_Warrior_Savageblow",
    WARRIOR_FURY   = "Interface\\Icons\\Ability_Warrior_InnerRage",
    WARRIOR_PROT   = "Interface\\Icons\\Ability_Warrior_Defensivestance",
    PALADIN_HOLY   = "Interface\\Icons\\Spell_Holy_HolyBolt",
    PALADIN_PROT   = "Interface\\Icons\\Spell_Holy_DevotionAura",
    PALADIN_RET    = "Interface\\Icons\\Spell_Holy_AuraOfLight",
    HUNTER_BM      = "Interface\\Icons\\Ability_Hunter_BeastMastery",
    HUNTER_MM      = "Interface\\Icons\\Ability_Marksmanship",
    HUNTER_SURV    = "Interface\\Icons\\Ability_Hunter_SwiftStrike",
    ROGUE_ASS      = "Interface\\Icons\\Ability_Rogue_Eviscerate",
    ROGUE_COMBAT   = "Interface\\Icons\\Ability_BackStab",
    ROGUE_SUB      = "Interface\\Icons\\Ability_Stealth",
    PRIEST_DISC    = "Interface\\Icons\\Spell_Holy_PowerWordShield",
    PRIEST_HOLY    = "Interface\\Icons\\Spell_Holy_GuardianSpirit",
    PRIEST_SHADOW  = "Interface\\Icons\\Spell_Shadow_ShadowWordPain",
    DK_BLOOD       = "Interface\\Icons\\Spell_DeathKnight_BloodPresence",
    DK_FROST       = "Interface\\Icons\\Spell_DeathKnight_FrostPresence",
    DK_UNHOLY      = "Interface\\Icons\\Spell_DeathKnight_UnholyPresence",
    SHAMAN_ELEM    = "Interface\\Icons\\Spell_Nature_Lightning",
    SHAMAN_ENH     = "Interface\\Icons\\Spell_Nature_LightningShield",
    SHAMAN_RESTO   = "Interface\\Icons\\Spell_Nature_MagicImmunity",
    MAGE_ARCANE    = "Interface\\Icons\\Spell_Holy_MagicalSentry",
    MAGE_FIRE      = "Interface\\Icons\\Spell_Fire_FireBolt02",
    MAGE_FROST     = "Interface\\Icons\\Spell_Frost_FrostBolt02",
    WARLOCK_AFF    = "Interface\\Icons\\Spell_Shadow_DeathCoil",
    WARLOCK_DEMO   = "Interface\\Icons\\Spell_Shadow_Metamorphosis",
    WARLOCK_DESTRO = "Interface\\Icons\\Spell_Shadow_RainOfFire",
    DRUID_BALANCE  = "Interface\\Icons\\Spell_Nature_StarFall",
    DRUID_FERAL    = "Interface\\Icons\\Ability_Druid_CatForm",
    DRUID_RESTO    = "Interface\\Icons\\Spell_Nature_HealingTouch",
}

-- Spec names bilingüe para SPEC_INFO
local SPEC_NAMES = {
    ES = {
        WARRIOR_ARMS   = "Armas",        WARRIOR_FURY   = "Furia",
        WARRIOR_PROT   = "Protección",   PALADIN_HOLY   = "Sagrado",
        PALADIN_PROT   = "Protección",   PALADIN_RET    = "Reprensión",
        HUNTER_BM      = "Bestias",      HUNTER_MM      = "Puntería",
        HUNTER_SURV    = "Supervivencia",ROGUE_ASS      = "Asesinato",
        ROGUE_COMBAT   = "Combate",      ROGUE_SUB      = "Sutileza",
        PRIEST_DISC    = "Disciplina",   PRIEST_HOLY    = "Sagrado",
        PRIEST_SHADOW  = "Sombra",       DK_BLOOD       = "Sangre",
        DK_FROST       = "Escarcha",     DK_UNHOLY      = "Profano",
        SHAMAN_ELEM    = "Elemental",    SHAMAN_ENH     = "Mejora",
        SHAMAN_RESTO   = "Restauración", MAGE_ARCANE    = "Arcano",
        MAGE_FIRE      = "Fuego",        MAGE_FROST     = "Escarcha",
        WARLOCK_AFF    = "Aflicción",    WARLOCK_DEMO   = "Demonología",
        WARLOCK_DESTRO = "Destrucción",  DRUID_BALANCE  = "Equilibrio",
        DRUID_FERAL    = "Feral",        DRUID_RESTO    = "Restauración",
    },
    EN = {
        WARRIOR_ARMS   = "Arms",         WARRIOR_FURY   = "Fury",
        WARRIOR_PROT   = "Protection",   PALADIN_HOLY   = "Holy",
        PALADIN_PROT   = "Protection",   PALADIN_RET    = "Retribution",
        HUNTER_BM      = "Beast Mastery",HUNTER_MM      = "Marksmanship",
        HUNTER_SURV    = "Survival",     ROGUE_ASS      = "Assassination",
        ROGUE_COMBAT   = "Combat",       ROGUE_SUB      = "Subtlety",
        PRIEST_DISC    = "Discipline",   PRIEST_HOLY    = "Holy",
        PRIEST_SHADOW  = "Shadow",       DK_BLOOD       = "Blood",
        DK_FROST       = "Frost",        DK_UNHOLY      = "Unholy",
        SHAMAN_ELEM    = "Elemental",    SHAMAN_ENH     = "Enhancement",
        SHAMAN_RESTO   = "Restoration",  MAGE_ARCANE    = "Arcane",
        MAGE_FIRE      = "Fire",         MAGE_FROST     = "Frost",
        WARLOCK_AFF    = "Affliction",   WARLOCK_DEMO   = "Demonology",
        WARLOCK_DESTRO = "Destruction",  DRUID_BALANCE  = "Balance",
        DRUID_FERAL    = "Feral",        DRUID_RESTO    = "Restoration",
    },
}

local ROLE_NAMES = {
    ES = {
        melee  = "Daño C-C",
        ranged = "Rango",
        tank   = "Tanque",
        heal   = "Sanador",
        feral  = "Feral",
    },
    EN = {
        melee  = "Melee DPS",
        ranged = "Ranged DPS",
        tank   = "Tank",
        heal   = "Healer",
        feral  = "Feral",
    },
}

-- Mapa de rol interno para cada spec
local SPEC_ROLE_KEY = {
    WARRIOR_ARMS   = "melee",  WARRIOR_FURY   = "melee",  WARRIOR_PROT   = "tank",
    PALADIN_HOLY   = "heal",   PALADIN_PROT   = "tank",   PALADIN_RET    = "melee",
    HUNTER_BM      = "ranged", HUNTER_MM      = "ranged", HUNTER_SURV    = "ranged",
    ROGUE_ASS      = "melee",  ROGUE_COMBAT   = "melee",  ROGUE_SUB      = "melee",
    PRIEST_DISC    = "heal",   PRIEST_HOLY    = "heal",   PRIEST_SHADOW  = "ranged",
    DK_BLOOD       = "tank",   DK_FROST       = "melee",  DK_UNHOLY      = "melee",
    SHAMAN_ELEM    = "ranged", SHAMAN_ENH     = "melee",  SHAMAN_RESTO   = "heal",
    MAGE_ARCANE    = "ranged", MAGE_FIRE      = "ranged", MAGE_FROST     = "ranged",
    WARLOCK_AFF    = "ranged", WARLOCK_DEMO   = "ranged", WARLOCK_DESTRO = "ranged",
    DRUID_BALANCE  = "ranged", DRUID_FERAL    = "feral",  DRUID_RESTO    = "heal",
}

local SPEC_COLOR = {
    melee  = {0.9, 0.2, 0.2},
    ranged = {1.0, 0.6, 0.1},
    tank   = {0.4, 0.7, 1.0},
    heal   = {0.2, 0.9, 0.4},
    feral  = {0.9, 0.5, 0.1},
}

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

-- labelKey referencia la clave en L[] para traducción dinámica
local SLOT_LAYOUT = {
    { name = "Head",      labelKey = "Head",     x = -120, y =  145 },
    { name = "Neck",      labelKey = "Neck",     x = -120, y =   98 },
    { name = "Shoulder",  labelKey = "Shoulder", x = -120, y =   51 },
    { name = "Back",      labelKey = "Back",     x = -120, y =    4 },
    { name = "Chest",     labelKey = "Chest",    x = -120, y =  -43 },
    { name = "Shirt",     labelKey = "Shirt",    x = -120, y =  -90 },
    { name = "Tabard",    labelKey = "Tabard",   x = -120, y = -137 },
    { name = "Wrist",     labelKey = "Wrist",    x = -120, y = -184 },
    { name = "Hands",     labelKey = "Hands",    x =  106, y =  145 },
    { name = "Waist",     labelKey = "Waist",    x =  106, y =   98 },
    { name = "Legs",      labelKey = "Legs",     x =  106, y =   51 },
    { name = "Feet",      labelKey = "Feet",     x =  106, y =    4 },
    { name = "Finger1",   labelKey = "Ring1",    x =  106, y =  -43 },
    { name = "Finger2",   labelKey = "Ring2",    x =  106, y =  -90 },
    { name = "Trinket1",  labelKey = "Trinket1", x =  106, y = -137 },
    { name = "Trinket2",  labelKey = "Trinket2", x =  106, y = -184 },
    { name = "MainHand",  labelKey = "MainHand", x = -120, y = -231 },
    { name = "OffHand",   labelKey = "OffHand",  x =  106, y = -231 },
    { name = "Ranged",    labelKey = "Ranged",   x =    3, y = -231 },
}

local SLOT_SZ = 37
local WIN_W   = 660  -- Ajustado a 660 para dar máxima holgura de lectura
local WIN_H   = 620

local QUALITY_COLOR = {
    [0] = {0.62, 0.62, 0.62},
    [1] = {1,    1,    1   },
    [2] = {0.12, 1,    0   },
    [3] = {0,    0.44, 0.87},
    [4] = {0.64, 0.21, 0.93},
    [5] = {1,    0.5,  0   },
}

-- SPEC_INFO generado dinámicamente desde las tablas bilingüe (ver arriba)
local function GetSpecInfo(specKey)
    local roleKey = SPEC_ROLE_KEY[specKey]
    if not roleKey then return nil end
    return {
        name  = (SPEC_NAMES[LANG] and SPEC_NAMES[LANG][specKey]) or specKey,
        role  = (ROLE_NAMES[LANG] and ROLE_NAMES[LANG][roleKey]) or roleKey,
        color = SPEC_COLOR[roleKey] or {1, 1, 1},
        icon  = SPEC_ICONS[specKey],
    }
end

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

-- Marco principal Unificado
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

-- Contenedor izquierdo para mantener relativas las coordenadas de los slots antiguos
local paperdollFrame = CreateFrame("Frame", nil, inspectFrame)
paperdollFrame:SetSize(420, 620)
paperdollFrame:SetPoint("TOPLEFT", inspectFrame, "TOPLEFT", 0, 0)

-- Encabezado expansivo
local inspectHeader = CreateFrame("Frame", nil, inspectFrame)
inspectHeader:SetPoint("TOPLEFT",  inspectFrame, "TOPLEFT",  0, 0)
inspectHeader:SetPoint("TOPRIGHT", inspectFrame, "TOPRIGHT", 0, 0)
inspectHeader:SetHeight(52)
inspectHeader:SetBackdrop({ bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background" })
inspectHeader:SetBackdropColor(0.08, 0.07, 0.03, 1)

-- Icono de clase gigante en el encabezado izquierdo
local classIcon = inspectHeader:CreateTexture(nil, "OVERLAY")
classIcon:SetSize(36, 36)
classIcon:SetPoint("TOPLEFT", inspectHeader, "TOPLEFT", 12, -8)
classIcon:Hide()

local inspectTitle = inspectHeader:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
inspectTitle:SetPoint("TOPLEFT", inspectHeader, "TOPLEFT", 56, -8)
inspectTitle:SetTextColor(1, 0.82, 0, 1)
inspectTitle:SetText("NPCBot Inventory Inspector")

local inspectSubTitle = inspectHeader:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
inspectSubTitle:SetPoint("TOPLEFT", inspectTitle, "BOTTOMLEFT", 0, -2)
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

local creditsLabel = inspectFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
creditsLabel:SetPoint("BOTTOM", inspectFrame, "BOTTOM", 0, 8)
creditsLabel:SetTextColor(0.4, 0.4, 0.4, 1)
creditsLabel:SetText(T("credits"))

-- ============================================================
-- BOTÓN DE SELECCIÓN DE IDIOMA
-- ============================================================
local langBtn = CreateFrame("Button", "NBI_LangBtn", inspectFrame, "UIPanelButtonTemplate")
langBtn:SetSize(42, 22)
langBtn:SetPoint("BOTTOMRIGHT", inspectFrame, "BOTTOMRIGHT", -10, 6)
langBtn:SetText(T("lang_btn"))
langBtn:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_TOP")
    GameTooltip:SetText(T("lang_tooltip"), 1, 1, 1)
    GameTooltip:Show()
end)
langBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)
langBtn:SetScript("OnClick", function(self)
    LANG = (LANG == "ES") and "EN" or "ES"
    -- Actualizar etiqueta del botón
    self:SetText(T("lang_btn"))
    -- Actualizar créditos y título
    creditsLabel:SetText(T("credits"))
    inspectTitle:SetText(T("title"))
    statsRefreshBtn:SetText(T("refresh_btn"))
    -- Actualizar labels de slots
    for _, slotInfo in ipairs(SLOT_LAYOUT) do
        local sf = inspectFrame.slotFrames[slotInfo.name]
        if sf and sf.slotLabel then
            sf.slotLabel:SetText(T(slotInfo.labelKey))
        end
    end
    -- Re-abrir la ventana actual con el nuevo idioma
    if inspectFrame:IsShown() and inspectFrame.currentBot then
        NBI.OpenInspect(inspectFrame.currentBot)
    end
end)

-- Icono de spec en el encabezado (al lado del subtítulo)
local specIcon = inspectHeader:CreateTexture(nil, "OVERLAY")
specIcon:SetSize(14, 14)
specIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
specIcon:Hide()
inspectFrame.specIcon = specIcon

local centerBg = CreateFrame("Frame", nil, paperdollFrame)
centerBg:SetSize(150, 330)
centerBg:SetPoint("CENTER", paperdollFrame, "CENTER", -7, -20)
centerBg:SetBackdrop({
    bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 12,
    insets = { left = 3, right = 3, top = 3, bottom = 3 },
})
centerBg:SetBackdropColor(0.05, 0.05, 0.1, 0.5)
centerBg:SetBackdropBorderColor(0.3, 0.25, 0.1, 0.6)

-- Modelo 3D ampliado verticalmente al 100% para rellenar de forma limpia el espacio vacío
local portraitModel = CreateFrame("PlayerModel", "NBI_PortraitModel", centerBg)
portraitModel:SetSize(136, 318)
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
    local sf = CreateFrame("Button", "NBI_Slot_" .. slotInfo.name, paperdollFrame)
    sf:SetSize(SLOT_SZ, SLOT_SZ)
    sf:SetPoint("CENTER", paperdollFrame, "CENTER", slotInfo.x, slotInfo.y - 10)
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

    local lbl = paperdollFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    lbl:SetPoint("TOP", sf, "BOTTOM", 0, -1)
    lbl:SetTextColor(0.45, 0.45, 0.45, 1)
    lbl:SetText(T(slotInfo.labelKey))

    sf.icon      = icon
    sf.qbar      = qbar
    sf.slotLabel = lbl
    sf.link      = nil
    sf.slotName  = slotInfo.name
    sf.labelKey  = slotInfo.labelKey

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

-- DISEÑO UNIFICADO CORREGIDO: Lateral ensanchado a 220px para textos limpios sin cortes
local STATS_WIN_W = 220
local STATS_WIN_H = 540

local statsWin = CreateFrame("Frame", "NBI_StatsWindow", inspectFrame)
statsWin:SetSize(STATS_WIN_W, STATS_WIN_H)
statsWin:SetPoint("TOPRIGHT", inspectFrame, "TOPRIGHT", -12, -58)
GoldBorder(statsWin)

local statsRefreshBtn = CreateFrame("Button", nil, statsWin, "UIPanelButtonTemplate")
statsRefreshBtn:SetSize(STATS_WIN_W - 24, 22)
statsRefreshBtn:SetPoint("BOTTOM", statsWin, "BOTTOM", 0, 8)
statsRefreshBtn:SetText(T("refresh_btn"))
statsRefreshBtn:SetScript("OnClick", function()
    if statsWin.currentBot then
        NBI.RequestRealStats()
    end
end)

local statsScroll = CreateFrame("ScrollFrame", "NBI_StatsScroll", statsWin, "UIPanelScrollFrameTemplate")
statsScroll:SetPoint("TOPLEFT",     statsWin, "TOPLEFT",     8, -8)
statsScroll:SetPoint("BOTTOMRIGHT", statsWin, "BOTTOMRIGHT", -28, 38)

local statsContent = CreateFrame("Frame", nil, statsScroll)
statsContent:SetSize(STATS_WIN_W - 36, 10)
statsScroll:SetScrollChild(statsContent)

local statRows = {}
local function GetStatRow(index)
    if not statRows[index] then
        local row = CreateFrame("Frame", nil, statsContent)
        row:SetSize(STATS_WIN_W - 36, 16)
        row:SetPoint("TOPLEFT", statsContent, "TOPLEFT", 2, -2 - (index - 1) * 18)

        local keyLbl = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        keyLbl:SetPoint("LEFT",  row, "LEFT", 2, 0)
        keyLbl:SetTextColor(0.75, 0.75, 0.75, 1)
        keyLbl:SetJustifyH("LEFT")
        -- Corregido: En 3.3.5 NO se usa SetWordWrap. Al no ponerle anclaje derecho fijo, 
        -- el texto jamás saltará de línea de forma errónea ni se pisará.

        local valLbl = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        valLbl:SetPoint("RIGHT", row, "RIGHT", -2, 0)
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
    { key = "maxhealth",   color = {0.3,  1,    0.3 } },
    { key = "maxpower",    color = {0.3,  0.6,  1   } },
    { key = "strength",    color = {1,    0.82, 0   } },
    { key = "agility",     color = {1,    0.82, 0   } },
    { key = "stamina",     color = {1,    0.82, 0   } },
    { key = "intellect",   color = {1,    0.82, 0   } },
    { key = "spirit",      color = {1,    0.82, 0   } },
    { section = "Attack" },
    { key = "attackPower", color = {0.9,  0.5,  0.1 } },
    { key = "spellPower",  color = {0.5,  0.5,  1   } },
    { key = "spellPen",    color = {0.5,  0.5,  1   } },
    { key = "critPct",     color = {0.2,  0.9,  0.4 }, fmt = "%.2f%%" },
    { key = "hastePct",    color = {0.2,  0.9,  0.4 }, fmt = "%.2f%%" },
    { key = "hitBonusPct", color = {0.2,  0.9,  0.4 }, fmt = "%.2f%%" },
    { key = "expertise",   color = {0.2,  0.9,  0.4 } },
    { key = "armorPenPct", color = {0.8,  0.8,  0.8 }, fmt = "%.2f%%" },
    { section = "Defense" },
    { key = "armor",       color = {0.6,  0.6,  0.8 } },
    { key = "defense",     color = {0.4,  0.7,  1   } },
    { key = "dodgePct",    color = {0.4,  0.7,  1   }, fmt = "%.2f%%" },
    { key = "parryPct",    color = {0.4,  0.7,  1   }, fmt = "%.2f%%" },
    { key = "blockPct",    color = {0.4,  0.7,  1   }, fmt = "%.2f%%" },
    { section = "Resist" },
    { key = "resHoly",     color = {1,    1,    0.6 } },
    { key = "resFire",     color = {1,    0.4,  0.1 } },
    { key = "resNature",   color = {0.3,  0.9,  0.2 } },
    { key = "resFrost",    color = {0.5,  0.8,  1   } },
    { key = "resShadow",   color = {0.7,  0.3,  0.9 } },
    { key = "resArcane",   color = {0.9,  0.3,  0.9 } },
}

local function PopulateStatsWindow(botName, realStats)
    statsWin.currentBot = botName

    for _, row in ipairs(statRows) do
        row:Hide()
        row.secTex:Hide()
    end

    local rowIndex = 1
    for _, entry in ipairs(REAL_STAT_DISPLAY) do
        if entry.section then
            local row = GetStatRow(rowIndex)
            row.key:SetText(T(entry.section))
            row.key:SetTextColor(1, 0.82, 0, 1)
            row.val:SetText("")
            if rowIndex > 1 then row.secTex:Show() end
            row:Show()
            rowIndex = rowIndex + 1
        else
            local val = realStats and realStats[entry.key]
            if val and val ~= 0 then
                local row = GetStatRow(rowIndex)
                row.key:SetText(T(entry.key))
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
        statsWin:Show()
    end

    if not realStats then
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

    -- Gestión e inyección dinámica del icono de Clase gigante
    local entry = NBI.botEntryByName and NBI.botEntryByName[botName]
    local botClass = entry and NBI.botClasses[entry]
    if botClass and CLASS_ICON_TCOORDS and CLASS_ICON_TCOORDS[botClass] then
        classIcon:SetTexture("Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes")
        classIcon:SetTexCoord(unpack(CLASS_ICON_TCOORDS[botClass]))
        classIcon:Show()
        inspectTitle:SetPoint("TOPLEFT", inspectHeader, "TOPLEFT", 56, -8)
    else
        classIcon:Hide()
        inspectTitle:SetPoint("TOPLEFT", inspectHeader, "TOPLEFT", 15, -8)
    end

    local gs = ""
    local statsText = NBI.botStats and NBI.botStats[botName]
    if statsText then
        local gsVal = statsText:match("GS%s*:%s*(%d+)")
        if gsVal then gs = "GS: " .. gsVal end
    end

    local roleText = ""
    local currentSpecKey = nil
    if entry then
        local botSpec = NBI.botRoles[entry]
        currentSpecKey = botSpec
        local info = GetSpecInfo(botSpec)

        if info then
            local rc = info.color
            roleText = string.format("|cff%02x%02x%02x%s (%s)|r",
                rc[1]*255, rc[2]*255, rc[3]*255, info.name, info.role)
        else
            roleText = "|cff888888" .. T("no_spec") .. "|r"
        end
    end

    -- Icono de spec en el encabezado
    local specIcon = inspectFrame.specIcon
    if currentSpecKey and SPEC_ICONS[currentSpecKey] then
        specIcon:SetTexture(SPEC_ICONS[currentSpecKey])
        -- Posición dinámica: al lado izquierdo del subtítulo
        specIcon:ClearAllPoints()
        specIcon:SetPoint("LEFT", inspectSubTitle, "LEFT", -18, 0)
        specIcon:Show()
        -- Desplazar el subtítulo para dar hueco al icono
        inspectSubTitle:ClearAllPoints()
        inspectSubTitle:SetPoint("TOPLEFT", inspectTitle, "BOTTOMLEFT", 18, -2)
    else
        specIcon:Hide()
        inspectSubTitle:ClearAllPoints()
        inspectSubTitle:SetPoint("TOPLEFT", inspectTitle, "BOTTOMLEFT", 0, -2)
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

    -- Llamada interna automática para pintar las estadísticas al unísono
    NBI.OpenStatsWindow(botName)

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

print("|cffFFD700[NPCBotInventory]|r " .. T("loaded_msg"))
