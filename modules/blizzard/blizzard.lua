local KUI, T, E, L, V, P, G = unpack(select(2, ...))
local B = KUI:NewModule("Blizzard", 'AceHook-3.0', 'AceEvent-3.0')

--Frames to move
B.Frames = {
	"AddonList",
	"AudioOptionsFrame",
	"BankFrame",
	"CharacterFrame",
	"ChatConfigFrame",
	"DressUpFrame",
	"FriendsFrame",
	"FriendsFriendsFrame",
	"GameMenuFrame",
	"GossipFrame",
	"GuildInviteFrame",
	"GuildRegistrarFrame",
	"HelpFrame",
	"InterfaceOptionsFrame",
	"ItemTextFrame",
	"LFDRoleCheckPopup",
	"LFGDungeonReadyDialog",
	"LFGDungeonReadyStatus",
	"LootFrame",
	"MailFrame",
	"MerchantFrame",
	"OpenMailFrame",
	"PVEFrame",
	"PetStableFrame",
	"PetitionFrame",
	"PVPReadyDialog",
	"QuestFrame",
	"QuestLogPopupDetailFrame",
	"RaidBrowserFrame",
	"RaidInfoFrame",
	"RaidParentFrame",
	"ReadyCheckFrame",
	"ReportCheatingDialog",
	"RolePollPopup",
	"SpellBookFrame",
	"SplashFrame",
	"StackSplitFrame",
	"StaticPopup1",
	"StaticPopup2",
	"StaticPopup3",
	"StaticPopup4",
	"TabardFrame",
	"TaxiFrame",
	"TimeManagerFrame",
	"TradeFrame",
	"TutorialFrame",
	"VideoOptionsFrame",
	"WorldMapFrame",
}

--These should be only temporary movable due to complications
B.TempOnly = {
	["BonusRollFrame"] = true,
	["BonusRollLootWonFrame"] = true,
	["BonusRollMoneyWonFrame"] = true,
}

--Blizz addons that load later
B.AddonsList = {
	["Blizzard_AchievementUI"] = { "AchievementFrame" },
	["Blizzard_AlliedRacesUI"] = { "AlliedRacesFrame" },
	["Blizzard_ArchaeologyUI"] = { "ArchaeologyFrame" },
	["Blizzard_AuctionUI"] = { "AuctionFrame" },
	["Blizzard_AzeriteUI"] = { "AzeriteEmpoweredItemUI" },
	["Blizzard_BarberShopUI"] = { "BarberShopFrame" },
	["Blizzard_BindingUI"] = { "KeyBindingFrame" },
	["Blizzard_BlackMarketUI"] = { "BlackMarketFrame" },
	["Blizzard_Calendar"] = { "CalendarCreateEventFrame", "CalendarFrame" },
	["Blizzard_ChallengesUI"] = { "ChallengesKeystoneFrame" }, -- 'ChallengesLeaderboardFrame'
	["Blizzard_Collections"] = { "CollectionsJournal", "WardrobeFrame" },
	["Blizzard_Communities"] = { "CommunitiesFrame" },
	["Blizzard_EncounterJournal"] = { "EncounterJournal" },
	["Blizzard_GarrisonUI"] = {
		"GarrisonLandingPage", "GarrisonMissionFrame", "GarrisonCapacitiveDisplayFrame",
		"GarrisonBuildingFrame", "GarrisonRecruiterFrame", "GarrisonRecruitSelectFrame",
		"GarrisonShipyardFrame", "OrderHallMissionFrame", "BFAMissionFrame",
	},
	["Blizzard_GMChatUI"] = { "GMChatStatusFrame" },
	["Blizzard_GMSurveyUI"] = { "GMSurveyFrame" },
	["Blizzard_GuildBankUI"] = { "GuildBankFrame" },
	["Blizzard_GuildControlUI"] = { "GuildControlUI" },
	["Blizzard_GuildUI"] = { "GuildFrame", "GuildLogFrame" },
	["Blizzard_InspectUI"] = { "InspectFrame" },
	["Blizzard_ItemAlterationUI"] = { "TransmogrifyFrame" },
	["Blizzard_ItemSocketingUI"] = { "ItemSocketingFrame" },
	["Blizzard_ItemUpgradeUI"] = { "ItemUpgradeFrame" },
	["Blizzard_LookingForGuildUI"] = { "LookingForGuildFrame" },
	["Blizzard_MacroUI"] = { "MacroFrame" },
	["Blizzard_OrderHallUI"] = { "OrderHallTalentFrame" },
	["Blizzard_QuestChoice"] = { "QuestChoiceFrame" },
	["Blizzard_ScrappingMachineUI"] = { "ScrappingMachineFrame" },
	["Blizzard_TalentUI"] = { "PlayerTalentFrame" },
	["Blizzard_TradeSkillUI"] = { "TradeSkillFrame" },
	["Blizzard_TrainerUI"] = { "ClassTrainerFrame" },
	["Blizzard_VoidStorageUI"] = { "VoidStorageFrame" },
}

