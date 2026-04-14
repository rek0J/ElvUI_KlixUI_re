local KUI, T, E, L, V, P, G = unpack(select(2, ...))
local KS = KUI:GetModule('KuiSkins')
local S = E:GetModule('Skins')

local function styleAnimaDiversion()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.animaDiversion ~= true or E.private.KlixUI.skins.blizzard.animaDiversion ~= true then return end

	local frame = _G.AnimaDiversionFrame
	if frame.backdrop then
		frame.backdrop:Styling()
	end

end

S:AddCallbackForAddon("Blizzard_AnimaDiversionUI", "KuiAnimaDiversion", styleAnimaDiversion)
