local KUI, T, E, L, V, P, G = unpack(select(2, ...))
local KS = KUI:GetModule('KuiSkins')
local S = E:GetModule('Skins')

local function SkinItemInteraction()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.itemInteraction ~= true or E.private.KlixUI.skins.blizzard.ItemInteraction ~= true then return end

	local ItemInteractionFrame = _G.ItemInteractionFrame
	if ItemInteractionFrame.backdrop then
		ItemInteractionFrame.backdrop:Styling()
	end
end

S:AddCallbackForAddon("Blizzard_ItemInteractionUI", "KuiItemInteraction", SkinItemInteraction)