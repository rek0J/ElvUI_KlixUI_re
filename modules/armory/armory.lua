local KUI, T, E, L, V, P, G = unpack(select(2, ...))
local KA = KUI:NewModule('KuiArmory', 'AceEvent-3.0', 'AceTimer-3.0', 'AceHook-3.0')
local LCG = LibStub('LibCustomGlow-1.0')
local LSM = E.LSM or E.Libs.LSM
local S = E:GetModule('Skins')
if IsAddOnLoaded("ElvUI_SLE") then return end

local Enum = _G.Enum or {}
local Enum_TransmogType = Enum.TransmogType or {}
local C_AzeriteEmpoweredItem = _G.C_AzeriteEmpoweredItem or {}
local Enum_TransmogType_Appearance = Enum_TransmogType.Appearance
local Enum_TransmogType_Illusion = Enum_TransmogType.Illusion

local HasAnyUnselectedPowers = C_AzeriteEmpoweredItem.HasAnyUnselectedPowers or KUI.dummy

local initialized = false
local updateTimer
local classCrest
local nakedButton

local socketsTable = { -- These bonusIDs should be sockets
	-- /dump T.string_split(":", T.GetInventoryItemLink("player", i))
	-- /dump T.string_split(":", T.GetInventoryItemLink("target", 17))
	[3] = true,
	-- Observed results:
	[1521] = true,
	[1530] = true,
	[1808] = true,
	[3345] = true,
	[3347] = true,
	[3350] = true,
	[3353] = true,
	[3357] = true,
	[3358] = true,
	[3360] = true,
	[3362] = true,
	[3368] = true,
	[3370] = true,
	[3372] = true,
	[3373] = true,
	[3378] = true,
	[3401] = true,
	[3521] = true,
	[3583] = true,
	[4086] = true,
	[4802] = true,
	[5278] = true,
}

local slots = {
	["HeadSlot"] = { true, true },
	["NeckSlot"] = { true, false },
	["ShoulderSlot"] = { true, true },
	["BackSlot"] = { true, false },
	["ChestSlot"] = { true, true },
	["WristSlot"] = { true, true },
	["MainHandSlot"] = { true, true },
	["SecondaryHandSlot"] = { true, true },
	["HandsSlot"] = { true, true },
	["WaistSlot"] = { true, true },
	["LegsSlot"] = { true, true },
	["FeetSlot"] = { true, true },
	["Finger0Slot"] = { true, false },
	["ShirtSlot"] = { false, false },
	["Finger1Slot"] = { true, false },
	["TabardSlot"] = { false, false },
	["Trinket0Slot"] = { true, false },
	["Trinket1Slot"] = { true, false },
}

local slotIDs = {
	[1] = "HeadSlot",
	[2] = "NeckSlot",
	[3] = "ShoulderSlot",
	[5] = "ChestSlot",
	[6] = "ShirtSlot",
	[7] = "TabardSlot",
	[8] = "WaistSlot",
	[9] = "LegsSlot",
	[10] = "FeetSlot",
	[11] = "WristSlot",
	[12] = "HandsSlot",
	[13] = "Finger0Slot",
	[14] = "Finger1Slot",
	[15] = "Trinket0Slot",
	[16] = "Trinket1Slot",
	[17] = "BackSlot",
	[18] = "MainHandSlot",
	[19] = "SecondaryHandSlot",
}

local AZSlots = {
	"Head", "Shoulder", "Chest",
}

local BlizzardBackdropList = {
    ["Alliance-bliz"] = [[Interface\LFGFrame\UI-PVP-BACKGROUND-Alliance]],
    ["Horde-bliz"] = [[Interface\LFGFrame\UI-PVP-BACKGROUND-Horde]],
    ["Arena-bliz"] = [[Interface\PVPFrame\PvpBg-NagrandArena-ToastBG]]
}

local levelColors = {
	[0] = "|cffff0000",
	[1] = "|cff00ff00",
	[2] = "|cffffff88",
}

-- From http://www.wowhead.com/items?filter=qu=7;sl=16:18:5:8:11:10:1:23:7:21:2:22:13:24:15:28:14:4:3:19:25:12:17:6:9;minle=1;maxle=1;cr=166;crs=3;crv=0
local heirlooms = {
	[80] = {
		44102,42944,44096,42943,42950,48677,42946,42948,42947,42992,
		50255,44103,44107,44095,44098,44097,44105,42951,48683,48685,
		42949,48687,42984,44100,44101,44092,48718,44091,42952,48689,
		44099,42991,42985,48691,44094,44093,42945,48716
	},
	["90h"] = {105689,105683,105686,105687,105688,105685,105690,105691,105684,105692,105693},
	["90n"] = {104399,104400,104401,104402,104403,104404,104405,104406,104407,104408,104409},
	["90f"] = {105675,105670,105672,105671,105674,105673,105676,105677,105678,105679,105680},
}

function KA:OnEnter()
	if self.Link and self.Link ~= '' then
		_G["GameTooltip"]:SetOwner(self, 'ANCHOR_RIGHT')

		self:SetScript('OnUpdate', function()
			_G["GameTooltip"]:ClearLines()
			_G["GameTooltip"]:SetHyperlink(self.Link)

			_G["GameTooltip"]:Show()
		end)
	end
end

function KA:OnLeave()
	self:SetScript('OnUpdate', nil)
	_G["GameTooltip"]:Hide()
end

function KA:Transmog_OnEnter()
	if self.Link and self.Link ~= '' then
		self.Texture:SetVertexColor(1, .8, 1)
		_G["GameTooltip"]:SetOwner(self, 'ANCHOR_BOTTOMRIGHT')
		
		self:SetScript('OnUpdate', function()
			_G["GameTooltip"]:ClearLines()
			_G["GameTooltip"]:SetHyperlink(self.Link)
			
			_G["GameTooltip"]:Show()
		end)
	end
