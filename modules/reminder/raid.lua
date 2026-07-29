local KUI, T, E, L, V, P, G = unpack(select(2, ...))
local KRR = KUI:NewModule("KuiRaidReminder")
local LCG = LibStub('LibCustomGlow-1.0')
KRR.modName = L["Raid Buff Reminder"]

KRR.VisibilityStates = {
	["DEFAULT"] = "[noexists, nogroup] hide; show",
	["INPARTY"] = "[combat] hide; [group] show; [petbattle] hide; hide",
	["ALWAYS"] = "[petbattle] hide; show",
}

KRR.ReminderBuffs = {
	Flask = {
		-- Mists of Pandaria
		114769,			-- Flask of Spring Blossoms (intellect)
		114770,			-- Flask of the Earth (stamina)
		114771,			-- Flask of the Warm Sun (agility)
		105696,			-- Flask of Winter's Bite (strength)
	},
	DefiledAugmentRune = {
		-- Legion/Argus content, doesn't exist on MoP Classic - see E.Mists checks below
		224001,			-- Defiled Augumentation (15 primary stat)
		270058,			-- Battle Scarred Augmentation (60 primary stat)
	},
	Intellect = {
		1459, -- Arcane Intellect
	},
	Stamina = {
		21562, -- Power Word: Fortitude
	},
	AttackPower = {
		6673, -- Battle Shout
	},
}

-- Buff name used by every "Well Fed" food effect regardless of item/stat, so a single
-- name-based aura check covers all MoP food instead of hardcoding every food item's spell ID.
local FOOD_BUFF_NAME = _G.WELL_FED or "Well Fed"

-- Which class can personally provide each class-restricted raid buff (for click-to-cast).
local CLASS_BUFF_SPELLS = {
	Intellect = {class = "MAGE", spell = 1459},
	Stamina = {class = "PRIEST", spell = 21562},
	AttackPower = {class = "WARRIOR", spell = 6673},
}

-- Returns the first configured item (in slot order) that's actually in the player's bags.
local function PickAvailableItem(items)
	if not items then return nil end
	for i = 1, 5 do
		local item = items[i]
		if item and item ~= "" and T.GetItemCount(item) > 0 then
			return item
		end
	end
	return nil
end

local flaskbuffs = KRR.ReminderBuffs["Flask"]
local darunebuffs = KRR.ReminderBuffs["DefiledAugmentRune"]
local intellectbuffs = KRR.ReminderBuffs["Intellect"]
local staminabuffs = KRR.ReminderBuffs["Stamina"]
local attackpowerbuffs = KRR.ReminderBuffs["AttackPower"]

local r, g, b = T.unpack(E["media"].rgbvaluecolor)
local color = {r, g, b, 1}

-- Returns true if the player currently has the given spell ID as a HELPFUL aura.
-- Prefers the direct GetPlayerAuraBySpellID API; falls back to an index scan.
local function PlayerHasAura(spellID)
	if C_UnitAuras then
		if C_UnitAuras.GetPlayerAuraBySpellID then
			return C_UnitAuras.GetPlayerAuraBySpellID(spellID) ~= nil
		end
		if C_UnitAuras.GetAuraDataByIndex then
			local i = 1
			while true do
				local aura = C_UnitAuras.GetAuraDataByIndex("player", i, "HELPFUL")
				if not aura then break end
				if aura.spellId == spellID then return true end
				i = i + 1
			end
			return false
		end
	end
	return false
end

-- Returns the icon texture for a spell ID, compatible with both old and new GetSpellInfo.
local function SpellIcon(spellID)
	if C_Spell and C_Spell.GetSpellInfo then
		local info = C_Spell.GetSpellInfo(spellID)
		if info then return info.iconID or info.originalIconID end
	end
	return T.select(3, T.GetSpellInfo(spellID))
end

-- Applies buff-found or buff-missing state to a frame.
local function ApplyBuffState(frame, spellID, found)
	if found then
		frame.t:SetTexture(SpellIcon(spellID))
		frame:SetAlpha(KRR.db.alpha or 0.3)
		LCG.PixelGlow_Stop(frame)
	else
		if KRR.db.glow then LCG.PixelGlow_Start(frame, color, nil, -0.25, nil, 1) end
		frame:SetAlpha(1)
	end
end

