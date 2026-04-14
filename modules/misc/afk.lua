local KUI, T, E, L, V, P, G = unpack(select(2, ...))
local AFK = E:GetModule('AFK')

local format, random, lower, tonumber, date, floor = string.format, random, string.lower, tonumber, date, floor

local CreateFrame = CreateFrame
local GetGameTime = GetGameTime
local GetScreenHeight, GetScreenWidth = GetScreenHeight, GetScreenWidth
local C_DateAndTime_GetCurrentCalendarTime = C_DateAndTime and C_DateAndTime.GetCurrentCalendarTime
local C_PetJournal_GetNumPets = C_PetJournal and C_PetJournal.GetNumPets
local C_PetJournal_GetPetInfoByIndex = C_PetJournal and C_PetJournal.GetPetInfoByIndex
local C_PetJournal_GetPetInfoBySpeciesID = C_PetJournal and C_PetJournal.GetPetInfoBySpeciesID
local GetAchievementInfo = GetAchievementInfo
local GetStatistic = GetStatistic
local IsXPUserDisabled = IsXPUserDisabled
local IsPlayerAtEffectiveMaxLevel = IsPlayerAtEffectiveMaxLevel
local UnitXP, UnitXPMax = UnitXP, UnitXPMax
local UnitLevel = UnitLevel
local InCombatLockdown = InCombatLockdown
local GetSpecialization = GetSpecialization
local GetActiveSpecGroup = GetActiveSpecGroup
local GetSpecializationInfo = GetSpecializationInfo
local GetAverageItemLevel = GetAverageItemLevel
local GetClampedCurrentExpansionLevel = GetClampedCurrentExpansionLevel
local GetExpansionDisplayInfo = GetExpansionDisplayInfo

local TIMEMANAGER_TOOLTIP_LOCALTIME, TIMEMANAGER_TOOLTIP_REALMTIME = TIMEMANAGER_TOOLTIP_LOCALTIME, TIMEMANAGER_TOOLTIP_REALMTIME
local LEVEL, NONE = LEVEL, NONE
local ITEM_UPGRADE_STAT_AVERAGE_ITEM_LEVEL, MIN_PLAYER_LEVEL_FOR_ITEM_LEVEL_DISPLAY = ITEM_UPGRADE_STAT_AVERAGE_ITEM_LEVEL, MIN_PLAYER_LEVEL_FOR_ITEM_LEVEL_DISPLAY

local classColor = E.myclass == 'PRIEST' and E.PriestColors or (CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[E.myclass] or RAID_CLASS_COLORS[E.myclass])

-- Source wowhead.com
local stats = {
	60,		-- Total deaths
	94,		-- Quests abandoned
	97,		-- Daily quests completed
	98,		-- Quests completed
	107,	-- Creatures killed
	112,	-- Deaths from drowning
	114,	-- Deaths from falling
	115,	-- Deaths from fire and lava
	319,	-- Duels won
	320,	-- Duels lost
	326,	-- Gold from quest rewards
	328,	-- Total gold acquired
	329,	-- Auctions posted
	331,	-- Most expensive bid on auction
	332,	-- Most expensive auction sold
	333,	-- Gold looted
	334,	-- Most gold ever owned
	338,	-- Vanity pets owned
	345,	-- Health potions consumed
	349,	-- Flight paths taken
	353,	-- Number of times hearthed
	588,	-- Total Honorable Kills
	812,	-- Healthstones used
	837,	-- Arenas won
	838,	-- Arenas played
	839,	-- Battlegrounds played
	840,	-- Battlegrounds won
	919,	-- Gold earned from auctions
	932,	-- Total 5-player dungeons entered
	933,	-- Total 10-player raids entered
	934,	-- Total 25-player raids entered
	1042,	-- Number of hugs
	1045,	-- Total cheers
	1047,	-- Total facepalms
	1065,	-- Total waves
	1066,	-- Total times LOL'd
	1197,	-- Total kills
	1198,	-- Total kills that grant experience or honor
	1336,	-- Creature type killed the most
	1339,	-- Mage portal taken most
	1487,	-- Total Killing Blows
	1491,	-- Battleground Killing Blows
	1518,	-- Fish caught
	1776,	-- Food eaten most
	2277,	-- Summons accepted
	5692,	-- Rated battlegrounds played
	5693,	-- Rated battleground played the most
	5695,	-- Rated battleground won the most
	5694,	-- Rated battlegrounds won
	7399,	-- Challenge mode dungeons completed
	8278,	-- Pet Battles won at max level
}

