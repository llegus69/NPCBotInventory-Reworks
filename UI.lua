-- ============================================================
-- NPCBotInventory - UI.lua
-- Panel lateral de bots con Multi-idioma, Avatares 2D e Iconos de Spec (Grandes)
-- Autor: Lleguito | Version: 3.8 | WotLK 3.3.5
-- ============================================================

local NBI = NPCBotInventory

local C = {
    bg     = {0.05, 0.05, 0.08, 0.97},
    header = {0.08, 0.08, 0.13, 1},
    gold   = {1,    0.82, 0.0,  1},
    white  = {1,    1,    1,    1},
    grey   = {0.55, 0.55, 0.55, 1},
    green  = {0.2,  0.9,  0.4,  1},
    border = {0.3,  0.25, 0.15, 1},
}

-- Ampliamos el ancho total para dar un espacio cómodo a los iconos más grandes
local PANEL_W = 275

-- ============================================================
-- LOCALIZACIÓN (SISTEMA DE IDIOMAS)
-- ============================================================
local locales = {
    es = {
        title = "NPCBots",
        langLabel = "Idioma:",
        clearAll = "Borrar todo",
        confirmClear = "¿Borrar todos los inventarios de bot?",
        yes = "Si, borrar",
        cancel = "Cancelar",
        toggleBtn = "Bot Inventory",
        minimapClick = "Click para abrir/cerrar",
        minimapDrag = "Arrastra para mover",
        inspectTooltip = "Abrir paperdoll de personaje",
        notFound = "Bot '%s' no encontrado.",
        loaded = "Cargado. Usa /botinv para abrir.",
    },
    en = {
        title = "NPCBots",
        langLabel = "Lang:",
        clearAll = "Clear All",
        confirmClear = "Clear all bot inventories?",
        yes = "Yes, clear",
        cancel = "Cancel",
        toggleBtn = "Bot Inventory",
        minimapClick = "Click to open/close",
        minimapDrag = "Drag to move",
        inspectTooltip = "Open paperdoll inspect",
        notFound = "Bot '%s' not found.",
        loaded = "Loaded. Use /botinv to open.",
    }
}

local L = locales.es

local function SetLanguage(lang)
    if locales[lang] then
        L = locales[lang]
        if NBIButtonPos then NBIButtonPos.lang = lang end
        if NBI_ListPanel then
            if NBI_ListPanel.titleText then NBI_ListPanel.titleText:SetText(L.title) end
            if NBI_ListPanel.langLabelText then NBI_ListPanel.langLabelText:SetText(L.langLabel) end
            if NBI_ListPanel.clearBtn then NBI_ListPanel.clearBtn:SetText(L.clearAll) end
            if NBI_ToggleButton then NBI_ToggleButton:SetText(L.toggleBtn) end
            StaticPopupDialogs["NBI_CONFIRM_CLEAR"].text = L.confirmClear
            StaticPopupDialogs["NBI_CONFIRM_CLEAR"].button1 = L.yes
            StaticPopupDialogs["NBI_CONFIRM_CLEAR"].button2 = L.cancel
            if NBI_ListPanel:IsShown() then RefreshBotList() end
        end
    end
end

-- ============================================================
-- HELPERS
-- ============================================================
local function SetStyle(frame)
    frame:SetBackdrop({
        bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 14,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })
    frame:SetBackdropColor(C.bg[1], C.bg[2], C.bg[3], C.bg[4])
    frame:SetBackdropBorderColor(C.border[1], C.border[2], C.border[3], 1)
end

local function MakeDraggable(frame)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop",  frame.StopMovingOrSizing)
end

local function Divider(parent, y)
    local d = parent:CreateTexture(nil, "ARTWORK")
    d:SetHeight(1)
    d:SetPoint("TOPLEFT",  parent, "TOPLEFT",  8, y)
    d:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -8, y)
    d:SetTexture(C.gold[1], C.gold[2], C.gold[3], 0.4)
end