end

function KA:Transmog_OnLeave()
	self.Texture:SetVertexColor(1, .5, 1)
	
	self:SetScript('OnUpdate', nil)
	_G["GameTooltip"]:Hide()
end

function KA:Illusion_OnEnter()
	_G["GameTooltip"]:SetOwner(self, 'ANCHOR_BOTTOM')
	_G["GameTooltip"]:AddLine(self.Link, 1, 1, 1)
	_G["GameTooltip"]:Show()
end

function KA:Illusion_OnLeave()
	_G["GameTooltip"]:Hide()
end

local function HasPaperDollInfo()
	local frame = _G.CharacterHeadSlot
	return frame and frame.DurabilityInfo and frame.Transmog and frame.Illusion and frame.Gradiation
end

local function HasArmoryGarrisonSupport()
	return E.Retail and _G.C_Garrison and _G.LE_GARRISON_TYPE_6_0
end

local function EnsureNakedButton()
	if nakedButton or not E.db.KlixUI.armory.naked then return end
	if not _G.PaperDollFrame or not _G.CharacterHeadSlot then return end

	local function Button_OnEnter(self)
		_G.GameTooltip:SetOwner(self, 'ANCHOR_TOPLEFT', 0, 4)
		_G.GameTooltip:ClearLines()
		_G.GameTooltip:AddLine(L["Instantly remove all your equipped gear."])
		_G.GameTooltip:Show()
	end

	local function Button_OnLeave()
		_G.GameTooltip:Hide()
	end

	local function UnequipItemInSlot(i)
		if T.InCombatLockdown() then return end
		local action = T.EquipmentManager_UnequipItemInSlot and T.EquipmentManager_UnequipItemInSlot(i)
		if action and T.EquipmentManager_RunAction then
			T.EquipmentManager_RunAction(action)
		end
	end

	nakedButton = T.CreateFrame("Button", "KuiArmoryNakedButton", _G.PaperDollFrame, "UIPanelButtonTemplate")
	nakedButton:SetFrameStrata("HIGH")
	nakedButton:Size(62, 20)
	nakedButton:Point("BOTTOMLEFT", _G.CharacterHeadSlot, "TOPLEFT", 0, 4)

	nakedButton.text = KUI:CreateText(nakedButton, "OVERLAY", 12, nil)
	nakedButton.text:Point("CENTER")
	nakedButton.text:SetText(L["Naked"])

	nakedButton:SetScript('OnEnter', Button_OnEnter)
	nakedButton:SetScript('OnLeave', Button_OnLeave)
	nakedButton:SetScript("OnClick", function()
		for i = 1, 17 do
			if T.GetInventoryItemTexture('player', i) then
				UnequipItemInSlot(i)
			end
		end
	end)

	if S and S.HandleButton then
		S:HandleButton(nakedButton)
	end
end

local function UpdateClassCrest()
	local insetRight = _G.CharacterFrameInsetRight
	if not insetRight then return end

	if E.db.KlixUI.armory.classCrests then
		if not classCrest then
			classCrest = insetRight:CreateTexture(nil, "BORDER")
			classCrest:Point("BOTTOM", insetRight, "BOTTOM", 0, 40)
			classCrest:Size(126, 120)
			classCrest:SetAlpha(.45)
			classCrest:SetDesaturated(true)
		end

		classCrest:SetTexture("Interface\\AddOns\\ElvUI_KlixUI\\media\\textures\\classIcons\\CLASS-"..E.myclass)
		classCrest:Show()
	elseif classCrest then
		classCrest:Hide()
	end
end

