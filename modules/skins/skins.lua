local KUI, T, E, L, V, P, G = unpack(select(2, ...))
local KS = KUI:NewModule("KuiSkins", "AceHook-3.0", "AceEvent-3.0")
local S = E:GetModule('Skins')
local AB = E:GetModule('ActionBars')
local LSM = E.LSM or E.Libs.LSM

local alpha
local backdropcolorr, backdropcolorg, backdropcolorb
local backdropfadecolorr, backdropfadecolorg, backdropfadecolorb
local unitFrameColorR, unitFrameColorG, unitFrameColorB
local rgbValueColorR, rgbValueColorG, rgbValueColorB
local bordercolorr, bordercolorg, bordercolorb

DUI_NORMAL_QUEST_DISPLAY = "|cffffffff%s|r"
DUI_TRIVIAL_QUEST_DISPLAY = TRIVIAL_QUEST_DISPLAY:gsub("000000", "ffffff")

local buttons = {
	"UI-Panel-MinimizeButton-Disabled",
	"UI-Panel-MinimizeButton-Up",
	"UI-Panel-SmallerButton-Up",
	"UI-Panel-BiggerButton-Up",
}

-- Depends on the arrow texture to be down by default.
KS.ArrowRotation = {
	['UP'] = 3.14,
	['DOWN'] = 0,
	['LEFT'] = -1.57,
	['RIGHT'] = 1.57,
}

-- Create shadow for textures
function KS:CreateSD(f, m, s, n)
	if f.Shadow then return end

	local frame = f
	if f:GetObjectType() == "Texture" then
		frame = f:GetParent()
	end

	local lvl = frame:GetFrameLevel()
	f.Shadow = CreateFrame("Frame", nil, frame)
	f.Shadow:SetPoint("TOPLEFT", f, -m, m)
	f.Shadow:SetPoint("BOTTOMRIGHT", f, m, -m)
	f.Shadow:CreateBackdrop()
	f.Shadow.backdrop:SetBackdropBorderColor(0, 0, 0, 1)
	f.Shadow.backdrop:SetFrameLevel(n or lvl)

	return f.Shadow
end

function KS:CreateBG(frame)
	T.assert(frame, "doesn't exist!")

	local f = frame
	if frame:IsObjectType('Texture') then f = frame:GetParent() end

	local bg = f:CreateTexture(nil, "BACKGROUND")
	bg:Point("TOPLEFT", frame, -E.mult, E.mult)
	bg:Point("BOTTOMRIGHT", frame, E.mult, -E.mult)
	bg:SetTexture(E.media.blankTex)
	bg:SetVertexColor(0, 0, 0)

	return bg
end

-- Gradient Texture
function KS:CreateGradient(f)
	T.assert(f, "doesn't exist!")

	local tex = f:CreateTexture(nil, "BACKGROUND")
	tex:ClearAllPoints()
	tex:SetPoint("TOPLEFT", 1, -1)
	tex:SetPoint("BOTTOMRIGHT", -1, 1)
	tex:SetTexture([[Interface\AddOns\ElvUI_KlixUI\media\textures\gradient.tga]])
	tex:SetVertexColor(.3, .3, .3, .15)
	tex:SetSnapToPixelGrid(false)
	tex:SetTexelSnappingBias(0)

	return tex
end

function KS:CreateBackdrop(frame)
	if frame.backdrop then return end

	local parent = frame.IsObjectType and frame:IsObjectType("Texture") and frame:GetParent() or frame

	local backdrop = T.CreateFrame("Frame", nil, parent)
	backdrop:SetOutside(frame)
	backdrop:SetTemplate("Transparent")

	if (parent:GetFrameLevel() - 1) >= 0 then
		backdrop:SetFrameLevel(parent:GetFrameLevel() - 1)
	else
		backdrop:SetFrameLevel(0)
	end

	frame.backdrop = backdrop
end

function KS:CreateBDFrame(f, a, left, right, top, bottom)
	T.assert(f, "doesn't exist!")

	local frame
	if f:IsObjectType('Texture') then
		frame = f:GetParent()
	else
		frame = f
	end

	local lvl = frame:GetFrameLevel()

	local bg = T.CreateFrame("Frame", nil, frame, "BackdropTemplate")
	bg:SetPoint("TOPLEFT", f, left or -1, top or 1)
	bg:SetPoint("BOTTOMRIGHT", f, right or 1, bottom or -1)
	bg:SetFrameLevel(lvl == 0 and 1 or lvl - 1)

	KS:CreateBD(bg, a or .5)

	return bg
end

