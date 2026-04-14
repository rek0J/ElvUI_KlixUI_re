local KUI, T, E, L, V, P, G = unpack(select(2, ...))
local KS = KUI:GetModule('KuiSkins')
local S = E:GetModule('Skins')

local function styleCovenantPreview()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.covenantPreview) or E.private.KlixUI.skins.blizzard.covenantPreview ~= true then return end

	local frame = _G.CovenantPreviewFrame
	frame:Styling()

	frame.Title:DisableDrawLayer('BACKGROUND')
	frame.Background:SetAlpha(0)
	frame.BorderFrame:SetAlpha(0)
	frame.InfoPanel.Parchment:SetAlpha(0)
end

S:AddCallbackForAddon('Blizzard_CovenantPreviewUI', 'KuiCovenantPreview', styleCovenantPreview)