-- Checks a buff list against the player's current auras and updates the frame.
local function CheckBuffList(frame, buffList)
	if not frame or not (buffList and buffList[1]) then return end
	frame.t:SetTexture(SpellIcon(buffList[1]))
	for _, spellID in T.pairs(buffList) do
		if PlayerHasAura(spellID) then
			ApplyBuffState(frame, spellID, true)
			return
		end
	end
	ApplyBuffState(frame, buffList[1], false)
end

-- Well Fed covers a different spell ID per food item, so match by aura name instead
-- of maintaining an ID list (and use the icon of whichever food is actually active).
local function CheckFoodBuff(frame)
	if not frame then return end
	if C_UnitAuras and C_UnitAuras.GetAuraDataByIndex then
		local i = 1
		while true do
			local aura = C_UnitAuras.GetAuraDataByIndex("player", i, "HELPFUL")
			if not aura then break end
			if aura.name == FOOD_BUFF_NAME then
				frame.t:SetTexture(aura.icon)
				frame:SetAlpha(KRR.db.alpha or 0.3)
				LCG.PixelGlow_Stop(frame)
				return
			end
			i = i + 1
		end
	end

	if KRR.db.glow then LCG.PixelGlow_Start(frame, color, nil, -0.25, nil, 1) end
	frame:SetAlpha(1)
end

-- BAG_UPDATE can fire dozens of times in a row (bag rearrange/loot), so debounce it
-- instead of re-scanning bags on every single one.
local bagUpdatePending = false
local function OnAuraChange(self, event, arg1, unit)
	if event == "BAG_UPDATE" then
		if not bagUpdatePending then
			bagUpdatePending = true
			T.C_Timer_After(0.2, function()
				bagUpdatePending = false
				KRR:UpdateClickActions()
			end)
		end
		return
	end

	if (event == "UNIT_AURA" and arg1 ~= "player") then return end

	CheckBuffList(FlaskFrame, flaskbuffs)
	CheckFoodBuff(FoodFrame)
	if not E.Mists then
		CheckBuffList(DARuneFrame, darunebuffs)
	end

	if KRR.db.class then
		CheckBuffList(IntellectFrame,   intellectbuffs)
		CheckBuffList(StaminaFrame,     staminabuffs)
		CheckBuffList(AttackPowerFrame, attackpowerbuffs)
	end
end

function KRR:CreateIconBuff(name, relativeTo, firstbutton)
	local button = T.CreateFrame("Button", name, KRR.frame, "SecureActionButtonTemplate")
	button:RegisterForClicks("AnyDown")
	if firstbutton == true then
		button:SetPoint("RIGHT", relativeTo, "RIGHT", E:Scale(-4), 0)
	else
		button:SetPoint("RIGHT", relativeTo, "LEFT", E:Scale(-4), 0)
	end
	button:Size(KRR.db.size)
	button:SetFrameLevel(self.frame.backdrop:GetFrameLevel() + 2)

	button:CreateBackdrop("Default")
	button.backdrop:SetPoint("TOPLEFT", E:Scale(-1), E:Scale(1))
	button.backdrop:SetPoint("BOTTOMRIGHT", E:Scale(1), E:Scale(-1))
	button.backdrop:SetFrameLevel(button:GetFrameLevel() - 1)

	button.t = button:CreateTexture(name..".t", "OVERLAY")
	button.t:SetTexCoord(T.unpack(E.TexCoords))
	button.t:SetAllPoints(button)
	
	-- Used for Glow
	button.overlay = T.CreateFrame("Button", nil, button)
	button.overlay:SetOutside(button, 0, 0)
	button.overlay:CreateIconShadow()
end

function KRR:Visibility()
	if KRR.db.enable then
		T.RegisterStateDriver(self.frame, "visibility", KRR.db.visibility == "CUSTOM" and KRR.db.customVisibility or KRR.VisibilityStates[KRR.db.visibility])
		E:EnableMover(self.frame.mover:GetName())
	else
		T.UnregisterStateDriver(self.frame, "visibility")
		self.frame:Hide()
		E:DisableMover(self.frame.mover:GetName())
	end
end

function KRR:Backdrop()
	if KRR.db.backdrop then
		self.frame.backdrop:Show()
		self.frame.backdrop:Styling()
	else
		self.frame.backdrop:Hide()
	end
end

