local KUI, T, E, L, V, P, G = unpack(select(2, ...))
local KAB = KUI:NewModule('KUIActionbars', 'AceEvent-3.0', "AceHook-3.0", "AceBucket-3.0")
local LAB = LibStub("LibActionButton-1.0-ElvUI")
local LCG = LibStub('LibCustomGlow-1.0')

if E.private.actionbar.enable ~= true then return; end

local ActiveButtons = LAB.activeButtons
local OverlayedSpellID = {
    ["ROGUE"] = {5171, 193316, 199804, 2098, 1943, 32645, 408, 196819, 195452, 206237, 26679},
    ["DRUID"] = {52610, 1079, 22568, 22570},
}

local HearthStoneList = {
	54452,		-- Ethereal Portal
	64488,		-- The Innkeeper's Daughter
	93672,		-- Dark Portal
	142542,		-- Tome of Town Portal
	162973,		-- Greatfather Winter's Hearthstone
	163045,		-- Headless Horseman's Hearthstone
	165669,		-- Lunar Elder's Hearthstone
	165670,		-- Peddlefeet's Lovely Hearthstone
	165802,		-- Noble Gardener"s Hearthstone
	166746, 	-- Fire Eater"s Hearthstone
	166747, 	-- Brewfest Reveler"s Hearthstone
	168907, 	-- Holographic Digitalization Hearthstone
	172179, 	-- Eternal Traveler's HS
}

function KAB:ABStyling()
	-- Buttons
	local db = E.db.KlixUI.actionbars
	for i = 1, 10 do
		for k = 1, 12 do
			local buttonBars = {_G["ElvUI_Bar"..i.."Button"..k]}
			for _, button in T.pairs(buttonBars) do
				button:CreateIconShadow()
			end
		end
	end

	-- Pet Buttons
	for i = 1, NUM_PET_ACTION_SLOTS do
		local petButtons = {_G['PetActionButton'..i]}
		for _, button in T.pairs(petButtons) do
			button:CreateIconShadow()
		end
	end
	
	-- Stance Buttons
	for i = 1, (NUM_STANCE_SLOTS or 0) do
		local stanceButtons = {_G["ElvUI_StanceBarButton"..i]}
		for _, button in T.pairs(stanceButtons) do
			button:CreateIconShadow()
		end
	end
	
end

function KAB:StyleBackdrops()
	-- Actionbar backdrops
	for i = 1, 10 do
		local styleBacks = {_G['ElvUI_Bar'..i]}
		for _, frame in T.pairs(styleBacks) do
			if frame and frame.backdrop then
				frame.backdrop:Styling()
			end
		end
	end

	-- Other bar backdrops
	local styleOtherBacks = {_G.ElvUI_BarPet, _G.ElvUI_StanceBar}
	for _, frame in T.pairs(styleOtherBacks) do
		if frame and frame.backdrop then
			frame.backdrop:Styling()
		end
	end
	
	-- Pet Buttons
	for i = 1, _G.NUM_PET_ACTION_SLOTS do
		local petButtons = {_G['PetActionButton'..i]}
		for _, button in T.pairs(petButtons) do
			if button then
				button:Styling()
			end
		end
	end
end

-- Glow
function KAB:SpellActivationGlow()
	if not E.db.KlixUI.actionbars.glow.enable or T.IsAddOnLoaded("CoolGlow") then return end
	T.C_Timer_After(0,function()
		if LibStub then
			local lib = LibStub:GetLibrary("LibButtonGlow-1.0",4)
			if lib then
				-- NOTE: replaces LibButtonGlow-1.0 globally — affects all addons using it (DBM, BigWigs etc.)
				-- Only active when KlixUI glow is enabled and CoolGlow is absent.
				function lib.HideOverlayGlow(button)
					LCG.PixelGlow_Stop(button)
				end
				function lib.ShowOverlayGlow(button)
					if button:GetAttribute("type") == "action" then
						local actionType,actionID = T.GetActionInfo(button:GetAttribute("action"))
						local color = {E.db.KlixUI.actionbars.glow.color.r, E.db.KlixUI.actionbars.glow.color.g, E.db.KlixUI.actionbars.glow.color.b, E.db.KlixUI.actionbars.glow.color.a or 1}
						LCG.PixelGlow_Start(button, color, E.db.KlixUI.actionbars.glow.number, E.db.KlixUI.actionbars.glow.frequency, E.db.KlixUI.actionbars.glow.length, E.db.KlixUI.actionbars.glow.thickness, E.db.KlixUI.actionbars.glow.xOffset, E.db.KlixUI.actionbars.glow.yOffset, nil)
					end
				end
			end
		end
	end)
