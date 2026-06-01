-- ============================================================
-- NPCBotInventory - BotInspect.lua
-- Ventana paperdoll unificada: slots automáticos + stats integradas
-- Compatible con WotLK 3.3.5
-- Autor: Lleguito 
-- ============================================================

local NBI = NPCBotInventory

-- ============================================================
-- SISTEMA DE IDIOMAS / LANGUAGE SYSTEM
-- ============================================================
local LANG = "ES"  -- Idioma por defecto / Default language

local L = {}

-- Etiquetas de slots y textos / Slot labels & texts
L["ES"] = {
    Head      = "Cabeza", Neck      = "Cuello", Shoulder  = "Hombros", Back      = "Espalda",
    Chest     = "Pecho", Shirt     = "Camisa", Tabard    = "Tabardo", Wrist     = "Muñecas",
    Hands     = "Manos", Waist     = "Cintura", Legs      = "Piernas", Feet      = "Pies",
    Ring1     = "Anillo 1", Ring2     = "Anillo 2", Trinket1  = "Reliq. 1", Trinket2  = "Reliq. 2",
    MainHand  = "Mano Ppal.", OffHand   = "Mano Sec.", 
    Ranged    = "Rango / Reliquia",
    Base      = "Base", Attack    = "Ataque", Defense   = "Defensa", Resist    = "Resistencias",
    maxhealth   = "Vida Máx", maxpower    = "Maná/Energía", strength    = "Fuerza",
    agility     = "Agilidad", stamina     = "Aguante", intellect   = "Intelecto",
    spirit      = "Espíritu", attackPower = "Poder Ataque", spellPower  = "Poder Hechizo",
    spellPen    = "Pen. Hechizo", critPct     = "Crítico", hastePct    = "Celeridad",
    hitBonusPct = "Golpe", expertise   = "Pericia", armorPenPct = "Pen. Armadura",
    armor       = "Armadura", defense     = "Defensa", dodgePct    = "Esquivar",
    parryPct    = "Parada", blockPct    = "Bloqueo", resHoly     = "Sagrado",
    resFire     = "Fuego", resNature   = "Naturaleza", resFrost    = "Escarcha",
    resShadow   = "Sombras", resArcane   = "Arcano",
    refresh_btn = "Actualizar Stats", no_spec     = "Sin Spec",
    title       = "NPCBot Inventory Inspector", credits     = "Creado por Lleguito",
    loaded_msg  = "BotInspect unificado cargado. /botinv inspect <nombre>",
    lang_prefix = "Idioma:",
    -- Textos de Ayuda
    help_btn    = "Ayuda",
    help_title  = "Información de Ayuda",
    help_text   = "Recuerda: Si hay algún dato que no se ve, clic en \"Borrar todo\" del cuadro NPCBot para eliminar todos los registros y pedirle a los bots \"Muéstrame tu inventario\", así se actualizarán los datos.",
    help_ok     = "Entendido",
    no_party_msg = "Para poder ver el modelo 3D y los datos restantes, el bot tiene que pertenecer a tu grupo",
}

L["EN"] = {
    Head      = "Head", Neck      = "Neck", Shoulder  = "Shoulder", Back      = "Back",
    Chest     = "Chest", Shirt     = "Shirt", Tabard    = "Tabard", Wrist     = "Wrist",
    Hands     = "Hands", Waist     = "Waist", Legs      = "Legs", Feet      = "Feet",
    Ring1     = "Ring 1", Ring2     = "Ring 2", Trinket1  = "Trinket 1", Trinket2  = "Trinket 2",
    MainHand  = "Main Hand", OffHand   = "Off Hand", 
    Ranged    = "Ranged / Relic",
    Base      = "Base", Attack    = "Attack", Defense   = "Defense", Resist    = "Resistences",
    maxhealth   = "Max Health", maxpower    = "Mana/Energy", strength    = "Strength",
    agility     = "Agility", stamina     = "Stamina", intellect   = "Intellect",
    spirit      = "Spirit", attackPower = "Attack Power", spellPower  = "Spell Power",
    spellPen    = "Spell Pen.", critPct     = "Critical", hastePct    = "Haste",
    hitBonusPct = "Hit", expertise   = "Expertise", armorPenPct = "Armor Pen.",
    armor       = "Armor", defense     = "Defense", dodgePct    = "Dodge",
    parryPct    = "Parry", blockPct    = "Block", resHoly     = "Holy",
    resFire     = "Fire", resNature   = "Nature", resFrost    = "Frost",
    resShadow   = "Shadow", resArcane   = "Arcane",
    refresh_btn = "Refresh Stats", no_spec     = "No Spec",
    title       = "NPCBot Inventory Inspector", credits     = "Created by Lleguito",
    loaded_msg  = "BotInspect loaded. /botinv inspect <name>",
    lang_prefix = "Language:",
    -- Help Texts
    help_btn    = "Help",
    help_title  = "Help Information",
    help_text   = "Remember: If any data is missing, click \"Clear All\" in the NPCBot frame to clear all records, then ask the bots \"Show me your inventory\" to update the data.",
    help_ok     = "Got it",
    no_party_msg = "To view the 3D model and remaining data, the bot must be in your party",
}

