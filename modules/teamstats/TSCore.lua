----------------------------------------------------------
-- Credits: L
----------------------------------------------------------
local KUI, T, E, L, V, P, G = unpack(select(2, ...))

WW = {}
local lib_meta = {}
local wrapper_meta = {}

_G.WidgetWrapper = WW

local SupportedTypes = {"Frame", "Button", "CheckButton", "ColorSelect", "Cooldown", "GameTooltip", "ScrollFrame", "SimpleHTML", "Slider", "StatusBar", "EditBox", "MessageFrame", "ScrollingMessageFrame", "Model", "PlayerModel", "DressUpModel", "TabardModel", "Minimap", "ArchaeologyDigSiteFrame", "MovieFrame", "QuestPOIFrame", }
for i = 1, #SupportedTypes do SupportedTypes[SupportedTypes[i]] = true end


local CALLING_ARGS = {}
local CALLING_ARGS_LEN = 0

local function transferArgs(...)
    table.wipe(CALLING_ARGS)
    CALLING_ARGS_LEN = select("#", ...)
    for i = 1, CALLING_ARGS_LEN do
        local argi = select(i, ...)
        if argi and getmetatable(argi) == wrapper_meta then
            CALLING_ARGS[i] = argi._F
        else
            CALLING_ARGS[i] = argi
        end
    end
end

lib_meta.__index = function(lib, key)
    local func
    
    if SupportedTypes[key] then
        func = function(self, ...)
            transferArgs(...)
            local frame = CreateFrame(key, unpack(CALLING_ARGS, 1, CALLING_ARGS_LEN))
            return self:Wrap(frame)
        end
        lib[key] = func
        return func
    elseif key == "Font" then
        func = function(self, ...)
            local font = CreateFont(...)
            return self:Wrap(font)
        end
        lib[key] = func
        return func
    end
end

local MAX_REUSE = 10
local REUSE_WRAPPERS = {}

function WW:Wrap(frame, keep)
    if getmetatable(frame) == wrapper_meta then return frame end
    if frame.__wrapper then return frame.__wrapper end
    local wrapper = table.remove(REUSE_WRAPPERS) or {}
    rawset(wrapper, "_F", frame)
    if keep then frame.__wrapper = wrapper end
    setmetatable(wrapper, wrapper_meta)
    return wrapper
end

function WW:un(frame)
    if getmetatable(frame) == wrapper_meta then return frame() end
    return frame
end

lib_meta.__call = WW.Wrap
setmetatable(WW, lib_meta)

wrapper_meta.__div = function(op1, op2)
    return op1._F
end

local GETTER_PATTERNS = {"^Has[A-Z]", "^Is[A-Z]", "^Can[A-Z]", "^Create[A-Z]", "^Get[A-Z]"}
local function IsGetterMethod(methodName)
    for i = 1, #GETTER_PATTERNS do
        if methodName:find(GETTER_PATTERNS[i]) then
            return true
        end
    end
end

wrapper_meta.__index = function(wrapper, key)
    assert(key ~= "_F", "this wrapper is clear and reused.")
    local func
    
    func = wrapper_meta[key]
    if func then return func end
    
    if SupportedTypes[key] then
        func = function(self, name, template, parentKey)
            local frame = CreateFrame(key, name, self._F, template)
            local wrapped = WW:Wrap(frame)
            self._F.__wrapper = self
            if parentKey then
                self._F[parentKey] = frame
            end
            return wrapped
        end
        wrapper_meta[key] = func
        return func
    end
    
    if key == "CreateAnimation" or key == "CreateAnimationGroup" or key == "CreateFontString" or key == "CreateTexture" or key == "CreateControlPoint" then
        func = function(self, ...)
            local obj = self._F[key](self._F, ...)
            return WW:Wrap(obj)
        end
        wrapper_meta[key] = func
        return func
    end
    
    if type(wrapper._F[key]) == "function" then
        if not IsGetterMethod(key) then
            func = function(self, ...)
                assert(self._F[key], "attempt to call method '" .. key .. "' (a nil value)")
                transferArgs(...)
                local _1, _2, _3, _4, _5 = self._F[key](self._F, unpack(CALLING_ARGS, 1, CALLING_ARGS_LEN))
                return self
            end
            wrapper_meta[key] = func
            return func
        else
            func = function(self, ...)
                assert(self._F[key], "attempt to call method '" .. key .. "' (a nil value)")
                return self._F[key](self._F, ...)
            end
            wrapper_meta[key] = func
            return func
        end
    end
    
    return wrapper._F[key]
end

wrapper_meta.__newindex = function(wrapper, key, value)
    if getmetatable(value) == wrapper_meta then
        wrapper._F[key] = value:un()
    else
        wrapper._F[key] = value
    end
end

wrapper_meta.__call = function(self, func, ...)
    if (func) then
        return self._F[func](self._F, ...)
    else
        return self._F
    end
end

