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
		-- Legion
		188034,			-- Flask of the Countless Armies (59 str)
		188035,			-- Flask of the Thousand Scars (88 sta)
		188033,			-- Flask of the Seventh Demon (59 agi)
		188031,			-- Flask of the Whispered Pact (59 int)
		242551,			-- Fel Focus Str, Agi and Int +23, stam + 34

		-- Battle for Azeroth 
		251836,			-- Flask of the Currents (238 agi)
		251837,			-- Flask of Endless Fathoms (238 int)
		251838,			-- Flask of the Vast Horizon (357 sta)
		251839,			-- Flask of the Undertow (238 str)
		298836,			-- Greater Flask of the Currents
		298837,			-- Greater Flask of Endless Fathoms
		298839,			-- Greater Flask of the Vast Horizon
		298841,			-- Greater Flask of the Undertow

		-- Shadowlands
		307166,			-- Eternal FLask (190 stat)
		307185,			-- Spectral Flask of Power (73 stat)
		307187,			-- Spectral Flask of Stamina (109 sta)
	},
	DefiledAugmentRune = {
		224001,			-- Defiled Augumentation (15 primary stat)
		270058,			-- Battle Scarred Augmentation (60 primary stat)
	},
	Food = {
		104280,	-- Well Fed

		-- Shadowlands
		259455,	-- Well Fed
		308434,	-- Well Fed
		308488,	-- Well Fed
		308506,	-- Well Fed
		308514,	-- Well Fed
		308637,	-- Well Fed
		327715,	-- Well Fed
		327851,	-- Well Fed
	},
	Intellect = {
		264760, -- War-Scroll of Intellect
		1459, -- Arcane Intellect
	},
	Stamina = {
		6307, -- Blood Pact
		264764, -- War-Scroll of Fortitude
		21562, -- Power Word: Fortitude
	},
	AttackPower = {
		264761, -- War-Scroll of Battle
		6673, -- Battle Shout
	},
}

local flaskbuffs = KRR.ReminderBuffs["Flask"]
local foodbuffs = KRR.ReminderBuffs["Food"]
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
	if not (buffList and buffList[1]) then return end
	frame.t:SetTexture(SpellIcon(buffList[1]))
	for _, spellID in T.pairs(buffList) do
		if PlayerHasAura(spellID) then
			ApplyBuffState(frame, spellID, true)
			return
		end
	end
	ApplyBuffState(frame, buffList[1], false)
end

local function OnAuraChange(self, event, arg1, unit)
	if (event == "UNIT_AURA" and arg1 ~= "player") then return end

	CheckBuffList(FlaskFrame,       flaskbuffs)
	CheckBuffList(FoodFrame,        foodbuffs)
	CheckBuffList(DARuneFrame,      darunebuffs)

	if KRR.db.class then
		CheckBuffList(IntellectFrame,   intellectbuffs)
		CheckBuffList(StaminaFrame,     staminabuffs)
		CheckBuffList(AttackPowerFrame, attackpowerbuffs)
	end
end

function KRR:CreateIconBuff(name, relativeTo, firstbutton)
	local button = T.CreateFrame("Frame", name, KRR.frame)
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
	
	if KRR.db.class then
		self.frame:SetSize((KRR.db.size * 6) + 28, KRR.db.size + 8) -- Backdrop + size (still needs some adjustments, LOL :P)
		self:CreateIconBuff("IntellectFrame", RaidBuffReminder, true)
		self:CreateIconBuff("StaminaFrame", IntellectFrame, false)
		self:CreateIconBuff("AttackPowerFrame", StaminaFrame, false)
		self:CreateIconBuff("FlaskFrame", AttackPowerFrame, false)
		self:CreateIconBuff("FoodFrame", FlaskFrame, false)
		self:CreateIconBuff("DARuneFrame", FoodFrame, false)
	else
		self.frame:SetSize((KRR.db.size * 3) + 16, KRR.db.size + 8) -- Backdrop + size (still needs some adjustments, LOL :P)
		self:CreateIconBuff("FlaskFrame", RaidBuffReminder, true)
		self:CreateIconBuff("FoodFrame", FlaskFrame, false)
		self:CreateIconBuff("DARuneFrame", FoodFrame, false)
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
	self.frame:SetScript("OnEvent", OnAuraChange)

	E:CreateMover(self.frame, "KUI_RaidBuffReminderMover", L["Raid Buffs Reminder"], nil, nil, nil, "ALL,SOLO,PARTY,RAID,KLIXUI", nil, "KlixUI,modules,reminder")

	function KRR:ForUpdateAll()
		KRR.db = E.db.KlixUI.reminder.raid
		self:Backdrop()
		self:Visibility()
	end

	self:ForUpdateAll()
end

KUI:RegisterModule(KRR:GetName())