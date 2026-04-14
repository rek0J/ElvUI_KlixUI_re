local KUI, T, E, L, V, P, G = unpack(select(2, ...))
local KUIL = KUI:NewModule('KuiLayout', 'AceHook-3.0', 'AceEvent-3.0');
local KS = KUI:GetModule('KuiSkins')
local KC = KUI:GetModule("KuiChat")
local COMP = KUI:GetModule("KuiCompatibility")
local AB = E:GetModule("ActionBars")
local CH = E:GetModule("Chat")
local LO = E:GetModule('Layout')
local DT = E:GetModule('DataTexts')
local M = E:GetModule('Minimap')
local LSM = E.LSM or E.Libs.LSM

local GameTooltip = _G.GameTooltip
local GameMenuButtonAddons = GameMenuButtonAddons

local cp = "|cFF00c0fa" -- +
local cm = "|cff9a1212" -- -

local PANEL_HEIGHT = 21;
local SPACING = (E.PixelMode and 1 or 3)
local BUTTON_NUM = 4

local Kui_dchat = T.CreateFrame('Frame', 'KuiDummyChat', E.UIParent, 'BackdropTemplate')
local Kui_deb = T.CreateFrame('Frame', 'KuiDummyEditBoxHolder', E.UIParent, 'BackdropTemplate')

local menuFrame = T.CreateFrame('Frame', 'KuiGameClickMenu', E.UIParent, 'BackdropTemplate')
menuFrame:SetTemplate('Transparent', true)

local function ToggleElvUIOptions(...)
	local toggleOptions = E.ToggleOptions or E.ToggleOptionsUI
	if toggleOptions then
		toggleOptions(E, ...)
	end
end

function KuiGameMenu_OnMouseUp(self)
	GameTooltip:Hide()
	KUI:Dropmenu(KUI.MenuList, menuFrame, self, 'tLeft', -SPACING, SPACING, 4)
	T.PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF);
end

local function ChatButton_OnClick(self)
	_G.GameTooltip:Hide()

	if E.db[self.parent:GetName()..'Faded'] then
		E.db[self.parent:GetName()..'Faded'] = nil
		T.UIFrameFadeIn(self.parent, 0.2, self.parent:GetAlpha(), 1)
		if T.IsAddOnLoaded('AddOnSkins') then
			local AS = T.unpack(AddOnSkins) or nil
			if AS.db.EmbedSystem or AS.db.EmbedSystemDual then AS:Embed_Show() end
		end
	else
		E.db[self.parent:GetName()..'Faded'] = true
		T.UIFrameFadeOut(self.parent, 0.2, self.parent:GetAlpha(), 0)
		self.parent.fadeInfo.finishedFunc = self.parent.fadeFunc
	end
	T.PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF);
end

local kbuttons = {}

function KUIL:ToggleKuiDts()
	local db = E.db.KlixUI.datatexts.chat
	local edb = E.db.datatexts

	if edb.leftChatPanel or edb.rightChatPanel then
		db.enable = false
		KuiLeftChatDTPanel:Hide()
		KuiRightChatDTPanel:Hide()
	end

	if db.enable then
		if db.showChatDt == 'SHOWBOTH' then
			KuiLeftChatDTPanel:Show()
			KuiRightChatDTPanel:Show()
		elseif db.showChatDt == 'LEFT' then
			if not edb.leftChatPanel then
				KuiLeftChatDTPanel:Show()
			end
			KuiRightChatDTPanel:Hide()
		elseif db.showChatDt == 'RIGHT' then
			KuiLeftChatDTPanel:Hide()
			if not edb.rightChatPanel then
				KuiRightChatDTPanel:Show()
			end
		end
		for i = 1, BUTTON_NUM do
			kbuttons[i]:Show()
		end
	else
		KuiLeftChatDTPanel:Hide()
		KuiRightChatDTPanel:Hide()
		for i = 1, BUTTON_NUM do
			kbuttons[i]:Hide()
		end
	end
end

