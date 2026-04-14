local KUI, T, E, L, V, P, G = unpack(select(2, ...))
local KS = KUI:GetModule('KuiSkins')
local S = E:GetModule('Skins')

--Cache global variables
local _G = _G
local unpack = unpack
local hooksecurefunc = hooksecurefunc
--WoW API / Variables
-- GLOBALS:

local r, g, b = T.unpack(E["media"].rgbvaluecolor)

local function styleUIDropDownMenu()
	if E.private.skins.blizzard.enable ~= true then return end

	hooksecurefunc("UIDropDownMenu_SetIconImage", function(icon, texture)
		if texture:find("Divider") then
			icon:SetColorTexture(r, g, b, .8)
			icon:SetHeight(1)
		end
	end)
end

S:AddCallback("KuiUIDropDownMenu", styleUIDropDownMenu)
