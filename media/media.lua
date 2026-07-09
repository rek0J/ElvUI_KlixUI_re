local KUI, T, E, L, V, P, G = unpack(select(2, ...))
local M = KUI:NewModule("KuiMedia", "AceHook-3.0")

local FadingFrame_Show = FadingFrame_Show

M.Zones = L["KUI_MEDIA_ZONES"]
M.PvPInfo = L["KUI_MEDIA_PVP"]
M.Subzones = L["KUI_MEDIA_SUBZONES"]
M.PVPArena = L["KUI_MEDIA_PVPARENA"]

local Colors = {
	[1] = {0.41, 0.8, 0.94}, -- sanctuary
	[2] = {1.0, 0.1, 0.1}, -- hostile
	[3] = {0.1, 1.0, 0.1}, --friendly
	[4] = {1.0, 0.7, 0}, --contested
	[5] = {1.0, 0.9294, 0.7607}, --white
}

local function ZoneTextPos()
	if ( _G["PVPInfoTextString"]:GetText() == "" ) then
		_G["SubZoneTextString"]:SetPoint("TOP", "ZoneTextString", "BOTTOM", 0, -E.db.KlixUI.media.fonts.subzone.offset);
	else
		_G["SubZoneTextString"]:SetPoint("TOP", "PVPInfoTextString", "BOTTOM", 0, -E.db.KlixUI.media.fonts.subzone.offset);
	end
end

local function MakeFont(obj, font, size, style, r, g, b, sr, sg, sb, sox, soy)
	if obj and font and size then
		style = type(style) == "string" and style ~= "NONE" and style ~= "" and style or ""
		obj:SetFont(font, size, style)
		if sr and sg and sb then obj:SetShadowColor(sr, sg, sb) end
		if sox and soy then obj:SetShadowOffset(sox, soy) end
		if r and g and b then obj:SetTextColor(r, g, b)
		elseif r then obj:SetAlpha(r) end
	end
end

local function FontFlags(flags)
	return type(flags) == "string" and flags ~= "NONE" and flags ~= "" and flags or ""
end

local function SetBlizzFont(obj, font, size, flags)
	if obj and font and size then
		obj:SetFont(font, size, flags or "")
	end
end