end

-- Finishing Move Glow!
local function ShowOverlayGlow(self)
	local color = {E.db.KlixUI.actionbars.glow.color.r, E.db.KlixUI.actionbars.glow.color.g, E.db.KlixUI.actionbars.glow.color.b, E.db.KlixUI.actionbars.glow.color.a or 1}
    LCG.PixelGlow_Start(self, color, E.db.KlixUI.actionbars.glow.number, E.db.KlixUI.actionbars.glow.frequency, E.db.KlixUI.actionbars.glow.length, E.db.KlixUI.actionbars.glow.thickness, E.db.KlixUI.actionbars.glow.xOffset, E.db.KlixUI.actionbars.glow.yOffset, nil)
end

local function HideOverlayGlow(self)
    LCG.PixelGlow_Stop(self)
end

local function IsOverlayedSpell(spellID)
    local _, class = T.UnitClass("player")
    if (not OverlayedSpellID[class]) then return false end
    local points = T.UnitPower("player", Enum.PowerType.ComboPoints)
    local maxPoints = T.UnitPowerMax("player", Enum.PowerType.ComboPoints)
    for i = 1, #OverlayedSpellID[class] do
        if spellID == OverlayedSpellID[class][i] and points == maxPoints then
            return true
        end
    end
    return false
end

local function UpdateOverlayGlow(self)
    local spellId = self:GetSpellId()
    local isOverlayed = spellId and IsOverlayedSpell(spellId)
    if not isOverlayed and spellId and T.IsSpellOverlayed then
        isOverlayed = T.IsSpellOverlayed(spellId)
    end

    if isOverlayed then
        ShowOverlayGlow(self)
    else
        HideOverlayGlow(self)
    end
end

function KAB:OnEvent()
    if ElvUI and E.db.KlixUI.actionbars.glow.enable and E.db.KlixUI.actionbars.glow.finishMove and not T.IsAddOnLoaded("CoolGlow") then
        for button in T.next, ActiveButtons do
            UpdateOverlayGlow(button)
        end
    end
end

-- Random Hearthstone
local HearthStoneListChecked = {}
local HearthStoneName = {}
local PlayerHasToy = T.PlayerHasToy or _G.PlayerHasToy
local DefaultHearthstone = "item:6948"
local TableWipe = T.wipe or _G.wipe or function(tbl)
	for key in T.pairs(tbl) do
		tbl[key] = nil
	end
end
local HearthStoneToUse = DefaultHearthstone
local RandomHearthStone

local function GetDefaultHearthstone()
	return DefaultHearthstone
end

local function HearthStoneToUse_UpdateList()
	TableWipe(HearthStoneListChecked)
	TableWipe(HearthStoneName)

	if not PlayerHasToy then return end

	for k, v in T.ipairs(HearthStoneList) do
		if PlayerHasToy(v) then
			T.table_insert(HearthStoneName, "item:"..v)
		end
	end
end

