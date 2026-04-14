local KUI, T, E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local _G = _G
--WoW API / Variables
-- GLOBALS:

local function styleVoidstorage()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.voidstorage ~= true or E.private.KlixUI.skins.blizzard.voidstorage ~= true then return end

	local VoidStorageFrame = _G.VoidStorageFrame
	VoidStorageFrame:Styling()

	VoidStorageFrame.Page1:ClearAllPoints()
	VoidStorageFrame.Page1:SetPoint("LEFT", VoidStorageFrame, "TOPRIGHT", 2, -60)
end

S:AddCallbackForAddon("Blizzard_VoidStorageUI", "KuiVoidStorage", styleVoidstorage)