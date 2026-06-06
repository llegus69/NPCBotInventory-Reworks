-- ============================================================
-- NPCBotInventory - UI.lua
-- Panel lateral de bots y boton flotante
-- Autor: Lleguito | Version: 3.0 | WotLK 3.3.5
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

local PANEL_W = 270

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
    return t
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
listPanel:SetResizable(true)
listPanel:SetMinResize(200, 150)
SetStyle(listPanel)
MakeDraggable(listPanel)
listPanel:Hide()

Header(listPanel, "NPCBots")

local listClose = CreateFrame("Button", nil, listPanel, "UIPanelCloseButton")
listClose:SetPoint("TOPRIGHT", listPanel, "TOPRIGHT", 1, 1)
listClose:SetScript("OnClick", function()
    listPanel:Hide()
end)

local listScroll = CreateFrame("ScrollFrame", "NBI_ListScroll", listPanel, "UIPanelScrollFrameTemplate")
listScroll:SetPoint("TOPLEFT",     listPanel, "TOPLEFT",     6, -42)
listScroll:SetPoint("BOTTOMRIGHT", listPanel, "BOTTOMRIGHT", -28, 44)

local listContent = CreateFrame("Frame", nil, listScroll)
listContent:SetHeight(10)
listContent:SetWidth(1)  -- mínimo; el scroll lo ajusta al ancho disponible
listScroll:SetScrollChild(listContent)

-- Hacer que listContent se estire al ancho del scroll en todo momento
listScroll:SetScript("OnSizeChanged", function(self)
    listContent:SetWidth(self:GetWidth())
end)

listPanel.botButtons = {}

