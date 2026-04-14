local KUI, T, E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule('Skins')

local function styleAddonManager()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.addonManager ~= true or E.private.KlixUI.skins.blizzard.addonManager ~= true then return end

	_G.AddonList:Styling()
	if _G.AddonCharacterDropDown then
		_G.AddonCharacterDropDown:SetWidth(170)
	end -- MoP Classic: AddonCharacterDropDown may not exist, skip if missing
end

S:AddCallback("KuiAddonManager", styleAddonManager)