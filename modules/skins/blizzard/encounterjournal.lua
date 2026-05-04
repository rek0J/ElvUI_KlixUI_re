local KUI, T, E, L, V, P, G = unpack(select(2, ...))
local KS = KUI:GetModule('KuiSkins')
local S = E:GetModule('Skins')

local r, g, b = T.unpack(E["media"].rgbvaluecolor)

local function SafeHide(frame)
	if frame and frame.Hide then
		frame:Hide()
	end
end

local function SafeKill(frame)
	if frame and frame.Kill then
		frame:Kill()
	elseif frame and frame.Hide then
		frame:Hide()
	end
end

local function SafeSetAlpha(frame, alpha)
	if frame and frame.SetAlpha then
		frame:SetAlpha(alpha)
	end
end

local function SafeSetTextColor(fontString, ...)
	if not fontString or not fontString.SetTextColor then return end
	if fontString.IsObjectType and not fontString:IsObjectType("FontString") then
		return
	end

	pcall(fontString.SetTextColor, fontString, ...)
end

local function SafeSetFontObject(fontString, fontObject)
	if fontString and fontString.SetFontObject then
		fontString:SetFontObject(fontObject)
	end
end

local function SafeDisableDrawLayer(frame, layer)
	if frame and frame.DisableDrawLayer then
		frame:DisableDrawLayer(layer)
	end
end

local function SafeReskin(button)
	if button and KS and KS.Reskin then
		KS:Reskin(button)
	end
end

local function SafeHook(target, method, func)
	if type(target) == "string" then
		if type(_G[target]) == "function" and type(method) == "function" then
			hooksecurefunc(target, method)
		end
	elseif target and type(method) == "string" and type(target[method]) == "function" and type(func) == "function" then
		hooksecurefunc(target, method, func)
	end
end

local function SkinBosses()
	local bossIndex = 1;
	local _, _, bossID = T.EJ_GetEncounterInfoByIndex(bossIndex);
	local bossButton;

	while bossID do
		bossButton = _G["EncounterJournalBossButton"..bossIndex]
		if bossButton and not bossButton.isSkinned then
			S:HandleButton(bossButton)
			if bossButton.creature then
				bossButton.creature:ClearAllPoints()
				bossButton.creature:Point("TOPLEFT", 1, -4)
			end
			bossButton.isSkinned = true
		end

		bossIndex = bossIndex + 1;
		_, _, bossID = T.EJ_GetEncounterInfoByIndex(bossIndex);
	end
end

local function SkinOverviewInfo(self, _, index)
	local header = self and self.overviews and self.overviews[index]
	if not header or not header.button or header.isSkinned then return end
	if not header.isSkinned then

		SafeSetAlpha(header.descriptionBG, 0)
		SafeSetAlpha(header.descriptionBGBottom, 0)
		for i = 4, 18 do
			local region = T.select(i, header.button:GetRegions())
			if region and region.SetTexture then
				region:SetTexture()
			end
		end

		S:HandleButton(header.button)

		SafeSetTextColor(header.button.title, T.unpack(E["media"].rgbvaluecolor))
		if header.button.title then header.button.title.SetTextColor = E.noop end
		SafeSetTextColor(header.button.expandedIcon, 1, 1, 1)
		if header.button.expandedIcon then header.button.expandedIcon.SetTextColor = E.noop end

		header.isSkinned = true
	end
end

local function SkinOverviewInfoBullets(object)
	local parent = object and object.GetParent and object:GetParent()

	if parent and parent.Bullets then
		for _, bullet in T.pairs(parent.Bullets) do
			if not bullet.styled then
				SafeSetTextColor(bullet.Text, 1, 1, 1)
				bullet.styled = true
			end
		end
	end
end

