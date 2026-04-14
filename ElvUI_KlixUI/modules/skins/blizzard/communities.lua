local KUI, T, E, L, V, P, G = unpack(select(2, ...))
local KS = KUI:GetModule('KuiSkins')
local S = E:GetModule('Skins')

local r, g, b = T.unpack(E["media"].rgbvaluecolor)

local function styleCommunities()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.Communities ~= true or E.private.KlixUI.skins.blizzard.communities ~= true then return end
	local CommunitiesFrame = _G.CommunitiesFrame
	if CommunitiesFrame.backdrop then
	CommunitiesFrame.backdrop:Styling()
	end

	-- Active Communities
	hooksecurefunc(_G.CommunitiesListEntryMixin, "SetClubInfo", function(self, clubInfo, isInvitation, isTicket)
		if clubInfo then
			if self.bg and self.bg.backdrop and not self.IsStyled then
				KS:CreateGradient(self.bg.backdrop)
				self.IsStyled = true
			end
		end
	end)

	-- Add Community Button
	hooksecurefunc(_G.CommunitiesListEntryMixin, "SetAddCommunity", function(self)
		if self.bg and self.bg.backdrop and not self.IsStyled then
			KS:CreateGradient(self.bg.backdrop)
			self.IsStyled = true
		end
	end)

	for _, name in T.next, {"ChatTab", "RosterTab", "GuildBenefitsTab", "GuildInfoTab"} do
		local tab = CommunitiesFrame[name]
		tab:GetRegions():Hide()
		KS:ReskinIcon(tab.Icon)
		tab:GetHighlightTexture():SetColorTexture(r, g, b, .25)
	end

	-- Chat Tab
	local Dialog = CommunitiesFrame.NotificationSettingsDialog
	Dialog:StripTextures()
	Dialog.BG:Hide()
	if Dialog.backdrop then
	Dialog.backdrop:Styling()
	end

	KS:Reskin(Dialog.OkayButton)
	KS:Reskin(Dialog.CancelButton)
	Dialog.ScrollFrame.Child.QuickJoinButton:Size(25, 25)
	KS:Reskin(Dialog.ScrollFrame.Child.AllButton)
	KS:Reskin(Dialog.ScrollFrame.Child.NoneButton)

	hooksecurefunc(Dialog, "Refresh", function(self)
		local frame = self.ScrollFrame.Child
		for i = 1, frame:GetNumChildren() do
			local child = T.select(i, frame:GetChildren())
			if child.StreamName and not child.styled then
				KS:Reskin(child.ShowNotificationsButton)
				KS:Reskin(child.HideNotificationsButton)

				child.styled = true
			end
		end
	end)

	local Dialog = CommunitiesFrame.EditStreamDialog
	KS:CreateBDFrame(Dialog.Description, .25)
	if Dialog.backdrop then
	Dialog.backdrop:Styling()
	end

	-- Roster
	KS:CreateBDFrame(CommunitiesFrame.MemberList.ListScrollFrame, .25)

	local DetailFrame = CommunitiesFrame.GuildMemberDetailFrame
	DetailFrame:ClearAllPoints()
	DetailFrame:Point("TOPLEFT", CommunitiesFrame, "TOPRIGHT", 34, 0)
	DetailFrame:Styling()

	-- Guild Perks
	hooksecurefunc("CommunitiesGuildPerks_Update", function(self)
		local buttons = self.Container.buttons
		for i = 1, #buttons do
			local button = buttons[i]
			if button and button.backdrop and not button.isStyled then
				button.backdrop:SetTemplate("Transparent")
				button.backdrop:Point("TOPLEFT", button.Icon, -1, 1)
				button.backdrop:Point("BOTTOMRIGHT", button.Right, 1, -1)
				KS:CreateGradient(button.backdrop)
				button.isStyled = true
			end
		end
	end)

	-- Guild Rewards
	hooksecurefunc("CommunitiesGuildRewards_Update", function(self)
		local buttons = self.RewardsContainer.buttons
		for i = 1, #buttons do
			local button = buttons[i]
			if button and button.backdrop and not button.isStyled then
				button.backdrop:SetTemplate("Transparent")
				button.backdrop:Point("TOPLEFT", button.Icon, 0, 1)
				button.backdrop:Point("BOTTOMRIGHT", 0, 3)
				KS:CreateGradient(button.backdrop)

				if button.hover then
					button.hover:SetInside(button.backdrop)
					button.hover:SetColorTexture(r, g, b, 0.3)
				end

				button.DisabledBG:Hide()
				button.isStyled = true
			end
		end
	end)

	-- Guild Recruitment
	local GuildRecruitmentFrame = _G.CommunitiesGuildRecruitmentFrame
	if GuildRecruitmentFrame.backdrop then
	GuildRecruitmentFrame.backdrop:Styling()
	end

	if CommunitiesFrame.RecruitmentDialog.backdrop then
		CommunitiesFrame.RecruitmentDialog.backdrop:Styling()
	end

	-- Guild Log
	local GuildLog = _G.CommunitiesGuildLogFrame
	GuildLog:Styling()

	--Guild MOTD Edit
	local GuildText = _G.CommunitiesGuildTextEditFrame
	GuildText:Styling()

	-- Guild News Filter
	local GuildNewsFilter = _G.CommunitiesGuildNewsFiltersFrame
	if GuildNewsFilter.backdrop then
	GuildNewsFilter.backdrop:Styling()
	end
end

S:AddCallbackForAddon("Blizzard_Communities", "KuiCommunities", styleCommunities)