function KUIL:ResizeMinimapPanels()
	_G.MinimapPanel:Point('TOPLEFT', _G.Minimap.backdrop, 'BOTTOMLEFT', 0, -SPACING)
	_G.MinimapPanel:Point('BOTTOMRIGHT', _G.Minimap.backdrop, 'BOTTOMRIGHT', 0, -(SPACING + PANEL_HEIGHT))
end

function KUIL:ToggleTransparency()
	local db = E.db.KlixUI.datatexts.chat
	local Kui_ldtp = _G.KuiLeftChatDTPanel
	local Kui_rdtp = _G.KuiRightChatDTPanel

	if not db.backdrop then
		Kui_ldtp:SetTemplate('NoBackdrop')
		Kui_rdtp:SetTemplate('NoBackdrop')
		for i = 1, BUTTON_NUM do
			kbuttons[i]:SetTemplate('NoBackdrop')
		end
	else
		if db.transparent then
			Kui_ldtp:SetTemplate('Transparent')
			Kui_rdtp:SetTemplate('Transparent')
			for i = 1, BUTTON_NUM do
				kbuttons[i]:SetTemplate('Transparent')
			end
		else
			Kui_ldtp:SetTemplate('Default', true)
			Kui_rdtp:SetTemplate('Default', true)
			for i = 1, BUTTON_NUM do
				kbuttons[i]:SetTemplate('Default', true)
			end
		end
	end
end

function KUIL:Styles()
	if not E.db.KlixUI.general.style then return end

	local Kui_ldtp = _G.KuiLeftChatDTPanel
	local Kui_rdtp = _G.KuiRightChatDTPanel

	if E.db.KlixUI.datatexts.chat.style then
		Kui_rdtp:Styling()
		Kui_ldtp:Styling()
		for i = 1, BUTTON_NUM do
			kbuttons[i]:Styling()
		end
	end
end

function KUIL:PositionEditBoxHolder(bar)
	Kui_deb:ClearAllPoints()
	Kui_deb:Point('TOPLEFT', bar.backdrop, 'BOTTOMLEFT', 0, -SPACING)
	Kui_deb:Point('BOTTOMRIGHT', bar.backdrop, 'BOTTOMRIGHT', 0, -(PANEL_HEIGHT + 6))
end

local function updateButtonFont()
	for i = 1, BUTTON_NUM do
		if kbuttons[i].text then
			kbuttons[i].text:SetFont(LSM:Fetch('font', E.db.datatexts.font), E.db.datatexts.fontSize, E.db.datatexts.fontOutline)
			kbuttons[i].text:SetTextColor(KUI:unpackColor(E.db.general.valuecolor))
		end
	end
end

local function EnsureKuiDatatextPanelFonts(panelName)
	if DT.GetPanelSettings then
		DT:GetPanelSettings(panelName)
	elseif not DT.db.panels[panelName] then
		DT.db.panels[panelName] = {}
	end

	local db = DT.db.panels[panelName]
	local defaults = G.datatexts and G.datatexts.newPanelInfo and G.datatexts.newPanelInfo.fonts
	if not defaults then return end

	if not db.fonts then
		db.fonts = {}
	end

	if db.fonts.enable == nil then
		db.fonts.enable = defaults.enable
	end
	if not db.fonts.font then
		db.fonts.font = defaults.font
	end
	if type(db.fonts.fontSize) ~= "number" then
		db.fonts.fontSize = defaults.fontSize
	end
	if not db.fonts.fontOutline then
		db.fonts.fontOutline = defaults.fontOutline
	end
end

local function EnsureKuiDatatextLoadedInfo()
	if not DT.db or not DT.LoadedInfo then return end

	if not DT.LoadedInfo.font then
		DT.LoadedInfo.font = LSM:Fetch('font', DT.db.font)
	end
	if type(DT.LoadedInfo.fontSize) ~= "number" then
		DT.LoadedInfo.fontSize = DT.db.fontSize
	end
	if not DT.LoadedInfo.fontOutline then
		DT.LoadedInfo.fontOutline = DT.db.fontOutline
	end
end

local function Panel_OnShow(self)
	self:SetFrameLevel(0)
end

