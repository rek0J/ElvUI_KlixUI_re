local KUI, T, E, L, V, P, G = unpack(select(2, ...))
local KS = KUI:GetModule('KuiSkins')
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local _G = _G
local pairs, select = pairs, select
--WoW API / Variables
local CreateFrame = CreateFrame
local C_QuestLog_GetNumQuestLogEntries = C_QuestLog.GetNumQuestLogEntries
local C_QuestLog_GetMaxNumQuestsCanAccept = C_QuestLog.GetMaxNumQuestsCanAccept
-- GLOBALS:

local r, g, b = T.unpack(E["media"].rgbvaluecolor)

local function styleWorldmap()
	if E.Mists then return end
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.worldmap ~= true or E.private.KlixUI.skins.blizzard.worldmap ~= true then return end
	if not _G.WorldMapFrame or (_G.WorldMapFrame.IsForbidden and _G.WorldMapFrame:IsForbidden()) then return end
	if not _G.QuestScrollFrame or (_G.QuestScrollFrame.IsForbidden and _G.QuestScrollFrame:IsForbidden()) then return end
	if not _G.WorldMapFrame.backdrop then return end

	_G.WorldMapFrame.backdrop:Styling()

	local frame = CreateFrame("Frame", nil,  _G.QuestScrollFrame)
	frame:Size(230, 20)
	frame:SetPoint("TOP", 0, 21)
	KS:CreateBD(frame, .25)

	frame.text = frame:CreateFontString(nil, "ARTWORK")
	frame.text:FontTemplate()
	frame.text:SetTextColor(r, g, b)
	frame.text:SetAllPoints()

	frame.text:SetText(select(2, C_QuestLog_GetNumQuestLogEntries()).."/"..C_QuestLog_GetMaxNumQuestsCanAccept().." "..L["Quests"])

	frame:SetScript("OnEvent", function(self, event)
		frame.text:SetText(select(2, C_QuestLog_GetNumQuestLogEntries()).."/"..C_QuestLog_GetMaxNumQuestsCanAccept().." "..L["Quests"])
	end)

	if _G.QuestScrollFrame.DetailFrame.backdrop then
		_G.QuestScrollFrame.DetailFrame.backdrop:Hide()
	end

	if _G.QuestSessionManager then
		hooksecurefunc(_G.QuestSessionManager, "NotifyDialogShow", function(_, dialog)
			if not dialog or dialog.IsStyled then return end
			if dialog.backdrop then
				dialog.backdrop:Styling()
			end
			dialog.isStyled = true
		end)
	end
end

S:AddCallback("KuiSkinWorldMap", styleWorldmap)
