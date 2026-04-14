local KUI, T, E, L, V, P, G = unpack(select(2, ...))

local PADDING = 10
local BUTTON_HEIGHT = 16
local BUTTON_WIDTH = 135
local counter = 0
local hoverVisible = false

KUI.MenuList = {}

local function AddMenuItem(text, func)
	if not text then return end

	T.table_insert(KUI.MenuList, {
		text = text,
		func = func,
	})
end

AddMenuItem(CHARACTER_BUTTON, function() ToggleCharacter("PaperDollFrame") end)
AddMenuItem(SPELLBOOK_ABILITIES_BUTTON, function()
	if not SpellBookFrame:IsShown() then
		T.ShowUIPanel(SpellBookFrame)
	else
		T.HideUIPanel(SpellBookFrame)
	end
end)
AddMenuItem(SPECIALIZATION, function()
	if not PlayerTalentFrame then
		TalentFrame_LoadUI()
	end

	if not PlayerTalentFrame:IsShown() then
		T.ShowUIPanel(PlayerTalentFrame)
		_G["PlayerTalentFrameTab"..SPECIALIZATION_TAB]:Click()
	else
		T.HideUIPanel(PlayerTalentFrame)
	end
end)
AddMenuItem(TALENTS, function()
	if not PlayerTalentFrame then
		TalentFrame_LoadUI()
	end

	if not PlayerTalentFrame:IsShown() then
		T.ShowUIPanel(PlayerTalentFrame)
		_G["PlayerTalentFrameTab"..TALENTS_TAB]:Click()
	else
		T.HideUIPanel(PlayerTalentFrame)
	end
end)
AddMenuItem(LFG_TITLE, function() ToggleLFDParentFrame() end)
AddMenuItem(ACHIEVEMENT_BUTTON, function() ToggleAchievementFrame() end)
AddMenuItem(REPUTATION, function() ToggleCharacter("ReputationFrame") end)
if not E.Mists then
	AddMenuItem(GARRISON_TYPE_8_0_LANDING_PAGE_TITLE, function() GarrisonLandingPageMinimapButton_OnClick() end)
end
AddMenuItem(COMMUNITIES_FRAME_TITLE, function() ToggleGuildFrame() end)
AddMenuItem(L["Calendar"], function() GameTimeFrame:Click() end)
AddMenuItem(MOUNTS, function() ToggleCollectionsJournal(1) end)
AddMenuItem(PET_JOURNAL, function() ToggleCollectionsJournal(2) end)
AddMenuItem(TOY_BOX, function() ToggleCollectionsJournal(3) end)
AddMenuItem(HEIRLOOMS, function() ToggleCollectionsJournal(4) end)
AddMenuItem(WARDROBE, function() ToggleCollectionsJournal(5) end)
AddMenuItem(MACROS, function() GameMenuButtonMacros:Click() end)
AddMenuItem(TIMEMANAGER_TITLE, function() T.ToggleFrame(TimeManagerFrame) end)
AddMenuItem(ENCOUNTER_JOURNAL, function()
	if not T.IsAddOnLoaded("Blizzard_EncounterJournal") then
		EncounterJournal_LoadUI()
	end

	ToggleFrame(EncounterJournal)
end)
AddMenuItem(SOCIAL_BUTTON, function() ToggleFriendsFrame() end)
AddMenuItem(MAINMENU_BUTTON, function()
	if not GameMenuFrame:IsShown() then
		if VideoOptionsFrame:IsShown() then
			VideoOptionsFrameCancel:Click()
		elseif AudioOptionsFrame:IsShown() then
			AudioOptionsFrameCancel:Click()
		elseif InterfaceOptionsFrame:IsShown() then
			InterfaceOptionsFrameCancel:Click()
		end
		CloseMenus()
		CloseAllWindows()
		T.ShowUIPanel(GameMenuFrame)
	else
		T.HideUIPanel(GameMenuFrame)
		MainMenuMicroButton_SetNormal()
	end
end)
AddMenuItem(HELP_BUTTON, function() ToggleHelpFrame() end)
AddMenuItem(BLIZZARD_STORE, function() StoreMicroButton:Click() end)

local function sortFunction(a, b)
	return a.text < b.text
end

table.sort(KUI.MenuList, sortFunction)

local function OnClick(btn)
	local parent = btn:GetParent()
	btn.func()
	T.UIFrameFadeOut(parent, 0.3, parent:GetAlpha(), 0)
	parent.fadeInfo.finishedFunc = function() parent:Hide() end
end

local function OnEnter(btn)
	E:UIFrameFadeIn(btn.hoverTex, .3, 0, 1)
	hoverVisible = true
