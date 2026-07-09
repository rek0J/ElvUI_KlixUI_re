local KUI, T, E, L, V, P, G = unpack(select(2, ...))
local ABS = KUI:NewModule("AutoButtons", "AceEvent-3.0")
local LSM = E.LSM or E.Libs.LSM

local C_QuestLog = rawget(_G, "C_QuestLog")
-- C_QuestLog.GetInfo takes a QUEST LOG index, not a watch index.
-- Never use it here; always go through GetQuestIndexForWatch to translate watch→log.
local C_QuestLog_GetNumQuestWatches = C_QuestLog and rawget(C_QuestLog, "GetNumQuestWatches")
local GetNumQuestWatches = T.GetNumQuestWatches or _G.GetNumQuestWatches
-- Phase 5 may have moved GetQuestIndexForWatch into C_QuestLog namespace.
local GetQuestIndexForWatch = _G.GetQuestIndexForWatch
	or (C_QuestLog and rawget(C_QuestLog, "GetQuestIndexForWatch"))
local ITEMQUALITY = _G.Enum and _G.Enum.ItemQuality
local ITEMQUALITY_COMMON = ITEMQUALITY and (ITEMQUALITY.Common or ITEMQUALITY.Standard) or 1

local QuestItemList = {}
local garrisonsmv = {118897, 118903}
local garrisonsc = {114116, 114119, 114120, 120301, 120302}

BINDING_HEADER_KLIXUI_AutoSlotButton = KUI.Title.. L["Auto InventoryItem Button"]
BINDING_HEADER_KLIXUI_AutoQuestButton = KUI.Title.. L["Auto QuestItem Button"]

for i = 1, 12 do
	_G["BINDING_NAME_CLICK AutoSlotButton"..i..":LeftButton"] = L["Auto InventoryItem Button"]..i
	_G["BINDING_NAME_CLICK AutoQuestButton"..i..":LeftButton"] = L["Auto QuestItem Button"]..i
end

local C_Item = rawget(_G, "C_Item")

local function SafeIsItemInRange(itemID, unit)
	if not itemID or not unit or not UnitExists(unit) then
		return nil
	end

	if T.InCombatLockdown() then
		return nil
	end

	if C_Item and C_Item.IsItemInRange then
		return C_Item.IsItemInRange(itemID, unit)
	elseif T.IsItemInRange then
		return T.IsItemInRange(itemID, unit)
	end

	return nil
end

local function GetWatchedQuestCount()
	-- Prefer the classic global; fall back to C_QuestLog namespace if moved in a later build.
	if GetNumQuestWatches then
		return GetNumQuestWatches()
	end
	if C_QuestLog_GetNumQuestWatches then
		return C_QuestLog_GetNumQuestWatches()
	end
	return 0
end

local function GetWatchedQuestData(index)
	-- GetQuestIndexForWatch translates watch-slot → quest-log-index (classic MoP API).
	-- C_QuestLog.GetInfo takes a quest-log-index, NOT a watch-index, so we never use it
	-- here. Using it with a watch-index would return data for the wrong quest.
	local questLogIndex = GetQuestIndexForWatch and GetQuestIndexForWatch(index)
	if not questLogIndex then
		if KUI.AutoButtonClickDebug then
			KUI:Print(string.format("|cfff960d9[AB-DBG]|r Watch[%d]: GetQuestIndexForWatch=nil (API missing?)", index))
		end
		return
	end

	local title, _, _, isHeader, _, isComplete, _, questID = T.GetQuestLogTitle(questLogIndex)
	if isHeader then return end

	return questID, title, questLogIndex, isComplete
end

local function GetBorderColorFromQuality(rarity)
	local r, g, b = E:GetItemQualityColor(rarity)
	if r and g and b then
		return r, g, b
	end

	return unpack(E.media.bordercolor)
end

local function GetQuestItemList()
    T.table_wipe(QuestItemList)
    local watchCount = GetWatchedQuestCount()
    for i = 1, watchCount do
		local questID, title, questLogIndex, isComplete = GetWatchedQuestData(i)
        if questLogIndex then
            local link, item, charges, showItemWhenComplete = T.GetQuestLogSpecialItemInfo(questLogIndex)
            if link then
                local itemID = T.tonumber(link:match(":(%d+):"))
                if itemID then
                    QuestItemList[itemID] = {
                        ["isComplete"] = isComplete,
                        ["showItemWhenComplete"] = showItemWhenComplete,
                        ["questLogIndex"] = questLogIndex,
                        ["itemLink"] = link,  -- kept for reliable SetAttribute("item")
                    }
                end
            end
        end
    end

    if KUI.AutoButtonClickDebug then
        local count = 0
        for _ in T.pairs(QuestItemList) do count = count + 1 end
        KUI:Print(string.format("|cfff960d9[AB-DBG]|r QuestItemList: %d items | watched: %d | GetQuestIndexForWatch=%s",
            count, watchCount, tostring(GetQuestIndexForWatch ~= nil)))
    end

    ABS:ScanItem("QUEST")
