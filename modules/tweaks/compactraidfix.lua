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
-- Fix B: wrap CompactUnitFrame_UpdateVisible to bail early for CompactRaidFrame* frames.
--        The wrapper is installed once (guard flag) and preserves the original for any
--        other compact frame types ElvUI may legitimately use.
-- Fix C: RegisterStateDriver("hide") on container/manager frames as a secure fallback.

local FRAMES_TO_FIX = { "CompactRaidFrameContainer", "CompactRaidFrameManager" }

local unitFrameOverridden = false

local function OverrideFunctions()
	if CompactRaidFrameManager_UpdateShown then
		CompactRaidFrameManager_UpdateShown = function() end
	end
	if CompactRaidFrameManager_UpdateContainerVisibility then
		CompactRaidFrameManager_UpdateContainerVisibility = function() end
	end
	if not unitFrameOverridden and CompactUnitFrame_UpdateVisible then
		local orig = CompactUnitFrame_UpdateVisible
		CompactUnitFrame_UpdateVisible = function(frame)
			local name = frame and frame.GetName and frame:GetName()
			if name and name:match("^CompactRaidFrame%d") then return end
			return orig(frame)
		end
		unitFrameOverridden = true
	end
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
end

OverrideFunctions()

local f = T.CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("PLAYER_REGEN_ENABLED")
f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", function(self, event, arg1)
	if event == "ADDON_LOADED" and arg1 == "Blizzard_CompactRaidFrames" then
		OverrideFunctions()
	else
		ApplyFix()
	end
end)