end

local function OnLeave(btn)
	E:UIFrameFadeOut(btn.hoverTex, .3, 1, 0)
	hoverVisible = false
end

local function ResolveMenuParent(parent)
	if type(parent) == "string" then
		parent = _G[parent]
	end

	if parent and parent.IsObjectType and parent:IsObjectType("Frame") then
		return parent
	end

	return E.UIParent
end

-- added parent, removed the mouse x,y and set menu frame position to any parent corners.
-- Also added delay to autohide
function KUI:Dropmenu(list, frame, parent, pos, xOffset, yOffset, delay, addedSize)
	local db = E.db.KlixUI.gamemenu
	parent = ResolveMenuParent(parent)
	
	local r, g, b
	if db.color == 1 then
		r, g, b = KUI.r, KUI.g, KUI.b
	elseif db.color == 2 then
		r, g, b = KUI:unpackColor(db.customColor)
	else
		r, g, b = KUI:unpackColor(E.db.general.valuecolor)
	end
	
	if not frame.buttons then
		frame.buttons = {}
		frame:SetFrameStrata('DIALOG')
		frame:SetClampedToScreen(true)
		T.table_insert(T.UISpecialFrames, frame:GetName())
		frame:Hide()
		frame:Styling()
	end

	frame:SetParent(parent)

	xOffset = xOffset or 0
	yOffset = yOffset or 0

	for i=1, #frame.buttons do
		frame.buttons[i]:Hide()
	end

	for i=1, #list do 
		if not frame.buttons[i] then
			frame.buttons[i] = T.CreateFrame('Button', nil, frame)

			frame.buttons[i].hoverTex = frame.buttons[i]:CreateTexture(nil, 'OVERLAY')
			frame.buttons[i].hoverTex:SetAllPoints()
			frame.buttons[i].hoverTex:SetTexture(E.Media.Textures.Highlight)
			frame.buttons[i].hoverTex:SetBlendMode('BLEND')
			frame.buttons[i].hoverTex:SetDrawLayer('BACKGROUND')
			frame.buttons[i].hoverTex:SetAlpha(0)

			frame.buttons[i].text = frame.buttons[i]:CreateFontString(nil, 'BORDER')
			frame.buttons[i].text:SetAllPoints()
			frame.buttons[i].text:FontTemplate()
			frame.buttons[i].text:SetJustifyH('LEFT')

			frame.buttons[i]:SetScript('OnEnter', OnEnter)
			frame.buttons[i]:SetScript('OnLeave', OnLeave)
		end

		frame.buttons[i]:Show()
		frame.buttons[i]:Height(BUTTON_HEIGHT)
		frame.buttons[i]:Width(BUTTON_WIDTH + (addedSize or 0))
		frame.buttons[i].text:SetText(list[i].text)
		frame.buttons[i].text:SetTextColor(r, g, b)
		frame.buttons[i].hoverTex:SetVertexColor(r, g, b)
		frame.buttons[i].func = list[i].func
		frame.buttons[i]:SetScript('OnClick', OnClick)

		if i == 1 then
			frame.buttons[i]:Point('TOPLEFT', frame, 'TOPLEFT', PADDING, -PADDING)
		else
			frame.buttons[i]:Point('TOPLEFT', frame.buttons[i-1], 'BOTTOMLEFT')
		end
	end

	frame:SetScript('OnShow', function(self)
		T.UIFrameFadeIn(self, 0.2, self:GetAlpha(), 1)
	end)

	frame:SetScript('OnUpdate', function(self, elapsed)
		if hoverVisible then return end
		counter = counter + elapsed
		if counter >= delay then
			T.UIFrameFadeOut(self, 0.3, self:GetAlpha(), 0)
			self.fadeInfo.finishedFunc = function() self:Hide() end
			counter = 0
		end
	end)

	frame:Height((#list * BUTTON_HEIGHT) + PADDING * 2)
	frame:Width(BUTTON_WIDTH + PADDING * 2 + (addedSize or 0))
	frame:ClearAllPoints()
	if pos == 'tLeft' then
		frame:Point('BOTTOMRIGHT', parent, 'TOPLEFT', xOffset, yOffset)
	elseif pos == 'tRight' then
		frame:Point('BOTTOMLEFT', parent, 'TOPRIGHT', xOffset, yOffset)
	elseif pos == 'bLeft' then
		frame:Point('TOPRIGHT', parent, 'BOTTOMLEFT', xOffset, yOffset)
	elseif pos == 'bRight' then
		frame:Point('TOPLEFT', parent, 'BOTTOMRIGHT', xOffset, yOffset)
	end

	T.ToggleFrame(frame)
end
