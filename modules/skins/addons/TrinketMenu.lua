local KUI, T, E, L, V, P, G = unpack(select(2, ...))
local KS = KUI:GetModule('KuiSkins')
local S = E:GetModule('Skins')

local function styleTrinketMenu()
	if not T.IsAddOnLoaded("TrinketMenu") then return end
	
	-- Main Frame
	TrinketMenu_MainFrame:StripTextures()
	TrinketMenu_MainFrame:CreateBackdrop("Transparent")
	TrinketMenu_MainFrame.backdrop:SetPoint("TOPLEFT", 5, -5)
	TrinketMenu_MainFrame.backdrop:SetPoint("BOTTOMRIGHT", -5, 5)
	TrinketMenu_MainFrame.backdrop:Styling()

	--TrinketMenu_MainResizeButton:SetNormalTexture("")

	-- Menu frame
	TrinketMenu_MenuFrame:StripTextures()
	TrinketMenu_MenuFrame:CreateBackdrop("Transparent")
	TrinketMenu_MenuFrame.backdrop:SetPoint("TOPLEFT", 5, -5)
	TrinketMenu_MenuFrame.backdrop:SetPoint("BOTTOMRIGHT", -5, 5)
	TrinketMenu_MenuFrame.backdrop:Styling()

	--TrinketMenu_MenuResizeButton:SetNormalTexture("")

	for i = 0, 1 do
		local item = _G["TrinketMenu_Trinket"..i]
		local icon = _G["TrinketMenu_Trinket"..i.."Icon"]
		local cooldown = _G["TrinketMenu_Trinket"..i.."Cooldown"]

		item:StripTextures()
		item:SetTemplate()
		item:StyleButton()
		item:SetBackdropColor(0, 0, 0, 0)

		icon:SetTexCoord(T.unpack(E.TexCoords))
		icon:SetInside()

		E:RegisterCooldown(cooldown)

		item:HookScript("OnUpdate", function(self)
			local link = i == 0 and T.GetInventoryItemLink("player", 13) or T.GetInventoryItemLink("player", 14)

			if link then
				local quality = T.select(3, T.GetItemInfo(link))

				self:SetBackdropBorderColor(T.GetItemQualityColor(quality))
			end
		end)
	end

	for i = 1, 30 do
		local item = _G["TrinketMenu_Menu"..i]
		local icon = _G["TrinketMenu_Menu"..i.."Icon"]
		local cooldown = _G["TrinketMenu_Menu"..i.."Cooldown"]

		item:StripTextures()
		item:SetTemplate()
		item:StyleButton()
		item:SetBackdropColor(0, 0, 0, 0)

		icon:SetTexCoord(T.unpack(E.TexCoords))
		icon:SetInside()

		E:RegisterCooldown(cooldown)
	end

	-- Options Frame
	TrinketMenu_OptFrame:StripTextures()
	TrinketMenu_OptFrame:CreateBackdrop("Transparent")
	TrinketMenu_OptFrame.backdrop:Styling()

	TrinketMenu_SubOptFrame:StripTextures()
	TrinketMenu_SubOptFrame:CreateBackdrop("Transparent")
	TrinketMenu_SubOptFrame.backdrop:Styling()

	S:HandleButton(TrinketMenu_Tab1)
	TrinketMenu_Tab1:SetPoint("TOPRIGHT", -7, -22)
	TrinketMenu_Tab1:SetSize(94, 24)

	S:HandleButton(TrinketMenu_Tab2)
	TrinketMenu_Tab2:SetPoint("TOPRIGHT", TrinketMenu_Tab1, "TOPLEFT", -2, 0)
	TrinketMenu_Tab2:SetSize(94, 24)

	S:HandleButton(TrinketMenu_Tab3)
	TrinketMenu_Tab3:SetPoint("TOPRIGHT", TrinketMenu_Tab2, "TOPLEFT", -2, 0)
	TrinketMenu_Tab3:SetSize(94, 24)

	--S:HandleButton(TrinketMenu_OptBindButton)

	local checkboxes = {
		TrinketMenu_Trinket0Check,
		TrinketMenu_Trinket1Check,
		TrinketMenu_OptLocked,
		TrinketMenu_OptShowIcon,
		TrinketMenu_OptDisableToggle,
		TrinketMenu_OptSquareMinimap,
		TrinketMenu_OptCooldownCount,
		TrinketMenu_OptLargeCooldown,
		TrinketMenu_OptShowTooltips,
		TrinketMenu_OptTooltipFollow,
		TrinketMenu_OptTinyTooltips,
		TrinketMenu_OptShowHotKeys,
		TrinketMenu_OptStopOnSwap,
		TrinketMenu_OptRedRange,
		TrinketMenu_OptKeepDocked,
		TrinketMenu_OptKeepOpen,
		TrinketMenu_OptMenuOnShift,
		TrinketMenu_OptMenuOnRight,
		TrinketMenu_OptNotify,
		TrinketMenu_OptNotifyThirty,
		TrinketMenu_OptNotifyChatAlso,
		TrinketMenu_OptSetColumns,
		TrinketMenu_SortPriority,
		TrinketMenu_SortKeepEquipped,
		TrinketMenu_OptHideOnLoad,
		TrinketMenu_OptHidePetBattle
	}

	for _, checkbox in T.pairs(checkboxes) do
		S:HandleCheckBox(checkbox)
	end

	S:HandleSliderFrame(TrinketMenu_OptColumnsSlider)
	S:HandleSliderFrame(TrinketMenu_OptMainScaleSlider)
	S:HandleSliderFrame(TrinketMenu_OptMenuScaleSlider)
	
	TrinketMenu_OptMainScaleSlider:ClearAllPoints()
	TrinketMenu_OptMainScaleSlider:SetPoint("BOTTOM", TrinketMenu_OptMainScaleSliderText, "BOTTOM", 0, -15)
	
	TrinketMenu_OptMenuScaleSlider:ClearAllPoints()
	TrinketMenu_OptMenuScaleSlider:SetPoint("BOTTOM", TrinketMenu_OptMenuScaleSliderText, "BOTTOM", 0, -15)

	TrinketMenu_LockButton:Hide()

	S:HandleCloseButton(TrinketMenu_CloseButton)
	TrinketMenu_CloseButton:SetSize(32)
	TrinketMenu_CloseButton:SetPoint("TOPRIGHT", 6, 6)

	TrinketMenu_SubQueueFrame:StripTextures()
	TrinketMenu_SortListFrame:StripTextures()

	TrinketMenu_SortScroll:StripTextures()
	TrinketMenu_SortScroll:CreateBackdrop("Transparent")

	S:HandleScrollBar(TrinketMenu_SortScrollScrollBar)

	TrinketMenu_SortDelay:StripTextures()
	S:HandleEditBox(TrinketMenu_SortDelay)

	for i = 1, 9 do
		local item = _G["TrinketMenu_Sort"..i]
		local icon = _G["TrinketMenu_Sort"..i.."Icon"]
		local highlight = _G["TrinketMenu_Sort"..i.."Highlight"]

		item:CreateBackdrop()
		item.backdrop:SetOutside(icon)

		icon:SetTexCoord(T.unpack(E.TexCoords))

		highlight:SetTexture(1, 1, 1, 0.3)
		highlight:SetInside()
	end

	S:HandleNextPrevButton(TrinketMenu_MoveUp, "up")

	S:HandleNextPrevButton(TrinketMenu_MoveDown, "down")

	S:HandleNextPrevButton(TrinketMenu_Delete)

	TrinketMenu_ProfilesFrame:StripTextures()

	TrinketMenu_ProfilesListFrame:StripTextures()
	TrinketMenu_ProfilesListFrame:CreateBackdrop("Transparent")

	TrinketMenu_ProfileName:StripTextures()
	S:HandleEditBox(TrinketMenu_ProfileName)

	S:HandleButton(TrinketMenu_ProfilesDelete)
	S:HandleButton(TrinketMenu_ProfilesLoad)
	S:HandleButton(TrinketMenu_ProfilesSave)
	S:HandleButton(TrinketMenu_ProfilesCancel)

	for i = 1, 7 do
		local item = _G["TrinketMenu_Profile"..i]

		--S:HandleButtonHighlight(item)
	end

	S:HandleScrollBar(TrinketMenu_ProfileScrollScrollBar)
end
S:AddCallbackForAddon("TrinketMenu", "KuiTrinketMenu", styleTrinketMenu)