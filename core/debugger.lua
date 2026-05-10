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

-- ============================================================
-- Function-level trace
-- Usage: /kuidbg trace [threshold_ms]   start (default 5ms)
--        /kuidbg trace stop             show report
-- ============================================================
local trace = {
	active    = false,
	threshold = 5,
	results   = {},
	restores  = {},
}

local function TraceWrap(label, fn, threshold)
	local results = trace.results
	return function(self, ...)
		local t0 = GetTime()
		fn(self, ...)
		local ms = (GetTime() - t0) * 1000
		if ms >= threshold then
			tinsert(results, { label = label, ms = ms })
			if #results <= 20 then
				KUI:Print(format("|cff8080ff[TRACE]|r %s = %.1f ms", label, ms))
			end
		end
	end
end

function KUI:TraceStart(threshold)
	if trace.active then
		self:Print("|cffff8800[trace]|r already running – /kuidbg trace stop first")
		return
	end
	trace.threshold = threshold or 5
	trace.results   = {}
	trace.restores  = {}
	trace.active    = true

	local found = {}

	-- Instrument KUI_LocPanel OnUpdate (locpanel UpdateCoords, 0.2s throttle)
	local lp = _G["KUI_LocPanel"]
	if lp then
		local orig = lp:GetScript("OnUpdate")
		if orig then
			lp:SetScript("OnUpdate", TraceWrap("locpanel:UpdateCoords", orig, trace.threshold))
			local restore_lp = orig
			tinsert(trace.restores, function() lp:SetScript("OnUpdate", restore_lp) end)
			tinsert(found, "locpanel")
		end
	end

	-- Instrument SMB:GrabMinimapButtons (6s timer, O(n) table scan)
	local smb = GetSMBModule()
	if smb and smb.GrabMinimapButtons then
		local orig = smb.GrabMinimapButtons
		smb.GrabMinimapButtons = TraceWrap("SMB:GrabMinimapButtons", orig, trace.threshold)
		tinsert(trace.restores, function() smb.GrabMinimapButtons = orig end)
		tinsert(found, "GrabMinimapButtons")
	end

	if #found == 0 then
		self:Print("|cffff4444[trace]|r No instrumentable functions found. Frames may not be initialised yet.")
		trace.active = false
		return
	end

	self:Print(format(
		"|cff00ff00[trace]|r Function timer ON (threshold %d ms).  Tracing: %s.  Use /kuidbg trace stop.",
		trace.threshold, table_concat(found, ", ")
	))
end

function KUI:TraceStop()
	if not trace.active then
		self:Print("|cffff8800[trace]|r not running")
		return
	end
	for _, restore in ipairs(trace.restores) do
		restore()
	end
	trace.restores = {}
	trace.active   = false

	local n = #trace.results
	if n == 0 then
		self:Print(format(
			"|cff00ff00[trace]|r No KlixUI calls exceeded %d ms.",
			trace.threshold
		))
		self:Print("If spikes persist, another addon is the cause. Use /kuidbg scriptprofile + /reload.")
		return
	end

	local totals = {}
	for _, r in ipairs(trace.results) do
		local d = totals[r.label]
		if not d then
			d = { count = 0, total = 0, max = 0 }
			totals[r.label] = d
		end
		d.count = d.count + 1
		d.total = d.total + r.ms
		if r.ms > d.max then d.max = r.ms end
	end

	local lines = {
		format("=== KlixUI Trace Report === (%d slow calls, threshold %d ms)", n, trace.threshold),
		"",
	}
	for label, d in pairs(totals) do
		tinsert(lines, format(
			"%-42s  calls=%-4d  avg=%5.1f ms  max=%5.1f ms",
			label, d.count, d.total / d.count, d.max
		))
	end
	tinsert(lines, "")
	tinsert(lines, "If KlixUI functions are fast here but perf still shows spikes,")
	tinsert(lines, "another addon is responsible. Use /kuidbg scriptprofile + /reload.")
	self:ShowDebugOutput("KlixUI Trace Report", table_concat(lines, "\n"))
end

-- ============================================================
-- Script profiling toggle
-- Usage: /kuidbg scriptprofile
-- ============================================================
function KUI:ToggleScriptProfile()
	local current = GetCVar and GetCVar("scriptProfile")
	if current == "1" then
		SetCVar("scriptProfile", "0")
		self:Print("|cffff8800[perf]|r Script profiling DISABLED. /reload to apply.")
	else
		SetCVar("scriptProfile", "1")
		self:Print("|cff00ff00[perf]|r Script profiling ENABLED. /reload to apply.")
		self:Print("After reload: hover the |cffffff00System (KUI)|r datatext to see per-addon CPU usage.")
	end
end

-- ============================================================
-- Performance spike detector
-- Usage: /kuidbg perf [threshold_ms]   start (default 12ms)
--        /kuidbg perf stop             show report
-- ============================================================
local perf = {
	frame     = nil,
	running   = false,
	threshold = 12,
	prevTime  = nil,
	spikes    = {},
	startTime = nil,
}

local function PerfOnUpdate(self)
	local now = GetTime()
	if not perf.prevTime then
		perf.prevTime = now
		return
	end
	local frameMs = (now - perf.prevTime) * 1000
	perf.prevTime = now

	if frameMs >= perf.threshold then
		local spike = { time = now, ms = frameMs }
		tinsert(perf.spikes, spike)
		-- print first 30 spikes so the user can see them in real-time
		if #perf.spikes <= 30 then
			KUI:Print(format(
				"|cffff4444[SPIKE]|r t=+%.1fs  frame=|cffff8800%.1f|r ms  (~%d fps)",
				now - perf.startTime,
				frameMs,
				math.floor(1000 / frameMs + 0.5)
			))
		end
	end