function KA:UpdatePaperDoll()
	if not E.db.KlixUI.armory.enable then return end

	local unit = "player"
	if not unit then return end

	if not HasPaperDollInfo() then
		self:BuildInformation()
		if not HasPaperDollInfo() then
			return
		end
	end

	local frame, slot, current, maximum, r, g, b
	local itemLink, itemLevel, itemLevelMax, enchantInfo
	local _, numBonuses, affixes
	local avgItemLevel, avgEquipItemLevel = T.GetAverageItemLevel()
	local EnchantGlowColor = {KA.db.indicators.enchant.glow.color.r, KA.db.indicators.enchant.glow.color.g, KA.db.indicators.enchant.glow.color.b, KA.db.indicators.enchant.glow.color.a or 1}
	local SocketGlowColor = {KA.db.indicators.socket.glow.color.r, KA.db.indicators.socket.glow.color.g, KA.db.indicators.socket.glow.color.b, KA.db.indicators.socket.glow.color.a or 1}

	for k, _ in T.pairs(slots) do
		frame = _G[("Character")..k]
		slot = T.GetInventorySlotInfo(k)
		if slot and slot ~= '' then
			-- Reset Data first
			--[[if not E.db.general.itemLevel.displayCharacterInfo then
				frame.ItemLevel:SetText("")
			end]]
			frame.DurabilityInfo:SetText("")
			--[[if not E.db.general.itemLevel.displayCharacterInfo then
				if KA.db.indicators.enchant.glow.enable then
					frame.EnchantInfo:Hide()
				else
					frame.EnchantInfo:SetText("")
				end
			end
			if not E.db.general.itemLevel.displayCharacterInfo then
				frame.SocketHolder:Hide()
				frame.SocketHolder.Link = nil
			end]]
			frame.Transmog:Hide()
			frame.Transmog.Link = nil
			frame.Illusion:Hide()
			frame.Illusion.Link = nil
			frame.Gradiation:Hide()

			itemLink = T.GetInventoryItemLink(unit, slot)
			if (itemLink and itemLink ~= nil) then
				if T.type(itemLink) ~= "string" then return end
				_, _, _, _, _, _, _, _, _, _, _, _, _, numBonuses, affixes = T.string_split(":", itemLink, 15)
				numBonuses = T.tonumber(numBonuses) or 0

				local _, _, itemRarity, _, _, _, _, _, itemEquipLoc = T.GetItemInfo(itemLink)
				-- Item Level
				--[[if not E.db.general.itemLevel.displayCharacterInfo then
					if KA.db.ilvl.enable then
						if ((slot == 16 or slot == 17) and T.GetInventoryItemQuality(unit, slot) == LE_ITEM_QUALITY_ARTIFACT) then
							local itemLevelMainHand = 0
							local itemLevelOffHand = 0
							local itemLinkMainHand = T.GetInventoryItemLink(unit, 16)
							local itemLinkOffhand = T.GetInventoryItemLink(unit, 17)
							if itemLinkMainHand then itemLevelMainHand = self:GetItemLevel(unit, itemLinkMainHand or 0) end
							if itemLinkOffhand then itemLevelOffHand = self:GetItemLevel(unit, itemLinkOffhand or 0) end
							itemLevel = T.math_max(itemLevelMainHand or 0, itemLevelOffHand or 0)
						else
							itemLevel = self:GetItemLevel(unit, itemLink)
						end
						if itemLevel and avgEquipItemLevel then
							frame.ItemLevel:SetText(itemLevel)
						end
						if (slot == 4 or slot == 19) then
							frame.ItemLevel:SetText("")
						end
						if itemRarity and KA.db.ilvl.colorStyle == "RARITY" then
							local r, g, b = T.GetItemQualityColor(itemRarity)
							frame.ItemLevel:SetTextColor(r, g, b)
						elseif KA.db.ilvl.colorStyle == "LEVEL" then
							frame.ItemLevel:SetFormattedText("%s%d|r", levelColors[(itemLevel < avgEquipItemLevel-10 and 0 or (itemLevel > avgEquipItemLevel + 10 and 1 or (2)))], itemLevel)
						else
							frame.ItemLevel:SetTextColor(KUI:unpackColor(KA.db.ilvl.color))
						end
					end

					-- Enchants
					if KA.db.indicators.enchant.enable then
						if KA.db.indicators.enchant.glow.enable then
							local enchantInfo = self:CheckEnchants(itemLink)
							if enchantInfo then
								if (slot == 11 or slot == 12 or slot == 16 or (slot == 17 and itemEquipLoc ~= 'INVTYPE_SHIELD' and itemEquipLoc ~= 'INVTYPE_HOLDABLE')) then
									frame.EnchantInfo:Show()
									frame.EnchantInfo:SetBackdropColor(0, 0, 0, 0)
									LCG.AutoCastGlow_Stop(frame.EnchantInfo)
									LCG.ButtonGlow_Stop(frame.EnchantInfo)
									LCG.PixelGlow_Stop(frame.EnchantInfo)
								end	
							else
								if (slot == 11 or slot == 12 or slot == 16 or (slot == 17 and itemEquipLoc ~= 'INVTYPE_SHIELD' and itemEquipLoc ~= 'INVTYPE_HOLDABLE')) then
									frame.EnchantInfo:Show()
									frame.EnchantInfo:SetBackdropColor(0, 0, 0, 0)
									if KA.db.indicators.enchant.glow.style == "Button" then
										LCG.PixelGlow_Stop(frame.EnchantInfo)
										LCG.AutoCastGlow_Stop(frame.EnchantInfo)
										LCG.ButtonGlow_Start(frame.EnchantInfo, EnchantGlowColor, 0.25)
									elseif KA.db.indicators.enchant.glow.style == "Pixel" then
										LCG.ButtonGlow_Stop(frame.EnchantInfo)
										LCG.AutoCastGlow_Stop(frame.EnchantInfo)
										LCG.PixelGlow_Start(frame.EnchantInfo, EnchantGlowColor, nil, 0.25, nil, 2)
									elseif KA.db.indicators.enchant.glow.style == "AutoCast" then
										LCG.ButtonGlow_Stop(frame.EnchantInfo)
										LCG.PixelGlow_Stop(frame.EnchantInfo)
										LCG.AutoCastGlow_Start(frame.EnchantInfo, EnchantGlowColor, 6, 0.25, 1.5)
									end
								end
							end
						else
							local enchantInfo = self:GetEnchants(itemLink)
							if enchantInfo then
								if (slot == 11 or slot == 12 or slot == 16 or (slot == 17 and itemEquipLoc ~= 'INVTYPE_SHIELD' and itemEquipLoc ~= 'INVTYPE_HOLDABLE')) then
									frame.EnchantInfo:SetText(enchantInfo)
								end
							end
						end
					end

					-- Gems
					if KA.db.indicators.socket.enable then
						if numBonuses and numBonuses > 0 then
							for b = 1, numBonuses do
								local bonusID = select(b, T.string_split(":", affixes))
								if socketsTable[tonumber(bonusID)] then
									local _, gemLink = T.GetItemGem(itemLink, 1)
									if gemLink and gemLink ~= "" then
										local _, _, _, _, _, _, _, _, _, t = T.GetItemInfo(gemLink)
										if t and t > 0 then -- has a socket in the item
											if KA.db.indicators.socket.glow.enable then
												frame.SocketHolder:Show()
												frame.SocketHolder:SetBackdropColor(0, 0, 0, 0)
												LCG.ButtonGlow_Stop(frame.SocketHolder)
												LCG.PixelGlow_Stop(frame.SocketHolder)
												LCG.AutoCastGlow_Stop(frame.SocketHolder)
											else
												frame.SocketHolder:Show()
												frame.SocketHolder.Texture:SetTexture(t)
												frame.SocketHolder.Link = gemLink
											end
										end
									else -- has an empty socket
										if KA.db.indicators.socket.glow.enable then
											frame.SocketHolder:Show()
											frame.SocketHolder:SetBackdropColor(0, 0, 0, 0)
											if KA.db.indicators.socket.glow.style == "Button" then
												LCG.PixelGlow_Stop(frame.SocketHolder)
												LCG.AutoCastGlow_Stop(frame.SocketHolder)
												LCG.ButtonGlow_Start(frame.SocketHolder, SocketGlowColor, 0.25)
											elseif KA.db.indicators.socket.glow.style == "Pixel" then
												LCG.ButtonGlow_Stop(frame.SocketHolder)
												LCG.AutoCastGlow_Stop(frame.SocketHolder)
												LCG.PixelGlow_Start(frame.SocketHolder, SocketGlowColor, nil, 0.25, nil, 2)
											elseif KA.db.indicators.socket.glow.style == "AutoCast" then
												LCG.ButtonGlow_Stop(frame.SocketHolder)
												LCG.PixelGlow_Stop(frame.SocketHolder)
												LCG.AutoCastGlow_Start(frame.SocketHolder, SocketGlowColor, 6, 0.25, 1.5)
											end
										else
											frame.SocketHolder:Show()
											frame.SocketHolder:SetBackdropColor(255, 0, 0, 1)
											frame.SocketHolder.Texture:SetTexture('Interface\\AddOns\\ElvUI_KlixUI\\media\\textures\\warning')
										end
									end
								end
							end
						end
					end
				end]]

				-- Durability
				if KA.db.durability.enable then
					frame.DurabilityInfo:SetText()
					current, maximum = T.GetInventoryItemDurability(slot)
					if current and maximum and (not KA.db.durability.onlydamaged or current < maximum) then
						r, g, b = E:ColorGradient((current / maximum), 1, 0, 0, 1, 1, 0, 0, 1, 0)
						frame.DurabilityInfo:SetFormattedText("%s%.0f%%|r", E:RGBToHex(r, g, b), (current / maximum) * 100)
					end
				end
				
				-- Gradiation
				if KA.db.gradient.enable then
					frame.Gradiation:Show()
					frame.Gradiation:SetAlpha(KA.db.gradient.alpha)
					if itemRarity and KA.db.gradient.colorStyle == "RARITY" then
						local r, g, b = T.GetItemQualityColor(itemRarity)
						frame.Gradiation.Texture:SetVertexColor(r, g, b)
					elseif KA.db.gradient.colorStyle == "VALUE" then
						frame.Gradiation.Texture:SetVertexColor(T.unpack(E["media"].rgbvaluecolor))
					else
						frame.Gradiation.Texture:SetVertexColor(KUI:unpackColor(KA.db.gradient.color))
					end
				end
				
				-- Azerite Neck
				--if _G["CharacterNeckSlot"].RankFrame:IsShown()then
					--_G["CharacterNeckSlot"].RankFrame:SetBackdropBorderColor(0.9, 0.8, 0.5)
				--end
			end
		end
	end
