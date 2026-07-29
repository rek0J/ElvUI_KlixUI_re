local KUI, T, E, L, V, P, G = unpack(select(2, ...))
local LSM = E.LSM or E.Libs.LSM

-- Cache global variables
-- Lua functions
local _G = _G

local function SafeNamespace(name)
	local namespace = rawget(_G, name)
	if namespace then
		return namespace
	end

	namespace = setmetatable({}, {
		__index = function()
			return KUI.dummy
		end,
	})
	_G[name] = namespace

	return namespace
end

local AuraUtil = SafeNamespace("AuraUtil")
local C_Container = rawget(_G, "C_Container")
local C_Map = rawget(_G, "C_Map")
local C_Timer = rawget(_G, "C_Timer")
local C_Heirloom = rawget(_G, "C_Heirloom")
local C_PetJournal = rawget(_G, "C_PetJournal") -- Pet Battles/Pet Journal is native MoP (5.0.4) content, not retail-only
-- Deaktiviert: Retail-only C_ APIs, die in MoP Classic nicht existieren
-- local C_AreaPoiInfo = SafeNamespace("C_AreaPoiInfo")
-- local C_AzeriteEmpoweredItem = SafeNamespace("C_AzeriteEmpoweredItem")
-- local C_AzeriteEssence = SafeNamespace("C_AzeriteEssence")
-- local C_AzeriteItem = SafeNamespace("C_AzeriteItem")
-- local C_BattleNet = SafeNamespace("C_BattleNet")
-- local C_Calendar = SafeNamespace("C_Calendar")
-- local C_CampaignInfo = SafeNamespace("C_CampaignInfo")
-- local C_ChallengeMode = SafeNamespace("C_ChallengeMode")
-- local C_ChatInfo = SafeNamespace("C_ChatInfo")
-- local C_Club = SafeNamespace("C_Club")
-- local C_CreatureInfo = SafeNamespace("C_CreatureInfo")
-- local C_CurrencyInfo = SafeNamespace("C_CurrencyInfo")
-- local C_DateAndTime = SafeNamespace("C_DateAndTime")
-- local C_EquipmentSet = SafeNamespace("C_EquipmentSet")
-- local C_FriendList = SafeNamespace("C_FriendList")
-- local C_Garrison = SafeNamespace("C_Garrison")
-- local C_Heirloom = SafeNamespace("C_Heirloom")
-- local C_IslandsQueue = SafeNamespace("C_IslandsQueue")
-- local C_Item = SafeNamespace("C_Item")
-- local C_LFGList = SafeNamespace("C_LFGList")
-- local C_Map = SafeNamespace("C_Map")
-- local C_MapExplorationInfo = SafeNamespace("C_MapExplorationInfo")
-- local C_NamePlate = SafeNamespace("C_NamePlate")
-- local C_NewItems = SafeNamespace("C_NewItems")
-- local C_PaperDollInfo = SafeNamespace("C_PaperDollInfo")
-- local C_PetBattles = SafeNamespace("C_PetBattles")
-- local C_QuestLine = SafeNamespace("C_QuestLine")
-- local C_QuestLog = SafeNamespace("C_QuestLog")
-- local C_Reputation = SafeNamespace("C_Reputation")
-- local C_Scenario = SafeNamespace("C_Scenario")
-- local C_ScrappingMachineUI = SafeNamespace("C_ScrappingMachineUI")
-- local C_SocialQueue = SafeNamespace("C_SocialQueue")
-- local C_SpecializationInfo = SafeNamespace("C_SpecializationInfo")
-- local C_TaskQuest = SafeNamespace("C_TaskQuest")
-- local C_TaxiMap = SafeNamespace("C_TaxiMap")
-- local C_Texture = SafeNamespace("C_Texture")
-- local C_Timer = SafeNamespace("C_Timer")
-- local C_ToyBox = SafeNamespace("C_ToyBox")
-- local C_TradeSkillUI = SafeNamespace("C_TradeSkillUI")
-- local C_Transmog = SafeNamespace("C_Transmog")
-- local C_TransmogCollection = SafeNamespace("C_TransmogCollection")
-- local C_VignetteInfo = SafeNamespace("C_VignetteInfo")
-- local C_WowTokenPublic = SafeNamespace("C_WowTokenPublic")

local function Compat_GetContainerNumSlots(bagID)
	if GetContainerNumSlots then
		return GetContainerNumSlots(bagID)
	end

	if C_Container and C_Container.GetContainerNumSlots then
		return C_Container.GetContainerNumSlots(bagID)
	end

	return 0
end

local function Compat_GetContainerItemInfo(bagID, slotID)
	if GetContainerItemInfo then
		return GetContainerItemInfo(bagID, slotID)
	end

	if C_Container and C_Container.GetContainerItemInfo then
		local itemInfo, stackCount, isLocked, quality, isReadable, hasLoot, hyperlink, isFiltered, hasNoValue, itemID, isBound = C_Container.GetContainerItemInfo(bagID, slotID)
		if not itemInfo then return end
		if type(itemInfo) ~= "table" then
			return itemInfo, stackCount, isLocked, quality, isReadable, hasLoot, hyperlink, isFiltered, hasNoValue, itemID, isBound
		end

		return itemInfo.iconFileID or itemInfo.icon,
			itemInfo.stackCount or itemInfo.stackSize or itemInfo.count,
			itemInfo.isLocked,
			itemInfo.quality,
			itemInfo.isReadable,
			itemInfo.hasLoot,
			itemInfo.hyperlink,
			itemInfo.isFiltered,
			itemInfo.hasNoValue,
			itemInfo.itemID,
			itemInfo.isBound
	end
end

local function Compat_GetContainerItemID(bagID, slotID)
	if GetContainerItemID then
		return GetContainerItemID(bagID, slotID)
	end

	if C_Container and C_Container.GetContainerItemID then
		return C_Container.GetContainerItemID(bagID, slotID)
	end

	local _, _, _, _, _, _, _, _, _, itemID = Compat_GetContainerItemInfo(bagID, slotID)
	return itemID
end

local function Compat_GetContainerItemLink(bagID, slotID)
	if GetContainerItemLink then
		return GetContainerItemLink(bagID, slotID)
	end

	if C_Container and C_Container.GetContainerItemLink then
		return C_Container.GetContainerItemLink(bagID, slotID)
	end

	local _, _, _, _, _, _, itemLink = Compat_GetContainerItemInfo(bagID, slotID)
	return itemLink
end

local function Compat_GetContainerItemQuestInfo(bagID, slotID)
	if GetContainerItemQuestInfo then
		return GetContainerItemQuestInfo(bagID, slotID)
	end

	if C_Container and C_Container.GetContainerItemQuestInfo then
		local questInfo, questID, isActive = C_Container.GetContainerItemQuestInfo(bagID, slotID)
		if type(questInfo) == "table" then
			return questInfo.isQuestItem, questInfo.questID or questInfo.questId, questInfo.isActive
		end
		return questInfo, questID, isActive
	end
end

local function Compat_GetContainerItemEquipmentSetInfo(bagID, slotID)
	if GetContainerItemEquipmentSetInfo then
		return GetContainerItemEquipmentSetInfo(bagID, slotID)
	end

	if C_Container and C_Container.GetContainerItemEquipmentSetInfo then
		local inSet, setList = C_Container.GetContainerItemEquipmentSetInfo(bagID, slotID)
		if type(inSet) == "table" then
			return inSet.isInSet, inSet.setList
		end
		return inSet, setList
	end
end

T.AbbreviateNumbers = AbbreviateNumbers
T.abs = abs
T.AcceptQuest = AcceptQuest
T.AchievementFrame_DisplayComparison = AchievementFrame_DisplayComparison
T.AchievementFrame_LoadUI = AchievementFrame_LoadUI
T.AchievementFrame_SelectAchievement = AchievementFrame_SelectAchievement
T.ActionButton_HideOverlayGlow = ActionButton_HideOverlayGlow
T.ActionButton_ShowOverlayGlow = ActionButton_ShowOverlayGlow
T.AddQuestWatch = AddQuestWatch
T.Ambiguate = Ambiguate
T.AnimateTexCoords = AnimateTexCoords
T.assert = assert
T.AuraUtil_FindAuraByName = AuraUtil.FindAuraByName
T.AutoCastShine_AutoCastStart = AutoCastShine_AutoCastStart
T.AutoCastShine_AutoCastStop = AutoCastShine_AutoCastStop
T.BattlePetToolTip_Show = BattlePetToolTip_Show
T.bit_band = bit.band
T.bit_bor = bit.bor
T.bit_lshift = bit.lshift
T.BNConnected = BNConnected
T.BNet_GetClientTexture = BNet_GetClientTexture
T.BNet_GetValidatedCharacterName = BNet_GetValidatedCharacterName
T.BNGetFriendGameAccountInfo = BNGetFriendGameAccountInfo
T.BNGetFriendIndex = BNGetFriendIndex
T.BNGetFriendInfo = BNGetFriendInfo
T.BNGetGameAccountInfo = BNGetGameAccountInfo
T.BNGetNumFriendGameAccounts = BNGetNumFriendGameAccounts
T.BNGetNumFriends = BNGetNumFriends
T.BossBanner_BeginAnims = BossBanner_BeginAnims
T.BreakUpLargeNumbers = BreakUpLargeNumbers
T.BuyMerchantItem = BuyMerchantItem
T.BuyTrainerService = BuyTrainerService
-- Only restore wrappers that are present on MoP Classic and already used throughout KlixUI.
T.C_Map_GetBestMapForUnit = C_Map and C_Map.GetBestMapForUnit or KUI.dummy
T.C_Map_GetMapInfo = C_Map and C_Map.GetMapInfo or KUI.dummy
T.C_Map_GetPlayerMapPosition = C_Map and C_Map.GetPlayerMapPosition or KUI.dummy
T.C_Timer_After = C_Timer and C_Timer.After or KUI.dummy
T.C_Timer_NewTicker = C_Timer and C_Timer.NewTicker or KUI.dummy
T.C_Heirloom_IsItemHeirloom = C_Heirloom and C_Heirloom.IsItemHeirloom or KUI.dummy
T.C_Heirloom_PlayerHasHeirloom = C_Heirloom and C_Heirloom.PlayerHasHeirloom or KUI.dummy