end

function KUI:PerfStart(threshold)
	if perf.running then
		self:Print("|cffff8800[perf]|r already running – use /kuidbg perf stop first")
		return
	end
	perf.threshold = threshold or 12
	perf.spikes    = {}
	perf.prevTime  = nil
	perf.startTime = GetTime()
	perf.running   = true

	if not perf.frame then
		perf.frame = CreateFrame("Frame")
	end
	perf.frame:SetScript("OnUpdate", PerfOnUpdate)

	self:Print(format(
		"|cff00ff00[perf]|r Frame-spike monitor ON  (threshold |cffff8800%d|r ms = %d fps).  "
		.. "Run |cffffff00/kuidbg perf stop|r to see the report.",
		perf.threshold, math.floor(1000 / perf.threshold + 0.5)
	))
end

function KUI:PerfStop()
	if not perf.running then
		self:Print("|cffff8800[perf]|r not running")
		return
	end
	perf.running = false
	perf.frame:SetScript("OnUpdate", nil)

	local n = #perf.spikes
	if n == 0 then
		self:Print("|cff00ff00[perf]|r No spikes detected above " .. perf.threshold .. " ms.")
		return
	end

	-- calculate intervals between spikes
	local intervals = {}
	for i = 2, n do
		tinsert(intervals, perf.spikes[i].time - perf.spikes[i-1].time)
	end

	local sumInt, minInt, maxInt = 0, math.huge, 0
	for _, v in ipairs(intervals) do
		sumInt = sumInt + v
		if v < minInt then minInt = v end
		if v > maxInt then maxInt = v end
	end
	local avgInt = n > 1 and (sumInt / #intervals) or 0

	local sumMs, maxMs = 0, 0
	for _, s in ipairs(perf.spikes) do
		sumMs = sumMs + s.ms
		if s.ms > maxMs then maxMs = s.ms end
	end

	local lines = {
		format("=== KlixUI Perf Report ===  (%d spikes, threshold %d ms)", n, perf.threshold),
		format("Spike frame time:   avg=%.1f ms   max=%.1f ms", sumMs / n, maxMs),
	}
	if n > 1 then
		tinsert(lines, format(
			"Interval between spikes:  avg=%.1f s   min=%.1f s   max=%.1f s",
			avgInt, minInt, maxInt
		))
		tinsert(lines, "")
		tinsert(lines, "Hint: if avg interval ≈ 10 s → system datatext (UpdateMemory)")
		tinsert(lines, "      if avg interval ≈  6 s → maps/minimapbuttons (GrabMinimapButtons)")
		tinsert(lines, "      if avg interval ≈  5 s → microBar UpdateFriends/UpdateGuild")
		tinsert(lines, "      if avg interval ≈ 15 s → titles datatext (UpdateTitles)")
		tinsert(lines, "      if avg interval < 2 s   → likely another addon (ElvUI/WeakAuras/AllTheThings/Zygor)")
		tinsert(lines, "")
		tinsert(lines, "Next steps when interval is short or hints don't match:")
		tinsert(lines, "  /kuidbg trace        – time KlixUI locpanel + GrabMinimapButtons (no reload)")
		tinsert(lines, "  /kuidbg scriptprofile – toggle per-addon CPU tracking, then /reload")
		tinsert(lines, "  After reload: hover the System (KUI) datatext for per-addon CPU.")
	end

	self:ShowDebugOutput("KlixUI Perf Report", table_concat(lines, "\n"))
end

function KUI:DebugCommand(msg)
	msg = strtrim(msg or "")

	local command, rest = match(msg, "^(%S+)%s*(.-)$")
	command = lower(command or "")
	rest = rest or ""

	if command == "" or command == "help" then
		self:ShowDebugOutput("KlixUI Debugger Help", table_concat({
			"/kuidbg help",
			"",
			"--- Performance ---",
			"/kuidbg perf [ms]       – frame-spike monitor (default 12 ms)",
			"/kuidbg perf stop       – stop and show report",
			"/kuidbg trace [ms]      – time KlixUI functions: locpanel, GrabMinimapButtons (default 5 ms)",
			"/kuidbg trace stop      – stop and show per-function report",
			"/kuidbg scriptprofile   – toggle per-addon CPU profiling (requires /reload)",
			"",
			"--- Debugging ---",
			"/kuidbg minimap",
			"/kuidbg button <FrameName or Token>",
			"/kuidbg frame <GlobalFrameName>",
			"/kuidbg taint",
			"",
			"--- Workflow ---",
			"1. /kuidbg perf → run 60s → /kuidbg perf stop",
			"2. If interval < 2s: /kuidbg trace → run 60s → /kuidbg trace stop",
			"3. If trace shows nothing slow: /kuidbg scriptprofile + /reload to find the addon",
		}, "\n"))
		return
	elseif command == "perf" then
		if lower(rest) == "stop" then
			self:PerfStop()
		else
			self:PerfStart(tonumber(rest))
		end
		return
	elseif command == "trace" then
		if lower(rest) == "stop" then
			self:TraceStop()
		else
			self:TraceStart(tonumber(rest))
		end
		return
	elseif command == "scriptprofile" then
		self:ToggleScriptProfile()
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