end

-- from http://www.wowinterface.com/forums/showthread.php?p=284771 by PhanX
-- Construct your search pattern based on the existing global string:
-- local S_UPGRADE_LEVEL   = "^" .. T.string_gsub(ITEM_UPGRADE_TOOLTIP_FORMAT, "%%d", "(%%d+)")
local S_ITEM_LEVEL      = "^" .. T.string_gsub(ITEM_LEVEL, "%%d", "(%%d+)")

-- Create the tooltip:
local scantip = T.CreateFrame("GameTooltip", "MyScanningTooltip", nil, "GameTooltipTemplate")
scantip:SetOwner(E.UIParent, "ANCHOR_NONE")

local function GetRealItemLevel(itemLink)
	if not itemLink then return end
	
	-- Pass the item link to the tooltip
	scantip:ClearLines()
	scantip:SetHyperlink(itemLink)

	-- Scan the tooltip:
	for i = 2, scantip:NumLines() do -- Line 1 is always the name so you can skip it.
		local text = _G["MyScanningTooltipTextLeft"..i]:GetText()
		if text and text ~= "" then
			local currentLevel = T.string_match(text, S_ITEM_LEVEL)
			if currentLevel then
				return currentLevel
			end
		end
	end
end

function KA:GetItemLevel(unit, itemLink)
	if not itemLink then return end

	local rarity, itemLevel = T.select(3, T.GetItemInfo(itemLink))
	if rarity == 7 then -- heirloom adjust
		itemLevel = self:HeirLoomLevel(unit, itemLink)
	end

	itemLevel = GetRealItemLevel(itemLink)
	itemLevel = T.tonumber(itemLevel)
	return itemLevel
end

-- Check missing enchants
--[[function KA:CheckEnchants(itemLink)
	if not itemLink then return end
	
	-- Pass the item link to the tooltip
	scantip:ClearLines()
	scantip:SetHyperlink(itemLink)

	for i = 1, scantip:NumLines() do
		local enchant = _G["MyScanningTooltipTextLeft"..i]:GetText():match(ENCHANTED_TOOLTIP_LINE:gsub("%%s", "(.+)"))
		if enchant then
			return enchant
		end
	end
end

function KA:GetEnchants(itemLink)
	if not itemLink then return end

	local enchantInfo = self:CheckEnchants(itemLink)

	if enchantInfo then
		enchantInfo = "|cff00ff00E|r"
	else
		enchantInfo = "|cffff0000E|r"
	end

	return enchantInfo
end]]

--[[heirloom ilvl equivalents
Vanilla: 1-60 = 60 / 60 = scales by 1 ilvl per player level
TBC rares: 85-115 = 30 / 10 = scales by 3 ilvl per player level
WLK rares: 130-190(200) = 60 / 10 = scales by 6 ilvl per player level
CAT rares: 272-333 = 61 / 5 = scales by 12.2 ilvl per player level
MOP rares: 364-450 = 86 / 5 = scales by 17.2 ilvl per player level (guesswork)
]]