function wrapper_meta:un()
    local f = self._F
    f.__wrapper = nil
    self._F = nil
    if (#REUSE_WRAPPERS < MAX_REUSE) then
        table.insert(REUSE_WRAPPERS, self)
    end
    return f
end

function wrapper_meta:Returned()
    assert(false, "This function is deprecated due to memory consideration.")
    return rawget(self, "_1"), rawget(self, "_2"), rawget(self, "_3"), rawget(self, "_4"), rawget(self, "_5")
end

function wrapper_meta:up()
    local _F = rawget(self, "_F")
    local parent = _F:GetParent()
    self:un()
    local wrapped = WW:Wrap(parent)
    return wrapped
end

function wrapper_meta:SetSize(width, height)
    self._F:SetWidth(width)
    self._F:SetHeight(height or width)
    return self
end
wrapper_meta.Size = wrapper_meta.SetSize

function wrapper_meta:GetSize()
    return self:GetWidth(), self:GetHeight()
end

function wrapper_meta:On(script, ...)
    self._F:GetScript("On" .. script)(self._F, ...)
    return self
end
function wrapper_meta:Load(script)
    return self:On("Load")
end

function wrapper_meta:SetParentKey(key)
    local parent = self._F:GetParent()
    if parent then
        parent[key] = self._F
    end
    return self
end
wrapper_meta.Key = wrapper_meta.SetParentKey

local abbr_points = {
    ["TL"] = "TOPLEFT",
    ["BL"] = "BOTTOMLEFT",
    ["TR"] = "TOPRIGHT",
    ["BR"] = "BOTTOMRIGHT",
    ["T"] = "TOP",
    ["B"] = "BOTTOM",
    ["L"] = "LEFT",
    ["R"] = "RIGHT",
}

function wrapper_meta:Point(point, relativeTo, relativePoint, x, y)
    if type(relativeTo) == "string" then
        if relativeTo == "$parent" then
            relativeTo = self._F:GetParent()
        else
            if relativeTo:find("%$parent") then
                local parentName = ""
                local parent = self._F:GetParent()
                while parent and not parent:GetName() do parent = parent:GetParent() end
                if parent and parent:GetName() then parentName = parent:GetName() end
                relativeTo = relativeTo:gsub("%$parent", parentName)
            end
            relativeTo = _G[relativeTo]
        end
    end
    
    if type(relativeTo) == "table" and type(relativePoint) == "number" then
        y = x
        x = relativePoint
        relativePoint = point
    end
    
    point = abbr_points[point] or point
    if (relativeTo == nil) then
        return self:SetPoint(point)
    else
        relativePoint = abbr_points[relativePoint] or relativePoint
        return self:SetPoint(point, relativeTo, relativePoint, x, y)
    end
end

function wrapper_meta:LEFT(...) return self:Point("LEFT", ...) end
function wrapper_meta:RIGHT(...) return self:Point("RIGHT", ...) end
function wrapper_meta:CENTER(...) return self:Point("CENTER", ...) end
function wrapper_meta:TOP(...) return self:SetPoint("TOP", ...) end
function wrapper_meta:BOTTOM(...) return self:Point("BOTTOM", ...) end
function wrapper_meta:TOPLEFT(...) return self:Point("TOPLEFT", ...) end
function wrapper_meta:TOPRIGHT(...) return self:Point("TOPRIGHT", ...) end
function wrapper_meta:BOTTOMLEFT(...) return self:Point("BOTTOMLEFT", ...) end
function wrapper_meta:BOTTOMRIGHT(...) return self:Point("BOTTOMRIGHT", ...) end
wrapper_meta.TL = wrapper_meta.TOPLEFT
wrapper_meta.TR = wrapper_meta.TOPRIGHT
wrapper_meta.BL = wrapper_meta.BOTTOMLEFT
wrapper_meta.BR = wrapper_meta.BOTTOMRIGHT
function wrapper_meta:ALL(...) return self:SetAllPoints(...) end
function wrapper_meta:CLEAR(...) return self:ClearAllPoints(...) end

function wrapper_meta:SetButtonFont(font)
    if font then
        self._F:SetNormalFontObject(WW:un(font))
    end
    if not self._F:GetFontString() then
        self._F:SetText(" ")
    end
    return self
end

function wrapper_meta:GetButtonText()
    return WW(self._F:GetFontString())
end

function wrapper_meta:SetFontHeightAndFlags(height, flags)
    local f = self._F
    if f:GetObjectType() ~= "Font" and f:GetObjectType() ~= "FontString" then
        f = f:GetFontObject()
        assert(f and f:GetObjectType() == "Font", "Need a font object.")
    end
    local name, oldheight, oldflags = f:GetFont()
    f:SetFont(name, height or oldheight, flags or oldflags)
    return self
end

function wrapper_meta:SetFontHeight(height)
    return self:SetFontHeightAndFlags(height, nil)
end

function wrapper_meta:SetFile(str_texture, ...)
    self:SetTexture(str_texture)
    if ... then self:SetTexCoord(...) end
    return self
end

function wrapper_meta:Texture(name, layer, str_texture, ...)
    return self:CreateTexture(name, layer):SetFile(str_texture, ...)
end

local cacheToTexture = setmetatable({}, {__index = function(self, type)self[type] = "Set" .. type .. "Texture" return self[type] end})
function wrapper_meta:ToTexture(type, ...)
    local parent = self._F:GetParent()
    parent[cacheToTexture[type]](parent, self._F, ...)
    return self
end

function UICoreFrameFlashStop(frame)
    tDeleteItem(FLASHFRAMES, frame)
    frame:SetAlpha(1.0)
    frame.flashTimer = nil
    if (frame.syncId) then
        UIFrameFlashTimerRefCount[frame.syncId] = UIFrameFlashTimerRefCount[frame.syncId] - 1
        if (UIFrameFlashTimerRefCount[frame.syncId] == 0) then
            UIFrameFlashTimers[frame.syncId] = nil
            UIFrameFlashTimerRefCount[frame.syncId] = nil
        end
        frame.syncId = nil
    end
    if (frame.showWhenDone) then
        frame:Show()
    else
        frame:Hide()
    end
end

function TplColumnButton(parent, name, height, width)
    width = width or 50
    local btn = WW:Button(name, parent):SetSize(width, height):EnableMouse(true):SetButtonFont("GameFontNormalSmall")
    
    btn:GetButtonText():LEFT(3, 0):RIGHT(-3, 0):SetJustifyH("CENTER"):SetWordWrap(false):up()
    :Texture(nil, "ARTWORK", "Interface\\FriendsFrame\\WhoFrame-ColumnTabs", 0, 0.078125, 0, 0.75):Key("L"):SetSize(5, height):TL():up()
    :Texture(nil, "BACKGROUND", "Interface\\FriendsFrame\\WhoFrame-ColumnTabs", 0.90625, 0.96875, 0, 0.75):Key("R"):SetSize(4, height):TR():up()
    :Texture(nil, "BACKGROUND", "Interface\\FriendsFrame\\WhoFrame-ColumnTabs", 0.078125, 0.90625, 0, 0.75):Key("M"):TL(btn.L, "TR"):BR(btn.R, "BL"):up()
    :Texture(nil, nil, "Interface\\PaperDollInfoFrame\\UI-Character-Tab-Highlight"):ToTexture("Highlight", "ADD"):TL(btn.L, -2, 7):BR(btn.R, 2, -7):up()
    
    return btn
end


function CoreUICreateHybridButtons(self, initialOffsetX, initialOffsetY, initialPoint, initialRelative, offsetX, offsetY, point, relativePoint)
    self.args = self.args or {}
    self.args[1], self.args[2], self.args[3], self.args[4], self.args[5], self.args[6], self.args[7], self.args[8] = initialOffsetX, initialOffsetY, initialPoint, initialRelative, offsetX, offsetY, point, relativePoint
    self.buttonCache = self.buttonCache or {}
    local scrollChild = self.scrollChild
    local button, buttonHeight, buttons, numButtons
    
    initialPoint = initialPoint or "TOPLEFT"
    initialRelative = initialRelative or "TOPLEFT"
    point = point or "TOPLEFT"
    relativePoint = relativePoint or "BOTTOMLEFT"
    offsetX = offsetX or 0
    offsetY = offsetY or 0
    
    if (self.buttons) then
        buttons = self.buttons
        buttonHeight = buttons[1]:GetHeight()
    else
        button = self:creator(1, nil)
        buttonHeight = button:GetHeight()
        button:SetPoint(initialPoint, scrollChild, initialRelative, initialOffsetX, initialOffsetY)
        buttons = {}
        tinsert(buttons, button)
        tinsert(self.buttonCache, button)
    end
    
    self.buttonHeight = math.floor(buttonHeight + .5) - offsetY
    
    local numButtons = math.ceil(self:GetHeight() / buttonHeight) + 1
    
    for i = #buttons + 1, numButtons do
        button = self.buttonCache[i]
        if not button then
            button = self:creator(i, nil)
            tinsert(self.buttonCache, button)
        end
        button:SetPoint(point, buttons[i - 1], relativePoint, offsetX, offsetY)
        tinsert(buttons, button)
    end
    
    scrollChild:SetWidth(self:GetWidth())
    scrollChild:SetHeight(numButtons * buttonHeight)
    self:SetVerticalScroll(0)
    self:UpdateScrollChildRect()
    
    self.buttons = buttons
    local scrollBar = self.scrollBar
    if (scrollBar) then
        scrollBar:SetMinMaxValues(0, numButtons * buttonHeight)
        scrollBar:SetValueStep(.005)
        scrollBar:SetValue(0)
    end
    
    self.stepSizePage = math.floor(self:GetHeight() / self.buttonHeight) * self.buttonHeight
    self.stepSizeLine = self.buttonHeight
    self.stepSize = math.ceil(self:GetHeight() / self.buttonHeight / 2) * self.buttonHeight
end

CoreUICreateHybridUpdateScroll = function(scrollFrame)
    local offset = HybridScrollFrame_GetOffset(scrollFrame)
    local buttons = scrollFrame.buttons
    local numButtons = #buttons
    local numData = scrollFrame:getNumFunc()
    local button, index, class
    for i = 1, numButtons do
        local button, index = buttons[i], offset + i
        if (index > numData) then
            button:Hide()
        else
            scrollFrame:updateFunc(button, index)
            button:Show()
        end
    end
    
    local totalHeight = numData * scrollFrame.buttonHeight
    local displayedHeight = numButtons * scrollFrame.buttonHeight
    if (scrollFrame.noScrollBar and scrollFrame.scrollBar) then scrollFrame.scrollBar.doNotHide = true end
    HybridScrollFrame_Update(scrollFrame, totalHeight, displayedHeight)
    if scrollFrame.scrollBar and floor(totalHeight - scrollFrame:GetHeight() + 0.5) <= 0 then scrollFrame.scrollBar:SetMinMaxValues(0, 1) end
    if (scrollFrame.noScrollBar and scrollFrame.scrollBar) then scrollFrame.scrollBar:Hide() end
end

function CoreUICreateHybridStep1(name, parent, barWidth, outBar, useBlizzardBar, stepType)
    local scroll = CreateFrame("ScrollFrame", name, parent, "HybridScrollFrameTemplate")
    scroll.stepType = stepType
    scroll:SetScript("OnMouseWheel", CoreUICreateHybrid_OnMouseWheel)
    
    local barWidth = barWidth or 6
    if not useBlizzardBar then
        local bar = CoreUICreateModernScrollBar(scroll, outBar and barWidth + 1 or -1, 1, false, barWidth, 32, 1)
        bar:SetScript("OnValueChanged", CoreUICreateHybrid_OnValueChanged)
        bar:SetFrameLevel(bar:GetFrameLevel() + 1)
        scroll.scrollUp = CoreUICreateHybrid_DummyButton
        scroll.scrollDown = CoreUICreateHybrid_DummyButton
        bar:SetFrameLevel(bar:GetFrameLevel() + 1)
    else
        local bar = CreateFrame("Slider", (name or tostring(scroll)) .. "ScrollBar", scroll, "MinimalHybridScrollBarTemplate")
        bar:SetPoint("TOPLEFT", scroll, "TOPRIGHT", 0, -16)
        bar:SetPoint("BOTTOMLEFT", scroll, "BOTTOMRIGHT", 0, 16)
        _G[bar:GetName() .. "Track"]:SetAlpha(0.3)
        scroll.scrollBar = bar
        bar:SetFrameLevel(bar:GetFrameLevel() + 1)
    end
    
    return scroll
end

local frameFlashManager = CreateFrame("FRAME")

local UIFrameFlashTimers = {}
local UIFrameFlashTimerRefCount = {}

function UICoreFrameFlash(frame, fadeInTime, fadeOutTime, flashDuration, showWhenDone, flashInHoldTime, flashOutHoldTime, syncId)
    if (frame) then
        local index = 1
        while FLASHFRAMES[index] do
            if (FLASHFRAMES[index] == frame) then
                return
            end
            index = index + 1
        end
        
        if (syncId) then
            frame.syncId = syncId
            if (UIFrameFlashTimers[syncId] == nil) then
                UIFrameFlashTimers[syncId] = 0
                UIFrameFlashTimerRefCount[syncId] = 0
            end
            UIFrameFlashTimerRefCount[syncId] = UIFrameFlashTimerRefCount[syncId] + 1
        else
            frame.syncId = nil
        end
        
        frame.fadeInTime = fadeInTime
        frame.fadeOutTime = fadeOutTime
        frame.flashDuration = flashDuration
        frame.showWhenDone = showWhenDone
        frame.flashTimer = 0
        frame.flashInHoldTime = flashInHoldTime
        frame.flashOutHoldTime = flashOutHoldTime
        tinsert(FLASHFRAMES, frame)
        frameFlashManager:SetScript("OnUpdate", UICoreFrameFlash_OnUpdate)
    end
end

function CoreUICreateHybridStep2(scroll, initialOffsetX, initialOffsetY, initialPoint, initialRelative, buttonOffset)
    assert(scroll.creator, "HybridScrollFrameError: no creator provided.")
    assert(scroll.getNumFunc, "HybridScrollFrameError: getNumFunc attribute not set.")
    assert(scroll.updateFunc, "HybridScrollFrameError: getNumFunc attribute not set.")
    
    CoreUICreateHybridButtons(scroll, initialOffsetX, initialOffsetY, initialPoint, initialRelative, 0, -buttonOffset, "TOP", "BOTTOM")
    scroll.update = function()CoreUICreateHybridUpdateScroll(scroll) end
    scroll.update()
end

TEXT = TEXT or function(text)
    return text
end

local localeMetaTable = {__newindex = function(t, k, v)rawset(t, k, v == true and k or v) end}
function NewLocale()
    local loc = GetLocale()
    return setmetatable({[loc] = true}, localeMetaTable)
end

function U1Message(text, r, g, b, chatFrame)
(chatFrame or DEFAULT_CHAT_FRAME):AddMessage(text, r, g, b)
end

function CoreUIShowOrHide(self, show)
    if self then
        if show then self:Show() else self:Hide() end
    end
end

local CreateResizeButton_OnMouseDown, CreateResizeButton_OnMouseUp
function CoreUICreateResizeButton(frame, point, resizePoint, offsetX, offsetY, size)
    local btn = CreateFrame("Button", nil, frame)
    local size = size or 16
    btn:SetWidth(size)
    btn:SetHeight(size)
    btn:SetPoint(point, frame, offsetX or 0, offsetY or 0)
    btn:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    btn:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
    btn:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
    local ULx, ULy, LLx, LLy, URx, URy, LRx, LRy = 0, 0, 0, 1, 1, 0, 1, 1
    if (point:find("LEFT")) then ULx = 1 LLx = 1 URx = 0 LRx = 0 end
    if (point:find("TOP")) then ULy = 1 LLy = 0 URy = 1 LRy = 0 end
    btn:GetNormalTexture():SetTexCoord(ULx, ULy, LLx, LLy, URx, URy, LRx, LRy)
    btn:GetHighlightTexture():SetTexCoord(ULx, ULy, LLx, LLy, URx, URy, LRx, LRy)
    btn:GetPushedTexture():SetTexCoord(ULx, ULy, LLx, LLy, URx, URy, LRx, LRy)
    btn.resizePoint = resizePoint or point
    
    CreateResizeButton_OnMouseDown = CreateResizeButton_OnMouseDown or function(self)
        self:SetButtonState("PUSHED", true)
        SetCursor("Interface\\CURSOR\\openhandglow")
        self:GetHighlightTexture():Hide()
        self:GetParent():StartSizing(self.resizePoint)
    end
    CreateResizeButton_OnMouseUp = CreateResizeButton_OnMouseUp or function(self)
        self:SetButtonState("NORMAL", false)
        SetCursor(nil)
        self:GetHighlightTexture():Show()
        self:GetParent():StopMovingOrSizing()
    end
    btn:SetScript("OnMouseDown", CreateResizeButton_OnMouseDown)
    btn:SetScript("OnMouseUp", CreateResizeButton_OnMouseUp)
    return btn
end

local EnableTooltip_OnLeave
function CoreUIEnableTooltip(frame, title, content, update)
    frame:EnableMouse(true)
    frame.tooltipTitle = title
    frame.tooltipText = content
    if (type(content) == "function") then frame.tooltipText = " " frame._tooltipText = content end
    frame:HookScript("OnEnter", CoreUIShowTooltip)
    if update then frame.UpdateTooltip = CoreUIShowTooltip end
    
    EnableTooltip_OnLeave = EnableTooltip_OnLeave or function(self)GameTooltip:Hide() end
    frame:HookScript("OnLeave", EnableTooltip_OnLeave)
end


function CoreUIShowTooltip(self, anchor)
    if (self.tooltipTitle or self.tooltipText or self.tooltipLines) then
        GameTooltip:SetOwner(self, anchor or self.tooltipAnchorPoint)
        GameTooltip:ClearLines()
        if (self.tooltipLines) then
            if (type(self.tooltipLines) == "string") then
                self.tooltipLines = {strsplit("`", self.tooltipLines)}
            end
            if (type(self.tooltipLines) == "table" and #self.tooltipLines > 0) then
                GameTooltip:AddLine(self.tooltipLines[1], 1, 1, 1)
                for i = 2, #self.tooltipLines do
                    GameTooltip:AddLine(self.tooltipLines[i], nil, nil, nil, true)
                end
            end
        else
            if (self.tooltipTitle) then GameTooltip:AddLine(self.tooltipTitle, 1, 1, 1) end
        end
        
        if (type(self._tooltipText) == "function") then
            self._tooltipText(self, GameTooltip)
        else
            GameTooltip:AddLine(self.tooltipText, nil, nil, nil, true)
        end
        
        GameTooltip:Show()
    end
end

function CoreUISetTextWithClassColor(buttonString, text, class)
    buttonString:SetText(text)
    if (class) then
        local classColor = RAID_CLASS_COLORS[class]
        buttonString:SetTextColor(classColor.r, classColor.g, classColor.b)
    else
        buttonString:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
    end
end

local CoreUIMakeMovable_OnMouseDown, CoreUIMakeMovable_OnMouseUp
function CoreUIMakeMovable(f, target)
    if (target) then
        f._moveTarget = target
        target:SetMovable(true)
        target:SetClampedToScreen(true)
    else
        f:SetMovable(true)
        f:SetClampedToScreen(true)
    end
    CoreUIMakeMovable_OnMouseDown = CoreUIMakeMovable_OnMouseDown or function(self)
        local frame = self._moveTarget or self
        if (frame:IsMovable()) then frame:StartMoving() end
    end
    CoreUIMakeMovable_OnMouseUp = CoreUIMakeMovable_OnMouseUp or function(self)
        local frame = self._moveTarget or self
        frame:StopMovingOrSizing()
    end
    f:EnableMouse(true)
    f:SetScript("OnMouseDown", CoreUIMakeMovable_OnMouseDown)
    f:SetScript("OnMouseUp", CoreUIMakeMovable_OnMouseUp)
end


function CoreUIRegisterSlash(name, slash1, slash2, func)
    SlashCmdList[name] = func
    _G["SLASH_" .. name .. "1"] = slash1
    if slash2 then _G["SLASH_" .. name .. "2"] = slash2 end
end

function CoreUIAnchor(container, initPoint, initRelative, initX, initY, subPoint, subRelative, subX, subY, ...)
    local first = ...
    first:ClearAllPoints()
    first:SetPoint(initPoint, WW:un(container), initRelative, initX, initY)
    for i = 2, select("#", ...) do
        local obj = select(i, ...)
        obj:ClearAllPoints()
        obj:SetPoint(subPoint, WW:un(first), subRelative, subX, subY)
        first = obj
    end
end

function CoreUIKeepCorner(frame, point)
    local left, top, width, height = frame:GetLeft(), frame:GetTop(), frame:GetWidth(), frame:GetHeight()
    if left == nil or top == nil then return end
    if point:find("RIGHT") then
        left = left + width
    end
    if point:find("BOTTOM") then
        top = top + height
    end
    frame:ClearAllPoints()
    frame:SetPoint(point, UIParent, "BOTTOMLEFT", left, top)
end


local slotWeight = {
    ["INVTYPE_RELIC"] = 0.3164,
    ["INVTYPE_TRINKET"] = 0.5625,
    ["INVTYPE_2HWEAPON"] = 2.000,
    ["INVTYPE_WEAPONMAINHAND"] = 1.0000,
    ["INVTYPE_WEAPONOFFHAND"] = 1.0000,
    ["INVTYPE_RANGED"] = 2,
    ["INVTYPE_THROWN"] = 0,
    ["INVTYPE_RANGEDRIGHT"] = 2,
    ["INVTYPE_SHIELD"] = 1.0000,
    ["INVTYPE_WEAPON"] = 1.0000,
    ["INVTYPE_HOLDABLE"] = 1.0000,
    ["INVTYPE_HEAD"] = 1.0000,
    ["INVTYPE_NECK"] = 0.5625,
    ["INVTYPE_SHOULDER"] = 0.7500,
    ["INVTYPE_CHEST"] = 1.0000,
    ["INVTYPE_ROBE"] = 1.0000,
    ["INVTYPE_WAIST"] = 0.7500,
    ["INVTYPE_LEGS"] = 1.0000,
    ["INVTYPE_FEET"] = 0.75,
    ["INVTYPE_WRIST"] = 0.5625,
    ["INVTYPE_HAND"] = 0.7500,
    ["INVTYPE_FINGER"] = 0.5625,
    ["INVTYPE_CLOAK"] = 0.5625,
}

local TYPE_WAND = "Wand"
local TYPE_WANDS = "Wands"
if (GetLocale() == "zhCN" or GetLocale() == "zhTW") then TYPE_WAND = "魔杖" TYPE_WANDS = "魔杖" end
local ItemUpgradeInfo = LibStub("LibItemUpgradeInfo-1.0")

local tip = CreateFrame("GameTooltip", "GameTooltipForItemLevel", nil, "ShoppingTooltipTemplate")
for i = 1, 4 do
    tip:AddFontStrings(
        tip:CreateFontString("$parentTextLeft" .. i, nil, "GameTooltipText"),
        tip:CreateFontString("$parentTextRight" .. i, nil, "GameTooltipText")
)
end

local pattern = ITEM_LEVEL:gsub("%%d", "(%%d+)")
local extractLink = "\124H(item:.-)\124h.-\124h"
local cache = {}
function U1GetItemLevelByScanTooltip(itemLink, slot)
    local name, _, quality, ilevel, extract
    if not slot then
        name, _, quality, ilevel = GetItemInfo(itemLink)
        _, _, extract = itemLink:find(extractLink)
        if not extract then return nil end
        if cache[extract] then return cache[extract] end
    else
        itemLink = GetInventoryItemLink(itemLink, slot)
    end
    if not itemLink then return end
    
    tip:SetOwner(WorldFrame, "ANCHOR_NONE")
    for i = 1, 4 do
        if _G[tip:GetName() .. "Texture" .. i] then
            _G[tip:GetName() .. "Texture" .. i]:SetTexture("")
        end
    end
    if slot then
        tip:SetInventoryItem(itemLink, slot)
    else
        tip:SetHyperlink(itemLink)
    end
    tip:Show()
    for i = 2, 4 do
        local text = _G[tip:GetName() .. "TextLeft" .. i]:GetText()
        if text then
            local _, _, v = text:find(pattern)
            if v then
                v = tonumber(v)
                if quality ~= 6 and extract then cache[extract] = v end
                return v
            end
        end
    end
    return ItemUpgradeInfo:GetUpgradedItemLevel(itemLink) or ilevel
end

function U1GetRealItemLevel(link, unit, slot)
    if unit and (slot == 16 or slot == 17) then
        local _, _, quality = GetItemInfo(link)
        if quality == 6 then
            local main_hand = U1GetItemLevelByScanTooltip(unit, 16) or 0
            local off_hand = U1GetItemLevelByScanTooltip(unit, 17) or 0
            return max(main_hand, off_hand)
        end
    end
    return U1GetItemLevelByScanTooltip(link)
end

local function GetRealInventoryType(link)
    local _, _, quality, _, _, _, typeName, _, invType = GetItemInfo(link)
    if invType == "INVTYPE_RANGEDRIGHT" and (typeName == TYPE_WAND or typeName == TYPE_WANDS) then
        invType = "INVTYPE_WEAPON"
    end
    return invType
end

local function GetItemScore(link, blizzard, unit, slot)
    if not (link) then return end
    local ilevel = U1GetRealItemLevel(link, unit, slot)
    local invType = GetRealInventoryType(link)
    return ilevel, invType, blizzard and 1 or slotWeight[invType]
end

function U1GetInventoryLevelColor(avgLevel, quality)
    local STEP1, STEP2, STEP3, STEP4, STEP5 = 190, 296, 325, 355, 405
    if not avgLevel or avgLevel <= 0 then return .5, .5, .5 end
    if avgLevel < STEP1 then
        return 1, 1, 1
    elseif avgLevel <= STEP2 then
        return GetItemQualityColor(2)
    elseif avgLevel <= STEP3 then
        return GetItemQualityColor(3)
    elseif avgLevel <= STEP4 then
        return (avgLevel - STEP3) / (STEP4 - STEP3), 0.5, 1
    elseif avgLevel < STEP5 or (quality and quality ~= 5) then
        return 1, 0, 1 - (avgLevel - STEP4) / (STEP5 - STEP4)
    else
        return 1, 0.5, 0
    end
end

local itemLinks = {}
local ItemStats = {}

function U1GetInventoryLevel(unit, blizzard)
    if not UnitIsPlayer(unit) then return end
    
    if (blizzard == nil) then blizzard = select(4, GetBuildInfo()) > 40200 end
    
    table.wipe(itemLinks)
    for i = 1, 17 do
        if i ~= 4 and GetInventoryItemTexture(unit, i) then
            itemLinks[i] = GetInventoryItemLink(unit, i)
            if not itemLinks[i] then return end
        end
    end
    
    local _, class = UnitClass(unit)
    
    local invType16, quality16, iLevel16, _
    if itemLinks[16] then _, _, quality16, _, _, _, _, _, invType16 = GetItemInfo(itemLinks[16]) end
    
    local warriorTitan = not blizzard and (class == "WARRIOR") and itemLinks[16] and itemLinks[17] and (invType16 == "INVTYPE_2HWEAPON")
    
    local count, totalScore, totalLevel, totalMod, totalPVP = 0, 0, 0, 0, 0
    for i = 1, 17 do
        local link = itemLinks[i]
        if (link) then
            local ilevel, invType, mod = GetItemScore(link, blizzard, unit, i)
            if i == 16 then iLevel16 = ilevel end
            if mod and ilevel then
                if not blizzard then
                    if warriorTitan and (i == 16 or i == 17) then
                        mod = mod * 0.5
                    end
                    totalScore = totalScore + ilevel * mod
                    totalMod = totalMod + mod
                end
                count = count + 1
                totalLevel = totalLevel + ilevel
            end
        end
    end
    
    local avgLevel, avgLevelEquiped
    local slotCount = 16
    if blizzard then
        if iLevel16 and not itemLinks[17] and (invType16 == "INVTYPE_2HWEAPON" or invType16 == "INVTYPE_RANGEDRIGHT" or invType16 == "INVTYPE_RANGED" or quality16 == 6) then
            totalLevel = totalLevel + iLevel16
            count = count + 1
        end
        avgLevel = totalLevel / slotCount
    else
        avgLevel = totalMod > 0 and totalScore / totalMod or 0
    end
    
    local r, g, b = U1GetInventoryLevelColor(avgLevel)
    local color = string.format("%02x%02x%02x", r * 255, g * 255, b * 255)
    
    local precise = avgLevel
    avgLevel = avgLevel > 0 and tonumber(string.format("%.1f", avgLevel)) or 0
    
    return avgLevel, color, totalPVP, totalLevel, count, slotCount, itemLinks, string.format("%0.3f", precise)
end

do
    local enchantables = {
        Finger0Slot = "戒",
        Finger1Slot = "戒",
        MainHandSlot = "武",
    }
    
    function U1GetUnitEnchantInfo(unit, waist_extra_slot)
        local total, hasenchant = 0, 0
        local missing = ""
        
        for slot, shortname in next, enchantables do
            local link = GetInventoryItemLink(unit, GetInventorySlotInfo(slot))
            if (link) then
                local enchantid = link:match "item:%d+:(%d+):"
                enchantid = enchantid and tonumber(enchantid)
                
                total = total + 1
                
                if (enchantid and enchantid > 0) then
                    hasenchant = hasenchant + 1
                else
                    if (slot == "WaistSlot" and waist_extra_slot) then
                        hasenchant = hasenchant + 1
                    elseif #missing < 12 then
                        missing = missing .. shortname
                    end
                end
            end
        end
        
        return total, hasenchant, missing
    end
end


local slots = {"Head", "Neck", "Shoulder", "Shirt", "Chest", "Waist", "Legs", "Feet", "Wrist", "Hands", "Finger0", "Finger1", "Trinket0", "Trinket1", "Back", "MainHand", "SecondaryHand", }

do
    local fmt = string.format
    local gem_slots = {
        EMPTY_SOCKET = true,
        EMPTY_SOCKET_BLUE = true,
        EMPTY_SOCKET_COGWHEEL = true,
        EMPTY_SOCKET_HYDRAULIC = true,
        EMPTY_SOCKET_META = true,
        EMPTY_SOCKET_NO_COLOR = true,
        EMPTY_SOCKET_PRISMATIC = true,
        EMPTY_SOCKET_RED = true,
        EMPTY_SOCKET_YELLOW = true,
        EMPTY_SOCKET_PUNCHCARDYELLOW = false,
        EMPTY_SOCKET_PUNCHCARDRED = false,
        EMPTY_SOCKET_PUNCHCARDBLUE = false,
    }
    
    local _item_stat_tbl = {}
    local get_item_stats = function(item)
        wipe(_item_stat_tbl)
        return GetItemStats(item, _item_stat_tbl)
    end
    
    function U1GetUnitGemInfo(unit)
        local gem_s = 0
        local slot_s = 0
        local top_s, sec_s, oth_s = 0, 0, 0
        local waist_extra_slot = false

        for id, slot in next, slots do
            local link = GetInventoryItemLink(unit, id)
            if(link) then
                local i_slot, i_gem = 0, 0

                local stats = get_item_stats(link)
                if stats==nil then return UNKNOWN end
                for k, v in next, stats do
                    if(gem_slots[k]) then
                        i_slot = i_slot + v
                    end
                end
                slot_s = slot_s + i_slot

                if slot == 'Waist' or i_slot > 0 then
                    for i = 1, 3 do
                        local gemname, gemlink = GetItemGem(link, i)
                        if(gemlink) then
                            local name, link, quality, iLevel, reqLevel, itype, subType = GetItemInfo(gemlink)
                            gem_s = gem_s + 1
                            if(quality >= 3) then
                                sec_s = sec_s + 1
                            else
                                oth_s = oth_s + 1
                            end
                            i_gem = i_gem + 1
                        end
                    end
                end

                if(slot == 'Waist' and i_gem > i_slot) then
                    waist_extra_slot = true
                end
            end
        end

        slot_s = math.max(slot_s, gem_s)
        local fc = NORMAL_FONT_COLOR_CODE
        local res
        if slot_s == 0 or gem_s == 0 then
            res ="0"
        else
            if sec_s == 0 then
                res = fmt('%d/%d (|cff00dd70%d|r)', gem_s, slot_s, oth_s)
            elseif oth_s == 0 then
                res = fmt('%d/%d (|cff0070dd%d|r)', gem_s, slot_s, sec_s)
            else
                res = fmt('%d/%d (|cff0070dd%d|r+|cff00dd70%d|r)', gem_s, slot_s, sec_s, oth_s) --|cffa335ee%d|r top_s
            end
        end

        return res, waist_extra_slot
    end
end


local _, core = ...
local L = core.L
local floor, ceil, format, tostring = floor, ceil, format, tostring
local pairs, ipairs, next, wipe, assert, type, tinsert, select, tremove, GetTime, setmeta, rawg = pairs, ipairs, next, wipe, assert, type, tinsert, select, tremove, GetTime, setmetatable, rawget

function copy(fromTable, toTable)
    toTable = toTable or {}
    if not fromTable then return end
    for k, v in pairs(fromTable) do
        toTable[k] = v
    end
    return toTable
end

local xpcall = xpcall

local function errorhandler(err)
    return geterrorhandler()(err)
end

local function CreateDispatcher(argCount)
    local code = [[
		local xpcall, eh = ...
		local method, ARGS
		local function call() return method(ARGS) end

		local function dispatch(func, ...)
			method = func
			if not method then return end
			ARGS = ...
			return xpcall(call, eh)
		end

		return dispatch
	]]
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    local ARGS = {}
    for i = 1, argCount do ARGS[i] = "arg" .. i end
    code = code:gsub("ARGS", table.concat(ARGS, ", "))
    return assert(loadstring(code, "safecall Dispatcher[" .. argCount .. "]"))(xpcall, errorhandler)
end


local Dispatchers = setmetatable({}, {__index = function(self, argCount)
    local dispatcher = CreateDispatcher(argCount)
    rawset(self, argCount, dispatcher)
    return dispatcher
end})

Dispatchers[0] = function(func)
    return xpcall(func, errorhandler)
end

function safecall(func, ...)
    return Dispatchers[select("#", ...)](func, ...)
end

core.frame = CreateFrame("Frame")
local runOnNextCount = 0
local runOnNextFrame = {}
local runOnNextKeyCount = 0
local runOnNextKey = setmetatable({}, {__newindex = function(t, k, v)rawset(t, k, v)runOnNextKeyCount = runOnNextKeyCount + 1 end})
core.frame:SetScript("OnUpdate", function(self)
    if runOnNextKeyCount > 0 then
        for k, v in next, runOnNextKey do
            safecall(v, k)
            runOnNextKey[k] = nil
        end
        runOnNextKeyCount = 0
    end
    if runOnNextCount > 0 then
        local oldCount = runOnNextCount
        for i = 1, oldCount do
            local v = runOnNextFrame[i]
            if v[1] then
                safecall(v[1], select(2, unpack(v)))
            end
            wipe(v)
        end
        runOnNextCount = runOnNextCount - oldCount
        for i = 1, runOnNextCount do
            copy(runOnNextFrame[i + runOnNextCount], runOnNextFrame[i])
            wipe(runOnNextFrame[i + runOnNextCount])
        end
    end
end)

function RunOnNextFrame(func, ...)
    runOnNextCount = runOnNextCount + 1
    local data = runOnNextFrame[runOnNextCount]
    if (not data) then
        data = {}
        runOnNextFrame[runOnNextCount] = data
    end
    data[1] = func
    for i = 1, select("#", ...) do
        data[i + 1] = select(i, ...)
    end
end

function CoreOnEvent(event, func, frame)
    local f = CreateFrame("Frame")
    f.addon = addon or f
    f:SetScript("OnEvent", function(self, event, ...)
        local func = self.addon[event]
        func(self.addon, event, ...)
    end)
    f:RegisterEvent(event)
    f[event] = func
    return f
end

RequestProtection = {}
local RP = RequestProtection
local debug = function() end
local submitRequest, doneRequest
local stats = {}
local mirror = {}
local enteredWorld = IsLoggedIn()

local PROTECT_LIST = {
    SetAchievementComparisonUnit = {
        event = "INSPECT_ACHIEVEMENT_READY",
        pattern = "UIParent%.lua:%d-: in function InspectAchievements",
        guid_getter = function(...) return UnitGUID(...) end,
        timeout = 120,
        interval = 1,
        clear = "ClearAchievementComparisonUnit"
    },
}

local function scheduleOrBlock(schedule, name, reqFuncOrArgs, callback)
    assert(PROTECT_LIST[name], "This function is not protected.")
    local stat = stats[name]
    if stat.timeout or stat.interval then
        if shedule then
            table.insert(stat.queue, {reqFuncOrArgs, callback})
        else
            RunOnNextFrame(callback, false, "blocked")
        end
    else
        submitRequest(name, reqFuncOrArgs, callback, true)
    end
end

function RP:Schedule(name, reqFuncOrArgs, callback)
    scheduleOrBlock(true, name, reqFuncOrArgs, callback)
end

function RP:Call(name, reqFuncOrArgs, callback)
    scheduleOrBlock(false, name, reqFuncOrArgs, callback)
end

function RP:hook(name, func)
    assert(type(_G[name]) == "function", "Bad arg1, string function name expected")
    assert(type(func) == "function", "Bad arg2, function expected")
    
    self.origins = self.origins or {}
    self.hooks = self.hooks or {}
    
    if not self.origins[name] then
        self.origins[name] = _G[name]
        _G[name] = function(...) return self.hooks[name](...) end
    end
    self.hooks[name] = func
end

local frame = WW:Frame():RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("PLAYER_LEAVING_WORLD")
for _name, define in pairs(PROTECT_LIST) do
    frame:RegisterEvent(define.event)
    stats[_name] = {
        callback = nil,
        timeout = nil,
        interval = nil,
        queue = {},
        guid,
    }
    mirror[define.event] = _name
    
    local o = _G[define.clear]
    _G[define.clear] = function(...)o(...) end
    RP:hook(define.clear, function()
        debug(define.clear, " blocked")
    end)
    RP:hook(_name, function(...)
        debug(_name, "called", ...)
        local stat, define = stats[_name], PROTECT_LIST[_name]
        local manual = debugstack():find(define.pattern)
        if manual or (stat.timeout == nil and stat.interval == nil and enteredWorld) then
            local newguid = define.guid_getter(...)
            if stat.guid == newguid then
                return
            end
            
            if manual then
                doneRequest(_name, false, "interrupted")
            end
            stat.timeout = GetTime() + define.timeout
            stat.interval = nil
            stat.guid = guid
            pcall(RP.origins[define.clear])
            return RP.origins[_name](...)
        end
        debug(_name, ", but blocked")
    end)
end

frame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        if ... == "Blizzard_InspectUI" then
            if InspectGuildFrame_Update then
                RP:hook("InspectGuildFrame_Update", function()
                    if InspectFrame.unit and GetGuildInfo(InspectFrame.unit) then
                        RP.origins["InspectGuildFrame_Update"]()
                    end
                end)
            end
        elseif ... == "Blizzard_AchievementUI" then
            if AchievementFrameComparison_UpdateStatusBars then
                RP:hook("AchievementFrameComparison_UpdateStatusBars", function(id)
                    if id and id ~= "summary" then
                        RP.origins["AchievementFrameComparison_UpdateStatusBars"](id)
                    end
                end)
            end
        end
    elseif event == "PLAYER_ENTERING_WORLD" then
        enteredWorld = true
    elseif event == "PLAYER_LEAVING_WORLD" then
        enteredWorld = false
    elseif mirror[event] then
        doneRequest(mirror[event], true, event, ...)
    end
end)

local span, next = 0.05, 0
frame:SetScript("OnUpdate", function(self, elapsed)
    if next > span then
        next = 0
        local now = GetTime()
        for _name, stat in pairs(stats) do
            if stat.timeout and now >= stat.timeout then
                debug(_name, "timeout")
                doneRequest(_name, false, "timeout")
            end
            if stat.interval and now >= stat.interval then
                stat.interval = nil
                while stat.timeout == nil and #stat.queue > 0 do
                    submitRequest(_name, unpack(table.remove(stat.queue, 1)))
                end
            end
        end
    else
        next = next + elapsed
    end
end)

submitRequest = function(name, reqFuncOrArgs, callback, nextFrame)
    local stat, type = stats[name], type(reqFuncOrArgs)
    if type ~= "function" then
        if type == "table" then
            _G[name](unpack(reqFuncOrArgs))
        else
            _G[name](reqFuncOrArgs)
        end
    else
        reqFuncOrArgs(_G[name])
        if not stat.timeout then
            if nextFrame then
                RunOnNextFrame(callback, false, "skip")
            else
                xpcall(function()callback(false, "skip") end, geterrorhandler())
            end
        end
    end
    if stat.timeout then stat.callback = callback end
end

doneRequest = function(_name, success, cause, ...)
    local stat = stats[_name]
    if stat.callback then
        xpcall(function()stat.callback(success, cause) end, geterrorhandler())
        stat.callback = nil
    end
    stat.timeout = nil
    stat.interval = GetTime() + PROTECT_LIST[_name].interval
end