end

local function GetWorldQuestItemList(toggle)
    local mapID = T.C_Map_GetBestMapForUnit("player") or 0
    local taskInfo = T.C_TaskQuest_GetQuestsForPlayerByMapID(mapID)
    local isComplete
    
    if (taskInfo and #taskInfo > 0) then
        for i, info in T.pairs(taskInfo) do
            local questID = info.questId
            local questLogIndex = T.GetQuestLogIndexByID(questID)
            if questLogIndex then
                local link, item, charges, showItemWhenComplete = T.GetQuestLogSpecialItemInfo(questLogIndex)
                if link then
                    local itemID = T.tonumber(link:match(":(%d+):"))
                    QuestItemList[itemID] = {
                        ["isComplete"] = isComplete,
                        ["showItemWhenComplete"] = showItemWhenComplete,
                        ["questLogIndex"] = questLogIndex,
                    }
                end
            end
        end
    end
    
    if (toggle ~= "init") then
        ABS:ScanItem("QUEST")
    end
end

local function haveIt(num, spellName)
    if not spellName then return false end
    
    for i = 1, num do
        local AutoButton = _G["AutoQuestButton" .. i]
        if not AutoButton then break end
        if AutoButton.spellName == spellName then
            return false
        end
    end

    return true
end

local function IsUsableItem(itemId)
    local itemSpell = T.GetItemSpell(itemId)
    if not itemSpell then return false end
    
    return itemSpell
end

local function IsSlotItem(itemId)
    local itemSpell = IsUsableItem(itemId)
    local itemName = T.GetItemInfo(itemId)
    
    return itemSpell
end

local function AutoButtonHide(AutoButton)
    if not AutoButton then return end

    AutoButton:SetAlpha(0)
    if not T.InCombatLockdown() then
        AutoButton:EnableMouse(false)
    else
        AutoButton:RegisterEvent("PLAYER_REGEN_ENABLED")
        AutoButton:SetScript("OnEvent", function(self, event)
            if event == "PLAYER_REGEN_ENABLED" then
                self:EnableMouse(false)
                self:UnregisterEvent("PLAYER_REGEN_ENABLED")
            end
        end)
    end
end

local function HideAllButton(event)
    if T.InCombatLockdown() then
        KUI:RunOutOfCombat("AutoButtons:HideAllButton", function()
            HideAllButton(event)
        end)
        return
    end

    local i, k = 1, 1

    for i = k, 12 do
        AutoButtonHide(_G["AutoQuestButton" .. i])
    end

    for i = 1, 12 do
        AutoButtonHide(_G["AutoSlotButton" .. i])
    end
end

-- type1="item" and type1="click"+clickbutton=ContainerFrameItemButton were both tested
-- in isolation via /run and BOTH silently no-op on this client: ContainerFrame*Item*
-- globals exist but IsShown()==false even with bags open (this client's bag UI doesn't
-- populate those legacy per-slot globals the way older clients did), and the native
-- "item" attribute dispatch does nothing either. The only mechanism confirmed to
-- actually execute for every case (equip slot AND bag item) is type1="macro" +
-- macrotext="/use ..." — same as Blizzard's own paperdoll slot buttons internally,
-- extended here to bag items via "/use item:<id>" (identical to a hand-typed macro).
local function AutoButtonApplyAttributes(btn)
    local spellName, spellID
    local invLink

    if btn.slotID then
        invLink = GetInventoryItemLink("player", btn.slotID)
        if invLink then
            spellName, spellID = T.GetItemSpell and T.GetItemSpell(invLink)
        end
        if not spellName and btn.itemID then
            spellName, spellID = T.GetItemSpell and T.GetItemSpell(btn.itemID)
        end

        btn:SetAttribute("type1",     "macro")
        btn:SetAttribute("macrotext", "/use " .. btn.slotID)
    elseif btn.itemID then
        invLink = btn.itemLink
        if invLink then
            spellName, spellID = T.GetItemSpell and T.GetItemSpell(invLink)
        end
        if not spellName then
            spellName, spellID = T.GetItemSpell and T.GetItemSpell(btn.itemID)
        end

        btn:SetAttribute("type1",     "macro")
        btn:SetAttribute("macrotext", "/use item:" .. btn.itemID)
    end

    if KUI.AutoButtonClickDebug then
        local cbName = btn:GetAttribute("clickbutton") and btn:GetAttribute("clickbutton"):GetName() or nil
        KUI:Print(string.format(
            "|cfff960d9[AB-DBG]|r ApplyAttr %s | link=%s | slotID=%s | spellName=%s | spellID=%s | type=%s | macrotext=%s | spell=%s | item=%s | clickbtn=%s | combat=%s",
            tostring(btn:GetName()),
            tostring(invLink),
            tostring(btn.slotID),
            tostring(spellName),
            tostring(spellID),
            tostring(btn:GetAttribute("type1")),
            tostring(btn:GetAttribute("macrotext")),
            tostring(btn:GetAttribute("spell")),
            tostring(btn:GetAttribute("item")),
            tostring(cbName),
            tostring(T.InCombatLockdown())))
    end
end

local function AutoButtonShow(AutoButton)
    if not AutoButton then return end

    AutoButton:SetAlpha(1)
    AutoButton:SetScript("OnEnter", function(self)
		if self:GetParent() == E.ActionBars.fadeParent then
			if(not E.ActionBars.fadeParent.mouseLock) then
				E:UIFrameFadeIn(E.ActionBars.fadeParent, 0.2, E.ActionBars.fadeParent:GetAlpha(), 1)
			end
		end
        if T.InCombatLockdown() then return end
	_G.GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT", 0, -2)
	_G.GameTooltip:ClearLines()
        if self.slotID then
			_G.GameTooltip:SetInventoryItem("player", self.slotID)
        elseif self.itemID then
            -- SetItemByID is Dragonflight+; use SetHyperlink for MoP Classic compat.
            _G.GameTooltip:SetHyperlink("item:" .. self.itemID)
        end
		_G.GameTooltip:Show()
    end)
    AutoButton:SetScript("OnLeave", function(self)
		if self:GetParent() == E.ActionBars.fadeParent then
			if(not E.ActionBars.fadeParent.mouseLock) then
				E:UIFrameFadeOut(E.ActionBars.fadeParent, 0.2, E.ActionBars.fadeParent:GetAlpha(), 1 - E.ActionBars.db.globalFadeAlpha)
			end
		end
        _G.GameTooltip:Hide()
    end)
    
    if not T.InCombatLockdown() then
        AutoButton:EnableMouse(true)
        AutoButtonApplyAttributes(AutoButton)
    else
        AutoButton:RegisterEvent("PLAYER_REGEN_ENABLED")
        AutoButton:SetScript("OnEvent", function(self, event)
            if event == "PLAYER_REGEN_ENABLED" then
                self:EnableMouse(true)
                AutoButtonApplyAttributes(self)
                self:UnregisterEvent("PLAYER_REGEN_ENABLED")
            end
        end)
    end
end

local function CreateButton(name, size)
    if _G[name] then
		_G[name]:SetSize(size, size)
		_G[name].Count:FontTemplate(nil, ABS.db.countFontSize, "OUTLINE")
		_G[name].HotKey:FontTemplate(nil, ABS.db.bindFontSize, "OUTLINE")

		return _G[name]
    end
    
    -- Generic "type" attribute + RegisterForClicks("AnyUp") silently no-ops on this
    -- client for both macro and click-forward dispatch: PreClick/PostClick still
    -- fire (they're plain Lua script hooks), but the underlying protected action
    -- never actually runs. Confirmed via isolated /run testing that the fix is the
    -- per-mouse-button "type1" attribute (not generic "type") combined with
    -- RegisterForClicks("AnyDown") (not "AnyUp") on a bare SecureActionButtonTemplate.
    -- ActionButtonTemplate was tried too but is NOT required for dispatch, and for
    -- type1="click" it actively breaks things: its built-in pickup/drag handling
    -- hijacks the click, turning it into "pick up this icon" instead of forwarding.
    local AutoButton = T.CreateFrame("Button", name, E.UIParent, "SecureActionButtonTemplate")
    AutoButton:SetSize(size, size)
    AutoButton:CreateBackdrop("Default")
    if AutoButton.backdrop then AutoButton.backdrop:EnableMouse(false) end
    AutoButton:StyleButton()
    AutoButton:SetClampedToScreen(true)
    AutoButton:SetAlpha(0)
    AutoButton:EnableMouse(false)
    AutoButton:RegisterForClicks("AnyDown")
    AutoButton:SetFrameStrata("MEDIUM")
    AutoButton:SetFrameLevel(E.UIParent:GetFrameLevel() + 10)

	-- Frame (not Button) so it never intercepts mouse clicks from its parent.
	-- Explicit EnableMouse(false) because CooldownFrameTemplate and some ElvUI versions
	-- can leave child frames mouse-enabled, silently absorbing clicks before they reach
	-- the SecureActionButton.
	AutoButton.Overlay = T.CreateFrame("Frame", nil, AutoButton)
	AutoButton.Overlay:EnableMouse(false)
	AutoButton.Overlay:CreateIconShadow()
	AutoButton.Overlay:SetOutside(AutoButton, 0, 0)
	
    AutoButton.Texture = AutoButton:CreateTexture(nil, "OVERLAY", nil)
	AutoButton.Texture:SetPoint("TOPLEFT", AutoButton, "TOPLEFT", 2, -2)
	AutoButton.Texture:SetPoint("BOTTOMRIGHT", AutoButton, "BOTTOMRIGHT", -2, 2)
    AutoButton.Texture:SetTexCoord(unpack(E.TexCoords))

    AutoButton.Count = AutoButton:CreateFontString(nil, "OVERLAY")
	AutoButton.Count:FontTemplate(nil, ABS.db.countFontSize, "OUTLINE")
    AutoButton.Count:SetTextColor(1, 1, 1, 1)
	AutoButton.Count:SetPoint("BOTTOMRIGHT", AutoButton, "BOTTOMRIGHT", 0, 0)
    AutoButton.Count:SetJustifyH("CENTER")

    AutoButton.HotKey = AutoButton:CreateFontString(nil, "OVERLAY")
    AutoButton.HotKey:FontTemplate(nil, ABS.db.bindFontSize, "OUTLINE")
    AutoButton.HotKey:SetTextColor(1, 1, 1)
	AutoButton.HotKey:SetPoint("TOPRIGHT", AutoButton, "TOPRIGHT", 0, 0)
    AutoButton.HotKey:SetJustifyH("RIGHT")
    
    AutoButton.Cooldown = T.CreateFrame("Cooldown", nil, AutoButton, "CooldownFrameTemplate")
    AutoButton.Cooldown:SetPoint("TOPLEFT", AutoButton, "TOPLEFT", 2, -2)
    AutoButton.Cooldown:SetPoint("BOTTOMRIGHT", AutoButton, "BOTTOMRIGHT", -2, 2)
    AutoButton.Cooldown:SetSwipeColor(1, 1, 1, 1)
    AutoButton.Cooldown:SetDrawBling(false)
    AutoButton.Cooldown:EnableMouse(false)  -- must not absorb clicks destined for the button
    
    -- E:RegisterCooldown(cooldown, which) reads "which" from the 2nd call argument,
    -- NOT from a cooldown.CooldownOverride field (that field doesn't exist in ElvUI's
    -- Cooldowns.lua) - pass it directly or this silently registers as 'global' instead.
    E:RegisterCooldown(AutoButton.Cooldown, 'actionbar')

    -- Shrink just this button's cooldown countdown text by 1px, without touching
    -- E.db.cooldown.actionbar (that's shared by every real actionbar/petbar cooldown).
    if AutoButton.Cooldown.Text then
        local font, size, outline = AutoButton.Cooldown.Text:GetFont()
        if size then
            AutoButton.Cooldown.Text:FontTemplate(font, size - 1, outline)
        end
    end

    if E.FrameLocks then E.FrameLocks[AutoButton] = true end

    -- Click debugger – toggle with /kuidbg abclick
    -- PreClick fires if the click reaches this button; PostClick fires after secure action.
    -- If neither fires the button is covered by another frame intercepting the click.
    -- OnMouseDown fires on press (before click registration); useful to confirm mouse events reach button.
    local function ClickDebugDump(self, tag, btn)
        if not KUI.AutoButtonClickDebug then return end
        local cb = self:GetAttribute("clickbutton")
        print(string.format(
            "|cfff960d9[ClickDBG]|r %s %s | click=%s | obj=%s | type=%s | spell=%s | item=%s | macrotext=%s | clickbtn=%s | mouse=%s | hasOnClick=%s | mouseOver=%s | combat=%s",
            tag,
            self:GetName() or "?",
            tostring(btn),
            tostring(self:GetObjectType()),
            tostring(self:GetAttribute("type1")),
            tostring(self:GetAttribute("spell")),
            tostring(self:GetAttribute("item")),
            tostring(self:GetAttribute("macrotext")),
            tostring(cb and cb:GetName() or nil),
            tostring(self:IsMouseEnabled()),
            tostring(self:GetScript("OnClick") ~= nil),
            tostring(MouseIsOver(self)),
            tostring(T.InCombatLockdown())))
    end

    AutoButton:HookScript("OnMouseDown", function(self, btn)
        ClickDebugDump(self, "|cff55ccffMDOWN|r", btn)
    end)
    AutoButton:HookScript("OnMouseUp", function(self, btn)
        if not KUI.AutoButtonClickDebug then return end
        print(string.format(
            "|cfff960d9[ClickDBG]|r MUP   %s | click=%s | combat=%s",
            self:GetName() or "?",
            tostring(btn),
            tostring(T.InCombatLockdown())))
    end)
    AutoButton:SetScript("PreClick", function(self, btn, down)
        ClickDebugDump(self, "|cffff8800PRE |r", btn)
    end)
    AutoButton:SetScript("PostClick", function(self, btn, down)
        ClickDebugDump(self, "|cff00ff00POST|r", btn)
    end)

    return AutoButton
end

function ABS:ScanItem(event)
    if T.InCombatLockdown() then
        KUI:RunOutOfCombat("AutoButtons:ScanItem", function()
            ABS:ScanItem(event)
        end)
        return
    end

    local db = E.db.KlixUI.actionbars.autoButtons

    HideAllButton(event)
    --GetWorldQuestItemList("init")
    
    local questItemIDList = {}
    local minimapZoneText = T.GetMinimapZoneText()

	-- Garrison related
    if minimapZoneText == L["Alliance Mine"] or minimapZoneText == L["Horde Mine"] then
        for i = 1, #garrisonsmv do
            local count = T.GetItemCount(garrisonsmv[i])
            if count and (count > 0) and (not ABS.db.blackList[garrisonsmv[i]]) then
                tinsert(questItemIDList, garrisonsmv[i])
            end
        end
    elseif minimapZoneText == L["Salvage Yard"] then
        for i = 1, #garrisonsc do
            local count = T.GetItemCount(garrisonsc[i])
            if count and (count > 0) and (not ABS.db.blackList[garrisonsc[i]]) then
                tinsert(questItemIDList, garrisonsc[i])
            end
        end
    else

	-- Quest Items
        for k, v in T.pairs(QuestItemList) do
            if (not QuestItemList[k].isComplete) or (QuestItemList[k].isComplete and QuestItemList[k].showItemWhenComplete) then
                if not ABS.db.blackList[k] then
                    T.table_insert(questItemIDList, k)
                end
            end
        end
        for k, v in T.pairs(ABS.db.whiteList) do
            local count = T.GetItemCount(k)
            if count and (count > 0) and v and (not ABS.db.blackList[k]) then
                T.table_insert(questItemIDList, k)
            end
        end
        if T.GetItemCount(123866) and (T.GetItemCount(123866) >= 5) and (not ABS.db.blackList[123866]) and (T.C_Map_GetBestMapForUnit("player") == 945) then
            T.table_insert(questItemIDList, 123866)
        end
    end
    
	-- FIX [SORT]: GetItemInfo() im Sort-Comparator wird O(n log n) mal aufgerufen.
    -- Caching auf O(n) reduziert ueberfluessige API-Aufrufe beim Kampf-Exit.
    local itemTypeCache = {}
    for _, itemID in ipairs(questItemIDList) do
        itemTypeCache[itemID] = T.select(7, T.GetItemInfo(itemID))
    end
    sort(questItemIDList, function(v1, v2)
        local itemType1 = itemTypeCache[v1]
        local itemType2 = itemTypeCache[v2]
        if itemType1 and itemType2 then
            return itemType1 > itemType2
        else
            return v1 > v2
        end
    end)
    
    if ABS.db.questAutoButtons.enable == true and ABS.db.questAutoButtons.questNum > 0 then
        for i = 1, #questItemIDList do
            local itemID = questItemIDList[i]
            local itemName, _, rarity = T.GetItemInfo(itemID)
            
            if i > ABS.db.questAutoButtons.questNum then break end
            
            local AutoButton = _G["AutoQuestButton" .. i]
            local count = T.GetItemCount(itemID, nil, 1)
            local itemIcon = T.GetItemIcon(itemID)
            
            if not AutoButton then break end
            AutoButton.Texture:SetTexture(itemIcon)
            AutoButton.itemName = itemName
            AutoButton.itemID = itemID
            AutoButton.itemLink = QuestItemList[itemID] and QuestItemList[itemID].itemLink
            AutoButton.slotID = nil  -- clear any stale slot from previous use
            AutoButton.ap = false
            AutoButton.questLogIndex = QuestItemList[itemID] and QuestItemList[itemID].questLogIndex or -1
            AutoButton.spellName = IsUsableItem(itemID)
            local r, g, b
            if ABS.db.questAutoButtons.questBBColorByItem then
                if rarity and rarity > ITEMQUALITY_COMMON then
                    r, g, b = GetBorderColorFromQuality(rarity)
				else
					r, g, b = 1, 1, 1
                end
            else
                local colorDB = ABS.db.questAutoButtons.questBBColor
                if colorDB then
                    r, g, b = colorDB.r, colorDB.g, colorDB.b
                end
            end
			if not (r and g and b) then
				r, g, b = unpack(E.media.bordercolor)
			end
			AutoButton.backdrop:SetBackdropBorderColor(r, g, b)
            
            if count and count > 1 then
                AutoButton.Count:SetText(count)
            else
                AutoButton.Count:SetText("")
            end
            
            AutoButton:SetScript("OnUpdate", function(self, elapsed)
            	self.rangeElapsed = (self.rangeElapsed or 0) + elapsed

                local start, duration, enable
                if self.questLogIndex and self.questLogIndex > 0 then
                    start, duration, enable = T.GetQuestLogSpecialItemCooldown(self.questLogIndex)
                end
                if not start then
                    start, duration, enable = T.GetItemCooldown(self.itemID)
                end

                T.CooldownFrame_Set(self.Cooldown, start or 0, duration or 0, enable or 0)

                if duration and duration > 0 and enable and enable == 0 then
                    self.Texture:SetVertexColor(0.4, 0.4, 0.4)
                    return
                end

                if self.rangeElapsed < 0.5 then
		            return
	            end
	            self.rangeElapsed = 0

                local inRange = SafeIsItemInRange(self.itemID, "target")
                if inRange == false then
                    self.Texture:SetVertexColor(1, 0, 0)
                else
                    self.Texture:SetVertexColor(1, 1, 1)
                end
            end)
            AutoButtonShow(AutoButton)
        end
    end
    
    local num = 0
    if ABS.db.slotAutoButtons.enable == true and ABS.db.slotAutoButtons.slotNum > 0 then
        for w = 1, 18 do
            local slotID = T.GetInventoryItemID("player", w)
            if slotID and IsSlotItem(slotID) and not ABS.db.blackList[slotID] then
                local itemName, _, rarity = T.GetItemInfo(slotID)
                local itemIcon = T.GetInventoryItemTexture("player", w)
                num = num + 1
                if num > ABS.db.slotAutoButtons.slotNum then break end
                
                local AutoButton = _G["AutoSlotButton" .. num]
                if not AutoButton then break end

                local r, g, b
                if rarity and rarity > ITEMQUALITY_COMMON and ABS.db.slotAutoButtons.slotBBColorByItem then
					r, g, b = GetBorderColorFromQuality(rarity)
                else
                    local colorDB = ABS.db.slotAutoButtons.slotBBColor
                    if colorDB then
                        r, g, b = colorDB.r, colorDB.g, colorDB.b
                    end
                end
				if not (r and g and b) then
					r, g, b = unpack(E.media.bordercolor)
				end
				AutoButton.backdrop:SetBackdropBorderColor(r, g, b)

                AutoButton.Texture:SetTexture(itemIcon)
                AutoButton.Count:SetText("")
                AutoButton.slotID = w
                AutoButton.itemID = slotID
                AutoButton.itemLink = nil  -- slot buttons use slotID path, no link needed
                AutoButton.itemName = nil
                AutoButton.spellName = IsUsableItem(slotID)
                
                -- FIX [P-AB]: Throttle fuer Inventar-Cooldown-Anzeige. Ohne Throttle:
                -- GetInventoryItemCooldown + CooldownFrame_Set jeden Frame = unnoetige CPU-Last.
                AutoButton:SetScript("OnUpdate", function(self, elapsed)
                    self._cdElapsed = (self._cdElapsed or 0) + elapsed
                    if self._cdElapsed < 0.1 then return end
                    self._cdElapsed = 0
                    local cd_start, cd_finish, cd_enable = T.GetInventoryItemCooldown("player", self.slotID)
                    T.CooldownFrame_Set(AutoButton.Cooldown, cd_start, cd_finish, cd_enable)
                end)
                AutoButtonShow(AutoButton)
            end
        end
    end
end

local lastUpdate = 0
function ABS:ScanItemCount(elapsed)
	local db = E.db.KlixUI.actionbars.autoButtons
    lastUpdate = lastUpdate + elapsed
	
    if lastUpdate < 0.5 then
        return
    end

    lastUpdate = 0

    for i = 1, db.questAutoButtons.questNum do
        local f = _G["AutoQuestButton" .. i]
        if f and f.itemName then
            local count = T.GetItemCount(f.itemID, nil, 1)
            
            if count and count > 1 then
                f.Count:SetText(count)
            else
                f.Count:SetText("")
            end
        end
	end           
end

function ABS:UpdateBind()
    if not ABS.db.autoButtons then return end

    if ABS.db.questAutoButtons.enable == true then
        for i = 1, ABS.db.questAutoButtons.questNum do
            local bindButton = "CLICK AutoQuestButton" .. i .. ":LeftButton"
            local button = _G["AutoQuestButton" .. i]
            local bindText = T.GetBindingKey(bindButton)
            if not bindText then
                bindText = ""
            else
                bindText = T.string_gsub(bindText, "SHIFT--", "S")
                bindText = T.string_gsub(bindText, "CTRL--", "C")
                bindText = T.string_gsub(bindText, "ALT--", "A")
            end
            
            if button then button.HotKey:SetText(bindText) end
        end
    end

    if ABS.db.slotAutoButtons.enable == true then
        for i = 1, ABS.db.slotAutoButtons.slotNum do
            local bindButton = "CLICK AutoSlotButton" .. i .. ":LeftButton"
            local button = _G["AutoSlotButton" .. i]
            local bindText = T.GetBindingKey(bindButton)
            if not bindText then
                bindText = ""
            else
                bindText = T.string_gsub(bindText, "SHIFT--", "S")
                bindText = T.string_gsub(bindText, "CTRL--", "C")
                bindText = T.string_gsub(bindText, "ALT--", "A")
            end
            
            if button then button.HotKey:SetText(bindText) end
        end
    end
end

function ABS:ToggleAutoButton()
    if ABS.db.enable then
		self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED", "ScanItem")
        self:RegisterEvent("UNIT_INVENTORY_CHANGED", "ScanItem")
        self:RegisterEvent("ZONE_CHANGED", "ScanItem")
        self:RegisterEvent("ZONE_CHANGED_NEW_AREA", "ScanItem")
        self:RegisterEvent("BAG_UPDATE_DELAYED", "ScanItem")
        self:RegisterEvent("UPDATE_BINDINGS", "UpdateBind")
        self:RegisterEvent("QUEST_WATCH_LIST_CHANGED", GetQuestItemList)
        self:RegisterEvent("QUEST_LOG_UPDATE", GetQuestItemList)
        -- Ensure quest items appear on fresh login/reload before QUEST_LOG_UPDATE fires.
        self:RegisterEvent("PLAYER_ENTERING_WORLD", GetQuestItemList)
        --self:RegisterEvent("QUEST_ACCEPTED", GetWorldQuestItemList)
        --self:RegisterEvent("QUEST_TURNED_IN", GetWorldQuestItemList)

        if not ABS.Update then ABS.Update = T.CreateFrame("Frame") end
        self.Update:SetScript("OnUpdate", ABS.ScanItemCount)
        self:ScanItem("FIRST")
        self:UpdateBind()
    else
        HideAllButton()
		self:UnregisterEvent("PLAYER_SPECIALIZATION_CHANGED")
        self:UnregisterEvent("UNIT_INVENTORY_CHANGED")
        self:UnregisterEvent("ZONE_CHANGED")
        self:UnregisterEvent("ZONE_CHANGED_NEW_AREA")
        self:UnregisterEvent("BAG_UPDATE_DELAYED")
        self:UnregisterEvent("UPDATE_BINDINGS")
        self:UnregisterEvent("QUEST_WATCH_LIST_CHANGED")
        self:UnregisterEvent("QUEST_LOG_UPDATE")
        self:UnregisterEvent("PLAYER_ENTERING_WORLD")
        if self.Update then self.Update:SetScript("OnUpdate", nil) end
    end
end

local buttonTypes = { "quest", "slot" }
function ABS:UpdateAutoButton()
    if T.InCombatLockdown() then
        KUI:RunOutOfCombat("AutoButtons:UpdateAutoButton", function()
            ABS:UpdateAutoButton()
        end)
        return
    end

    local i = 0
    local lastButton, lastColumnButton, buttonsPerRow
    if ABS.db.questAutoButtons.enable == true then
        for i = 1, ABS.db.questAutoButtons.questNum do
            local f = CreateButton("AutoQuestButton" .. i, ABS.db.questAutoButtons.questSize)
            buttonsPerRow = ABS.db.questAutoButtons.questPerRow
            lastButton = _G["AutoQuestButton" .. i - 1]
            lastColumnButton = _G["AutoQuestButton" .. i - buttonsPerRow]
            
            if ABS.db.questAutoButtons.questNum < ABS.db.questAutoButtons.questPerRow then
                buttonsPerRow = ABS.db.questAutoButtons.questNum
            end
            f:ClearAllPoints()
            
            if i == 1 then
                f:SetPoint("LEFT", AutoButtonAnchor, "LEFT", 0, 0)
            elseif (i - 1) % buttonsPerRow == 0 then
                f:SetPoint("TOP", lastColumnButton, "BOTTOM", 0, -1)
            else
                if ABS.db.questAutoButtons.questDirection == "RIGHT" then
                    f:SetPoint("LEFT", lastButton, "RIGHT", ABS.db.questAutoButtons.questSpace, 0)
                elseif ABS.db.questAutoButtons.questDirection == "LEFT" then
                    f:SetPoint("RIGHT", lastButton, "LEFT", -(ABS.db.questAutoButtons.questSpace), 0)
                end
            end
        end
    end

    if ABS.db.slotAutoButtons.enable == true then
        for i = 1, ABS.db.slotAutoButtons.slotNum do
            local f = CreateButton("AutoSlotButton" .. i, ABS.db.slotAutoButtons.slotSize)
            buttonsPerRow = ABS.db.slotAutoButtons.slotPerRow
            lastButton = _G["AutoSlotButton" .. i - 1]
            lastColumnButton = _G["AutoSlotButton" .. i - buttonsPerRow]
            
            if ABS.db.slotAutoButtons.slotNum < ABS.db.slotAutoButtons.slotPerRow then
                --buttonsPerRow = ABS.db.questAutoButtons.questNum
                buttonsPerRow = ABS.db.slotAutoButtons.slotNum
            end
            f:ClearAllPoints()
            
            if i == 1 then
                f:SetPoint("LEFT", AutoButtonAnchor2, "LEFT", 0, 0)
            elseif (i - 1) % buttonsPerRow == 0 then
                f:SetPoint("TOP", lastColumnButton, "BOTTOM", 0, -1)
            else
                if ABS.db.slotAutoButtons.slotDirection == "RIGHT" then
                    f:SetPoint("LEFT", lastButton, "RIGHT", ABS.db.slotAutoButtons.slotSpace, 0)
                elseif ABS.db.slotAutoButtons.slotDirection == "LEFT" then
                    f:SetPoint("RIGHT", lastButton, "LEFT", -(ABS.db.slotAutoButtons.slotSpace), 0)
                end
            end
        end
    end

    self:ToggleAutoButton()
end

function ABS:Initialize()	
	ABS.db = E.db.KlixUI.actionbars.autoButtons

	if ABS.db.enable ~= true then return end

	KUI:RegisterDB(self, "autoButtons")

	function ABS:ForUpdateAll()
		ABS.db = E.db.KlixUI.actionbars.autoButtons
	end

	self:ForUpdateAll()
	
    local AutoButtonAnchor = T.CreateFrame("Frame", "AutoButtonAnchor", E.UIParent)
    AutoButtonAnchor:SetClampedToScreen(true)
    AutoButtonAnchor:SetPoint("BOTTOMRIGHT", E.UIParent, "BOTTOMRIGHT", -375, 195)
    AutoButtonAnchor:SetSize(ABS.db.questAutoButtons.questSize or 35, ABS.db.questAutoButtons.questSize or 35)
	E:CreateMover(AutoButtonAnchor, "AutoButtonAnchorMover", L["Quest Auto Buttons"], nil, nil, nil, "ALL,ACTIONBARS,KLIXUI", function() return ABS.db.enable end)

    local AutoButtonAnchor2 = T.CreateFrame("Frame", "AutoButtonAnchor2", E.UIParent)
    AutoButtonAnchor2:SetClampedToScreen(true)
    AutoButtonAnchor2:SetPoint("BOTTOMRIGHT", E.UIParent, "BOTTOMRIGHT", -375, 232)
    AutoButtonAnchor2:SetSize(ABS.db.slotAutoButtons.slotSize or 35, ABS.db.slotAutoButtons.slotSize or 35)
	E:CreateMover(AutoButtonAnchor2, "AutoButtonAnchor2Mover", L["Inventory Auto Buttons"], nil, nil, nil, "ALL,ACTIONBARS,KLIXUI", function() return ABS.db.enable end)

    self:UpdateAutoButton()
end

KUI:RegisterModule(ABS:GetName())