local function ShowOrHideBar4(bar, button)
	if E.db.actionbar.bar4.enabled == true then
		E.db.actionbar.bar4.enabled = false
	elseif E.db.actionbar.bar4.enabled == false then
		E.db.actionbar.bar4.enabled = true
	end
	AB:UpdateButtonSettings("bar4")
end

local function ShowOrHideBar5(bar, button)
	if E.db.actionbar.bar5.enabled == true then
		E.db.actionbar.bar5.enabled = false
	elseif E.db.actionbar.bar5.enabled == false then
		E.db.actionbar.bar5.enabled = true
	end
	AB:UpdateButtonSettings("bar5")
end

local function MoveButtonBar(button, bar)
	if button == kbuttons4 then
		if E.db.actionbar.bar4.enabled == true then
			button.text:SetText(cm.."-|r")
		else
			button.text:SetText(cp.."+|r")
		end
	end

	if button == kbuttons2 then
		if E.db.actionbar.bar5.enabled == true then
			button.text:SetText(cm.."-|r")
		else
			button.text:SetText(cp.."+|r")
		end
	end
end

local function UpdateBar4(self, bar)
	GameTooltip:Hide()
	if T.InCombatLockdown() then KUI:Print(ERR_NOT_IN_COMBAT) return end
	local button = self

	ShowOrHideBar4(bar, button)
	MoveButtonBar(button, bar)
end

local function UpdateBar5(self, bar)
	GameTooltip:Hide()
	if T.InCombatLockdown() then KUI:Print(ERR_NOT_IN_COMBAT) return end
	local button = self

	ShowOrHideBar5(bar, button)
	MoveButtonBar(button, bar)
end

function KUIL:SpecandEquipBar_OnClick()
	GameTooltip:Hide()

	if SpecializationBar:IsShown() and EquipmentSets:IsShown() then
		SpecializationBar:Hide()
		EquipmentSets:Hide()
	else
		SpecializationBar:Show()
		EquipmentSets:Show()
	end
end

-- ChatButton thx Merathilis
function KUIL:CreateChatButtons()
	if E.db.KlixUI.chat.chatButton ~= true or E.private.chat.enable ~= true then return end

	E.db.KlixUI.chat.expandPanel = 150
	E.db.KlixUI.chat.panelHeight = E.db.KlixUI.chat.panelHeight or E.db.chat.panelHeight

	local panelBackdrop = E.db.chat.panelBackdrop
	local ChatButton = CreateFrame("Frame", "KUIChatButton", _G["LeftChatPanel"].backdrop)
	ChatButton:ClearAllPoints()
	ChatButton:Point("TOPLEFT", _G["LeftChatPanel"].backdrop, "TOPLEFT", 4, -8)
	ChatButton:Size(13, 13)
	if E.db.chat.panelBackdrop == "HIDEBOTH" or E.db.chat.panelBackdrop == "LEFT" then
		ChatButton:SetAlpha(0)
	else
		ChatButton:SetAlpha(0.55)
	end
	ChatButton:SetFrameLevel(_G["LeftChatPanel"]:GetFrameLevel() + 5)

	ChatButton.tex = ChatButton:CreateTexture(nil, "OVERLAY")
	ChatButton.tex:SetInside()
	ChatButton.tex:SetTexture("Interface\\AddOns\\ElvUI_KlixUI\\media\\textures\\chatButton")

	ChatButton:SetScript("OnMouseUp", function (self, btn)
		if InCombatLockdown() then return end
		if btn == "LeftButton" then
			if E.db.KlixUI.chat.isExpanded then
				E.db.chat.panelHeight = E.db.chat.panelHeight - E.db.KlixUI.chat.expandPanel
				CH:PositionChats()
				E.db.KlixUI.chat.isExpanded = false
			else
				E.db.chat.panelHeight = E.db.chat.panelHeight + E.db.KlixUI.chat.expandPanel
				CH:PositionChats()
				E.db.KlixUI.chat.isExpanded = true
			end
		end
	end)

	ChatButton:SetScript("OnEnter", function(self)
		if GameTooltip:IsForbidden() then return end

		self:SetAlpha(0.8)
		GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT", 0, 6)
		GameTooltip:ClearLines()
		if E.db.KlixUI.chat.isExpanded then
			GameTooltip:AddLine(KUI:cOption(L["BACK"]))
		else
			GameTooltip:AddLine(KUI:cOption(L["Expand the chat"]))
		end
		GameTooltip:Show()
		if InCombatLockdown() then GameTooltip:Hide() end
	end)

	ChatButton:SetScript("OnLeave", function(self)
		if E.db.chat.panelBackdrop == "HIDEBOTH" or E.db.chat.panelBackdrop == "LEFT" then
			self:SetAlpha(0)
		else
			self:SetAlpha(0.55)
		end
		GameTooltip:Hide()
	end)