function KS:CreateBD(f, a)
	T.assert(f, "doesn't exist!")

	f:CreateBackdrop()
	local r = backdropfadecolorr or 0
	local g = backdropfadecolorg or 0
	local b = backdropfadecolorb or 0
	local alphaVal = a or alpha or 1
	f.backdrop:SetBackdropColor(r, g, b, alphaVal)
	f.backdrop:SetBackdropBorderColor(bordercolorr or 0, bordercolorg or 0, bordercolorb or 0)
end

-- ClassColored ScrollBars
do
	local function GrabScrollBarElement(frame, element)
	local FrameName = frame:GetDebugName()
		return frame[element] or FrameName and (_G[FrameName..element] or strfind(FrameName, element)) or nil
	end

function KS:ReskinScrollBar(frame, thumbTrimY, thumbTrimX)
	local parent = frame:GetParent()

	local Thumb = GrabScrollBarElement(frame, 'ThumbTexture') or GrabScrollBarElement(frame, 'thumbTexture') or frame.GetThumbTexture and frame:GetThumbTexture()

	if Thumb and Thumb.backdrop then
		local r, g, b = unpack(E.media.rgbvaluecolor or {1,1,1})
		r = r or 1; g = g or 1; b = b or 1
		Thumb.backdrop:SetBackdropColor(r, g, b)
	end
	end
end

-- Overwrite ElvUI Tabs function to be transparent
function KS:ReskinTab(tab)
	if not tab then return end

	if tab.backdrop then
		tab.backdrop:SetTemplate("Transparent")
		tab.backdrop:Styling()
	end
end

function KS:ColorButton()
	if self.backdrop then self = self.backdrop end
	local r = rgbValueColorR or 1
	local g = rgbValueColorG or 1
	local b = rgbValueColorB or 1
	self:SetBackdropColor(r, g, b, .3)
	self:SetBackdropBorderColor(r, g, b)
end

function KS:ClearButton()
	if self.backdrop then self = self.backdrop end
	self:SetBackdropColor(0, 0, 0, 0)
	if self.isUnitFrameElement then
		self:SetBackdropBorderColor(unitFrameColorR or 1, unitFrameColorG or 1, unitFrameColorB or 1)
	else
		self:SetBackdropBorderColor(bordercolorr or 0, bordercolorg or 0, bordercolorb or 0)
	end
end

function KS:OnEnter()
	if self:IsEnabled() then
		if self.backdrop then self = self.backdrop end
		if self.SetBackdropBorderColor then
			local r = rgbValueColorR or 1
			local g = rgbValueColorG or 1
			local b = rgbValueColorB or 1
			self:SetBackdropBorderColor(r, g, b)
			self:SetBackdropColor(r, g, b, 0.75) -- maybe 0.5?
		end
	end
end

function KS:OnLeave()
	if self:IsEnabled() then
		if self.backdrop then self = self.backdrop end
		if self.SetBackdropBorderColor then
			self:SetBackdropBorderColor(bordercolorr or 0, bordercolorg or 0, bordercolorb or 0)
			self:SetBackdropColor(backdropfadecolorr or 0, backdropfadecolorg or 0, backdropfadecolorb or 0, alpha or 1)
		end
	end
end

-- Buttons
function KS:Reskin(button, strip, isDeclineButton, noStyle, setTemplate, styleTemplate, noGlossTex)
	assert(button, "doesn't exist!")

	if strip then button:StripTextures() end
	KS:CreateGradient(button)

	if button.Icon then
		local Texture = button.Icon:GetTexture()
		if Texture and strfind(Texture, [[Interface\ChatFrame\ChatFrameExpandArrow]]) then
			button.Icon:SetTexture([[Interface\AddOns\ElvUI_KlixUI\media\textures\Arrow]])
			button.Icon:SetVertexColor(1, 1, 1)
			button.Icon:SetRotation(KS.ArrowRotation['RIGHT'])
		end
	end

	if not noStyle then
		if setTemplate then
			button:SetTemplate('Transparent', not noGlossTex) -- force transparent
	else
			button:CreateBackdrop('Transparent', not noGlossTex) -- force transparent
			button.backdrop:SetAllPoints()
	end

		button:HookScript("OnEnter", KS.OnEnter)
		button:HookScript("OnLeave", KS.OnLeave)
	end
end

