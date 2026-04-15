local KUI, T, E, L, V, P, G = unpack(select(2, ...))
local KS = KUI:GetModule('KuiSkins')
local S = E:GetModule('Skins')
local C_SpecializationInfo = _G.C_SpecializationInfo
local GetNumSpecializations = T.GetNumSpecializations or (C_SpecializationInfo and C_SpecializationInfo.GetNumSpecializations)
local GetSpecialization = T.GetSpecialization or (C_SpecializationInfo and C_SpecializationInfo.GetSpecialization)
local GetSpecializationInfo = T.GetSpecializationInfo or (C_SpecializationInfo and C_SpecializationInfo.GetSpecializationInfo)
local GetSpecializationRole = T.GetSpecializationRole or _G.GetSpecializationRole or (C_SpecializationInfo and C_SpecializationInfo.GetSpecializationRole)
local GetSpecializationSpells = T.GetSpecializationSpells or _G.GetSpecializationSpells
local GetPvpTalentInfoByID = _G.GetPvpTalentInfoByID
local C_SpecializationInfo_IsInitialized = T.C_SpecializationInfo_IsInitialized or (C_SpecializationInfo and C_SpecializationInfo.IsInitialized)
local C_SpecializationInfo_GetSpellsDisplay = T.C_SpecializationInfo_GetSpellsDisplay or (C_SpecializationInfo and C_SpecializationInfo.GetSpellsDisplay)
local MAX_TALENT_TIERS = _G.MAX_TALENT_TIERS or 7
local NUM_TALENT_COLUMNS = _G.NUM_TALENT_COLUMNS or 3

local r, g, b = T.unpack(E["media"].rgbvaluecolor)