local function Header(parent, text)
    local h = CreateFrame("Frame", nil, parent)
    h:SetPoint("TOPLEFT",  parent, "TOPLEFT",  0, 0)
    h:SetPoint("TOPRIGHT", parent, "TOPRIGHT", 0, 0)
    h:SetHeight(34)
    h:SetBackdrop({ bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background" })
    h:SetBackdropColor(C.header[1], C.header[2], C.header[3], C.header[4])
    
    local t = h:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    t:SetPoint("LEFT", h, "LEFT", 12, 0)
    t:SetText(text)
    t:SetTextColor(C.gold[1], C.gold[2], C.gold[3])
    
    Divider(parent, -34)
    parent.titleText = t
    return h
end

local function SolidTexture(parent, r, g, b, a, layer)
    local tex = parent:CreateTexture(nil, layer or "BACKGROUND")
    tex:SetTexture(r, g, b, a or 1)
    return tex
end

-- ============================================================
-- PANEL DE LISTA DE BOTS
-- ============================================================
local listPanel = CreateFrame("Frame", "NBI_ListPanel", UIParent)
listPanel:SetSize(PANEL_W, 420)
listPanel:SetPoint("CENTER", UIParent, "CENTER", -300, 0)
listPanel:SetFrameStrata("MEDIUM")
SetStyle(listPanel)
MakeDraggable(listPanel)
listPanel:Hide()

local headerFrame = Header(listPanel, L.title)

local listClose = CreateFrame("Button", nil, listPanel, "UIPanelCloseButton")
listClose:SetPoint("TOPRIGHT", listPanel, "TOPRIGHT", 4, 4)
listClose:SetScript("OnClick", function() listPanel:Hide() end)

local langLabel = headerFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
langLabel:SetPoint("LEFT", listPanel.titleText, "RIGHT", 15, -1)
langLabel:SetText(L.langLabel)
langLabel:SetTextColor(C.grey[1], C.grey[2], C.grey[3])
listPanel.langLabelText = langLabel

local langDropdown = CreateFrame("Frame", "NBI_LangDropdown", listPanel, "UIDropDownMenuTemplate")
langDropdown:SetPoint("LEFT", langLabel, "RIGHT", -12, -3)
UIDropDownMenu_SetWidth(langDropdown, 45)

local function LangDropdown_OnClick(self)
    UIDropDownMenu_SetSelectedValue(langDropdown, self.value)
    SetLanguage(self.value)
    UIDropDownMenu_SetText(langDropdown, self.value:upper())
end

UIDropDownMenu_Initialize(langDropdown, function(self, level)
    local info = UIDropDownMenu_CreateInfo()
    info.text = "ES" info.value = "es" info.func = LangDropdown_OnClick info.checked = (L == locales.es)
    UIDropDownMenu_AddButton(info, level)
    info.text = "EN" info.value = "en" info.func = LangDropdown_OnClick info.checked = (L == locales.en)
    UIDropDownMenu_AddButton(info, level)
end)

local listScroll = CreateFrame("ScrollFrame", "NBI_ListScroll", listPanel, "UIPanelScrollFrameTemplate")
listScroll:SetPoint("TOPLEFT",     listPanel, "TOPLEFT",     6, -42)
listScroll:SetPoint("BOTTOMRIGHT", listPanel, "BOTTOMRIGHT", -26, 44)

local listContent = CreateFrame("Frame", nil, listScroll)
listContent:SetSize(PANEL_W - 36, 10)
listScroll:SetScrollChild(listContent)

listPanel.botButtons = {}

function RefreshBotList()
    for _, btn in pairs(listPanel.botButtons) do
        btn:Hide()
        btn:SetParent(nil)
    end
    wipe(listPanel.botButtons)

    local names = {}
    for name in pairs(NBI.botInventories) do table.insert(names, name) end
    table.sort(names)

    local btnH = 28 -- Aumentamos ligeramente la altura de cada fila para los iconos más grandes
    local yOff = -4

    for _, botName in ipairs(names) do
        local btn = CreateFrame("Button", nil, listContent)
        btn:SetSize(PANEL_W - 40, btnH)
        btn:SetPoint("TOPLEFT", listContent, "TOPLEFT", 2, yOff)

        local bg = SolidTexture(btn, 0.12, 0.12, 0.18, 0.8, "BACKGROUND")
        bg:SetAllPoints()

        local hl = SolidTexture(btn, C.gold[1], C.gold[2], C.gold[3], 0.15, "HIGHLIGHT")
        hl:SetAllPoints()

        local dot = SolidTexture(btn, C.green[1], C.green[2], C.green[3], 1, "ARTWORK")
        dot:SetSize(6, 6)
        dot:SetPoint("LEFT", btn, "LEFT", 6, 0)

        -- Identificar si el bot está accesible como unidad para extraer datos
        local unitID = nil
        if UnitName("target") == botName then unitID = "target"
        elseif UnitName("focus") == botName then unitID = "focus"
        else
            for i = 1, MAX_PARTY_MEMBERS or 4 do
                if UnitName("party"..i) == botName then unitID = "party"..i break end
            end
        end

        -- 1. AVATAR 2D (ROSTRO) - Aumentado a 22x22
        local avatar = btn:CreateTexture(nil, "ARTWORK")
        avatar:SetSize(22, 22)
        avatar:SetPoint("LEFT", btn, "LEFT", 16, 0)
        if unitID then
            SetPortraitTexture(avatar, unitID)
        else
            avatar:SetTexture("Interface\\Icons\\INV_Helmet_04")
        end
        avatar:SetTexCoord(0.08, 0.92, 0.08, 0.92)

        -- 2. ICONO DE ESPECIFICACIÓN / CLASE - Aumentado a 20x20
        local specIcon = btn:CreateTexture(nil, "ARTWORK")
        specIcon:SetSize(20, 20)
        specIcon:SetPoint("LEFT", avatar, "RIGHT", 5, 0)
        
        if unitID then
            local _, classFilename = UnitClass(unitID)
            if classFilename then
                specIcon:SetTexture("Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes")
                local coords = CLASS_BUTTONS[classFilename]
                if coords then
                    specIcon:SetTexCoord(coords[1], coords[2], coords[3], coords[4])
                end
            else
                specIcon:SetTexture("Interface\\Icons\\Ability_Marksmanship")
                specIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
            end
        else
            -- Icono por defecto (Espadas cruzadas) si el bot no está en el rango/foco
            specIcon:SetTexture("Interface\\Icons\\Ability_Marksmanship")
            specIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        end

        -- Nombre desplazado teniendo en cuenta el nuevo tamaño de los iconos
        local lbl = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        lbl:SetPoint("LEFT",  specIcon, "RIGHT",  6, 0)
        lbl:SetPoint("RIGHT", btn, "RIGHT", -55, 0)
        lbl:SetJustifyH("LEFT")
        lbl:SetTextColor(C.white[1], C.white[2], C.white[3])
        lbl:SetText(botName)

        local count = NBI.botInventories[botName] and #NBI.botInventories[botName] or 0
        local cnt = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        cnt:SetPoint("RIGHT", btn, "RIGHT", -28, 0)
        cnt:SetTextColor(C.grey[1], C.grey[2], C.grey[3])
        cnt:SetText("(" .. count .. ")")

        local inspBtn = CreateFrame("Button", nil, btn)
        inspBtn:SetSize(22, 22)
        inspBtn:SetPoint("RIGHT", btn, "RIGHT", -2, 0)

        local inspIcon = inspBtn:CreateTexture(nil, "ARTWORK")
        inspIcon:SetAllPoints()
        inspIcon:SetTexture("Interface\\Icons\\INV_Misc_Book_09")
        inspIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

        local inspHL = inspBtn:CreateTexture(nil, "HIGHLIGHT")
        inspHL:SetAllPoints()
        inspHL:SetTexture("Interface\\Buttons\\ButtonHilight-Square")
        inspHL:SetBlendMode("ADD")

        inspBtn:SetScript("OnClick", function()
            if NPCBotInventory.OpenInspect then NPCBotInventory.OpenInspect(botName) end
        end)
        inspBtn:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(L.inspectTooltip)
            GameTooltip:Show()
        end)
        inspBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)

        btn:SetScript("OnEnter", function() lbl:SetTextColor(C.gold[1], C.gold[2], C.gold[3]) end)
        btn:SetScript("OnLeave", function() lbl:SetTextColor(C.white[1], C.white[2], C.white[3]) end)

        table.insert(listPanel.botButtons, btn)
        yOff = yOff - btnH - 2
    end

    listContent:SetHeight(math.abs(yOff) + 8)
    listPanel:SetHeight(math.min(math.max(math.abs(yOff) + 90, 120), 500))
