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
	AddLine(lines, "MouseEnabled: %s", BoolText(frame and frame.IsMouseEnabled and frame:IsMouseEnabled()))
	AddLine(lines, "FrameStrata: %s", tostring(frame and frame.GetFrameStrata and frame:GetFrameStrata() or "nil"))
	AddLine(lines, "FrameLevel: %s", tostring(frame and frame.GetFrameLevel and frame:GetFrameLevel() or "nil"))
	AddLine(lines, "Alpha: %s", tostring(frame and frame.GetAlpha and frame:GetAlpha() or "nil"))
	AddLine(lines, "Size: %s x %s", tostring(frame and frame.GetWidth and frame:GetWidth() or "nil"), tostring(frame and frame.GetHeight and frame:GetHeight() or "nil"))
	if frame and frame.GetAttribute then
		AddLine(lines, "attr type: %s", tostring(frame:GetAttribute("type")))
		AddLine(lines, "attr item: %s", tostring(frame:GetAttribute("item")))
		AddLine(lines, "attr macrotext: %s", tostring(frame:GetAttribute("macrotext")))
	end
	if frame and frame.itemID ~= nil then
		AddLine(lines, "itemID: %s | itemName: %s | slotID: %s", tostring(frame.itemID), tostring(frame.itemName), tostring(frame.slotID))
	end
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
-- Precision timing: debugprofilestop() delta is sub-ms and monotonic.
-- Taking before/after delta avoids the global-reset side-effect of
-- debugprofilestart() and works correctly even with nested calls.
-- ============================================================
local _dpStop = debugprofilestop
local function PreciseMs()
	return _dpStop and _dpStop() or (GetTime() * 1000)
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
	ring      = {},    -- rolling window for perf+trace attribution
	ringN     = 20,
	ringIdx   = 0,
}

local function TraceRecord(label, ms)
	trace.ringIdx = (trace.ringIdx % trace.ringN) + 1
	trace.ring[trace.ringIdx] = { label = label, ms = ms, t = GetTime() }
	tinsert(trace.results, { label = label, ms = ms })
	local n = #trace.results
	if n <= 30 then
		KUI:Print(format("|cff8080ff[TRACE]|r %s = |cffff8800%.2f|r ms", label, ms))
	elseif n == 31 then
		KUI:Print("|cff8080ff[TRACE]|r (too many hits – further prints suppressed; /kuidbg trace stop for report)")
	end
end

local function TraceWrap(label, fn, threshold)
	return function(self, ...)
		local t0 = PreciseMs()
		fn(self, ...)
		local ms = PreciseMs() - t0
		if ms >= threshold then TraceRecord(label, ms) end
	end
end

local function TraceWrapEvent(label, fn, threshold)
	return function(self, event, ...)
		local t0 = PreciseMs()
		fn(self, event, ...)
		local ms = PreciseMs() - t0
		if ms >= threshold then
			TraceRecord(label .. "[" .. tostring(event) .. "]", ms)
		end
	end
end

local function TryWrapScript(frame, scriptType, label, threshold, restores, found)
	if not frame or not frame.GetScript then return false end
	local orig = frame:GetScript(scriptType)
	if not orig then return false end
	local wrapped = (scriptType == "OnEvent")
		and TraceWrapEvent(label, orig, threshold)
		or  TraceWrap(label, orig, threshold)
	frame:SetScript(scriptType, wrapped)
	tinsert(restores, function()
		if frame and frame.SetScript then frame:SetScript(scriptType, orig) end
	end)
	tinsert(found, label)
	return true
end

local function TryWrapMethod(obj, methodName, label, threshold, restores, found)
	if not obj or type(obj[methodName]) ~= "function" then return false end
	local orig = obj[methodName]
	obj[methodName] = TraceWrap(label, orig, threshold)
	tinsert(restores, function() obj[methodName] = orig end)
	tinsert(found, label)
	return true
end

