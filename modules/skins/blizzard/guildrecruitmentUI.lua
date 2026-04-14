local KUI, T, E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule('Skins')

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.guild ~= true then return end

	local rolesFrame = _G.CommunitiesGuildRecruitmentFrameRecruitment.RolesFrame
	KUI:ReskinRole(rolesFrame.TankButton, "TANK")
	KUI:ReskinRole(rolesFrame.HealerButton, "HEALER")
	KUI:ReskinRole(rolesFrame.DamagerButton, "DPS")
end

S:AddCallbackForAddon("Blizzard_GuildRecruitmentUI", "KuiGuildRecruitment", LoadSkin)