-- These should not be on screen at the same time
B.ExlusiveFrames = {
	["QuestFrame"] = { "GossipFrame", },
	["GossipFrame"] = { "QuestFrame", },
	["GameMenuFrame"] = { "VideoOptionsFrame", "InterfaceOptionsFrame", "HelpFrame",},
	["VideoOptionsFrame"] = { "GameMenuFrame",},
	["InterfaceOptionsFrame"] = { "GameMenuFrame",},
	["HelpFrame"] = { "GameMenuFrame",},
}

B.FramesAreaAlter = {
	["GarrisonMissionFrame"] = "left",
	["OrderHallMissionFrame"] = "left",
	["BFAMissionFrame"] = "left",
}

B.SpecialDefaults = {
	["GarrisonMissionFrame"] = { "CENTER", _G.UIParent, "CENTER", 0, 0 },
	["OrderHallMissionFrame"] = { "CENTER", _G.UIParent, "CENTER", 0, 0 },
	["BFAMissionFrame"] = { "CENTER", _G.UIParent, "CENTER", 0, 0 },
}

B.OriginalDefaults = {}
B.SessionPoints = {}
B.PendingPositions = {}

local function IsBlizzMoveSupported()
	return E.Retail or E.TBC or E.Mists
end

local ProtectedBlizzardFrames = {
	MultiCastActionBarFrame = true,
	MultiCastActionBar = true,
	TotemFrame = true,
	ShapeshiftBarFrame = true,
	PossessBarFrame = true,
}

local function ShouldSkipBlizzMoveFrame(Name)
	return (E.Mists and Name == "GameMenuFrame") or ProtectedBlizzardFrames[Name]
end

local function IsFrameProtectedOrForbidden(frame)
	if not frame then return true end
	if frame.IsForbidden and frame:IsForbidden() then return true end
	if frame.IsProtected and frame:IsProtected() then return true end
end

local function ResolveAnchorParent(parent)
	if T.type(parent) == "string" then
		return _G[parent] or _G.UIParent
	end

	return parent or _G.UIParent
end

local function GetAnchorData(frame)
	local point, relativeTo, relativePoint, xOfs, yOfs = frame:GetPoint()
	local parentName

	if relativeTo and relativeTo.GetName then
		parentName = relativeTo:GetName()
	end

	if (not parentName or parentName == "") and frame:GetParent() and frame:GetParent().GetName then
		parentName = frame:GetParent():GetName()
	end

	return point, parentName or "UIParent", relativePoint, xOfs, yOfs
end

local function QueuePositionUpdate(frame)
	if not frame or not frame.GetName then return end

	local Name = frame:GetName()
	if Name then
		B.PendingPositions[Name] = true
		B:RegisterEvent("PLAYER_REGEN_ENABLED", "ApplyPendingPositions")
	end
end

local function OnDragStart(self)
	if T.UnitAffectingCombat("player") then return end -- Not allowed to move in combat, cause reasons.
	local Name = self:GetName()
	if not E.private.KlixUI.module.blizzmove.remember and not B.OriginalDefaults[Name] then
		B.OriginalDefaults[Name] = {GetAnchorData(self)}
	end
	self.IsMoving = true
	self:StartMoving()
