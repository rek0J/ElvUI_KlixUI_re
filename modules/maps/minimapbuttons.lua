local KUI, T, E, L, V, P, G = unpack(select(2, ...))
local SMB = KUI:NewModule("KuiSquareMinimapButtons", "AceEvent-3.0", "AceHook-3.0", "AceTimer-3.0")
local COMP = KUI:GetModule("KuiCompatibility")
local floor = math.floor
local ceil = math.ceil
local max = math.max
local min = math.min
local ipairs = ipairs
local sort = table.sort
local strgmatch = string.gmatch
local strupper = string.upper
local strtrim = strtrim

SMB.Buttons = {}
SMB.Collapsed = false

local ignoreButtons = {
	'HelpOpenWebTicketButton',
	'MiniMapVoiceChatFrame',
	'TimeManagerClockButton',
	'BattlefieldMinimap',
	'ButtonCollectFrame',
	'GameTimeFrame',
	'QueueStatusMinimapButton',
	'GarrisonLandingPageMinimapButton',
	'MiniMapMailFrame',
	'MiniMapTracking',
	'MinimapZoomIn',
	'MinimapZoomOut',
	'TukuiMinimapZone',
	'TukuiMinimapCoord',
	'RecipeRadarMinimapButtonFrame',
}

local GenericIgnores = {
	'Archy',
	'GatherMatePin',
	'GatherNote',
	'GuildInstance',
	'HandyNotesPin',
	'MiniMap',
	'Spy_MapNoteList_mini',
	'ZGVMarker',
	'poiMinimap',
	'GuildMap3Mini',
	'LibRockConfig-1.0_MinimapButton',
	'NauticusMiniIcon',
	'WestPointer',
	'Cork',
	'DugisArrowMinimapPoint',
	'QuestieFrame',
}

local PartialIgnores = { 'Node', 'Note', 'Pin', 'POI' }

local ButtonFunctions = { 'SetParent', 'ClearAllPoints', 'SetPoint', 'SetSize', 'SetScale', 'SetFrameStrata', 'SetFrameLevel' }
local DecorativeTextureIDs = {
	[-2718] = true,
	[136430] = true,
	[136467] = true,
	[136477] = true,
}

local function HasTexture(texture)
	return texture and texture.IsObjectType and texture:IsObjectType('Texture') and texture.GetTexture and texture:GetTexture()
end

local function IsDecorativeTextureValue(texture, layer)
	if not texture then return true end
	if DecorativeTextureIDs[texture] then return true end
	if layer == "BACKGROUND" or layer == "BORDER" or layer == "HIGHLIGHT" then
		return true
	end

	local textureString = T.string_lower(T.tostring(texture))
	return textureString:find("border", 1, true) or textureString:find("background", 1, true) or textureString:find("overlay", 1, true) or textureString:find("highlight", 1, true) or textureString:find("mask", 1, true) or textureString:find("ring", 1, true)
end

local function IsLibDBIconButton(Button)
	if not Button then return false end

	local name = Button.GetName and Button:GetName()
	return (name and T.string_sub(name, 1, 12) == "LibDBIcon10_") or (Button.dataObject ~= nil)
end

local function GetPrimaryIconTexture(Button)
	if not Button then return end

	local name = Button.GetName and Button:GetName()
	local candidates = {
		Button.icon,
		Button.Icon,
		name and _G[name.."Icon"] or nil,
		name and _G[name.."IconTexture"] or nil,
		Button.GetNormalTexture and Button:GetNormalTexture() or nil,
	}

	for _, texture in ipairs(candidates) do
		if HasTexture(texture) and not IsDecorativeTextureValue(texture:GetTexture(), texture.GetDrawLayer and texture:GetDrawLayer()) then
			return texture
		end
	end

	for i = 1, Button:GetNumRegions() do
		local region = T.select(i, Button:GetRegions())
		if HasTexture(region) and not IsDecorativeTextureValue(region:GetTexture(), region.GetDrawLayer and region:GetDrawLayer()) then
			return region
		end
	end

	for _, texture in ipairs(candidates) do
		if HasTexture(texture) then
			return texture
		end
	end

	for i = 1, Button:GetNumRegions() do
		local region = T.select(i, Button:GetRegions())
		if HasTexture(region) then
			return region
		end
	end
end

local function IsDecorativeTexture(region)
	if not region or not region.IsObjectType or not region:IsObjectType("Texture") then return false end

	local texture = region.GetTexture and region:GetTexture()
	local layer = region.GetDrawLayer and region:GetDrawLayer()
	return IsDecorativeTextureValue(texture, layer)
end

local function GetTextureTexCoords(texture)
	if not texture or not texture.GetTexCoord then return end

	local coords = { texture:GetTexCoord() }
	if #coords == 4 and coords[1] ~= nil then
		local left, right, top, bottom = coords[1], coords[2], coords[3], coords[4]
		return left, right, top, bottom
	end
end

local function NormalizeButtonToken(token)
	token = token and strtrim(T.tostring(token)) or ""
	token = token:gsub("%s+", "")
	return strupper(token)
end

local function BuildButtonAliases(key, kind)
	local aliases = {}
	key = NormalizeButtonToken(key)
	if not key or key == "" then return aliases end

	aliases[key] = true

	if kind ~= "blizzard" then
		local short = key
		short = short:gsub("^LIBDBICON10_", "")
		short = short:gsub("^LIBDBICON_", "")
		short = short:gsub("^MINIMAPBUTTON_", "")
		short = short:gsub("MINIMAPBUTTON$", "")
		short = short:gsub("_BUTTON$", "")
		short = short:gsub("BUTTON$", "")
		short = short:gsub("^SMB_", "")
		short = NormalizeButtonToken(short)

		if short ~= "" then
			aliases[short] = true
		end
	end

	return aliases
