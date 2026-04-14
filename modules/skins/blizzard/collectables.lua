local KUI, T, E, L, V, P, G = unpack(select(2, ...))
local KS = KUI:GetModule('KuiSkins')
local S = E:GetModule('Skins')

TransmogSlots = {
  "BackSlot",          -- Back (cloak) slot
  "ChestSlot",         -- Chest slot
  "FeetSlot",          -- Feet (boots) slot
  "HandsSlot",         -- Hand (gloves) slot
  "HeadSlot",          -- Head (helmet) slot
  "LegsSlot",          -- Legs (pants) slot
  "MainHandSlot",      -- Main hand weapon slot
  "SecondaryHandSlot", -- Off-hand (weapon, shield, or held item) slot
  "ShirtSlot",         -- Shirt slot
  "ShoulderSlot",      -- Shoulder slot
  "TabardSlot",        -- Tabard slot
  "WaistSlot",         -- Waist (belt) slot
  "WristSlot"          -- Wrist (bracers) slot
}

local r, g, b = T.unpack(E["media"].rgbvaluecolor)

local function GetJournalButtons(frame)
	if not frame then return end

	local scrollFrame = frame.ListScrollFrame or frame.listScroll
	return scrollFrame and scrollFrame.buttons
end

local function StyleJournalActionButton(button, border, icon)
	if border then
		border:Hide()
	end

	if icon then
		icon:SetTexCoord(unpack(E.TexCoords))
	end

	if button then
		button:SetPushedTexture("")
		local highlight = button:GetHighlightTexture()
		if highlight then
			highlight:SetColorTexture(1, 1, 1, .25)
		end
	end
end

