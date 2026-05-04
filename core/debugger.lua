local KUI, T, E = unpack(select(2, ...))

local _G = _G
local CreateFrame = CreateFrame
local format = string.format
local gmatch = string.gmatch
local lower = string.lower
local match = string.match
local strtrim = strtrim
local tinsert = table.insert
local table_concat = table.concat
local tostring = tostring

local function SafeName(object)
	if not object then
		return "nil"
	end

	if object.GetName then
		local name = object:GetName()
		if name and name ~= "" then
			return name
		end
	end

	return "<anonymous>"
end

local function BoolText(value)
	return value and "true" or "false"
end

local function SafeCall(object, method)
	if object and object[method] then
		return object[method](object)
	end
end

local function TextureText(texture)
	if not texture or not texture.IsObjectType or not texture:IsObjectType("Texture") then
		return "nil"
	end

	local texturePath = texture.GetTexture and texture:GetTexture()
	local atlas = texture.GetAtlas and texture:GetAtlas()
	local drawLayer, subLevel = texture.GetDrawLayer and texture:GetDrawLayer()
	local alpha = texture.GetAlpha and texture:GetAlpha()
	local shown = texture.IsShown and texture:IsShown()

	return format(
		"%s | tex=%s | atlas=%s | layer=%s:%s | alpha=%s | shown=%s",
		SafeName(texture),
		tostring(texturePath or "nil"),
		tostring(atlas or "nil"),
		tostring(drawLayer or "nil"),
		tostring(subLevel or "nil"),
		tostring(alpha or "nil"),
		BoolText(shown)
	)
end

local function AddLine(lines, text, ...)
	if select("#", ...) > 0 then
		text = format(text, ...)
	end

	tinsert(lines, text)
end

local function AddPointInfo(lines, frame)
	if not frame or not frame.GetNumPoints then return end

	local points = frame:GetNumPoints() or 0
	AddLine(lines, "Points: %d", points)

	for i = 1, points do
		local point, anchor, relativePoint, x, y = frame:GetPoint(i)
		AddLine(
			lines,
			"  [%d] %s -> %s:%s (%s, %s)",
			i,
			tostring(point),
			SafeName(anchor),
			tostring(relativePoint),
			tostring(x),
			tostring(y)
		)
	end
end

local function AddTextureSlots(lines, frame)
	if not frame then return end

	local slots = {
		{ "icon", frame.icon },
		{ "Icon", frame.Icon },
		{ "texture", frame.texture },
		{ "Texture", frame.Texture },
		{ "SMBIcon", frame.SMBIcon },
		{ "NormalTexture", frame.GetNormalTexture and frame:GetNormalTexture() or nil },
		{ "PushedTexture", frame.GetPushedTexture and frame:GetPushedTexture() or nil },
		{ "HighlightTexture", frame.GetHighlightTexture and frame:GetHighlightTexture() or nil },
	}

	AddLine(lines, "Texture slots:")
	for _, slot in ipairs(slots) do
		AddLine(lines, "  %s: %s", slot[1], TextureText(slot[2]))
	end
end

local function AddRegionInfo(lines, frame, limit)
	if not frame or not frame.GetNumRegions then return end

	local numRegions = frame:GetNumRegions() or 0
	AddLine(lines, "Regions: %d", numRegions)

	limit = limit or 8
	for i = 1, numRegions do
		if i > limit then
			AddLine(lines, "  ... %d more regions", numRegions - limit)
			break
		end

		local region = select(i, frame:GetRegions())
		if region and region.IsObjectType and region:IsObjectType("Texture") then
			AddLine(lines, "  [%d] %s", i, TextureText(region))
		else
			AddLine(lines, "  [%d] %s", i, region and region:GetObjectType() or "nil")
		end
	end
end