function M:SetBlizzFonts()
	if E.private.general.replaceBlizzFonts then
		local db = E.db.KlixUI.media.fonts
		if _G["ZoneTextString"] then SetBlizzFont(_G["ZoneTextString"], E.LSM:Fetch('font', db.zone.font), db.zone.size, FontFlags(db.zone.outline)) end -- Main zone name
		if _G["PVPInfoTextString"] then SetBlizzFont(_G["PVPInfoTextString"], E.LSM:Fetch('font', db.pvp.font), db.pvp.size, FontFlags(db.pvp.outline)) end -- PvP status for main zone
		if _G["PVPArenaTextString"] then SetBlizzFont(_G["PVPArenaTextString"], E.LSM:Fetch('font', db.pvp.font), db.pvp.size, FontFlags(db.pvp.outline)) end -- PvP status for subzone
		if _G["SubZoneTextString"] then SetBlizzFont(_G["SubZoneTextString"], E.LSM:Fetch('font', db.subzone.font), db.subzone.size, FontFlags(db.subzone.outline)) end -- Subzone name

		if _G["SendMailBodyEditBox"] then
			SetBlizzFont(_G["SendMailBodyEditBox"], E.LSM:Fetch('font', db.mail.font), db.mail.size, FontFlags(db.mail.outline))
		end -- MoP Classic: only set font if frame exists
		if _G["OpenMailBodyText"] and not _G["OpenMailBodyText"]:IsObjectType("SimpleHTML") then
			SetBlizzFont(_G["OpenMailBodyText"], E.LSM:Fetch('font', db.mail.font), db.mail.size, FontFlags(db.mail.outline))
		end -- MoP Classic: only set font if frame exists
		if _G["QuestFont"] then SetBlizzFont(_G["QuestFont"], E.LSM:Fetch('font', db.gossip.font), db.gossip.size, FontFlags(db.gossip.outline)) end -- Font in Quest Log/Petitions
		-- if _G["QuestFont_Large"] then _G["QuestFont_Large"]:SetFont(E.LSM:Fetch('font', db.questFontLarge.font), db.questFontLarge.size, db.questFontLarge.outline) end -- No idea what that is for
		if _G["QuestFont_Super_Huge"] then SetBlizzFont(_G["QuestFont_Super_Huge"], E.LSM:Fetch('font', db.questFontSuperHuge.font), db.questFontSuperHuge.size, FontFlags(db.questFontSuperHuge.outline)) end
		if _G["QuestFont_Enormous"] then SetBlizzFont(_G["QuestFont_Enormous"], E.LSM:Fetch('font', db.questFontSuperHuge.font), db.questFontSuperHuge.size, FontFlags(db.questFontSuperHuge.outline)) end
		if _G["NumberFont_Shadow_Med"] then SetBlizzFont(_G["NumberFont_Shadow_Med"], E.LSM:Fetch('font', db.editbox.font), db.editbox.size, FontFlags(db.editbox.outline)) end --Chat editbox
		--Objective Frame
		if _G["ObjectiveTrackerFrame"] and _G["ObjectiveTracker_Update"] and not _G["ObjectiveTrackerFrame"].KUIHookedFonts then
			hooksecurefunc("ObjectiveTracker_Update", function(reason, id)
				if _G["ObjectiveTrackerBlocksFrame"] and _G["ObjectiveTrackerBlocksFrame"].QuestHeader and _G["ObjectiveTrackerBlocksFrame"].QuestHeader.Text then
					SetBlizzFont(_G["ObjectiveTrackerBlocksFrame"].QuestHeader.Text, E.LSM:Fetch('font', E.db.KlixUI.media.fonts.objectiveHeader.font), E.db.KlixUI.media.fonts.objectiveHeader.size, FontFlags(E.db.KlixUI.media.fonts.objectiveHeader.outline))
				end
				if _G["ObjectiveTrackerBlocksFrame"] and _G["ObjectiveTrackerBlocksFrame"].AchievementHeader and _G["ObjectiveTrackerBlocksFrame"].AchievementHeader.Text then
					SetBlizzFont(_G["ObjectiveTrackerBlocksFrame"].AchievementHeader.Text, E.LSM:Fetch('font', E.db.KlixUI.media.fonts.objectiveHeader.font), E.db.KlixUI.media.fonts.objectiveHeader.size, FontFlags(E.db.KlixUI.media.fonts.objectiveHeader.outline))
				end
				if _G["ObjectiveTrackerBlocksFrame"] and _G["ObjectiveTrackerBlocksFrame"].ScenarioHeader and _G["ObjectiveTrackerBlocksFrame"].ScenarioHeader.Text then
					SetBlizzFont(_G["ObjectiveTrackerBlocksFrame"].ScenarioHeader.Text, E.LSM:Fetch('font', E.db.KlixUI.media.fonts.objectiveHeader.font), E.db.KlixUI.media.fonts.objectiveHeader.size, FontFlags(E.db.KlixUI.media.fonts.objectiveHeader.outline))
				end
				if _G["WORLD_QUEST_TRACKER_MODULE"] and _G["WORLD_QUEST_TRACKER_MODULE"].Header and _G["WORLD_QUEST_TRACKER_MODULE"].Header.Text then
					SetBlizzFont(_G["WORLD_QUEST_TRACKER_MODULE"].Header.Text, E.LSM:Fetch('font', E.db.KlixUI.media.fonts.objectiveHeader.font), E.db.KlixUI.media.fonts.objectiveHeader.size, FontFlags(E.db.KlixUI.media.fonts.objectiveHeader.outline))
				end
				if _G["BONUS_OBJECTIVE_TRACKER_MODULE"] and _G["BONUS_OBJECTIVE_TRACKER_MODULE"].Header and _G["BONUS_OBJECTIVE_TRACKER_MODULE"].Header.Text then
					SetBlizzFont(_G["BONUS_OBJECTIVE_TRACKER_MODULE"].Header.Text, E.LSM:Fetch('font', E.db.KlixUI.media.fonts.objectiveHeader.font), E.db.KlixUI.media.fonts.objectiveHeader.size, FontFlags(E.db.KlixUI.media.fonts.objectiveHeader.outline))
				end
			end)
			_G["ObjectiveTrackerFrame"].KUIHookedFonts = true
		end
		if _G["ObjectiveTrackerFrame"] and _G["ObjectiveTrackerFrame"].HeaderMenu and _G["ObjectiveTrackerFrame"].HeaderMenu.Title then
			SetBlizzFont(_G["ObjectiveTrackerFrame"].HeaderMenu.Title, E.LSM:Fetch('font', db.objectiveHeader.font), db.objectiveHeader.size, FontFlags(db.objectiveHeader.outline))
		end
		if _G["ObjectiveTrackerBlocksFrame"] and _G["ObjectiveTrackerBlocksFrame"].QuestHeader and _G["ObjectiveTrackerBlocksFrame"].QuestHeader.Text then
			SetBlizzFont(_G["ObjectiveTrackerBlocksFrame"].QuestHeader.Text, E.LSM:Fetch('font', db.objectiveHeader.font), db.objectiveHeader.size, FontFlags(db.objectiveHeader.outline))
		end
		if _G["ObjectiveTrackerBlocksFrame"] and _G["ObjectiveTrackerBlocksFrame"].AchievementHeader and _G["ObjectiveTrackerBlocksFrame"].AchievementHeader.Text then
			SetBlizzFont(_G["ObjectiveTrackerBlocksFrame"].AchievementHeader.Text, E.LSM:Fetch('font', db.objectiveHeader.font), db.objectiveHeader.size, FontFlags(db.objectiveHeader.outline))
		end
		if _G["ObjectiveTrackerBlocksFrame"] and _G["ObjectiveTrackerBlocksFrame"].ScenarioHeader and _G["ObjectiveTrackerBlocksFrame"].ScenarioHeader.Text then
			SetBlizzFont(_G["ObjectiveTrackerBlocksFrame"].ScenarioHeader.Text, E.LSM:Fetch('font', db.objectiveHeader.font), db.objectiveHeader.size, FontFlags(db.objectiveHeader.outline))
		end
		if _G["BONUS_OBJECTIVE_TRACKER_MODULE"] and _G["BONUS_OBJECTIVE_TRACKER_MODULE"].Header and _G["BONUS_OBJECTIVE_TRACKER_MODULE"].Header.Text then
			SetBlizzFont(_G["BONUS_OBJECTIVE_TRACKER_MODULE"].Header.Text, E.LSM:Fetch('font', db.objectiveHeader.font), db.objectiveHeader.size, FontFlags(db.objectiveHeader.outline))
		end
		if _G["WORLD_QUEST_TRACKER_MODULE"] and _G["WORLD_QUEST_TRACKER_MODULE"].Header and _G["WORLD_QUEST_TRACKER_MODULE"].Header.Text then
			SetBlizzFont(_G["WORLD_QUEST_TRACKER_MODULE"].Header.Text, E.LSM:Fetch('font', db.objectiveHeader.font), db.objectiveHeader.size, FontFlags(db.objectiveHeader.outline))
		end
		if _G["ObjectiveFont"] then MakeFont(_G["ObjectiveFont"], E.LSM:Fetch('font', db.objective.font), db.objective.size, db.objective.outline) end
		if M.BonusObjectiveBarText then SetBlizzFont(M.BonusObjectiveBarText, E.LSM:Fetch('font', db.objective.font), db.objective.size, FontFlags(db.objective.outline)) end
	end
