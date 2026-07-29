local KUI, T, E, L, V, P, G = unpack(select(2, ...))

-- Fix: ADDON_ACTION_BLOCKED – CompactRaidFrame
--
-- Root cause: HereBeDragons (KlixUI/TomTom) fires callbacks in a tainted context →
-- TomTom calls SetZoom → CVar change → two separate paths both blocked:
--
-- Path 1 (9×): CompactRaidFrameManager_UpdateContainerVisibility → CompactRaidFrameManager:Show()
-- Path 2 (1×): CompactUnitFrame OnEvent → CompactUnitFrame_UpdateAll → CompactUnitFrame_UpdateVisible
--              → CompactRaidFrame1:Show()
--
-- Fix A: replace CompactRaidFrameManager_UpdateShown and _UpdateContainerVisibility with no-ops.
-- Fix B: UnregisterAllEvents on CompactRaidFrame1..N so the OnEvent at CUF.lua:202 never
--        fires for these frames → UpdateAll/UpdateVisible/Show() chain never reached.
--        Avoids global function overrides that taint NamePlate calls (prior approach).
-- Fix C: RegisterStateDriver("hide") on container/manager frames as a secure fallback.

local FRAMES_TO_FIX = { "CompactRaidFrameContainer", "CompactRaidFrameManager" }

local function OverrideFunctions()
	if CompactRaidFrameManager_UpdateShown then
		CompactRaidFrameManager_UpdateShown = function() end
	end
	if CompactRaidFrameManager_UpdateContainerVisibility then
		CompactRaidFrameManager_UpdateContainerVisibility = function() end
	end
end

local function UnregisterRaidFrameEvents()
	for i = 1, 40 do
		local frame = _G["CompactRaidFrame" .. i]
		if frame then
			frame:UnregisterAllEvents()
		end
	end
end

-- Fix D: Blizzard's CompactRaidFrameContainerMixin:GetUnitFrame creates new CompactRaidFrame<N>
-- buttons on demand (still on GROUP_ROSTER_UPDATE) and immediately calls
-- CompactUnitFrame_SetUpdateAllEvent(frame, "GROUP_ROSTER_UPDATE") on them - this can happen
-- *after* the periodic sweep above already ran (race on the same event), leaving a freshly
-- created frame (e.g. CompactRaidFrame6 when the raid grows) still wired up. Hooking the exact
-- function Blizzard uses to wire that event closes the race regardless of timing.
if type(_G.CompactUnitFrame_SetUpdateAllEvent) == "function" then
	hooksecurefunc("CompactUnitFrame_SetUpdateAllEvent", function(frame)
		if frame and frame.GetName and frame.UnregisterAllEvents then
			local name = frame:GetName()
			if name and name:match("^CompactRaidFrame%d") then
				frame:UnregisterAllEvents()
			end
		end
	end)
end

local function ApplyFix()
	if T.InCombatLockdown() then return end
	for _, name in ipairs(FRAMES_TO_FIX) do
		local frame = _G[name]
		if frame then
			frame:SetScript("OnShow", nil)
			frame:SetScript("OnHide", nil)
			frame:Hide()
			RegisterStateDriver(frame, "visibility", "hide")
		end
	end
	UnregisterRaidFrameEvents()
end

OverrideFunctions()

local f = T.CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("PLAYER_REGEN_ENABLED")
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("GROUP_ROSTER_UPDATE")
f:SetScript("OnEvent", function(self, event, arg1)
	if event == "ADDON_LOADED" and arg1 == "Blizzard_CompactRaidFrames" then
		OverrideFunctions()
	else
		ApplyFix()
	end
end)