function KS:StyleButton(button)
	if button.isStyled then return end

	if button.SetHighlightTexture then
		button:SetHighlightTexture(E["media"].blankTex)
		button:GetHighlightTexture():SetVertexColor(1, 1, 1, .2)
		button:GetHighlightTexture():SetInside()
		button.SetHighlightTexture = E.noop
	end

	if button.SetPushedTexture then
		button:SetPushedTexture(E["media"].blankTex)
		button:GetPushedTexture():SetVertexColor(.9, .8, .1, .5)
		button:GetPushedTexture():SetInside()
		button.SetPushedTexture = E.noop
	end

	if button.GetCheckedTexture then
		button:SetPushedTexture(E["media"].blankTex)
		button:GetCheckedTexture():SetVertexColor(0, 1, 0, .5)
		button:GetCheckedTexture():SetInside()
		button.GetCheckedTexture = E.noop
	end

	local Cooldown = button:GetName() and _G[button:GetName()..'Cooldown'] or button.Cooldown or button.cooldown or nil

	if Cooldown then
		Cooldown:SetInside()
		if Cooldown.SetSwipeColor then
			Cooldown:SetSwipeColor(0, 0, 0, 1)
		end
	end

	button.isStyled = true
end

function KS:ReskinIcon(icon, backdrop)
	T.assert(icon, "doesn't exist!")

	icon:SetTexCoord(T.unpack(E.TexCoords))

	if icon:GetDrawLayer() ~= 'ARTWORK' then
		icon:SetDrawLayer("ARTWORK")
	end

	if backdrop then
		KS:CreateBackdrop(icon)
	end
end

function KS:SkinPanel(panel)
	panel.tex = panel:CreateTexture(nil, "ARTWORK")
	panel.tex:SetAllPoints()
	panel.tex:SetTexture(E.media.blankTex)
	panel.tex:SetGradient("VERTICAL", rgbValueColorR, rgbValueColorG, rgbValueColorB)
end

function KS:ReskinGarrisonPortrait(self)
	self.Portrait:ClearAllPoints()
	self.Portrait:SetPoint("TOPLEFT", 4, -4)
	self.PortraitRing:Hide()
	self.PortraitRingQuality:SetTexture("")
	if self.Highlight then self.Highlight:Hide() end

	self.LevelBorder:SetScale(.0001)
	self.Level:ClearAllPoints()
	self.Level:SetPoint("BOTTOM", self, 0, 12)

	self.squareBG = KS:CreateBDFrame(self, 1)
	self.squareBG:SetFrameLevel(self:GetFrameLevel())
	self.squareBG:SetPoint("TOPLEFT", 3, -3)
	self.squareBG:SetPoint("BOTTOMRIGHT", -3, 11)

	if self.PortraitRingCover then
		self.PortraitRingCover:SetColorTexture(0, 0, 0)
		self.PortraitRingCover:SetAllPoints(self.squareBG)
	end

	if self.Empty then
		self.Empty:SetColorTexture(0, 0, 0)
		self.Empty:SetAllPoints(self.Portrait)
	end
end

local buttons = {
	"ElvUIMoverNudgeWindowUpButton",
	"ElvUIMoverNudgeWindowDownButton",
	"ElvUIMoverNudgeWindowLeftButton",
	"ElvUIMoverNudgeWindowRightButton",
}

local function replaceConfigArrows(button)
	-- remove the default icons
	local tex = _G[button:GetName().."Icon"]
	if tex then
		tex:SetTexture(nil)
	end

	-- add the new icon
	if not button.img then
		button.img = button:CreateTexture(nil, 'ARTWORK')
		button.img:SetTexture('Interface\\AddOns\\ElvUI_KlixUI\\media\\textures\\arrow')
		button.img:SetSize(12, 12)
		button.img:Point('CENTER')
		button.img:SetVertexColor(1, 1, 1)

		button:HookScript('OnMouseDown', function(btn)
			if btn:IsEnabled() then
				btn.img:Point("CENTER", -1, -1);
			end
		end)

		button:HookScript('OnMouseUp', function(btn)
			btn.img:Point("CENTER", 0, 0);
		end)
	end
end

function KS:ApplyConfigArrows()
	for _, btn in T.pairs(buttons) do
		replaceConfigArrows(_G[btn])
	end

	-- Apply the rotation
	_G["ElvUIMoverNudgeWindowUpButton"].img:SetRotation(KS.ArrowRotation['UP'])
	_G["ElvUIMoverNudgeWindowDownButton"].img:SetRotation(KS.ArrowRotation['DOWN'])
	_G["ElvUIMoverNudgeWindowLeftButton"].img:SetRotation(KS.ArrowRotation['LEFT'])
	_G["ElvUIMoverNudgeWindowRightButton"].img:SetRotation(KS.ArrowRotation['RIGHT'])