end

-- Gamemenu Buttons
function KUIL:CreateLayout()
	local db = E.db.KlixUI.datatexts
	EnsureKuiDatatextPanelFonts('KuiLeftChatDTPanel')
	EnsureKuiDatatextPanelFonts('KuiRightChatDTPanel')
	
	-- Left dt panel
	local Kui_ldtp = CreateFrame('Frame', 'KuiLeftChatDTPanel', E.UIParent, 'BackdropTemplate')
	Kui_ldtp:SetTemplate('Default', true)
	Kui_ldtp:SetFrameStrata('BACKGROUND')
	Kui_ldtp:Point('TOPLEFT', LeftChatPanel, 'BOTTOMLEFT', (SPACING +PANEL_HEIGHT), -SPACING)
	Kui_ldtp:Point('BOTTOMRIGHT', LeftChatPanel, 'BOTTOMRIGHT', -(SPACING +PANEL_HEIGHT), -PANEL_HEIGHT -SPACING)
	Kui_ldtp:Styling()
	DT:RegisterPanel(KuiLeftChatDTPanel, 3, 'ANCHOR_BOTTOM', 0, -4)

	-- Right dt panel
	local Kui_rdtp = CreateFrame('Frame', 'KuiRightChatDTPanel', E.UIParent, 'BackdropTemplate')
	Kui_rdtp:SetTemplate('Default', true)
	Kui_rdtp:SetFrameStrata('BACKGROUND')
	Kui_rdtp:Point('TOPLEFT', RightChatPanel, 'BOTTOMLEFT', (SPACING +PANEL_HEIGHT), -SPACING)
	Kui_rdtp:Point('BOTTOMRIGHT', RightChatPanel, 'BOTTOMRIGHT', -(SPACING +PANEL_HEIGHT), -PANEL_HEIGHT -SPACING)
	Kui_rdtp:Styling()
	DT:RegisterPanel(KuiRightChatDTPanel, 3, 'ANCHOR_BOTTOM', 0, -4)

	-- dummy frame for chat/threat (left)
	Kui_dchat:SetFrameStrata('LOW')
	Kui_dchat:Point('TOPLEFT', LeftChatPanel, 'BOTTOMLEFT', 0, -SPACING)
	Kui_dchat:Point('BOTTOMRIGHT', LeftChatPanel, 'BOTTOMRIGHT', 0, -PANEL_HEIGHT -SPACING)

	-- Buttons
	for i = 1, BUTTON_NUM do
		kbuttons[i] = T.CreateFrame('Button', 'KuiButton_'..i, E.UIParent, 'BackdropTemplate')
		kbuttons[i]:RegisterForClicks('AnyUp')
		kbuttons[i]:SetFrameStrata("BACKGROUND")
		kbuttons[i]:CreateSoftGlow()
		kbuttons[i].sglow:Hide()
		kbuttons[i].text = kbuttons[i]:CreateFontString(nil, 'OVERLAY')
		kbuttons[i].text:FontTemplate(LSM:Fetch('font', E.db.datatexts.font), E.db.datatexts.fontSize, E.db.datatexts.fontOutline)
		kbuttons[i].text:SetPoint('CENTER', 1, 0)
		kbuttons[i].text:SetJustifyH('CENTER')
		kbuttons[i].text:SetTextColor(KUI:unpackColor(E.db.general.valuecolor))

		-- ElvUI Config
		if i == 1 then
			kbuttons[i]:Point('TOPLEFT', Kui_rdtp, 'TOPRIGHT', SPACING, 0)
			kbuttons[i]:Point('BOTTOMRIGHT', Kui_rdtp, 'BOTTOMRIGHT', PANEL_HEIGHT + SPACING, 0)
			kbuttons[i].parent = RightChatPanel
			kbuttons[i].text:SetText('C')

			kbuttons[i]:SetScript('OnEnter', function(self)
				GameTooltip:SetOwner(self, 'ANCHOR_TOPRIGHT', 0, 2)
				GameTooltip:ClearLines()
				GameTooltip:AddLine(L['Left Click: Toggle Configuration'], selectioncolor)
				if T.IsAddOnLoaded('AddOnSkins') then
					GameTooltip:AddLine(L['Right Click: Toggle Embedded Addon'], selectioncolor)
				elseif E.db.datatexts.battleground == true then
					GameTooltip:AddLine(L['Right Click: Toggle Battleground DataTexts'], selectioncolor)
				end
				GameTooltip:AddLine(L['Shift + Click: Toggle Chat'], 0.7, 0.7, 1)
				GameTooltip:AddLine(L['Control + Click: Toggle |cfff960d9KlixUI|r Configuration'], 0.7, 0.7, 1)
				self.sglow:Show()

				if T.IsShiftKeyDown() then
					self.text:SetText('>')
					self:SetScript('OnClick', ChatButton_OnClick)
				else
					self.text:SetText('C')
					self:SetScript('OnClick', function(self, btn)
					if T.IsControlKeyDown() then
						KUI:DasOptions()
					elseif btn == 'LeftButton' then
							ToggleElvUIOptions()
						else
							if T.IsAddOnLoaded('AddOnSkins') then
								local AS = T.unpack(AddOnSkins) or nil
								if AS:CheckOption('EmbedRightChat') then
									if EmbedSystem_MainWindow:IsShown() then
										AS:SetOption('EmbedIsHidden', true)
										EmbedSystem_MainWindow:Hide()
									else
										AS:SetOption('EmbedIsHidden', false)
										EmbedSystem_MainWindow:Show()
									end
								end
							else
								if E.db.datatexts.battleground == true then
								E:BGStats()
								else return end
							end
						end
						T.PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF);
					end)
				end

				GameTooltip:Show()
				if T.InCombatLockdown() then GameTooltip:Hide() end
			end)

			kbuttons[i]:SetScript('OnLeave', function(self)
				self.text:SetText('C')
				self.sglow:Hide()
				GameTooltip:Hide()
			end)
			
		-- Game menu button
		elseif i == 2 then
			kbuttons[i]:Point('TOPRIGHT', Kui_rdtp, 'TOPLEFT', -SPACING, 0)
			kbuttons[i]:Point('BOTTOMLEFT', Kui_rdtp, 'BOTTOMLEFT', -(PANEL_HEIGHT + SPACING), 0)
			kbuttons[i].parent = ElvUI_Bar5
			kbuttons[i].text:SetText('G')

			kbuttons[i]:SetScript('OnEnter', function(self)
				self.sglow:Show()
				if T.IsShiftKeyDown() then
						if E.db.actionbar.bar5.enabled == true then -- double check for login
							kbuttons[i].text:SetText(cm.."-|r")
						else
							kbuttons[i].text:SetText(cp.."+|r")
						end
					self:SetScript('OnClick', UpdateBar5)
				else
				self:SetScript('OnClick', function(self, btn)
					if btn == "LeftButton" then
						KuiGameMenu_OnMouseUp(self)
					
						end
					end)
				end
				GameTooltip:SetOwner(self, 'ANCHOR_TOPRIGHT', 0, 2)
				GameTooltip:ClearLines()
				GameTooltip:AddLine(L['Left Click: Toggle |cfff960d9KlixUI |r']..MAINMENU_BUTTON, selectioncolor)
				GameTooltip:AddLine(L['Shift + Click: Toggle ActionBar5'], 0.7, 0.7, 1)
				GameTooltip:Show()
				if T.InCombatLockdown() or KuiGameClickMenu:IsShown() then GameTooltip:Hide() end
			end)
			
			kbuttons[i]:SetScript('OnLeave', function(self)
				self.text:SetText('G')
				self.sglow:Hide()
				GameTooltip:Hide()
			end)

		-- Voice/AddOns Button
		elseif i == 3 then
			kbuttons[i]:Point('TOPRIGHT', Kui_ldtp, 'TOPLEFT', -SPACING, 0)
			kbuttons[i]:Point('BOTTOMLEFT', Kui_ldtp, 'BOTTOMLEFT', -(PANEL_HEIGHT + SPACING), 0)
			kbuttons[i].text:SetText('A')
			kbuttons[i].parent = _G.LeftChatPanel

			kbuttons[i]:SetScript('OnEnter', function(self)
				self.sglow:Show()
				if T.IsShiftKeyDown() then
					self.text:SetText('<')
					self:SetScript('OnClick', ChatButton_OnClick)
				else
				self:SetScript('OnClick', function(self, btn)
					if T.IsControlKeyDown() and E.db.KlixUI.actionbars.SEBar.enable then
						KUIL:SpecandEquipBar_OnClick(self)
					elseif btn == "LeftButton" then
						if (E.db.KlixUI.addonpanel.Enable and not (COMP.PA and _G.ProjectAzilroka.db["stAddonManager"]['Enable'])) then
							if APFrame:IsShown() then
								APFrame:Hide()
							else
								APFrame:Show()
							end
						else
							GameMenuButtonAddons:Click()
						end
					elseif btn == "RightButton" then
						KUI:GetModule("KuiEmotes").ChatEmote.ToggleEmoteTable()
					end
				end)
				end
				GameTooltip:SetOwner(self, 'ANCHOR_TOPLEFT', 0, 2)
				GameTooltip:ClearLines()
				GameTooltip:AddLine(L['Left Click: Toggle Addon List'], selectioncolor)
				GameTooltip:AddLine(L['Right Click: Toggle Emoticons'], selectioncolor)
				GameTooltip:AddLine(L['Shift + Click: Toggle Chat'], 0.7, 0.7, 1)
				if E.db.KlixUI.actionbars.SEBar.enable then
					GameTooltip:AddLine(L['Control + Click: Toggle Spec & Equip Bar'], 0.7, 0.7, 1)
				end
				GameTooltip:Show()
				if T.InCombatLockdown() then GameTooltip:Hide() end
			end)

			kbuttons[i]:SetScript('OnLeave', function(self)
				self.text:SetText('A')
				self.sglow:Hide()
				GameTooltip:Hide()
			end)

		-- LFG Button
		elseif i == 4 then
			kbuttons[i]:Point('TOPLEFT', Kui_ldtp, 'TOPRIGHT', SPACING, 0)
			kbuttons[i]:Point('BOTTOMRIGHT', Kui_ldtp, 'BOTTOMRIGHT', PANEL_HEIGHT + SPACING, 0)
			kbuttons[i].parent = ElvUI_Bar4
			kbuttons[i].text:SetText('L')
			
			kbuttons[i]:SetScript('OnEnter', function(self)
				self.sglow:Show()
				if T.IsShiftKeyDown() then
						if E.db.actionbar.bar4.enabled == true then -- double check for login
							kbuttons[i].text:SetText(cm.."-|r")
						else
							kbuttons[i].text:SetText(cp.."+|r")
						end
					self:SetScript('OnClick', UpdateBar4)
				else
				self:SetScript('OnClick', function(self, btn)
			                        if btn == "LeftButton" then 
							T.PVEFrame_ToggleFrame()
							T.PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF);
						elseif btn == "RightButton" then
							T.ToggleCommunitiesFrame()
						end
					end)
				end
				GameTooltip:SetOwner(self, 'ANCHOR_TOPLEFT', 0, 2)
				GameTooltip:ClearLines()
				GameTooltip:AddLine(L['Left Click: Toggle Looking for Group'], selectioncolor)
				GameTooltip:AddLine(L['Right Click: Toggle Guild & Communities'], selectioncolor)
				GameTooltip:AddLine(L['Shift + Click: Toggle ActionBar4'], 0.7, 0.7, 1)
				GameTooltip:Show()
				if T.InCombatLockdown() then GameTooltip:Hide() end
			end)
			
			kbuttons[i]:SetScript('OnLeave', function(self)
				self.text:SetText('L')
				self.sglow:Hide()
				GameTooltip:Hide()
			end)
		end
	end
	
	MinimapPanel:Height(PANEL_HEIGHT)
	ElvUI_BottomPanel:SetScript('OnShow', Panel_OnShow)
	ElvUI_BottomPanel:SetFrameLevel(0)
	ElvUI_TopPanel:SetScript('OnShow', Panel_OnShow)
	ElvUI_TopPanel:SetFrameLevel(0)

	LeftChatPanel.backdrop:Styling()
	RightChatPanel.backdrop:Styling()

