local KUI, T, E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule('Skins')

-- Cache global variables
-- Lua functions
local _G = _G
-- WoW API / Variables
-- GLOBALS:

local function LoadAddOnSkin()
	if E.private.KlixUI.skins.addonSkins.tb ~= true or not T.IsAddOnLoaded("TextureBrowser") then return end

	local frame = _G.TextureBrowser
	frame:StripTextures()

	frame:CreateBackdrop("Transparent")
	frame.backdrop:Styling()
	frame.outline:SetTemplate("Transparent")

	S:HandleCloseButton(frame.close)
	S:HandleScrollBar(_G.TextureBrowserScrollScrollBar)
	S:HandleButton(frame.btnFilter)
end

S:AddCallbackForAddon("TextureBrowser", "KUITextureBrowser", LoadAddOnSkin)
