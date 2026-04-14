local KUI, T, E, L, V, P, G = unpack(select(2, ...))
local DT = E:GetModule('DataTexts')
local C_SpecializationInfo = _G.C_SpecializationInfo

local SELECT_LOOT_SPECIALIZATION, LOOT_SPECIALIZATION_DEFAULT = SELECT_LOOT_SPECIALIZATION, LOOT_SPECIALIZATION_DEFAULT
local GetSpecialization = T.GetSpecialization or (C_SpecializationInfo and C_SpecializationInfo.GetSpecialization)
local GetSpecializationInfo = T.GetSpecializationInfo or (C_SpecializationInfo and C_SpecializationInfo.GetSpecializationInfo)
local GetSpecializationInfoByID = T.GetSpecializationInfoByID or _G.GetSpecializationInfoByID or (C_SpecializationInfo and C_SpecializationInfo.GetSpecializationInfoByID)
local GetActiveSpecGroup = T.GetActiveSpecGroup or (C_SpecializationInfo and C_SpecializationInfo.GetActiveSpecGroup)
local GetNumSpecGroups = T.GetNumSpecGroups or _G.GetNumSpecGroups
local GetNumSpecializations = T.GetNumSpecializations or (C_SpecializationInfo and C_SpecializationInfo.GetNumSpecializations)
local SetActiveSpecGroup = T.SetActiveSpecGroup or (C_SpecializationInfo and C_SpecializationInfo.SetActiveSpecGroup)
local GetLootSpecialization = T.GetLootSpecialization or _G.GetLootSpecialization
local SetLootSpecialization = T.SetLootSpecialization or _G.SetLootSpecialization

local lastPanel, active
local displayString = '';
local activeString = T.string_join("", "|cff00FF00" , ACTIVE_PETS, "|r")
local inactiveString = T.string_join("", "|cffFF0000", FACTION_INACTIVE, "|r")

local menuFrame = T.CreateFrame("Frame", "KlixUI_LootSpecializationDatatextClickMenu", E.UIParent, "UIDropDownMenuTemplate")
menuFrame:CreateBackdrop('Transparent')

local menuList = {
	{ text = SELECT_LOOT_SPECIALIZATION, isTitle = true, notCheckable = true },
	{ notCheckable = true, func = function() if SetLootSpecialization then SetLootSpecialization(0) end end },
	{ notCheckable = true },
	{ notCheckable = true },
	{ notCheckable = true },
	{ notCheckable = true }
}

local function OpenSpecMenu(menu, panel)
	if E.EasyMenu and E.SetEasyMenuAnchor and E.ComplicatedMenu then
		E:SetEasyMenuAnchor(E.EasyMenu, panel or E.UIParent)
		E:ComplicatedMenu(menu, E.EasyMenu, nil, nil, nil, "MENU")
		return true
	end

	local easyMenu = T.EasyMenu or _G.EasyMenu
	if easyMenu then
		easyMenu(menu, menuFrame, "cursor", -15, -7, "MENU", 2)
		return true
	end
end

local specList = {
	{ text = SPECIALIZATION, isTitle = true, notCheckable = true },
	{ notCheckable = true },
	{ notCheckable = true },
	{ notCheckable = true },
	{ notCheckable = true }
}

local function GetSpecializationNameByIndex(index)
	if not (index and GetSpecializationInfo) then return end

	local _, name = GetSpecializationInfo(index)
	return name
end

local function GetSpecializationNameByID(specID)
	if not specID then return end

	if GetSpecializationInfoByID then
		local _, name = GetSpecializationInfoByID(specID)
		if name then
			return name
		end
	end

	if GetNumSpecializations and GetSpecializationInfo then
		local numSpecs = GetNumSpecializations()
		if type(numSpecs) == "number" then
			for index = 1, numSpecs do
				local id, name = GetSpecializationInfo(index)
				if id == specID and name then
					return name
				end
			end
		end
	end

	local info = E.SpecInfoBySpecID and E.SpecInfoBySpecID[specID]
	return info and info.name
end

local function OnEvent(self)
	lastPanel = self
	if not (GetSpecialization and GetSpecializationInfo and GetActiveSpecGroup) then
		self.text:SetText('')
		return
	end

	local specIndex = GetSpecialization();
	if not specIndex then return end

	active = GetActiveSpecGroup()

	local talent = ''
	local groupSpecIndex = GetSpecialization(false, false, active)
	if groupSpecIndex then
		local name = GetSpecializationNameByIndex(groupSpecIndex)
		if name then
			talent = T.string_format('%s', name)
		end
	end

	self.text:SetFormattedText('%s', talent)
