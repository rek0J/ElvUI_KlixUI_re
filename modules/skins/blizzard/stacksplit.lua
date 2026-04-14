local KUI, T, E, L, V, P, G = unpack(select(2, ...))
local KS = KUI:GetModule('KuiSkins')
local S = E:GetModule('Skins')

--Cache global variables
local _G = _G
local pairs, unpack = pairs, unpack
--WoW API / Variables
-- GLOBALS:

local r, g, b = T.unpack(E["media"].rgbvaluecolor)

local function styleStyleStackSplitFrame()
	if E.private.skins.blizzard.enable ~= true then return end

	local StackSplitFrame = _G.StackSplitFrame
	StackSplitFrame:Styling()
end

S:AddCallback("KuiStackSplitFrame", styleStyleStackSplitFrame)