function KRR:Initialize()
	KRR.db = E.db.KlixUI.reminder.raid

	self.frame = T.CreateFrame("Frame", "RaidBuffReminder", E.UIParent)
	self.frame:CreateBackdrop('Transparent')
	self.frame:SetPoint("TOP", E.UIParent, "TOP", 0, -67)
	E.FrameLocks[self.frame] = true

	self.frame.backdrop:SetAllPoints()

	-- DA Rune (Legion/Argus) doesn't exist on MoP Classic, so it gets neither a frame nor a check there.
	local numIcons = (KRR.db.class and 3 or 0) + 2 + (E.Mists and 0 or 1)
	self.frame:SetSize((KRR.db.size * numIcons) + 28, KRR.db.size + 8) -- Backdrop + size (still needs some adjustments, LOL :P)

	if KRR.db.class then
		self:CreateIconBuff("IntellectFrame", RaidBuffReminder, true)
		self:CreateIconBuff("StaminaFrame", IntellectFrame, false)
		self:CreateIconBuff("AttackPowerFrame", StaminaFrame, false)
		self:CreateIconBuff("FlaskFrame", AttackPowerFrame, false)
		self:CreateIconBuff("FoodFrame", FlaskFrame, false)
		if not E.Mists then
			self:CreateIconBuff("DARuneFrame", FoodFrame, false)
		end
	else
		self:CreateIconBuff("FlaskFrame", RaidBuffReminder, true)
		self:CreateIconBuff("FoodFrame", FlaskFrame, false)
		if not E.Mists then
			self:CreateIconBuff("DARuneFrame", FoodFrame, false)
		end
	end

	self.frame:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
	self.frame:RegisterEvent("UNIT_INVENTORY_CHANGED")
	self.frame:RegisterEvent("UNIT_AURA")
	self.frame:RegisterEvent("PLAYER_REGEN_ENABLED")
	self.frame:RegisterEvent("PLAYER_REGEN_DISABLED")
	self.frame:RegisterEvent("PLAYER_ENTERING_WORLD")
	self.frame:RegisterEvent("UPDATE_BONUS_ACTIONBAR")
	self.frame:RegisterEvent("CHARACTER_POINTS_CHANGED")
	self.frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	self.frame:RegisterEvent("GROUP_ROSTER_UPDATE")
	self.frame:RegisterEvent("BAG_UPDATE")
	self.frame:SetScript("OnEvent", OnAuraChange)

	E:CreateMover(self.frame, "KUI_RaidBuffReminderMover", L["Raid Buffs Reminder"], nil, nil, nil, "ALL,SOLO,PARTY,RAID,KLIXUI", nil, "KlixUI,modules,reminder")

	function KRR:ForUpdateAll()
		KRR.db = E.db.KlixUI.reminder.raid
		self:Backdrop()
		self:Visibility()
	end

	self:ForUpdateAll()
	self:UpdateClickActions()
end

-- Wires up left-click-to-use on the Flask/Food icons (first available item out of up to 5
-- configured slots, in order) and, on the three class-buff icons, click-to-cast the player's
-- own buff when their class provides it.
-- SetAttribute on a secure button is forbidden in combat, hence KUI:RunOutOfCombat.
function KRR:UpdateClickActions()
	KUI:RunOutOfCombat("KuiRaidReminder:UpdateClickActions", function()
		for _, info in T.pairs({
			{frame = _G.FlaskFrame, item = PickAvailableItem(KRR.db.flaskItems)},
			{frame = _G.FoodFrame, item = PickAvailableItem(KRR.db.foodItems)},
		}) do
			if info.frame then
				if info.item then
					info.frame:SetAttribute("type", "item")
					info.frame:SetAttribute("item", info.item)
				else
					info.frame:SetAttribute("type", nil)
					info.frame:SetAttribute("item", nil)
				end
			end
		end

		if KRR.db.class then
			for key, info in T.pairs(CLASS_BUFF_SPELLS) do
				local frame = _G[key.."Frame"]
				if frame then
					if E.myclass == info.class then
						frame:SetAttribute("type", "spell")
						frame:SetAttribute("spell", info.spell)
					else
						frame:SetAttribute("type", nil)
						frame:SetAttribute("spell", nil)
					end
				end
			end
		end
	end)
end

KUI:RegisterModule(KRR:GetName())