-- Create Time
local function createTime()
	local hour, hour24, minute, ampm = T.tonumber(T.date("%I")), T.tonumber(T.date("%H")), T.tonumber(T.date("%M")), T.date("%p"):lower()
	local sHour, sMinute = T.GetGameTime()

	local localTime = T.string_format("|cffb3b3b3%s|r %d:%02d|cffb3b3b3%s|r", TIMEMANAGER_TOOLTIP_LOCALTIME, hour, minute, ampm)
	local localTime24 = T.string_format("|cffb3b3b3%s|r %02d:%02d", TIMEMANAGER_TOOLTIP_LOCALTIME, hour24, minute)
	local realmTime = T.string_format("|cffb3b3b3%s|r %d:%02d|cffb3b3b3%s|r", TIMEMANAGER_TOOLTIP_REALMTIME, sHour, sMinute, ampm)
	local realmTime24 = T.string_format("|cffb3b3b3%s|r %02d:%02d", TIMEMANAGER_TOOLTIP_REALMTIME, sHour, sMinute)

	if E.db.datatexts.localtime then
		if E.db.datatexts.time24 then
			return localTime24
		else
			return localTime
		end
	else
		if E.db.datatexts.time24 then
			return realmTime24
		else
			return realmTime
		end
	end
end

local monthAbr = {
	[1] = L["Jan"],
	[2] = L["Feb"],
	[3] = L["Mar"],
	[4] = L["Apr"],
	[5] = L["May"],
	[6] = L["Jun"],
	[7] = L["Jul"],
	[8] = L["Aug"],
	[9] = L["Sep"],
	[10] = L["Oct"],
	[11] = L["Nov"],
	[12] = L["Dec"],
}

local daysAbr = {
	[1] = L["Sun"],
	[2] = L["Mon"],
	[3] = L["Tue"],
	[4] = L["Wed"],
	[5] = L["Thu"],
	[6] = L["Fri"],
	[7] = L["Sat"],
}

local function GetCurrentCalendarTime()
	if C_DateAndTime_GetCurrentCalendarTime then
		return C_DateAndTime_GetCurrentCalendarTime()
	end

	local now = date("*t")
	return {
		weekday = now.wday,
		month = now.month,
		monthDay = now.day,
		year = now.year,
	}
end

local function FindPetSpeciesIDByName(petName)
	if not petName or petName == "" then return end

	if T.C_PetJournal_FindPetIDByName then
		return T.C_PetJournal_FindPetIDByName(petName)
	end

	if not C_PetJournal_GetNumPets or not C_PetJournal_GetPetInfoByIndex then return end

	local wantedName = lower(petName)
	for i = 1, C_PetJournal_GetNumPets() do
		local _, speciesID, _, customName, _, _, _, speciesName = C_PetJournal_GetPetInfoByIndex(i)
		if (customName and lower(customName) == wantedName) or (speciesName and lower(speciesName) == wantedName) then
			return speciesID
		end
	end
end

-- Create Date
local function createDate()
	local currentDate = GetCurrentCalendarTime()
	if not currentDate then return end

	local presentWeekday = currentDate.weekday;
	local presentMonth = currentDate.month;
	local presentDay = currentDate.monthDay;
	local presentYear = currentDate.year;
	AFK.AFKMode.top.date:SetFormattedText("%s, %s %d, %d", daysAbr[presentWeekday], monthAbr[presentMonth], presentDay, presentYear)
end

