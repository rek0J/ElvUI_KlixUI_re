local KUI, T, E, L, V, P, G = unpack(select(2, ...))
local KS = KUI:GetModule('KuiSkins')
local S = E:GetModule('Skins')

local r, g, b = T.unpack(E["media"].rgbvaluecolor)

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
	local header = self.overviews[index]
	if not header or not header.button or header.isSkinned then return end
	if not header.isSkinned then

		header.descriptionBG:SetAlpha(0)
		header.descriptionBGBottom:SetAlpha(0)
		for i = 4, 18 do
			T.select(i, header.button:GetRegions()):SetTexture()
		end

		S:HandleButton(header.button)

		header.button.title:SetTextColor(T.unpack(E["media"].rgbvaluecolor))
		header.button.title.SetTextColor = E.noop
		header.button.expandedIcon:SetTextColor(1, 1, 1)
		header.button.expandedIcon.SetTextColor = E.noop

		header.isSkinned = true
	end
end

local function SkinOverviewInfoBullets(object)
	local parent = object:GetParent()

	if parent.Bullets then
		for _, bullet in T.pairs(parent.Bullets) do
			if not bullet.styled then
				bullet.Text:SetTextColor(1, 1, 1)
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
			header.flashAnim.Play = E.noop

			header.descriptionBG:SetAlpha(0)
			header.descriptionBGBottom:SetAlpha(0)
			for i = 4, 18 do
				T.select(i, header.button:GetRegions()):SetTexture()
			end

			header.description:SetTextColor(1, 1, 1)
			header.button.title:SetTextColor(T.unpack(E["media"].rgbvaluecolor))
			header.button.title.SetTextColor = E.noop
			header.button.expandedIcon:SetTextColor(1, 1, 1)
			header.button.expandedIcon.SetTextColor = E.noop

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
	local searchBox = _G.EncounterJournal.searchBox
		if not searchBox then return end

		if index == 1 then
		result:SetPoint("TOPLEFT", searchBox, "BOTTOMLEFT", 0, 1)
		result:SetPoint("TOPRIGHT", searchBox, "BOTTOMRIGHT", -5, 1)
		else
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

		local index = 1
		while true do
			local bu = instanceSelect.scroll.child.InstanceButtons[index]
			if not bu then return end

			bu:SetNormalTexture("")
			bu:SetHighlightTexture("")
			bu:SetPushedTexture("")
			bu.bgImage:SetDrawLayer("BACKGROUND", 1)

			local bg = KS:CreateBG(bu.bgImage)
		bg:SetPoint("TOPLEFT", 3, -3)
		bg:SetPoint("BOTTOMRIGHT", -4, 2)
			index = index + 1
		end
end