T.C_PetJournal_FindPetIDByName = C_PetJournal and C_PetJournal.FindPetIDByName
T.C_PetJournal_GetPetInfoByIndex = C_PetJournal and C_PetJournal.GetPetInfoByIndex
T.C_PetJournal_GetPetInfoBySpeciesID = C_PetJournal and C_PetJournal.GetPetInfoBySpeciesID
T.C_PetJournal_GetNumCollectedInfo = C_PetJournal and C_PetJournal.GetNumCollectedInfo
T.C_PetJournal_SetAllPetSourcesChecked = C_PetJournal and C_PetJournal.SetAllPetSourcesChecked
T.C_PetJournal_SetAllPetTypesChecked = C_PetJournal and C_PetJournal.SetAllPetTypesChecked
T.C_PetJournal_SetFilterChecked = C_PetJournal and C_PetJournal.SetFilterChecked
T.CanAffordMerchantItem = CanAffordMerchantItem
T.CancelAuction = CancelAuction
T.CancelDuel = CancelDuel
T.CanCooperateWithGameAccount = CanCooperateWithGameAccount
T.CanEditOfficerNote = CanEditOfficerNote
T.CanEditPublicNote = CanEditPublicNote
T.CanInspect = CanInspect
T.CastSpellByName = CastSpellByName
T.ChatEdit_ActivateChat = ChatEdit_ActivateChat
T.ChatEdit_ChooseBoxForSend = ChatEdit_ChooseBoxForSend
T.ChatEdit_GetActiveWindow = ChatEdit_GetActiveWindow
T.ChatEdit_InsertLink = ChatEdit_InsertLink
T.ChatFrame_AddChannel = ChatFrame_AddChannel
T.ChatFrame_AddMessageEventFilter = ChatFrame_AddMessageEventFilter
T.ChatFrame_RemoveChannel = ChatFrame_RemoveChannel
T.ChatFrame_TimeBreakDown = ChatFrame_TimeBreakDown
T.CheckInteractDistance = CheckInteractDistance
T.CinematicFrame_CancelCinematic = CinematicFrame_CancelCinematic
T.ClearAchievementComparisonUnit = ClearAchievementComparisonUnit
T.ClearAllLFGDungeons = ClearAllLFGDungeons
T.ClearCursor = ClearCursor
T.CloseAllBags = CloseAllBags
T.CloseLoot = CloseLoot
T.CloseQuest = CloseQuest
T.CollectionsJournal_LoadUI = CollectionsJournal_LoadUI
T.CombatLog_Object_IsA = CombatLog_Object_IsA
T.CombatLogGetCurrentEventInfo = CombatLogGetCurrentEventInfo
T.CompleteLFGRoleCheck = CompleteLFGRoleCheck
T.CompleteQuest = CompleteQuest
T.ConfirmAcceptQuest = ConfirmAcceptQuest
T.ConvertToRaid = ConvertToRaid
T.CooldownFrame_Set = CooldownFrame_Set
T.CraftRecipe = CraftRecipe
T.CreateFrame = CreateFrame
T.CreateMacro = CreateMacro
T.date = date
T.DeleteCursorItem = DeleteCursorItem
T.DepositReagentBank = DepositReagentBank
T.DevTools_Dump = DevTools_Dump
T.difftime = difftime
T.DisableAddOn = DisableAddOn
T.DisableAllAddOns = DisableAllAddOns
T.EasyMenu = EasyMenu
T.EditMacro = EditMacro
T.EJ_GetCurrentTier = EJ_GetCurrentTier
T.EJ_GetEncounterInfoByIndex = EJ_GetEncounterInfoByIndex
T.EJ_GetInstanceByIndex = EJ_GetInstanceByIndex
T.EJ_GetNumSearchResults = EJ_GetNumSearchResults
T.EJ_GetNumTiers = EJ_GetNumTiers
T.EJ_SelectTier = EJ_SelectTier
T.EnableAddOn = EnableAddOn
T.EnableAllAddOns = EnableAllAddOns
T.EquipItemByName = EquipItemByName
T.EquipmentManager_RunAction = EquipmentManager_RunAction
T.EquipmentManager_UnequipItemInSlot = EquipmentManager_UnequipItemInSlot
T.EquipmentManager_UnpackLocation = EquipmentManager_UnpackLocation
T.error = error
T.ExpandCurrencyList = ExpandCurrencyList
T.FauxScrollFrame_GetOffset = FauxScrollFrame_GetOffset
T.FCF_GetChatWindowInfo = FCF_GetChatWindowInfo
T.FCF_GetCurrentChatFrameID = FCF_GetCurrentChatFrameID
T.FlipCameraYaw = FlipCameraYaw
T.FriendsFrame_GetLastOnline = FriendsFrame_GetLastOnline
T.FriendsFrame_UpdateFriends = FriendsFrame_UpdateFriends
T.FriendsFrameTooltip_SetLine = FriendsFrameTooltip_SetLine
T.floor = floor
T.GameMovieFinished = GameMovieFinished
T.GameTooltip = GameTooltip
T.GameTooltip_AddQuestRewardsToTooltip = GameTooltip_AddQuestRewardsToTooltip
T.GameTooltip_Hide = GameTooltip_Hide
T.GameTooltip_SetDefaultAnchor = GameTooltip_SetDefaultAnchor
T.GameTooltip_ShowCompareItem = GameTooltip_ShowCompareItem
T.Garrison_LoadUI = Garrison_LoadUI
T.GarrisonFollowerTooltip_Show = GarrisonFollowerTooltip_Show
T.GarrisonLandingPageMinimapButton_OnClick = GarrisonLandingPageMinimapButton_OnClick
T.GetAchievementInfo = GetAchievementInfo
T.GetAchievementLink = GetAchievementLink
T.GetAchievementNumCriteria = GetAchievementNumCriteria
T.GetActionInfo = GetActionInfo
T.GetActionTexture = GetActionTexture
T.GetActiveSpecGroup = GetActiveSpecGroup
T.GetActiveTitle = GetActiveTitle
T.GetAddOnCPUUsage = GetAddOnCPUUsage
T.GetAddOnEnableState = GetAddOnEnableState
T.GetAddOnDependencies = GetAddOnDependencies
T.GetAddOnInfo = GetAddOnInfo
T.GetAddOnMemoryUsage = GetAddOnMemoryUsage
T.GetAddOnMetadata = GetAddOnMetadata
T.GetAddOnOptionalDependencies = GetAddOnOptionalDependencies
T.GetArchaeologyRaceInfoByID = GetArchaeologyRaceInfoByID
T.GetAuctionItemInfo = GetAuctionItemInfo
T.GetAuctionItemLink = GetAuctionItemLink
T.GetAutoCompleteRealms = GetAutoCompleteRealms
T.GetAutoQuestPopUp = GetAutoQuestPopUp
T.GetAvailableBandwidth = GetAvailableBandwidth
T.GetAverageItemLevel = GetAverageItemLevel
T.GetAvoidance = GetAvoidance
T.GetBackpackCurrencyInfo = GetBackpackCurrencyInfo
T.GetBattlefieldScore = GetBattlefieldScore
T.GetBattlefieldStatus = GetBattlefieldStatus
T.GetBindingKey = GetBindingKey
T.GetBindingText = GetBindingText
T.GetBindLocation = GetBindLocation
T.GetBlockChance = GetBlockChance
T.GetBuildInfo = GetBuildInfo
T.GetBuybackItemLink = GetBuybackItemLink
T.GetCameraZoom = GetCameraZoom
T.GetChannelList = GetChannelList
T.GetChannelName = GetChannelName
T.GetChatWindowInfo = GetChatWindowInfo
T.GetChatWindowSavedPosition = GetChatWindowSavedPosition
T.GetClampedCurrentExpansionLevel = GetClampedCurrentExpansionLevel
T.GetClassInfo = GetClassInfo
T.GetCombatRating = GetCombatRating
T.GetCombatRatingBonus = GetCombatRatingBonus
T.GetCombatRatingBonusForCombatRatingValue = GetCombatRatingBonusForCombatRatingValue
T.GetComparisonAchievementPoints = GetComparisonAchievementPoints
T.GetComparisonStatistic = GetComparisonStatistic
T.GetContainerItemEquipmentSetInfo = Compat_GetContainerItemEquipmentSetInfo
T.GetContainerItemID = Compat_GetContainerItemID
T.GetContainerItemInfo = Compat_GetContainerItemInfo
T.GetContainerItemLink = Compat_GetContainerItemLink
T.GetContainerItemQuestInfo = Compat_GetContainerItemQuestInfo
T.GetContainerNumSlots = Compat_GetContainerNumSlots
T.GetCritChance = GetCritChance
T.GetCritChanceProvidesParryEffect = GetCritChanceProvidesParryEffect
T.GetCurrencyInfo = C_CurrencyInfo.GetCurrencyInfo
T.GetCurrencyListInfo = C_CurrencyInfo.GetCurrencyListInfo
T.GetCurrencyListSize = C_CurrencyInfo.GetCurrencyListSize
T.GetCurrentRegion = GetCurrentRegion
T.GetCurrentTitle = GetCurrentTitle
T.GetCursorInfo = GetCursorInfo
T.GetCursorPosition = GetCursorPosition
T.GetCVar     = C_CVar and C_CVar.GetCVar     or GetCVar
T.GetCVarBool = C_CVar and C_CVar.GetCVarBool or GetCVarBool
T.GetDetailedItemLevelInfo = GetDetailedItemLevelInfo
T.GetDifficultyInfo = GetDifficultyInfo
T.GetDistanceSqToQuest = GetDistanceSqToQuest
T.GetDodgeChance = GetDodgeChance
T.GetDownloadedPercentage = GetDownloadedPercentage
T.GetDungeonDifficultyID = GetDungeonDifficultyID
T.GetExpansionDisplayInfo = GetExpansionDisplayInfo
T.GetExpansionLevel = GetExpansionLevel
T.GetFactionInfo = GetFactionInfo
T.GetFactionInfoByID = GetFactionInfoByID
T.GetFilteredAchievementID = GetFilteredAchievementID
T.GetFramerate = GetFramerate
T.GetFriendInfo = GetFriendInfo
T.GetFriendshipReputation = GetFriendshipReputation
T.GetFriendshipReputationRanks = GetFriendshipReputationRanks
T.GetGameTime = GetGameTime
T.getglobal = getglobal
T.GetGossipActiveQuests = GetGossipActiveQuests
T.GetGossipAvailableQuests = GetGossipAvailableQuests
T.GetGuildInfo = GetGuildInfo
T.GetGuildLogoInfo = GetGuildLogoInfo
T.GetGuildRosterInfo = GetGuildRosterInfo
T.GetGuildRosterMOTD = GetGuildRosterMOTD
T.GetGuildTradeSkillInfo = GetGuildTradeSkillInfo
T.GetHaste = GetHaste
T.GetHitModifier = GetHitModifier
T.GetInboxHeaderInfo = GetInboxHeaderInfo
T.GetInboxInvoiceInfo = GetInboxInvoiceInfo
T.GetInboxNumItems = GetInboxNumItems
T.GetInboxText = GetInboxText
T.GetInspectArenaData = GetInspectArenaData
T.GetInspectGuildInfo = GetInspectGuildInfo
T.GetInspectHonorData = GetInspectHonorData
T.GetInspectRatedBGData = GetInspectRatedBGData
T.GetInspectSpecialization = GetInspectSpecialization
T.GetInstanceInfo = GetInstanceInfo
T.GetInventoryItemCooldown = GetInventoryItemCooldown
T.GetInventoryItemDurability = GetInventoryItemDurability
T.GetInventoryItemID = GetInventoryItemID
T.GetInventoryItemLink = GetInventoryItemLink
T.GetInventoryItemQuality = GetInventoryItemQuality
T.GetInventoryItemTexture = GetInventoryItemTexture
T.GetInventorySlotInfo = GetInventorySlotInfo
T.GetItemClassInfo = GetItemClassInfo
T.GetItemCooldown = function(...)
	-- Plain GetItemCooldown global is gone on newer clients; itemID-based lookup
	-- moved to C_Container.GetItemCooldown (same args/returns as the old global).
	local fn = GetItemCooldown or (C_Container and C_Container.GetItemCooldown)
	if fn then
		local start, duration, enable = fn(...)
		return start or 0, duration or 0, enable or 0
	end

	return 0, 0, 0