-- Coordenadas UV del atlas de iconos de clase (WotLK)
local CLASS_ICON_COORDS = {
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
local CLASS_ICON_ATLAS = "Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes"

local function FindBotUnit(botName)
    for i = 1, 4 do
        local unit = "party" .. i
        if UnitExists(unit) and UnitName(unit) == botName then
            return unit
        end
    end
    return nil
end

local function RefreshBotList()
    for _, btn in pairs(listPanel.botButtons) do
        btn:Hide()
        btn:SetParent(nil)
    end
    wipe(listPanel.botButtons)

    local names = {}
    for name in pairs(NBI.botInventories) do
        table.insert(names, name)
    end
    table.sort(names)

    local btnH  = 48
    local yOff  = -6

    for _, botName in ipairs(names) do
        local btn = CreateFrame("Button", nil, listContent)
        btn:SetHeight(btnH)
        -- Ancho dinámico: se estira con listContent siempre
        btn:SetPoint("TOPLEFT",  listContent, "TOPLEFT",  2, yOff)
        btn:SetPoint("TOPRIGHT", listContent, "TOPRIGHT", -2, yOff)

        -- Fondo principal
        local bg = SolidTexture(btn, 0.10, 0.10, 0.16, 0.92, "BACKGROUND")
        bg:SetAllPoints()

        -- Separador inferior dorado
        local sepLine = btn:CreateTexture(nil, "ARTWORK")
        sepLine:SetHeight(1)
        sepLine:SetPoint("BOTTOMLEFT",  btn, "BOTTOMLEFT",  2, 0)
        sepLine:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", -2, 0)
        sepLine:SetTexture(C.gold[1], C.gold[2], C.gold[3], 0.18)

        -- Highlight hover
        local hl = SolidTexture(btn, C.gold[1], C.gold[2], C.gold[3], 0.1, "HIGHLIGHT")
        hl:SetAllPoints()

        -- ── Retrato 2D del bot ──────────────────────────────────────
        local avatarBorder = CreateFrame("Frame", nil, btn)
        avatarBorder:SetSize(40, 40)
        avatarBorder:SetPoint("LEFT", btn, "LEFT", 4, 0)
        avatarBorder:SetBackdrop({
            bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true, tileSize = 8, edgeSize = 8,
            insets = { left = 1, right = 1, top = 1, bottom = 1 },
        })
        avatarBorder:SetBackdropColor(0.04, 0.04, 0.09, 1)
        avatarBorder:SetBackdropBorderColor(C.gold[1], C.gold[2], C.gold[3], 0.55)

        -- Retrato 2D real usando SetPortraitTexture
        local portraitTex = avatarBorder:CreateTexture(nil, "ARTWORK")
        portraitTex:SetSize(34, 34)
        portraitTex:SetPoint("CENTER", avatarBorder, "CENTER", 0, 0)

        local unitId = FindBotUnit(botName)
        if unitId then
            SetPortraitTexture(portraitTex, unitId)
        else
            -- Fallback: icono de clase o genérico
            portraitTex:SetTexture("Interface\\Icons\\INV_Misc_Statue_02")
            portraitTex:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        end

        -- ── Icono de clase (esquina inferior derecha del avatar) ────
        local classFrame = CreateFrame("Frame", nil, btn)
        classFrame:SetSize(16, 16)
        classFrame:SetPoint("BOTTOMLEFT", avatarBorder, "BOTTOMRIGHT", -8, -1)
        classFrame:SetFrameLevel(avatarBorder:GetFrameLevel() + 2)

        local classIconTex = classFrame:CreateTexture(nil, "ARTWORK")
        classIconTex:SetAllPoints()
        classIconTex:SetTexture(CLASS_ICON_ATLAS)

        local botEntry = NBI.botEntryByName and NBI.botEntryByName[botName]
        local botClass = botEntry and NBI.botClasses and NBI.botClasses[botEntry]
        if not botClass and unitId then
            _, botClass = UnitClass(unitId)
        end

        local coords = botClass and CLASS_ICON_COORDS[botClass]
        if coords then
            classIconTex:SetTexCoord(coords[1], coords[2], coords[3], coords[4])
        else
            classIconTex:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
            classIconTex:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        end

        -- ── Nombre ──────────────────────────────────────────────────
        local lbl = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        lbl:SetPoint("TOPLEFT", btn, "TOPLEFT", 52, -8)
        lbl:SetPoint("RIGHT",   btn, "RIGHT",   -38, 0)
        lbl:SetJustifyH("LEFT")
        lbl:SetTextColor(C.white[1], C.white[2], C.white[3])
        lbl:SetText(botName)

        -- ── Sub-línea: spec / rol ────────────────────────────────────
        local roleStr = ""
        if botEntry then
            local spec = NBI.botRoles and NBI.botRoles[botEntry]
            if spec then roleStr = spec:gsub("_", " ") end
        end
        local subLbl = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        subLbl:SetPoint("TOPLEFT", lbl, "BOTTOMLEFT", 0, -2)
        subLbl:SetPoint("RIGHT",   btn, "RIGHT",      -38, 0)
        subLbl:SetJustifyH("LEFT")
        subLbl:SetTextColor(C.grey[1], C.grey[2], C.grey[3])
        subLbl:SetText(roleStr)

        -- ── Botón inspect (icono de habilidades/libro) ──────────────
        local inspBtn = CreateFrame("Button", nil, btn)
        inspBtn:SetSize(26, 26)
        inspBtn:SetPoint("RIGHT", btn, "RIGHT", -10, 0)
        inspBtn:SetFrameLevel(btn:GetFrameLevel() + 5)
        inspBtn:EnableMouse(true)

        local inspIcon = inspBtn:CreateTexture(nil, "ARTWORK")
        inspIcon:SetAllPoints()
        inspIcon:SetTexture("Interface\\Icons\\INV_Misc_Book_09")
        inspIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

        local inspHL2 = inspBtn:CreateTexture(nil, "HIGHLIGHT")
        inspHL2:SetAllPoints()
        inspHL2:SetTexture("Interface\\Buttons\\ButtonHilight-Square")
        inspHL2:SetBlendMode("ADD")

        inspBtn:SetScript("OnClick", function()
            if NPCBotInventory.OpenInspect then
                NPCBotInventory.OpenInspect(botName)
            end
        end)
        inspBtn:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText("Abrir paperdoll")
            GameTooltip:Show()
        end)
        inspBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)

        btn:SetScript("OnEnter", function()
            lbl:SetTextColor(C.gold[1], C.gold[2], C.gold[3])
        end)
        btn:SetScript("OnLeave", function()
            lbl:SetTextColor(C.white[1], C.white[2], C.white[3])
        end)

        table.insert(listPanel.botButtons, btn)
        yOff = yOff - btnH - 3
    end

    listContent:SetHeight(math.abs(yOff) + 8)
    listPanel:SetHeight(math.min(math.max(math.abs(yOff) + 90, 120), 500))
