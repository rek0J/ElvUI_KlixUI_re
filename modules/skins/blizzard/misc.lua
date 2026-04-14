local KUI, T, E, L, V, P, G = unpack(select(2, ...))
local KS = KUI:GetModule('KuiSkins')
local S = E:GetModule('Skins')

-- Cache global variables
-- Lua functions
local _G = _G
local getn = getn
local next, pairs = next, pairs
local tinsert = table.insert
-- WoW API
local hooksecurefunc = hooksecurefunc
local IsAddOnLoaded = IsAddOnLoaded
local WorldStateAlwaysUpFrame = _G["WorldStateAlwaysUpFrame"]
-- GLOBALS: hooksecurefunc, NUM_ALWAYS_UP_UI_FRAMES

local MAX_STATIC_POPUPS = 4

local function SafeStyle(frame)
	if not frame or (frame.IsForbidden and frame:IsForbidden()) then return end
	if frame.Styling then
		frame:Styling()
	end
end

local function styleMisc()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.misc ~= true then return end

	local GameMenuFrame = _G.GameMenuFrame
	if GameMenuFrame and not (GameMenuFrame.IsForbidden and GameMenuFrame:IsForbidden()) then
		SafeStyle(GameMenuFrame)

		-- GameMenu Header Color
		for i = 1, GameMenuFrame:GetNumRegions() do
			local Region = T.select(i, GameMenuFrame:GetRegions())
			if Region.IsObjectType and Region:IsObjectType('FontString') then
				Region:SetTextColor(1, 1, 1)
			end
		end
	end
	
	-- Graveyard button (a bit ugly if you press it)
	local GhostFrame = _G.GhostFrame
	local GhostFrameContentsFrame = _G.GhostFrameContentsFrame
	if GhostFrame and not (GhostFrame.IsForbidden and GhostFrame:IsForbidden()) then
		GhostFrame:StripTextures()
		if GhostFrameContentsFrame and not (GhostFrameContentsFrame.IsForbidden and GhostFrameContentsFrame:IsForbidden()) then
			GhostFrameContentsFrame:StripTextures()
		end
		GhostFrame:CreateBackdrop("Transparent")
		SafeStyle(GhostFrame.backdrop)
	end

	-- Tooltips
	local tooltips = {
		GameTooltip,
		FriendsTooltip,
		ItemRefTooltip,
		ItemRefShoppingTooltip1,
		ItemRefShoppingTooltip2,
		ItemRefShoppingTooltip3,
		AutoCompleteBox,
		ShoppingTooltip1,
		ShoppingTooltip2,
		ShoppingTooltip3,
		FloatingBattlePetTooltip,
		FloatingPetBattleAbilityTooltip,
		FloatingGarrisonFollowerTooltip,
		FloatingGarrisonFollowerAbilityTooltip,
		PetBattlePrimaryUnitTooltip,
		PetBattlePrimaryAbilityTooltip,
		EventTraceTooltip,
		FrameStackTooltip,
		QuestScrollFrame.WarCampaignTooltip,
		QuestScrollFrame.StoryTooltip,
		DatatextTooltip
	}

	for _, frame in T.pairs(tooltips) do
		if frame and not frame.style then
			SafeStyle(frame)
		end
	end

	local skins = {
		"StaticPopup1",
		"StaticPopup2",
		"StaticPopup3",
		"StaticPopup4",
		"InterfaceOptionsFrame",
		"VideoOptionsFrame",
		"AudioOptionsFrame",
		"AutoCompleteBox",
		"ReadyCheckFrame",
		"StackSplitFrame",
		"QueueStatusFrame",
		"LFDReadyCheckPopup",
		"LFDRoleCheckPopup",
	}

	for i = 1, T.table_getn(skins) do
		if _G[skins[i]] then
			SafeStyle(_G[skins[i]])
		end
	end -- MoP Classic: Only style if frame exists
	
	-- ElvUI StaticPopups
	for i = 1, MAX_STATIC_POPUPS do
		local frame = _G["ElvUI_StaticPopup"..i]
		SafeStyle(frame)
	end
	
	-- Default Bags
	local defaultBags = {
		ContainerFrame1.backdrop,
		ContainerFrame2.backdrop,
		ContainerFrame3.backdrop,
		ContainerFrame4.backdrop,
		ContainerFrame5.backdrop,
	}

	for _, frame in T.pairs(defaultBags) do
		if frame and not frame.style then
			SafeStyle(frame)
		end
	end
	
	--DropDownMenu
	hooksecurefunc("UIDropDownMenu_CreateFrames", function(level, index)
		local listFrame = _G["DropDownList"..level]
		if not listFrame then return end
		local listFrameName = listFrame:GetName()

		local Backdrop = _G[listFrameName.."Backdrop"]
		if Backdrop and not Backdrop.IsSkinned then
			SafeStyle(Backdrop)
			Backdrop.IsSkinned = true
		end

		local menuBackdrop = _G[listFrameName.."MenuBackdrop"]
		if menuBackdrop and not menuBackdrop.IsSkinned then
			if menuBackdrop.backdrop then
				SafeStyle(menuBackdrop.backdrop)
			else
				SafeStyle(menuBackdrop)
			end
			menuBackdrop.IsSkinned = true
		end
	end)
	
	--DropDownMenu library support
	if _G.LibStub("LibUIDropDownMenu", true) then
		if _G.L_DropDownList1Backdrop then
			SafeStyle(_G.L_DropDownList1Backdrop)
		end
		if _G.L_DropDownList1MenuBackdrop then
			SafeStyle(_G.L_DropDownList1MenuBackdrop)
		end
		hooksecurefunc("L_UIDropDownMenu_CreateFrames", function()
			local backdrop = _G["L_DropDownList".._G.L_UIDROPDOWNMENU_MAXLEVELS.."Backdrop"]
			local menuBackdrop = _G["L_DropDownList".._G.L_UIDROPDOWNMENU_MAXLEVELS.."MenuBackdrop"]
			if backdrop and not backdrop.template then
				SafeStyle(backdrop)
			end
			if menuBackdrop and not menuBackdrop.template then
				SafeStyle(menuBackdrop)
			end
		end)
	end

	if _G.CopyChatFrame then
		SafeStyle(_G.CopyChatFrame)
	end

	for i = 1, MAX_STATIC_POPUPS do
		local frame = _G["ElvUI_StaticPopup"..i]
		SafeStyle(frame)
	end

	local TalentMicroButtonAlert = _G.TalentMicroButtonAlert
	if TalentMicroButtonAlert then
		SafeStyle(TalentMicroButtonAlert)
	end
	
	if _G.ScriptErrorsFrame then
		SafeStyle(_G.ScriptErrorsFrame)
	end
	
	if _G.GearManagerDialogPopup then
		SafeStyle(_G.GearManagerDialogPopup)
	end
	
	-- ElvUI Stuff
	SafeStyle(_G.LeftChatDataPanel)
	SafeStyle(_G.RightChatDataPanel)
	SafeStyle(_G.ElvUI_TopPanel)
	SafeStyle(_G.ElvUI_BottomPanel)
	
	SafeStyle(_G.MirrorTimer1StatusBar and _G.MirrorTimer1StatusBar.backdrop)
	SafeStyle(_G.MirrorTimer2StatusBar and _G.MirrorTimer2StatusBar.backdrop)
	SafeStyle(_G.MirrorTimer3StatusBar and _G.MirrorTimer3StatusBar.backdrop)
	
	SafeStyle(_G.ElvUIVendorGraysFrame and _G.ElvUIVendorGraysFrame.backdrop)
	
	if _G.SplashFrame then
		SafeStyle(_G.SplashFrame)
	end -- MoP Classic: only style if SplashFrame exists

	SafeStyle(_G.ChatConfigFrame)
	
	if _G.RaidUtilityPanel then
		SafeStyle(_G.RaidUtilityPanel)
	end
	
	if _G.ChatMenu then
		SafeStyle(_G.ChatMenu)
	end

	if _G.EmoteMenu then
		SafeStyle(_G.EmoteMenu)
	end

	if _G.LanguageMenu then
		SafeStyle(_G.LanguageMenu)
	end

	if _G.VoiceMacroMenu then
		SafeStyle(_G.VoiceMacroMenu)
	end
	
	if _G.ElvUI_AltPowerBar then
		SafeStyle(_G.ElvUI_AltPowerBar.backdrop)
	end
	
	if E:SpawnTutorialFrame() then
		SafeStyle(_G.ElvUITutorialWindow)
	end
	
	if _G.ElvLootFrame then
		SafeStyle(_G.ElvLootFrame)
	end
	
	if _G.ColorPickerFrame then
		SafeStyle(_G.ColorPickerFrame)
	end

	-- DataStore
	if IsAddOnLoaded("DataStore") then
		local frame = _G.DataStoreFrame
		if frame then
			SafeStyle(frame)
		end
	end
end

S:AddCallback("KuiBlizzMisc", styleMisc)