-- Create random stats
local function createStats()
	local id = stats[T.math_random( #stats )]
	local _, name = T.GetAchievementInfo(id)
	local result = T.GetStatistic(id)
	if result == "--" then result = NONE end
	return T.string_format("%s: |cfff0ff00%s|r", name, result)
end

local active
local function getSpec()
	if not T.GetSpecialization then
		return '' -- MoP Classic: skip if GetSpecialization is missing, fallback to safe default
	end
	local specIndex = T.GetSpecialization()
	if not specIndex then return '' end

	active = T.GetActiveSpecGroup and T.GetActiveSpecGroup() or 1

	local talent = ''
	local i = T.GetSpecialization(false, false, active)
	if i then
		i = T.select and T.select(2, T.GetSpecializationInfo(i)) or ''
		if(i) then
			talent = T.string_format('%s', i)
		end
	end

	return T.string_format('%s', talent)
end

local function getItemLevel()
	local level = T.UnitLevel and T.UnitLevel("player") or 0
	local _, equipped = T.GetAverageItemLevel and T.GetAverageItemLevel() or 0, 0
	local minLevel = MIN_PLAYER_LEVEL_FOR_ITEM_LEVEL_DISPLAY or 0
	local ilvl = ''
	if type(level) ~= "number" then level = tonumber(level) or 0 end
	if type(minLevel) ~= "number" then minLevel = tonumber(minLevel) or 0 end
	if type(equipped) ~= "number" then equipped = tonumber(equipped) or 0 end
	if (level >= minLevel and equipped > 0) then
		ilvl = T.string_format('\n%s: %d', ITEM_UPGRADE_STAT_AVERAGE_ITEM_LEVEL or "ilvl", equipped)
	end
	return ilvl
end

function AFK:UpdateStatMessage()
	E:UIFrameFadeIn(self.AFKMode.statMsg.info, 1, 1, 0)
	local createdStat = createStats()
	self.AFKMode.statMsg.info:SetText(createdStat)
	E:UIFrameFadeIn(self.AFKMode.statMsg.info, 1, 0, 1)
end

function AFK:UpdateLogOff()
	local timePassed = T.GetTime() - self.startTime
	local minutes = T.math_floor(timePassed/60)
	local neg_seconds = -timePassed % 60

	self.AFKMode.top.Status:SetValue(T.math_floor(timePassed))

	if minutes - 29 == 0 and T.math_floor(neg_seconds) == 0 then
		self:CancelTimer(self.logoffTimer)
		self.AFKMode.countd.text:SetFormattedText("%s: |cfff0ff0000:00|r", L["Logout Timer"])
	else
		self.AFKMode.countd.text:SetFormattedText("%s: |cfff0ff00%02d:%02d|r", L["Logout Timer"], minutes -29, neg_seconds)
	end
end

local function UpdateTimer()
	if E.db.KlixUI.general.AFK ~= true then return end

	local createdTime = createTime()

	-- Set time
	AFK.AFKMode.top.time:SetFormattedText(createdTime)

	-- Set Date
	createDate()

	-- Don't need the default timer
	AFK.AFKMode.bottom.time:SetText(nil)
end
hooksecurefunc(AFK, "UpdateTimer", UpdateTimer)

-- XP string
local M = E:GetModule('DataBars');
local function GetXPinfo()
	if IsPlayerAtEffectiveMaxLevel() or T.IsXPUserDisabled() then return end

	local cur, max = UnitXP('player'), UnitXPMax('player')
	if max <= 0 then max = 1 end
	local curlvl = T.UnitLevel('player')
	return T.string_format('|cfff0ff00%d%%|r (%s) %s |cfff0ff00%d|r', (max - cur) / max * 100, E:ShortValue(max - cur), L["remaining till level"], curlvl + 1)
end

AFK.SetAFKKui = AFK.SetAFK
function AFK:SetAFK(status)
	self:SetAFKKui(status)
	if E.db.KlixUI.general.AFK ~= true then return end

	if(status) then
		local xptxt = GetXPinfo()
		local level = T.UnitLevel('player')
		local race = T.UnitRace('player')
		local localizedClass = T.UnitClass('player')
		local spec = getSpec()
		local ilvl = getItemLevel()
		local petName = E.db.KlixUI.misc.AFKPetModel.pet
		local scale = E.db.KlixUI.misc.AFKPetModel.modelScale
		local facingRad = E.db.KlixUI.misc.AFKPetModel.facing * (T.math_pi/180)
		local animation = E.db.KlixUI.misc.AFKPetModel.animation
		self.AFKMode.top:Height(0)
		self.AFKMode.top.anim.height:Play()
		self.AFKMode.bottom:Height(0)
		self.AFKMode.bottom.anim.height:Play()
		self.startTime = T.GetTime()
		self.statsTimer = self:ScheduleRepeatingTimer("UpdateStatMessage", 5)
		self.logoffTimer = self:ScheduleRepeatingTimer("UpdateLogOff", 1)
		if petName ~= "" then
			local speciesID = FindPetSpeciesIDByName(petName)
			local displayID = speciesID and C_PetJournal_GetPetInfoBySpeciesID and T.select(12, C_PetJournal_GetPetInfoBySpeciesID(speciesID))

			if displayID then
				self.AFKMode.pet.model:SetModelScale(scale)
				self.AFKMode.pet.model:SetFacing(facingRad)
				self.AFKMode.pet.model:ClearModel()
				self.AFKMode.pet.model:SetDisplayInfo(displayID)
				--Animation types are undocumented. Some are listed here: http://us.battle.net/wow/en/forum/topic/8569600188
				self.AFKMode.pet.model:SetAnimation(animation)
				self.AFKMode.pet.model:SetCustomCamera(1)
				self.AFKMode.pet.model:SetCameraDistance(20) --Zoom out, otherwise we get a huge model
			else
				self.AFKMode.pet.model:ClearModel()
			end
		end
		if xptxt then
			self.AFKMode.xp:Show()
			self.AFKMode.xp.text:SetText(xptxt)
		else
			self.AFKMode.xp:Hide()
			self.AFKMode.xp.text:SetText("")
		end
		self.AFKMode.bottom.name:SetFormattedText("%s - %s\n%s %s %s %s %s%s", E.myname, E.myrealm, LEVEL, level, race, spec, localizedClass, ilvl)

		self.isAFK = true
	else
		self:CancelTimer(self.statsTimer)
		self:CancelTimer(self.logoffTimer)

		self.AFKMode.countd.text:SetFormattedText("%s: |cfff0ff00-30:00|r", L["Logout Timer"])
		self.AFKMode.statMsg.info:SetFormattedText("|cffb3b3b3%s|r", L["Random Stats"])
		self.isAFK = false
	end
end

local function createPetModel(self)
	self.AFKMode.pet = T.CreateFrame("Frame", nil, self.AFKMode)
	self.AFKMode.pet:Size(150, 150)
	self.AFKMode.pet:Point("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 400, 60)
	E:CreateMover(self.AFKMode.pet, "AFKPetModelMover", "AFK Pet Model", nil, nil, nil, "AFK")
	
	self.AFKMode.pet.model = T.CreateFrame("PlayerModel", "ElvUIAFKPetModel", self.AFKMode.pet)
	self.AFKMode.pet.model:Point("CENTER", self.AFKMode.pet, "CENTER")
	--Use a large frame so borders don't become visible when pets do one of their special animations
	self.AFKMode.pet.model:Size(T.GetScreenWidth()*2, T.GetScreenHeight()*2)
end
hooksecurefunc(AFK, "Initialize", createPetModel)

local find = string.find

local function IsFoolsDay()
	if T.string_find(T.date(), '04/01/') then
		return true;
	else
		return false;
	end
end

local function prank(self, status)
	if(T.InCombatLockdown()) then return end
	--if not IsFoolsDay() then return end

	if(status) then

	end
end
--hooksecurefunc(AFK, "SetAFK", prank)

local function Initialize()
	if E.db.general.afk ~= true or E.db.KlixUI.general.AFK ~= true then return end

	local level = T.UnitLevel('player')
	local race = T.UnitRace('player')
	local localizedClass = T.UnitClass('player')
	local className = E.myclass
	local spec = getSpec()
	local ilvl = getItemLevel()

	-- Create Top frame
	AFK.AFKMode.top = T.CreateFrame('Frame', nil, AFK.AFKMode, 'BackdropTemplate')
	AFK.AFKMode.top:SetFrameLevel(0)
	AFK.AFKMode.top:SetTemplate('Transparent', true, true)
	AFK.AFKMode.top:SetBackdropBorderColor(.3, .3, .3, 1)
	AFK.AFKMode.top:CreateWideShadow()
	AFK.AFKMode.top:ClearAllPoints()
	AFK.AFKMode.top:Point("TOP", AFK.AFKMode, "TOP", 0, E.Border)
	AFK.AFKMode.top:Width(T.GetScreenWidth() + (E.Border*2))
	
	-- Frame Styling
	AFK.AFKMode.top:Styling()
	AFK.AFKMode.bottom:Styling()

	-- Top Animation
	AFK.AFKMode.top.anim = CreateAnimationGroup(AFK.AFKMode.top)
	AFK.AFKMode.top.anim.height = AFK.AFKMode.top.anim:CreateAnimation("Height")
	AFK.AFKMode.top.anim.height:SetChange(T.GetScreenHeight() * (1 / 20))
	AFK.AFKMode.top.anim.height:SetDuration(1)
	AFK.AFKMode.top.anim.height:SetSmoothing("Bounce")

	-- move the chat lower or disable it
	AFK.AFKMode.chat:ClearAllPoints()
	if E.db.KlixUI.general.AFKChat then
		AFK.AFKMode.chat:Point("TOPLEFT", AFK.AFKMode.top, "BOTTOMLEFT", 4, -10)
	else
		AFK.AFKMode.chat:Hide()
	end

	-- WoW logo
	AFK.AFKMode.top.wowlogo = T.CreateFrame('Frame', nil, AFK.AFKMode) -- need this to upper the logo layer
	AFK.AFKMode.top.wowlogo:Point("TOP", AFK.AFKMode.top, "TOP", 0, -5)
	AFK.AFKMode.top.wowlogo:SetFrameStrata("MEDIUM")
	AFK.AFKMode.top.wowlogo:Size(300, 150)
	AFK.AFKMode.top.wowlogo.tex = AFK.AFKMode.top.wowlogo:CreateTexture(nil, 'OVERLAY')
	local currentExpansionLevel = T.GetClampedCurrentExpansionLevel()
	local expansionDisplayInfo = T.GetExpansionDisplayInfo(currentExpansionLevel)
	if expansionDisplayInfo then
		AFK.AFKMode.top.wowlogo.tex:SetTexture(expansionDisplayInfo.logo)
	end
	AFK.AFKMode.top.wowlogo.tex:SetInside()

	-- Server/Local Time text
	AFK.AFKMode.top.time = AFK.AFKMode.top:CreateFontString(nil, 'OVERLAY')
	AFK.AFKMode.top.time:FontTemplate(nil, 16)
	AFK.AFKMode.top.time:SetText("")
	AFK.AFKMode.top.time:Point("RIGHT", AFK.AFKMode.top, "RIGHT", -20, 0)
	AFK.AFKMode.top.time:SetJustifyH("LEFT")
	AFK.AFKMode.top.time:SetTextColor(T.unpack(E["media"].rgbvaluecolor))

	-- Date text
	AFK.AFKMode.top.date = AFK.AFKMode.top:CreateFontString(nil, 'OVERLAY')
	AFK.AFKMode.top.date:FontTemplate(nil, 16)
	AFK.AFKMode.top.date:SetText("")
	AFK.AFKMode.top.date:Point("LEFT", AFK.AFKMode.top, "LEFT", 20, 0)
	AFK.AFKMode.top.date:SetJustifyH("RIGHT")
	AFK.AFKMode.top.date:SetTextColor(T.unpack(E["media"].rgbvaluecolor))

	-- Statusbar on Top frame decor showing time to log off (30mins)
	AFK.AFKMode.top.Status = T.CreateFrame('StatusBar', nil, AFK.AFKMode.top)
	AFK.AFKMode.top.Status:SetStatusBarTexture((E["media"].normTex))
	AFK.AFKMode.top.Status:SetMinMaxValues(0, 1800)
	AFK.AFKMode.top.Status:SetStatusBarColor(T.unpack(E["media"].rgbvaluecolor))
	AFK.AFKMode.top.Status:SetFrameLevel(2)
	AFK.AFKMode.top.Status:Point('TOPRIGHT', AFK.AFKMode.top, 'BOTTOMRIGHT', 0, E.PixelMode and 3 or 5)
	AFK.AFKMode.top.Status:Point('BOTTOMLEFT', AFK.AFKMode.top, 'BOTTOMLEFT', 0, E.PixelMode and 1 or 2)
	AFK.AFKMode.top.Status:SetValue(0)

	AFK.AFKMode.bottom:SetTemplate('Transparent', true, true)
	AFK.AFKMode.bottom:SetBackdropBorderColor(.3, .3, .3, 1)
	AFK.AFKMode.bottom:CreateWideShadow()
	AFK.AFKMode.bottom.modelHolder:SetFrameLevel(7)

	-- Bottom Frame Animation
	AFK.AFKMode.bottom.anim = CreateAnimationGroup(AFK.AFKMode.bottom)
	AFK.AFKMode.bottom.anim.height = AFK.AFKMode.bottom.anim:CreateAnimation("Height")
	AFK.AFKMode.bottom.anim.height:SetChange(T.GetScreenHeight() * (1 / 9))
	AFK.AFKMode.bottom.anim.height:SetDuration(1)
	AFK.AFKMode.bottom.anim.height:SetSmoothing("Bounce")

	-- Move the factiongroup sign to the center
	AFK.AFKMode.bottom.factionb = T.CreateFrame('Frame', nil, AFK.AFKMode) -- need this to upper the faction logo layer
	AFK.AFKMode.bottom.factionb:Point("BOTTOM", AFK.AFKMode.bottom, "TOP", 0, -40)
	AFK.AFKMode.bottom.factionb:SetFrameStrata("MEDIUM")
	AFK.AFKMode.bottom.factionb:SetFrameLevel(10)
	AFK.AFKMode.bottom.factionb:Size(220, 220)
	AFK.AFKMode.bottom.faction:ClearAllPoints()
	AFK.AFKMode.bottom.faction:SetParent(AFK.AFKMode.bottom.factionb)
	AFK.AFKMode.bottom.faction:SetInside()
	-- Apply class texture rather than the faction
	AFK.AFKMode.bottom.faction:SetTexture('Interface\\AddOns\\ElvUI_KlixUI\\media\\textures\\classIcons\\CLASS-'..className)

	-- Add more info in the name and position it to the center
	AFK.AFKMode.bottom.name:ClearAllPoints()
	AFK.AFKMode.bottom.name:Point("TOP", AFK.AFKMode.bottom.factionb, "BOTTOM", 0, 5)
	AFK.AFKMode.bottom.name:SetFormattedText("%s - %s\n%s %s %s %s %s%s", E.myname, E.myrealm, LEVEL, level, race, spec, localizedClass, ilvl)
	AFK.AFKMode.bottom.name:SetJustifyH("CENTER")
	AFK.AFKMode.bottom.name:FontTemplate(nil, 18)

	-- Lower the guild text size a bit
	AFK.AFKMode.bottom.guild:ClearAllPoints()
	AFK.AFKMode.bottom.guild:Point("TOP", AFK.AFKMode.bottom.name, "BOTTOM", 0, -6)
	AFK.AFKMode.bottom.guild:FontTemplate(nil, 12)
	AFK.AFKMode.bottom.guild:SetJustifyH("CENTER")

	
	-- ElvUI Logo
	AFK.AFKMode.bottom.LogoTop:ClearAllPoints()
	AFK.AFKMode.bottom.LogoTop:SetParent(AFK.AFKMode.bottom)
	AFK.AFKMode.bottom.LogoTop:Point("LEFT", AFK.AFKMode.bottom, "LEFT", 50, 8)
	AFK.AFKMode.bottom.LogoTop:Size(120, 55)
	-- AFK.AFKMode.bottom.LogoTop:Hide() -- Hide ElvUI Logo

	AFK.AFKMode.bottom.LogoBottom:ClearAllPoints()
	-- AFK.AFKMode.bottom.LogoBottom:SetParent(AFK.AFKMode.bottom)
	AFK.AFKMode.bottom.LogoBottom:Point("LEFT", AFK.AFKMode.bottom, "LEFT", 50, 8)
	AFK.AFKMode.bottom.LogoBottom:Size(120, 55)

	-- ElvUI Version
	AFK.AFKMode.bottom.eversion = KUI:CreateText(AFK.AFKMode.bottom, "OVERLAY", 12, nil)
	AFK.AFKMode.bottom.eversion:SetText("v"..E.version.."|r")
	AFK.AFKMode.bottom.eversion:Point("TOP", AFK.AFKMode.bottom.LogoTop, "BOTTOM")
	AFK.AFKMode.bottom.eversion:SetTextColor(T.unpack(E["media"].rgbvaluecolor))

	-- KlixUI Logo
	AFK.AFKMode.bottom.KuiLogo = AFK.AFKMode.bottom:CreateTexture(nil, "OVERLAY")
	AFK.AFKMode.bottom.KuiLogo:SetTexture("Interface\\AddOns\\ElvUI_KlixUI\\media\\textures\\KlixUILogo.tga")
	AFK.AFKMode.bottom.KuiLogo:Point("RIGHT", AFK.AFKMode.bottom, "RIGHT", -50, 8)
	AFK.AFKMode.bottom.KuiLogo:Size(80, 80)

	-- KlixUI Version
	AFK.AFKMode.bottom.mversion = KUI:CreateText(AFK.AFKMode.bottom, "OVERLAY", 12, nil)
	AFK.AFKMode.bottom.mversion:SetText("v"..KUI.Version)
	AFK.AFKMode.bottom.mversion:Point("TOP", AFK.AFKMode.bottom.KuiLogo, "BOTTOM")
	AFK.AFKMode.bottom.mversion:SetTextColor(T.unpack(E["media"].rgbvaluecolor))

	-- Random stats decor (taken from install routine)
	AFK.AFKMode.statMsg = CreateFrame("Frame", nil, AFK.AFKMode)
	AFK.AFKMode.statMsg:Size(418, 72)
	AFK.AFKMode.statMsg:Point("CENTER", 0, 200)

	AFK.AFKMode.statMsg.bg = AFK.AFKMode.statMsg:CreateTexture(nil, 'BACKGROUND')
	AFK.AFKMode.statMsg.bg:SetTexture([[Interface\LevelUp\LevelUpTex]])
	AFK.AFKMode.statMsg.bg:Point('BOTTOM')
	AFK.AFKMode.statMsg.bg:Size(326, 103)
	AFK.AFKMode.statMsg.bg:SetTexCoord(0.00195313, 0.63867188, 0.03710938, 0.23828125)
	AFK.AFKMode.statMsg.bg:SetVertexColor(1, 1, 1, 0.7)

	AFK.AFKMode.statMsg.lineTop = AFK.AFKMode.statMsg:CreateTexture(nil, 'BACKGROUND')
	AFK.AFKMode.statMsg.lineTop:SetDrawLayer('BACKGROUND', 2)
	AFK.AFKMode.statMsg.lineTop:SetTexture([[Interface\LevelUp\LevelUpTex]])
	AFK.AFKMode.statMsg.lineTop:Point("TOP")
	AFK.AFKMode.statMsg.lineTop:Size(418, 7)
	AFK.AFKMode.statMsg.lineTop:SetTexCoord(0.00195313, 0.81835938, 0.01953125, 0.03320313)

	AFK.AFKMode.statMsg.lineBottom = AFK.AFKMode.statMsg:CreateTexture(nil, 'BACKGROUND')
	AFK.AFKMode.statMsg.lineBottom:SetDrawLayer('BACKGROUND', 2)
	AFK.AFKMode.statMsg.lineBottom:SetTexture([[Interface\LevelUp\LevelUpTex]])
	AFK.AFKMode.statMsg.lineBottom:Point("BOTTOM")
	AFK.AFKMode.statMsg.lineBottom:Size(418, 7)
	AFK.AFKMode.statMsg.lineBottom:SetTexCoord(0.00195313, 0.81835938, 0.01953125, 0.03320313)

	-- Countdown decor
	AFK.AFKMode.countd = T.CreateFrame("Frame", nil, AFK.AFKMode)
	AFK.AFKMode.countd:Size(418, 36)
	AFK.AFKMode.countd:Point("TOP", AFK.AFKMode.statMsg.lineBottom, "BOTTOM")

	AFK.AFKMode.countd.bg = AFK.AFKMode.countd:CreateTexture(nil, 'BACKGROUND')
	AFK.AFKMode.countd.bg:SetTexture([[Interface\LevelUp\LevelUpTex]])
	AFK.AFKMode.countd.bg:Point('BOTTOM')
	AFK.AFKMode.countd.bg:Size(326, 56)
	AFK.AFKMode.countd.bg:SetTexCoord(0.00195313, 0.63867188, 0.03710938, 0.23828125)
	AFK.AFKMode.countd.bg:SetVertexColor(1, 1, 1, 0.7)

	AFK.AFKMode.countd.lineBottom = AFK.AFKMode.countd:CreateTexture(nil, 'BACKGROUND')
	AFK.AFKMode.countd.lineBottom:SetDrawLayer('BACKGROUND', 2)
	AFK.AFKMode.countd.lineBottom:SetTexture([[Interface\LevelUp\LevelUpTex]])
	AFK.AFKMode.countd.lineBottom:Point('BOTTOM')
	AFK.AFKMode.countd.lineBottom:Size(418, 7)
	AFK.AFKMode.countd.lineBottom:SetTexCoord(0.00195313, 0.81835938, 0.01953125, 0.03320313)

	-- 30 mins countdown text
	AFK.AFKMode.countd.text = AFK.AFKMode.countd:CreateFontString(nil, 'OVERLAY')
	AFK.AFKMode.countd.text:FontTemplate(nil, 12)
	AFK.AFKMode.countd.text:Point("CENTER", AFK.AFKMode.countd, "CENTER")
	AFK.AFKMode.countd.text:SetJustifyH("CENTER")
	AFK.AFKMode.countd.text:SetFormattedText("%s: |cfff0ff00-30:00|r", L["Logout Timer"])
	AFK.AFKMode.countd.text:SetTextColor(0.7, 0.7, 0.7)

	AFK.AFKMode.bottom.time:Hide()

	local xptxt = GetXPinfo()
	-- XP info
	AFK.AFKMode.xp = T.CreateFrame("Frame", nil, AFK.AFKMode)
	AFK.AFKMode.xp:Size(418, 36)
	AFK.AFKMode.xp:Point("TOP", AFK.AFKMode.countd.lineBottom, "BOTTOM")
	AFK.AFKMode.xp.bg = AFK.AFKMode.xp:CreateTexture(nil, 'BACKGROUND')
	AFK.AFKMode.xp.bg:SetTexture([[Interface\LevelUp\LevelUpTex]])
	AFK.AFKMode.xp.bg:Point('BOTTOM')
	AFK.AFKMode.xp.bg:Size(326, 56)
	AFK.AFKMode.xp.bg:SetTexCoord(0.00195313, 0.63867188, 0.03710938, 0.23828125)
	AFK.AFKMode.xp.bg:SetVertexColor(1, 1, 1, 0.7)
	AFK.AFKMode.xp.lineBottom = AFK.AFKMode.xp:CreateTexture(nil, 'BACKGROUND')
	AFK.AFKMode.xp.lineBottom:SetDrawLayer('BACKGROUND', 2)
	AFK.AFKMode.xp.lineBottom:SetTexture([[Interface\LevelUp\LevelUpTex]])
	AFK.AFKMode.xp.lineBottom:Point('BOTTOM')
	AFK.AFKMode.xp.lineBottom:Size(418, 7)
	AFK.AFKMode.xp.lineBottom:SetTexCoord(0.00195313, 0.81835938, 0.01953125, 0.03320313)
	AFK.AFKMode.xp.text = AFK.AFKMode.xp:CreateFontString(nil, 'OVERLAY')
	AFK.AFKMode.xp.text:FontTemplate(nil, 12)
	AFK.AFKMode.xp.text:Point("CENTER", AFK.AFKMode.xp, "CENTER")
	AFK.AFKMode.xp.text:SetJustifyH("CENTER")
	AFK.AFKMode.xp.text:SetText(xptxt)
	AFK.AFKMode.xp.text:SetTextColor(0.7, 0.7, 0.7)

	-- Random stats frame
	AFK.AFKMode.statMsg.info = AFK.AFKMode.statMsg:CreateFontString(nil, 'OVERLAY')
	AFK.AFKMode.statMsg.info:FontTemplate(nil, 18)
	AFK.AFKMode.statMsg.info:Point("CENTER", AFK.AFKMode.statMsg, "CENTER", 0, -2)
	AFK.AFKMode.statMsg.info:SetText(T.string_format("|cffb3b3b3%s|r", L["Random Stats"]))
	AFK.AFKMode.statMsg.info:SetJustifyH("CENTER")
	AFK.AFKMode.statMsg.info:SetTextColor(0.7, 0.7, 0.7)
end

hooksecurefunc(AFK, "Initialize", Initialize)
