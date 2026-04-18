local KUI, T, E, L, V, P, G = unpack(select(2, ...))
local KS = KUI:GetModule('KuiSkins')
local S = E:GetModule('Skins')

-- Cache globals
local _G = _G
local select, unpack = select, unpack

-- WoW API / Variables
local hooksecurefunc = hooksecurefunc
local GetInspectSpecialization = GetInspectSpecialization
local GetSpecializationRoleByID = GetSpecializationRoleByID
local GetSpecializationInfoByID = GetSpecializationInfoByID
local UnitGUID = UnitGUID

local r, g, b = T.unpack(E.media.rgbvaluecolor)

local function updateIcon(self)
	if not self or not self.specIcon then return end

	local spec
	if _G.INSPECTED_UNIT then
		spec = T.GetInspectSpecialization(_G.INSPECTED_UNIT)
	end

	if spec and spec > 0 then
		local role = T.GetSpecializationRoleByID(spec)
		if role then
			local _, _, _, icon = T.GetSpecializationInfoByID(spec)
			if icon then
				self.specIcon:SetTexture(icon)
			end
		end
	end
end

local function styleInspect()
	if E.private.skins.blizzard.enable ~= true
		or E.private.skins.blizzard.inspect ~= true
		or E.private.KlixUI.skins.blizzard.inspect ~= true
	then
		return
	end

	local InspectFrame = _G.InspectFrame
	local InspectModelFrame = _G.InspectModelFrame
	local InspectTalentFrame = _G.InspectTalentFrame
	local InspectGuildFrameBG = _G.InspectGuildFrameBG
	local InspectPaperDollFrame = _G.InspectPaperDollFrame

	if not InspectFrame then return end

	if InspectModelFrame and InspectModelFrame.DisableDrawLayer then
		InspectModelFrame:DisableDrawLayer("OVERLAY")
	end

	if InspectFrame.backdrop then
		InspectFrame.backdrop:Styling()
	end

	if InspectTalentFrame then
		local regions = { InspectTalentFrame:GetRegions() }
		if regions[1] then regions[1]:Hide() end
		if regions[2] then regions[2]:Hide() end
	end

	if InspectGuildFrameBG then
		InspectGuildFrameBG:Hide()
	end

	if InspectModelFrame and InspectModelFrame.backdrop then
		InspectModelFrame.backdrop:Hide()
	end

	if InspectModelFrame then
		local regions = { InspectModelFrame:GetRegions() }
		for i = 1, 5 do
			if regions[i] then
				regions[i]:Hide()
			end
		end
	end

	-- MoP Classic safety: ViewButton may not exist
	local viewButton = InspectPaperDollFrame and InspectPaperDollFrame.ViewButton
	if viewButton then
		viewButton:ClearAllPoints()
		viewButton:SetPoint("TOP", InspectFrame, 0, -45)
	end

	-- Character
	if _G.InspectMainHandSlot then
		local mhRegions = { _G.InspectMainHandSlot:GetRegions() }
		if mhRegions[11] then
			mhRegions[11]:Hide()
		end
	end

	local slots = {
		"Head", "Neck", "Shoulder", "Shirt", "Chest", "Waist", "Legs", "Feet", "Wrist",
		"Hands", "Finger0", "Finger1", "Trinket0", "Trinket1", "Back", "MainHand",
		"SecondaryHand", "Tabard",
	}

	for i = 1, #slots do
		local slot = _G["Inspect" .. slots[i] .. "Slot"]
		local slotFrame = _G["Inspect" .. slots[i] .. "SlotFrame"]

		if slotFrame then
			slotFrame:Hide()
		end

		if slot then
			if slot.SetNormalTexture then
				slot:SetNormalTexture("")
			end

			if slot.SetPushedTexture then
				slot:SetPushedTexture("")
			end

			if slot.icon then
				slot.icon:SetTexCoord(T.unpack(E.TexCoords))
			end

			if slot.IconBorder then
				slot.IconBorder:SetDrawLayer("BACKGROUND")
			end
		end
	end

	if _G.InspectPaperDollItemSlotButton_Update then
		hooksecurefunc("InspectPaperDollItemSlotButton_Update", function(button)
			if not button then return end

			if button.IconBorder then
				button.IconBorder:SetTexture(E.media.normTex)
			end

			if button.icon then
				button.icon:SetShown(button.hasItem)
			end
		end)
	end

	-- Talents
	if InspectTalentFrame and InspectTalentFrame.InspectSpec then
		local inspectSpec = InspectTalentFrame.InspectSpec

		if inspectSpec.ring then
			inspectSpec.ring:Hide()
		end

		if InspectTalentFrame.InspectTalents then
			for i = 1, 7 do
				local row = InspectTalentFrame.InspectTalents["tier" .. i]
				if row then
					for j = 1, 3 do
						local bu = row["talent" .. j]
						if bu then
							if bu.Slot then
								bu.Slot:Hide()
							end

							if bu.border then
								bu.border:SetTexture("")
							end

							if bu.icon then
								bu.icon:SetDrawLayer("ARTWORK")
								bu.icon:SetTexCoord(T.unpack(E.TexCoords))
								KS:CreateBG(bu.icon)
							end
						end
					end
				end
			end
		end

		if inspectSpec.specIcon then
			inspectSpec.specIcon:SetTexCoord(T.unpack(E.TexCoords))
			KS:CreateBG(inspectSpec.specIcon)
		end

		inspectSpec:HookScript("OnShow", updateIcon)

		InspectTalentFrame:HookScript("OnEvent", function(self, event, unit)
			if not InspectFrame:IsShown() then return end
			if event == "INSPECT_READY" and InspectFrame.unit and T.UnitGUID(InspectFrame.unit) == unit then
				if self.InspectSpec then
					updateIcon(self.InspectSpec)
				end
			end
		end)

		local roleIcon = inspectSpec.roleIcon
		if roleIcon then
			roleIcon:SetTexture(E.media.roleIcons)
			local bg = KS:CreateBDFrame(roleIcon, 1)
			if bg then
				bg:SetPoint("TOPLEFT", roleIcon, 2, -1)
				bg:SetPoint("BOTTOMRIGHT", roleIcon, -1, 2)
			end
		end
	end

	for i = 1, 4 do
		local tab = _G["InspectFrameTab" .. i]
		if tab then
			KS:ReskinTab(tab)
			if i ~= 1 then
				local prevTab = _G["InspectFrameTab" .. (i - 1)]
				if prevTab then
					tab:SetPoint("LEFT", prevTab, "RIGHT", -15, 0)
				end
			end
		end
	end
end

S:AddCallbackForAddon("Blizzard_InspectUI", "KuiInspect", styleInspect)