-- Minimap elements styling
       if E.private.general.minimap.enable then Minimap.backdrop:Styling() end
end

function KUIL:ChangeLayout()
	if CopyChatFrame then CopyChatFrame:Styling() end

	self:ResizeMinimapPanels()
	self:ToggleTransparency()
end

-- Based on CodeNameBlaze chat lines
function KUIL:CreateAndModifyChatPanels()
	--Left Chat Tab Separator
	local ltabseparator = T.CreateFrame('Frame', 'LeftChatTabSeparator', _G.LeftChatPanel, 'BackdropTemplate')
	ltabseparator:SetFrameStrata('BACKGROUND')
	ltabseparator:SetFrameLevel(_G.LeftChatPanel:GetFrameLevel() + 2)
	ltabseparator:Size(E.db.chat.panelWidth - 10, 1)
	ltabseparator:Point('TOP', LeftChatPanel, 0, -24)
	ltabseparator:SetTemplate('Transparent')
	
	--Right Chat Tab Separator
	local rtabseparator = T.CreateFrame('Frame', 'RightChatTabSeparator', _G.RightChatPanel, 'BackdropTemplate')
	rtabseparator:SetFrameStrata('BACKGROUND')
	rtabseparator:SetFrameLevel(_G.RightChatPanel:GetFrameLevel() + 2)
	rtabseparator:Size(E.db.chat.panelWidth - 10, 1)
	rtabseparator:Point('TOP', RightChatPanel, 0, -24)
	rtabseparator:SetTemplate('Transparent')