end

local function OnEnter(self)
	if not (GetSpecialization and GetSpecializationInfo and GetActiveSpecGroup and GetNumSpecGroups) then return end

	DT:SetupTooltip(self)

	for i = 1, GetNumSpecGroups() do
		local specGroup = GetSpecialization(false, false, i)
		if specGroup then
			local name = GetSpecializationNameByIndex(specGroup)
			if name then
				DT.tooltip:AddLine(T.string_join(" ", T.string_format(displayString, name), (i == active and activeString or inactiveString)),1,1,1)
			end
		end
	end

	DT.tooltip:AddLine(' ')
	local specialization = GetLootSpecialization and GetLootSpecialization()
	if specialization == 0 then
		local specIndex = GetSpecialization();

		if specIndex then
			local name = GetSpecializationNameByIndex(specIndex)
			if name then
				DT.tooltip:AddLine(T.string_format('|cffFFFFFF%s:|r %s', SELECT_LOOT_SPECIALIZATION, T.string_format(LOOT_SPECIALIZATION_DEFAULT, name)))
			end
		end
	else
		local name = GetSpecializationNameByID(specialization)
		if name then
			DT.tooltip:AddLine(T.string_format('|cffFFFFFF%s:|r %s', SELECT_LOOT_SPECIALIZATION, name))
		end
	end

	DT.tooltip:AddLine(" ")
	DT.tooltip:AddDoubleLine(L["Left Click:"], L["Change Talent Specialization"], 0.7, 0.7, 1.0)
	DT.tooltip:AddDoubleLine(L["Right Click:"], L["Change Loot Specialization"], 0.7, 0.7, 1.0)
	
	DT.tooltip:Show()
end

local function OnClick(self, button)
	if not (GetSpecialization and GetSpecializationInfo) then return end

	local specIndex = GetSpecialization();
	if not specIndex then return end

	if button == "LeftButton" then
		if not (GetNumSpecGroups and SetActiveSpecGroup) then return end
		if not PlayerTalentFrame then
			T.LoadAddOn("Blizzard_TalentUI")
		end
		for index = 1, GetNumSpecGroups() do
			local specGroup = GetSpecialization(false, false, index)
			local id, name, _, texture = specGroup and GetSpecializationInfo(specGroup);
			name = name or GetSpecializationNameByID(id)
			if id and name and texture then
				specList[index + 1].text = T.string_format('|T%s:14:14:0:0:64:64:4:60:4:60|t  %s', texture, name)
				specList[index + 1].func = function() SetActiveSpecGroup(index) end
			elseif id and name then
				specList[index + 1].text = name
				specList[index + 1].func = function() SetActiveSpecGroup(index) end
			else
				specList[index + 1] = nil
			end
		end
		OpenSpecMenu(specList, self)
	else
		if not (GetNumSpecializations and SetLootSpecialization) then return end
		DT.tooltip:Hide()
		local specName = GetSpecializationNameByIndex(specIndex)
		if specName then
			menuList[2].text = T.string_format(LOOT_SPECIALIZATION_DEFAULT, specName)
		end

		for index = 1, GetNumSpecializations() do
			local id, name = GetSpecializationInfo(index);
			name = name or GetSpecializationNameByID(id)
			if id and name then
				menuList[index + 2].text = name
				menuList[index + 2].func = function() SetLootSpecialization(id) end
			else
				menuList[index + 2] = nil
			end
		end
		OpenSpecMenu(menuList, self)
	end
end

local function ValueColorUpdate(hex, r, g, b)
	displayString = T.string_join("", "|cffFFFFFF%s:|r ")

	if lastPanel ~= nil then
		OnEvent(lastPanel)
	end
end
E['valueColorUpdateFuncs'][ValueColorUpdate] = true

DT:RegisterDatatext('Spec Switch (KUI)', KUI.Title, {"PLAYER_ENTERING_WORLD", "CHARACTER_POINTS_CHANGED", "PLAYER_TALENT_UPDATE", "ACTIVE_TALENT_GROUP_CHANGED"}, OnEvent, nil, OnClick, OnEnter)