local function T(key)
    return L[LANG][key] or key
end

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

local SPEC_NAMES = {
    ES = {
        WARRIOR_ARMS   = "Armas",        WARRIOR_FURY   = "Furia",        WARRIOR_PROT   = "Protección",
        PALADIN_HOLY   = "Sagrado",      PALADIN_PROT   = "Protección",   PALADIN_RET    = "Reprensión",
        HUNTER_BM      = "Bestias",      HUNTER_MM      = "Puntería",     HUNTER_SURV    = "Supervivencia",
        ROGUE_ASS      = "Asesinato",    ROGUE_COMBAT   = "Combate",      ROGUE_SUB      = "Sutileza",
        PRIEST_DISC    = "Disciplina",   PRIEST_HOLY    = "Sagrado",      PRIEST_SHADOW  = "Sombra",
        DK_BLOOD       = "Sangre",       DK_FROST       = "Escarcha",     DK_UNHOLY      = "Profano",
        SHAMAN_ELEM    = "Elemental",    SHAMAN_ENH     = "Mejora",       SHAMAN_RESTO   = "Restauración",
        MAGE_ARCANE    = "Arcano",       MAGE_FIRE      = "Fuego",        MAGE_FROST     = "Escarcha",
        WARLOCK_AFF    = "Aflicción",    WARLOCK_DEMO   = "Demonología",  WARLOCK_DESTRO = "Destrucción",
        DRUID_BALANCE  = "Equilibrio",   DRUID_FERAL    = "Feral",        DRUID_RESTO    = "Restauración",
    },
    EN = {
        WARRIOR_ARMS   = "Arms",         WARRIOR_FURY   = "Fury",         WARRIOR_PROT   = "Protection",
        PALADIN_HOLY   = "Holy",         PALADIN_PROT   = "Protection",   PALADIN_RET    = "Retribution",
        HUNTER_BM      = "Beast Mastery",HUNTER_MM      = "Marksmanship", HUNTER_SURV    = "Survival",
        ROGUE_ASS      = "Assassination",ROGUE_COMBAT   = "Combat",       ROGUE_SUB      = "Subtlety",
        PRIEST_DISC    = "Discipline",   PRIEST_HOLY    = "Holy",         PRIEST_SHADOW  = "Shadow",
        DK_BLOOD       = "Blood",        DK_FROST       = "Frost",        DK_UNHOLY      = "Unholy",
        SHAMAN_ELEM    = "Elemental",    SHAMAN_ENH     = "Enhancement",  SHAMAN_RESTO   = "Restoration",
        MAGE_ARCANE    = "Arcane",       MAGE_FIRE      = "Fuego",        MAGE_FROST     = "Frost",
        WARLOCK_AFF    = "Affliction",   WARLOCK_DEMO   = "Demonology",   WARLOCK_DESTRO = "Destruction",
        DRUID_BALANCE  = "Balance",      DRUID_FERAL    = "Feral",        DRUID_RESTO    = "Restoration",
    },
}

local ROLE_NAMES = {
    ES = { melee = "Daño C-C", ranged = "Rango", tank = "Tanque", heal = "Sanador", feral = "Feral" },
    EN = { melee = "Melee DPS", ranged = "Ranged DPS", tank = "Tank", heal = "Healer", feral = "Feral" },
}

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
    melee  = {0.9, 0.2, 0.2}, ranged = {1.0, 0.6, 0.1}, tank   = {0.4, 0.7, 1.0},
    heal   = {0.2, 0.9, 0.4}, feral  = {0.9, 0.5, 0.1},
}