end
T.GetItemCount = GetItemCount
T.GetItemGem = GetItemGem
T.GetItemIcon = GetItemIcon
T.GetItemInfo = GetItemInfo
T.GetItemInfoFromHyperlink = GetItemInfoFromHyperlink
T.GetItemInfoInstant = GetItemInfoInstant
T.GetItemLevelColor = GetItemLevelColor
T.GetItemQualityColor = GetItemQualityColor
T.GetItemSpell = GetItemSpell or (rawget(_G, "C_Item") and rawget(_G, "C_Item").GetItemSpell)
T.GetLatestThreeSenders = GetLatestThreeSenders
T.GetLFGCompletionReward = GetLFGCompletionReward
T.GetLFGCompletionRewardItem = GetLFGCompletionRewardItem
T.GetLFGDungeonEncounterInfo = GetLFGDungeonEncounterInfo
T.GetLFGDungeonInfo = GetLFGDungeonInfo
T.GetLFGDungeonNumEncounters = GetLFGDungeonNumEncounters
T.GetLFGDungeonRewardInfo = GetLFGDungeonRewardInfo
T.GetLFGDungeonRewards = GetLFGDungeonRewards
T.GetLFGDungeonShortageRewardInfo = GetLFGDungeonShortageRewardInfo
T.GetLFGRandomDungeonInfo = GetLFGRandomDungeonInfo
T.GetLFGRoleShortageRewards = GetLFGRoleShortageRewards
T.GetLifesteal = GetLifesteal
T.GetLocale = GetLocale
T.GetLootMethod = GetLootMethod
T.GetLootRollItemInfo = GetLootRollItemInfo
T.GetLootRollItemLink = GetLootRollItemLink
T.GetLootSlotInfo = GetLootSlotInfo
T.GetLootSlotLink = GetLootSlotLink
T.GetLootSlotType = GetLootSlotType
T.GetLootSpecialization = GetLootSpecialization
T.GetLootThreshold = GetLootThreshold
T.GetMacroInfo = GetMacroInfo
T.GetManaRegen = GetManaRegen
T.GetMapInfo = GetMapInfo
T.GetMasteryEffect = GetMasteryEffect
T.GetMaxBattlefieldID = GetMaxBattlefieldID
T.GetMaxLevelForExpansionLevel = GetMaxLevelForExpansionLevel
T.GetMaxPlayerHonorLevel = GetMaxPlayerHonorLevel
T.GetMaxPlayerLevel = GetMaxPlayerLevel
T.GetMaxTalentTier = GetMaxTalentTier
T.GetMeleeHaste = GetMeleeHaste
T.GetMerchantItemID = GetMerchantItemID
T.GetMerchantItemInfo = GetMerchantItemInfo
T.GetMerchantItemLink = GetMerchantItemLink
T.GetMerchantItemMaxStack = GetMerchantItemMaxStack
T.GetMerchantNumItems = GetMerchantNumItems
T.getmetatable = getmetatable
T.GetMinimapZoneText = GetMinimapZoneText
T.GetModResilienceDamageReduction = GetModResilienceDamageReduction
T.GetMoney = GetMoney
T.GetMoneyString = GetMoneyString
T.GetMouseFocus = GetMouseFocus or function()
	return E.GetMouseFocus and E:GetMouseFocus()
end
T.GetNetIpTypes = GetNetIpTypes
T.GetNetStats = GetNetStats
T.C_QuestLog_GetNextWaypointText = C_QuestLog.GetNextWaypointText
T.GetNumActiveQuests = GetNumActiveQuests
T.GetNumAuctionItems = GetNumAuctionItems
T.GetNumAddOns = GetNumAddOns
T.GetNumAutoQuestPopUps = GetNumAutoQuestPopUps
T.GetNumAvailableQuests = GetNumAvailableQuests
T.GetNumBattlefieldScores = GetNumBattlefieldScores
T.GetNumBuybackItems = GetNumBuybackItems
T.GetNumClasses = GetNumClasses
T.GetNumFactions = GetNumFactions
T.GetNumFilteredAchievements = GetNumFilteredAchievements
T.GetNumFriends = GetNumFriends
T.GetNumGossipActiveQuests = GetNumGossipActiveQuests
T.GetNumGossipAvailableQuests = GetNumGossipAvailableQuests
T.GetNumGossipOptions = GetNumGossipOptions
T.GetNumGroupMembers = GetNumGroupMembers
T.GetNumGuildMembers = GetNumGuildMembers
T.GetNumLootItems = GetNumLootItems
T.GetNumMacros = GetNumMacros
T.C_QuestLog_GetNumQuestLogEntries = C_QuestLog.GetNumQuestLogEntries
T.C_QuestLog_GetMaxNumQuestsCanAccept = C_QuestLog.GetMaxNumQuestsCanAccept
T.GetNumQuestChoices = GetNumQuestChoices
T.GetNumQuestItems = GetNumQuestItems
T.GetNumQuestLeaderBoards = GetNumQuestLeaderBoards
T.GetNumQuestLogEntries = C_QuestLog.GetNumQuestLogEntries
T.GetNumQuestLogRewardCurrencies = GetNumQuestLogRewardCurrencies
T.GetNumQuestLogRewardSpells = GetNumQuestLogRewardSpells
T.GetNumQuestWatches = GetNumQuestWatches
T.GetNumRandomDungeons = GetNumRandomDungeons
T.GetNumRewardSpells = GetNumRewardSpells
T.GetNumRFDungeons = GetNumRFDungeons
T.GetNumSavedInstances = GetNumSavedInstances
T.GetNumSavedWorldBosses = GetNumSavedWorldBosses
T.GetNumSpecGroups = GetNumSpecGroups
T.GetNumSpecializations = GetNumSpecializations
T.GetNumSpecializationsForClassID = GetNumSpecializationsForClassID
T.GetNumSubgroupMembers = GetNumSubgroupMembers
T.GetNumTitles = GetNumTitles
T.GetNumTrackingTypes = GetNumTrackingTypes
T.GetNumTrainerServices = GetNumTrainerServices
T.GetNumWatchedTokens = GetNumWatchedTokens
T.GetNumWorldPVPAreas = GetNumWorldPVPAreas
T.GetOverrideBarIndex = GetOverrideBarIndex
T.GetParryChance = GetParryChance
T.GetPersonalRatedInfo = GetPersonalRatedInfo
T.GetPetActionInfo = GetPetActionInfo
T.GetPetActionCooldown = GetPetActionCooldown
T.GetPlayerInfoByGUID = GetPlayerInfoByGUID
T.GetPlayerTradeMoney = GetPlayerTradeMoney
T.GetProfessionInfo = GetProfessionInfo
T.GetProfessions = GetProfessions
T.GetPVPLifetimeStats = GetPVPLifetimeStats
T.GetQuestDifficultyColor = GetQuestDifficultyColor
T.GetQuestItemInfo = GetQuestItemInfo
T.GetQuestItemLink = GetQuestItemLink
T.GetQuestLink = GetQuestLink
T.GetQuestLogCompletionText = GetQuestLogCompletionText
T.GetQuestLogIndexByID = GetQuestLogIndexByID
T.GetQuestLogLeaderBoard = GetQuestLogLeaderBoard
T.GetQuestLogSelection = GetQuestLogSelection
T.GetQuestLogSpecialItemCooldown = GetQuestLogSpecialItemCooldown
T.GetQuestLogSpecialItemInfo = GetQuestLogSpecialItemInfo
T.GetQuestLogRewardInfo = GetQuestLogRewardInfo
T.GetQuestLogRewardMoney = GetQuestLogRewardMoney
T.GetQuestLogRewardXP = GetQuestLogRewardXP
T.GetQuestLogTitle = GetQuestLogTitle
T.GetQuestObjectiveInfo = GetQuestObjectiveInfo
T.GetQuestReward = GetQuestReward
T.GetQuestLogRewardCurrencyInfo = GetQuestLogRewardCurrencyInfo
T.GetQuestTagInfo = C_QuestLog.GetQuestTagInfo
T.GetQuestUiMapID = GetQuestUiMapID
T.GetQuestWatchInfo = GetQuestWatchInfo
T.GetRaidDifficultyID = GetRaidDifficultyID
T.GetRaidRosterInfo = GetRaidRosterInfo
T.GetRaidTargetIndex = GetRaidTargetIndex
T.GetRangedCritChance = GetRangedCritChance
T.GetRangedHaste = GetRangedHaste
T.GetRealmName = GetRealmName
T.GetRealZoneText = GetRealZoneText
T.GetRecipeInfo = GetRecipeInfo
T.GetRFDungeonInfo = GetRFDungeonInfo
T.GetSavedInstanceInfo = GetSavedInstanceInfo
T.GetSavedWorldBossInfo = GetSavedWorldBossInfo
T.GetScreenHeight = GetScreenHeight
T.GetScreenWidth = GetScreenWidth
T.GetSelectedFaction = GetSelectedFaction
T.GetShapeshiftForm = GetShapeshiftForm
T.GetSortedSelfResurrectOptions = GetSortedSelfResurrectOptions
T.GetSpecialization = GetSpecialization
T.GetSpecializationInfo = GetSpecializationInfo
T.GetSpecializationInfoByID = GetSpecializationInfoByID
T.GetSpecializationInfoForClassID = GetSpecializationInfoForClassID
T.GetSpecializationRole = GetSpecializationRole
T.GetSpecializationRoleByID = GetSpecializationRoleByID
T.GetSpecializationSpells = GetSpecializationSpells
T.GetSpellAvailableLevel = GetSpellAvailableLevel
T.GetSpellBonusDamage = GetSpellBonusDamage
T.GetSpellBonusHealing = GetSpellBonusHealing
T.GetSpellBookItemInfo = GetSpellBookItemInfo
T.GetSpellCharges  = C_Spell and C_Spell.GetSpellCharges  or GetSpellCharges
T.GetSpellCooldown = C_Spell and C_Spell.GetSpellCooldown or GetSpellCooldown
T.GetSpellCritChance = GetSpellCritChance
T.GetSpellHitModifier = GetSpellHitModifier
if C_Spell and C_Spell.GetSpellInfo then
	T.GetSpellInfo = function(id)
		local info = C_Spell.GetSpellInfo(id)
		if info then
			return info.name, info.subName or "", info.iconID, info.castTime, info.minRange, info.maxRange, info.spellID or id, info.originalIconID
		end
	end
