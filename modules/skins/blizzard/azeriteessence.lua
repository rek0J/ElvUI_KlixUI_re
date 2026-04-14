local KUI, T, E, L, V, P, G = unpack(select(2, ...))
local KS = KUI:GetModule('KuiSkins')
local S = E:GetModule('Skins')

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.azeriteEssence ~= true or E.private.KlixUI.skins.blizzard.AzeriteEssence ~= true then return end
	if not T.C_AzeriteEssence_CanOpenUI() then return end

	local AzeriteEssenceUI = _G.AzeriteEssenceUI
	AzeriteEssenceUI:Styling()

	for _, button in pairs(AzeriteEssenceUI.EssenceList.buttons) do
		if button.backdrop then
			button.backdrop:SetTemplate("Transparent")
			KS:CreateGradient(button.backdrop)
		end
	end
end

if E.Retail then
	S:AddCallbackForAddon("Blizzard_AzeriteEssenceUI", "KuiAzeriteEssenceUI", LoadSkin)
end