local function BuildFrameDump(frame)
	local lines = {}
	AddLine(lines, "Frame: %s", SafeName(frame))
	AddLine(lines, "Type: %s", frame and frame.GetObjectType and frame:GetObjectType() or "nil")
	AddLine(lines, "Parent: %s", SafeName(frame and frame.GetParent and frame:GetParent() or nil))
	AddLine(lines, "Shown: %s", BoolText(frame and frame.IsShown and frame:IsShown()))
	AddLine(lines, "Visible: %s", BoolText(frame and frame.IsVisible and frame:IsVisible()))
	AddLine(lines, "Protected: %s", BoolText(frame and frame.IsProtected and frame:IsProtected()))
	AddLine(lines, "Forbidden: %s", BoolText(frame and frame.IsForbidden and frame:IsForbidden()))
	AddLine(lines, "FrameStrata: %s", tostring(frame and frame.GetFrameStrata and frame:GetFrameStrata() or "nil"))
	AddLine(lines, "FrameLevel: %s", tostring(frame and frame.GetFrameLevel and frame:GetFrameLevel() or "nil"))
	AddLine(lines, "Alpha: %s", tostring(frame and frame.GetAlpha and frame:GetAlpha() or "nil"))
	AddLine(lines, "Size: %s x %s", tostring(frame and frame.GetWidth and frame:GetWidth() or "nil"), tostring(frame and frame.GetHeight and frame:GetHeight() or "nil"))
	AddPointInfo(lines, frame)
	AddTextureSlots(lines, frame)
	AddRegionInfo(lines, frame)

	return table_concat(lines, "\n")
end

local function GetSMBModule()
	local ok, module = pcall(KUI.GetModule, KUI, "KuiSquareMinimapButtons")
	if ok then
		return module
	end
end

local function FindSMBButton(token)
	local module = GetSMBModule()
	if not module or not module.Buttons then return end

	token = lower(strtrim(token or ""))
	if token == "" then return end

	for _, button in ipairs(module.Buttons) do
		local name = button and button.GetName and button:GetName()
		local key = button and button.SMBData and button.SMBData.key
		local displayKey = button and button.SMBData and button.SMBData.displayKey

		if lower(tostring(name or "")) == token or lower(tostring(key or "")) == token or lower(tostring(displayKey or "")) == token then
			return button
		end
	end
end

function KUI:CreateDebugFrame()
	if self.DebugFrame then
		return self.DebugFrame
	end

	local frame = CreateFrame("Frame", "KlixUIDebuggerFrame", E.UIParent or _G.UIParent, "BackdropTemplate")
	frame:SetSize(900, 620)
	frame:SetPoint("CENTER")
	frame:SetFrameStrata("DIALOG")
	frame:SetMovable(true)
	frame:EnableMouse(true)
	frame:RegisterForDrag("LeftButton")
	frame:SetClampedToScreen(true)
	frame:SetScript("OnDragStart", frame.StartMoving)
	frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
	frame:CreateBackdrop("Transparent")
	if frame.backdrop and frame.backdrop.Styling then
		frame.backdrop:Styling()
	end

	frame.title = frame:CreateFontString(nil, "OVERLAY")
	frame.title:SetFont(E.media.normFont, 14, "OUTLINE")
	frame.title:SetPoint("TOPLEFT", frame, "TOPLEFT", 12, -12)
	frame.title:SetJustifyH("LEFT")

	local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
	close:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -4, -4)

	local scroll = CreateFrame("ScrollFrame", "KlixUIDebuggerScrollFrame", frame, "UIPanelScrollFrameTemplate")
	scroll:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -34)
	scroll:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -32, 10)

	local editBox = CreateFrame("EditBox", "KlixUIDebuggerEditBox", scroll)
	editBox:SetMultiLine(true)
	editBox:SetAutoFocus(false)
	editBox:SetFontObject(ChatFontNormal)
	editBox:SetWidth(840)
	editBox:SetScript("OnEscapePressed", function() frame:Hide() end)
	editBox:SetScript("OnTextChanged", function(self)
		scroll:UpdateScrollChildRect()
	end)
	editBox:SetTextInsets(4, 4, 4, 4)
	scroll:SetScrollChild(editBox)

	frame.scroll = scroll
	frame.editBox = editBox
	frame:Hide()

	self.DebugFrame = frame
	return frame