else
	T.GetSpellInfo = GetSpellInfo
end
T.GetSpellLink = GetSpellLink
T.GetSpellRank = GetSpellRank
T.GetSpellTexture  = C_Spell and C_Spell.GetSpellTexture  or GetSpellTexture
T.GetStatistic = GetStatistic
T.GetSubZoneText = GetSubZoneText
T.GetTalentInfo = GetTalentInfo
T.GetTalentInfoByID = GetTalentInfoByID
T.GetTalentLink = GetTalentLink
T.GetTargetTradeMoney = GetTargetTradeMoney
T.GetTaskInfo = GetTaskInfo
T.GetThreatStatusColor = GetThreatStatusColor
T.GetTime = GetTime
T.GetTitleName = GetTitleName
T.GetTrackingInfo = GetTrackingInfo
T.GetTradeSkillLine = GetTradeSkillLine
T.GetTradeSkillNumReagents = GetTradeSkillNumReagents
T.GetTradeSkillReagentInfo = GetTradeSkillReagentInfo
T.GetTradeTargetItemLink = GetTradeTargetItemLink
T.GetTrainerServiceInfo = GetTrainerServiceInfo
T.GetUnitName = GetUnitName
T.GetVehicleBarIndex = GetVehicleBarIndex
T.GetVersatilityBonus = GetVersatilityBonus
T.GetWatchedFactionInfo = GetWatchedFactionInfo
T.GetWeaponEnchantInfo = GetWeaponEnchantInfo
T.GetWhoInfo = GetWhoInfo
T.GetWorldPVPAreaInfo = GetWorldPVPAreaInfo
T.GetXPExhaustion = GetXPExhaustion
T.GetZonePVPInfo = GetZonePVPInfo
T.GetZoneText = GetZoneText
T.GroupFinderFrame_ShowGroupFrame = GroupFinderFrame_ShowGroupFrame
T.GroupLootContainer_AddFrame = GroupLootContainer_AddFrame
T.GroupLootContainer_RemoveFrame = GroupLootContainer_RemoveFrame
T.GuildControlGetNumRanks = GuildControlGetNumRanks
T.GuildControlGetRankName = GuildControlGetRankName
T.GuildInvite = GuildInvite
T.GuildRoster = GuildRoster
T.HasExtraActionBar = HasExtraActionBar
T.HasInspectHonorData = HasInspectHonorData
T.HasNewMail = HasNewMail
T.HaveQuestRewardData = HaveQuestRewardData
T.HideUIPanel = HideUIPanel
T.hooksecurefunc = hooksecurefunc
T.HybridScrollFrame_GetOffset = HybridScrollFrame_GetOffset
T.InCombatLockdown = InCombatLockdown
T.InviteToGroup = InviteToGroup
T.InviteUnit = InviteUnit
T.ipairs = ipairs
T.IsAddOnLoaded = IsAddOnLoaded
T.IsAltKeyDown = IsAltKeyDown
T.IsArtifactPowerItem = IsArtifactPowerItem
T.IsArtifactRelicItem = IsArtifactRelicItem
T.IsAvailableQuestTrivial = IsAvailableQuestTrivial
T.IsContainerItemAnUpgrade = IsContainerItemAnUpgrade
T.IsControlKeyDown = IsControlKeyDown
T.IsCurrentSpell = IsCurrentSpell
T.IsDressableItem = IsDressableItem
T.IsEquippableItem = IsEquippableItem
T.IsEveryoneAssistant = IsEveryoneAssistant
T.IsFactionInactive = IsFactionInactive
T.IsIndoors = IsIndoors
T.IsInGroup = IsInGroup
T.IsInGuild = IsInGuild
T.IsInInstance = IsInInstance
T.IsInLFGDungeon = IsInLFGDungeon
T.IsInRaid = IsInRaid
T.IsItemInRange = IsItemInRange
T.IsLFGDungeonJoinable = IsLFGDungeonJoinable
T.IsLoggedIn = IsLoggedIn
T.IsModifiedClick = IsModifiedClick
T.IsModifierKeyDown = IsModifierKeyDown
T.IsMounted = IsMounted
T.IsMouseButtonDown = IsMouseButtonDown
T.IsMouselooking = IsMouselooking
T.IsPartyLFG = IsPartyLFG
T.IsPassiveSpell = IsPassiveSpell
T.IsQuestBounty = IsQuestBounty
T.IsQuestFlaggedCompleted = IsQuestFlaggedCompleted
T.IsQuestTask = IsQuestTask
T.IsQuestWatched = IsQuestWatched
T.IsResting = IsResting
T.IsShiftKeyDown = IsShiftKeyDown
T.IsSpellKnown = IsSpellKnown
T.IsSpellOverlayed = IsSpellOverlayed
T.IsTitleKnown = IsTitleKnown
T.IsTradeSkillGuild = IsTradeSkillGuild
T.IsTradeSkillLinked = IsTradeSkillLinked
T.IsUsableItem = IsUsableItem
T.IsUsableSpell = IsUsableSpell
T.IsXPUserDisabled = IsXPUserDisabled
T.ItemHasRange = ItemHasRange
T.JoinLFG = JoinLFG
T.JoinTemporaryChannel = JoinTemporaryChannel
T.LE_TRANSMOG_TYPE_APPEARANCE = LE_TRANSMOG_TYPE_APPEARANCE
T.LE_TRANSMOG_TYPE_ILLUSION = LE_TRANSMOG_TYPE_ILLUSION
T.LearnPvpTalent = LearnPvpTalent
T.LearnTalent = LearnTalent
T.LFDQueueFrame_SetType = LFDQueueFrame_SetType
T.LFGListSearchEntryUtil_GetFriendList = LFGListSearchEntryUtil_GetFriendList
T.LFGListUtil_GetQuestDescription = LFGListUtil_GetQuestDescription
T.LoadAddOn = LoadAddOn
T.LoggingCombat = LoggingCombat
T.LootSlot = LootSlot
T.Mastery_OnEnter = Mastery_OnEnter
T.math_abs = math.abs
T.math_ceil = math.ceil
T.math_floor = math.floor
T.math_max = math.max
T.math_min = math.min
T.math_modf = math.modf
T.math_pi = math.pi
T.math_pow = math.pow
T.math_random = math.random
T.math_sqrt = math.sqrt
T.MerchantFrame_UpdateAltCurrency = MerchantFrame_UpdateAltCurrency
T.MerchantFrameItem_UpdateQuality = MerchantFrameItem_UpdateQuality
T.MinimapMailFrameUpdate = MinimapMailFrameUpdate
T.mod = mod
T.MoneyFrame_SetMaxDisplayWidth = MoneyFrame_SetMaxDisplayWidth
T.MoneyFrame_Update = MoneyFrame_Update
T.MouselookStop = MouselookStop
T.MovementSpeed_OnEnter = MovementSpeed_OnEnter
T.MovementSpeed_OnUpdate = MovementSpeed_OnUpdate
T.next = next
T.ObjectiveTracker_Collapse = ObjectiveTracker_Collapse
T.ObjectiveTracker_Expand = ObjectiveTracker_Expand
T.ObjectiveTracker_Update = ObjectiveTracker_Update
T.OpenAllBags = OpenAllBags
T.OpenAzeriteEmpoweredItemUIFromItemLocation = OpenAzeriteEmpoweredItemUIFromItemLocation
T.pairs = pairs
T.PanelTemplates_DeselectTab = PanelTemplates_DeselectTab
T.PanelTemplates_GetSelectedTab = PanelTemplates_GetSelectedTab
T.PanelTemplates_TabResize = PanelTemplates_TabResize
T.PaperDollFrame_SetItemLevel = PaperDollFrame_SetItemLevel
T.PaperDollFrame_SetLabelAndText = PaperDollFrame_SetLabelAndText
T.pcall = pcall
T.PickupContainerItem = PickupContainerItem or (C_Container and C_Container.PickupContainerItem) or KUI.dummy
T.PickupMacro = PickupMacro
T.PlaceAuctionBid = PlaceAuctionBid
T.PlayerHasToy = PlayerHasToy
T.PlaySound = PlaySound
T.PlaySoundFile = PlaySoundFile
T.print = print
T.PVEFrame_ToggleFrame = PVEFrame_ToggleFrame
T.QuestFlagsPVP = QuestFlagsPVP
T.QuestGetAutoAccept = QuestGetAutoAccept
T.QuestHasPOIInfo = QuestHasPOIInfo
T.QuestInfo_GetRewardButton = QuestInfo_GetRewardButton
T.QuestIsFromAreaTrigger = QuestIsFromAreaTrigger
T.QuestUtils_IsQuestWorldQuest = QuestUtils_IsQuestWorldQuest
T.QueueStatusMinimapButton_OnLeave = QueueStatusMinimapButton_OnLeave
T.RaiseFrameLevel = RaiseFrameLevel
T.random = random
T.RegisterStateDriver = RegisterStateDriver
T.ReloadUI = ReloadUI
T.RemoveFriend = RemoveFriend
T.RemoveQuestWatch = RemoveQuestWatch
T.RepopMe = RepopMe
T.RequestRaidInfo = RequestRaidInfo
T.RequestTimePlayed = RequestTimePlayed
T.Screenshot = Screenshot
T.SearchLFGGetResults = SearchLFGGetResults
T.SecondsToTime = SecondsToTime
T.select = select
T.SelectActiveQuest = SelectActiveQuest
T.SelectAvailableQuest = SelectAvailableQuest
T.SelectGossipActiveQuest = SelectGossipActiveQuest
T.SelectGossipAvailableQuest = SelectGossipAvailableQuest
T.SelectGossipOption = SelectGossipOption
T.SendChatMessage = SendChatMessage
T.SendWho = SendWho
T.SetAchievementComparisonUnit = SetAchievementComparisonUnit
T.SetAchievementSearchString = SetAchievementSearchString
T.SetCurrentTitle = SetCurrentTitle
T.SetCVar     = C_CVar and C_CVar.SetCVar     or SetCVar
T.SetItemButtonCount = SetItemButtonCount
T.SetItemButtonNameFrameVertexColor = SetItemButtonNameFrameVertexColor
T.SetItemButtonNormalTextureVertexColor = SetItemButtonNormalTextureVertexColor
T.SetItemButtonSlotVertexColor = SetItemButtonSlotVertexColor
T.SetItemButtonStock = SetItemButtonStock
T.SetItemButtonTexture = SetItemButtonTexture
T.SetItemButtonTextureVertexColor = SetItemButtonTextureVertexColor
T.SetItemRef = SetItemRef
T.SetLFGDungeon = SetLFGDungeon
T.SetLFGRoles = SetLFGRoles
T.SetLootSpecialization = SetLootSpecialization
T.setmetatable = setmetatable
T.SetMoneyFrameColor = SetMoneyFrameColor
T.SetOverrideBindingClick = SetOverrideBindingClick
T.SetPortraitToTexture = SetPortraitToTexture
T.SetRaidTarget = SetRaidTarget
T.SetSpecialization = SetSpecialization
T.SetWatchedFactionIndex = SetWatchedFactionIndex
T.ShouldShowILevelInFollowerList = ShouldShowILevelInFollowerList
T.ShowFriends = ShowFriends
T.ShowGarrisonLandingPage = ShowGarrisonLandingPage
T.ShowQuestComplete = ShowQuestComplete
T.ShowUIPanel = ShowUIPanel
T.SlashCmdList = SlashCmdList
T.SocialQueueUtil_GetQueueName = SocialQueueUtil_GetQueueName
T.SocialQueueUtil_GetRelationshipInfo = SocialQueueUtil_GetRelationshipInfo
T.SocketInventoryItem = SocketInventoryItem
T.SortQuestWatches = SortQuestWatches
T.SpellBook_GetSpellBookSlot = SpellBook_GetSpellBookSlot
T.StaticPopup_Hide = StaticPopup_Hide
T.StaticPopup_Show = StaticPopup_Show
T.StaticPopupSpecial_Hide = StaticPopupSpecial_Hide
T.string_byte = string.byte
T.string_find = string.find
T.string_format = string.format
T.string_gmatch = string.gmatch
T.string_gsub = string.gsub
T.string_join = string.join
T.string_len = string.len
T.string_lower = string.lower
T.string_match = string.match
T.string_split = string.split
T.string_sub = string.sub
T.string_upper = string.upper
T.string_utf8sub = string.utf8sub
T.strtrim = strtrim
T.table_concat = table.concat
T.table_copy = table.copy
T.table_getn = table.getn
T.table_insert = table.insert
T.table_maxn = table.maxn
T.table_sort = table.sort
T.table_wipe = table.wipe
T.table_remove = table.remove
T.TakeTaxiNode = TakeTaxiNode
T.TalentFrame_LoadUI = TalentFrame_LoadUI
T.TalkingHead_LoadUI = TalkingHead_LoadUI
T.tContains = tContains
T.time = time
T.ToggleAllBags = ToggleAllBags
T.ToggleCharacter = ToggleCharacter
T.ToggleCommunitiesFrame = ToggleCommunitiesFrame
T.ToggleDropDownMenu = ToggleDropDownMenu
T.ToggleFrame = ToggleFrame
T.ToggleGuildFrame = ToggleGuildFrame
T.ToggleTalentFrame = ToggleTalentFrame
T.ToggleWorldMap = ToggleWorldMap
T.TokenFrame_Update = TokenFrame_Update
T.TopBannerManager_Show = TopBannerManager_Show
T.tonumber = tonumber
T.tostring = tostring
T.type = type
T.UIDropDownMenu_AddButton = UIDropDownMenu_AddButton
T.UIDropDownMenu_AddSeparator = UIDropDownMenu_AddSeparator
T.UIDropDownMenu_CreateInfo = UIDropDownMenu_CreateInfo
T.UIDropDownMenu_Initialize = UIDropDownMenu_Initialize
T.UIDropDownMenu_SetSelectedID = UIDropDownMenu_SetSelectedID
T.UIErrorsFrame = UIErrorsFrame
T.UIFrameFade = UIFrameFade
T.UIFrameFadeIn = UIFrameFadeIn
T.UIFrameFadeOut = UIFrameFadeOut
T.UIParent = UIParent
T.UIParentLoadAddOn = UIParentLoadAddOn
T.UISpecialFrames = UISpecialFrames
T.UnitAffectingCombat = UnitAffectingCombat
T.UnitArmor = UnitArmor
T.UnitAttackPower = UnitAttackPower
T.UnitAttackSpeed = UnitAttackSpeed
T.UnitAura = UnitAura
T.UnitBattlePetSpeciesID = UnitBattlePetSpeciesID
T.UnitBattlePetType = UnitBattlePetType
T.UnitBuff = UnitBuff
T.UnitCanAttack = UnitCanAttack
T.UnitCastingInfo = UnitCastingInfo
T.UnitChannelInfo = UnitChannelInfo
T.UnitClass = UnitClass
T.UnitClassification = UnitClassification
T.UnitDamage = UnitDamage
T.UnitDebuff = UnitDebuff
T.UnitDetailedThreatSituation = UnitDetailedThreatSituation
T.UnitExists = UnitExists
T.UnitFactionGroup = UnitFactionGroup
T.UnitFullName = UnitFullName
T.UnitGroupRolesAssigned = UnitGroupRolesAssigned
T.UnitGUID = UnitGUID
T.UnitHealth = UnitHealth
T.UnitHealthMax = UnitHealthMax
T.UnitHonor = UnitHonor
T.UnitHonorLevel = UnitHonorLevel
T.UnitHonorMax = UnitHonorMax
T.UnitInParty = UnitInParty
T.UnitInRaid = UnitInRaid
T.UnitInVehicle = UnitInVehicle
T.UnitIsAFK = UnitIsAFK
T.UnitIsBattlePet = UnitIsBattlePet
T.UnitIsConnected = UnitIsConnected
T.UnitIsDead = UnitIsDead
T.UnitIsDeadOrGhost = UnitIsDeadOrGhost
T.UnitIsDND = UnitIsDND
T.UnitIsGhost = UnitIsGhost
T.UnitIsGroupAssistant = UnitIsGroupAssistant
T.UnitIsGroupLeader = UnitIsGroupLeader
T.UnitIsInMyGuild = UnitIsInMyGuild
T.UnitIsPlayer = UnitIsPlayer
T.UnitIsTapDenied = UnitIsTapDenied
T.UnitIsUnit = UnitIsUnit
T.UnitIsVisible = UnitIsVisible
T.UnitLevel = UnitLevel
T.UnitName = UnitName
T.UnitOnTaxi = UnitOnTaxi
T.UnitPlayerOrPetInParty = UnitPlayerOrPetInParty
T.UnitPlayerOrPetInRaid = UnitPlayerOrPetInRaid
T.UnitPowerBarAltStatus_UpdateText = UnitPowerBarAltStatus_UpdateText
T.UnitPower = UnitPower
T.UnitPowerMax = UnitPowerMax
T.UnitPowerType = UnitPowerType
T.UnitPVPName = UnitPVPName
T.UnitRace = UnitRace
T.UnitRangedAttackPower = UnitRangedAttackPower
T.UnitRangedDamage = UnitRangedDamage
T.UnitReaction = UnitReaction
T.UnitRealmRelationship = UnitRealmRelationship
T.UnitSetRole = UnitSetRole
T.UnitSex = UnitSex
T.UnitSpellHaste = UnitSpellHaste
T.UnitStat = UnitStat
T.UnitVehicleSeatCount = UnitVehicleSeatCount
T.UnitXP = UnitXP
T.UnitXPMax = UnitXPMax
T.unpack = unpack
T.UnregisterStateDriver = UnregisterStateDriver
T.UpdateAddOnCPUUsage = UpdateAddOnCPUUsage
T.UpdateAddOnMemoryUsage = UpdateAddOnMemoryUsage
T.UseContainerItem = UseContainerItem or (C_Container and C_Container.UseContainerItem) or KUI.dummy
T.UseItemByName = UseItemByName
T.VehicleSeatIndicator_SetUpVehicle = VehicleSeatIndicator_SetUpVehicle
T.WardrobeCollectionFrame_OpenTransmogLink = WardrobeCollectionFrame_OpenTransmogLink
T.WrapTextInColorCode = WrapTextInColorCode

