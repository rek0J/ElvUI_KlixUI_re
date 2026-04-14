local KUI, T, E, L, V, P, G = unpack(select(2, ...))
local KS = KUI:GetModule('KuiSkins')
local S = E:GetModule('Skins')

local r, g, b = T.unpack(E["media"].rgbvaluecolor)

local function styleAuctionhouse()
	if E.Mists or E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.auctionhouse ~= true or E.private.KlixUI.skins.blizzard.auctionhouse ~= true then return end

	local Frame = _G.AuctionHouseFrame
	if not Frame then return end
	Frame:Styling()

	local ItemBuyFrame = Frame.ItemBuyFrame
	if ItemBuyFrame and ItemBuyFrame.ItemDisplay and ItemBuyFrame.ItemDisplay.backdrop then
		KS:CreateGradient(ItemBuyFrame.ItemDisplay.backdrop)
	end
	if ItemBuyFrame and ItemBuyFrame.ItemList and ItemBuyFrame.ItemList.backdrop then
		KS:CreateGradient(ItemBuyFrame.ItemList.backdrop)
	end

	local CommoditiesBuyFrame = Frame.CommoditiesBuyFrame
	if CommoditiesBuyFrame and CommoditiesBuyFrame.BuyDisplay and CommoditiesBuyFrame.BuyDisplay.ItemDisplay and CommoditiesBuyFrame.BuyDisplay.ItemDisplay.backdrop then
		KS:CreateGradient(CommoditiesBuyFrame.BuyDisplay.ItemDisplay.backdrop)
	end
	if CommoditiesBuyFrame and CommoditiesBuyFrame.ItemList and CommoditiesBuyFrame.ItemList.backdrop then
		KS:CreateGradient(CommoditiesBuyFrame.ItemList.backdrop)
	end

	local ItemSellFrame = Frame.ItemSellFrame
	if ItemSellFrame and ItemSellFrame.ItemDisplay and ItemSellFrame.ItemDisplay.backdrop then
		KS:CreateGradient(ItemSellFrame.ItemDisplay.backdrop)
	end
	if Frame.ItemSellList and Frame.ItemSellList.ScrollFrame and Frame.ItemSellList.ScrollFrame.backdrop then
		KS:CreateGradient(Frame.ItemSellList.ScrollFrame.backdrop)
	end

	local AuctionsFrame = _G.AuctionHouseFrameAuctionsFrame
	if AuctionsFrame and AuctionsFrame.ItemDisplay and AuctionsFrame.ItemDisplay.backdrop then
		KS:CreateGradient(AuctionsFrame.ItemDisplay.backdrop)
	end
	if AuctionsFrame and AuctionsFrame.ItemList and AuctionsFrame.ItemList.ScrollFrame and AuctionsFrame.ItemList.ScrollFrame.backdrop then
		KS:CreateGradient(AuctionsFrame.ItemList.ScrollFrame.backdrop)
	end
	if AuctionsFrame and AuctionsFrame.CommoditiesList and AuctionsFrame.CommoditiesList.ScrollFrame and AuctionsFrame.CommoditiesList.ScrollFrame.backdrop then
		KS:CreateGradient(AuctionsFrame.CommoditiesList.ScrollFrame.backdrop)
	end
end

S:AddCallbackForAddon("Blizzard_AuctionHouseUI", "KuiAuctionhouse", styleAuctionhouse)