end
hooksecurefunc(E, "CreateMoverPopup", KS.ApplyConfigArrows)

function KS:ReskinAS(AS)
	-- Reskin AddOnSkins
	function AS:SkinTab(Tab, Strip)
		if Tab.isSkinned then return end
		local TabName = Tab:GetName()

		if TabName then
			for _, Region in T.pairs(S.Blizzard.Regions) do
				if _G[TabName..Region] then
					_G[TabName..Region]:SetTexture(nil)
				end
			end
		end

		for _, Region in T.pairs(S.Blizzard.Regions) do
			if Tab[Region] then
				Tab[Region]:SetAlpha(0)
			end
		end

		if Tab.GetHighlightTexture and Tab:GetHighlightTexture() then
			Tab:GetHighlightTexture():SetTexture(nil)
		else
			Strip = true
		end

		if Strip then
			AS:StripTextures(Tab)
		end

		AS:CreateBackdrop(Tab, 'Transparent')

		if AS:CheckAddOn("ElvUI") and AS:CheckOption("ElvUISkinModule") then
			-- Check if ElvUI already provides the backdrop. Otherwise we have two backdrops (e.g. Auctionhouse)
			if Tab.backdrop then
				Tab.Backdrop:Hide()
			else
				AS:SetTemplate(Tab.Backdrop, "Transparent") -- Set it to transparent
				Tab.Backdrop:Styling()
			end
		end

		Tab.Backdrop:Point("TOPLEFT", 10, AS.PixelPerfect and -1 or -3)
		Tab.Backdrop:Point("BOTTOMRIGHT", -10, 3)

		Tab.isSkinned = true
	end

	function AS:SkinButton(Button, Strip)
		if Button.isSkinned then return end

		local ButtonName = Button.GetName and Button:GetName()
		local foundArrow

		if Button.Icon then
			local Texture = Button.Icon:GetTexture()
			if Texture and (type(Texture) == 'string' and strfind(Texture, [[Interface\ChatFrame\ChatFrameExpandArrow]])) then
				foundArrow = true
			end
		end

		if Strip then
			AS:StripTextures(Button)
		end

		for _, Region in pairs(AS.Blizzard.Regions) do
			Region = ButtonName and _G[ButtonName..Region] or Button[Region]
			if Region then
				Region:SetAlpha(0)
			end
		end

		if foundArrow then
			Button.Icon:SetTexture([[Interface\AddOns\AddOnSkins\Media\Textures\Arrow]])
			Button.Icon:SetSnapToPixelGrid(false)
			Button.Icon:SetTexelSnappingBias(0)
			Button.Icon:SetVertexColor(1, 1, 1)
			Button.Icon:SetRotation(AS.ArrowRotation['right'])
		end

		if Button.SetNormalTexture then Button:SetNormalTexture('') end
		if Button.SetHighlightTexture then Button:SetHighlightTexture('') end
		if Button.SetPushedTexture then Button:SetPushedTexture('') end
		if Button.SetDisabledTexture then Button:SetDisabledTexture('') end

		AS:SetTemplate(Button, 'Transparent')

		if Button.GetFontString and Button:GetFontString() ~= nil then
			if Button:IsEnabled() then
				Button:GetFontString():SetTextColor(1, 1, 1)
			else
				Button:GetFontString():SetTextColor(.5, .5, .5)
			end
		end

		Button:HookScript("OnEnable", function(self)
			if self.GetFontString and self:GetFontString() ~= nil then
				self:GetFontString():SetTextColor(1, 1, 1)
			end
		end)
		Button:HookScript("OnDisable", function(self)
			if self.GetFontString and self:GetFontString() ~= nil then
				self:GetFontString():SetTextColor(.5, .5, .5)
			end
		end)

		Button:HookScript("OnEnter", KS.OnEnter)
		Button:HookScript("OnLeave", KS.OnLeave)
	end
end

-- Replace the Recap button script re-set function
function S:UpdateRecapButton()
	if self and self.button4 and self.button4:IsEnabled() then
		self.button4:SetScript("OnEnter", KS.ColorButton)
		self.button4:SetScript("OnLeave", KS.ClearButton)
	end
end

--[[ HOOK TO THE UIWIDGET TYPES ]]
function KS:ReskinSkinTextWithStateWidget(widgetFrame)
	local text = widgetFrame.Text
	if text then
		text:SetTextColor(1, 1, 1)
	end
end