T.GetSpell = function(id)
	local name = T.GetSpellInfo(id)
	return name
end

T.SafeHookScript = function (frame, handlername, newscript)
	local oldValue = frame:GetScript(handlername)
	frame:SetScript(handlername, newscript)
	return oldValue
end

KUI.IsDev = {
	["Klix"] = true,
	["Klixi"] = true,
	["Klixx"] = true,
	["Klixy"] = true,
	["Tricklez"] = true,
}

KUI.IsDevRealm = {
	["Twisting Nether"] = true,
}

function KUI:IsDeveloper()
	return KUI.IsDev[E.myname] or false
end

function KUI:IsDeveloperRealm()
	return KUI.IsDevRealm[E.myrealm] or false
end

function KUI:Print(...)
	T.print("|cfff960d9".."KlixUI:|r", ...)
end

function KUI:PrintURL(url) -- Credits: Azilroka
	return T.string_format("|cfff960d9[|Hurl:%s|h%s|h]|r", url, url)
end

function KUI:ErrorPrint(msg)
	T.print("|cffFF0000KlixUI Error:|r", msg)
end

local combatQueue = {}
local combatQueueFrame
-- FIX [DRIP]: Drain-Variablen fuer frame-verteilte Queue-Abarbeitung.
-- Statt alle Funktionen auf einmal abzufeuern (FPS-Spike), laeuft jeweils
-- eine Funktion pro Frame. So wird der FPS-Drop beim Verlassen des Kampfes verteilt.
local combatDrainQueue = {}
local combatDrainIndex = 1
local combatDrainFrame

