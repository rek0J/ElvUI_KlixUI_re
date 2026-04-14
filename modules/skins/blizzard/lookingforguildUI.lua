local KUI, T, E, L, V, P, G = unpack(select(2, ...))
local KS = KUI:GetModule('KuiSkins')
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local _G = _G
--WoW API / Variables
local hooksecurefunc = hooksecurefunc
-- GLOBALS:

local function styleLookingForGuild()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.lfguild ~= true or E.private.KlixUI.skins.blizzard.lfguild ~= true then return end

	local function SkinLFGuild(self)
		self:Styling()
	end
	hooksecurefunc("LookingForGuildFrame_OnShow", SkinLFGuild)

	local styled
	hooksecurefunc("LookingForGuildFrame_CreateUIElements", function()
		if styled then return end
		DUI:ReskinRole(_G.LookingForGuildTankButton, "TANK")
		DUI:ReskinRole(_G.LookingForGuildHealerButton, "HEALER")
		DUI:ReskinRole(_G.LookingForGuildDamagerButton, "DPS")

		styled = true
	end)
end

S:AddCallbackForAddon("Blizzard_LookingForGuildUI", "KuiLookingForGuild", styleLookingForGuild)