function KA:HeirLoomLevel(unit, itemLink)
	local level = T.UnitLevel(unit)

	if level > 85 then
		local _, _, _, _, itemId = T.string_find(itemLink, "|?c?f?f?(%x*)|?H?([^:]*):?(%d+):?(%d*):?(%d*):?(%d*):?(%d*):?(%d*):?(%-?%d*):?(%-?%d*):?(%d*):?(%d*)|?h?%[?([^%[%]]*)%]?|?h?|?r?")
		itemId = T.tonumber(itemId)

		for _, id in T.pairs(heirlooms["90h"]) do
			if id == itemId then
				level = 582
				break
			end
		end

		for _, id in T.pairs(heirlooms["90n"]) do
			if id == itemId then
				level = 569
				break
			end
		end

		for _, id in T.pairs(heirlooms["90f"]) do
			if id == itemId then
				level = 548
				break
			end
		end
	elseif level > 80 then
		local _, _, _, _, itemId = T.string_find(itemLink, "|?c?f?f?(%x*)|?H?([^:]*):?(%d+):?(%d*):?(%d*):?(%d*):?(%d*):?(%d*):?(%-?%d*):?(%-?%d*):?(%d*):?(%d*)|?h?%[?([^%[%]]*)%]?|?h?|?r?")
		itemId = T.tonumber(itemId)

		for _, id in T.pairs(heirlooms[80]) do
			if id == itemId then
				level = 80
				break
			end
		end
	end

	if level > 85 then
		return level
	elseif level > 80 then -- CAT heirloom scaling kicks in at 81
		return (( level - 81) * 12.2) + 272;
	elseif level > 67 then -- WLK heirloom scaling kicks in at 68
		return (( level - 68) * 6) + 130;
	elseif level > 59 then -- TBC heirloom scaling kicks in at 60
		return (( level - 60) * 3) + 85;
	else
		return level
	end
end

function KA:InitialUpdatePaperDoll()
	KA:UnregisterEvent("PLAYER_ENTERING_WORLD")

	self:BuildInformation()

	-- update player info
	self:ScheduleTimer("UpdatePaperDoll", 5)

	initialized = true
end

local function UpdateiLvLPoints(id)
	if not id then return end
	
	if id <= 7 or id == 17 or id == 11 then 		-- Left side
		return "BOTTOMLEFT", "BOTTOMLEFT", 1, 2
	elseif id <= 16 then 							-- Right side
		return "BOTTOMRIGHT", "BOTTOMRIGHT", 2, 2
	else											-- Weapon slots
		if KA.db.indicators.illusion.enable then
			return "BOTTOM", "BOTTOM", 2, 6
		else
			return "BOTTOM", "BOTTOM", 2, 1
		end
	end
end

local function UpdateDurabilityPoints(id)
	if not id then return end
	
	if id <= 7 or id == 17 or id == 11 then 		-- Left side
		return "TOPRIGHT", "TOPRIGHT", 3, -2
	elseif id <= 16 then 							-- Right side
		return "TOPLEFT", "TOPLEFT", 1, -2
	else											-- Weapon slots
		return "TOPLEFT", "TOPLEFT", 1, -2
	end
end

local function UpdateGemPoints(id)
	if not id then return end

	if id <= 7 or id == 17 or id == 11 then 		-- Left side
		return "LEFT", "RIGHT", 4, 0
	elseif id <= 16 then						-- Right side
		return "RIGHT", "LEFT", -4, 0
	else										-- Weapon slots
		return "TOP", "TOP", 0, 16
	end
end