function KUI:DebugProtectedAction(...)
	if not self.DebugProtectedActions then return end
	self:Print(...)
end

function KUI:IsFrameSafe(frame)
	if not frame then
		self.LastUnsafeFrame = "nil"
		self.LastUnsafeFrameReason = "missing"
		return false
	end

	local name = frame.GetName and frame:GetName()
	if self:IsUnsafeUnitFrame(frame) then
		self.LastUnsafeFrame = name or tostring(frame)
		self.LastUnsafeFrameReason = "unsafe-unit-frame"
		return false
	end

	if frame.IsForbidden and frame:IsForbidden() then
		self.LastUnsafeFrame = name or tostring(frame)
		self.LastUnsafeFrameReason = "forbidden"
		return false
	end

	return true
end

function KUI:IsUnsafeUnitFrame(frame)
	if not frame then return true end

	local name = frame.GetName and frame:GetName()
	if name then
		if name:find("^PartyMemberFrame") then return true end
		if name:find("^Cell") then return true end
		if name:find("^CompactRaidFrame") then return true end
		if name:find("^CompactPartyFrame") then return true end
		if name:find("^CompactUnitFrame") then return true end
		if name == "CompactRaidFrameManager" or name == "CompactRaidFrameContainer" then return true end
		if name == "RaidFrame" or name == "RaidParentFrame" then return true end
	end

	if frame.IsForbidden and frame:IsForbidden() then return true end
	return false
end

-- FIX [DRIP]: Verarbeitet eine Funktion aus dem Drain-Queue pro Frame.
-- Bei Kampf-Wiedereintritt: verbleibende Eintraege zurueck in combatQueue.
-- combatQueueFrame ist persistent und hat PLAYER_REGEN_ENABLED dauerhaft
-- registriert, daher kein erneuter EnsureCombatQueueFrame()-Aufruf noetig.
local function DrainNextQueuedFunc(self)
	if T.InCombatLockdown and T.InCombatLockdown() then
		for i = combatDrainIndex, #combatDrainQueue do
			combatQueue[combatDrainQueue[i].key] = combatDrainQueue[i].func
		end
		wipe(combatDrainQueue)
		combatDrainIndex = 1
		self:SetScript("OnUpdate", nil)
		return
	end

	local item = combatDrainQueue[combatDrainIndex]
	if not item then
		wipe(combatDrainQueue)
		combatDrainIndex = 1
		self:SetScript("OnUpdate", nil)
		return
	end

	combatDrainIndex = combatDrainIndex + 1
	local ok, err = pcall(item.func)
	if not ok then
		KUI:DebugProtectedAction("Protected update failed (drain):", item.key, err)
	end
end

local function EnsureCombatQueueFrame()
	if combatQueueFrame then return end

	combatQueueFrame = T.CreateFrame("Frame")
	combatQueueFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
	combatQueueFrame:SetScript("OnEvent", function()
		KUI:FlushCombatQueue()
	end)
end

function KUI:RunOutOfCombat(key, func)
	if type(func) ~= "function" then return false end

	key = key or tostring(func)
	if T.InCombatLockdown and T.InCombatLockdown() then
		combatQueue[key] = func
		EnsureCombatQueueFrame()
		self.LastProtectedAction = key
		self.LastProtectedActionQueued = true
		self:DebugProtectedAction("Queued protected update:", key)
		return false
	end

	self.LastProtectedAction = key
	self.LastProtectedActionQueued = false
	local ok, err = pcall(func)
	if not ok then
		self:DebugProtectedAction("Protected update failed:", key, err)
	end

	return ok
end

-- FIX [DRIP]: Statt alle Funktionen synchron abzuarbeiten (FPS-Spike),
-- wird die erste Funktion sofort ausgefuehrt und alle weiteren werden
-- einzeln ueber aufeinanderfolgende Frames verteilt (1 Funktion/Frame).
-- Das eliminiert den FPS-Einbruch beim Verlassen des Kampfes.
function KUI:FlushCombatQueue()
	if T.InCombatLockdown and T.InCombatLockdown() then return end

	local count = 0
	for key, func in pairs(combatQueue) do
		combatQueue[key] = nil
		count = count + 1
		combatDrainQueue[count] = {key = key, func = func}
	end

	if count == 0 then return end

	-- Erste Funktion sofort ausfuehren (kein wahrnehmbarer Delay)
	combatDrainIndex = 2
	local first = combatDrainQueue[1]
	local ok, err = pcall(first.func)
	if not ok then
		self:DebugProtectedAction("Protected update failed:", first.key, err)
	end

	-- Restliche Funktionen: eine pro Frame ueber combatDrainFrame verteilen
	if combatDrainIndex <= count then
		if not combatDrainFrame then
			combatDrainFrame = T.CreateFrame("Frame")
		end
		combatDrainFrame:SetScript("OnUpdate", DrainNextQueuedFunc)
	else
		wipe(combatDrainQueue)
		combatDrainIndex = 1
	end
end

function KUI:cOption(name)
	local color = '|cfff960d9%s |r'
	return (color):format(name)
end

function KUI:SplitList(list, variable, cleanup)
	if cleanup then T.table_wipe(list) end

	for word in variable:gmatch('%S+') do
		list[word] = true
	end
end

function KUI:MismatchText()
	local text = T.string_format(L["MSG_KUI_ELV_OUTDATED"], KUI.ElvUIV, KUI.ElvUIX)
	return text
end

-- Inform us of the patch info we play on.
_G.SLASH_WOWVERSION1, _G.SLASH_WOWVERSION2 = "/patch", "/version"
SlashCmdList["WOWVERSION"] = function()
	KUI:Print("Patch:", KUI.WoWPatch..", ".. "Build:", KUI.WoWBuild..", ".. "Released", KUI.WoWPatchReleaseDate..", ".. "Interface:", KUI.TocVersion)
end

-- Register KlixUI media here
function KUI:RegisterKuiMedia()
	--Fonts
	E.media.CGB = LSM:Fetch('font', 'Century Gothic Bold')
	E.media.Days = LSM:Fetch('font', 'Days')
	E.media.Expressway = LSM:Fetch('font', 'Expressway')
	E.media.Gilroy = LSM:Fetch('font', 'Gilroy Bold')
	E.media.Teko = LSM:Fetch('font', 'Teko Bold')

	--Textures
	E.media.Empty = LSM:Fetch('statusbar', 'Empty')
	E.media.Klix = LSM:Fetch('statusbar', 'Klix')
	E.media.Klix1 = LSM:Fetch('statusbar', 'Klix1')
	E.media.Klix2 = LSM:Fetch('statusbar', 'Klix2')
	E.media.Klix3 = LSM:Fetch('statusbar', 'Klix3')
	E.media.Klix4 = LSM:Fetch('statusbar', 'Klix4')
	E.media.KlixRainbow1 = LSM:Fetch('statusbar', 'KlixRainbow1')
	E.media.KlixRainbow2 = LSM:Fetch('statusbar', 'KlixRainbow2')
	E.media.KlixGradient = LSM:Fetch("statusbar", "KlixGradient")
	E.media.KuiOnePixel = LSM:Fetch('statusbar', 'KuiOnePixel')
	E.media.KlixBlank = LSM:Fetch('statusbar', 'KlixBlank')
	
	-- Custom Textures
	E.media.roleIcons = [[Interface\AddOns\ElvUI_KlixUI\media\textures\UI-LFG-ICON-ROLES]]
end

-- Color and class color stuff
function KUI:unpackColor(color)
	return color.r, color.g, color.b, color.a
end

KUI.ClassColor = E.myclass == "PRIEST" and E.PriestColors or (CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[E.myclass] or RAID_CLASS_COLORS[E.myclass])
KUI.ClassColors = {}
KUI.Classes = {}

for k, v in pairs(LOCALIZED_CLASS_NAMES_MALE) do KUI.Classes[v] = k end
for k, v in pairs(LOCALIZED_CLASS_NAMES_FEMALE) do KUI.Classes[v] = k end

local colors = CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS
for class in T.pairs(colors) do
	KUI.ClassColors[class] = {}
	KUI.ClassColors[class].r = colors[class].r
	KUI.ClassColors[class].g = colors[class].g
	KUI.ClassColors[class].b = colors[class].b
	KUI.ClassColors[class].colorStr = colors[class].colorStr
end
KUI.r, KUI.g, KUI.b = KUI.ClassColors[E.myclass].r, KUI.ClassColors[E.myclass].g, KUI.ClassColors[E.myclass].b

function KUI:ClassColor(class)
	local color = KUI.ClassColors[class]
	if not color then return 1, 1, 1 end
	return color.r, color.g, color.b
end

function KUI:ClassColorCode(class)
	local color = class and (CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[KUI.Classes[class]] or RAID_CLASS_COLORS[KUI.Classes[class]]) or { r = 1, g = 1, b = 1 }

	return format('FF%02x%02x%02x', color.r * 255, color.g * 255, color.b * 255)
end

KUI.colors = {
	class = {},
}