local function styleCollections()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.collections ~= true or E.private.KlixUI.skins.blizzard.collections ~= true then return end

	local CollectionsJournal = _G.CollectionsJournal
	if not CollectionsJournal then return end
	CollectionsJournal:Styling()

	if _G.CollectionsJournalTab1 and _G.CollectionsJournalTab2 then
		_G.CollectionsJournalTab2:SetPoint("LEFT", _G.CollectionsJournalTab1, "RIGHT", -15, 0)
	end
	if _G.CollectionsJournalTab2 and _G.CollectionsJournalTab3 then
		_G.CollectionsJournalTab3:SetPoint("LEFT", _G.CollectionsJournalTab2, "RIGHT", -15, 0)
	end
	if _G.CollectionsJournalTab3 and _G.CollectionsJournalTab4 then
		_G.CollectionsJournalTab4:SetPoint("LEFT", _G.CollectionsJournalTab3, "RIGHT", -15, 0)
	end
	if _G.CollectionsJournalTab4 and _G.CollectionsJournalTab5 then
		_G.CollectionsJournalTab5:SetPoint("LEFT", _G.CollectionsJournalTab4, "RIGHT", -15, 0)
	end

	-- [[ Mounts and pets ]]
	local PetJournal = _G.PetJournal
	local MountJournal = _G.MountJournal
	if not MountJournal or not PetJournal then return end

	for i = 1, 9 do
		local mountRegion = MountJournal.MountCount and select(i, MountJournal.MountCount:GetRegions())
		local petRegion = PetJournal.PetCount and select(i, PetJournal.PetCount:GetRegions())
		if mountRegion then mountRegion:Hide() end
		if petRegion then petRegion:Hide() end
	end

	if MountJournal.LeftInset then MountJournal.LeftInset:Hide() end
	if MountJournal.RightInset then MountJournal.RightInset:Hide() end
	if PetJournal.LeftInset then PetJournal.LeftInset:Hide() end
	if PetJournal.RightInset then PetJournal.RightInset:Hide() end
	if PetJournal.PetCardInset then PetJournal.PetCardInset:Hide() end
	if PetJournal.loadoutBorder then PetJournal.loadoutBorder:Hide() end
	if MountJournal.MountDisplay and MountJournal.MountDisplay.YesMountsTex then MountJournal.MountDisplay.YesMountsTex:SetAlpha(0) end
	if MountJournal.MountDisplay and MountJournal.MountDisplay.NoMountsTex then MountJournal.MountDisplay.NoMountsTex:SetAlpha(0) end
	if MountJournal.MountDisplay and MountJournal.MountDisplay.ShadowOverlay then MountJournal.MountDisplay.ShadowOverlay:Hide() end
	if _G.PetJournalTutorialButton and _G.PetJournalTutorialButton.Ring then _G.PetJournalTutorialButton.Ring:Hide() end

	if MountJournal.MountCount then KS:CreateBD(MountJournal.MountCount, .25) end
	if PetJournal.PetCount then KS:CreateBD(PetJournal.PetCount, .25) end
	if MountJournal.MountDisplay and MountJournal.MountDisplay.ModelScene then
		KS:CreateBD(MountJournal.MountDisplay.ModelScene, .25)
	end

	-- Mount list
	local mountButtons = GetJournalButtons(MountJournal)
	if mountButtons then
		for _, bu in pairs(mountButtons) do
			if bu.backdrop then
				KS:CreateGradient(bu.backdrop)
			end

			local dragButton = bu.DragButton or bu.dragButton
			if dragButton and dragButton.ActiveTexture then
				dragButton.ActiveTexture:SetAlpha(0)
			end

			if bu.name and not bu.pulseName then
				bu.pulseName = bu:CreateFontString(nil, "OVERLAY", "GameFontNormal")
				bu.pulseName:SetJustifyH("LEFT")
				bu.pulseName:SetSize(147, 25)
				bu.pulseName:SetAllPoints(bu.name)
				bu.pulseName:Hide()

				bu.pulseName.anim = bu.pulseName:CreateAnimationGroup()
				bu.pulseName.anim:SetToFinalAlpha(true)

				bu.pulseName.anim.alphaout = bu.pulseName.anim:CreateAnimation("Alpha")
				bu.pulseName.anim.alphaout:SetOrder(1)
				bu.pulseName.anim.alphaout:SetFromAlpha(1)
				bu.pulseName.anim.alphaout:SetToAlpha(0)
				bu.pulseName.anim.alphaout:SetDuration(1)

				bu.pulseName.anim.alphain = bu.pulseName.anim:CreateAnimation("Alpha")
				bu.pulseName.anim.alphain:SetOrder(2)
				bu.pulseName.anim.alphain:SetFromAlpha(0)
				bu.pulseName.anim.alphain:SetToAlpha(1)
				bu.pulseName.anim.alphain:SetDuration(1)

				hooksecurefunc(bu.name, "SetText", function(self, text)
					bu.pulseName:SetText(text)
					bu.pulseName:SetTextColor(unpack(E["media"].rgbvaluecolor))
				end)

				bu:HookScript("OnUpdate", function(self)
					if self.active then
						bu.pulseName:Show()
						bu.pulseName.anim:Play()
					elseif bu.pulseName.anim:IsPlaying() then
						bu.pulseName:Hide()
						bu.pulseName.anim:Stop()
					end
				end)
			end
		end
	end

	-- Pet list
	local petButtons = GetJournalButtons(PetJournal)
	if petButtons then
		for _, bu in pairs(petButtons) do
			if bu.backdrop then
				KS:CreateGradient(bu.backdrop)
			end
		end
	end

	StyleJournalActionButton(PetJournal.HealPetButton, _G.PetJournalHealPetButtonBorder, _G.PetJournalHealPetButtonIconTexture)

	do
		local ic = MountJournal.MountDisplay and MountJournal.MountDisplay.InfoButton and MountJournal.MountDisplay.InfoButton.Icon
		if ic then
			ic:SetTexCoord(unpack(E.TexCoords))
			KS:CreateBG(ic)
		end
	end

	if _G.PetJournalLoadoutBorderSlotHeaderText and _G.PetJournalLoadoutBorderTop then
		_G.PetJournalLoadoutBorderSlotHeaderText:SetParent(PetJournal)
		_G.PetJournalLoadoutBorderSlotHeaderText:SetPoint("CENTER", _G.PetJournalLoadoutBorderTop, "TOP", 0, 4)
	end

	StyleJournalActionButton(_G.PetJournalSummonRandomFavoritePetButton, _G.PetJournalSummonRandomFavoritePetButtonBorder, _G.PetJournalSummonRandomFavoritePetButtonIconTexture)

	-- Favourite mount button
	StyleJournalActionButton(_G.MountJournalSummonRandomFavoriteButton, _G.MountJournalSummonRandomFavoriteButtonBorder, _G.MountJournalSummonRandomFavoriteButtonIconTexture)

	-- Pet card
	local card = _G.PetJournalPetCard
	if card and card.PetInfo and card.PetInfo.icon and card.xpBar then
		if _G.PetJournalPetCardBG then
			_G.PetJournalPetCardBG:Hide()
		end
		if card.PetInfo.levelBG then card.PetInfo.levelBG:SetAlpha(0) end
		if card.PetInfo.qualityBorder then card.PetInfo.qualityBorder:SetAlpha(0) end
		if card.AbilitiesBG1 then card.AbilitiesBG1:SetAlpha(0) end
		if card.AbilitiesBG2 then card.AbilitiesBG2:SetAlpha(0) end
		if card.AbilitiesBG3 then card.AbilitiesBG3:SetAlpha(0) end

		if card.PetInfo.level then
			card.PetInfo.level:SetFontObject(_G.GameFontNormal)
			card.PetInfo.level:SetTextColor(1, 1, 1)
		end

		card.PetInfo.icon:SetTexCoord(unpack(E.TexCoords))
		card.PetInfo.icon.bg = KS:CreateBG(card.PetInfo.icon)

		KS:CreateBD(card, .25)

		for i = 2, 12 do
			local region = select(i, card.xpBar:GetRegions())
			if region then
				region:Hide()
			end
		end

		KS:CreateBDFrame(card.xpBar, .25)

		for i = 1, 6 do
			local bu = card["spell" .. i]
			if bu and bu.icon then
				KS:ReskinIcon(bu.icon)
			end
		end

		hooksecurefunc("PetJournal_UpdatePetCard", function(self)
			if not (self and self.PetInfo and self.PetInfo.qualityBorder and self.PetInfo.icon and self.PetInfo.icon.bg) then return end

			local border = self.PetInfo.qualityBorder
			local r, g, b

			if border:IsShown() then
				r, g, b = self.PetInfo.qualityBorder:GetVertexColor()
			else
				r, g, b = 0, 0, 0
			end

			self.PetInfo.icon.bg:SetVertexColor(r, g, b)
		end)
	end

	-- Pet loadout
	for i = 1, 3 do
		local bu = _G["PetJournalLoadoutPet"..i]
		local loadoutBG = _G["PetJournalLoadoutPet" .. i .. "BG"]
		if not bu then
			break
		end

		if loadoutBG then
			loadoutBG:Hide()
		end

		if bu.iconBorder then bu.iconBorder:SetAlpha(0) end
		if bu.qualityBorder then bu.qualityBorder:SetTexture("") end
		if bu.levelBG then bu.levelBG:SetAlpha(0) end
		if bu.helpFrame then
			local helpRegion = bu.helpFrame:GetRegions()
			if helpRegion then
				helpRegion:Hide()
			end
		end
		if bu.dragButton and bu.dragButton:GetHighlightTexture() then
			bu.dragButton:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
		end

		if bu.level then
			bu.level:SetFontObject(_G.GameFontNormal)
			bu.level:SetTextColor(1, 1, 1)
		end

		if bu.icon then
			bu.icon:SetTexCoord(unpack(E.TexCoords))
			bu.icon.bg = KS:CreateBDFrame(bu.icon, .25)
		end

		if bu.setButton and bu.icon then
			local setButtonRegion = bu.setButton:GetRegions()
			if setButtonRegion then
				setButtonRegion:SetPoint("TOPLEFT", bu.icon, -5, 5)
				setButtonRegion:SetPoint("BOTTOMRIGHT", bu.icon, 5, -5)
			end
		end

		KS:CreateBD(bu, .25)

		if bu.qualityBorder and type(bu.qualityBorder.SetVertexColor) == "function" and bu.name then
			hooksecurefunc(bu.qualityBorder, "SetVertexColor", function(_, r, g, b)
				bu.name:SetTextColor(r, g, b)
			end)
		end

		for i = 2, 12 do
			if bu.xpBar then
				local region = select(i, bu.xpBar:GetRegions())
				if region then
					region:Hide()
				end
			end
		end

		if bu.xpBar then
			bu.xpBar:SetStatusBarTexture(E["media"].normTex)
			KS:CreateBDFrame(bu.xpBar, .25)
		end

		local healthLeft = _G["PetJournalLoadoutPet" .. i .. "HealthFramehealthStatusBarLeft"]
		local healthRight = _G["PetJournalLoadoutPet" .. i .. "HealthFramehealthStatusBarRight"]
		local healthMiddle = _G["PetJournalLoadoutPet" .. i .. "HealthFramehealthStatusBarMiddle"]
		local healthBGMiddle = _G["PetJournalLoadoutPet" .. i .. "HealthFramehealthStatusBarBGMiddle"]
		if healthLeft then healthLeft:Hide() end
		if healthRight then healthRight:Hide() end
		if healthMiddle then healthMiddle:Hide() end
		if healthBGMiddle then healthBGMiddle:Hide() end

		if bu.healthFrame and bu.healthFrame.healthBar then
			bu.healthFrame.healthBar:SetStatusBarTexture(E["media"].normTex)
			KS:CreateBDFrame(bu.healthFrame.healthBar, .25)
		end

		for j = 1, 3 do
			local spell = bu["spell" .. j]
			if spell then
				spell:SetPushedTexture("")
				local highlight = spell:GetHighlightTexture()
				if highlight then
					highlight:SetColorTexture(1, 1, 1, .25)
				end
				local spellRegion = spell:GetRegions()
				if spellRegion then
					spellRegion:Hide()
				end

				if spell.icon then
					spell.icon:SetTexCoord(unpack(E.TexCoords))
					KS:CreateBG(spell.icon)
				end
			end
		end
	end

	hooksecurefunc("PetJournal_UpdatePetLoadOut", function()
		for i = 1, 3 do
			local bu = PetJournal.Loadout["Pet" .. i]
			if bu and bu.icon and bu.icon.bg and bu.helpFrame then
				bu.icon.bg:SetShown(not bu.helpFrame:IsShown())
				if bu.qualityBorder then
					bu.icon.bg:SetBackdropBorderColor(bu.qualityBorder:GetVertexColor())
				end
			end

			if bu and bu.dragButton and bu.helpFrame then
				bu.dragButton:SetEnabled(not bu.helpFrame:IsShown())
			end
		end
	end)

	PetJournal.SpellSelect.BgEnd:Hide()
	PetJournal.SpellSelect.BgTiled:Hide()

	-- [[ Toy box ]]
	local ToyBox = _G.ToyBox

	-- Progress bar
	local progressBar = ToyBox.progressBar
	progressBar.text:SetPoint("CENTER", 0, 1)

	-- Toys
	for i = 1, 18 do
		local button = ToyBox.iconsFrame["spellButton" .. i]
		KS:StyleButton(button)
		KS:ReskinIcon(button.iconTexture)
		KS:ReskinIcon(button.iconTextureUncollected)

		button.name:SetPoint("LEFT", button, "RIGHT", 9, 0)

		local bg = KS:CreateBDFrame(button)
		bg:SetPoint("TOPLEFT", button, "TOPRIGHT", 0, -2)
		bg:SetPoint("BOTTOMLEFT", button, "BOTTOMRIGHT", 0, 2)
		bg:SetPoint("RIGHT", button.name, "RIGHT", 0, 0)
		KS:CreateGradient(bg)
	end

	-- [[ Heirlooms ]]
	local HeirloomsJournal = _G.HeirloomsJournal

	-- Progress bar
	local progressBar = HeirloomsJournal.progressBar
	progressBar.text:SetPoint("CENTER", 0, 1)

	hooksecurefunc(HeirloomsJournal, "UpdateButton", function(_, button)
		if not button.IsStyled then
			local bg = KS:CreateBDFrame(button)
			bg:SetPoint("TOPLEFT", button, "TOPRIGHT", 0, -2)
			bg:SetPoint("BOTTOMLEFT", button, "BOTTOMRIGHT", 0, 2)
			bg:SetPoint("RIGHT", button.name, "RIGHT", 2, 0)
			KS:CreateGradient(bg)
			button.IsStyled = true
		end
	end)

	-- Header
	hooksecurefunc(HeirloomsJournal, "LayoutCurrentPage", function()
		for i = 1, #HeirloomsJournal.heirloomHeaderFrames do
			local header = HeirloomsJournal.heirloomHeaderFrames[i]
			if not header.IsStyled then
				header.text:SetTextColor(1, 1, 1)
				header.text:FontTemplate(E["media"].normFont, 16, "OUTLINE")

				header.IsStyled = true
			end
		end
	end)

	-- [[ WardrobeCollectionFrame ]]
	local WardrobeCollectionFrame = _G.WardrobeCollectionFrame
	if WardrobeCollectionFrame and WardrobeCollectionFrame.ItemsCollectionFrame then
		local ItemsCollectionFrame = WardrobeCollectionFrame.ItemsCollectionFrame

		for index = 1, 2 do
			local tab = _G["WardrobeCollectionFrameTab" .. index]
			if tab then
				for i = 1, 6 do
					local region = select(i, tab:GetRegions())
					if region then
						region:SetAlpha(0)
					end
				end

				if tab.backdrop then
					tab.backdrop:Hide()
				end

				tab:SetHighlightTexture("")
				tab.bg = KS:CreateBDFrame(tab, .25)
				tab.bg:SetPoint("TOPLEFT", 3, -3)
				tab.bg:SetPoint("BOTTOMRIGHT", -3, -1)
			end
		end

		if type(_G.WardrobeCollectionFrame_SetTab) == "function" then
			hooksecurefunc("WardrobeCollectionFrame_SetTab", function(tabID)
				for index = 1, 2 do
					local tab = _G["WardrobeCollectionFrameTab" .. index]
					if tab and tab.bg then
						if tabID == index then
							tab.bg:SetBackdropColor(r, g, b, .45)
						else
							tab.bg:SetBackdropColor(0, 0, 0, .2)
						end
					end
				end
			end)
		end

		-- Progress bar
		local progressBar = WardrobeCollectionFrame.progressBar
		if progressBar and progressBar.text then
			progressBar.text:SetPoint("CENTER", 0, 1)
		end

		-- ItemSetsCollection
		local SetsCollectionFrame = WardrobeCollectionFrame.SetsCollectionFrame
		if SetsCollectionFrame then
			if SetsCollectionFrame.Model then
				KS:CreateBDFrame(SetsCollectionFrame.Model, .25)
			end

			local ScrollFrame = SetsCollectionFrame.ScrollFrame
			if ScrollFrame and ScrollFrame.buttons then
				for i = 1, #ScrollFrame.buttons do
					local bu = ScrollFrame.buttons[i]
					if bu then
						if bu.Background then bu.Background:Hide() end
						if bu.HighlightTexture then bu.HighlightTexture:SetTexture("") end
						if bu.Icon then KS:ReskinIcon(bu.Icon) end

						if bu.SelectedTexture then
							bu.SelectedTexture:SetDrawLayer("BACKGROUND")
							bu.SelectedTexture:SetColorTexture(r, g, b, .25)
							bu.SelectedTexture:ClearAllPoints()
							bu.SelectedTexture:SetPoint("TOPLEFT", 1, -2)
							bu.SelectedTexture:SetPoint("BOTTOMRIGHT", -1, 2)
							KS:CreateBDFrame(bu.SelectedTexture, .25)
						end
					end
				end
			end

			local DetailsFrame = SetsCollectionFrame.DetailsFrame
			if DetailsFrame then
				if DetailsFrame.ModelFadeTexture then DetailsFrame.ModelFadeTexture:Hide() end
				if DetailsFrame.IconRowBackground then DetailsFrame.IconRowBackground:Hide() end
			end

			if type(SetsCollectionFrame.SetItemFrameQuality) == "function" then
				hooksecurefunc(SetsCollectionFrame, "SetItemFrameQuality", function(_, itemFrame)
					local ic = itemFrame and itemFrame.Icon
					if not ic then return end

					if not ic.bg then
						ic:SetTexCoord(unpack(E.TexCoords))
						if itemFrame.IconBorder then
							itemFrame.IconBorder:Hide()
							itemFrame.IconBorder.Show = KUI.dummy
						end
						ic.bg = KS:CreateBDFrame(ic)
					end

					if itemFrame.collected and T.C_TransmogCollection_GetSourceInfo then
						local sourceInfo = T.C_TransmogCollection_GetSourceInfo(itemFrame.sourceID)
						local quality = sourceInfo and sourceInfo.quality
						local color = _G.BAG_ITEM_QUALITY_COLORS[quality or 1]
						ic.bg:SetBackdropBorderColor(color.r, color.g, color.b)
					else
						ic.bg:SetBackdropBorderColor(0, 0, 0)
					end
				end)
			end
		end
	end

	-- [[ Wardrobe ]]
	local WardrobeFrame = _G.WardrobeFrame
	local WardrobeTransmogFrame = _G.WardrobeTransmogFrame
	if WardrobeFrame and WardrobeTransmogFrame then
		WardrobeFrame:Styling()

		if _G.WardrobeOutfitFrame then
			KS:CreateBDFrame(_G.WardrobeOutfitFrame, .25)
			KS:CreateSD(_G.WardrobeOutfitFrame, .25)
		end

		if WardrobeTransmogFrame.SpecButton and WardrobeTransmogFrame.ApplyButton then
			WardrobeTransmogFrame.SpecButton:SetPoint("RIGHT", WardrobeTransmogFrame.ApplyButton, "LEFT", -3, 0)
		end

		local slots = {
			"Head",
			"Shoulder",
			"Chest",
			"Waist",
			"Legs",
			"Feet",
			"Wrist",
			"Hands",
			"Back",
			"Shirt",
			"Tabard",
			"MainHand",
			"SecondaryHand"
		}

		if WardrobeTransmogFrame.ModelScene then
			for i = 1, #slots do
				local slot = WardrobeTransmogFrame.ModelScene[slots[i] .. "Button"]
				if slot then
					if slot.Border then slot.Border:Hide() end
					if slot.Icon then
						slot.Icon:SetDrawLayer("BACKGROUND", 1)
						KS:ReskinIcon(slot.Icon)
					end
					slot:SetHighlightTexture(E["media"].normTex)

					local hl = slot:GetHighlightTexture()
					if hl then
						hl:SetVertexColor(1, 1, 1, .25)
						hl:SetPoint("TOPLEFT", 2, -2)
						hl:SetPoint("BOTTOMRIGHT", -2, 2)
					end
				end
			end
		end

		-- Edit Frame
		if _G.WardrobeOutfitEditFrame then
			for i = 1, 11 do
				local region = select(i, _G.WardrobeOutfitEditFrame:GetRegions())
				if region then
					region:Hide()
				end
			end
			if _G.WardrobeOutfitEditFrame.Title then
				_G.WardrobeOutfitEditFrame.Title:Show()
			end

			if _G.WardrobeOutfitEditFrame.EditBox then
				for i = 2, 5 do
					local region = select(i, _G.WardrobeOutfitEditFrame.EditBox:GetRegions())
					if region then
						region:Hide()
					end
				end
			end
		end
		
		if E.db.KlixUI.misc.transmog and WardrobeTransmogFrame.ModelScene and WardrobeTransmogFrame.ModelScene.ClearAllPendingButton then	
			-- Remove Transmog Button
			local ClearAllPendingButton = WardrobeTransmogFrame.ModelScene.ClearAllPendingButton
			local button = T.CreateFrame("Button", KUI.Title.."TransmogRemoveButton", WardrobeTransmogFrame, "UIMenuButtonStretchTemplate")
			local pendingPoint = {"TOPLEFT", ClearAllPendingButton, "BOTTOMLEFT", 0, -5}
			local defaultPoint = {"TOPLEFT", ClearAllPendingButton, "TOPLEFT", 0, 0}
			button:Width(26)
			button:Height(26)
			button:SetFrameLevel(ClearAllPendingButton:GetFrameLevel())
			button:Point(T.unpack(defaultPoint))
			S:HandleButton(button)

			-- button icon
			button.Icon = button:CreateTexture(KUI.Title.."TransmogRemoveButtonTexture", "ARTWORK")
			button.Icon:SetAtlas("XMarksTheSpot")
			button.Icon:Size(18, 18)
			button.Icon:Point("CENTER")
			
			button:HookScript("OnEnter", function(self)
				GameTooltip:SetOwner(self, 'ANCHOR_TOPLEFT', 0, 4)
				GameTooltip:AddLine(L["Instantly remove all transmogs."])
				GameTooltip:Show()
			end)

			button:HookScript("OnLeave", function(self)
				GameTooltip:Hide()
			end)

			button:HookScript("OnClick", function(self, button)
				if (button == "LeftButton") then S:RemoveAllTransmog() end
			end)

			-- Hook to set button point
			ClearAllPendingButton:HookScript("OnShow", function(self)
				button:Point(T.unpack(pendingPoint))
			end)
			ClearAllPendingButton:HookScript("OnHide", function(self)
				button:Point(T.unpack(defaultPoint))
			end)
		end
	end
end

-- Removes transmog from all transmogged slots.
function S:RemoveAllTransmog()
	for _, slot in T.pairs(TransmogSlots) do
    local slotID = T.GetInventorySlotInfo(slot)
    S:RemoveTransmog(slotID)
  end
end

-- Removes transmog from the specified slot if possible.
-- @param slotID - the inventory slot to remove transmog
function S:RemoveTransmog(slotID)
  local isTransmogrified, hasPending = T.C_Transmog_GetSlotInfo(slotID, LE_TRANSMOG_TYPE_APPEARANCE)
  if isTransmogrified then
    T.C_Transmog_SetPending(slotID, LE_TRANSMOG_TYPE_APPEARANCE, 0)
  elseif hasPending then
    T.C_Transmog_ClearPending(slotID, LE_TRANSMOG_TYPE_APPEARANCE)
  end
end

S:AddCallbackForAddon("Blizzard_Collections", "KuiCollections", styleCollections)