local EQUIP_SLOT_MAP = {
    INVTYPE_HEAD = "Head", INVTYPE_NECK = "Neck", INVTYPE_SHOULDER = "Shoulder", INVTYPE_CLOAK = "Back",
    INVTYPE_CHEST = "Chest", INVTYPE_ROBE = "Chest", INVTYPE_BODY = "Shirt", INVTYPE_TABARD = "Tabard",
    INVTYPE_WRIST = "Wrist", INVTYPE_HAND = "Hands", INVTYPE_WAIST = "Waist", INVTYPE_LEGS = "Legs",
    INVTYPE_FEET = "Feet", INVTYPE_FINGER = "Finger1", INVTYPE_TRINKET = "Trinket1",
    INVTYPE_WEAPON = "MainHand", INVTYPE_2HWEAPON = "MainHand", INVTYPE_WEAPONMAINHAND = "MainHand",
    INVTYPE_WEAPONOFFHAND = "OffHand", INVTYPE_SHIELD = "OffHand", INVTYPE_HOLDABLE = "OffHand",
    INVTYPE_RANGED = "Ranged", INVTYPE_RANGEDRIGHT = "Ranged", INVTYPE_THROWN = "Ranged", INVTYPE_RELIC = "Ranged",
}

local SLOT_LAYOUT = {
    { name = "Head",      labelKey = "Head",     x = -150, y =  200 },
    { name = "Neck",      labelKey = "Neck",     x = -150, y =  146 },
    { name = "Shoulder",  labelKey = "Shoulder", x = -150, y =   92 },
    { name = "Back",      labelKey = "Back",     x = -150, y =   38 },
    { name = "Chest",     labelKey = "Chest",    x = -150, y =  -16 },
    { name = "Shirt",     labelKey = "Shirt",    x = -150, y =  -70 },
    { name = "Tabard",    labelKey = "Tabard",   x = -150, y = -124 },
    { name = "Wrist",     labelKey = "Wrist",    x = -150, y = -178 },
    { name = "Hands",     labelKey = "Hands",    x =  140, y =  200 },
    { name = "Waist",     labelKey = "Waist",    x =  140, y =  146 },
    { name = "Legs",      labelKey = "Legs",     x =  140, y =   92 },
    { name = "Feet",      labelKey = "Feet",     x =  140, y =   38 },
    { name = "Finger1",   labelKey = "Ring1",    x =  140, y =  -16 },
    { name = "Finger2",   labelKey = "Ring2",    x =  140, y =  -70 },
    { name = "Trinket1",  labelKey = "Trinket1", x =  140, y = -124 },
    { name = "Trinket2",  labelKey = "Trinket2", x =  140, y = -178 },
    { name = "MainHand",  labelKey = "MainHand", x = -150, y = -245 },
    { name = "OffHand",   labelKey = "OffHand",  x =  140, y = -245 },
    { name = "Ranged",    labelKey = "Ranged",   x =   -5, y = -245 },
}

local SLOT_SZ = 37
local WIN_W   = 680
local WIN_H   = 620

local QUALITY_COLOR = {
    [0] = {0.62, 0.62, 0.62}, [1] = {1,    1,    1   }, [2] = {0.12, 1,    0   },
    [3] = {0,    0.44, 0.87}, [4] = {0.64, 0.21, 0.93}, [5] = {1,    0.5,  0   },
}

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

local paperdollFrame = CreateFrame("Frame", nil, inspectFrame)
paperdollFrame:SetSize(440, 620)
paperdollFrame:SetPoint("TOPLEFT", inspectFrame, "TOPLEFT", 0, 0)