end
hooksecurefunc(LO, "CreateChatPanels", KUIL.CreateAndModifyChatPanels)

--KlixUI Panels
function KUIL:TopPanelLayout()
	local db = E.db.KlixUI.misc.panels.top
	local frame = ElvUI_TopPanel

	if E.db.KlixUI.general.style then
		if db.style then
			ElvUI_TopPanel:Styling()
		else
			if frame.squares or frame.gradient or frame.mshadow then
				ElvUI_TopPanel.squares:SetTexture(nil)
				ElvUI_TopPanel.gradient:SetTexture(nil)
				ElvUI_TopPanel.mshadow:SetTexture(nil)
			end
		end
	end

	if db.transparency then
		ElvUI_TopPanel:SetTemplate('Transparent')
	else
		ElvUI_TopPanel:SetTemplate('Default')
	end

	ElvUI_TopPanel:Height(db.height)

end

function KUIL:BottomPanelLayout()
	local db = E.db.KlixUI.misc.panels.bottom
	local frame = ElvUI_BottomPanel

	if E.db.KlixUI.general.style then
		if db.style then
			ElvUI_BottomPanel:Styling()
		else
			if frame.squares or frame.gradient or frame.mshadow then
				ElvUI_BottomPanel.squares:SetTexture(nil)
				ElvUI_BottomPanel.gradient:SetTexture(nil)
				ElvUI_BottomPanel.mshadow:SetTexture(nil)
			end
		end
	end

	if db.transparency then
		ElvUI_BottomPanel:SetTemplate('Transparent')
	else
		ElvUI_BottomPanel:SetTemplate('Default')
	end

	ElvUI_BottomPanel:Height(db.height)
