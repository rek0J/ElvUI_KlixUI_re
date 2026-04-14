local KUI, T, E, L, V, P, G = unpack(select(2, ...))
local KB = KUI:NewModule("KuiBags", "AceHook-3.0", "AceEvent-3.0")
local KS = KUI:GetModule('KuiSkins')
local S = E:GetModule('Skins')
local B = E:GetModule("Bags")

local function HasElvUIBagSupport()
	return E.private.bags.enable and B and B.BagFrames and B.GetContainerNumSlots
end

-- Styling
function KB:SkinBags()
	if _G.ElvUI_ContainerFrame then
		_G.ElvUI_ContainerFrame:Styling()
		_G.ElvUI_ContainerFrameContainerHolder:Styling()
	end

	if _G.ElvUIBags then
		_G.ElvUIBags.backdrop:Styling()
	end
end

function KB:SkinBank()
	if _G.ElvUI_BankContainerFrame then
		_G.ElvUI_BankContainerFrame:Styling()
		_G.ElvUI_BankContainerFrameContainerHolder:Styling()
	end
end

function KB:AllInOneBags()
	self:SkinBags()
	hooksecurefunc(B, "OpenBank", KB.SkinBank)
end

function KB:SkinBlizzBags()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.bags ~= true or E.private.bags.enable then return end

	for i = 1, NUM_CONTAINER_FRAMES, 1 do
		local container = _G['ContainerFrame'..i]
		if container.backdrop then
			container.backdrop:Styling()
		end
	end
	if _G.BankFrame then
		_G.BankFrame:Styling()
	end
end

function KB:GUILDBANKFRAME_OPENED()
	T.OpenAllBags()
end

function KB:GUILDBANKFRAME_CLOSED()
	_G.ContainerFrame1.backpackWasOpen = nil
	T.CloseAllBags()
end

function KB:AUCTION_HOUSE_SHOW()
	T.OpenAllBags()
end

function KB:AUCTION_HOUSE_CLOSED()
	_G.ContainerFrame1.backpackWasOpen = nil
	T.CloseAllBags()
end

function KB:TRADE_SHOW()
	T.OpenAllBags()
end

function KB:TRADE_CLOSED()
	_G.ContainerFrame1.backpackWasOpen = nil
	T.CloseAllBags()
end

local function HasObliterumForgeSupport()
	return E.Retail
end

function KB:OBLITERUM_FORGE_SHOW()
	if not HasObliterumForgeSupport() then return end
	T.OpenAllBags()
end

function KB:OBLITERUM_FORGE_CLOSE()
	if not HasObliterumForgeSupport() then return end
	_G.ContainerFrame1.backpackWasOpen = nil
	T.CloseAllBags()
end

function KB:HookBags(isBank)
	if not HasElvUIBagSupport() then return end

	local slot
	for _, bagFrame in T.pairs(B.BagFrames) do
		if bagFrame and bagFrame.BagIDs and bagFrame.Bags then
			-- Apply shadow for all current bagslots
			for _, bagID in pairs(bagFrame.BagIDs) do
				for slotID = 1, B:GetContainerNumSlots(bagID) do
					if bagFrame.Bags[bagID] then
						slot = bagFrame.Bags[bagID][slotID]
						if slot then
							slot:CreateIconShadow()
						end
					end
				end
			end
		end
	end
	
	-- Apply shadow for reagent bank
	if _G.ElvUIReagentBankFrameItem1 then
		for slotID = 1, 98 do
			local slot = _G["ElvUIReagentBankFrameItem"..slotID]
			if slot then
				slot:CreateIconShadow()
			end
		end
	end
	
	-- Apply shadow for bagbar
	if _G.ElvUI_ContainerFrameContainerHolder then
		if _G.ElvUIMainBagBackpack then
			_G.ElvUIMainBagBackpack:CreateIconShadow()
		end
		
		for bagSlot = 0, 3 do
			local bag = _G["ElvUIMainBag"..bagSlot.."Slot"]
			if bag then
				bag:CreateIconShadow()
			end
		end
	end
	
	-- Apply shadow for the bag buttons
	if _G.ElvUI_ContainerFrame then
		if _G.ElvUI_ContainerFrame.vendorGraysButton then
			_G.ElvUI_ContainerFrame.vendorGraysButton:CreateIconShadow()
		end
		if _G.ElvUI_ContainerFrameBagsButton then
			_G.ElvUI_ContainerFrameBagsButton:CreateIconShadow()
		end
		if _G.ElvUI_ContainerFrameSortButton then
			_G.ElvUI_ContainerFrameSortButton:CreateIconShadow()
		end
	end
end

function KB:Initialize()
	if not HasElvUIBagSupport() then return end
	
	KB.db = E.db.KlixUI.bags
	
	self:AllInOneBags()
	self:SkinBlizzBags()
	self:SkinBank()
	
	KB:RegisterEvent("GUILDBANKFRAME_OPENED")
	KB:RegisterEvent("GUILDBANKFRAME_CLOSED")
	KB:RegisterEvent("AUCTION_HOUSE_SHOW")
	KB:RegisterEvent("AUCTION_HOUSE_CLOSED")
	KB:RegisterEvent("TRADE_SHOW")
	KB:RegisterEvent("TRADE_CLOSED")
	if HasObliterumForgeSupport() then
		KB:RegisterEvent("OBLITERUM_FORGE_SHOW")
		KB:RegisterEvent("OBLITERUM_FORGE_CLOSE")
	end
	
	KB:RegisterEvent("BANKFRAME_OPENED")
	KB:RegisterEvent("BANKFRAME_CLOSED")
	KB:RegisterEvent("MAIL_SHOW")
	KB:RegisterEvent("MAIL_CLOSED")
	KB:RegisterEvent("MERCHANT_SHOW")
	KB:RegisterEvent("MERCHANT_CLOSED")
	KB:RegisterEvent("BAG_UPDATE_DELAYED")
	
	-- Applying stuff to already existing bags
	self:HookBags()
	hooksecurefunc(B, "Layout", function(self, isBank)
		KB:HookBags(isBank)
	end)
	
	-- This table is for initial update of a frame, cause applying transparent template breaks color borders
	KB.InitialUpdates = {
		Bank = false,
		ReagentBank = false,
		ReagentBankButton = false,
	}

	-- Fix borders for bag frames
	hooksecurefunc(B, "OpenBank", function()
		if not KB.InitialUpdates.Bank then --For bank, just update on first show
			B:Layout(true)
			KB.InitialUpdates.Bank = true
		end
		local reagentToggle = _G.ElvUI_BankContainerFrame and _G.ElvUI_BankContainerFrame.reagentToggle
		if reagentToggle and not KB.InitialUpdates.ReagentBankButton then --For reagent bank, hook to toggle button and update layout when first clicked
			reagentToggle:HookScript("OnClick", function()
				if not KB.InitialUpdates.ReagentBank then
					B:Layout(true)
					KB.InitialUpdates.ReagentBank = true
				end
			end)
			KB.InitialUpdates.ReagentBankButton = true
		end
	end)
end

KUI:RegisterModule(KB:GetName())