local inspectHeader = CreateFrame("Frame", nil, inspectFrame)
inspectHeader:SetPoint("TOPLEFT",  inspectFrame, "TOPLEFT",  0, 0)
inspectHeader:SetPoint("TOPRIGHT", inspectFrame, "TOPRIGHT", 0, 0)
inspectHeader:SetHeight(52)
inspectHeader:SetBackdrop({ bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background" })
inspectHeader:SetBackdropColor(0.08, 0.07, 0.03, 1)

-- TÍTULO ALINEADO Y CENTRADO EN EL MEDIO DEL PAPERDOLL
local inspectTitle = inspectHeader:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
inspectTitle:SetPoint("CENTER", paperdollFrame, "TOP", 12, -26) -- Desplazado ligeramente a la derecha para equilibrar el icono
inspectTitle:SetTextColor(1, 0.82, 0, 1)
inspectTitle:SetText("NPCBot Inventory Inspector")

-- ============================================================
-- ICONO DEL TÍTULO (Libro de Hechizos y Habilidades)
-- ============================================================
local inspectTitleIcon = inspectHeader:CreateTexture(nil, "OVERLAY")
inspectTitleIcon:SetSize(22, 22)
inspectTitleIcon:SetTexture("Interface\\Spellbook\\Spellbook-Icon")
inspectTitleIcon:SetPoint("RIGHT", inspectTitle, "LEFT", -8, 0)

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
-- ANCLAJES SECTOR IDIOMA (Mantenidos fijos a la derecha)
-- ============================================================
local langText = inspectFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
langText:SetPoint("TOPRIGHT", inspectFrame, "TOPRIGHT", -75, -20)
langText:SetTextColor(1, 0.82, 0, 1)
langText:SetText(T("lang_prefix"))
inspectFrame.langText = langText

local langSelector = CreateFrame("Frame", "NBI_LangSelector", inspectFrame, "BackdropTemplate")
langSelector:SetSize(40, 20)
langSelector:SetPoint("LEFT", langText, "RIGHT", 6, 0)
langSelector:SetBackdrop({
    bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 8, edgeSize = 8,
    insets = { left = 2, right = 2, top = 2, bottom = 2 },
})
langSelector:SetBackdropColor(0.08, 0.08, 0.12, 0.9)
langSelector:SetBackdropBorderColor(0.5, 0.42, 0.1, 0.8)
langSelector:EnableMouse(true)
langSelector:SetFrameLevel(inspectFrame:GetFrameLevel() + 5)

local langLabel = langSelector:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
langLabel:SetPoint("CENTER", langSelector, "CENTER", 0, 0)
langLabel:SetTextColor(1, 1, 1, 1)
langLabel:SetText(LANG)
inspectFrame.langLabel = langLabel

local langDropdown = CreateFrame("Frame", "NBI_LangDropdown", inspectFrame, "BackdropTemplate")
langDropdown:SetSize(40, 46)
langDropdown:SetPoint("TOPRIGHT", langSelector, "BOTTOMRIGHT", 0, -2)
langDropdown:SetBackdrop({
    bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 8, edgeSize = 8,
    insets = { left = 2, right = 2, top = 2, bottom = 2 },
})
langDropdown:SetBackdropColor(0.08, 0.08, 0.12, 0.97)
langDropdown:SetBackdropBorderColor(0.5, 0.42, 0.1, 0.9)
langDropdown:SetFrameLevel(inspectFrame:GetFrameLevel() + 20)
langDropdown:Hide()

-- ============================================================
-- VENTANA DE AYUDA (HELP FRAME)
-- ============================================================
local helpWin = CreateFrame("Frame", "NBI_HelpWindow", inspectFrame)
helpWin:SetSize(400, 160)
helpWin:SetPoint("CENTER", inspectFrame, "CENTER", 0, 0)
helpWin:SetFrameLevel(inspectFrame:GetFrameLevel() + 50)
GoldBorder(helpWin)
helpWin:SetBackdropColor(0.08, 0.08, 0.12, 0.98)
helpWin:Hide()

local helpWinTitle = helpWin:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
helpWinTitle:SetPoint("TOP", helpWin, "TOP", 0, -15)
helpWinTitle:SetTextColor(1, 0.82, 0, 1)
helpWinTitle:SetText(T("help_title"))

local helpWinText = helpWin:CreateFontString(nil, "OVERLAY", "GameFontNormal")
helpWinText:SetPoint("TOPLEFT", helpWin, "TOPLEFT", 20, -45)
helpWinText:SetPoint("BOTTOMRIGHT", helpWin, "BOTTOMRIGHT", -20, 45)
helpWinText:SetJustifyH("CENTER")
helpWinText:SetJustifyV("TOP")
helpWinText:SetTextColor(1, 1, 1, 1)
helpWinText:SetText(T("help_text"))

local helpWinClose = CreateFrame("Button", nil, helpWin, "UIPanelButtonTemplate")
helpWinClose:SetSize(100, 26)
helpWinClose:SetPoint("BOTTOM", helpWin, "BOTTOM", 0, 15)
helpWinClose:SetText(T("help_ok"))
helpWinClose:SetScript("OnClick", function() helpWin:Hide() end)

-- ============================================================
-- BOTÓN DE AYUDA (Posicionado arriba a la izquierda del idioma)
-- ============================================================
local helpBtn = CreateFrame("Button", nil, inspectFrame, "UIPanelButtonTemplate")
helpBtn:SetSize(75, 22)
helpBtn:SetPoint("RIGHT", langText, "LEFT", -28, 0)
helpBtn:SetText(T("help_btn"))
helpBtn:SetScript("OnClick", function()
    if helpWin:IsShown() then helpWin:Hide() else helpWin:Show() end
end)

local function ApplyLanguage(newLang)
    LANG = newLang
    langLabel:SetText(LANG)
    creditsLabel:SetText(T("credits"))
    inspectTitle:SetText(T("title"))
    
    if inspectFrame.langText then inspectFrame.langText:SetText(T("lang_prefix")) end
    if statsRefreshBtn then statsRefreshBtn:SetText(T("refresh_btn")) end
    if helpBtn then helpBtn:SetText(T("help_btn")) end
    if helpWinTitle then helpWinTitle:SetText(T("help_title")) end
    if helpWinText then helpWinText:SetText(T("help_text")) end
    if helpWinClose then helpWinClose:SetText(T("help_ok")) end
    if inspectFrame.noPartyMessage then inspectFrame.noPartyMessage:SetText(T("no_party_msg")) end
    
    for _, slotInfo in ipairs(SLOT_LAYOUT) do
        local sf = inspectFrame.slotFrames and inspectFrame.slotFrames[slotInfo.name]
        if sf and sf.slotLabel then
            sf.slotLabel:SetText(T(slotInfo.labelKey))
        end
    end
    if inspectFrame:IsShown() and inspectFrame.currentBot then
        NBI.OpenInspect(inspectFrame.currentBot)
    end
    langDropdown:Hide()
end

local LANG_OPTIONS = { "ES", "EN" }
for i, optLang in ipairs(LANG_OPTIONS) do
    local row = CreateFrame("Button", nil, langDropdown)
    row:SetSize(36, 20)
    row:SetPoint("TOPLEFT", langDropdown, "TOPLEFT", 2, -2 - (i-1)*22)
    local rowBg = row:CreateTexture(nil, "BACKGROUND")
    rowBg:SetAllPoints(row)
    rowBg:SetTexture(0, 0, 0, 0)
    row:SetScript("OnEnter", function() rowBg:SetTexture(0.3, 0.25, 0.05, 0.5) end)
    row:SetScript("OnLeave", function() rowBg:SetTexture(0, 0, 0, 0) end)
    
    local optLabel = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    optLabel:SetPoint("CENTER", row, "CENTER", 0, 0)
    optLabel:SetTextColor(1, 1, 1, 1)
    optLabel:SetText(optLang)
    
    row:SetScript("OnClick", function() ApplyLanguage(optLang) end)
end

langSelector:SetScript("OnMouseDown", function()
    if langDropdown:IsShown() then langDropdown:Hide() else langDropdown:Show() end
end)

inspectFrame:SetScript("OnMouseDown", function() langDropdown:Hide() end)

-- ============================================================
-- MODELO 3D TOTALMENTE INTEGRADO Y REESCALADO SIN VACÍOS
-- ============================================================
local centerBg = CreateFrame("Frame", nil, paperdollFrame)
centerBg:SetSize(220, 443) 
centerBg:SetPoint("TOP", paperdollFrame, "CENTER", -5, 208) 
centerBg:SetBackdrop({
    bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 12,
    insets = { left = 3, right = 3, top = 3, bottom = 3 },
})
centerBg:SetBackdropColor(0.05, 0.05, 0.1, 0.5)
centerBg:SetBackdropBorderColor(0.3, 0.25, 0.1, 0.6)

local portraitModel = CreateFrame("PlayerModel", "NBI_PortraitModel", centerBg)
portraitModel:SetSize(212, 435)
portraitModel:SetPoint("CENTER", centerBg, "CENTER", 0, 0)

-- ============================================================
-- MENSAJE DE ADVERTENCIA (FUERA DE GRUPO)
-- ============================================================
local noPartyMessage = centerBg:CreateFontString(nil, "OVERLAY", "GameFontNormal")
noPartyMessage:SetPoint("CENTER", centerBg, "CENTER", 0, 0)
noPartyMessage:SetSize(180, 200)
noPartyMessage:SetJustifyH("CENTER")
noPartyMessage:SetJustifyV("MIDDLE")
noPartyMessage:SetTextColor(1, 0.3, 0.3, 1)
noPartyMessage:SetText(T("no_party_msg"))
noPartyMessage:Hide()
inspectFrame.noPartyMessage = noPartyMessage

local portraitPlaceholder = centerBg:CreateTexture(nil, "ARTWORK")
portraitPlaceholder:SetSize(120, 120)
portraitPlaceholder:SetPoint("CENTER", portraitModel, "CENTER", 0, 0)
portraitPlaceholder:SetTexture("Interface\\CHARACTERFRAME\\TempPortraitAlphaMask")
portraitPlaceholder:SetAlpha(0.3)

local infoOverlay = CreateFrame("Frame", nil, centerBg)
infoOverlay:SetSize(212, 45)
infoOverlay:SetPoint("BOTTOM", portraitModel, "BOTTOM", 0, 0)
local bgTex = infoOverlay:CreateTexture(nil, "BACKGROUND")
bgTex:SetAllPoints()
bgTex:SetTexture(0, 0, 0, 0.8)

local botInfoClassIcon = infoOverlay:CreateTexture(nil, "OVERLAY")
botInfoClassIcon:SetSize(18, 18)
botInfoClassIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
botInfoClassIcon:SetPoint("TOPLEFT", infoOverlay, "TOPLEFT", 10, -5)
inspectFrame.botInfoClassIcon = botInfoClassIcon

local botInfoName = infoOverlay:CreateFontString(nil, "OVERLAY", "GameFontNormal")
botInfoName:SetPoint("LEFT", botInfoClassIcon, "RIGHT", 6, 0)
botInfoName:SetPoint("RIGHT", infoOverlay, "RIGHT", -10, 0)
botInfoName:SetJustifyH("LEFT")
botInfoName:SetTextColor(1, 0.82, 0, 1)
inspectFrame.botInfoName = botInfoName

local botInfoSpecIcon = infoOverlay:CreateTexture(nil, "OVERLAY")
botInfoSpecIcon:SetSize(14, 14)
botInfoSpecIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
botInfoSpecIcon:SetPoint("BOTTOMLEFT", infoOverlay, "BOTTOMLEFT", 10, 6)
inspectFrame.botInfoSpecIcon = botInfoSpecIcon

local botInfoSpec = infoOverlay:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
botInfoSpec:SetPoint("LEFT", botInfoSpecIcon, "RIGHT", 6, 0)
botInfoSpec:SetPoint("RIGHT", infoOverlay, "RIGHT", -10, 0)
botInfoSpec:SetJustifyH("LEFT")
botInfoSpec:SetTextColor(0.75, 0.75, 0.75, 1)
inspectFrame.botInfoSpec = botInfoSpec

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
        local unitId = inspectFrame.FindBotUnitId(botName)
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
    local entry = NBI.botEntryByName and NBI.botEntryByName[botName]
    local botClass = entry and NBI.botClasses[entry]

    local gs = ""
    local statsText = NBI.botStats and NBI.botStats[botName]
    if statsText then
        local gsVal = statsText:match("GS%s*:%s*(%d+)")
        if gsVal then gs = "GS: " .. gsVal end
    end

    inspectFrame.botInfoName:SetText(botName)

    local bic = inspectFrame.botInfoClassIcon
    if botClass and CLASS_ICON_TCOORDS and CLASS_ICON_TCOORDS[botClass] then
        bic:SetTexture("Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes")
        bic:SetTexCoord(unpack(CLASS_ICON_TCOORDS[botClass]))
        bic:Show()
    else
        bic:Hide()
    end

    local biSpec = inspectFrame.botInfoSpec
    local biSpecIcon = inspectFrame.botInfoSpecIcon
    local info = entry and GetSpecInfo(NBI.botRoles[entry])
    
    if info then
        if SPEC_ICONS[NBI.botRoles[entry]] then
            biSpecIcon:SetTexture(SPEC_ICONS[NBI.botRoles[entry]])
            biSpecIcon:Show()
        else
            biSpecIcon:Hide()
        end
        local rc = info.color
        local specStr = string.format("|cff%02x%02x%02x%s|r", rc[1]*255, rc[2]*255, rc[3]*255, info.name)
        if gs ~= "" then
            specStr = specStr .. "  |cff33ff66" .. gs .. "|r"
        end
        biSpec:SetText(specStr)
    else
        biSpecIcon:Hide()
        biSpec:SetText(gs ~= "" and ("|cff33ff66" .. gs .. "|r") or "")
    end

    if unitId then
        portraitModel:SetUnit(unitId)
        portraitPlaceholder:SetAlpha(0)
        inspectFrame.noPartyMessage:Hide()
    else
        portraitModel:ClearModel()
        portraitPlaceholder:SetAlpha(0.3)
        inspectFrame.noPartyMessage:Show()
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

    NBI.OpenStatsWindow(botName)

    helpWin:Hide()
    
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