local function SkinAbilitiesInfo()
	local index = 1
	local header = _G["EncounterJournalInfoHeader"..index]
	while header do
		if header.button and not header.isSkinned then
			if header.flashAnim then header.flashAnim.Play = E.noop end

			SafeSetAlpha(header.descriptionBG, 0)
			SafeSetAlpha(header.descriptionBGBottom, 0)
			for i = 4, 18 do
				local region = T.select(i, header.button:GetRegions())
				if region and region.SetTexture then
					region:SetTexture()
				end
			end

			SafeSetTextColor(header.description, 1, 1, 1)
			SafeSetTextColor(header.button.title, T.unpack(E["media"].rgbvaluecolor))
			if header.button.title then header.button.title.SetTextColor = E.noop end
			SafeSetTextColor(header.button.expandedIcon, 1, 1, 1)
			if header.button.expandedIcon then header.button.expandedIcon.SetTextColor = E.noop end

			S:HandleButton(header.button)

			if header.button.abilityIcon and not header.button.bg then
				header.button.bg = T.CreateFrame("Frame", nil, header.button, "BackdropTemplate")
				header.button.bg:SetTemplate()
				header.button.bg:SetOutside(header.button.abilityIcon)
				header.button.bg:SetFrameLevel(header.button.bg:GetFrameLevel() - 1)
				header.button.abilityIcon:SetTexCoord(.08, .92, .08, .92)
			end

			header.isSkinned = true
		end

		if header.button and header.button.bg and header.button.abilityIcon and header.button.abilityIcon:IsShown() then
			header.button.bg:Show()
		elseif header.button and header.button.bg then
			header.button.bg:Hide()
		end

		index = index + 1
		header = _G["EncounterJournalInfoHeader"..index]
	end
end


local function resultOnEnter(self)
		self.hl:Show()
end

local function resultOnLeave(self)
		self.hl:Hide()
end

local function styleSearchButton(result, index)
		if not result then return end
	local searchBox = _G.EncounterJournal and _G.EncounterJournal.searchBox
		if not searchBox then return end

		if index == 1 then
		result:SetPoint("TOPLEFT", searchBox, "BOTTOMLEFT", 0, 1)
		result:SetPoint("TOPRIGHT", searchBox, "BOTTOMRIGHT", -5, 1)
		else
		if not searchBox.searchPreview or not searchBox.searchPreview[index-1] then return end
		result:SetPoint("TOPLEFT", searchBox.searchPreview[index-1], "BOTTOMLEFT", 0, 1)
		result:SetPoint("TOPRIGHT", searchBox.searchPreview[index-1], "BOTTOMRIGHT", 0, 1)
		end

		result:SetNormalTexture("")
		result:SetPushedTexture("")
		result:SetHighlightTexture("")

		local hl = result:CreateTexture(nil, "BACKGROUND")
		hl:SetAllPoints()
		hl:SetTexture(E["media"].normTex)
		hl:SetVertexColor(r, g, b, .2)
		hl:Hide()
		result.hl = hl

	if result.CreateBackdrop then
		result:CreateBackdrop()
	end
		if result.backdrop then
			result.backdrop:SetBackdropColor(.1, .1, .1, .9)
		end

		if result.icon then
			local region = result:GetRegions()
			if region then
				region:Hide() -- icon frame
			end

			result.icon:SetTexCoord(T.unpack(E.TexCoords))

			local bg = KS:CreateBG(result.icon)
			bg:SetDrawLayer("BACKGROUND", 1)
		end

		result:HookScript("OnEnter", resultOnEnter)
		result:HookScript("OnLeave", resultOnLeave)
end

local function listInstances()
	local instanceSelect = _G.EncounterJournal.instanceSelect
	if not instanceSelect then return end

	local instanceButtons =
		(instanceSelect.scroll and instanceSelect.scroll.child and instanceSelect.scroll.child.InstanceButtons) or
		(instanceSelect.scrollChild and instanceSelect.scrollChild.InstanceButtons) or
		(instanceSelect.ScrollChild and instanceSelect.ScrollChild.InstanceButtons) or
		(instanceSelect.ScrollContainer and instanceSelect.ScrollContainer.Child and instanceSelect.ScrollContainer.Child.InstanceButtons) or
		instanceSelect.InstanceButtons or
		instanceSelect.buttons
	if not instanceButtons then return end

	local index = 1
	while true do
		local bu = instanceButtons[index]
		if not bu then return end

		bu:SetNormalTexture("")
		bu:SetHighlightTexture("")
		bu:SetPushedTexture("")

		if bu.bgImage then
			bu.bgImage:SetDrawLayer("BACKGROUND", 1)
			local bg = KS:CreateBG(bu.bgImage)
			bg:SetPoint("TOPLEFT", 3, -3)
			bg:SetPoint("BOTTOMRIGHT", -4, 2)
		end

		index = index + 1
	end
end

local function SkinEJButton(button)
	if not button then return end

	SafeSetAlpha(button.UpLeft, 0)
	SafeSetAlpha(button.UpRight, 0)
	SafeSetAlpha(button.DownLeft, 0)
	SafeSetAlpha(button.DownRight, 0)
	SafeHide(select(5, button:GetRegions()))
	SafeHide(select(6, button:GetRegions()))
	SafeReskin(button)
end