local function HearthStoneToUse_Random(frame)
	local itemToUse = GetDefaultHearthstone()

	if #HearthStoneName >= 1 then
		itemToUse = HearthStoneName[T.random(#HearthStoneName)]
	end

	if not T.InCombatLockdown() then
		HearthStoneToUse = itemToUse
		frame:SetAttribute("macrotext", "/use "..itemToUse)
		frame.NeedToRandom = false
	else
		frame.NeedToRandom = true
	end
end

function KAB:Macro_Refresh()
	local name = T.GetMacroInfo("KuiRHS")
	local HSNAME = GetDefaultHearthstone()
	if (not HSNAME) or (T.InCombatLockdown()) then return end
	if not name then
		local gNum, pNum = T.GetNumMacros()
		if (gNum == 72) then return end
		local macroId = T.CreateMacro("KuiRHS", "inv_misc_rune_01", 
		"#showtooltip "..HSNAME..[[

]]..[[
/rhs check
/click RandomHearthStone]],
		nil, 1)
		KUI:Print("A random hearthstone macro has been created, move it to your actionbar.")
		T.PickupMacro("KuiRHS")
	else
		local macroID = T.EditMacro("KuiRHS", "KuiRHS", "inv_misc_rune_01", 
		"#showtooltip "..HSNAME..[[

]]..[[
/rhs check
/click RandomHearthStone]])
		KUI:Print("A random hearthstone macro has been created, move it to your actionbar.")
		T.PickupMacro("KuiRHS")
	end
end

RandomHearthStone = T.CreateFrame("Button", "RandomHearthStone", E.UIParent, "SecureActionButtonTemplate")
RandomHearthStone:SetSize(1, 1)
RandomHearthStone:SetPoint("TOPLEFT", E.UIParent, "TOPLEFT", -100, -100)
RandomHearthStone:EnableMouse(true)
RandomHearthStone:Show()
RandomHearthStone:RegisterForClicks("AnyUp", "AnyDown")
-- FIX [T1]: SetAttribute mit InCombatLockdown() absichern.
-- Bei /reload im Kampf wuerden diese globalen Aufrufe Taint ausloesen.
-- NeedToRandom = true signalisiert dem PLAYER_REGEN_ENABLED-Handler,
-- dass "type" und "macrotext" noch nachgesetzt werden muessen.
if not InCombatLockdown() then
	RandomHearthStone:SetAttribute("type", "macro")
	RandomHearthStone:SetAttribute("macrotext", "/use "..HearthStoneToUse)
	RandomHearthStone.NeedToRandom = false
else
	RandomHearthStone.NeedToRandom = true
end

RandomHearthStone:RegisterEvent("PLAYER_ENTERING_WORLD")
RandomHearthStone:RegisterEvent("PLAYER_REGEN_ENABLED")
RandomHearthStone:SetScript("OnEvent", function(self, event)
	if event == "PLAYER_ENTERING_WORLD" then
		if not RandomHearthstone_DB then
			RandomHearthstone_DB = {}
			RandomHearthstone_DB.Version = 1 
		end
		if RandomHearthstone_DB.Version < 1 then
			KAB:Macro_Refresh()
		end
		
		HearthStoneToUse_UpdateList()
		HearthStoneToUse_Random(RandomHearthStone)
		T.C_Timer_After(5, function(self2)
			HearthStoneToUse_UpdateList()
			HearthStoneToUse_Random(RandomHearthStone)
		end)
	end
	if event == "PLAYER_REGEN_ENABLED" then
		if self.NeedToRandom == true then
			-- FIX [T1]: "type"-Attribut auch bei verzoegerter Initialisierung (Reload im Kampf) setzen.
			self:SetAttribute("type", "macro")
			HearthStoneToUse_UpdateList()
			HearthStoneToUse_Random(RandomHearthStone)
		end
	end
end)

local function DeleteHearthstone()
	if not E.db.KlixUI.actionbars.hearthstone.delete then return end
	
	for bag = 0,4 do
		for slot = 1, 32 do
			local itemID = T.GetContainerItemID(bag,slot)
			if itemID == 6948 then
				T.PickupContainerItem(bag,slot)
				T.DeleteCursorItem()
				KUI:Print("Hearthstone deleted!")
			end
		end
	end
end

function KAB:Initialize()
	T.C_Timer_After(1, KAB.ABStyling)
	T.C_Timer_After(1, KAB.StyleBackdrops)
	if T.IsAddOnLoaded('ElvUI_TB') then T.DisableAddOn('ElvUI_TB') end
	
	
	KAB:SpellActivationGlow()
	
	KAB:RegisterEvent("UNIT_POWER_UPDATE", "OnEvent")
    KAB:RegisterEvent("PLAYER_TARGET_CHANGED", "OnEvent")
	KAB:RegisterBucketEvent("BAG_UPDATE", 0.2, DeleteHearthstone)
	
	SlashCmdList["RHS"] = function(msg)
		if msg == "check" then
			HearthStoneToUse_UpdateList()
			HearthStoneToUse_Random(RandomHearthStone)
			KUI:Print("Random Hearthstone:", HearthStoneToUse)
		else
			self:Macro_Refresh()
		end
	end
	SLASH_RHS1 = "/rhs"
end

KUI:RegisterModule(KAB:GetName())
