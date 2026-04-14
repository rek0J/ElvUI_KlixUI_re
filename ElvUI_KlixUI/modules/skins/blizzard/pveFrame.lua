local KUI, T, E, L, V, P, G = unpack(select(2, ...))
local KS = KUI:GetModule('KuiSkins')
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local _G = _G
--WoW API / Variables
-- GLOBALS:

local function stylePVE()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.lfg ~= true or E.private.KlixUI.skins.blizzard.lfg ~= true then return; end

	local PVEFrame = _G.PVEFrame
	PVEFrame:Styling()

	local iconSize = 56-2*E.mult
	for i = 1, 3 do
		local bu = _G["GroupFinderFrame"]["groupButton"..i]
	
		KS:Reskin(bu)

		bu.name:SetTextColor(1, 1, 1)

		bu.icon:SetSize(iconSize, iconSize)
		bu.icon:SetDrawLayer("OVERLAY")
		bu.icon:ClearAllPoints()
		bu.icon:SetPoint("LEFT", bu, "LEFT", 5, 0)
	end
end

S:AddCallback("KuiPVE", stylePVE)