end

local function GetPreferredButtonToken(aliases, fallback)
	local preferred = fallback

	for alias in T.pairs(aliases or {}) do
		if not preferred or #alias < #preferred then
			preferred = alias
		end
	end

	return preferred or fallback
end

local function MatchesButtonTokenSet(buttonData, tokenSet)
	if not buttonData or not tokenSet then return false end
	if buttonData.key and tokenSet[buttonData.key] then return true end

	for alias in T.pairs(buttonData.aliases or {}) do
		if tokenSet[alias] then
			return true
		end
	end

	return false
end

local function ParseButtonTokens(value)
	local tokens, hasTokens, ordered, orderMap = {}, false, {}, {}

	for token in strgmatch(value or "", "[^,\r\n;]+") do
		token = NormalizeButtonToken(token)
		if token ~= "" and not tokens[token] then
			tokens[token] = true
			orderMap[token] = #ordered + 1
			T.table_insert(ordered, token)
			hasTokens = true
		end
	end

	return tokens, hasTokens, ordered, orderMap
end

local function GetButtonTokenOrder(buttonData, orderMap)
	if not buttonData or not orderMap then return end
	if buttonData.key and orderMap[buttonData.key] then
		return orderMap[buttonData.key]
	end

	local best
	for alias in T.pairs(buttonData.aliases or {}) do
		local order = orderMap[alias]
		if order and (not best or order < best) then
			best = order
		end
	end

	return best
end

local function GetGrowthSettings(direction)
	if direction == "LEFT_DOWN" then
		return true, false, true
	elseif direction == "RIGHT_UP" then
		return true, true, false
	elseif direction == "LEFT_UP" then
		return true, false, false
	elseif direction == "DOWN_RIGHT" then
		return false, true, true
	elseif direction == "DOWN_LEFT" then
		return false, false, true
	elseif direction == "UP_RIGHT" then
		return false, true, false
	elseif direction == "UP_LEFT" then
		return false, false, false
	end

	return true, true, true
end

function SMB:LockButton(Button)
	for _, Function in T.pairs(ButtonFunctions) do
		Button[Function] = KUI.dummy
	end
end

function SMB:UnlockButton(Button)
	for _, Function in T.pairs(ButtonFunctions) do
		Button[Function] = nil
	end
end

function SMB:RegisterButton(Button, key, kind)
	if not Button then return end

	Button.SMBData = Button.SMBData or {}
	Button.SMBData.key = NormalizeButtonToken(key or Button:GetName())
	Button.SMBData.kind = kind or Button.SMBData.kind or "addon"
	Button.SMBData.aliases = BuildButtonAliases(Button.SMBData.key, Button.SMBData.kind)
	Button.SMBData.displayKey = GetPreferredButtonToken(Button.SMBData.aliases, Button.SMBData.key)

	if not Button.SMBRegistered then
		Button.SMBRegistered = true
		T.table_insert(self.Buttons, Button)
	end
end

function SMB:GetDiscoveredButtonKeys()
	local tokens = {}
	local added = {}

	for _, Button in ipairs(self.Buttons or {}) do
		local data = Button.SMBData
		local displayKey = data and data.displayKey
		if displayKey and not added[displayKey] then
			added[displayKey] = true
			T.table_insert(tokens, displayKey)
		end
	end

	return tokens
end

function SMB:GetAvailableButtonTokens()
	local tokens = {}
	local added = {}

	for _, Button in ipairs(self.Buttons or {}) do
		local data = Button.SMBData
		local displayKey = data and data.displayKey
		local key = data and data.key
		local kind = data and data.kind

		if displayKey and not added[displayKey] then
			added[displayKey] = true
			T.table_insert(tokens, kind == "blizzard" and displayKey or (displayKey ~= key and (displayKey .. " (" .. key .. ")") or displayKey))
		end
	end

	sort(tokens, function(a, b) return a < b end)
	return tokens
end

function SMB:GetButtonTokensTooltipText(prefix)
	local tokens = self:GetAvailableButtonTokens()
	local tokenText = #tokens > 0 and T.table_concat(tokens, ", ") or "No buttons detected yet."

	if prefix and prefix ~= "" then
		return prefix .. "\n\nAvailable entries:\n" .. tokenText
	end

	return "Available entries:\n" .. tokenText
end

function SMB:SyncConfiguredLists()
	local discovered = self:GetDiscoveredButtonKeys()
	if #discovered == 0 then return end

	local knownSet, _, knownOrdered = ParseButtonTokens(self.db.knownButtons)
	local whiteSet, hasWhiteList, whiteOrdered = ParseButtonTokens(self.db.whitelist)
	local _, hasBlackList = ParseButtonTokens(self.db.blacklist)
	local _, hasCollapsedList = ParseButtonTokens(self.db.collapsedButtons)
	local changed = false

	if not hasWhiteList then
		whiteOrdered = {}
		whiteSet = {}
		for _, token in ipairs(discovered) do
			whiteSet[token] = true
			T.table_insert(whiteOrdered, token)
		end
		self.db.whitelist = T.table_concat(whiteOrdered, ",")
		changed = true
	end

	for _, token in ipairs(discovered) do
		if not knownSet[token] then
			knownSet[token] = true
			T.table_insert(knownOrdered, token)

			if not whiteSet[token] then
				whiteSet[token] = true
				T.table_insert(whiteOrdered, token)
				self.db.whitelist = T.table_concat(whiteOrdered, ",")
			end

			changed = true
		end
	end

	if not hasBlackList then
		self.db.blacklist = "MAIL,TRACKING,QUEUE"
		changed = true
	end

	if not hasCollapsedList then
		self.db.collapsedButtons = "KLIXUI"
		changed = true
	end

	if changed then
		self.db.knownButtons = T.table_concat(knownOrdered, ",")
	end