KUI.colors.class = {
	["DEATHKNIGHT"]	= { 0.77,	0.12,	0.23 },
	["DEMONHUNTER"]	= { 0.64,	0.19,	0.79 },
	["DRUID"]		= { 1,		0.49,	0.04 },
	["HUNTER"]		= { 0.58,	0.86,	0.49 },
	["MAGE"]		= { 0.2,	0.76,	1 },
	["MONK"]		= { 0,		1,		0.59 },
	["PALADIN"]		= { 0.96,	0.55,	0.73 },
	["PRIEST"]		= { 0.99,	0.99,	0.99 },
	["ROGUE"]		= { 1,		0.96,	0.41 },
	["SHAMAN"]		= { 0,		0.44,	0.87 },
	["WARLOCK"]		= { 0.6,	0.47,	0.85 },
	["WARRIOR"]		= { 0.9,	0.65,	0.45 },
}

for class, color in T.pairs(KUI.colors.class) do
	KUI.colors.class[class] = { r = color[1], g = color[2], b = color[3] }
end

-- Convert RGB values to Hexdecimal
-- Here is r, g, b valuesbetween 0~1
local function RGBToHex(r, g, b)
	r = r <= 1 and r >= 0 and r or 0
	g = g <= 1 and g >= 0 and g or 0
	b = b <= 1 and b >= 0 and b or 0
	return T.string_format("%02x%02x%02x", r*255, g*255, b*255)
end

-- Custom color to string
function KUI:ColorStr(str, r, g, b)
	local hex
	local coloredString
	
	if r and g and b then
		hex = RGBToHex(r, g, b)
	else
		-- Default string is light blue
		hex = RGBToHex(52/255, 152/255, 219/255)
	end
	
	coloredString = "|cff"..hex..str.."|r"
	return coloredString
end

-- Search in a table like {"arg1", "arg2", "arg3"}
function KUI:SimpleTable(table, item)
	for i = 1, #table do
		if table[i] == item then  
			return true 
		end
	end

	return false
end

-- Check Chat channels
KUI.CheckChat = function(warning)
	if T.IsInGroup(_G.LE_PARTY_CATEGORY_INSTANCE) then
		return "INSTANCE_CHAT"
	elseif T.IsInRaid(_G.LE_PARTY_CATEGORY_HOME) then
		if warning and (T.UnitIsGroupLeader("player") or T.UnitIsGroupAssistant("player") or T.IsEveryoneAssistant()) then
			return "RAID_WARNING"
		else
			return "RAID"
		end
	elseif T.IsInGroup(_G.LE_PARTY_CATEGORY_HOME) then
		return "PARTY"
	end

	return "SAY"
end

function KUI:IsAddOnEnabled(addon, character)
	if (T.type(character) == 'boolean' and character == true) then
		character = nil
	end
	return T.GetAddOnEnableState(character, addon) == 2
end

function KUI:IsAddOnPartiallyEnabled(addon, character)
	if (T.type(character) == 'boolean' and character == true) then
		character = nil
	end
	return T.GetAddOnEnableState(character, addon) == 1
end

function KUI:PairsByKeys(t, f)
	local a = {}
	for n in T.pairs(t) do T.table_insert(a, n) end
	T.table_sort(a, f)
	local i = 0
	local iter = function()
		i = i + 1
		if a[i] == nil then return nil
			else return a[i], t[a[i]]
		end
	end
	return iter
end

-- Movers
function KUI:SetMoverPosition(mover, point, anchor, secondaryPoint, x, y)
	if not _G[mover] then return end
	local frame = _G[mover]

	frame:ClearAllPoints()
	frame:Point(point, anchor, secondaryPoint, x, y)
	E:SaveMoverPosition(mover)
end

