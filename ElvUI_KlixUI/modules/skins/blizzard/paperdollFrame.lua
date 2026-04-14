local KUI, T, E, L, V, P, G = unpack(select(2, ...))
local KS = KUI:GetModule('KuiSkins')
local S = E:GetModule('Skins')
local C_SpecializationInfo = _G.C_SpecializationInfo

local r, g, b = T.unpack(E["media"].rgbvaluecolor)
local GetSpecialization = T.GetSpecialization or (C_SpecializationInfo and C_SpecializationInfo.GetSpecialization)
local GetSpecializationInfo = T.GetSpecializationInfo or (C_SpecializationInfo and C_SpecializationInfo.GetSpecializationInfo)
local GetSpecializationRole = T.GetSpecializationRole or _G.GetSpecializationRole or (C_SpecializationInfo and C_SpecializationInfo.GetSpecializationRole)

local function styleCPaperDollFrame()
	if E.Mists then return end
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.character ~= true or E.private.KlixUI.skins.blizzard.character ~= true then return end

	local CharacterStatsPane = _G.CharacterStatsPane

	--_G.CharacterModelFrame:DisableDrawLayer("BACKGROUND")
	--_G.CharacterModelFrame:DisableDrawLayer("BORDER")
	--_G.CharacterModelFrame:DisableDrawLayer("OVERLAY")

	local slots = {
		"Head", "Neck", "Shoulder", "Shirt", "Chest", "Waist", "Legs", "Feet", "Wrist",
		"Hands", "Finger0", "Finger1", "Trinket0", "Trinket1", "Back", "MainHand",
		"SecondaryHand", "Tabard",
	}

	for i = 1, #slots do
		local slot = _G["Character"..slots[i].."Slot"]
		local border = slot.IconBorder

		_G["Character"..slots[i].."SlotFrame"]:Hide()
		
		slot:CreateIconShadow()
		
		slot:SetNormalTexture("")
		slot:SetPushedTexture("")
		slot:GetHighlightTexture():SetColorTexture(r, g, b, .25)
		slot.SetHighlightTexture = KUI.dummy
		slot.icon:SetTexCoord(T.unpack(E.TexCoords))

		border:Point("TOPLEFT", -1, 1)
		border:Point("BOTTOMRIGHT", 1, -1)
		border:SetDrawLayer("BACKGROUND")
		KS:CreateBDFrame(slot, .25)
	end

	local function StatsPane(type)
	_G.CharacterStatsPane[type]:StripTextures()
	_G.CharacterStatsPane[type].backdrop:Hide()
	end

	local function CharacterStatFrameCategoryTemplate(frame)
		frame:StripTextures()

		local bg = frame.Background
		bg:SetTexture([[Interface\LFGFrame\UI-LFG-SEPARATOR]])
		bg:SetTexCoord(0, 0.6640625, 0, 0.3125)
		bg:ClearAllPoints()
		bg:Point("CENTER", 0, -5)
		bg:Size(210, 30)
		bg:SetVertexColor(r, g, b, 0.5)
	end

	if not T.IsAddOnLoaded("DejaCharacterStats") then
		   if CharacterStatsPane.ItemLevelCategory then
			   if CharacterStatsPane.ItemLevelCategory.Title then
				   CharacterStatsPane.ItemLevelCategory.Title:SetTextColor(T.unpack(E["media"].rgbvaluecolor))
			   end
			   StatsPane("ItemLevelCategory")
			   CharacterStatFrameCategoryTemplate(CharacterStatsPane.ItemLevelCategory)
		   end
		   if CharacterStatsPane.AttributesCategory then
			   if CharacterStatsPane.AttributesCategory.Title then
				   CharacterStatsPane.AttributesCategory.Title:SetTextColor(T.unpack(E["media"].rgbvaluecolor))
			   end
			   StatsPane("AttributesCategory")
			   CharacterStatFrameCategoryTemplate(CharacterStatsPane.AttributesCategory)
		   end
		   if CharacterStatsPane.EnhancementsCategory then
			   if CharacterStatsPane.EnhancementsCategory.Title then
				   CharacterStatsPane.EnhancementsCategory.Title:SetTextColor(T.unpack(E["media"].rgbvaluecolor))
			   end
			   StatsPane("EnhancementsCategory")
			   CharacterStatFrameCategoryTemplate(CharacterStatsPane.EnhancementsCategory)
		   end


		-- Copied from ElvUI
		local function ColorizeStatPane(frame)
			if frame.leftGrad then frame.leftGrad:StripTextures() end
			if frame.rightGrad then frame.rightGrad:StripTextures() end

			frame.leftGrad = frame:CreateTexture(nil, "BORDER")
			frame.leftGrad:Width(80)
			frame.leftGrad:Height(frame:GetHeight())
			frame.leftGrad:Point("LEFT", frame, "CENTER")
			frame.leftGrad:SetTexture(E.media.blankTex)
			frame.leftGrad:SetGradientAlpha("Horizontal", r, g, b, 0.5, r, g, b, 0)

			frame.rightGrad = frame:CreateTexture(nil, "BORDER")
			frame.rightGrad:Width(80)
			frame.rightGrad:Height(frame:GetHeight())
			frame.rightGrad:Point("RIGHT", frame, "CENTER")
			frame.rightGrad:SetTexture(E.media.blankTex)
			frame.rightGrad:SetGradientAlpha("Horizontal", r, g, b, 0, r, g, b, 0.5)
		end

			   if CharacterStatsPane.ItemLevelFrame and CharacterStatsPane.ItemLevelFrame.Background then
				   CharacterStatsPane.ItemLevelFrame.Background:SetAlpha(0)
				   ColorizeStatPane(CharacterStatsPane.ItemLevelFrame)
			   end


		hooksecurefunc("PaperDollFrame_UpdateStats", function()
			local level = T.UnitLevel("player")
			local categoryYOffset = -5
			local statYOffset = 0

			if not T.IsAddOnLoaded("DejaCharacterStats") and CharacterStatsPane.ItemLevelCategory then
				   if ( level >= MIN_PLAYER_LEVEL_FOR_ITEM_LEVEL_DISPLAY ) then
					   if CharacterStatsPane.ItemLevelFrame then
						   T.PaperDollFrame_SetItemLevel(CharacterStatsPane.ItemLevelFrame, "player")
						   if CharacterStatsPane.ItemLevelFrame.Value then
							   CharacterStatsPane.ItemLevelFrame.Value:SetTextColor(T.GetItemLevelColor())
						   end
						   CharacterStatsPane.ItemLevelFrame:Show()
					   end
					   CharacterStatsPane.ItemLevelCategory:Show()
					   if CharacterStatsPane.AttributesCategory then
						   CharacterStatsPane.AttributesCategory:Point("TOP", 0, -76)
					   end
				   else
					   CharacterStatsPane.ItemLevelCategory:Hide()
					   if CharacterStatsPane.ItemLevelFrame then
						   CharacterStatsPane.ItemLevelFrame:Hide()
					   end
					   if CharacterStatsPane.AttributesCategory then
						   CharacterStatsPane.AttributesCategory:Point("TOP", 0, -20)
					   end
					   categoryYOffset = -12
					   statYOffset = -6
				   end
			end

			if not CharacterStatsPane.statsFramePool then return end

			local spec = GetSpecialization and GetSpecialization() or nil
			local role = GetSpecializationRole and spec and GetSpecializationRole(spec) or nil

			CharacterStatsPane.statsFramePool:ReleaseAll()
			-- we need a stat frame to first do the math to know if we need to show the stat frame
			-- so effectively we'll always pre-allocate
			local statFrame = CharacterStatsPane.statsFramePool:Acquire()

			local lastAnchor

			for catIndex = 1, #PAPERDOLL_STATCATEGORIES do
				local catFrame = CharacterStatsPane[PAPERDOLL_STATCATEGORIES[catIndex].categoryFrame]
				if catFrame then
					local numStatInCat = 0
					for statIndex = 1, #PAPERDOLL_STATCATEGORIES[catIndex].stats do
						local stat = PAPERDOLL_STATCATEGORIES[catIndex].stats[statIndex]
						local showStat = true
						if ( showStat and stat.primary ) then
							local primaryStat
							if GetSpecializationInfo and spec then
								primaryStat = T.select(6, GetSpecializationInfo(spec, nil, nil, nil, T.UnitSex("player")))
							end

							if primaryStat and ( stat.primary ~= primaryStat ) then
								showStat = false
							end
						end
						if ( showStat and stat.roles ) then
							local foundRole = false
							for _, statRole in T.pairs(stat.roles) do
								if ( role == statRole ) then
									foundRole = true
									break
								end
							end
							showStat = foundRole
						end
						if ( showStat ) then
							statFrame.onEnterFunc = nil
							PAPERDOLL_STATINFO[stat.stat].updateFunc(statFrame, "player")
							if ( not stat.hideAt or stat.hideAt ~= statFrame.numericValue ) then
								if ( numStatInCat == 0 ) then
									if ( lastAnchor ) then
										catFrame:Point("TOP", lastAnchor, "BOTTOM", 0, categoryYOffset)
									end
									statFrame:Point("TOP", catFrame, "BOTTOM", 0, -2)
								else
									statFrame:Point("TOP", lastAnchor, "BOTTOM", 0, statYOffset)
								end
								numStatInCat = numStatInCat + 1
								statFrame.Background:SetShown(false)
								ColorizeStatPane(statFrame)
								statFrame.leftGrad:SetShown((numStatInCat % 2) == 0)
								statFrame.rightGrad:SetShown((numStatInCat % 2) == 0)
								lastAnchor = statFrame
								-- done with this stat frame, get the next one
								statFrame = CharacterStatsPane.statsFramePool:Acquire()
							end
						end
					end
					catFrame:SetShown(numStatInCat > 0)
				end
			end
			-- release the current stat frame
			CharacterStatsPane.statsFramePool:Release(statFrame)
		end)
	end
	
	if T.IsAddOnLoaded("ElvUI_SLE") or E.db.KlixUI.armory.enable then
		_G.PaperDollFrame:HookScript("OnShow", function()
			if CharacterStatsPane.DefenceCategory then
				CharacterStatsPane.DefenceCategory.Title:SetTextColor(T.unpack(E["media"].rgbvaluecolor))
				StatsPane("DefenceCategory")
				CharacterStatFrameCategoryTemplate(CharacterStatsPane.DefenceCategory)
			end
			if CharacterStatsPane.OffenseCategory then
				CharacterStatsPane.OffenseCategory.Title:SetTextColor(T.unpack(E["media"].rgbvaluecolor))
				StatsPane("OffenseCategory")
				CharacterStatFrameCategoryTemplate(CharacterStatsPane.OffenseCategory)
			end
		end)
	end

	-- CharacterFrame Class Texture
	if not ClassTexture and E.db.KlixUI.armory.classCrests then
		ClassTexture = _G.CharacterFrameInsetRight:CreateTexture(nil, "BORDER")
		ClassTexture:Point("BOTTOM", _G.CharacterFrameInsetRight, "BOTTOM", 0, 40)
		ClassTexture:Size(126, 120)
		ClassTexture:SetAlpha(.45)
		ClassTexture:SetTexture("Interface\\AddOns\\ElvUI_KlixUI\\media\\textures\\classIcons\\CLASS-"..E.myclass)
		ClassTexture:SetDesaturated(true)
	end
	
	-- Flyoutbuttons shadow
	local function UpdateFlyoutButtons(button)
		button:CreateIconShadow()
	end
	hooksecurefunc("EquipmentFlyout_DisplayButton", UpdateFlyoutButtons)
end

S:AddCallback("KuiPaperDoll", styleCPaperDollFrame)