end

function SMB:RefreshButtonFilters()
	self.WhiteListButtons, self.HasWhiteList, self.WhiteListOrder, self.WhiteListOrderMap = ParseButtonTokens(self.db.whitelist)
	self.BlackListButtons, self.HasBlackList, self.BlackListOrder, self.BlackListOrderMap = ParseButtonTokens(self.db.blacklist)
	self.CollapsedButtons, self.HasCollapsedButtons, self.CollapsedButtonOrder, self.CollapsedButtonsOrderMap = ParseButtonTokens(self.db.collapsedButtons)
	self.Collapsed = self.db.enableCollapse and self.db.collapsed
end

function SMB:ApplyBarPosition()
	if not self.Bar or not self.db.useCustomPosition then return end

	local parent = self.db.dockToMinimap and _G.Minimap or UIParent
	if not parent then parent = UIParent end

	self.Bar:ClearAllPoints()
	self.Bar:SetPoint(self.db.point or "TOPRIGHT", parent, self.db.relativePoint or "BOTTOMRIGHT", self.db.xOffset or 0, self.db.yOffset or 0)
end

function SMB:UpdateCollapseToggle()
	if not self.Toggle then return end

	if self.db.enableCollapse then
		self.Toggle:Show()
		self.Toggle.text:SetText(self.Collapsed and "+" or "-")
		self.Toggle:ClearAllPoints()
		self.Toggle:SetPoint("BOTTOMRIGHT", self.Bar, "TOPRIGHT", 0, 2)
	else
		self.Toggle:Hide()
	end
end

function SMB:ShouldKeepButton(Button, collapsed)
	if not Button or not Button.SMBData then return false end

	local available = Button:GetParent() == self.Hider or Button:IsShown()
	if not available then return false end

	local kind = Button.SMBData.kind or "addon"
	local source = self.db.buttonSource or "ALL"

	if source == "ADDON" and kind == "blizzard" then return false end
	if source == "BLIZZARD" and kind ~= "blizzard" then return false end
	if MatchesButtonTokenSet(Button.SMBData, self.BlackListButtons) then return false end
	if self.HasWhiteList and not MatchesButtonTokenSet(Button.SMBData, self.WhiteListButtons) then return false end
	if collapsed and self.HasCollapsedButtons and not MatchesButtonTokenSet(Button.SMBData, self.CollapsedButtons) then return false end

	return true
end