function KA:BuildInformation()
	if not _G.CharacterHeadSlot then return end

	for id, slotName in T.pairs(slotIDs) do
		if not id then return end
		
		local frame = _G["Character"..slotIDs[id]]
		local iLvLPoint, iLvLParentPoint, x1, y1 = UpdateiLvLPoints(id)
		local DuraPoint, DuraParentPoint, x2, y2 = UpdateDurabilityPoints(id)
		local GemPoint, GemParentPoint, x3, y3 = UpdateGemPoints(id)
		
		-- Item Level
		--[[if not E.db.general.itemLevel.displayCharacterInfo then
			frame.ItemLevel = frame:CreateFontString(nil, "OVERLAY")
			frame.ItemLevel:SetPoint(iLvLPoint, frame, iLvLParentPoint, x1 or 0, y1 or 0)
			frame.ItemLevel:FontTemplate(LSM:Fetch("font", KA.db.ilvl.font), KA.db.ilvl.textSize, KA.db.ilvl.fontOutline)
		end]]

		-- Durability
		if not frame.DurabilityInfo then
			frame.DurabilityInfo = frame:CreateFontString(nil, "OVERLAY")
			frame.DurabilityInfo:SetPoint(DuraPoint, frame, DuraParentPoint, x2 or 0, y2 or 0)
			frame.DurabilityInfo:FontTemplate(LSM:Fetch("font", KA.db.durability.font), KA.db.durability.textSize, KA.db.durability.fontOutline)
		end
		
		-- Enchant Info
		--[[if not E.db.general.itemLevel.displayCharacterInfo then
			if KA.db.indicators.enchant.glow.enable then
				frame.EnchantInfo = T.CreateFrame('Frame', nil, frame)
				frame.EnchantInfo:SetSize(37)
				frame.EnchantInfo:SetBackdrop({
					bgFile = E.media.blankTex,
					edgeFile = E.media.blankTex,
					tile = false, tileSize = 0, edgeSize = E.mult,
					insets = { left = 0, right = 0, top = 0, bottom = 0}
				})
				frame.EnchantInfo:SetBackdropBorderColor(0, 0, 0, 0)
				frame.EnchantInfo:SetPoint("CENTER", frame, "CENTER", 0, 0)
			else
				frame.EnchantInfo = frame:CreateFontString(nil, "OVERLAY")
				frame.EnchantInfo:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 1, -1)
				frame.EnchantInfo:FontTemplate(LSM:Fetch("font", KA.db.durability.font), (KA.db.durability.textSize + 1), KA.db.durability.fontOutline)
			end
		end]]

		
		-- Gem Info
		--[[if not E.db.general.itemLevel.displayCharacterInfo then
			if KA.db.indicators.socket.glow.enable then
				frame.SocketHolder = T.CreateFrame('Frame', nil, frame)
				frame.SocketHolder:SetSize(37)
				frame.SocketHolder:SetBackdrop({
					bgFile = E.media.blankTex,
					edgeFile = E.media.blankTex,
					tile = false, tileSize = 0, edgeSize = E.mult,
					insets = { left = 0, right = 0, top = 0, bottom = 0}
				})
				frame.SocketHolder:SetBackdropBorderColor(0, 0, 0, 0)
				frame.SocketHolder:SetPoint("CENTER", frame, "CENTER", 0, 0)
			else
				frame.SocketHolder = T.CreateFrame('Frame', nil, frame)
				frame.SocketHolder:SetSize(12)
				frame.SocketHolder:SetBackdrop({
					bgFile = E.media.blankTex,
					edgeFile = E.media.blankTex,
					tile = false, tileSize = 0, edgeSize = E.mult,
					insets = { left = E.mult, right = E.mult, top = E.mult, bottom = E.mult }
				})
				frame.SocketHolder:SetBackdropBorderColor(0, 0, 0, 1)
				frame.SocketHolder:SetPoint(GemPoint, frame, GemParentPoint, x3 or 0, y3 or 0)
				frame.SocketHolder:SetScript('OnEnter', self.OnEnter)
				frame.SocketHolder:SetScript('OnLeave', self.OnLeave)

				frame.SocketHolder.Texture = frame.SocketHolder:CreateTexture(nil, 'OVERLAY')
				frame.SocketHolder.Texture:SetTexCoord(unpack(E.TexCoords))
				frame.SocketHolder.Texture:SetInside()
			end
		end]]
		
		-- Transmog Info
		if not frame.Transmog then
			frame.Transmog = T.CreateFrame('Button', nil, frame)
			frame.Transmog:SetSize(12, 12)
			frame.Transmog:SetScript('OnEnter', self.Transmog_OnEnter)
			frame.Transmog:SetScript('OnLeave', self.Transmog_OnLeave)
					
			frame.Transmog.Texture = frame.Transmog:CreateTexture(nil, 'OVERLAY')
			frame.Transmog.Texture:SetInside()
			frame.Transmog.Texture:SetTexture('Interface\\AddOns\\ElvUI_KlixUI\\media\\textures\\anchor')
			frame.Transmog.Texture:SetVertexColor(1, .5, 1)
					
			if id <= 7 or id == 17 or id == 11 then -- Left Side
				frame.Transmog:SetPoint("TOPLEFT", _G["Character"..slotName], "TOPLEFT", -2, 2)
				frame.Transmog.Texture:SetTexCoord(0, 1, 1, 0)
			elseif id <= 16 then -- Right Side
				frame.Transmog:SetPoint("TOPRIGHT", _G["Character"..slotName], "TOPRIGHT", 2, 2)
				frame.Transmog.Texture:SetTexCoord(1, 0, 1, 0)
			elseif id == 18 then -- Main Hand (Left side)
				frame.Transmog:SetPoint("BOTTOMRIGHT", _G["Character"..slotName], "BOTTOMRIGHT", 2, -2)
				frame.Transmog.Texture:SetTexCoord(1, 0, 0, 1)
			elseif id == 19 then -- Secondary Hand (Right side)
				frame.Transmog:SetPoint("BOTTOMLEFT", _G["Character"..slotName], "BOTTOMLEFT", -2, -2)
				frame.Transmog.Texture:SetTexCoord(0, 1, 0, 1)
			end
		end
		
		-- Illusion Info
		if not frame.Illusion then
			frame.Illusion = T.CreateFrame('Button', nil, frame)
			frame.Illusion:SetSize(14, 14)
			--frame.Illusion:SetBackdrop({
				--bgFile = E.media.blankTex,
				--edgeFile = E.media.blankTex,
				--tile = false, tileSize = 0, edgeSize = E.mult,
				--insets = { left = 0, right = 0, top = 0, bottom = 0}
			--})
			frame.Illusion:SetPoint('CENTER', _G["Character"..slotName], 'BOTTOM', 0, -2)
			frame.Illusion:SetScript('OnEnter', self.Illusion_OnEnter)
			frame.Illusion:SetScript('OnLeave', self.Illusion_OnLeave)
			frame.Illusion:CreateBackdrop()
			if _G['Character'..slotName].IconBorder then
				hooksecurefunc(_G['Character'..slotName].IconBorder, 'SetVertexColor', function(self, r, g, b)
					frame.Illusion.backdrop:SetBackdropBorderColor(r, g, b)
				end)
			end
					
			frame.Illusion.Texture = frame.Illusion:CreateTexture(nil, 'OVERLAY')
			frame.Illusion.Texture:SetInside()
			frame.Illusion.Texture:SetTexCoord(.1, .9, .1, .9)
		end
		
		-- Gradiation
		if not frame.Gradiation then
			frame.Gradiation = T.CreateFrame('Frame', nil, frame)
			frame.Gradiation:SetSize(110, _G["Character"..slotName]:GetHeight()+4)
			local characterModelFrame = _G["CharacterModelFrame"]
			frame.Gradiation:SetFrameLevel(characterModelFrame and characterModelFrame:GetFrameLevel() or frame:GetFrameLevel())

			frame.Gradiation.Texture = frame.Gradiation:CreateTexture(nil, "OVERLAY")
			frame.Gradiation.Texture:SetInside()
			frame.Gradiation.Texture:SetTexture('Interface\\AddOns\\ElvUI_KlixUI\\media\\textures\\Gradation')

			if id <= 7 or id == 17 or id == 11 or id == 19 then -- Left Side
				frame.Gradiation:SetPoint("LEFT", _G["Character"..slotName], "RIGHT", 0, 0)
				frame.Gradiation.Texture:SetTexCoord(0, 1, 0, 1)
			elseif id <= 16 or id == 18 then -- Right Side
				frame.Gradiation:SetPoint("RIGHT", _G["Character"..slotName], "LEFT", 0, 0)
				frame.Gradiation.Texture:SetTexCoord(1, 0, 0, 1)
			end
		end
	end
	
	-- Azerite Neck
	local neckSlot = _G.CharacterNeckSlot
	if neckSlot and neckSlot.RankFrame then
		neckSlot.RankFrame:StripTextures()
		neckSlot.RankFrame:CreateBackdrop("Transparent")
		neckSlot.RankFrame:SetSize(18, 18)
		neckSlot.RankFrame:SetPoint("TOP", neckSlot, 0, -3)
		neckSlot.RankFrame.Label:SetPoint("CENTER", neckSlot.RankFrame, 1, 0)
	end
