local KUI, T, E, L, V, P, G = unpack(select(2, ...))
local KS = KUI:GetModule('KuiSkins')
local S = E:GetModule('Skins')

local _G = _G

local function styleGMChat()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.GMChat ~= true or E.private.KlixUI.skins.blizzard.GMChat ~= true then return end

	if _G.GMChatFrame.backdrop then
		_G.GMChatFrame.backdrop:Styling()
	end

	if _G.GMChatTab.backdrop then
		_G.GMChatTab.backdrop:Styling()
	end
end

S:AddCallbackForAddon("Blizzard_GMChatUI", "KuiGMChatUI", styleGMChat)