-- hook the skin functions
hooksecurefunc(S, "HandleTab", KS.ReskinTab)
hooksecurefunc(S, "HandleButton", KS.Reskin)
hooksecurefunc(S, "HandleScrollBar", KS.ReskinScrollBar)
-- New Widget Types
hooksecurefunc(S, "SkinTextWithStateWidget", KS.ReskinSkinTextWithStateWidget)

local function ReskinVehicleExit()
	if not E.private.KlixUI.skins.vehicleButton or not E.private.actionbar.enable then return end

	if MasqueGroup and E.private.actionbar.masque.actionbars then return end

	local f = _G.MainMenuBarVehicleLeaveButton
	if not f or (f.IsForbidden and f:IsForbidden()) then return end

	f:SetNormalTexture("Interface\\AddOns\\ElvUI_KlixUI\\media\\textures\\arrow")
	f:SetPushedTexture("Interface\\AddOns\\ElvUI_KlixUI\\media\\textures\\arrow")
	f:SetHighlightTexture("Interface\\AddOns\\ElvUI_KlixUI\\media\\textures\\arrow")

	local normal = f.GetNormalTexture and f:GetNormalTexture()
	local pushed = f.GetPushedTexture and f:GetPushedTexture()

	if normal then
		normal:SetTexCoord(0, 1, 0, 1)
	end

	if pushed then
		pushed:SetTexCoord(0, 1, 0, 1)
	end
end

function KS:SetOutside(obj, anchor, xOffset, yOffset, anchor2)
	xOffset = xOffset or 1
	yOffset = yOffset or 1
	anchor = anchor or obj:GetParent()

	assert(anchor)
	if obj:GetPoint() then
		obj:ClearAllPoints()
	end

	obj:SetPoint('TOPLEFT', anchor, 'TOPLEFT', -xOffset, yOffset)
	obj:SetPoint('BOTTOMRIGHT', anchor2 or anchor, 'BOTTOMRIGHT', xOffset, -yOffset)
end

-- keep the colors updated
local function updateMedia()
	rgbValueColorR, rgbValueColorG, rgbValueColorB = unpack(E["media"].rgbvaluecolor)
	unitFrameColorR, unitFrameColorG, unitFrameColorB = unpack(E.media.unitframeBorderColor)
	backdropfadecolorr, backdropfadecolorg, backdropfadecolorb, alpha = unpack(E.media.backdropfadecolor)
	backdropcolorr, backdropcolorg, backdropcolorb = unpack(E.media.backdropcolor)
	bordercolorr, bordercolorg, bordercolorb = unpack(E.media.bordercolor)
end
hooksecurefunc(E, "UpdateMedia", updateMedia)


-- Skin various addons!
function KS:StyleAddons()
	-- CoolGlow
	if T.IsAddOnLoaded("CoolGlow") then
		if CoolGlowTestFrame then
			_G["CoolGlowTestFrame"]:Styling()
		end
	end
	
	-- ElvUI_InfoBar
	if T.IsAddOnLoaded("ElvUI_InfoBar") then
		local IFFrames = {
			_G["IF_InfoBar1"].Background,
			_G["IF_InfoBar2"].Background,
			_G["IF_InfoBar3"].Background,
			_G["IF_InfoBar4"].Background,
			_G["IF_InfoBar5"].Background,
			_G["IF_InfoBar6"].Background,
			_G["IF_InfoBar7"].Background,
			_G["IF_InfoBar8"].Background,
			_G["IF_InfoBar9"].Background,
			_G["IF_InfoBar10"].Background,
			_G["IF_Menu"].Button1.Background,
			_G["IF_Menu"].Button2.Background,
			_G["IF_Menu"].Button3.Background,
			_G["IF_Menu"].Button4.Background,
			_G["IF_Menu"].Button5.Background,
			_G["IF_Menu"].Clear.Background
		}
		for _, frame in T.pairs(IFFrames) do
			if frame then
				frame:Styling()
			end
		end
	end
end

function KS:PLAYER_ENTERING_WORLD(...)
	self:StyleAddons()

	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
end

function KS:Initialize()
	self.db = E.private.KlixUI.skins

	updateMedia()
	self:StyleElvUIConfig()

	if AB then
		if AB.CreateVehicleLeave then
			hooksecurefunc(AB, "CreateVehicleLeave", ReskinVehicleExit)
		end

		if AB.UpdateVehicleLeave then
			hooksecurefunc(AB, "UpdateVehicleLeave", ReskinVehicleExit)
		end
	end
	
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	
	if IsAddOnLoaded("AddOnSkins") then
		if AddOnSkins then
			KS:ReskinAS(T.unpack(AddOnSkins))
		end
	end
end

KUI:RegisterModule(KS:GetName())