function SMB:HandleBlizzardButtons()
	if not SMB.db.enable then return end

	local garrisonButton = _G.GarrisonLandingPageMinimapButton
	local mailFrame = _G.MiniMapMailFrame
	local mailIcon = _G.MiniMapMailIcon
	local mailBorder = _G.MiniMapMailBorder
	local trackingFrame = (_G.MinimapCluster and (_G.MinimapCluster.Tracking or _G.MinimapCluster.TrackingFrame)) or _G.MiniMapTrackingFrame or _G.MiniMapTracking
	local trackingButton = _G.MiniMapTrackingButton or trackingFrame
	local queueButton = _G.QueueStatusMinimapButton
	local allowBlizzard = (SMB.db.buttonSource or "ALL") ~= "ADDON"

	if not allowBlizzard then
		self:Update()
		return
	end

	if SMB.db.hideGarrison and garrisonButton then
		garrisonButton:UnregisterAllEvents()
		garrisonButton:SetParent(self.Hider)
		garrisonButton:Hide()
	elseif SMB.db.moveGarrison and garrisonButton and not garrisonButton.SMB then
		garrisonButton:SetParent(_G.Minimap)
		garrisonButton:Show()
		garrisonButton:SetScale(1)
		garrisonButton:SetHitRectInsets(0, 0, 0, 0)
		garrisonButton:SetScript('OnEnter', nil)
		garrisonButton:SetScript('OnLeave', nil)

		garrisonButton:HookScript('OnEnter', function(self)
			self.backdrop:SetBackdropBorderColor(T.unpack(E["media"].rgbvaluecolor))
			if SMB.Bar:IsShown() then
				T.UIFrameFadeIn(SMB.Bar, 0.2, SMB.Bar:GetAlpha(), 1)
			end
		end)
		garrisonButton:HookScript('OnLeave', function(self)
			self:SetTemplate()
			if SMB.Bar:IsShown() and SMB.db.barMouseOver then
				T.UIFrameFadeOut(SMB.Bar, 0.2, SMB.Bar:GetAlpha(), 0)
			end
		end)

		garrisonButton.SMB = true
		self:RegisterButton(garrisonButton, "GARRISON", "blizzard")
	end

	if SMB.db.moveMail and mailFrame and not mailFrame.SMB and mailIcon then
		local Frame = T.CreateFrame('Frame', 'SMB_MailFrame', self.Bar)
		Frame:SetSize(SMB.db.iconSize, SMB.db.iconSize)
		Frame:SetTemplate()
		Frame.Icon = Frame:CreateTexture(nil, 'ARTWORK')
		Frame.Icon:SetPoint('CENTER')
		Frame.Icon:SetSize(18, 18)
		Frame.Icon:SetTexture(mailIcon:GetTexture())
		Frame:EnableMouse(true)
		Frame:HookScript('OnEnter', function(self)
			if T.HasNewMail() then
				_G.GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT")
				if _G.GameTooltip:IsOwned(self) then
					T.MinimapMailFrameUpdate()
				end
			end
			self:SetBackdropBorderColor(T.unpack(E["media"].rgbvaluecolor))
			if SMB.Bar:IsShown() then
				T.UIFrameFadeIn(SMB.Bar, 0.2, SMB.Bar:GetAlpha(), 1)
			end
		end)
		Frame:HookScript('OnLeave', function(self)
			_G.GameTooltip:Hide()
			self:SetTemplate()
			if SMB.Bar:IsShown() and SMB.db.BarMouseOver then
				T.UIFrameFadeOut(SMB.Bar, 0.2, SMB.Bar:GetAlpha(), 0)
			end
		end)

		mailFrame:HookScript('OnShow', function() Frame.Icon:SetVertexColor(0, 1, 0)	end)
		mailFrame:HookScript('OnHide', function() Frame.Icon:SetVertexColor(1, 1, 1) end)

		-- Hide Icon & Border
		mailIcon:Hide()
		if mailBorder then
			mailBorder:Hide()
		end

		mailFrame.SMB = true
		self:RegisterButton(Frame, "MAIL", "blizzard")
	end
	
	if SMB.db.moveTracker and trackingFrame and trackingButton and not trackingButton.SMB then
		trackingFrame.Show = nil

		trackingFrame:Show()

		trackingFrame:SetParent(self.Bar)
		trackingFrame:SetSize(SMB.db.iconSize, SMB.db.iconSize)

		if _G.MiniMapTrackingIcon then
			_G.MiniMapTrackingIcon:ClearAllPoints()
			_G.MiniMapTrackingIcon:SetPoint('CENTER')
		end

		if _G.MiniMapTrackingBackground then
			_G.MiniMapTrackingBackground:SetAlpha(0)
		end
		if _G.MiniMapTrackingIconOverlay then
			_G.MiniMapTrackingIconOverlay:SetAlpha(0)
		end
		if trackingButton ~= trackingFrame then
			trackingButton:SetAlpha(0)

			trackingButton:SetParent(trackingFrame)
			trackingButton:ClearAllPoints()
			trackingButton:SetAllPoints(trackingFrame)

			trackingButton:SetScript('OnMouseDown', nil)
			trackingButton:SetScript('OnMouseUp', nil)
		end

		trackingButton:HookScript('OnEnter', function(self)
			trackingFrame:SetBackdropBorderColor(T.unpack(E["media"].rgbvaluecolor))
			if SMB.Bar:IsShown() then
				T.UIFrameFadeIn(SMB.Bar, 0.2, SMB.Bar:GetAlpha(), 1)
			end
		end)
		trackingButton:HookScript('OnLeave', function(self)
			trackingFrame:SetTemplate()
			if SMB.Bar:IsShown() and SMB.db.barMouseOver then
				T.UIFrameFadeOut(SMB.Bar, 0.2, SMB.Bar:GetAlpha(), 0)
			end
		end)

		trackingButton.SMB = true
		trackingFrame.SMB = true
		self:RegisterButton(trackingFrame, "TRACKING", "blizzard")
	end

	if SMB.db.moveQueue and queueButton and not queueButton.SMB then
		local Frame = T.CreateFrame('Frame', 'SMB_QueueFrame', self.Bar)
		Frame:SetTemplate()
		Frame:SetSize(SMB.db.iconSize, SMB.db.iconSize)
		Frame.Icon = Frame:CreateTexture(nil, 'ARTWORK')
		Frame.Icon:SetSize(SMB.db.iconSize, SMB.db.iconSize)
		Frame.Icon:SetPoint('CENTER')
		Frame.Icon:SetTexture([[Interface\LFGFrame\LFG-Eye]])
		Frame.Icon:SetTexCoord(0, 64 / 512, 0, 64 / 256)
		Frame:SetScript('OnMouseDown', function()
			if _G.PVEFrame:IsShown() then
				T.HideUIPanel(_G.PVEFrame)
			else
				T.ShowUIPanel(_G.PVEFrame)
				T.GroupFinderFrame_ShowGroupFrame()
			end
		end)
		Frame:HookScript('OnEnter', function(self)
			self:SetBackdropBorderColor(T.unpack(E["media"].rgbvaluecolor))
			if SMB.Bar:IsShown() then
				T.UIFrameFadeIn(SMB.Bar, 0.2, SMB.Bar:GetAlpha(), 1)
			end
		end)
		Frame:HookScript('OnLeave', function(self)
			self:SetTemplate()
			if SMB.Bar:IsShown() and SMB.db.barMouseOver then
				T.UIFrameFadeOut(SMB.Bar, 0.2, SMB.Bar:GetAlpha(), 0)
			end
		end)

		queueButton:SetParent(self.Bar)
		queueButton:SetFrameLevel(Frame:GetFrameLevel() + 2)
		queueButton:ClearAllPoints()
		queueButton:SetPoint("CENTER", Frame, "CENTER", 0, 0)

		queueButton:SetHighlightTexture(nil)

		queueButton:HookScript('OnShow', function(self)
			Frame:EnableMouse(false)
		end)
		queueButton:HookScript('PostClick', T.QueueStatusMinimapButton_OnLeave)
		queueButton:HookScript('OnHide', function(self)
			Frame:EnableMouse(true)
		end)

		queueButton.SMB = true
		self:RegisterButton(Frame, "QUEUE", "blizzard")
	end
		
	self:Update()
end

