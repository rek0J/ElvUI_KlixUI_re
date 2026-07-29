local KUI, T, E, L, V, P, G = unpack(select(2, ...))

local f = T.CreateFrame("frame")
local moviePlayed = false

_G.CinematicFrame:HookScript("OnShow", function(self, ...)
	if T.IsModifierKeyDown() or E.global.KlixUI.cinematic.kill == false or T.IsAddOnLoaded("CinematicCanceler") then return end
	KUI:Print("Cinematic Canceled.")
	T.CinematicFrame_CancelCinematic()
end)

local omfpf = _G["MovieFrame_PlayMovie"]
_G["MovieFrame_PlayMovie"] = function(...)
	if T.IsModifierKeyDown() or E.global.KlixUI.cinematic.kill == false or T.IsAddOnLoaded("CinematicCanceler") then return omfpf(...) end
	KUI:Print("Movie Canceled.")
	if T.GameMovieFinished then T.GameMovieFinished() end
	return true
end


if type(_G.GameMovieFinished) == "function" then
	hooksecurefunc(_G, "GameMovieFinished", function() if moviePlayed then T.SetCVar("Sound_EnableAllSound", 0) end moviePlayed = false end)
end

local function eventhandler(self, event)
if E.global.KlixUI.cinematic.kill then return end

	if not T.GetCVarBool("Sound_EnableAllSound") then
		if (event == "CINEMATIC_START") and E.global.KlixUI.cinematic.enableSound then
			T.SetCVar("Sound_EnableAllSound", 1)
		elseif (event == "PLAY_MOVIE") and E.global.KlixUI.cinematic.enableSound then
			moviePlayed = true
			T.SetCVar("Sound_EnableAllSound", 1)
		elseif(event == "CINEMATIC_STOP") and E.global.KlixUI.cinematic.enableSound then
			T.SetCVar("Sound_EnableAllSound", 0)
		elseif(event == "QUEST_COMPLETE") and E.global.KlixUI.cinematic.enableSound or E.global.KlixUI.cinematic.talkingheadSound then
			T.SetCVar("Sound_EnableAllSound", 0)
		elseif(event == "TALKINGHEAD_CLOSE") and E.global.KlixUI.cinematic.talkingheadSound and not E.db.KlixUI.misc.talkingHead then
			T.SetCVar("Sound_EnableAllSound", 0)
		elseif (event == "TALKINGHEAD_REQUESTED") and E.global.KlixUI.cinematic.talkingheadSound and not E.db.KlixUI.misc.talkingHead then
			if self:IsEventRegistered("TALKINGHEAD_REQUESTED") then
				T.SetCVar("Sound_EnableAllSound", 1)
			end
		end
	end
end

f:RegisterEvent("CINEMATIC_START")
f:RegisterEvent("CINEMATIC_STOP")
f:RegisterEvent("PLAY_MOVIE")
f:RegisterEvent("QUEST_COMPLETE")
if _G.TALKINGHEAD_REQUESTED or pcall(function() return f:RegisterEvent("TALKINGHEAD_REQUESTED") end) then
	f:RegisterEvent("TALKINGHEAD_REQUESTED")
end
if _G.TALKINGHEAD_CLOSE or pcall(function() return f:RegisterEvent("TALKINGHEAD_CLOSE") end) then
	f:RegisterEvent("TALKINGHEAD_CLOSE")
end
f:SetScript("OnEvent", eventhandler)