end

function KUIL:SetShadowLevel(n)
	self.f:SetAlpha(n/100)
end

--KlixUI Shadow Overlay
function KUIL:ShadowOverlay()
	-- Based on ncShadow, Credits go to Merathilis
	if not E.db.KlixUI.general.shadowOverlay.enable then return end

	self.f = T.CreateFrame("Frame", KUI.Title.."ShadowBackground")
	self.f:Point("TOPLEFT")
	self.f:Point("BOTTOMRIGHT")
	self.f:SetFrameLevel(0)
	self.f:SetFrameStrata("BACKGROUND")

	self.f.tex = self.f:CreateTexture()
	self.f.tex:SetTexture([[Interface\Addons\ElvUI_KlixUI\media\textures\overlay]])
	self.f.tex:SetAllPoints(self.f)
	
	self:SetShadowLevel(E.db.KlixUI.general.shadowOverlay.alpha or 60)
end

-- Based on CodeNameBlaze chat lines
function KUIL:ToggleChatSeparators()
	if E.db.KlixUI.chat.chatTabSeparator == 'SHOWBOTH' then
		_G.LeftChatTabSeparator:Show()
		_G.RightChatTabSeparator:Show()
	elseif E.db.KlixUI.chat.chatTabSeparator == 'HIDEBOTH' then
		_G.LeftChatTabSeparator:Hide()
		_G.RightChatTabSeparator:Hide()
	elseif E.db.KlixUI.chat.chatTabSeparator == 'LEFTONLY' then
		_G.LeftChatTabSeparator:Show()
		_G.RightChatTabSeparator:Hide()
	elseif E.db.KlixUI.chat.chatTabSeparator == 'RIGHTONLY' then
		_G.LeftChatTabSeparator:Hide()
		_G.RightChatTabSeparator:Show()
	end
