local KUI, T, E, L, V, P, G = unpack(select(2, ...))

-- Fix: ADDON_ACTION_BLOCKED – CompactRaidFrame
--
-- Root cause: HereBeDragons (KlixUI/TomTom) fires callbacks in a tainted context →
-- TomTom calls SetZoom → CVar change → CompactRaidFrameManager_UpdateContainerVisibility
-- → Show() on a SecureHandlerShowHideTemplate frame → ADDON_ACTION_BLOCKED.
--
-- RegisterStateDriver alone does NOT suppress the error. It overrides visibility
-- via the secure attribute system AFTER Show() is attempted, but the blocked call
-- fires at the call site. The fix must prevent Show() from being called at all.
--
-- Fix: replace the Blizzard update functions with no-ops. These frames are managed
-- by ElvUI's raid-frame system and must never be shown. RegisterStateDriver("hide")
-- is kept as a secure fallback for any Show() call from other code paths.

local FRAMES_TO_FIX = { "CompactRaidFrameContainer", "CompactRaidFrameManager" }

local function OverrideFunctions()
	if CompactRaidFrameManager_UpdateShown then
		CompactRaidFrameManager_UpdateShown = function() end
	end
	if CompactRaidFrameManager_UpdateContainerVisibility then
		CompactRaidFrameManager_UpdateContainerVisibility = function() end
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
