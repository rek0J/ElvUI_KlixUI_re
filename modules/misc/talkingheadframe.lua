local KUI, T, E, L, V, P, G = unpack(select(2, ...))
local THF = KUI:NewModule("TalkingHeadFrame", "AceEvent-3.0", "AceHook-3.0")

local TalkingHead_LoadUI = T.TalkingHead_LoadUI or _G.TalkingHead_LoadUI
local TalkingHead_PlayCurrent = _G.TalkingHeadFrame_PlayCurrent
local TalkingHead_CloseImmediately = _G.TalkingHeadFrame_CloseImmediately

function THF:HideTalkingHead()
	if E.db.KlixUI.misc.talkingHead and TalkingHead_PlayCurrent and TalkingHead_CloseImmediately then
		hooksecurefunc("TalkingHeadFrame_PlayCurrent", function()
			-- Query subzone text when the talkinghead plays
			zoneName = T.GetSubZoneText()
			mainZoneName = T.GetZoneText()
			-- If we are not doing withered training or islands expeditions, suppress the talkinghead
			if zoneName ~= "Temple of Fal'adora" and
				zoneName ~= "Falanaar Tunnels" and
				zoneName ~= "Shattered Locus" or 
				zoneName ~= "Molten Cay" or
				zoneName ~= "Un'gol Ruins" or
				zoneName ~= "The Rotting Mire" or
				zoneName ~= "Whispering Reef" or
				zoneName ~= "Verdant Wilds" or
				zoneName ~= "The Dread Chain" or
				zoneName ~= "Skittering Hollow" or
				zoneName ~= "Havenswood" or
				zoneName ~= "Jorundall" or
				zoneName ~= "Crestfall" or
				zoneName ~= "Snowblossom Village" or 
				mainZoneName ~= "Ashran" or
				mainZoneName ~= "Nazjatar" then
						
				TalkingHead_CloseImmediately()
				KUI:Print("TalkingHeadFrame closed.")
			end
		end)
	end
end

function THF:Initialize()
	if not E.Retail and not TalkingHead_LoadUI and not TalkingHead_PlayCurrent then
		return
	end

    if T.IsAddOnLoaded("Blizzard_TalkingHeadUI") then
		THF:HideTalkingHead()
	else -- We want the mover to be available immediately, so we load it ourselves
		if not TalkingHead_LoadUI then return end
		local f = T.CreateFrame("Frame")
		f:RegisterEvent("PLAYER_ENTERING_WORLD")
		f:SetScript("OnEvent", function(self, event)
			self:UnregisterEvent(event)
			TalkingHead_LoadUI()
			THF:HideTalkingHead()
		end)
	end
end

KUI:RegisterModule(THF:GetName())