function KS:StyleEncounterJournal()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.encounterjournal ~= true or E.private.KlixUI.skins.blizzard.encounterjournal ~= true then return end

	local EncounterJournal = _G.EncounterJournal
	if not EncounterJournal then return end
	if not EncounterJournal.backdrop and S.HandlePortraitFrame then
		S:HandlePortraitFrame(EncounterJournal)
	end
	if EncounterJournal.backdrop then
		EncounterJournal.backdrop:Styling()
	end

	if EncounterJournal.navBar and EncounterJournal.navBar.backdrop then
		EncounterJournal.navBar.backdrop:Hide()
	end

	-- [[ SearchBox ]]
	local searchBox = EncounterJournal.searchBox
	if searchBox and searchBox.searchPreviewContainer then
		if searchBox.searchPreviewContainer.botLeftCorner then searchBox.searchPreviewContainer.botLeftCorner:Hide() end
		if searchBox.searchPreviewContainer.botRightCorner then searchBox.searchPreviewContainer.botRightCorner:Hide() end
		if searchBox.searchPreviewContainer.bottomBorder then searchBox.searchPreviewContainer.bottomBorder:Hide() end
		if searchBox.searchPreviewContainer.leftBorder then searchBox.searchPreviewContainer.leftBorder:Hide() end
		if searchBox.searchPreviewContainer.rightBorder then searchBox.searchPreviewContainer.rightBorder:Hide() end
	end

	if searchBox and searchBox.searchPreview then
		for i = 1, #searchBox.searchPreview do
			styleSearchButton(searchBox.searchPreview[i], i)
		end
		styleSearchButton(searchBox.showAllResults, 6)
	end

	-- [[ SearchResults ]]
	local searchResults = EncounterJournal.searchResults
	if searchResults then
		searchResults:CreateBackdrop()
		if searchResults.backdrop then
			searchResults.backdrop:SetBackdropColor(.15, .15, .15, .9)
		end
		for i = 3, 11 do
			local region = select(i, searchResults:GetRegions())
			if region then
				region:Hide()
			end
		end
	end

	if _G.EncounterJournalSearchResultsBg then
		_G.EncounterJournalSearchResultsBg:Hide()
	end

	SafeHook("EncounterJournal_SearchUpdate", function()
		if not searchResults then return end
		local scrollFrame = searchResults.scrollFrame
		if not scrollFrame or not scrollFrame.buttons then return end
		local offset = T.HybridScrollFrame_GetOffset(scrollFrame)
		local results = scrollFrame.buttons
		local result, index

		local numResults = T.EJ_GetNumSearchResults()

		for i = 1, #results do
			result = results[i]
			index = offset + i

			if index <= numResults then
				if not result.styled then
					result:SetNormalTexture("")
					result:SetPushedTexture("")
					result:GetRegions():Hide()

					SafeSetTextColor(result.resultType, 1, 1, 1)
					SafeSetTextColor(result.path, 1, 1, 1)

					KS:CreateBG(result.icon)

					result.styled = true
				end

				if result.icon:GetTexCoord() == 0 then
					result.icon:SetTexCoord(T.unpack(E.TexCoords))
				end
			end
		end
	end)

	local searchResultsScrollFrame = searchResults and searchResults.scrollFrame
	SafeHook(searchResultsScrollFrame, "update", function(self)
		if not self.buttons then return end
		for i = 1, #self.buttons do
			local result = self.buttons[i]

			if result and result.icon and result.icon:GetTexCoord() == 0 then
				result.icon:SetTexCoord(T.unpack(E.TexCoords))
			end
		end
	end)

	--[[ NavBar ]]
	if EncounterJournal.navBar then
		EncounterJournal.navBar:SetWidth(550)
		EncounterJournal.navBar:SetPoint("TOPLEFT", 20, -22)
	end

	--[[ Inset ]]
	if EncounterJournal.inset then
		EncounterJournal.inset:DisableDrawLayer("BORDER")
		if EncounterJournal.inset.Bg then
			EncounterJournal.inset.Bg:Hide()
		end
	end

	--[[ InstanceSelect ]]
	local instanceSelect = EncounterJournal.instanceSelect
	if instanceSelect and instanceSelect.bg then
		instanceSelect.bg:Hide()
	end

	SafeHook("EncounterJournal_ListInstances", listInstances)
	listInstances()

	--[[ EncounterFrame ]]
	local encounter = EncounterJournal.encounter

	--[[ InstanceFrame ]]
	local instance = encounter and encounter.instance
	local lore =
		_G.EncounterJournalEncounterFrameInstanceFrameLoreScrollFrameScrollChildLore or
		(instance and instance.loreScroll and instance.loreScroll.child and instance.loreScroll.child.lore)
	SafeSetTextColor(lore, 1, 1, 1)

	--[[ Info ]]
	local info = encounter and encounter.info
	if info then
		SafeDisableDrawLayer(info, "BACKGROUND")

		SafeSetTextColor(info.encounterTitle, 1, 1, 1)

		SkinEJButton(info.difficulty)

		SafeReskin(info.reset)

		SafeSetTextColor(info.detailsScroll and info.detailsScroll.child and info.detailsScroll.child.description, 1, 1, 1)

		local overviewChild = info.overviewScroll and info.overviewScroll.child
		SafeSetTextColor(overviewChild and overviewChild.loreDescription, 1, 1, 1)
		SafeHide(overviewChild and overviewChild.header)
		local overviewTitle = _G.EncounterJournalEncounterFrameInfoOverviewScrollFrameScrollChildTitle or (overviewChild and overviewChild.title)
		SafeSetFontObject(overviewTitle, "GameFontNormalLarge")
		SafeSetTextColor(overviewTitle, 1, 1, 1)
		SafeSetTextColor(overviewChild and overviewChild.overviewDescription and overviewChild.overviewDescription.Text, 1, 1, 1)

		if info.lootScroll then
			SkinEJButton(info.lootScroll.filter)
			SkinEJButton(info.lootScroll.slotFilter)

			local encLoot = info.lootScroll.buttons
			if encLoot then
				for i = 1, #encLoot do
					local item = encLoot[i]

					SafeSetTextColor(item and item.boss, 1, 1, 1)
					SafeSetTextColor(item and item.slot, 1, 1, 1)
					SafeSetTextColor(item and item.armorType, 1, 1, 1)

					SafeSetAlpha(item and item.bossTexture, 0)
					SafeSetAlpha(item and item.bosslessTexture, 0)

					if item and item.icon then
						item.icon:SetTexCoord(T.unpack(E.TexCoords))
						item.icon:SetDrawLayer("OVERLAY")
						KS:CreateBG(item.icon)
					end

					SafeHide(item and item.backdrop)

					if item and not item.KUIBG then
						local bg = T.CreateFrame("Frame", nil, item)
						bg:SetPoint("TOPLEFT")
						bg:SetPoint("BOTTOMRIGHT", 0, 1)
						bg:SetFrameLevel(item:GetFrameLevel() - 1)
						KS:CreateBD(bg, .25)
						KS:CreateGradient(bg)
						item.KUIBG = bg
					end
				end
			end
		end

		if info.model then
			SafeHide(info.model.dungeonBG)
		end
		SafeHide(_G.EncounterJournalEncounterFrameInfoModelFrameShadow)
		if _G.EncounterJournalEncounterFrameInfoModelFrame then
			KS:CreateBDFrame(_G.EncounterJournalEncounterFrameInfoModelFrame, .25)
		end

		-- [[ Encounter Info Frame ]]
		local EncounterInfo = info

		SafeKill(_G.EncounterJournalEncounterFrameInfoBG)
		SafeHide(EncounterInfo.backdrop)

		 --Tabs
		local tabs = {
			EncounterInfo.overviewTab,
			EncounterInfo.lootTab,
			EncounterInfo.bossTab,
			EncounterInfo.modelTab,
		}

		for _, tab in pairs(tabs) do
			if tab and tab.backdrop then
				tab.backdrop:SetTemplate("Transparent")
				tab.backdrop:Styling()
			end
		end
	end

	--Encounter Instance Frame
	local EncounterInstance = instance
	SafeSetTextColor(EncounterInstance and EncounterInstance.loreScroll and EncounterInstance.loreScroll.child and EncounterInstance.loreScroll.child.lore, 1, 1, 1)

	SafeSetAlpha(_G.EncounterJournalEncounterFrameInstanceFrame and _G.EncounterJournalEncounterFrameInstanceFrame.titleBG, 0)

	-- [[ Loot ]]
	local LootJournal = EncounterJournal.LootJournal
	SafeDisableDrawLayer(LootJournal, "BACKGROUND")

	-- ToDo: Update me

	-- [[ SuggestFrame ]]
	local suggestFrame = EncounterJournal.suggestFrame
	if suggestFrame then
		-- Suggestion 1
		local suggestion = suggestFrame.Suggestion1

		if suggestion then
			SafeHide(suggestion.bg)

			KS:CreateBD(suggestion, .25)
			KS:CreateGradient(suggestion)

			if suggestion.icon then
				suggestion.icon:SetPoint("TOPLEFT", 135, -15)
			end

			local centerDisplay = suggestion.centerDisplay

			SafeSetTextColor(centerDisplay and centerDisplay.title and centerDisplay.title.text, 1, 1, 1)
			SafeSetTextColor(centerDisplay and centerDisplay.description and centerDisplay.description.text, .9, .9, .9)

			SafeReskin(suggestion.button)

			local reward = suggestion.reward

			SafeSetTextColor(reward and reward.text, .9, .9, .9)
			SafeHide(reward and reward.iconRing)
			if reward and reward.iconRingHighlight then reward.iconRingHighlight:SetTexture("") end
		end

		-- Suggestion 2 and 3
		for i = 2, 3 do
			suggestion = suggestFrame["Suggestion"..i]
			if suggestion then

				SafeHide(suggestion.bg)

				KS:CreateBD(suggestion, .25)
				KS:CreateGradient(suggestion)

				if suggestion.icon then
					suggestion.icon:SetPoint("TOPLEFT", 10, -10)
				end

				local centerDisplay = suggestion.centerDisplay

				if centerDisplay then
					centerDisplay:ClearAllPoints()
					centerDisplay:SetPoint("TOPLEFT", 85, -10)
				end
				SafeSetTextColor(centerDisplay and centerDisplay.title and centerDisplay.title.text, 1, 1, 1)
				SafeSetTextColor(centerDisplay and centerDisplay.description and centerDisplay.description.text, .9, .9, .9)

				local reward = suggestion.reward

				SafeHide(reward and reward.iconRing)
				if reward and reward.iconRingHighlight then reward.iconRingHighlight:SetTexture("") end
			end
		end
	end

	SafeHook("EJSuggestFrame_RefreshDisplay", function()
		local self = suggestFrame
		if not self or not self.suggestions then return end

		if #self.suggestions > 0 then
			local suggestion = self.Suggestion1
			local data = self.suggestions[1]

			SafeHide(suggestion and suggestion.iconRing)

			if suggestion and suggestion.icon and data then
				suggestion.icon:SetMask("")
				suggestion.icon:SetTexture(data.iconPath)
				suggestion.icon:SetTexCoord(T.unpack(E.TexCoords))
			end
		end

		if #self.suggestions > 1 then
			for i = 2, #self.suggestions do
				local suggestion = self["Suggestion"..i]
				if not suggestion then break end

				local data = self.suggestions[i]

				SafeHide(suggestion.iconRing)

				if data.iconPath and suggestion.icon then
					suggestion.icon:SetMask("")
					suggestion.icon:SetTexture(data.iconPath)
					suggestion.icon:SetTexCoord(T.unpack(E.TexCoords))
				end
			end
		end
	end)

	SafeHook("EJSuggestFrame_UpdateRewards", function(suggestion)
		local rewardData = suggestion and suggestion.reward and suggestion.reward.data
		if rewardData then
			local texture = rewardData.itemIcon or rewardData.currencyIcon or [[Interface\Icons\achievement_guildperk_mobilebanking]]
			if not suggestion.reward.icon then return end
			suggestion.reward.icon:SetMask("")
			suggestion.reward.icon:SetTexture(texture)

			if not suggestion.reward.icon.backdrop and suggestion.reward.icon.CreateBackdrop then
				suggestion.reward.icon:CreateBackdrop()
				if suggestion.reward.icon.backdrop then
					suggestion.reward.icon.backdrop:SetOutside(suggestion.reward.icon)
				end
			end

			if rewardData.itemID then
				local quality = T.select(3, T.GetItemInfo(rewardData.itemID))
				if quality and quality > 1 then
					r, g, b = T.GetItemQualityColor(quality)
				end
			end
			if suggestion.reward.icon.backdrop then
				suggestion.reward.icon.backdrop:SetBackdropBorderColor(r, g, b)
			end
		end
	end)

	--Overview Info (From Aurora)
	SafeHook("EncounterJournal_SetUpOverview", SkinOverviewInfo)

	--Overview Info Bullets (From Aurora)
	SafeHook("EncounterJournal_SetBullets", SkinOverviewInfoBullets)

	--Abilities Info (From Aurora)
	SafeHook("EncounterJournal_ToggleHeaders", SkinAbilitiesInfo)

	--Boss selection buttons
	SafeHook("EncounterJournal_DisplayInstance", SkinBosses)
end

S:AddCallbackForAddon("Blizzard_EncounterJournal", "KuiEncounterJournal", KS.StyleEncounterJournal)
