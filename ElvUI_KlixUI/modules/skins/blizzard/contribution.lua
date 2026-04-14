local KUI, T, E, L, V, P, G = unpack(select(2, ...))
local KS = KUI:GetModule('KuiSkins')
local S = E:GetModule('Skins')

local function styleContribution()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.Contribution ~= true or E.private.KlixUI.skins.blizzard.contribution ~= true then return end

	--Main Frame
	_G.ContributionCollectionFrame:StripTextures()
	KS:CreateBD(_G.ContributionCollectionFrame, .25)

	_G.ContributionCollectionFrame:Styling()

	local function styleText(self)
		self.Description:SetVertexColor(1, 1, 1)
	end
	hooksecurefunc(_G.ContributionMixin, "Setup", styleText)

	local function styleRewardText(self)
		self.RewardName:SetTextColor(1, 1, 1)
	end
	hooksecurefunc(_G.ContributionRewardMixin, "Setup", styleRewardText)
end

S:AddCallbackForAddon("Blizzard_Contribution", "KuiContribution", styleContribution)