function SMB:SkinMinimapButton(Button)
	if (not Button) or Button.isSkinned then return end

	local Name = Button:GetName()
	local IsLibDB = IsLibDBIconButton(Button)
	local OriginalIconTexture = GetPrimaryIconTexture(Button)
	local IconTexture = OriginalIconTexture
	local iconAsset = OriginalIconTexture and OriginalIconTexture.GetTexture and OriginalIconTexture:GetTexture()
	local left, right, top, bottom = GetTextureTexCoords(OriginalIconTexture)
	if not Name then return end

	if T.tContains(ignoreButtons, Name) then return end

	for i = 1, #GenericIgnores do
		if T.string_sub(Name, 1, T.string_len(GenericIgnores[i])) == GenericIgnores[i] then return end
	end

	for i = 1, #PartialIgnores do
		if T.string_find(Name, PartialIgnores[i]) ~= nil then return end
	end

	if IsLibDB then
		IconTexture = OriginalIconTexture

		if Button.SMBIcon then
			Button.SMBIcon:SetTexture(nil)
			Button.SMBIcon:SetAlpha(0)
			Button.SMBIcon:Hide()
		end

		if Button.SMBIconFrame then
			Button.SMBIconFrame:Hide()
		end
	end

	for i = 1, Button:GetNumRegions() do
		local Region = T.select(i, Button:GetRegions())
		if Region.IsObjectType and Region:IsObjectType('Texture') then
			local Texture = Region.GetTexture and Region:GetTexture()
			local TextureString = Texture and T.string_lower(T.tostring(Texture)) or ""

			if Region ~= IconTexture and (IsLibDB or IsDecorativeTexture(Region)) then
				Region:SetTexture(nil)
				Region:SetAlpha(0)
				Region:Hide()
			else
				if Name == 'BagSync_MinimapButton' then
					Region:SetTexture('Interface\\AddOns\\BagSync\\media\\icon')
				elseif Name == 'LibDBIcon10_DBM' then
					Region:SetTexture('Interface\\Icons\\INV_Helmet_87')
				elseif Name == 'OutfitterMinimapButton' then
					if TextureString == 'interface\\addons\\outfitter\\textures\\minimapbutton' then
						Region:SetTexture(nil)
					end
				elseif Name == 'SmartBuff_MiniMapButton' then
					Region:SetTexture('Interface\\Icons\\Spell_Nature_Purge')
				elseif Name == 'VendomaticButtonFrame' then
					Region:SetTexture('Interface\\Icons\\INV_Misc_Rabbit_2')
				end
				if Region == IconTexture then
					local anchor = Button.backdrop or Button
					Region:ClearAllPoints()
					Region:SetInside(anchor, 2, 2)
					if IsLibDB and left ~= nil then
						Region:SetTexCoord(left, right, top, bottom)
						Button:HookScript('OnLeave', function() Region:SetTexCoord(left, right, top, bottom) end)
						Region:SetDrawLayer('OVERLAY', 7)
					elseif IsLibDB then
						Region:SetTexCoord(0, 1, 0, 1)
						Button:HookScript('OnLeave', function() Region:SetTexCoord(0, 1, 0, 1) end)
						Region:SetDrawLayer('OVERLAY', 7)
					else
						Region:SetTexCoord(T.unpack(self.TexCoords))
						Button:HookScript('OnLeave', function() Region:SetTexCoord(T.unpack(self.TexCoords)) end)
						Region:SetDrawLayer('ARTWORK')
					end
					Region:SetAlpha(1)
					Region:Show()
					Region.SetPoint = function() return end
				end
			end
		end
	end
	
	local highlight = Button.GetHighlightTexture and Button:GetHighlightTexture()
	if highlight and highlight ~= IconTexture then
		highlight:SetTexture(nil)
		highlight:SetAlpha(0)
		highlight:Hide()
	end

	local pushed = Button.GetPushedTexture and Button:GetPushedTexture()
	if pushed and pushed ~= IconTexture then
		pushed:SetTexture(nil)
		pushed:SetAlpha(0)
		pushed:Hide()
	end

	local normal = Button.GetNormalTexture and Button:GetNormalTexture()
	if normal and normal ~= IconTexture and IsDecorativeTexture(normal) then
		normal:SetTexture(nil)
		normal:SetAlpha(0)
		normal:Hide()
	end

	if IconTexture and IconTexture.ClearAllPoints then
		local anchor = Button.backdrop or Button
		IconTexture:ClearAllPoints()
		IconTexture:SetInside(anchor, 2, 2)
		if IsLibDB and left ~= nil then
			IconTexture:SetTexCoord(left, right, top, bottom)
			IconTexture:SetDrawLayer('OVERLAY', 7)
		elseif IsLibDB then
			IconTexture:SetTexCoord(0, 1, 0, 1)
			IconTexture:SetDrawLayer('OVERLAY', 7)
		else
			IconTexture:SetTexCoord(T.unpack(self.TexCoords))
			IconTexture:SetDrawLayer('ARTWORK')
		end
		if IconTexture.SetVertexColor then
			IconTexture:SetVertexColor(1, 1, 1, 1)
		end
		if IconTexture.SetDesaturated then
			IconTexture:SetDesaturated(false)
		end
		if IconTexture.SetBlendMode then
			IconTexture:SetBlendMode("BLEND")
		end
		IconTexture:SetAlpha(1)
		IconTexture:Show()
	end

	if Button.ishadow then
		Button.ishadow:Hide()
	end
	Button:SetFrameLevel(_G.Minimap:GetFrameLevel() + 5)
	Button:SetSize(SMB.db.iconSize, SMB.db.iconSize)
	Button:CreateBackdrop("Default")
	if Button.backdrop and Button.backdrop.SetTemplate then
		Button.backdrop:SetTemplate("Default")
	end
	Button:CreateIconShadow()
	if Button.ishadow then
		Button.ishadow:SetParent(Button)
		Button.ishadow:ClearAllPoints()
		Button.ishadow:SetInside(Button, 0, 0)
		Button.ishadow:Show()
	end

	if IsLibDB and iconAsset and Button.backdrop then
		if not Button.SMBIcon then
			Button.SMBIcon = Button.backdrop:CreateTexture(nil, "ARTWORK")
		else
			Button.SMBIcon:SetParent(Button.backdrop)
		end

		Button.SMBIcon:ClearAllPoints()
		Button.SMBIcon:SetInside(Button.backdrop, 2, 2)
		Button.SMBIcon:SetTexture(iconAsset)
		if left ~= nil then
			Button.SMBIcon:SetTexCoord(left, right, top, bottom)
		else
			Button.SMBIcon:SetTexCoord(0, 1, 0, 1)
		end
		Button.SMBIcon:SetVertexColor(1, 1, 1, 1)
		if Button.SMBIcon.SetDesaturated then
			Button.SMBIcon:SetDesaturated(false)
		end
		if Button.SMBIcon.SetBlendMode then
			Button.SMBIcon:SetBlendMode("BLEND")
		end
		Button.SMBIcon:SetDrawLayer("ARTWORK", 7)
		Button.SMBIcon:SetAlpha(1)
		Button.SMBIcon:Show()

		if OriginalIconTexture and OriginalIconTexture ~= Button.SMBIcon then
			OriginalIconTexture:SetAlpha(0)
			OriginalIconTexture:Hide()
		end
	end

	Button:HookScript('OnEnter', function(self)
		self.backdrop:SetBackdropBorderColor(T.unpack(E["media"].rgbvaluecolor))
		if SMB.Bar:IsShown() then
			T.UIFrameFadeIn(SMB.Bar, 0.2, SMB.Bar:GetAlpha(), 1)
		end
	end)
	Button:HookScript('OnLeave', function(self)
		self:CreateBackdrop("Default")
		if self.backdrop and self.backdrop.SetTemplate then
			self.backdrop:SetTemplate("Default")
		end
		if self.ishadow then
			self.ishadow:SetParent(self)
			self.ishadow:ClearAllPoints()
			self.ishadow:SetInside(self, 0, 0)
			self.ishadow:Show()
		end
		if SMB.Bar:IsShown() and SMB.db.barMouseOver then
			T.UIFrameFadeOut(SMB.Bar, 0.2, SMB.Bar:GetAlpha(), 0)
		end
	end)

	Button.isSkinned = true
	self:RegisterButton(Button, Name, "addon")
