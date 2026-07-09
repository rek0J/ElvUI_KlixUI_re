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
local strlower = string.lower
local strmatch = string.match
local strupper = string.upper
local strtrim = strtrim
local issecurevariable = _G.issecurevariable

SMB.Buttons = {}
SMB.Collapsed = false
SMB.MouseOver = false
SMB.NeedsFullScan = true

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
	'SquareMinimapButtonBar',
	'KUI_SquareMinimapButtonBarMover',
	-- LFG / Dungeon Browser / Raid Browser / Group Finder — must stay on minimap
	'LFGMinimapFrame',
	'MiniMapLFGFrame',
	'LFDMinimapFrame',
	'LFGFrame',
	'GroupFinderFrame',
	'RaidBrowserFrame',
	'PremadeGroupsFrame',
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
local GoldBorderTextureIDs = {
	[136430] = true,
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
		Button.texture,
		Button.Texture,
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

local function GetExplicitButtonIconTexture(Button)
	local name = Button and Button.GetName and Button:GetName()
	local candidates = {
		Button and Button.icon,
		Button and Button.Icon,
		Button and Button.texture,
		Button and Button.Texture,
		name and _G[name.."Icon"] or nil,
		name and _G[name.."IconTexture"] or nil,
		name and _G[name.."Texture"] or nil,
	}

	for _, texture in ipairs(candidates) do
		if HasTexture(texture) then
			return texture
		end
	end

	return Button and Button.GetNormalTexture and Button:GetNormalTexture()
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

local function UseOriginalButtonStyle()
	return SMB.db and SMB.db.buttonStyle == "ORIGINAL"
end

local function SetTextureShown(texture, shown)
	if not texture or not texture.IsObjectType or not texture:IsObjectType("Texture") then return end

	if shown then
		texture:Show()
	else
		texture:Hide()
	end
end

local function IsGoldBorderTexture(region)
	if not region or not region.IsObjectType or not region:IsObjectType("Texture") then return false end

	local texture = region.GetTexture and region:GetTexture()
	if GoldBorderTextureIDs[texture] then
		return true
	end

	local textureString = strlower(T.tostring(texture or ""))
	return textureString:find("trackingborder", 1, true) ~= nil
end

local function UpdateTextureMaxSize(size, texture)
	if not texture or not texture.GetWidth or not texture.GetHeight then
		return size
	end

	return max(size, texture:GetWidth() or 0, texture:GetHeight() or 0)
end

local function CaptureNativeButtonMetrics(Button)
	if not Button or Button.SMBNativeMetricsCaptured then return end

	local width = Button.GetWidth and Button:GetWidth() or 0
	local height = Button.GetHeight and Button:GetHeight() or 0
	local visualSize = max(width, height)

	for _, texture in ipairs({
		Button.border,
		Button.background,
		Button.icon,
		Button.Icon,
		Button.texture,
		Button.Texture,
	}) do
		visualSize = UpdateTextureMaxSize(visualSize, texture)
	end

	Button.SMBNativeWidth = width > 0 and width or 31
	Button.SMBNativeHeight = height > 0 and height or Button.SMBNativeWidth
	Button.SMBNativeVisualSize = visualSize > 0 and visualSize or max(Button.SMBNativeWidth, Button.SMBNativeHeight)
	Button.SMBNativeMetricsCaptured = true
end

local function GetNativeVisualSize(Button)
	CaptureNativeButtonMetrics(Button)

	local nativeVisualSize = Button and Button.SMBNativeVisualSize or 0
	return nativeVisualSize > 0 and nativeVisualSize or 31
end

local function GetNativeFrameSize(Button)
	CaptureNativeButtonMetrics(Button)

	local nativeWidth = Button and Button.SMBNativeWidth or 0
	local nativeHeight = Button and Button.SMBNativeHeight or 0
	local nativeFrameSize = max(nativeWidth, nativeHeight)
	return nativeFrameSize > 0 and nativeFrameSize or 31
end

local function GetOriginalStyleScale(Button, targetSize)
	local nativeFrameSize = GetNativeFrameSize(Button)
	return nativeFrameSize > 0 and ((targetSize or SMB.db.iconSize) / nativeFrameSize) or 1
end

local function GetOriginalStyleFootprint(Button, targetSize)
	return GetNativeVisualSize(Button) * GetOriginalStyleScale(Button, targetSize)
end

local function ApplyDarkBorder(frame)
	if not frame then return end

	if frame.SetBackdropBorderColor then
		frame:SetBackdropBorderColor(0, 0, 0, 1)
	end
end

local function ApplySquareButtonBorder(Button)
	if not Button then return end

	if not Button.backdrop and Button.CreateBackdrop then
		Button:CreateBackdrop("Default", true)
	end

	if Button.backdrop then
		if Button.backdrop.SetTemplate then
			Button.backdrop:SetTemplate("Default", true)
		end
		Button.backdrop:SetFrameStrata(Button:GetFrameStrata())
		Button.backdrop:SetFrameLevel(max(Button:GetFrameLevel() - 1, 0))
		ApplyDarkBorder(Button.backdrop)
		Button.backdrop:Show()
	end
end

local function AnchorSquareIcon(Button, texture, isLibDBIcon, left, right, top, bottom)
	if not Button or not texture or not texture.ClearAllPoints then return end

	local anchor = Button.backdrop or Button
	texture:SetParent(Button)
	texture:ClearAllPoints()
	texture:SetInside(anchor, 2, 2)

	if isLibDBIcon and left ~= nil then
		texture:SetTexCoord(left, right, top, bottom)
	elseif isLibDBIcon then
		texture:SetTexCoord(0, 1, 0, 1)
	else
		texture:SetTexCoord(T.unpack(SMB.TexCoords or E.TexCoords))
	end

	texture:SetDrawLayer(isLibDBIcon and "OVERLAY" or "ARTWORK", 7)
	texture:SetAlpha(1)
	texture:Show()
end

local function SyncTextureState(target, source, left, right, top, bottom)
	if not target or not source then return end

	if source.GetTexture then
		local texture = source:GetTexture()
		if texture then
			target:SetTexture(texture)
		end
	end

	if left ~= nil then
		target:SetTexCoord(left, right, top, bottom)
	elseif source.GetTexCoord then
		target:SetTexCoord(source:GetTexCoord())
	end

	if source.GetVertexColor and target.SetVertexColor then
		target:SetVertexColor(source:GetVertexColor())
	end

	if source.GetDesaturated and target.SetDesaturated then
		target:SetDesaturated(source:GetDesaturated())
	end

	if source.GetBlendMode and target.SetBlendMode then
		target:SetBlendMode(source:GetBlendMode())
	end
end

local function NormalizeButtonToken(token)
	token = token and strtrim(T.tostring(token)) or ""
	token = token:gsub("%s+", "")
	return strupper(token)
end

local function IsTomCatsButton(frameName)
	return frameName and strmatch(frameName, "^TomCats%-") ~= nil
end

local function NameEndsWithNumber(frameName)
	return frameName and strmatch(frameName, "%d$") ~= nil
end

local function NameMatchesButtonPattern(frameName)
	if not frameName or frameName == "" then return false end

	local patterns = {
		"^LibDBIcon10_",
		"MinimapButton",
		"MinimapFrame",
		"MinimapIcon",
		"[-_]Minimap[-_]",
		"Minimap$",
	}

	for _, pattern in ipairs(patterns) do
		if strmatch(frameName, pattern) ~= nil then
			return true
		end
	end

	return false
end

local function NameMatchesPinPattern(frameName)
	if not frameName or frameName == "" then return false end

	local patterns = {
		"^HandyNotes",
		"^TomTom",
		"^HereBeDragons",
		"^Questie",
		"^GatherMate",
		"^pin",
		"^Pin",
	}

	for _, pattern in ipairs(patterns) do
		if strmatch(frameName, pattern) ~= nil then
			return true
		end
	end

	return false
end

-- Patterns for Blizzard frames that must stay on the minimap and must never be collected.
-- Used in addition to the exact-name ignoreButtons list above.
local ForbiddenPatterns = {
	"QueueStatus",
	"LFG",
	"LFD",
	"RaidBrowser",
	"GroupFinder",
	"PremadeGroups",
	"LookingForGroup",
}

local function IsForbiddenMinimapButton(name)
	if not name or name == "" then return false end
	if T.tContains(ignoreButtons, name) then return true end
	for _, pattern in ipairs(ForbiddenPatterns) do
		if name:find(pattern, 1, true) then
			return true
		end
	end
	return false
end

local function IsLikelyNamedMinimapButton(object)
	if not object or not object.GetName then return false end

	local frameName = object:GetName()
	if not frameName or frameName == "" then return false end
	if issecurevariable and issecurevariable(_G, frameName) then return false end
	if IsForbiddenMinimapButton(frameName) then return false end
	if IsTomCatsButton(frameName) then return true end
	if NameEndsWithNumber(frameName) then return false end

	return NameMatchesButtonPattern(frameName) and not NameMatchesPinPattern(frameName)
end

local function GetLibDBIcon()
	local LibStub = _G.LibStub
	return LibStub and LibStub:GetLibrary("LibDBIcon-1.0", true)
end

local function GetLibMapButton()
	local LibStub = _G.LibStub
	return LibStub and LibStub:GetLibrary("LibMapButton-1.1", true)
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

local function RemoveButtonTokensFromList(value, buttonData)
	local _, _, ordered = ParseButtonTokens(value)
	local kept = {}

	for _, token in ipairs(ordered) do
		if not (buttonData and (token == buttonData.key or (buttonData.aliases and buttonData.aliases[token]))) then
			T.table_insert(kept, token)
		end
	end

	return T.table_concat(kept, ",")
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

	if not Button.SMBVisibilityHooksInstalled then
		Button.SMBVisibilityHooksInstalled = true

		hooksecurefunc(Button, "Show", function(frame)
			if frame and frame.SMBRegistered then
				SMB:QueueUpdate()
			end
		end)

		hooksecurefunc(Button, "Hide", function(frame)
			if frame and frame.SMBRegistered then
				SMB:QueueUpdate()
			end
		end)
	end
end

function SMB:QueueUpdate()
	if self.UpdateQueued then return end
	self.UpdateQueued = true

	T.C_Timer_After(0, function()
		SMB.UpdateQueued = nil
		if SMB and SMB.Update and SMB.db and SMB.db.enable then
			SMB:Update()
		end
	end)
end

function SMB:GetButtonSize()
	return self.db.buttonSize or self.db.iconSize or 28
end

function SMB:GetButtonSpacing()
	return self.db.buttonSpacing or self.db.spacing or 4
end

function SMB:GetButtonsPerRow()
	return self.db.maxButtonsPerRow or self.db.buttonsPerRow or 8
end

function SMB:TrySkinAndRegisterButton(Button)
	if not Button or Button == self.Bar or Button == self.Hider or Button == self.Toggle then return false end
	if Button.IsForbidden and Button:IsForbidden() then return false end
	if not (Button.IsObjectType and (Button:IsObjectType('Button') or Button:IsObjectType('Frame'))) then return false end

	local width = Button.GetWidth and Button:GetWidth() or 0
	if width > 0 and (width < 15 or width > 96) then
		return false
	end

	CaptureNativeButtonMetrics(Button)

	local wasSkinned = Button.isSkinned
	self:SkinMinimapButton(Button)
	return (not wasSkinned) and Button.isSkinned
end

function SMB:CollectLibDBIconButtons()
	local LibDBIcon = GetLibDBIcon()
	local changed = false
	if not LibDBIcon then return changed end
	if not LibDBIcon.GetButtonList or not LibDBIcon.GetMinimapButton then return changed end

	for _, buttonName in ipairs(LibDBIcon:GetButtonList()) do
		local button = LibDBIcon:GetMinimapButton(buttonName)
		if self:TrySkinAndRegisterButton(button) then
			changed = true
		end
	end

	return changed
end

function SMB:CollectLibMapButtonButtons()
	local LibMapButton = GetLibMapButton()
	local changed = false
	if not LibMapButton or not LibMapButton.buttons then return changed end

	for _, button in T.pairs(LibMapButton.buttons) do
		if self:TrySkinAndRegisterButton(button) then
			changed = true
		end
	end

	return changed
end

function SMB:HookLibDBIconButtons()
	if self.LibDBIconHooked then return end

	local LibDBIcon = GetLibDBIcon()
	if not LibDBIcon or not LibDBIcon.RegisterCallback then return end

	self.LibDBIconHooked = true
	LibDBIcon.RegisterCallback(self, "LibDBIcon_IconCreated", function(_, _, button)
		if SMB:TrySkinAndRegisterButton(button) then
			SMB:QueueUpdate()
		end
	end)
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

function SMB:EnsureKnownButtons()
	if not self.db or not self.db.enable then return end

	if self.GrabMinimapButtons then
		self:GrabMinimapButtons()
	end

	self:SyncConfiguredLists()
	self:RefreshButtonFilters()
end

function SMB:GetKnownButtonTokens()
	if not self.db then return {} end

	self:EnsureKnownButtons()

	local _, hasKnownButtons, orderedKnownButtons = ParseButtonTokens(self.db.knownButtons)
	if hasKnownButtons then
		return orderedKnownButtons
	end

	return self:GetDiscoveredButtonKeys()
end

function SMB:GetKnownButtonValues()
	local values = {}

	for _, token in ipairs(self:GetKnownButtonTokens()) do
		values[token] = token
	end

	return values
end

function SMB:IsButtonTokenInList(listKey, token)
	if not self.db or not listKey or not token then return false end

	token = NormalizeButtonToken(token)
	local tokens = ParseButtonTokens(self.db[listKey])
	return tokens[token] or false
end

function SMB:SetButtonTokenInList(listKey, token, enabled)
	if not self.db or not listKey or not token then return end

	token = NormalizeButtonToken(token)
	if token == "" then return end

	local tokenSet, _, orderedTokens = ParseButtonTokens(self.db[listKey])

	if enabled then
		if not tokenSet[token] then
			T.table_insert(orderedTokens, token)
		end
	else
		local keptTokens = {}
		for _, existingToken in ipairs(orderedTokens) do
			if existingToken ~= token then
				T.table_insert(keptTokens, existingToken)
			end
		end
		orderedTokens = keptTokens
	end

	self.db[listKey] = T.table_concat(orderedTokens, ",")
	self:RefreshSettings()
end

function SMB:SyncConfiguredLists()
	local knownSet, _, knownOrdered = ParseButtonTokens(self.db.knownButtons)
	local changed = false

	-- Phase 1: Clean stale entries from older versions. Runs unconditionally so that
	-- the DB is sanitised even when no buttons have been discovered yet (e.g. when the
	-- options panel opens before the first GrabMinimapButtons pass completes).

	-- 1a: Remove ignoreButtons entries that were registered by an older code path.
	do
		local ignoreSet = {}
		for _, name in ipairs(ignoreButtons) do
			ignoreSet[NormalizeButtonToken(name)] = true
		end
		local cleaned = {}
		for _, token in ipairs(knownOrdered) do
			if ignoreSet[token] then
				knownSet[token] = nil
				changed = true
			else
				cleaned[#cleaned + 1] = token
			end
		end
		knownOrdered = cleaned
	end

	-- 1b: Remove non-preferred alias entries (e.g. LIBDBICON10_KLIXUI when KLIXUI is
	-- the displayKey). Older versions stored the full frame-name; this deduplicates.
	do
		local aliasToDisplay = {}
		for _, Button in ipairs(self.Buttons or {}) do
			local data = Button.SMBData
			if data and data.displayKey and data.aliases then
				for alias in T.pairs(data.aliases) do
					if alias ~= data.displayKey then
						aliasToDisplay[alias] = data.displayKey
					end
				end
			end
		end
		local cleaned = {}
		local aliasRemoved = false
		for _, token in ipairs(knownOrdered) do
			if aliasToDisplay[token] then
				knownSet[token] = nil
				aliasRemoved = true
			else
				cleaned[#cleaned + 1] = token
			end
		end
		if aliasRemoved then
			knownOrdered = cleaned
			knownSet = {}
			for _, token in ipairs(knownOrdered) do
				knownSet[token] = true
			end
			changed = true
		end
	end

	-- Phase 2: Add newly discovered buttons. Skip when nothing is registered yet.
	local discovered = self:GetDiscoveredButtonKeys()
	if #discovered == 0 then
		if changed then
			self.db.knownButtons = T.table_concat(knownOrdered, ",")
		end
		return
	end

	local whiteSet, hasWhiteList, whiteOrdered = ParseButtonTokens(self.db.whitelist)
	local _, hasBlackList = ParseButtonTokens(self.db.blacklist)
	local _, hasCollapsedList = ParseButtonTokens(self.db.collapsedButtons)

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

function SMB:RemoveHiddenButtonFromConfiguredLists(Button)
	local data = Button and Button.SMBData
	if not data or data.kind == "blizzard" then return end

	local newWhiteList = RemoveButtonTokensFromList(self.db.whitelist, data)
	local newCollapsed = RemoveButtonTokensFromList(self.db.collapsedButtons, data)

	if newWhiteList ~= self.db.whitelist or newCollapsed ~= self.db.collapsedButtons then
		self.db.whitelist = newWhiteList
		self.db.collapsedButtons = newCollapsed
		self:RefreshButtonFilters()
	end

	T.C_Timer_After(0, function()
		if SMB and SMB.Update then
			SMB:Update()
		end
	end)
end

function SMB:ApplyBarPosition()
	if not self.Bar or not self.db.useCustomPosition then return end
	if T.InCombatLockdown() then
		self.PendingLayout = true
		return
	end

	local parent = self.db.dockToMinimap and _G.Minimap or UIParent
	if not parent then parent = UIParent end

	self.Bar:ClearAllPoints()
	self.Bar:SetPoint(self.db.point or "TOPRIGHT", parent, self.db.relativePoint or "BOTTOMRIGHT", self.db.xOffset or 0, self.db.yOffset or 0)
end

function SMB:UpdateCollapseToggle()
	if not self.Toggle then return end
	if T.InCombatLockdown() then
		self.PendingLayout = true
		return
	end

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

	local kind = Button.SMBData.kind or "addon"
	local source = self.db.buttonSource or "ALL"

	if source == "ADDON" and kind == "blizzard" then return false end
	if source == "BLIZZARD" and kind ~= "blizzard" then return false end
	if MatchesButtonTokenSet(Button.SMBData, self.BlackListButtons) then return false end
	if self.HasWhiteList and not MatchesButtonTokenSet(Button.SMBData, self.WhiteListButtons) then return false end
	if collapsed and self.HasCollapsedButtons and not MatchesButtonTokenSet(Button.SMBData, self.CollapsedButtons) then return false end

	return true
end

function SMB:ApplyGoldBorderSetting(Button)
	if not Button then return end

	local showBorder = not (UseOriginalButtonStyle() or (self.db and self.db.hideGoldBorder))

	if Button.border then
		SetTextureShown(Button.border, showBorder)
	end

	if Button.SMBGoldBorder then
		if Button.SMBGoldBorder.IsObjectType then
			SetTextureShown(Button.SMBGoldBorder, showBorder)
		else
			for _, texture in ipairs(Button.SMBGoldBorder) do
				SetTextureShown(texture, showBorder)
			end
		end
	end

	for i = 1, Button:GetNumRegions() do
		local region = T.select(i, Button:GetRegions())
		if IsGoldBorderTexture(region) then
			SetTextureShown(region, showBorder)
		end
	end
end

function SMB:ApplyOriginalButtonLook(Button)
	if not Button then return end

	local showBackdrop = self.db and self.db.hideGoldBorder

	if not Button.backdrop and Button.CreateBackdrop then
		Button:CreateBackdrop("Default")
	end
	if Button.backdrop then
		if showBackdrop then
			if Button.backdrop.SetTemplate then
				Button.backdrop:SetTemplate("Default")
			end
			Button.backdrop:SetFrameStrata(Button:GetFrameStrata())
			Button.backdrop:SetFrameLevel(max(Button:GetFrameLevel() - 1, 0))
			Button.backdrop:Show()
		else
			Button.backdrop:Hide()
		end
	end
	if Button.ishadow then
		Button.ishadow:Hide()
	end
	if Button.SMBIcon then
		Button.SMBIcon:SetTexture(nil)
		Button.SMBIcon:SetAlpha(0)
		Button.SMBIcon:Hide()
	end
	if Button.SMBOriginalIcon then
		Button.SMBOriginalIcon:SetParent(Button)
		Button.SMBOriginalIcon:SetAlpha(1)
		Button.SMBOriginalIcon:Show()
	end
	if Button.SMBIconFrame then
		Button.SMBIconFrame:Hide()
	end

	self:ApplyGoldBorderSetting(Button)
end

function SMB:HandleBlizzardButtons()
	if not SMB.db.enable then return end
	if T.InCombatLockdown() then
		self.PendingLayout = true
		return
	end

	local garrisonButton = _G.GarrisonLandingPageMinimapButton
	local mailFrame = _G.MiniMapMailFrame
	local mailIcon = _G.MiniMapMailIcon
	local mailBorder = _G.MiniMapMailBorder
	local trackingFrame = (_G.MinimapCluster and (_G.MinimapCluster.Tracking or _G.MinimapCluster.TrackingFrame)) or _G.MiniMapTrackingFrame or _G.MiniMapTracking
	local trackingButton = _G.MiniMapTrackingButton or trackingFrame
	local queueButton = _G.QueueStatusMinimapButton
	local allowBlizzard = (SMB.db.buttonSource or "ALL") ~= "ADDON"
	local useOriginalStyle = UseOriginalButtonStyle()

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
		if not useOriginalStyle then
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
		end

		garrisonButton.SMB = true
		CaptureNativeButtonMetrics(garrisonButton)
		self:RegisterButton(garrisonButton, "GARRISON", "blizzard")
	end

	if SMB.db.moveMail and mailFrame and not mailFrame.SMB and mailIcon then
		if useOriginalStyle then
			mailFrame:SetParent(_G.Minimap)
			mailFrame:Show()
			mailFrame.SMB = true
			mailFrame.SMBGoldBorder = mailBorder
			CaptureNativeButtonMetrics(mailFrame)
			self:RegisterButton(mailFrame, "MAIL", "blizzard")
		else
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
				if SMB.Bar:IsShown() and SMB.db.barMouseOver then
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
	end
	
	if SMB.db.moveTracker and trackingFrame and trackingButton and not trackingButton.SMB then
		if useOriginalStyle then
			trackingFrame.Show = nil
			trackingFrame:Show()
			trackingFrame:SetParent(_G.Minimap)
			trackingFrame.SMBGoldBorder = {
				_G.MiniMapTrackingButtonBorder,
				_G.MiniMapTrackingIconOverlay,
			}
			trackingButton.SMB = true
			trackingFrame.SMB = true
			CaptureNativeButtonMetrics(trackingFrame)
			self:RegisterButton(trackingFrame, "TRACKING", "blizzard")
		else
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
	end

	if SMB.db.moveQueue and queueButton and not queueButton.SMB then
		if useOriginalStyle then
			queueButton:SetParent(_G.Minimap)
			queueButton.SMB = true
			queueButton.SMBGoldBorder = _G.QueueStatusMinimapButtonBorder
			CaptureNativeButtonMetrics(queueButton)
			self:RegisterButton(queueButton, "QUEUE", "blizzard")
		else
			local Frame = T.CreateFrame('Frame', 'SMB_QueueFrame', self.Bar)
			Frame:SetTemplate()
			Frame:SetSize(SMB.db.iconSize, SMB.db.iconSize)
			Frame.Icon = Frame:CreateTexture(nil, 'ARTWORK')
			Frame.Icon:SetSize(SMB.db.iconSize, SMB.db.iconSize)
			Frame.Icon:SetPoint('CENTER')
			Frame.Icon:SetTexture([[Interface\LFGFrame\LFG-Eye]])
			Frame.Icon:SetTexCoord(0, 64 / 512, 0, 64 / 256)
			Frame:SetScript('OnMouseDown', function()
				if not _G.PVEFrame then return end
				if _G.PVEFrame:IsShown() then
					T.HideUIPanel(_G.PVEFrame)
				else
					T.ShowUIPanel(_G.PVEFrame)
					if T.GroupFinderFrame_ShowGroupFrame then
						T.GroupFinderFrame_ShowGroupFrame()
					elseif _G.GroupFinderFrame_ShowGroupFrame then
						_G.GroupFinderFrame_ShowGroupFrame()
					end
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

			if queueButton.SetHighlightTexture then
				queueButton:SetHighlightTexture("")
			end

			queueButton:HookScript('OnShow', function(self)
				Frame:EnableMouse(false)
			end)
			if T.QueueStatusMinimapButton_OnLeave then
				queueButton:HookScript('PostClick', T.QueueStatusMinimapButton_OnLeave)
			elseif _G.QueueStatusMinimapButton_OnLeave then
				queueButton:HookScript('PostClick', _G.QueueStatusMinimapButton_OnLeave)
			end
			queueButton:HookScript('OnHide', function(self)
				Frame:EnableMouse(true)
			end)

			queueButton.SMB = true
			self:RegisterButton(Frame, "QUEUE", "blizzard")
		end
	end
		
	self:Update()
end

function SMB:SkinMinimapButton(Button)
	if (not Button) or Button.isSkinned then return end
	if Button == self.Bar or Button == self.Hider or Button == self.Toggle then return end

	local Name = Button:GetName()
	local IsLibDB = IsLibDBIconButton(Button)
	local OriginalIconTexture = GetPrimaryIconTexture(Button) or GetExplicitButtonIconTexture(Button)
	local IconTexture = OriginalIconTexture
	local left, right, top, bottom = GetTextureTexCoords(OriginalIconTexture)
	if not Name then return end
	if not OriginalIconTexture then return end

	if IsForbiddenMinimapButton(Name) then return end

	for i = 1, #GenericIgnores do
		if T.string_sub(Name, 1, T.string_len(GenericIgnores[i])) == GenericIgnores[i] then return end
	end

	for i = 1, #PartialIgnores do
		if T.string_find(Name, PartialIgnores[i]) ~= nil then return end
	end

	if UseOriginalButtonStyle() then
		CaptureNativeButtonMetrics(Button)
		Button:SetFrameLevel(_G.Minimap:GetFrameLevel() + 5)
		Button:SetScale(1)
		Button.isSkinned = true
		self:RegisterButton(Button, Name, "addon")
		self:ApplyOriginalButtonLook(Button)
		return
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

	ApplySquareButtonBorder(Button)

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
					AnchorSquareIcon(Button, Region, IsLibDB, left, right, top, bottom)
					if IsLibDB and left ~= nil then
						Button:HookScript('OnLeave', function() Region:SetTexCoord(left, right, top, bottom) end)
					elseif IsLibDB then
						Button:HookScript('OnLeave', function() Region:SetTexCoord(0, 1, 0, 1) end)
					else
						Button:HookScript('OnLeave', function() Region:SetTexCoord(T.unpack(self.TexCoords)) end)
					end
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
		AnchorSquareIcon(Button, IconTexture, IsLibDB, left, right, top, bottom)
		if IconTexture.SetVertexColor and not IsLibDB then
			IconTexture:SetVertexColor(1, 1, 1, 1)
		end
		if IconTexture.SetDesaturated and not IsLibDB then
			IconTexture:SetDesaturated(false)
		end
		if IconTexture.SetBlendMode and not IsLibDB then
			IconTexture:SetBlendMode("BLEND")
		end
	end

	Button:SetFrameLevel(_G.Minimap:GetFrameLevel() + 5)
	Button:SetSize(SMB.db.iconSize, SMB.db.iconSize)
	ApplySquareButtonBorder(Button)
	if Button.CreateIconShadow then
		Button:CreateIconShadow()
	end
	if Button.ishadow then
		Button.ishadow:Show()
	end

	-- Keep LibDB icons on their original live texture path so brokers that swap
	-- icons at runtime (for example WeakAuras) keep updating correctly.
	Button.SMBOriginalIcon = OriginalIconTexture

	if Button.SMBOriginalIcon then
		AnchorSquareIcon(Button, Button.SMBOriginalIcon, IsLibDB, left, right, top, bottom)
	end

	if IsLibDB and Button.SMBIcon then
		Button.SMBIcon:SetTexture(nil)
		Button.SMBIcon:SetAlpha(0)
		Button.SMBIcon:Hide()
	end

	Button:HookScript('OnEnter', function(self)
		SMB.MouseOver = true
		self.backdrop:SetBackdropBorderColor(T.unpack(E["media"].rgbvaluecolor))
		if SMB.Bar:IsShown() then
			T.UIFrameFadeIn(SMB.Bar, 0.2, SMB.Bar:GetAlpha(), 1)
		end
	end)
	Button:HookScript('OnLeave', function(self)
		SMB.MouseOver = false
		ApplySquareButtonBorder(self)
		if self.SMBIcon then
			self.SMBIcon:SetTexture(nil)
			self.SMBIcon:SetAlpha(0)
			self.SMBIcon:Hide()
		end
		if self.SMBOriginalIcon then
			AnchorSquareIcon(self, self.SMBOriginalIcon, IsLibDBIconButton(self), left, right, top, bottom)
		end
		if self.ishadow then
			self.ishadow:Show()
		end
		if SMB.Bar:IsShown() and SMB.db.barMouseOver then
			T.UIFrameFadeOut(SMB.Bar, 0.2, SMB.Bar:GetAlpha(), 0)
		end
	end)
	Button:HookScript("OnMouseDown", function(self, button)
		self.SMBPendingRightClickHide = (button == "RightButton")
	end)
	Button:HookScript("OnMouseUp", function(self)
		if self.SMBPendingRightClickHide then
			T.C_Timer_After(0.5, function()
				if self and self.SMBPendingRightClickHide and self:IsShown() then
					self.SMBPendingRightClickHide = nil
				end
			end)
		end
	end)
	Button:HookScript("OnHide", function(self)
		if self.SMBPendingRightClickHide and self:GetParent() ~= SMB.Hider then
			self.SMBPendingRightClickHide = nil
			SMB:RemoveHiddenButtonFromConfiguredLists(self)
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

function SMB:IsValidButton(Button)
	if not Button or Button == self.Bar or Button == self.Hider or Button == self.Toggle then return false end
	if Button.IsForbidden and Button:IsForbidden() then return false end
	if not Button.IsObjectType or not (Button:IsObjectType("Button") or Button:IsObjectType("Frame")) then return false end
	if not Button.SMBRegistered or not Button.SMBData then return false end

	return true
end

function SMB:AddButtonToList(list, added, Button)
	if not self:IsValidButton(Button) or added[Button] then return end

	added[Button] = true
	T.table_insert(list, Button)
end

function SMB:SortButtons(buttons, orderMap)
	local sortBy = SMB.db.sortBy or "ADDED"
	if sortBy == "ADDED" then return end

	sort(buttons, function(a, b)
		local aData, bData = a.SMBData or {}, b.SMBData or {}
		local aKey, bKey = aData.key or "", bData.key or ""
		local aOrder = sortBy == "BY_FILTERING" and GetButtonTokenOrder(aData, orderMap)
		local bOrder = sortBy == "BY_FILTERING" and GetButtonTokenOrder(bData, orderMap)

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
		elseif sortBy == "TYPE_NAME" and aData.kind ~= bData.kind then
			return aData.kind == "blizzard"
		end

		return aKey < bKey
	end)
end

function SMB:PrepareButtonForLayout(Button, buttonSize)
	Button:SetParent(self.Bar)
	Button:SetAlpha(1)
	if Button.EnableMouse then
		Button:EnableMouse(true)
	end

	Button:ClearAllPoints()
	if UseOriginalButtonStyle() then
		CaptureNativeButtonMetrics(Button)
		Button:SetSize(Button.SMBNativeWidth or buttonSize, Button.SMBNativeHeight or buttonSize)
		Button:SetScale(GetOriginalStyleScale(Button, buttonSize))
	else
		Button:SetSize(buttonSize, buttonSize)
		Button:SetScale(1)
	end
	Button:SetFrameStrata("MEDIUM")
	Button:SetFrameLevel(self.Bar:GetFrameLevel() + 1)
end

function SMB:ApplyButtonStyle(Button)
	if UseOriginalButtonStyle() then
		self:ApplyOriginalButtonLook(Button)
	else
		ApplySquareButtonBorder(Button)
		if Button.SMBIcon then
			Button.SMBIcon:SetTexture(nil)
			Button.SMBIcon:SetAlpha(0)
			Button.SMBIcon:Hide()
		end
		if Button.SMBOriginalIcon then
			AnchorSquareIcon(Button, Button.SMBOriginalIcon, IsLibDBIconButton(Button), GetTextureTexCoords(Button.SMBOriginalIcon))
		end
		if Button.ishadow then
			Button.ishadow:Show()
		end
		if Button.SMBIconFrame then
			Button.SMBIconFrame:Hide()
		end
	end
end

function SMB:LayoutButtons(buttons)
	local buttonSize = self:GetButtonSize()
	local spacing = self:GetButtonSpacing()
	local buttonsPerRow = max(floor(self:GetButtonsPerRow()), 1)
	local visibleCount = #buttons
	local horizontalFirst, growsRight, growsDown = GetGrowthSettings(self.db.growthDirection)
	local columns, rows = 0, 0

	if visibleCount > 0 then
		if horizontalFirst then
			columns = min(visibleCount, buttonsPerRow)
			rows = ceil(visibleCount / buttonsPerRow)
		else
			rows = min(visibleCount, buttonsPerRow)
			columns = ceil(visibleCount / buttonsPerRow)
		end
	end

	local step = buttonSize + spacing

	for index, Button in ipairs(buttons) do
		self:PrepareButtonForLayout(Button, buttonSize)

		local position = index - 1
		local col, row

		if horizontalFirst then
			col = position % buttonsPerRow
			row = floor(position / buttonsPerRow)
		else
			row = position % buttonsPerRow
			col = floor(position / buttonsPerRow)
		end

		local visualCol = growsRight and col or (columns - 1 - col)
		local visualRow = growsDown and row or (rows - 1 - row)
		local x = (visualCol * step) + (buttonSize / 2)
		local y = -((visualRow * step) + (buttonSize / 2))

		Button:SetPoint("CENTER", self.Bar, "TOPLEFT", x, y)
		self:ApplyButtonStyle(Button)
		Button:SetScript("OnDragStart", nil)
		Button:SetScript("OnDragStop", nil)
		SMB:LockButton(Button)
	end

	local minBarSize = self.db.enableCollapse and 16 or buttonSize
	local barWidth = visibleCount > 0 and ((columns * buttonSize) + ((columns - 1) * spacing)) or minBarSize
	local barHeight = visibleCount > 0 and ((rows * buttonSize) + ((rows - 1) * spacing)) or minBarSize

	self.Bar:SetSize(barWidth, barHeight)
end

function SMB:UpdateButtonBar()
	if T.InCombatLockdown() then
		self.PendingLayout = true
		return
	end

	self:SyncConfiguredLists()
	self:RefreshButtonFilters()

	local activeButtons, layoutButtons = {}, {}
	local activeAdded, layoutAdded = {}, {}
	local collapsed = self.Collapsed

	for _, Button in ipairs(SMB.Buttons) do
		SMB:UnlockButton(Button)

		if self:IsValidButton(Button) and self:ShouldKeepButton(Button, collapsed) then
			self:AddButtonToList(activeButtons, activeAdded, Button)
			if Button:IsShown() then
				self:AddButtonToList(layoutButtons, layoutAdded, Button)
			end
		end
	end

	self:SortButtons(layoutButtons, collapsed and self.CollapsedButtonsOrderMap or self.WhiteListOrderMap)

	for _, Button in ipairs(SMB.Buttons) do
		if self:IsValidButton(Button) then
			if activeAdded[Button] then
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
	end

	self:LayoutButtons(layoutButtons)
	self:ApplyBarPosition()
	self:UpdateCollapseToggle()

	if SMB.db.backdrop then
		self.Bar:CreateBackdrop("Transparent", true)
		if self.Bar.Styling then
			self.Bar:Styling()
		end
	else
		if self.Bar.SetBackdrop then self.Bar:SetBackdrop(nil) end
		if self.Bar.squares or self.Bar.gradient or self.Bar.mshadow then
			self.Bar.squares:SetTexture(nil)
			self.Bar.gradient:SetTexture(nil)
			self.Bar.mshadow:SetTexture(nil)
		end
	end

	if #layoutButtons == 0 and not self.db.enableCollapse then
		self.Bar:Hide()
	else
		self.Bar:Show()
	end

	self.MouseOver = (self.Bar and self.Bar:IsMouseOver()) or (self.Toggle and self.Toggle:IsMouseOver()) or false
	if not self.MouseOver then
		for _, Button in ipairs(layoutButtons) do
			if Button.IsMouseOver and Button:IsMouseOver() then
				self.MouseOver = true
				break
			end
		end
	end

	if SMB.db.barMouseOver then
		if self.MouseOver then
			T.UIFrameFadeIn(self.Bar, 0.2, self.Bar:GetAlpha(), 1)
		else
			T.UIFrameFadeOut(self.Bar, 0.2, self.Bar:GetAlpha(), 0)
		end
	else
		T.UIFrameFadeIn(self.Bar, 0.2, self.Bar:GetAlpha(), 1)
	end
end

function SMB:GrabMinimapButtons()
	if T.InCombatLockdown() then
		self.PendingLayout = true
		self.NeedsFullScan = true
		return
	end
	if IsInPetBattle() then return end
	local changed = false

	self:HookLibDBIconButtons()

	if self:CollectLibDBIconButtons() then
		changed = true
	end

	if self:CollectLibMapButtonButtons() then
		changed = true
	end

	-- O(n) statt O(n²): GetChildren() einmal aufrufen und in Tabelle packen
	for _, Frame in T.pairs({ _G.Minimap, _G.MinimapBackdrop, _G.MinimapCluster }) do
		if Frame then
			local NumChildren = Frame:GetNumChildren()
			if self.NeedsFullScan or NumChildren ~= (Frame.SMBNumChildren or 0) then
				local children = {Frame:GetChildren()}
				for i = 1, NumChildren do
					local object = children[i]
					if object then
						local name = object:GetName()
						local width = object:GetWidth()
						if name and width > 15 and width < 96 and (object:IsObjectType('Button') or object:IsObjectType('Frame')) then
							if self:TrySkinAndRegisterButton(object) then
								changed = true
							end
						end
					end
				end
			end

			Frame.SMBNumChildren = NumChildren
		end
	end

	for _, object in T.pairs({
		_G.WIM3MinimapButton,
		_G["AllTheThings-Minimap"],
	}) do
		if self:TrySkinAndRegisterButton(object) then
			changed = true
		end
	end

	local uiParentChildren = UIParent:GetNumChildren()
	if self.NeedsFullScan or uiParentChildren ~= (self.UIParentNumChildren or 0) then
		-- O(n) statt O(n²): UIParent hat 200-400 Kinder; select(i, GetChildren()) war O(n²)
		local children = {UIParent:GetChildren()}
		for i = 1, uiParentChildren do
			local object = children[i]
			if object and object ~= self.Bar and object ~= self.Hider and object ~= self.Toggle and (not object.IsForbidden or not object:IsForbidden()) and (object:IsObjectType('Button') or object:IsObjectType('Frame')) then
				local width = object:GetWidth()
				if width and width > 15 and width < 96 and IsLikelyNamedMinimapButton(object) then
					if self:TrySkinAndRegisterButton(object) then
						changed = true
					end
				end
			end
		end
	end
	self.UIParentNumChildren = uiParentChildren
	self.NeedsFullScan = false

	if changed then
		self:Update()
	end
end

function SMB:Update()
	if not SMB.db.enable then return end
	self:UpdateButtonBar()
end

function SMB:PLAYER_REGEN_DISABLED()
	if SMB.db.hideInCombat then SMB.Bar:Hide() end
end

function SMB:PLAYER_REGEN_ENABLED()
	if SMB.db.enable then SMB.Bar:Show() end
	if self.PendingLayout then
		self.PendingLayout = nil
		self:HandleBlizzardButtons()
		self:GrabMinimapButtons()
		self:Update()
	end
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
	if SMB.db.buttonStyle == nil then SMB.db.buttonStyle = "SQUARE" end
	if SMB.db.hideGoldBorder == nil then SMB.db.hideGoldBorder = false end
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

	SMB.Bar:SetScript('OnEnter', function(self)
		SMB.MouseOver = true
		T.UIFrameFadeIn(self, 0.2, self:GetAlpha(), 1)
	end)
	SMB.Bar:SetScript('OnLeave', function(self)
		SMB.MouseOver = false
		if SMB.db['barMouseOver'] then
			T.UIFrameFadeOut(self, 0.2, self:GetAlpha(), 0)
		end
	end)

	function SMB:ForUpdateAll()
		SMB.db = E.db.KlixUI.maps.minimap.buttons
		SMB.NeedsFullScan = true
		SMB:RefreshSettings()
	end
	SMB:ForUpdateAll()

	self:RegisterEvent("PLAYER_REGEN_DISABLED")
	self:RegisterEvent("PLAYER_REGEN_ENABLED")
	
	E:CreateMover(SMB.Bar, "KUI_SquareMinimapButtonBarMover", L["Square Minimap Buttons Bar"], nil, nil, nil, 'ALL,GENERAL,KLIXUI', nil, "KlixUI,modules,maps,minimap,buttons")
	SMB:RefreshSettings()

	SMB.TexCoords = {T.unpack(E.TexCoords)}

	SMB:HookLibDBIconButtons()
	SMB:HandleBlizzardButtons()
	SMB:GrabMinimapButtons()
	SMB:ScheduleTimer("HookLibDBIconButtons", 1)
	SMB:ScheduleTimer("GrabMinimapButtons", 1)
	SMB:ScheduleRepeatingTimer('GrabMinimapButtons', 6)
	SMB:ScheduleTimer('HandleBlizzardButtons', 7)
end

KUI:RegisterModule(SMB:GetName())