end

function KA:AzeriteGlow()
	if not E.Retail then return end

	for i = 1, #AZSlots do
		local azslot = _G["Character"..AZSlots[i].."Slot"]
		local r, g, b = T.unpack(E["media"].rgbvaluecolor)

		if azslot and azslot.DisplayAsAzeriteEmpoweredItem and azslot.AzeriteTexture and azslot.AvailableTraitFrame then
			hooksecurefunc(azslot, "DisplayAsAzeriteEmpoweredItem", function(self, itemLocation)
				self.AzeriteTexture:Hide()
				self.AvailableTraitFrame:Hide()
				--PaperDollItemsFrame.EvaluateHelpTip = function(self) self.UnspentAzeriteHelpBox:Hide() end
				if HasAnyUnselectedPowers(itemLocation) then
					LCG.PixelGlow_Start(self, {r, g, b, 1}, nil, -0.25, nil, 2)
				else
					LCG.PixelGlow_Stop(self)
				end
			end)
		end
	end
end

function KA:UpdateIlvlFont()
	_G["CharacterStatsPane"].ItemLevelFrame.Value:FontTemplate(LSM:Fetch('font', KA.db.stats.ItemLevel.font), KA.db.stats.ItemLevel.size or 12, KA.db.stats.ItemLevel.outline)
	_G["CharacterStatsPane"].ItemLevelFrame:SetHeight((KA.db.stats.ItemLevel.size or 12) + 4)
	_G["CharacterStatsPane"].ItemLevelFrame.Background:SetHeight((KA.db.stats.ItemLevel.size or 12) + 4)
	if _G["CharacterStatsPane"].ItemLevelFrame.leftGrad then
		_G["CharacterStatsPane"].ItemLevelFrame.leftGrad:SetHeight((KA.db.stats.ItemLevel.size or 12) + 4)
		_G["CharacterStatsPane"].ItemLevelFrame.rightGrad:SetHeight((KA.db.stats.ItemLevel.size or 12) + 4)
	end
end

function KA:firstGarrisonToast()
	KA:UnregisterEvent("GARRISON_MISSION_FINISHED")
	self:ScheduleTimer("UpdatePaperDoll", 7)
end

function KA:Update_BG(frame)
    if KA.db.backdrop.selectedBG == "NONE" then
        frame.BG:SetTexture(nil)
    elseif KA.db.backdrop.selectedBG == "CUSTOM" then
        frame.BG:SetTexture(KA.db.backdrop.customAddress)
    elseif KA.db.backdrop.selectedBG == "CLASS" then
        frame.BG:SetTexture("Interface\\AddOns\\ElvUI_KlixUI\\media\\textures\\armory\\"..E.myclass)
    elseif KA.db.backdrop.selectedBG == "FACTION" then
        frame.BG:SetTexture("Interface\\AddOns\\ElvUI_KlixUI\\media\\textures\\armory\\"..E.myfaction)
    elseif KA.db.backdrop.selectedBG == "RACE" then
        frame.BG:SetTexture("Interface\\AddOns\\ElvUI_KlixUI\\media\\textures\\armory\\"..E.myrace)
    else
        frame.BG:SetTexture(BlizzardBackdropList[KA.db.backdrop.selectedBG] or "Interface\\AddOns\\ElvUI_KlixUI\\media\\textures\\armory\\"..KA.db.backdrop.selectedBG)
    end
    frame.BG:SetAlpha(KA.db.backdrop.alpha)
end

function KA:ElvOverlayToggle()
	local overlay = _G["CharacterModelFrameBackgroundOverlay"]
	if not overlay then return end

	if E.db.KlixUI.armory.backdrop.overlay then
		overlay:Show()
	else
		overlay:Hide()
	end
end