end

-- ============================================================
-- BOTON "BORRAR TODO"
-- ============================================================
StaticPopupDialogs["NBI_CONFIRM_CLEAR"] = {
    text           = L.confirmClear,
    button1        = L.yes,
    button2        = L.cancel,
    OnAccept       = function() NBI.ClearAll() end,
    timeout        = 0,
    whileDead      = true,
    hideOnEscape   = true,
    preferredIndex = 3,
}

local clearBtn = CreateFrame("Button", nil, listPanel, "UIPanelButtonTemplate")
clearBtn:SetSize(PANEL_W - 20, 24)
clearBtn:SetPoint("BOTTOM", listPanel, "BOTTOM", 0, 10)
clearBtn:SetText(L.clearAll)
clearBtn:SetScript("OnClick", function() StaticPopup_Show("NBI_CONFIRM_CLEAR") end)
listPanel.clearBtn = clearBtn

-- ============================================================
-- BOTON DE MINIMAPA
-- ============================================================
local minimapBtn = CreateFrame("Button", "NBI_MinimapButton", Minimap)
minimapBtn:SetSize(28, 28)
minimapBtn:SetFrameStrata("MEDIUM")
minimapBtn:SetFrameLevel(8)

local minimapAngle = 220

local function UpdateMinimapPos()
    local rad = math.rad(minimapAngle)
    local x = math.cos(rad) * 80
    local y = math.sin(rad) * 80
    minimapBtn:SetPoint("CENTER", Minimap, "CENTER", x, y)