end

local function IsInPetBattle()
	if T.C_PetBattles_IsInBattle then
		return T.C_PetBattles_IsInBattle()
	end

	local petBattles = _G.C_PetBattles
	if petBattles and petBattles.IsInBattle then
		return petBattles.IsInBattle()
	end

	return false
end

function SMB:GrabMinimapButtons()
	if T.InCombatLockdown() or IsInPetBattle() then return end

	for _, Frame in T.pairs({ _G.Minimap, _G.MinimapBackdrop, _G.MinimapCluster }) do
		if Frame then
			local NumChildren = Frame:GetNumChildren()
			if NumChildren < (Frame.SMBNumChildren or 0) then return end
			for i = 1, NumChildren do
				local object = T.select(i, Frame:GetChildren())
				if object then
					local name = object:GetName()
					local width = object:GetWidth()
					if name and width > 15 and width < 52 and (object:IsObjectType('Button') or object:IsObjectType('Frame')) then
						self:SkinMinimapButton(object)
					end
				end
			end

			Frame.SMBNumChildren = NumChildren
		end
	end

	self:Update()
end

function SMB:Update()
	if not SMB.db.enable then return end
	if T.InCombatLockdown() then return end

	self:SyncConfiguredLists()
	self:RefreshButtonFilters()

	local VisibleButtons, CollapsedButtons = {}, {}
	local ButtonsPerRow = SMB.db.buttonsPerRow or 8
	local Spacing = SMB.db.buttonSpacing or 2
	local Size = SMB.db.iconSize or 20
	local horizontalFirst, growRight, growDown = GetGrowthSettings(SMB.db.growthDirection)

	for _, Button in ipairs(SMB.Buttons) do
		SMB:UnlockButton(Button)

		if self:ShouldKeepButton(Button, false) then
			T.table_insert(VisibleButtons, Button)
			if self:ShouldKeepButton(Button, true) then
				T.table_insert(CollapsedButtons, Button)
			end
		end
	end

	local sortBy = SMB.db.sortBy or "ADDED"
	if sortBy ~= "ADDED" then
		sort(VisibleButtons, function(a, b)
			local aData, bData = a.SMBData or {}, b.SMBData or {}
			local aKey, bKey = aData.key or "", bData.key or ""
			local aOrder = sortBy == "BY_FILTERING" and GetButtonTokenOrder(aData, self.WhiteListOrderMap)
			local bOrder = sortBy == "BY_FILTERING" and GetButtonTokenOrder(bData, self.WhiteListOrderMap)

			if sortBy == "BY_FILTERING" then
				if aOrder and bOrder and aOrder ~= bOrder then
					return aOrder < bOrder
				elseif aOrder and not bOrder then
					return true
				elseif bOrder and not aOrder then
					return false
				end
			end

			if sortBy == "NAME_DESC" then
				return aKey > bKey
			elseif sortBy == "TYPE_NAME" then
				if aData.kind ~= bData.kind then
					return aData.kind == "blizzard"
				end
			end

			return aKey < bKey
		end)

		sort(CollapsedButtons, function(a, b)
			local aData, bData = a.SMBData or {}, b.SMBData or {}
			local aKey, bKey = aData.key or "", bData.key or ""
			local aOrder = sortBy == "BY_FILTERING" and GetButtonTokenOrder(aData, self.CollapsedButtonsOrderMap)
			local bOrder = sortBy == "BY_FILTERING" and GetButtonTokenOrder(bData, self.CollapsedButtonsOrderMap)

			if sortBy == "BY_FILTERING" then
				if aOrder and bOrder and aOrder ~= bOrder then
					return aOrder < bOrder
				elseif aOrder and not bOrder then
					return true
				elseif bOrder and not aOrder then
					return false
				end
			end

			if sortBy == "NAME_DESC" then
				return aKey > bKey
			elseif sortBy == "TYPE_NAME" then
				if aData.kind ~= bData.kind then
					return aData.kind == "blizzard"
				end
			end

			return aKey < bKey
		end)
	end

	local LayoutButtons = VisibleButtons
	if self.Collapsed then
		LayoutButtons = self.HasCollapsedButtons and CollapsedButtons or {}
	end

	for _, Button in ipairs(SMB.Buttons) do
		local include = false
		for _, LayoutButton in ipairs(LayoutButtons) do
			if Button == LayoutButton then
				include = true
				break
			end
		end

		if include then
			Button:SetParent(self.Bar)
			Button:SetAlpha(1)
			if Button.EnableMouse then
				Button:EnableMouse(true)
			end
		else
			Button:SetParent(self.Hider)
			Button:SetAlpha(0)
			if Button.EnableMouse then
				Button:EnableMouse(false)
			end
		end
	end

	local ActualButtons = #LayoutButtons
	local Columns, Rows = 0, 0
	if ActualButtons > 0 then
		if horizontalFirst then
			Columns = min(ActualButtons, ButtonsPerRow)
			Rows = ceil(ActualButtons / ButtonsPerRow)
		else
			Rows = min(ActualButtons, ButtonsPerRow)
			Columns = ceil(ActualButtons / ButtonsPerRow)
		end
	end

	for index, Button in ipairs(LayoutButtons) do
		local position = index - 1
		local row, col

		if horizontalFirst then
			row = floor(position / ButtonsPerRow)
			col = position % ButtonsPerRow
		else
			col = floor(position / ButtonsPerRow)
			row = position % ButtonsPerRow
		end

		if not growRight then
			col = (Columns - 1) - col
		end
		if not growDown then
			row = (Rows - 1) - row
		end

		local xOffset = Spacing + ((Size + Spacing) * col)
		local yOffset = -(Spacing + ((Size + Spacing) * row))

		Button:CreateBackdrop()
		Button:ClearAllPoints()
		Button:SetPoint("TOPLEFT", self.Bar, "TOPLEFT", xOffset, yOffset)
		Button:SetSize(SMB.db.iconSize, SMB.db.iconSize)
		Button:SetScale(1)
		Button:SetFrameStrata('MEDIUM')
		Button:SetFrameLevel(self.Bar:GetFrameLevel() + 1)
		Button:CreateBackdrop("Default")
		if Button.backdrop then
			if Button.backdrop.SetTemplate then
				Button.backdrop:SetTemplate("Default")
			end
			Button.backdrop:SetFrameStrata(Button:GetFrameStrata())
			Button.backdrop:SetFrameLevel(max(Button:GetFrameLevel() - 1, 0))
		end
		if Button.ishadow then
			Button.ishadow:SetParent(Button)
			Button.ishadow:ClearAllPoints()
			Button.ishadow:SetInside(Button, 0, 0)
			Button.ishadow:Show()
		end
		if Button.SMBIcon then
			if Button.backdrop then
				Button.SMBIcon:SetParent(Button.backdrop)
				Button.SMBIcon:ClearAllPoints()
				Button.SMBIcon:SetInside(Button.backdrop, 2, 2)
			else
				Button.SMBIcon:SetParent(Button)
				Button.SMBIcon:ClearAllPoints()
				Button.SMBIcon:SetInside(Button, 2, 2)
			end
			Button.SMBIcon:SetDrawLayer("ARTWORK", 7)
			Button.SMBIcon:SetAlpha(1)
			Button.SMBIcon:Show()
		end
		if Button.SMBIconFrame then
			Button.SMBIconFrame:Hide()
		end
		Button:SetScript('OnDragStart', nil)
		Button:SetScript('OnDragStop', nil)
		SMB:LockButton(Button)
	end

	local MinBarSize = self.db.enableCollapse and 16 or Size
	local BarWidth = ActualButtons > 0 and ((Columns * Size) + ((Columns + 1) * Spacing)) or MinBarSize
	local BarHeight = ActualButtons > 0 and ((Rows * Size) + ((Rows + 1) * Spacing)) or MinBarSize
	self.Bar:SetSize(BarWidth, BarHeight)
	self:ApplyBarPosition()
	self:UpdateCollapseToggle()

	if SMB.db.backdrop then
		self.Bar:CreateBackdrop("Transparent", true)
		self.Bar:Styling()
	else
		self.Bar:SetBackdrop(nil)
		if self.Bar.squares or self.Bar.gradient or self.Bar.mshadow then
			self.Bar.squares:SetTexture(nil)
			self.Bar.gradient:SetTexture(nil)
			self.Bar.mshadow:SetTexture(nil)
		end
	end

	if ActualButtons == 0 and not self.db.enableCollapse then
		self.Bar:Hide()
	else
		self.Bar:Show()
	end

	if SMB.db['barMouseOver'] then
		T.UIFrameFadeOut(self.Bar, 0.2, self.Bar:GetAlpha(), 0)
	else
		T.UIFrameFadeIn(self.Bar, 0.2, self.Bar:GetAlpha(), 1)
	end