local function styleTalents()
	if E.Mists then return end
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.talent ~= true or E.private.KlixUI.skins.blizzard.talent ~= true then return end
	
	_G.PlayerTalentFrame:Styling()

	-- Specc
	for i = 1, (GetNumSpecializations and GetNumSpecializations(false, nil) or 0) do
		local bu = _G.PlayerTalentFrameSpecialization and _G.PlayerTalentFrameSpecialization["specButton"..i]
		local _, _, _, icon = GetSpecializationInfo and GetSpecializationInfo(i, false, nil)

		if bu and bu.ring and bu.specIcon then
			bu.ring:Hide()

			bu.specIcon:SetTexture(icon)
			bu.specIcon:SetTexCoord(T.unpack(E.TexCoords))
			bu.specIcon:SetSize(50, 50)
			bu.specIcon:SetPoint("LEFT", bu, "LEFT", 15, 0)

			bu.SelectedTexture = bu:CreateTexture(nil, "BACKGROUND")
			bu.SelectedTexture:SetColorTexture(r, g, b, .5)
		end
	end

	-- Talents
	for i = 1, MAX_TALENT_TIERS do
		local row = _G.PlayerTalentFrameTalents and _G.PlayerTalentFrameTalents['tier'..i]
		for j = 1, NUM_TALENT_COLUMNS do
			local bu = row and row['talent'..j]
			if bu and bu.bg then
				KS:CreateGradient(bu.bg)
				if bu.bg.backdrop then
					bu.bg.backdrop:SetTemplate("Transparent")
				elseif bu.bg.SetTemplate then
					bu.bg:SetTemplate("Transparent")
				end
				if bu.bg.SelectedTexture then
					bu.bg.SelectedTexture:SetColorTexture(r, g, b, .5)
				end
			end
		end
	end

	for _, frame in T.pairs({ _G.PlayerTalentFrameSpecialization, _G.PlayerTalentFramePetSpecialization }) do
		local scrollChild = frame and frame.spellsScroll and frame.spellsScroll.child
		local roleIcon = scrollChild and scrollChild.roleIcon

		if scrollChild and roleIcon and scrollChild.ring and scrollChild.specIcon then
			scrollChild.ring:Hide()
			scrollChild.specIcon:SetTexCoord(T.unpack(E.TexCoords))
			scrollChild.specIcon:Size(70, 70)

			roleIcon:SetTexture(E.media.roleIcons)

			local left = scrollChild:CreateTexture(nil, "OVERLAY")
			left:SetWidth(1)
			left:SetTexture(E["media"].normTex)
			left:SetVertexColor(0, 0, 0)
			left:SetPoint("TOPLEFT", roleIcon, 3, -3)
			left:SetPoint("BOTTOMLEFT", roleIcon, 3, 4)

			local right = scrollChild:CreateTexture(nil, "OVERLAY")
			right:SetWidth(1)
			right:SetTexture(E["media"].normTex)
			right:SetVertexColor(0, 0, 0)
			right:SetPoint("TOPRIGHT", roleIcon, -3, -3)
			right:SetPoint("BOTTOMRIGHT", roleIcon, -3, 4)

			local top = scrollChild:CreateTexture(nil, "OVERLAY")
			top:SetHeight(1)
			top:SetTexture(E["media"].normTex)
			top:SetVertexColor(0, 0, 0)
			top:SetPoint("TOPLEFT", roleIcon, 3, -3)
			top:SetPoint("TOPRIGHT", roleIcon, -3, -3)

			local bottom = scrollChild:CreateTexture(nil, "OVERLAY")
			bottom:SetHeight(1)
			bottom:SetTexture(E["media"].normTex)
			bottom:SetVertexColor(0, 0, 0)
			bottom:SetPoint("BOTTOMLEFT", roleIcon, 3, 4)
			bottom:SetPoint("BOTTOMRIGHT", roleIcon, -3, 4)
		end
	end

	if GetSpecialization and GetSpecializationInfo and GetNumSpecializations then
		hooksecurefunc("PlayerTalentFrame_UpdateSpecFrame", function(self, spec)
			if C_SpecializationInfo_IsInitialized and not C_SpecializationInfo_IsInitialized() then
				return
			end

			local playerTalentSpec = GetSpecialization(nil, self.isPet, _G.PlayerSpecTab2 and _G.PlayerSpecTab2:GetChecked() and 2 or 1)
			local shownSpec = spec or playerTalentSpec or 1
			local numSpecs = GetNumSpecializations(nil, self.isPet) or 0

			local sex = self.isPet and T.UnitSex("pet") or T.UnitSex("player")
			local id, _, _, icon = GetSpecializationInfo(shownSpec, nil, self.isPet, nil, sex)
			local scrollChild = self.spellsScroll and self.spellsScroll.child
			if not scrollChild then return end

			if scrollChild.specIcon then
				scrollChild.specIcon:SetTexture(icon)
			end

			local index = 1
			local bonuses
			local bonusesIncrement = 1;
			if self.isPet then
				if GetSpecializationSpells then
					bonuses = {GetSpecializationSpells(shownSpec, nil, self.isPet, true)}
				end
				bonusesIncrement = 2;
			else
				bonuses = C_SpecializationInfo_GetSpellsDisplay and C_SpecializationInfo_GetSpellsDisplay(id)
			end

			if bonuses then
				for i = 1, #bonuses, bonusesIncrement do
					local frame = scrollChild["abilityButton"..index]
					local _, spellIcon = T.GetSpellTexture(bonuses[i])

					if frame and frame.icon then
						frame.icon:SetTexture(spellIcon)
						if frame.subText then
							frame.subText:SetTextColor(.75, .75, .75)
						end

						if not frame.styled and not frame.backdrop then
							if frame.ring then
								frame.ring:Hide()
							end
							frame.icon:SetTexCoord(T.unpack(E.TexCoords))
							KS:CreateBG(frame.icon)

							frame.styled = true
						end
					end
					index = index + 1
				end
			end

			for i = 1, numSpecs do
				local bu = self["specButton"..i]

				if bu and bu.roleName then
					if bu.disabled then
						bu.roleName:SetTextColor(.5, .5, .5)
					else
						bu.roleName:SetTextColor(1, 1, 1)
					end
				end
			end
		end)
	end

	local buttons = {"PlayerTalentFrameSpecializationSpecButton", "PlayerTalentFramePetSpecializationSpecButton"}

	for _, name in T.pairs(buttons) do
		for i = 1, 4 do
			local bu = _G[name..i]

			if bu and bu.backdrop then
				bu.backdrop:SetTemplate("Transparent")
				KS:CreateGradient(bu.backdrop)
			end

			if bu and bu.roleIcon then
				local roleIcon = bu.roleIcon
				roleIcon:SetTexture(E.media.roleIcons)
				local role = GetSpecializationRole and GetSpecializationRole(i, false, bu.isPet)
				if role then
					roleIcon:SetTexCoord(KUI:GetRoleTexCoord(role))
				end
			end
		end
	end

	-- PvP Talents
	local PvpTalentFrame = _G.PlayerTalentFrameTalents and _G.PlayerTalentFrameTalents.PvpTalentFrame

	if PvpTalentFrame and PvpTalentFrame.Slots and GetPvpTalentInfoByID then
		for _, button in pairs(PvpTalentFrame.Slots) do
			button:CreateBackdrop()
			button.backdrop:SetOutside(button.Texture)

			hooksecurefunc(button, "Update", function(self)
				local selectedTalentID = self.predictedSetting:Get()
				if selectedTalentID then
					local _, _, texture = GetPvpTalentInfoByID(selectedTalentID)
					self.Texture:SetTexture(texture)
					self.Texture:SetTexCoord(0.1, 0.9, 0.1, 0.9)
				else
					self.Texture:SetTexCoord(.15, .85, .15, .85)
				end
			end)
		end

		local PlayerTalentFrameTalentsPvpTalentFrameTalentList = _G.PlayerTalentFrameTalentsPvpTalentFrameTalentList
		if PlayerTalentFrameTalentsPvpTalentFrameTalentList and PlayerTalentFrameTalentsPvpTalentFrameTalentList.backdrop then
			PlayerTalentFrameTalentsPvpTalentFrameTalentList.backdrop:Styling()
		end

		for i = 1, 10 do
			local bu = _G["PlayerTalentFrameTalentsPvpTalentFrameTalentListScrollFrameButton"..i]
			if bu then
				local icon = bu.Icon
				-- Hide ElvUI backdrop
				if bu.backdrop then
					bu.backdrop:Hide()
				end

				KS:Reskin(bu)

				if bu.Selected then
					bu.Selected:SetTexture(nil)

					bu.selectedTexture = bu:CreateTexture(nil, "ARTWORK")
					bu.selectedTexture:SetInside(bu)
					bu.selectedTexture:SetColorTexture(r, g, b, .5)
					bu.selectedTexture:SetShown(bu.Selected:IsShown())

					hooksecurefunc(bu, "Update", function(selectedHere)
						if not bu.selectedTexture then return end
						if bu.Selected:IsShown() then
							bu.selectedTexture:SetShown(selectedHere)
						else
							bu.selectedTexture:Hide()
						end
					end)
				end

				if bu.backdrop then
					bu.backdrop:SetAllPoints()
				end

				if icon then
					icon:SetTexCoord(T.unpack(E.TexCoords))
					icon:SetDrawLayer("ARTWORK", 1)
				end
			end
		end
	end
end

S:AddCallbackForAddon("Blizzard_TalentUI", "KuiTalents", styleTalents)