end

local minimapBg = minimapBtn:CreateTexture(nil, "BACKGROUND")
minimapBg:SetSize(28, 28)
minimapBg:SetAllPoints()
minimapBg:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")

local minimapIcon = minimapBtn:CreateTexture(nil, "ARTWORK")
minimapIcon:SetSize(18, 18)
minimapIcon:SetPoint("CENTER", minimapBtn, "CENTER", 0, 0)
minimapIcon:SetTexture("Interface\\Icons\\INV_Misc_Note_01")
minimapIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

local minimapHL = minimapBtn:CreateTexture(nil, "HIGHLIGHT")
minimapHL:SetSize(28, 28)
minimapHL:SetAllPoints()
minimapHL:SetTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

minimapBtn:SetScript("OnClick", function(self, button)
    if listPanel:IsShown() then
        listPanel:Hide()
    else
        listPanel:ClearAllPoints()
        listPanel:SetPoint("TOP", toggleBtn, "BOTTOM", 0, -4)
        RefreshBotList()
        listPanel:Show()
    end
end)

minimapBtn:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    GameTooltip:AddLine("NPCBot Inventory")
    GameTooltip:AddLine(L.minimapClick, 0.8, 0.8, 0.8)
    GameTooltip:AddLine(L.minimapDrag, 0.5, 0.5, 0.5)
    GameTooltip:Show()
end)
minimapBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)