end

function KUIL:regEvents()
	self:ToggleTransparency()
end

function KUIL:PLAYER_ENTERING_WORLD(...)
	self:ToggleChatSeparators()
	self:ToggleKuiDts()
	self:regEvents()
	EnsureKuiDatatextPanelFonts('KuiLeftChatDTPanel')
	EnsureKuiDatatextPanelFonts('KuiRightChatDTPanel')
	EnsureKuiDatatextLoadedInfo()

	DT:UpdatePanelInfo('KuiLeftChatDTPanel')
	DT:UpdatePanelInfo('KuiRightChatDTPanel')

	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
end

local function InjectDatatextOptions()
	E.Options.args.datatexts.args.panels.args.KuiLeftChatDTPanel.name = KUI.Title..KUI:cOption(L['Left Chat Panel'])
	E.Options.args.datatexts.args.panels.args.KuiLeftChatDTPanel.order = 1001

	E.Options.args.datatexts.args.panels.args.KuiRightChatDTPanel.name = KUI.Title..KUI:cOption(L['Right Chat Panel'])
	E.Options.args.datatexts.args.panels.args.KuiRightChatDTPanel.order = 1002
end


function KUIL:Initialize()
	self:CreateLayout()
	self:TopPanelLayout()
	self:BottomPanelLayout()
	self:CreateChatButtons()	
	self:Styles()
	
	hooksecurefunc(LO, 'ToggleChatPanels', KUIL.ToggleKuiDts)
	hooksecurefunc(LO, 'ToggleChatPanels', KUIL.ResizeMinimapPanels)
	hooksecurefunc(M, 'UpdateSettings', KUIL.ResizeMinimapPanels)
	hooksecurefunc(DT, 'UpdatePanelInfo', KUIL.ToggleTransparency)
	hooksecurefunc(DT, 'LoadDataTexts', updateButtonFont)
	hooksecurefunc(E, 'UpdateMedia', updateButtonFont)
	
	self:ShadowOverlay()
	self:ToggleChatSeparators()
	self:RegisterEvent('PLAYER_ENTERING_WORLD')
	self:RegisterEvent('ACTIVE_TALENT_GROUP_CHANGED', 'regEvents')
end

KUI:RegisterModule(KUIL:GetName())