-- Scan _G for any frame whose global name starts with KUI_ or KlixUI and
-- wrap its OnUpdate/OnEvent scripts.  One-time cost at trace start only.
local function AutoScanGlobals(threshold, restores, found)
	for gName, obj in pairs(_G) do
		if type(gName) == "string"
		   and (gName:find("^KUI_") or gName:find("^KlixUI"))
		   and type(obj) == "table"
		   and obj.GetScript and obj.IsObjectType then
			local ok, isF = pcall(obj.IsObjectType, obj, "Frame")
			if ok and isF then
				TryWrapScript(obj, "OnUpdate", "OnUpdate:" .. gName, threshold, restores, found)
				TryWrapScript(obj, "OnEvent",  "OnEvent:"  .. gName, threshold, restores, found)
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
	trace.ring      = {}
	trace.ringIdx   = 0
	trace.active    = true

	local found = {}

	-- 1. Auto-scan all globally-named KUI_* / KlixUI* frames
	AutoScanGlobals(trace.threshold, trace.restores, found)

	-- 2. SMB module methods (not frame scripts, need manual wrapping)
	local smb = GetSMBModule()
	if smb then
		TryWrapMethod(smb, "GrabMinimapButtons", "SMB:GrabMinimapButtons", trace.threshold, trace.restores, found)
		TryWrapMethod(smb, "SyncConfiguredLists", "SMB:SyncConfiguredLists", trace.threshold, trace.restores, found)
	end

	-- 3. Known KlixUI module frame scripts (cooldowns, announcements, etc.)
	local moduleTargets = { "RaidCD", "EnemyCD", "DiminishCD", "PulseCD", "Announcer", "MicroBar", "RaidMarkers" }
	for _, mName in ipairs(moduleTargets) do
		local ok, mod = pcall(self.GetModule, self, mName)
		if ok and mod then
			local mFrame = rawget(mod, "frame") or rawget(mod, "Frame")
			if mFrame then
				TryWrapScript(mFrame, "OnUpdate", mName .. ":OnUpdate", trace.threshold, trace.restores, found)
				TryWrapScript(mFrame, "OnEvent",  mName .. ":OnEvent",  trace.threshold, trace.restores, found)
			end
		end
	end

	if #found == 0 then
		self:Print("|cffff4444[trace]|r No instrumentable targets found. Addon may not be fully initialized yet.")
		trace.active = false
		return
	end

	self:Print(format(
		"|cff00ff00[trace]|r Tracing |cffff8800%d|r targets (threshold |cffff8800%.1f|r ms).",
		#found, trace.threshold
	))
	self:Print("Targets: " .. table_concat(found, ", "))
	self:Print("Tip: also run |cffffff00/kuidbg perf|r – spikes will show which function was responsible.")
	self:Print("Use |cffffff00/kuidbg trace stop|r for the full report.")
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
			"|cff00ff00[trace]|r No KlixUI calls exceeded %.1f ms.",
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

	-- Sort by total time descending so the worst offender is at the top
	local sorted = {}
	for label, d in pairs(totals) do
		tinsert(sorted, { label = label, d = d })
	end
	table.sort(sorted, function(a, b) return a.d.total > b.d.total end)

	local lines = {
		format("=== KlixUI Trace Report === (%d slow calls, threshold %.1f ms)", n, trace.threshold),
		format("%-52s  %5s  %8s  %8s", "Function", "Calls", "Avg ms", "Max ms"),
		string.rep("-", 80),
	}
	for _, entry in ipairs(sorted) do
		local d = entry.d
		tinsert(lines, format(
			"%-52s  %5d  %8.2f  %8.2f",
			entry.label, d.count, d.total / d.count, d.max
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
	local current = T.GetCVar("scriptProfile")
	if current == "1" then
		T.SetCVar("scriptProfile", "0")
		self:Print("|cffff8800[perf]|r Script profiling DISABLED. /reload to apply.")
	else
		T.SetCVar("scriptProfile", "1")
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
		local spike = { time = now, ms = frameMs, attrib = nil }

		-- If trace is also running, attach any recent trace hits as attribution.
		-- The ring buffer holds the last ~20 calls within a 1s window.
		if trace.active then
			local parts = {}
			for i = 1, trace.ringN do
				local r = trace.ring[i]
				if r and (now - r.t) <= 1.0 then
					tinsert(parts, format("%s=%.1fms", r.label, r.ms))
				end
			end
			if #parts > 0 then
				spike.attrib = table_concat(parts, "  ")
			end
		end

		tinsert(perf.spikes, spike)
		if #perf.spikes <= 30 then
			local line = format(
				"|cffff4444[SPIKE]|r t=+%.1fs  frame=|cffff8800%.1f|r ms  (~%d fps)",
				now - perf.startTime, frameMs, math.floor(1000 / frameMs + 0.5)
			)
			if spike.attrib then
				line = line .. "\n         |cff8080ff→ " .. spike.attrib .. "|r"
			end
			KUI:Print(line)
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
		tinsert(lines, "      if avg interval ≈ 15 s → titles datatext (UpdateTitles)")
		tinsert(lines, "      if avg interval < 2 s   → likely another addon (ElvUI/WeakAuras/AllTheThings/Zygor)")
		tinsert(lines, "")

		-- Show attribution lines collected during concurrent trace
		local attributed = {}
		for _, s in ipairs(perf.spikes) do
			if s.attrib then
				tinsert(attributed, format("  t=+%.1fs  %.1fms  → %s", s.time - perf.startTime, s.ms, s.attrib))
			end
		end
		if #attributed > 0 then
			tinsert(lines, format("Attributed spikes (%d/%d had trace data):", #attributed, n))
			for _, line in ipairs(attributed) do
				tinsert(lines, line)
			end
			tinsert(lines, "")
		end

		tinsert(lines, "Next steps:")
		tinsert(lines, "  /kuidbg trace        – auto-instrument KlixUI frames+events (no reload)")
		tinsert(lines, "  /kuidbg scriptprofile – toggle per-addon CPU tracking, then /reload")
		tinsert(lines, "  After reload: hover the System (KUI) datatext for per-addon CPU.")
	end

	self:ShowDebugOutput("KlixUI Perf Report", table_concat(lines, "\n"))
end

function KUI:DebugAutoButtons()
	local lines = {}
	local names = {"AutoQuestButton", "AutoSlotButton"}
	for _, prefix in ipairs(names) do
		AddLine(lines, "=== %s ===", prefix)
		for i = 1, 12 do
			local btn = _G[prefix .. i]
			if not btn then break end
			local alpha = btn.GetAlpha and btn:GetAlpha() or "?"
			local mouseOn = btn.IsMouseEnabled and BoolText(btn:IsMouseEnabled()) or "?"
			local shown = btn.IsShown and BoolText(btn:IsShown()) or "?"
			local forbidden = btn.IsForbidden and BoolText(btn:IsForbidden()) or "?"
			local attrType = btn.GetAttribute and tostring(btn:GetAttribute("type")) or "?"
			local attrBag  = btn.GetAttribute and tostring(btn:GetAttribute("bag"))  or "?"
			local attrSlot = btn.GetAttribute and tostring(btn:GetAttribute("slot")) or "?"
			local attrMacro = btn.GetAttribute and tostring(btn:GetAttribute("macrotext")) or "?"
			AddLine(lines, "[%d] shown=%s alpha=%s mouse=%s forbidden=%s", i, shown, tostring(alpha), mouseOn, forbidden)
			AddLine(lines, "    type=%s bag=%s slot=%s macro=%s", attrType, attrBag, attrSlot, attrMacro)
			AddLine(lines, "    itemID=%s itemName=%s slotID=%s", tostring(btn.itemID), tostring(btn.itemName), tostring(btn.slotID))
		end
	end
	AddLine(lines, "")
	AddLine(lines, "InCombatLockdown: %s", BoolText(InCombatLockdown()))

	-- Quest watch API state
	local gwf = _G.GetQuestIndexForWatch
	local C_QL = rawget(_G, "C_QuestLog")
	local gwf_c = C_QL and rawget(C_QL, "GetQuestIndexForWatch")
	local gnw   = _G.GetNumQuestWatches
	local gnw_c = C_QL and rawget(C_QL, "GetNumQuestWatches")
	AddLine(lines, "")
	AddLine(lines, "=== Quest Watch API ===")
	AddLine(lines, "GetQuestIndexForWatch: %s | C_QuestLog.GetQuestIndexForWatch: %s",
		BoolText(gwf ~= nil), BoolText(gwf_c ~= nil))
	AddLine(lines, "GetNumQuestWatches: %s | C_QuestLog.GetNumQuestWatches: %s",
		BoolText(gnw ~= nil), BoolText(gnw_c ~= nil))
	local watchCount = (gnw and gnw()) or (gnw_c and gnw_c()) or 0
	AddLine(lines, "WatchCount: %d", watchCount)
	for wi = 1, watchCount do
		local qli = (gwf and gwf(wi)) or (gwf_c and gwf_c(wi))
		local title
		if qli and _G.GetQuestLogTitle then
			title = (_G.GetQuestLogTitle(qli))
		end
		local link
		if qli and _G.GetQuestLogSpecialItemInfo then
			link = (_G.GetQuestLogSpecialItemInfo(qli))
		end
		AddLine(lines, "  watch[%d] → logIdx=%s title=%s specialItem=%s", wi,
			tostring(qli), tostring(title), tostring(link ~= nil and "yes" or "no"))
	end

	self:ShowDebugOutput("AutoButtons Debug", table_concat(lines, "\n"))
end

function KUI:DebugAutoButtonTest(args)
	if args == "close" or args == "hide" then
		if _G["KUI_ABTestButton"] then _G["KUI_ABTestButton"]:Hide() end
		if _G["KUI_ABBareButton"] then _G["KUI_ABBareButton"]:Hide() end
		self:Print("[abtest] Test buttons hidden.")
		return
	end

	-- /kuidbg abtest bare <itemID>  – completely bare button, zero addon scripts
	local bareMode = false
	local trimmed = args or ""
	if trimmed:sub(1, 5) == "bare " then
		bareMode = true
		trimmed = trimmed:sub(6)
	end

	local itemID = tonumber(trimmed)
	if not itemID then
		self:Print("Usage: /kuidbg abtest <itemID>  |  /kuidbg abtest bare <itemID>  |  /kuidbg abtest close")
		return
	end

	if bareMode then
		if InCombatLockdown() then self:Print("[abtest] Cannot modify in combat.") return end
		local itemName = T.GetItemInfo and T.GetItemInfo(itemID)
		local icon = T.GetItemIcon and T.GetItemIcon(itemID)
		local bare = _G["KUI_ABBareButton"]
		if not bare then
			bare = CreateFrame("Button", "KUI_ABBareButton", UIParent, "SecureActionButtonTemplate")
			bare:SetSize(48, 48)
			bare:SetFrameStrata("DIALOG")
			bare:SetFrameLevel(100)
			bare:EnableMouse(true)
			bare:RegisterForClicks("AnyUp")
			local t = bare:CreateTexture(nil, "ARTWORK")
			t:SetAllPoints()
			bare.tex = t
			-- WrapScript: call UseItemByName directly in secure Lua (bypasses type dispatch)
			bare:WrapScript(bare, "OnClick", [[
				local b = self:GetAttribute("bag")
				local s = self:GetAttribute("slot")
				if b ~= nil and s then
					if UseContainerItem then UseContainerItem(b, s) return false end
				end
				local nm = self:GetAttribute("item")
				if nm then
					if UseItemByName then UseItemByName(nm) return false end
					if RunMacroText then RunMacroText("/use "..nm) return false end
				end
			]])
		end
		local bag, slot = KUI:BagSearch(itemID)
		bare:ClearAllPoints()
		bare:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
		bare:SetAttribute("item", nil)
		bare:SetAttribute("macrotext", nil)
		if bag ~= nil and slot then
			bare:SetAttribute("bag", bag)
			bare:SetAttribute("slot", slot)
		else
			bare:SetAttribute("bag", nil)
			bare:SetAttribute("slot", nil)
			bare:SetAttribute("item", itemName or nil)
		end
		bare.tex:SetTexture(icon or "Interface\\Icons\\INV_Misc_QuestionMark")
		bare:Show()
		self:Print(format("[abtest] BARE+WrapScript | itemID=%d | name=%s | bag=%s | slot=%s — klick und check ob Item benutzt wird", itemID, tostring(itemName), tostring(bag), tostring(slot)))
		return
	end

	if InCombatLockdown() then
		self:Print("[abtest] Cannot modify in combat.")
		return
	end

	local btn = _G["KUI_ABTestButton"]
	if not btn then
		btn = CreateFrame("Button", "KUI_ABTestButton", UIParent, "SecureActionButtonTemplate")
		btn:SetSize(48, 48)
		btn:SetFrameStrata("DIALOG")
		btn:EnableMouse(true)
		btn:RegisterForClicks("AnyUp")
		if btn.CreateBackdrop then
			btn:CreateBackdrop("Default")
			if btn.backdrop then btn.backdrop:EnableMouse(false) end
		end
		btn.tex = btn:CreateTexture(nil, "ARTWORK")
		btn.tex:SetAllPoints()
		btn.label = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		btn.label:SetPoint("TOP", btn, "BOTTOM", 0, -2)
		btn:HookScript("OnMouseDown", function(self, b)
			print(string.format(
				"|cfff960d9[ABTest]|r MDOWN | btn=%s | type=%s | bag=%s | slot=%s | macro=%s | mouse=%s | combat=%s",
				tostring(b),
				tostring(self:GetAttribute("type")),
				tostring(self:GetAttribute("bag")),
				tostring(self:GetAttribute("slot")),
				tostring(self:GetAttribute("macrotext")),
				tostring(self:IsMouseEnabled()),
				tostring(InCombatLockdown())))
		end)
		btn:HookScript("OnMouseUp", function(self, b)
			print(string.format("|cfff960d9[ABTest]|r MUP | btn=%s", tostring(b)))
		end)
		btn:SetScript("PreClick", function(self, b)
			print(string.format(
				"|cfff960d9[ABTest]|r PRE | btn=%s | type=%s | bag=%s | slot=%s | macro=%s | combat=%s",
				tostring(b),
				tostring(self:GetAttribute("type")),
				tostring(self:GetAttribute("bag")),
				tostring(self:GetAttribute("slot")),
				tostring(self:GetAttribute("macrotext")),
				tostring(InCombatLockdown())))
		end)
		btn:SetScript("PostClick", function(self, b)
			print("|cfff960d9[ABTest]|r POST → secure action fired")
		end)
	end

	btn:ClearAllPoints()
	btn:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
	btn:SetFrameLevel(100)
	btn:SetAttribute("item", nil)
	btn:SetAttribute("macrotext", nil)
	btn:SetAttribute("bag", nil)
	btn:SetAttribute("slot", nil)

	local itemName = T.GetItemInfo and T.GetItemInfo(itemID)
	local icon = T.GetItemIcon and T.GetItemIcon(itemID)
	btn.tex:SetTexture(icon or "Interface\\Icons\\INV_Misc_QuestionMark")

	-- type="item" + item=name calls UseItemByName(name) directly.
	-- bag/slot approach was confirmed broken in MoP Classic 5.5.4.
	if itemName then
		btn:SetAttribute("type", "item")
		btn:SetAttribute("item", itemName)
		btn.label:SetText("type=item | " .. itemName)
		self:Print(format("[abtest] itemID=%d | name=%s → type=item item=name", itemID, itemName))
	else
		local macro = "/use item:" .. itemID
		btn:SetAttribute("type", "macro")
		btn:SetAttribute("macrotext", macro)
		btn.label:SetText(macro)
		self:Print(format("[abtest] itemID=%d | name not cached → macro=%s", itemID, macro))
	end
	btn:SetAlpha(1)
	btn:Show()

	self:Print("[abtest] MDOWN/MUP/PRE/POST erscheinen im Chat. /kuidbg abtest close zum Entfernen.")
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
			"/kuidbg trace [ms]      – auto-instrument KlixUI frames+events (default 5 ms)",
			"/kuidbg trace stop      – stop and show per-function timing report (sorted by total cost)",
			"/kuidbg scriptprofile   – toggle per-addon CPU profiling (requires /reload)",
			"",
			"  Combined workflow for spike attribution:",
			"    /kuidbg perf  →  /kuidbg trace  →  reproduce the issue",
			"    /kuidbg trace stop  →  /kuidbg perf stop",
			"  Each spike line will show which KlixUI function ran in that frame.",
			"",
			"--- Debugging ---",
			"/kuidbg minimap",
			"/kuidbg button <FrameName or Token>",
			"/kuidbg frame <GlobalFrameName>",
			"/kuidbg taint",
			"/kuidbg autobuttons      – dump AutoQuestButton/AutoSlotButton state",
		"/kuidbg abclick          – toggle click debugger (MDOWN/MUP/PRE/POST per click in chat)",
		"/kuidbg abtest <itemID>  – create standalone test button with /use item:ID",
		"/kuidbg abtest close     – hide test button",
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
	elseif command == "autobuttons" or command == "ab" then
		self:DebugAutoButtons()
		return
	elseif command == "abclick" then
		KUI.AutoButtonClickDebug = not KUI.AutoButtonClickDebug
		self:Print("AutoButton click debug: " .. (KUI.AutoButtonClickDebug and "|cff00ff00ON|r" or "|cffff0000OFF|r"))
		return
	elseif command == "abtest" then
		self:DebugAutoButtonTest(rest)
		return
	end

	self:Print("Unknown debug command. Use /kuidbg help")
end