end

function SMB:PLAYER_REGEN_DISABLED()
	if SMB.db.hideInCombat then SMB.Bar:Hide() end
end

function SMB:PLAYER_REGEN_ENABLED()
	if SMB.db.enable then SMB.Bar:Show() end
end

function SMB:UpdateVisibility()
	T.RegisterStateDriver(SMB.Bar, 'visibility', SMB.db.visibility)
end

function SMB:RefreshSettings()
	if not self.db then return end

	self:RefreshButtonFilters()
	self:ApplyBarPosition()
	self:UpdateVisibility()
	self:UpdateCollapseToggle()
	self:Update()
end

function SMB:Initialize()
	if not E.private.general.minimap.enable or not E.db.KlixUI.maps.minimap.buttons.enable then return end
	if ((COMP.PA and _G.ProjectAzilroka.db["SquareMinimapButtons"]['Enable']) or (COMP.SLE and E.private.sle.minimap.mapicons.enable)) then return end

	SMB.db = E.db.KlixUI.maps.minimap.buttons
	if SMB.db.buttonSource == nil then SMB.db.buttonSource = "ALL" end
	if SMB.db.sortBy == nil then SMB.db.sortBy = "BY_FILTERING" end
	if SMB.db.growthDirection == nil then SMB.db.growthDirection = "RIGHT_DOWN" end
	if SMB.db.useCustomPosition == nil then SMB.db.useCustomPosition = false end
	if SMB.db.dockToMinimap == nil then SMB.db.dockToMinimap = true end
	if SMB.db.point == nil then SMB.db.point = "TOPRIGHT" end
	if SMB.db.relativePoint == nil then SMB.db.relativePoint = "BOTTOMRIGHT" end
	if SMB.db.xOffset == nil then SMB.db.xOffset = 0 end
	if SMB.db.yOffset == nil then SMB.db.yOffset = -2 end
	if SMB.db.enableCollapse == nil then SMB.db.enableCollapse = true end
	if SMB.db.collapsed == nil then SMB.db.collapsed = false end
	if SMB.db.collapsedButtons == nil then SMB.db.collapsedButtons = "KLIXUI" end
	if SMB.db.whitelist == nil then SMB.db.whitelist = "" end
	if SMB.db.blacklist == nil then SMB.db.blacklist = "MAIL,TRACKING,QUEUE" end
	if SMB.db.knownButtons == nil then SMB.db.knownButtons = "" end

	SMB.Hider = T.CreateFrame("Frame", nil, UIParent)
	SMB.Hider:Hide()

	SMB.Bar = T.CreateFrame('Frame', 'SquareMinimapButtonBar', UIParent)
	SMB.Bar:Hide()
	
	if T.IsAddOnLoaded('XIV_Databar') then
		SMB.Bar:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -10, -211)
	else
		SMB.Bar:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -10, -207)
	end
	SMB.Bar:SetFrameStrata('LOW')
	SMB.Bar:SetClampedToScreen(true)
	SMB.Bar:SetMovable(true)
	SMB.Bar:EnableMouse(true)
	SMB.Bar:SetSize(SMB.db.iconSize, SMB.db.iconSize)
	SMB:UpdateVisibility()

	SMB.Toggle = T.CreateFrame("Button", nil, SMB.Bar, "BackdropTemplate")
	SMB.Toggle:SetSize(16, 16)
	SMB.Toggle:SetTemplate("Transparent")
	SMB.Toggle.text = KUI:CreateText(SMB.Toggle, "OVERLAY", 12, nil, "CENTER")
	SMB.Toggle.text:Point("CENTER", 0, 0)
	SMB.Toggle:HookScript("OnEnter", function(self)
		_G.GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
		_G.GameTooltip:ClearLines()
		_G.GameTooltip:AddLine("Minimap Buttons Collapse")
		_G.GameTooltip:AddLine(SMB:GetButtonTokensTooltipText("Use the \"Collapsed Buttons\" option to define which buttons stay visible while collapsed."), 1, 1, 1, true)
		_G.GameTooltip:Show()
	end)
	SMB.Toggle:HookScript("OnLeave", function()
		_G.GameTooltip:Hide()
	end)
	SMB.Toggle:SetScript("OnClick", function()
		if T.InCombatLockdown() then return end
		SMB.db.collapsed = not SMB.db.collapsed
		SMB.Collapsed = SMB.db.collapsed
		SMB:Update()
	end)

	SMB.Bar:SetScript('OnEnter', function(self) T.UIFrameFadeIn(self, 0.2, self:GetAlpha(), 1) end)
	SMB.Bar:SetScript('OnLeave', function(self)
		if SMB.db['barMouseOver'] then
			T.UIFrameFadeOut(self, 0.2, self:GetAlpha(), 0)
		end
	end)

	function SMB:ForUpdateAll()
		SMB.db = E.db.KlixUI.maps.minimap.buttons
		SMB:RefreshSettings()
	end
	SMB:ForUpdateAll()

	self:RegisterEvent("PLAYER_REGEN_DISABLED")
	self:RegisterEvent("PLAYER_REGEN_ENABLED")
	
	E:CreateMover(SMB.Bar, "KUI_SquareMinimapButtonBarMover", L["Square Minimap Buttons Bar"], nil, nil, nil, 'ALL,GENERAL,KLIXUI', nil, "KlixUI,modules,maps,minimap,buttons")
	SMB:RefreshSettings()

	SMB.TexCoords = {T.unpack(E.TexCoords)}

	SMB:HandleBlizzardButtons()
	SMB:GrabMinimapButtons()
	SMB:ScheduleRepeatingTimer('GrabMinimapButtons', 6)
	SMB:ScheduleTimer('HandleBlizzardButtons', 7)
end

KUI:RegisterModule(SMB:GetName())