end

function M:TextWidth()
	local db = E.db.KlixUI.media.fonts or E.db.KlixUI.media.fonts
	_G["ZoneTextString"]:SetWidth(db.zone.width)
	_G["PVPInfoTextString"]:SetWidth(db.pvp.width)
	_G["PVPArenaTextString"]:SetWidth(db.pvp.width)
	_G["SubZoneTextString"]:SetWidth(db.subzone.width)
end

function M:TextShow()
	local z, i, a, s, c = T.random(1, #M.Zones), T.random(1, #M.PvPInfo), T.random(1, #M.PVPArena), T.random(1, #M.Subzones), T.random(1, #Colors)
	local red, green, blue = T.unpack(Colors[c])

	--Setting texts--
	_G["ZoneTextString"]:SetText(M.Zones[z])
	_G["PVPInfoTextString"]:SetText(M.PvPInfo[i])
	_G["PVPArenaTextString"]:SetText(M.PVPArena[a])
	_G["SubZoneTextString"]:SetText(M.Subzones[s])

	ZoneTextPos()--nil, true)

	-- Applying colors
	_G["ZoneTextString"]:SetTextColor(red, green, blue)
	_G["PVPInfoTextString"]:SetTextColor(red, green, blue)
	_G["PVPArenaTextString"]:SetTextColor(red, green, blue)
	_G["SubZoneTextString"]:SetTextColor(red, green, blue)

	FadingFrame_Show(_G["ZoneTextFrame"])
	FadingFrame_Show(_G["SubZoneTextFrame"])
end

function M:Update()
	M:TextWidth()
end

function M:Initialize()
	if T.IsAddOnLoaded("ElvUI_SLE") then return; end

	M:TextWidth()
	hooksecurefunc(E, "UpdateBlizzardFonts", function() M:SetBlizzFonts() end)
	hooksecurefunc("SetZoneText", ZoneTextPos)
	M:SetBlizzFonts()
	M:Update()
end

KUI:RegisterModule(M:GetName())
