local KUI, T, E, L, V, P, G = unpack(select(2, ...))
local KS = KUI:GetModule('KuiSkins')
local S = E:GetModule('Skins')

local r, g, b = T.unpack(E["media"].rgbvaluecolor)

local function stylePvP()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.pvp ~= true or E.private.KlixUI.skins.blizzard.pvp ~= true then return end
	
	if _G.PVPReadyDialog then
		_G.PVPReadyDialog:Styling()
	end

	local PVPQueueFrame = _G.PVPQueueFrame
	local HonorFrame = _G.HonorFrame
	local ConquestFrame = _G.ConquestFrame
	local WarGamesFrame = _G.WarGamesFrame
	if not PVPQueueFrame then return end

	local iconSize = 56-2*E.mult
	for i = 1, 3 do
		local bu = PVPQueueFrame["CategoryButton"..i]
		if not bu then
			break
		end

		local cu = bu.CurrencyDisplay

		KS:Reskin(bu)

		if bu.Name then
			bu.Name:SetTextColor(1, 1, 1)
		end

		if bu.Icon then
			bu.Icon:SetSize(iconSize, iconSize)
			bu.Icon:SetDrawLayer("OVERLAY")
			bu.Icon:ClearAllPoints()
			bu.Icon:SetPoint("LEFT", bu, "LEFT", 5, 0)
		end

		if cu and cu.Icon and cu.Amount and bu.Name then
			local ic = cu.Icon

			ic:SetSize(16, 16)
			ic:SetPoint("TOPLEFT", bu.Name, "BOTTOMLEFT", 0, -8)
			cu.Amount:SetPoint("LEFT", ic, "RIGHT", 4, 0)

			ic:SetTexCoord(T.unpack(E.TexCoords))
			ic.bg = KS:CreateBG(ic)
			ic.bg:SetDrawLayer("BACKGROUND", 1)
		end
	end

	-- Casual - HonorFrame
	local Inset = HonorFrame and HonorFrame.Inset
	local BonusFrame = HonorFrame and HonorFrame.BonusFrame

	if BonusFrame then
		if BonusFrame.WorldBattlesTexture then
			BonusFrame.WorldBattlesTexture:Hide()
		end
		if BonusFrame.ShadowOverlay then
			BonusFrame.ShadowOverlay:Hide()
		end

		for _, bonusButton in pairs({"RandomBGButton", "RandomEpicBGButton", "Arena1Button", "BrawlButton", "SpecialEventButton"}) do
			local button = BonusFrame[bonusButton]
			if button and button.SelectedTexture then
				button.SelectedTexture:SetDrawLayer("BACKGROUND")
				button.SelectedTexture:SetColorTexture(r, g, b, .2)
				button.SelectedTexture:SetAllPoints()
			end

			if button and button.Reward and button.Reward.Icon then
				button.Reward.Icon:SetInside(button.Reward)
			end
		end
	end

	-- Honor frame specific
	if HonorFrame and HonorFrame.SpecificFrame and HonorFrame.SpecificFrame.buttons then
	for _, bu in T.pairs(HonorFrame.SpecificFrame.buttons) do
		if bu.Bg then bu.Bg:Hide() end
		if bu.Border then bu.Border:Hide() end

		KS:Reskin(bu)

		-- Hide ElvUI backdrop
		if bu.backdrop then
			bu.backdrop:Hide()
		end

		bu:SetNormalTexture("")
		bu:SetHighlightTexture("")

		local bg = T.CreateFrame("Frame", nil, bu)
		bg:SetPoint("TOPLEFT", 2, 0)
		bg:SetPoint("BOTTOMRIGHT", -1, 2)
		KS:CreateBD(bg, 0)
		bg:SetFrameLevel(bu:GetFrameLevel()-1)

		bu.tex = KS:CreateGradient(bu)
		bu.tex:SetDrawLayer("BACKGROUND")
		bu.tex:SetPoint("TOPLEFT", bg, 1, -1)
		bu.tex:SetPoint("BOTTOMRIGHT", bg, -1, 1)

		if bu.SelectedTexture then
			bu.SelectedTexture:SetDrawLayer("BACKGROUND")
			bu.SelectedTexture:SetColorTexture(r, g, b, .2)
			bu.SelectedTexture:SetAllPoints(bu.tex)
		end

		if bu.Icon then
			bu.Icon:SetTexCoord(T.unpack(E.TexCoords))
			bu.Icon.bg = KS:CreateBG(bu.Icon)
			bu.Icon.bg:SetDrawLayer("BACKGROUND", 1)
			bu.Icon:SetPoint("TOPLEFT", 5, -3)
		end
	end
	end

	-- Conquest
	if ConquestFrame then
		for _, bu in pairs({ConquestFrame.Arena2v2, ConquestFrame.Arena3v3, ConquestFrame.RatedBG}) do
			if bu and bu.SelectedTexture then
				bu.SelectedTexture:SetDrawLayer("BACKGROUND")
				bu.SelectedTexture:SetColorTexture(r, g, b, .25)
				bu.SelectedTexture:SetAllPoints()
			end
		end
		if ConquestFrame.Arena3v3 and ConquestFrame.Arena2v2 then
			ConquestFrame.Arena3v3:SetPoint("TOP", ConquestFrame.Arena2v2, "BOTTOM", 0, -1)
		end
	end
end

S:AddCallbackForAddon("Blizzard_PVPUI", "KuiPvPUI", stylePvP)
