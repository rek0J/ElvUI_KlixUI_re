local KUI, T, E, L, V, P, G = unpack(select(2, ...))
local KS = KUI:GetModule('KuiSkins')
local S = E:GetModule('Skins')

local r, g, b = T.unpack(E.media.rgbvaluecolor)

local function InitStyleWAO()
	local function GetWeakAurasOptionsFrame()
		if _G.WeakAurasOptions then
			return _G.WeakAurasOptions
		end

		if WeakAuras and type(WeakAuras.OptionsFrame) == "function" then
			return WeakAuras.OptionsFrame()
		end
	end

	local function Skin_WeakAurasOptions(...)
		--T.print("Options opened", ...)
		if not T.IsAddOnLoaded("WeakAuras") or not E.private.KlixUI.skins.addonSkins.wa then return end

		local frame = GetWeakAurasOptionsFrame()
		if not frame or frame.skinned then return end

		local close = frame.CloseButton
		if close then
			S:HandleCloseButton(close)
		end

		-- Disable import check
		--[[children[2]:Hide()
		local import = children[2]:GetChildren()
		S:HandleCheckBox(import)
		import:SetParent(frame)
		import:SetSize(25, 25)
		import:ClearAllPoints()
		import:SetPoint("LEFT", close, "RIGHT", 1, 0)]]

		-- Title
		--children[3]

		-- Frame size handle
		local sizer = frame.bottomRightResizer
		if sizer then
			sizer:SetNormalTexture("")
			sizer:SetHighlightTexture("")
			sizer:SetPushedTexture("")

			if not sizer.KlixUISizerTextures then
				sizer.KlixUISizerTextures = {}
				for i = 1, 3 do
					local tex = sizer:CreateTexture(nil, "OVERLAY")
					tex:SetSize(2, 2)
					tex:SetTexture(E.media.normTex)
					tex:SetVertexColor(r, g, b, .8)
					tex:Show()
					sizer.KlixUISizerTextures[i] = tex
				end
			end

			sizer.KlixUISizerTextures[1]:SetPoint("BOTTOMLEFT", sizer, "BOTTOMLEFT", 6, 6)
			sizer.KlixUISizerTextures[2]:SetPoint("BOTTOMLEFT", sizer.KlixUISizerTextures[1], "TOPLEFT", 0, 4)
			sizer.KlixUISizerTextures[3]:SetPoint("BOTTOMLEFT", sizer.KlixUISizerTextures[1], "BOTTOMRIGHT", 4, 0)
		end

		-- Tutorial
		--children[6]
		local _, _, _, enabled, loadable = T.GetAddOnInfo("WeakAurasTutorials")
		local tutOfs = (enabled and loadable) and 1 or 0

		--[[ Ace groups
			children[6+tutOfs] container
			children[7+tutOfs] texturePick
			children[8+tutOfs] iconPick
			children[9+tutOfs] modelPick
			children[10+tutOfs] importexport
			children[11+tutOfs] texteditor
			children[12+tutOfs] codereview
			children[13+tutOfs] buttonsContainer
		]]

		-- Search
		local filterInput = frame.filterInput or _G.WeakAurasFilterInput
		if filterInput then
			S:HandleEditBox(filterInput)
		end

		-- Remove Title BG
		frame:StripTextures()

		-- StripTextures will actually remove the backdrop too, so we need to put that back
		--KS:CreateBD(frame)
		--KS:CreateSD(frame)
		frame:Styling()

		frame.skinned = true
	end
	hooksecurefunc(WeakAuras, "ShowOptions", Skin_WeakAurasOptions)
end

if T.IsAddOnLoaded("WeakAurasOptions") then
	InitStyleWAO()
else
	local load = T.CreateFrame("Frame")
	load:RegisterEvent("ADDON_LOADED")
	load:SetScript("OnEvent", function(self, _, addon)
		if addon ~= "WeakAurasOptions" then return end
		self:UnregisterEvent("ADDON_LOADED")

		InitStyleWAO()

		load = nil
	end)
end