function KUI:AddMoverCategories()
	T.table_insert(E.ConfigModeLayouts, #(E.ConfigModeLayouts) + 1, "KLIXUI")
	E.ConfigModeLocalizedStrings["KLIXUI"] = T.string_format("|cfff960d9%s |r", "KlixUI")
end

-- Reset stuff
function KUI:Reset(group)
	if not group then T.print("U wot m8?") end

	if group == "marks" or group == "all" then
		E:CopyTable(E.db.KlixUI.raidmarkers, P.KlixUI.raidmarkers)
		E:ResetMovers(L["Raid Marker Bar"])
	end
	E:UpdateAll()
end

function KUI:GetMapInfo(id, arg)
	if not arg then return end
	local MapInfo = T.C_Map_GetMapInfo(id)
	if not MapInfo then return UNKNOWN end
	-- for k,v in pairs(MapInfo) do print(k,v) end
	if arg == "all" then return MapInfo["name"], MapInfo["mapID"], MapInfo["parentMapID"], MapInfo["mapType"] end
	return MapInfo[arg]
end

function KUI:SetupProfileCallbacks()
	E.data.RegisterCallback(self, "OnProfileChanged", "UpdateAll")
	E.data.RegisterCallback(self, "OnProfileCopied", "UpdateAll")
	E.data.RegisterCallback(self, "OnProfileReset", "UpdateAll")
end

-- Whiro's DB code magic
function KUI:UpdateRegisteredDBs()
	if (not KUI["RegisteredDBs"]) then
		return
	end

	local dbs = KUI["RegisteredDBs"]

	for tbl, path in T.pairs(dbs) do
		self:UpdateRegisteredDB(tbl, path)
	end
end

function KUI:UpdateRegisteredDB(tbl, path)
	local path_parts = {strsplit(".", path)}
	local _db = E.db.KlixUI
	for _, path_part in T.ipairs(path_parts) do
		_db = _db[path_part]
	end
	tbl.db = _db
end

function KUI:RegisterDB(tbl, path)
	if (not KUI["RegisteredDBs"]) then
		KUI["RegisteredDBs"] = {}
	end
	self:UpdateRegisteredDB(tbl, path)
	KUI["RegisteredDBs"][tbl] = path
end

function KUI:UpdateAll()
	self:UpdateRegisteredDBs()
	for _, mod in T.pairs(self["RegisteredModules"]) do
		if mod and mod.ForUpdateAll then
			mod:ForUpdateAll();
		end	
	end
end

-- Create moveable buttons in config
local function MovableButton_Match(s,v)
	local m1, m2, m3, m4 = "^"..v.."$", "^"..v..",", ","..v.."$", ","..v..","
	return (T.string_match(s, m1) and m1) or (T.string_match(s, m2) and m2) or (T.string_match(s, m3) and m3) or (T.string_match(s, m4) and v..",")
end
function KUI:MovableButtonSettings(db, key, value, remove, movehere)
	local str = db[key]
	if not db or not str or not value then return end

	local found = MovableButton_Match(str, E:EscapeString(value))
	if found and movehere then
		local tbl, sv, sm = {T.string_split(",", str)}
		for i in T.ipairs(tbl) do
			if tbl[i] == value then sv = i elseif tbl[i] == movehere then sm = i end
			if sv and sm then break end
		end
		T.table_remove(tbl, sm);
		T.table_insert(tbl, sv, movehere);

		db[key] = T.table_concat(tbl,',')

	elseif found and remove then
		db[key] = T.string_gsub(str, found, "")
	elseif not found and not remove then
		db[key] = (str == '' and value) or (str..","..value)
	end
end

function KUI:CreateMovableButtons(Order, Name, CanRemove, db, key)
	local moveItemFrom, moveItemTo

	local config = {
		order = Order,
		dragdrop = true,
		type = "multiselect",
		name = Name,
		dragOnLeave = function() end, --keep this here
		dragOnEnter = function(info)
			moveItemTo = info.obj.value
		end,
		dragOnMouseDown = function(info)
			moveItemFrom, moveItemTo = info.obj.value, nil
		end,
		dragOnMouseUp = function(info)
			KUI:MovableButtonSettings(db, key, moveItemTo, nil, moveItemFrom) --add it in the new spot
			moveItemFrom, moveItemTo = nil, nil
		end,
		dragGetTitle = function(info, TEXT)
			local itemID = T.tonumber(TEXT)
			if itemID then
				local text = T.GetItemInfo(itemID)
				if text then
					return text
				end
			end

			return TEXT
		end,
		values = function()
			local str = db[key]
			if str == "" then return nil end
			return {T.string_split(",",str)}
		end,
		get = function(info, value)
			local str = db[key]
			if str == "" then return nil end
			local tbl = {T.string_split(",",str)}
			return tbl[value]
		end,
		set = function(info, value) end,
	}

	if CanRemove then --This allows to remove shit
		config.dragOnClick = function(info)
			KUI:MovableButtonSettings(db, key, moveItemFrom, true)
		end
	end

	return config
end

-- Create font string
function KUI:CreateText(f, layer, fontsize, flag, justifyh)
	local text = f:CreateFontString(nil, layer)
	text:SetFont(E.media.normFont, fontsize, flag)
	text:SetJustifyH(justifyh or "CENTER")
	return text
end

-- Tooltip scanning stuff
local iLvlDB = {}
local itemLevelString = _G["ITEM_LEVEL"]:gsub("%%d", "")
local tip = T.CreateFrame("GameTooltip", "Kui_iLvlTooltip", nil, "GameTooltipTemplate")

function KUI:GetItemLevel(link, arg1, arg2)
	if iLvlDB[link] then return iLvlDB[link] end

	tip:SetOwner(UIParent, "ANCHOR_NONE")
	if arg1 and T.type(arg1) == "string" then
		tip:SetInventoryItem(arg1, arg2)
	elseif arg1 and T.type(arg1) == "number" then
		tip:SetBagItem(arg1, arg2)
	else
		tip:SetHyperlink(link)
	end

	for i = 2, 5 do
		local text = _G[tip:GetName().."TextLeft"..i]:GetText() or ""
		local found = text:find(itemLevelString)
		if found then
			local level = text:match("(%d+)%)?$")
			iLvlDB[link] = T.tonumber(level)
			break
		end
	end
	return iLvlDB[link]
end

function KUI:GetIconFromID(type, id)
    local path
    if type == "item" then
        path = T.select(10, T.GetItemInfo(id))
    elseif type == "spell" then
        path = T.select(3, T.GetSpellInfo(id))
    elseif type == "achiev" then
        path = T.select(10, T.GetAchievementInfo(id))
    end
    return path or nil
end

function KUI:BagSearch(itemId)
    for container = 0, NUM_BAG_SLOTS do
        for slot = 1, T.GetContainerNumSlots(container) do
            if itemId == T.GetContainerItemID(container, slot) then
                return container, slot
            end
        end
    end
end

-- Talent module stuff
-- Prints all the key value pairs in the given table (See python's dir() function)
function dir(t)
    for k, v in T.pairs(t) do
        T.print(k, v)
    end
end

-- Returns the length of the given table
function table.length(t)
    local count = 0
    for k, v in T.pairs(t) do
        count = count + 1
    end
    return count
end

--SoftGlow
function KUI:UpdateSoftGlowColor()
	if KUI["softGlow"] == nil then KUI["softGlow"] = {} end

	local sr, sg, sb = KUI:unpackColor(E.db.general.valuecolor)

	for glow, _ in T.pairs(KUI["softGlow"]) do
		if glow then
			glow:SetBackdropBorderColor(sr, sg, sb, 0.6)
		else
			KUI["softGlow"][glow] = nil
		end
	end
end
hooksecurefunc(E, "UpdateMedia", KUI.UpdateSoftGlowColor)

--Pulse
function KUI:CreatePulse(frame, speed, alpha, mult)
	T.assert(frame, "doesn't exist!")
	
	frame.speed = .02
	frame.mult = mult or 1
	frame.alpha = alpha or 1
	frame.tslu = 0
	frame:SetScript("OnUpdate", function(self, elapsed)
		elapsed = elapsed * (speed or 5/4)
		self.tslu = self.tslu + elapsed
		if self.tslu > self.speed then
			self.tslu = 0
			local currentAlpha = self.alpha * (alpha or 3/5)
			if currentAlpha < 0 then
				currentAlpha = 0
			elseif currentAlpha > 1 then
				currentAlpha = 1
			end

			self:SetAlpha(currentAlpha)
		end
		self.alpha = self.alpha - elapsed*self.mult
		if self.alpha < 0 and self.mult > 0 then
			self.mult = self.mult*-1
			self.alpha = 0
		elseif self.alpha > 1 and self.mult < 0 then
			self.mult = self.mult*-1
		end
	end)
end

-- Role Icons
function KUI:GetRoleTexCoord(role)
	if role == "TANK" then
		return .32/9.03, 2.04/9.03, 2.65/9.03, 4.3/9.03
	elseif role == "DPS" or role == "DAMAGER" then
		return 2.68/9.03, 4.4/9.03, 2.65/9.03, 4.34/9.03
	elseif role == "HEALER" then
		return 2.68/9.03, 4.4/9.03, .28/9.03, 1.98/9.03
	elseif role == "LEADER" then
		return .32/9.03, 2.04/9.03, .28/9.03, 1.98/9.03
	elseif role == "READY" then
		return 5.1/9.03, 6.76/9.03, .28/9.03, 1.98/9.03
	elseif role == "PENDING" then
		return 5.1/9.03, 6.76/9.03, 2.65/9.03, 4.34/9.03
	elseif role == "REFUSE" then
		return 2.68/9.03, 4.4/9.03, 5.02/9.03, 6.7/9.03
	end
end

function KUI:ReskinRole(self, role)
	if self.background then self.background:SetTexture("") end
	local cover = self.cover or self.Cover
	if cover then cover:SetTexture("") end
	local texture = self.GetNormalTexture and self:GetNormalTexture() or self.texture or self.Texture or (self.SetTexture and self)
	if texture then
		texture:SetTexture(E.media.roleIcons)
		texture:SetTexCoord(KUI:GetRoleTexCoord(role))
	end

	local checkButton = self.checkButton or self.CheckButton or self.CheckBox
	if checkButton then
		checkButton:SetFrameLevel(self:GetFrameLevel() + 2)
		checkButton:Point("BOTTOMLEFT", -2, -2)
	end

	local shortageBorder = self.shortageBorder
	if shortageBorder then
		shortageBorder:SetTexture("")
		local icon = self.incentiveIcon
		icon:Point("BOTTOMRIGHT")
		icon:Size(14, 14)
		icon.texture:SetSize(14, 14)
		icon.border:SetTexture("")
	end
end

local function CreateWideShadow(f)
	local borderr, borderg, borderb = 0, 0, 0
	local backdropr, backdropg, backdropb = 0, 0, 0

	local wideshadow = f.wideshadow or T.CreateFrame('Frame', nil, f, 'BackdropTemplate') -- This way you can replace current shadows.
	wideshadow:SetFrameLevel(1)
	wideshadow:SetFrameStrata('BACKGROUND')
	wideshadow:SetOutside(f, 6, 6)
	wideshadow:SetBackdrop( { 
		edgeFile = LSM:Fetch('border', 'ElvUI GlowBorder'), edgeSize = E:Scale(6),
		insets = {left = 8, right = 8, top = 8, bottom = 8},
	})
	wideshadow:SetBackdropColor(backdropr, backdropg, backdropb, 0)
	wideshadow:SetBackdropBorderColor(borderr, borderg, borderb, 0.5)
	f.wideshadow = wideshadow
end

--Shadow Overlay
local function CreateSoftShadow(f)
	local borderr, borderg, borderb = 0, 0, 0
	local backdropr, backdropg, backdropb = 0, 0, 0

	local softshadow = f.softshadow or T.CreateFrame('Frame', nil, f, 'BackdropTemplate') -- This way you can replace current shadows.
	softshadow:SetFrameLevel(1)
	softshadow:SetFrameStrata('BACKGROUND')
	softshadow:SetOutside(f, 2, 2)
	softshadow:SetBackdrop( { 
		edgeFile = LSM:Fetch('border', 'ElvUI GlowBorder'), edgeSize = E:Scale(2),
		insets = {left = 5, right = 5, top = 5, bottom = 5},
	})
	softshadow:SetBackdropColor(backdropr, backdropg, backdropb, 0)
	softshadow:SetBackdropBorderColor(borderr, borderg, borderb, 0.4)
	f.softshadow = softshadow
end

local function CreateSoftGlow(f)
	if f.sglow then return end

	local r, g, b = KUI:unpackColor(E.db.general.valuecolor)
	local sglow = T.CreateFrame('Frame', nil, f, 'BackdropTemplate')

	sglow:SetFrameLevel(1)
	sglow:SetFrameStrata(f:GetFrameStrata())
	sglow:SetOutside(f, 3, 3)
	sglow:SetBackdrop( { 
		edgeFile = LSM:Fetch('border', 'ElvUI GlowBorder'), edgeSize = E:Scale(3),
		insets = {left = 5, right = 5, top = 5, bottom = 5},
	})

	sglow:SetBackdropBorderColor(r, g, b, 0.6)

	f.sglow = sglow
	KUI["softGlow"][sglow] = true
end

--IconShadow
local function CreateIconShadow(f, alpha)
	if T.IsAddOnLoaded("Masque") then return end
	
	if E.db.KlixUI.general == nil then E.db.KlixUI.general = {} end
	if f.ishadow or E.db.KlixUI.general.iconShadow ~= true then return end
	
	local ishadow = f:CreateTexture(nil, "OVERLAY")
	ishadow:SetInside(f, 1, 1)
	ishadow:SetTexture([[Interface\AddOns\ElvUI_KlixUI\media\textures\overlay]])
	ishadow:SetVertexColor(1, 1, 1, alpha or 1)
	ishadow:Size(f:GetSize())

	f.ishadow = ishadow
	
	KUI["iconShadow"][ishadow] = true
end

local function Styling(f, useSquares, useGradient, useShadow, shadowOverlayWidth, shadowOverlayHeight, shadowOverlayAlpha)
	T.assert(f, "doesn't exist!")
	local frameName = f.GetName and f:GetName()
	if E.db.KlixUI.general == nil then E.db.KlixUI.general = {} end
	if f.styling or E.db.KlixUI.general.style == "NONE" then return end

	local style = T.CreateFrame("Frame", frameName or nil, f)

	if not(useSquares) and E.db.KlixUI.general.style == "ALL" or E.db.KlixUI.general.style == "SQUARES" then
		local squares = f:CreateTexture(f:GetName() and f:GetName().."Overlay" or nil, "BORDER")
		squares:ClearAllPoints()
		squares:Point("TOPLEFT", 1, -1)
		squares:Point("BOTTOMRIGHT", -1, 1)
		squares:SetTexture([[Interface\AddOns\ElvUI_KlixUI\media\textures\squares]], true, true)
		squares:SetHorizTile(true)
		squares:SetVertTile(true)
		squares:SetBlendMode("ADD")

		f.squares = squares
	end

	if not(useGradient) then
		local gradient = f:CreateTexture(f:GetName() and f:GetName().."Overlay" or nil, "BORDER")
		gradient:ClearAllPoints()
		gradient:Point("TOPLEFT", 1, -1)
		gradient:Point("BOTTOMRIGHT", -1, 1)
		gradient:SetTexture([[Interface\AddOns\ElvUI_KlixUI\media\textures\gradient.tga]])
		gradient:SetVertexColor(.3, .3, .3, .15)

		f.gradient = gradient
	end

	if not(useShadow) and E.db.KlixUI.general.style == "ALL" or E.db.KlixUI.general.style == "SHADOW" then
		local mshadow = f:CreateTexture(f:GetName() and f:GetName().."Overlay" or nil, "BORDER")
		mshadow:SetInside(f, 0, 0)
		mshadow:Width(shadowOverlayWidth or 33)
		mshadow:Height(shadowOverlayHeight or 33)
		mshadow:SetTexture([[Interface\AddOns\ElvUI_KlixUI\media\textures\overlay]])
		mshadow:SetVertexColor(1, 1, 1, shadowOverlayAlpha or 0.6)

		f.mshadow = mshadow
	end

	style:SetFrameLevel(f:GetFrameLevel() + 1)
	f.styling = style

	KUI["styling"][style] = true
end

local function addapi(object)
	local mt = T.getmetatable(object).__index
	if not object.Styling then mt.Styling = Styling end
	if not object.CreateIconShadow then mt.CreateIconShadow = CreateIconShadow end
	if not object.CreateSoftShadow then mt.CreateSoftShadow = CreateSoftShadow end
	if not object.CreateWideShadow then mt.CreateWideShadow = CreateWideShadow end
	if not object.CreateSoftGlow then mt.CreateSoftGlow = CreateSoftGlow end
end

local handled = {["Frame"] = true}
local object = T.CreateFrame("Frame")
addapi(object)
addapi(object:CreateTexture())
addapi(object:CreateFontString())

object = EnumerateFrames()
while object do
	if not object:IsForbidden() and not handled[object:GetObjectType()] then
		addapi(object)
		handled[object:GetObjectType()] = true
	end

	object = EnumerateFrames(object)
end
