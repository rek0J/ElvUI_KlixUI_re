local KUI, T, E, L, V, P, G = unpack(select(2, ...))
local KS = KUI:GetModule('KuiSkins')
local S = E:GetModule('Skins')

local function styleHelp()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.help ~= true or E.private.KlixUI.skins.blizzard.help ~= true then return end

	local frame = _G.HelpFrame
	if frame.backdrop then
		frame.backdrop:Styling()
	end
end

S:AddCallback("KuiHelp", styleHelp)