end

--When stop moving (or hiding), remember frame's positions.
local function OnDragStop(self)
	local wasMoving = self.IsMoving
	if T.InCombatLockdown() then
		self.IsMoving = false
		QueuePositionUpdate(self)
		return
	end

	if wasMoving and not T.InCombatLockdown() then
		self:StopMovingOrSizing()
	end

	if not wasMoving then
		return
	end

	local Name = self:GetName()
	local a, b, c, d, e = GetAnchorData(self)

	if self:IsShown() then
		B.SessionPoints[Name] = {a, b, c, d, e}
	end

	if E.private.KlixUI.module.blizzmove.remember and not B.TempOnly[Name] then -- Saving positions only if option is enabled and frame is not temporary movable
		if Name == "QuestFrame" or Name == "GossipFrame" then -- These 2 frames should always be in the same place. So having coordinates for them at the same time
			E.private.KlixUI.module.blizzmove.points["GossipFrame"] = {a, b, c, d, e}
			E.private.KlixUI.module.blizzmove.points["QuestFrame"] = {a, b, c, d, e}
		else
			E.private.KlixUI.module.blizzmove.points[Name] = {a, b, c, d, e}
		end
		self:SetUserPlaced(true)
	elseif self:IsShown() then
		self:SetUserPlaced(true)
	end
	self.IsMoving = false
end

-- On show set saved position
local function LoadPosition(self)
	if self.IsMoving == true then return end
	if T.InCombatLockdown() then
		QueuePositionUpdate(self)
		return
	end

	local Name = self:GetName()
	if not self:GetPoint() then -- Some frames don't have set positions when show script runs (e.g. CharacterFrame). For those set default position and save that.
		if B.SpecialDefaults[Name] then
			local a,b,c,d,e = T.unpack(B.SpecialDefaults[Name])
			self:SetPoint(a, ResolveAnchorParent(b), c, d, e, true)
		elseif B.OriginalDefaults[Name] then
			local a,b,c,d,e = T.unpack(B.OriginalDefaults[Name])
			self:SetPoint(a, ResolveAnchorParent(b), c, d, e, true)
		else
			self:SetPoint('TOPLEFT', UIParent, 'TOPLEFT', 16, -116, true)
		end
		OnDragStop(self)
	end

	if E.private.KlixUI.module.blizzmove.remember and E.private.KlixUI.module.blizzmove.points[Name] then
		self:ClearAllPoints()
		local a,b,c,d,e = T.unpack(E.private.KlixUI.module.blizzmove.points[Name])
		self:SetPoint(a, ResolveAnchorParent(b), c, d, e, true)
	elseif not E.private.KlixUI.module.blizzmove.remember and B.SessionPoints[Name] then
		self:ClearAllPoints()
		local a,b,c,d,e = T.unpack(B.SessionPoints[Name])
		self:SetPoint(a, ResolveAnchorParent(b), c, d, e, true)
	end

	if B.ExlusiveFrames[Name] then
		for _, name in T.pairs(B.ExlusiveFrames[Name]) do
			if _G[name] then
				_G[name]:Hide()
			end
		end
	end -- If this frame has others that should not be shown at the same time, hide those
end

--Hooking this to movable frames' SetPoint.
--Blizz love to move some frames when stuff happens, so if SetPoint is not passing an additional arg we call SetPoint again with saved position.
function B:RewritePoint(anchor, parent, point, x, y, KUIcalled)
	if KUIcalled or self.IsMoving then return end
	if T.InCombatLockdown() then
		QueuePositionUpdate(self)
		return
	end

	local name = self:GetName()
	if not E.private.KlixUI.module.blizzmove.remember and B.SessionPoints[name] then
		local a,b,c,d,e = T.unpack(B.SessionPoints[name])
		self:ClearAllPoints()
		self:SetPoint(a, ResolveAnchorParent(b), c, d, e, true)
	else
		LoadPosition(self)
	end
end