end

function KUI:ShowDebugOutput(title, text)
	local frame = self:CreateDebugFrame()
	frame.title:SetText(title or "KlixUI Debugger")
	frame.editBox:SetText(text or "")
	frame.editBox:HighlightText(0, 0)
	frame.editBox:SetCursorPosition(0)
	frame.scroll:SetVerticalScroll(0)
	frame:Show()
end

function KUI:DebugFrameCommand(frameName)
	frameName = strtrim(frameName or "")
	if frameName == "" then
		self:Print("Usage: /kuidbg frame <GlobalFrameName>")
		return
	end

	local frame = _G[frameName]
	if not frame then
		self:Print("Frame not found: " .. frameName)
		return
	end

	self:ShowDebugOutput("Frame Debug: " .. frameName, BuildFrameDump(frame))
end

function KUI:DebugMinimapButtonCommand(token)
	token = strtrim(token or "")
	if token == "" then
		self:Print("Usage: /kuidbg button <FrameName or Token>")
		return
	end

	local button = _G[token] or FindSMBButton(token)
	if not button then
		self:Print("Minimap button not found: " .. token)
		return
	end

	self:ShowDebugOutput("Minimap Button Debug: " .. SafeName(button), BuildFrameDump(button))
end

function KUI:DebugMinimapButtons()
	local lines = {}
	local module = GetSMBModule()

	if not module then
		AddLine(lines, "KuiSquareMinimapButtons module not available.")
		self:ShowDebugOutput("Minimap Buttons Debug", table_concat(lines, "\n"))
		return
	end

	AddLine(lines, "Module: %s", module:GetName())
	AddLine(lines, "Buttons registered: %d", #(module.Buttons or {}))
	AddLine(lines, "Bar: %s", SafeName(module.Bar))
	AddLine(lines, "Hider: %s", SafeName(module.Hider))
	AddLine(lines, "Collapsed: %s", BoolText(module.Collapsed))

	if module.db then
		AddLine(lines, "db.enable: %s", BoolText(module.db.enable))
		AddLine(lines, "db.buttonSource: %s", tostring(module.db.buttonSource))
		AddLine(lines, "db.sortBy: %s", tostring(module.db.sortBy))
		AddLine(lines, "db.whitelist: %s", tostring(module.db.whitelist))
		AddLine(lines, "db.blacklist: %s", tostring(module.db.blacklist))
		AddLine(lines, "db.collapsedButtons: %s", tostring(module.db.collapsedButtons))
	end

	for index, button in ipairs(module.Buttons or {}) do
		AddLine(lines, "")
		AddLine(lines, "[%d] %s", index, SafeName(button))
		AddLine(lines, "  parent=%s | shown=%s | alpha=%s | size=%sx%s", SafeName(button and button.GetParent and button:GetParent() or nil), BoolText(button and button.IsShown and button:IsShown()), tostring(button and button.GetAlpha and button:GetAlpha() or "nil"), tostring(button and button.GetWidth and button:GetWidth() or "nil"), tostring(button and button.GetHeight and button:GetHeight() or "nil"))
		if button and button.SMBData then
			AddLine(lines, "  key=%s | display=%s | kind=%s", tostring(button.SMBData.key), tostring(button.SMBData.displayKey), tostring(button.SMBData.kind))
		end

		AddLine(lines, "  icon=%s", TextureText(button and button.icon))
		AddLine(lines, "  Icon=%s", TextureText(button and button.Icon))
		AddLine(lines, "  SMBIcon=%s", TextureText(button and button.SMBIcon))
		AddLine(lines, "  normal=%s", TextureText(button and button.GetNormalTexture and button:GetNormalTexture() or nil))
		AddLine(lines, "  pushed=%s", TextureText(button and button.GetPushedTexture and button:GetPushedTexture() or nil))
		AddLine(lines, "  highlight=%s", TextureText(button and button.GetHighlightTexture and button:GetHighlightTexture() or nil))

		local count = button and button.GetNumRegions and button:GetNumRegions() or 0
		for regionIndex = 1, count do
			if regionIndex > 5 then
				AddLine(lines, "  ... %d more regions", count - 5)
				break
			end

			local region = select(regionIndex, button:GetRegions())
			if region and region.IsObjectType and region:IsObjectType("Texture") then
				AddLine(lines, "  region[%d]=%s", regionIndex, TextureText(region))
			end
		end
	end

	self:ShowDebugOutput("Minimap Buttons Debug", table_concat(lines, "\n"))
end

function KUI:DebugTaintFrames()
	local lines = {}
	local frames = {
		"WorldMapFrame",
		"QuestScrollFrame",
		"GameMenuFrame",
		"FriendsFrame",
		"ChatMenu",
		"VoiceChatPromptActivateChannel",
		"Minimap",
		"MiniMapTracking",
		"MiniMapTrackingButton",
		"QueueStatusMinimapButton",
		"PartyMemberFrame1",
		"PartyMemberFrame1PetFrame",
		"RaidFrame",
		"RaidParentFrame",
		"CompactRaidFrameManager",
		"CompactRaidFrameContainer",
		"CompactPartyFrame",
		"CellRaidFrameHeader0UnitButton15",
		"CellQuickCastButton",
		"CharacterFrame",
		"PaperDollFrame",
	}

	AddLine(lines, "combat=%s | lastProtectedAction=%s | queued=%s", BoolText(T.InCombatLockdown and T.InCombatLockdown()), tostring(self.LastProtectedAction or "nil"), BoolText(self.LastProtectedActionQueued))
	AddLine(lines, "lastUnsafeFrame=%s | reason=%s", tostring(self.LastUnsafeFrame or "nil"), tostring(self.LastUnsafeFrameReason or "nil"))

	for _, frameName in ipairs(frames) do
		local frame = _G[frameName]
		AddLine(
			lines,
			"%s | exists=%s | shown=%s | protected=%s | forbidden=%s | unsafeUnit=%s | parent=%s",
			frameName,
			BoolText(not not frame),
			BoolText(frame and frame.IsShown and frame:IsShown()),
			BoolText(frame and frame.IsProtected and frame:IsProtected()),
			BoolText(frame and frame.IsForbidden and frame:IsForbidden()),
			BoolText(frame and self.IsUnsafeUnitFrame and self:IsUnsafeUnitFrame(frame)),
			SafeName(frame and frame.GetParent and frame:GetParent() or nil)
		)
	end

	self:ShowDebugOutput("Taint Debug", table_concat(lines, "\n"))
end

function KUI:DebugCommand(msg)
	msg = strtrim(msg or "")

	local command, rest = match(msg, "^(%S+)%s*(.-)$")
	command = lower(command or "")
	rest = rest or ""

	if command == "" or command == "help" then
		self:ShowDebugOutput("KlixUI Debugger Help", table_concat({
			"/kuidbg help",
			"/kuidbg minimap",
			"/kuidbg button <FrameName or Token>",
			"/kuidbg frame <GlobalFrameName>",
			"/kuidbg taint",
			"",
			"Examples:",
			"/kuidbg minimap",
			"/kuidbg button LibDBIcon10_WeakAuras",
			"/kuidbg frame WorldMapFrame",
			"/kuidbg taint",
		}, "\n"))
		return
	elseif command == "minimap" or command == "smb" then
		self:DebugMinimapButtons()
		return
	elseif command == "button" then
		self:DebugMinimapButtonCommand(rest)
		return
	elseif command == "frame" then
		self:DebugFrameCommand(rest)
		return
	elseif command == "taint" then
		self:DebugTaintFrames()
		return
	end

	self:Print("Unknown debug command. Use /kuidbg help")
end