minimapBtn:SetMovable(true)
minimapBtn:RegisterForDrag("LeftButton")
minimapBtn:SetScript("OnDragStart", function(self)
    self:SetScript("OnUpdate", function(self)
        local mx, my = Minimap:GetCenter()
        local px, py = GetCursorPosition()
        local scale  = UIParent:GetEffectiveScale()
        px = px / scale py = py / scale
        minimapAngle = math.deg(math.atan2(py - my, px - mx))
        UpdateMinimapPos()
        NBIButtonPos = NBIButtonPos or {}
        NBIButtonPos.minimapAngle = minimapAngle
    end)
end)
minimapBtn:SetScript("OnDragStop", function(self) self:SetScript("OnUpdate", nil) end)

UpdateMinimapPos()

-- ============================================================
-- BOTON FLOTANTE
-- ============================================================
local toggleBtn = CreateFrame("Button", "NBI_ToggleButton", UIParent, "UIPanelButtonTemplate")
toggleBtn:SetSize(130, 28)
toggleBtn:SetText(L.toggleBtn)
toggleBtn:SetFrameStrata("HIGH")
MakeDraggable(toggleBtn)
toggleBtn:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    local point, _, relPoint, x, y = self:GetPoint()
    NBIButtonPos = { point = point, relPoint = relPoint, x = x, y = y }
    if listPanel:IsShown() then
        listPanel:ClearAllPoints()
        listPanel:SetPoint("TOP", self, "BOTTOM", 0, -4)
    end
end)
toggleBtn:SetScript("OnClick", function()
    if listPanel:IsShown() then
        listPanel:Hide()
    else
        listPanel:ClearAllPoints()
        listPanel:SetPoint("TOP", toggleBtn, "BOTTOM", 0, -4)
        RefreshBotList()
        listPanel:Show()
    end
end)

-- ============================================================
-- CALLBACKS desde Core.lua
-- ============================================================
function NBI.OnDataLoaded()
    toggleBtn:ClearAllPoints()
    if NBIButtonPos then
        local savedLang = NBIButtonPos.lang or "es"
        SetLanguage(savedLang)
        UIDropDownMenu_SetSelectedValue(langDropdown, savedLang)
        UIDropDownMenu_SetText(langDropdown, savedLang:upper())
        toggleBtn:SetPoint(NBIButtonPos.point or "TOPRIGHT", UIParent, NBIButtonPos.relPoint or "TOPRIGHT", NBIButtonPos.x or -220, NBIButtonPos.y or -100)
        if NBIButtonPos.minimapAngle then
            minimapAngle = NBIButtonPos.minimapAngle
            UpdateMinimapPos()
        end
    else
        toggleBtn:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -220, -100)
        UIDropDownMenu_SetSelectedValue(langDropdown, "es")
        UIDropDownMenu_SetText(langDropdown, "ES")
    end

    RefreshBotList()
    if next(NBI.botInventories) ~= nil then
        listPanel:ClearAllPoints()
        listPanel:SetPoint("TOP", toggleBtn, "BOTTOM", 0, -4)
        listPanel:Show()
    end
end

function NBI.OnBotDataUpdated(botName)
    if listPanel:IsShown() then RefreshBotList() end
end

function NBI.OnDataCleared() RefreshBotList() end

-- ============================================================
-- SLASH COMMANDS
-- ============================================================
SLASH_NBOTINV1 = "/botinv"
SLASH_NBOTINV2 = "/npcbotinv"
SlashCmdList["NBOTINV"] = function(msg)
    msg = msg:trim()
    if msg == "" then
        if listPanel:IsShown() then listPanel:Hide() else
            listPanel:ClearAllPoints()
            listPanel:SetPoint("TOP", toggleBtn, "BOTTOM", 0, -4)
            RefreshBotList()
            listPanel:Show()
        end
    else
        if NBI.botInventories[msg] and NPCBotInventory.OpenInspect then
            NPCBotInventory.OpenInspect(msg)
        else
            print("|cffFFD700[NPCBotInventory]|r " .. string.format(L.notFound, msg))
        end
    end
end

print("|cffFFD700[NPCBotInventory]|r " .. L.loaded)