function B:MakeMovable(Name)
	if ShouldSkipBlizzMoveFrame(Name) then return end

	local frame = _G[Name]
	if not frame then -- Some Blizzard frames are expansion/client specific and simply do not exist on MoP Classic.
		return
	end

	if IsFrameProtectedOrForbidden(frame) then
		return
	end

	if Name == "AchievementFrame" then _G.AchievementFrameHeader:EnableMouse(false) end --Cause achievement frame is a bitch

	frame:EnableMouse(true)
	frame:SetMovable(true)
	frame:SetClampedToScreen(true)
	frame:RegisterForDrag("LeftButton")

	frame:HookScript("OnShow", LoadPosition)
	frame:HookScript("OnDragStart", OnDragStart)
	frame:HookScript("OnDragStop", OnDragStop)
	frame:HookScript("OnHide", OnDragStop)
	hooksecurefunc(frame, "SetPoint", B.RewritePoint)
end

function B:ApplyPendingPositions()
	if T.InCombatLockdown() then return end

	self:UnregisterEvent("PLAYER_REGEN_ENABLED")

	for Name in T.pairs(B.PendingPositions) do
		B.PendingPositions[Name] = nil

		local frame = _G[Name]
		if frame and frame:IsShown() then
			LoadPosition(frame)
		end
	end
end

function B:Addons(event, addon)
	addon = B.AddonsList[addon]
	if not addon then return end
	if T.type(addon) == "table" then
		for i = 1, #addon do
			B:MakeMovable(addon[i])
		end
	else
		B:MakeMovable(addon)
	end
	B.addonCount = B.addonCount + 1
	--If every blizz addon is loaded we don't need to listen to these event
	if B.addonCount == #B.AddonsList then B:UnregisterEvent(event) end
end

function B:ErrorFrameSize()
	_G["UIErrorsFrame"]:SetSize(B.db.errorframe.width, B.db.errorframe.height) --512 x 60
end

local ToDelete = {
	["CalendarViewEventFrame"] = true,
	["CalendarViewHolidayFrame"] = true,
}

function B:Initialize()
	if T.IsAddOnLoaded("ElvUI_SLE") then return end
	
	B.db = E.db.KlixUI.blizzard
	
	B.addonCount = 0
	
	--DB conversion
	if E.private.KlixUI.module.blizzmove and type(E.private.KlixUI.module.blizzmove) == "boolean" then E.private.KlixUI.module.blizzmove = V.KlixUI.module.blizzmove end --Old setting conversions
	E.global.KlixUI.pvpreadydialogreset = nil
	if not E.private.KlixUI.pvpreadydialogreset then E.private.KlixUI.module.blizzmove.points["PVPReadyDialog"] = nil; E.private.KlixUI.pvpreadydialogreset = true end
	for Name, _ in T.pairs(ToDelete) do
		if E.private.KlixUI.module.blizzmove.points[Name] then E.private.KlixUI.module.blizzmove.points[Name] = nil end
	end

	if IsBlizzMoveSupported() and _G.PVPReadyDialog then
		_G.PVPReadyDialog:Hide()
	end

	if IsBlizzMoveSupported() and E.private.KlixUI.module.blizzmove.enable then
		for Name, _ in T.pairs(B.TempOnly) do --Remove these from saved variables so the script will not attempt to mess with them, cause they are not ment to be moved permanently
			if E.private.KlixUI.module.blizzmove.points[Name] then E.private.KlixUI.module.blizzmove.points[Name] = nil end
		end
		for i = 1, #B.Frames do
			B:MakeMovable(B.Frames[i])
		end

		self:RegisterEvent("ADDON_LOADED", "Addons")

		-- Check Forced Loaded AddOns
		for AddOn, Table in T.pairs(B.AddonsList) do
			if T.IsAddOnLoaded(AddOn) then
				for _, frame in T.pairs(Table) do
					B:MakeMovable(frame)
				end
			end
		end
	end

	B:ErrorFrameSize()
	function B:ForUpdateAll()
		B.db = E.db.KlixUI.blizzard
		B:ErrorFrameSize()
	end
end

KUI:RegisterModule(B:GetName())