end

-- ============================================================
-- PANEL DE AYUDA (compartido entre lista y paperdoll)
-- ============================================================
local helpPanel = CreateFrame("Frame", "NBI_HelpPanel", UIParent)
helpPanel:SetSize(340, 260)
helpPanel:SetPoint("CENTER")
helpPanel:SetFrameStrata("TOOLTIP")
helpPanel:SetBackdrop({
    bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 32,
    insets = { left = 8, right = 8, top = 8, bottom = 8 },
})
helpPanel:SetBackdropColor(0.05, 0.05, 0.08, 0.98)
helpPanel:SetBackdropBorderColor(0.5, 0.42, 0.1, 1)
helpPanel:SetMovable(true)
helpPanel:EnableMouse(true)
helpPanel:RegisterForDrag("LeftButton")
helpPanel:SetScript("OnDragStart", helpPanel.StartMoving)
helpPanel:SetScript("OnDragStop",  helpPanel.StopMovingOrSizing)
helpPanel:Hide()

-- Header del panel de ayuda
local helpHeader = CreateFrame("Frame", nil, helpPanel)
helpHeader:SetPoint("TOPLEFT",  helpPanel, "TOPLEFT",  0, 0)
helpHeader:SetPoint("TOPRIGHT", helpPanel, "TOPRIGHT", 0, 0)
helpHeader:SetHeight(32)
helpHeader:SetBackdrop({ bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background" })
helpHeader:SetBackdropColor(0.08, 0.07, 0.03, 1)

local helpTitle = helpHeader:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
helpTitle:SetPoint("CENTER", helpHeader, "CENTER", 0, 0)
helpTitle:SetTextColor(1, 0.82, 0, 1)
helpTitle:SetText("? Ayuda / Help")

local helpSep = helpPanel:CreateTexture(nil, "ARTWORK")
helpSep:SetHeight(1)
helpSep:SetPoint("TOPLEFT",  helpPanel, "TOPLEFT",  10, -32)
helpSep:SetPoint("TOPRIGHT", helpPanel, "TOPRIGHT", -10, -32)
helpSep:SetTexture(0.5, 0.42, 0.1, 0.6)

local helpClose = CreateFrame("Button", nil, helpPanel, "UIPanelCloseButton")
helpClose:SetPoint("TOPRIGHT", helpPanel, "TOPRIGHT", 2, 2)
helpClose:SetScript("OnClick", function() helpPanel:Hide() end)

-- Texto de ayuda bilingüe
local helpText = helpPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
helpText:SetPoint("TOPLEFT",     helpPanel, "TOPLEFT",     18, -44)
helpText:SetPoint("BOTTOMRIGHT", helpPanel, "BOTTOMRIGHT", -18,  18)
helpText:SetJustifyH("LEFT")
helpText:SetJustifyV("TOP")
helpText:SetSpacing(4)
helpText:SetText(
    "|cffFFD700[ES] Español|r\n" ..
    "• Si te falta algún dato, recuerda que tus bots\n" ..
    "  deben estar en el grupo (party).\n" ..
    "• Borra los datos y actualiza los registros diciéndole al bot:\n" ..
    "  |cff00ff96\"enséñame tu inventario\"|r\n" ..
    "• Si las estadísticas no aparecen, desconéctate\n" ..
    "  y vuelve a iniciar sesión.\n\n" ..
    "|cffFFD700[EN] English|r\n" ..
    "• If any data is missing, make sure your bots\n" ..
    "  are in your party.\n" ..
    "• Delete all and refresh records by telling the bot:\n" ..
    "  |cff00ff96\"show me your inventory\"|r\n" ..
    "• If stats are not showing, logout and login.\n" ..
    "  "
)

local function ToggleHelp(anchor)
    if helpPanel:IsShown() then
        helpPanel:Hide()
    else
        helpPanel:ClearAllPoints()
        helpPanel:SetPoint("TOPLEFT", anchor, "TOPRIGHT", 6, 0)
        helpPanel:Show()
    end
end

local function MakeHelpButton(parent, anchor)
    local btn = CreateFrame("Button", nil, parent)
    btn:SetSize(22, 22)
    btn:SetPoint("TOPRIGHT", anchor, "TOPLEFT", -2, -5)
    btn:SetFrameLevel(parent:GetFrameLevel() + 5)

    btn:SetBackdrop({
        bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 8, edgeSize = 10,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    btn:SetBackdropColor(0.08, 0.07, 0.03, 1)
    btn:SetBackdropBorderColor(0.5, 0.42, 0.1, 0.8)

    local lbl = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    lbl:SetPoint("CENTER", btn, "CENTER", 0, 0)
    lbl:SetText("|cffFFD700?|r")

    local hl = btn:CreateTexture(nil, "HIGHLIGHT")
    hl:SetAllPoints()
    hl:SetTexture("Interface\\Buttons\\ButtonHilight-Square")
    hl:SetBlendMode("ADD")

    btn:SetScript("OnClick", function() ToggleHelp(parent) end)
    btn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Ayuda / Help")
        GameTooltip:Show()
    end)
    btn:SetScript("OnLeave", function() GameTooltip:Hide() end)
    return btn
end

-- Botón ? en el panel de lista (junto al botón de cerrar)
MakeHelpButton(listPanel, listClose)

-- ============================================================
-- BOTON "BORRAR TODO"
-- ============================================================
StaticPopupDialogs["NBI_CONFIRM_CLEAR"] = {
    text           = "Borrar todos los inventarios de bot?",
    button1        = "Si, borrar",
    button2        = "Cancelar",
    OnAccept       = function() NBI.ClearAll() end,
    timeout        = 0,
    whileDead      = true,
    hideOnEscape   = true,
    preferredIndex = 3,
}

local clearBtn = CreateFrame("Button", nil, listPanel, "UIPanelButtonTemplate")
clearBtn:SetSize(PANEL_W - 20, 24)
clearBtn:SetPoint("BOTTOM", listPanel, "BOTTOM", 0, 10)
clearBtn:SetText("Borrar todo / Delete all")
clearBtn:SetScript("OnClick", function()
    StaticPopup_Show("NBI_CONFIRM_CLEAR")
end)

-- ── Handle de resize (esquina inferior derecha) ─────────────────
local resizeHandle = CreateFrame("Button", nil, listPanel)
resizeHandle:SetSize(16, 16)
resizeHandle:SetPoint("BOTTOMRIGHT", listPanel, "BOTTOMRIGHT", -2, 2)
resizeHandle:SetFrameLevel(listPanel:GetFrameLevel() + 10)

local resizeTex = resizeHandle:CreateTexture(nil, "OVERLAY")
resizeTex:SetAllPoints()
resizeTex:SetTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")

local resizeHL = resizeHandle:CreateTexture(nil, "HIGHLIGHT")
resizeHL:SetAllPoints()
resizeHL:SetTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")

resizeHandle:SetScript("OnMouseDown", function(self, button)
    if button == "LeftButton" then
        listPanel:StartSizing("BOTTOMRIGHT")
    end
end)
resizeHandle:SetScript("OnMouseUp", function(self, button)
    listPanel:StopMovingOrSizing()
    -- Guardar tamaño en SavedVariables
    NBIButtonPos = NBIButtonPos or {}
    NBIButtonPos.panelW = listPanel:GetWidth()
    NBIButtonPos.panelH = listPanel:GetHeight()
end)

resizeHandle:SetScript("OnEnter", function(self)
    resizeTex:SetTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
end)
resizeHandle:SetScript("OnLeave", function(self)
    resizeTex:SetTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
end)

-- ============================================================
-- BOTON DE MINIMAPA
-- ============================================================
local minimapBtn = CreateFrame("Button", "NBI_MinimapButton", Minimap)
minimapBtn:SetSize(28, 28)
minimapBtn:SetFrameStrata("MEDIUM")
minimapBtn:SetFrameLevel(8)

-- Posicion en angulo alrededor del minimapa (en grados)
-- Se guarda en SavedVariables para recordarla entre sesiones
local minimapAngle = 220  -- posicion inicial

local function UpdateMinimapPos()
    local rad = math.rad(minimapAngle)
    local x = math.cos(rad) * 80
    local y = math.sin(rad) * 80
    minimapBtn:SetPoint("CENTER", Minimap, "CENTER", x, y)
end

-- Fondo circular del boton
local minimapBg = minimapBtn:CreateTexture(nil, "BACKGROUND")
minimapBg:SetSize(28, 28)
minimapBg:SetAllPoints()
minimapBg:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")

-- Icono del boton (pergamino)
local minimapIcon = minimapBtn:CreateTexture(nil, "ARTWORK")
minimapIcon:SetSize(18, 18)
minimapIcon:SetPoint("CENTER", minimapBtn, "CENTER", 0, 0)
minimapIcon:SetTexture("Interface\\Icons\\INV_Misc_Note_01")
minimapIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

-- Highlight al pasar el raton
local minimapHL = minimapBtn:CreateTexture(nil, "HIGHLIGHT")
minimapHL:SetSize(28, 28)
minimapHL:SetAllPoints()
minimapHL:SetTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

-- Click izquierdo: abrir/cerrar panel
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

-- Tooltip del boton del minimapa
minimapBtn:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    GameTooltip:AddLine("NPCBot Inventory")
    GameTooltip:AddLine("Click para abrir/cerrar", 0.8, 0.8, 0.8)
    GameTooltip:AddLine("Arrastra para mover", 0.5, 0.5, 0.5)
    GameTooltip:Show()
end)
minimapBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)

-- Arrastrar el boton alrededor del minimapa
minimapBtn:SetMovable(true)
minimapBtn:RegisterForDrag("LeftButton")
minimapBtn:SetScript("OnDragStart", function(self)
    self:SetScript("OnUpdate", function(self)
        local mx, my = Minimap:GetCenter()
        local px, py = GetCursorPosition()
        local scale  = UIParent:GetEffectiveScale()
        px = px / scale
        py = py / scale
        minimapAngle = math.deg(math.atan2(py - my, px - mx))
        UpdateMinimapPos()
        -- Guardar angulo
        NBIButtonPos = NBIButtonPos or {}
        NBIButtonPos.minimapAngle = minimapAngle
    end)
end)
minimapBtn:SetScript("OnDragStop", function(self)
    self:SetScript("OnUpdate", nil)
end)

UpdateMinimapPos()

-- ============================================================
-- BOTON FLOTANTE
-- ============================================================
local toggleBtn = CreateFrame("Button", "NBI_ToggleButton", UIParent, "UIPanelButtonTemplate")
toggleBtn:SetSize(130, 28)
toggleBtn:SetText("Bot Inventory")
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
        toggleBtn:SetPoint(NBIButtonPos.point or "TOPRIGHT", UIParent, NBIButtonPos.relPoint or "TOPRIGHT", NBIButtonPos.x or -220, NBIButtonPos.y or -100)
        if NBIButtonPos.minimapAngle then
            minimapAngle = NBIButtonPos.minimapAngle
            UpdateMinimapPos()
        end
        -- Restaurar tamaño del panel si fue guardado
        if NBIButtonPos.panelW and NBIButtonPos.panelH then
            listPanel:SetSize(NBIButtonPos.panelW, NBIButtonPos.panelH)
        end
    else
        toggleBtn:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -220, -100)
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

function NBI.OnDataCleared()
    RefreshBotList()
end

-- ============================================================
-- SLASH COMMANDS
-- ============================================================
SLASH_NBOTINV1 = "/botinv"
SLASH_NBOTINV2 = "/npcbotinv"
SlashCmdList["NBOTINV"] = function(msg)
    msg = msg:trim()
    if msg == "" then
        if listPanel:IsShown() then
            listPanel:Hide()
        else
            listPanel:ClearAllPoints()
            listPanel:SetPoint("TOP", toggleBtn, "BOTTOM", 0, -4)
            RefreshBotList()
            listPanel:Show()
        end
    else
        if NBI.botInventories[msg] and NPCBotInventory.OpenInspect then
            NPCBotInventory.OpenInspect(msg)
        else
            print("|cffFFD700[NPCBotInventory]|r Bot '" .. msg .. "' no encontrado.")
        end
    end
end

print("|cffFFD700[NPCBotInventory]|r Cargado. Usa /botinv para abrir.")