function KA:Initialize()
	if not E.db.KlixUI.armory.enable or not E.private.skins.blizzard.character or IsAddOnLoaded('ElvUI_SLE') then return end

	KA.db = E.db.KlixUI.armory

	KUI:RegisterDB(self, "armory")

	local CharacterFrame = _G.CharacterFrame
	local defaultCharacterWidth = CharacterFrame and CharacterFrame:GetWidth() or nil
	local defaultCharacterHeight = CharacterFrame and CharacterFrame:GetHeight() or nil

	if _G.CharacterFrame_Expand then
		hooksecurefunc("CharacterFrame_Expand", function()
	        if _G["PaperDollFrame"]:IsShown() then
	            _G["CharacterFrame"]:SetWidth(650)
	            _G["CharacterFrame"]:SetHeight(450)
				KA:UpdatePanel()
	        end
	    end)
	end
	if _G.CharacterFrame_Collapse then
		hooksecurefunc("CharacterFrame_Collapse", function()
			if CharacterFrame and defaultCharacterWidth and defaultCharacterHeight then
				CharacterFrame:SetSize(defaultCharacterWidth, defaultCharacterHeight)
			end
			KA:UpdatePanel()
		end)
	end
	
	
	local CharacterModelFrame = _G.CharacterModelFrame
	local PaperDollFrame = _G.PaperDollFrame
	E:Delay(.1, function()
		local characterModelFrame = _G.CharacterModelFrame
		local characterModelFrameBackgroundOverlay = _G.CharacterModelFrameBackgroundOverlay
		if not characterModelFrame then return end

        _G["CharacterHandsSlot"]:SetPoint("TOPRIGHT", _G["CharacterFrameInsetRight"], "TOPLEFT", -4, -2)
        _G["CharacterMainHandSlot"]:SetPoint("BOTTOMLEFT", _G["PaperDollItemsFrame"], "BOTTOMLEFT", 185, 14)
        _G["CharacterFrameInsetRight"]:SetPoint("TOPLEFT", _G["CharacterFrameInset"], "TOPRIGHT", 110, 0)
        characterModelFrame:ClearAllPoints()
        characterModelFrame:SetPoint("TOPLEFT", _G["CharacterHeadSlot"])
        characterModelFrame:SetPoint("TOPRIGHT", _G["CharacterHandsSlot"])
        characterModelFrame:SetPoint("BOTTOM", _G["CharacterMainHandSlot"])
		if characterModelFrameBackgroundOverlay then
			characterModelFrameBackgroundOverlay:SetPoint("TOPLEFT", characterModelFrame, 0, 0)
			characterModelFrameBackgroundOverlay:SetPoint("BOTTOMRIGHT", characterModelFrame, 0, 0)
	        if E.db.KlixUI.armory.backdrop.overlay then
	            characterModelFrameBackgroundOverlay:Show()
	        else
	            characterModelFrameBackgroundOverlay:Hide()
	        end
		end
    end)
	
	if CharacterModelFrame and CharacterModelFrame.BackgroundTopLeft and CharacterModelFrame.BackgroundTopLeft:IsShown() then
		CharacterModelFrame.BackgroundTopLeft:Hide()
		CharacterModelFrame.BackgroundTopRight:Hide()
		CharacterModelFrame.BackgroundBotLeft:Hide()
		CharacterModelFrame.BackgroundBotRight:Hide()

		if CharacterModelFrame.backdrop then
			CharacterModelFrame.backdrop:Hide()
		end
    end
    
	if PaperDollFrame and CharacterModelFrame then
	    local frame = T.CreateFrame("Frame", "KuiCharacterArmory", PaperDollFrame)
	    frame:SetFrameLevel(CharacterModelFrame:GetFrameLevel() - 1)
	    frame.BG = frame:CreateTexture(nil, "OVERLAY")
	    frame.BG:SetPoint("TOPLEFT", CharacterModelFrame, 0, 0)
	    frame.BG:SetPoint("BOTTOMRIGHT", CharacterModelFrame, 0, 0)
	    KA:Update_BG(frame)
	end

	EnsureNakedButton()
	UpdateClassCrest()
	
	KA:RegisterEvent("UPDATE_INVENTORY_DURABILITY", "UpdatePaperDoll", false)
	KA:RegisterEvent("PLAYER_EQUIPMENT_CHANGED", "UpdatePaperDoll", false)
	KA:RegisterEvent("SOCKET_INFO_UPDATE", "UpdatePaperDoll", false)
	KA:RegisterEvent("COMBAT_RATING_UPDATE", "UpdatePaperDoll", false)
	KA:RegisterEvent("MASTERY_UPDATE", "UpdatePaperDoll", false)
	if HasArmoryGarrisonSupport() then
		KA:RegisterEvent("GARRISON_MISSION_FINISHED", "firstGarrisonToast", false)
	end
	KA:RegisterEvent("PLAYER_ENTERING_WORLD", "InitialUpdatePaperDoll")

	if _G["CharacterStatsPane"] and _G["CharacterStatsPane"].ItemLevelFrame and _G["CharacterStatsPane"].ItemLevelCategory then
		_G["CharacterStatsPane"].ItemLevelFrame:SetPoint("TOP", _G["CharacterStatsPane"].ItemLevelCategory, "BOTTOM", 0, 6)
	end

	-- Adjust the the Model Size
	if CharacterModelFrame and PaperDollFrame then
		CharacterModelFrame:ClearAllPoints()
		CharacterModelFrame:SetSize(221, 310)
		CharacterModelFrame:SetPoint('TOPLEFT', PaperDollFrame, 'TOPLEFT', 65, -70)
	end

	KA:AzeriteGlow()
	
	if not E.db.general.itemLevel.displayCharacterInfo then
		KA:UpdateIlvlFont()
	end

	-- Stats
	if not T.IsAddOnLoaded("DejaCharacterStats") then
		if not E.Mists then
			hooksecurefunc("PaperDollFrame_UpdateStats", KA.PaperDollFrame_UpdateStats)
			KA:ToggleStats()
			if KA.DisableStatCategoryDragging then
				KA:DisableStatCategoryDragging()
			end
		end
	end
	
	-- Pawn
	if T.IsAddOnLoaded("Pawn") and _G["PawnUI_InventoryPawnButton"] and CharacterModelFrame then
        _G["PawnUI_InventoryPawnButton"]:SetFrameLevel(CharacterModelFrame:GetFrameLevel() + 1)
    end
	
	-- Stats Panel
	if E.db.KlixUI.armory.statsPanel.enable and not KUI:IsDeveloper() then
		KA:RegisterEvent("SPELLS_CHANGED")
		if PaperDollFrame then
			PaperDollFrame:HookScript("OnShow", function() KA:UpdatePanel() end)
			PaperDollFrame:HookScript("OnHide", function()
				if _G.IcyVeinStatFrame then
					_G.IcyVeinStatFrame:Hide()
				end
			end)
		end
	end
end

KUI:RegisterModule(KA:GetName())