local function SkinEJButton(button)
	button.UpLeft:SetAlpha(0)
	button.UpRight:SetAlpha(0)
	button.DownLeft:SetAlpha(0)
	button.DownRight:SetAlpha(0)
	select(5, button:GetRegions()):Hide()
	select(6, button:GetRegions()):Hide()
	KS:Reskin(button)
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

					result.resultType:SetTextColor(1, 1, 1)
					result.path:SetTextColor(1, 1, 1)

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
	_G.EncounterJournalEncounterFrameInstanceFrameLoreScrollFrameScrollChildLore:SetTextColor(1, 1, 1)

	--[[ Info ]]
	local info = encounter.info
	info:DisableDrawLayer("BACKGROUND")

	info.encounterTitle:SetTextColor(1, 1, 1)

	SkinEJButton(info.difficulty)

	KS:Reskin(info.reset)

	info.detailsScroll.child.description:SetTextColor(1, 1, 1)

	info.overviewScroll.child.loreDescription:SetTextColor(1, 1, 1)
	info.overviewScroll.child.header:Hide()
	_G.EncounterJournalEncounterFrameInfoOverviewScrollFrameScrollChildTitle:SetFontObject("GameFontNormalLarge")
	_G.EncounterJournalEncounterFrameInfoOverviewScrollFrameScrollChildTitle:SetTextColor(1, 1, 1)
	info.overviewScroll.child.overviewDescription.Text:SetTextColor(1, 1, 1)

	SkinEJButton(info.lootScroll.filter)
	SkinEJButton(info.lootScroll.slotFilter)

	local encLoot = info.lootScroll.buttons
	for i = 1, #encLoot do
		local item = encLoot[i]

		item.boss:SetTextColor(1, 1, 1)
		item.slot:SetTextColor(1, 1, 1)
		item.armorType:SetTextColor(1, 1, 1)

		item.bossTexture:SetAlpha(0)
		item.bosslessTexture:SetAlpha(0)

		item.icon:SetTexCoord(T.unpack(E.TexCoords))
		item.icon:SetDrawLayer("OVERLAY")
		KS:CreateBG(item.icon)

		if item.backdrop then
			item.backdrop:Hide()
		end

		local bg = T.CreateFrame("Frame", nil, item)
		bg:SetPoint("TOPLEFT")
		bg:SetPoint("BOTTOMRIGHT", 0, 1)
		bg:SetFrameLevel(item:GetFrameLevel() - 1)
		KS:CreateBD(bg, .25)

		KS:CreateGradient(bg)
	end

	info.model.dungeonBG:Hide()
	_G.EncounterJournalEncounterFrameInfoModelFrameShadow:Hide()
	KS:CreateBDFrame(_G.EncounterJournalEncounterFrameInfoModelFrame, .25)

	-- [[ Encounter Info Frame ]]
	local EncounterInfo = EncounterJournal.encounter.info

	_G.EncounterJournalEncounterFrameInfoBG:Kill()
	if EncounterInfo.backdrop then
		EncounterInfo.backdrop:Hide()
	end

	 --Tabs
	local tabs = {
		EncounterInfo.overviewTab,
		EncounterInfo.lootTab,
		EncounterInfo.bossTab,
		EncounterInfo.modelTab,
	}

	for _, tab in pairs(tabs) do
		if tab.backdrop then
			tab.backdrop:SetTemplate("Transparent")
			tab.backdrop:Styling()
		end
	end

	--Encounter Instance Frame
	local EncounterInstance = EncounterJournal.encounter.instance
	EncounterInstance.loreScroll.child.lore:SetTextColor(1, 1, 1)

	_G.EncounterJournalEncounterFrameInstanceFrame.titleBG:SetAlpha(0)

	-- [[ Loot ]]
	local LootJournal = _G["EncounterJournal"].LootJournal
	LootJournal:DisableDrawLayer("BACKGROUND")

	-- ToDo: Update me

	-- [[ SuggestFrame ]]
	local suggestFrame = EncounterJournal.suggestFrame
	do
		-- Suggestion 1
		local suggestion = suggestFrame.Suggestion1

		suggestion.bg:Hide()

		KS:CreateBD(suggestion, .25)
		KS:CreateGradient(suggestion)

		suggestion.icon:SetPoint("TOPLEFT", 135, -15)

		local centerDisplay = suggestion.centerDisplay

		centerDisplay.title.text:SetTextColor(1, 1, 1)
		centerDisplay.description.text:SetTextColor(.9, .9, .9)

		KS:Reskin(suggestion.button)

		local reward = suggestion.reward

		reward.text:SetTextColor(.9, .9, .9)
		reward.iconRing:Hide()
		reward.iconRingHighlight:SetTexture("")

		-- Suggestion 2 and 3
		for i = 2, 3 do
			suggestion = suggestFrame["Suggestion"..i]

			suggestion.bg:Hide()

			KS:CreateBD(suggestion, .25)
			KS:CreateGradient(suggestion)

			suggestion.icon:SetPoint("TOPLEFT", 10, -10)

			centerDisplay = suggestion.centerDisplay

			centerDisplay:ClearAllPoints()
			centerDisplay:SetPoint("TOPLEFT", 85, -10)
			centerDisplay.title.text:SetTextColor(1, 1, 1)
			centerDisplay.description.text:SetTextColor(.9, .9, .9)

			reward = suggestion.reward

			reward.iconRing:Hide()
			reward.iconRingHighlight:SetTexture("")
		end
	end

	SafeHook("EJSuggestFrame_RefreshDisplay", function()
		local self = suggestFrame

		if #self.suggestions > 0 then
			local suggestion = self.Suggestion1
			local data = self.suggestions[1]

			suggestion.iconRing:Hide()

			if suggestion and data then
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

				suggestion.iconRing:Hide()

				if data.iconPath then
					suggestion.icon:SetMask("")
					suggestion.icon:SetTexture(data.iconPath)
					suggestion.icon:SetTexCoord(T.unpack(E.TexCoords))
				end
			end
		end
	end)

	SafeHook("EJSuggestFrame_UpdateRewards", function(suggestion)
		local rewardData = suggestion.reward.data
		if rewardData then
			local texture = rewardData.itemIcon or rewardData.currencyIcon or [[Interface\Icons\achievement_guildperk_mobilebanking]]
			suggestion.reward.icon:SetMask("")
			suggestion.reward.icon:SetTexture(texture)

			if not suggestion.reward.icon.backdrop then
				suggestion.reward.icon:CreateBackdrop()
				suggestion.reward.icon.backdrop:SetOutside(suggestion.reward.icon)
			end

			if rewardData.itemID then
				local quality = T.select(3, T.GetItemInfo(rewardData.itemID))
				if quality and quality > 1 then
					r, g, b = T.GetItemQualityColor(quality)
				end
			end
			suggestion.reward.icon.backdrop:SetBackdropBorderColor(r, g, b)
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
