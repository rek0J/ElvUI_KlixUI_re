local KUI, T, E, L, V, P, G = unpack(select(2, ...))
local KS = KUI:GetModule('KuiSkins')
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local _G = _G
local unpack = unpack
local select = select
--WoW API / Variables
local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc
local GetInboxText = GetInboxText
local GetInboxInvoiceInfo = GetInboxInvoiceInfo
--GLOBALS:

local r, g, b = T.unpack(E["media"].rgbvaluecolor)

local function styleMail()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.mail ~= true or E.private.KlixUI.skins.blizzard.mail ~= true then return end
	
	local MiniMapMailFrame = _G.MiniMapMailFrame
	local MiniMapMailIcon = _G.MiniMapMailIcon
	
	if E.db.KlixUI.maps.minimap.mail then
		-- Change the Minimap Mail icon
		_G.MiniMapMailIcon:SetTexture("Interface\\AddOns\\ElvUI_KlixUI\\media\\textures\\Mail")
		_G.MiniMapMailIcon:SetSize(22, 22)
		MiniMapMailFrame:Raise()

		if not E.db.KlixUI.maps.minimap.buttons.moveMail then
			MiniMapMailFrame:SetScript("OnShow", function()
				if not MiniMapMailFrame.highlight then
					MiniMapMailFrame.highlight = T.CreateFrame("Frame", nil, MiniMapMailFrame)
					MiniMapMailFrame.highlight:SetAllPoints(MiniMapMailFrame)
					MiniMapMailFrame.highlight:SetFrameLevel(MiniMapMailFrame:GetFrameLevel() + 1)

					MiniMapMailFrame.highlight.tex = MiniMapMailFrame.highlight:CreateTexture("OVERLAY")
					MiniMapMailFrame.highlight.tex:SetTexture("Interface\\AddOns\\ElvUI_KlixUI\\media\\textures\\Mail")
			                MiniMapMailFrame.highlight.tex:SetPoint("TOPLEFT", _G.MiniMapMailIcon, "TOPLEFT", -2, 2)
			                MiniMapMailFrame.highlight.tex:SetPoint("BOTTOMRIGHT", _G.MiniMapMailIcon, "BOTTOMRIGHT", 2, -2)
					MiniMapMailFrame.highlight.tex:SetVertexColor(r, g, b)

					KUI:CreatePulse(MiniMapMailFrame, 1, 1)
				end
			end)
		end
	end
	
	local MailFrame = _G.MailFrame
	MailFrame:Styling()

	-- InboxFrame
	for i = 1, _G.INBOXITEMS_TO_DISPLAY do
		local bg = _G["MailItem"..i]
		bg:StripTextures()

		if bg.backdrop then
			bg.backdrop:Hide()
		end
		KS:CreateBD(bg, .25)

		local b = _G["MailItem"..i.."Button"]
		b:StripTextures()
		b:CreateBackdrop("Transparent", true)
		b:StyleButton()
	end


	-- SendMailFrame (Retail-only frame guard)
	local SendMailFrame = _G.SendMailFrame
	local SendMailScrollFrame = _G.SendMailScrollFrame
	if SendMailScrollFrame then
		SendMailScrollFrame:CreateBackdrop("Transparent")

		local sendMailRegions = {SendMailFrame and SendMailFrame:GetRegions()}
		for i = 4, 7 do
			if sendMailRegions[i] then sendMailRegions[i]:Hide() end
		end

		local scrollRegion = T.select(4, SendMailScrollFrame:GetRegions())
		if scrollRegion then scrollRegion:Hide() end
		if _G.SendMailBodyEditBox then
			_G.SendMailBodyEditBox:SetPoint("TOPLEFT", 2, -2)
			_G.SendMailBodyEditBox:SetWidth(278)
		end -- MoP Classic: SendMailBodyEditBox may not exist, skip if missing
	end

	-- OpenMailFrame
	local OpenMailFrame = _G.OpenMailFrame
	OpenMailFrame:Styling()

	OpenMailFrame:SetPoint("TOPLEFT", _G.InboxFrame, "TOPRIGHT", 5, 0)
	if _G.OpenMailFrameIcon then _G.OpenMailFrameIcon:Hide() end
	_G.OpenMailTitleText:ClearAllPoints()
	_G.OpenMailTitleText:SetPoint("TOP", 0, -4)
	_G.OpenMailHorizontalBarLeft:Hide()

	local OpenMailScrollFrame = _G.OpenMailScrollFrame
	OpenMailScrollFrame:CreateBackdrop("Transparent")
	OpenMailScrollFrame:SetPoint("TOPLEFT", 17, -83)
	OpenMailScrollFrame:SetWidth(304)

	OpenMailScrollFrame.ScrollBar:ClearAllPoints()
	OpenMailScrollFrame.ScrollBar:SetPoint("TOPRIGHT", OpenMailScrollFrame, -1, -18)
	OpenMailScrollFrame.ScrollBar:SetPoint("BOTTOMRIGHT", OpenMailScrollFrame, -1, 18)
	_G.OpenScrollBarBackgroundTop:Hide()
	T.select(2, OpenMailScrollFrame:GetRegions()):Hide()
	_G.OpenStationeryBackgroundLeft:Hide()
	_G.OpenStationeryBackgroundRight:Hide()

	_G.InvoiceTextFontNormal:SetTextColor(1, 1, 1)
	_G.InvoiceTextFontSmall:SetTextColor(1, 1, 1)
	_G.OpenMailArithmeticLine:SetColorTexture(0.8, 0.8, 0.8)
	_G.OpenMailArithmeticLine:SetSize(256, 1)
	_G.OpenMailInvoiceAmountReceived:SetPoint("TOPRIGHT", _G.OpenMailArithmeticLine, "BOTTOMRIGHT", -14, -5)

	hooksecurefunc("OpenMail_Update", function()
		if not _G.InboxFrame.openMailID then
			return
		end

		local _, _, _, isInvoice = T.GetInboxText(_G.InboxFrame.openMailID)
		if isInvoice then
			local invoiceType, _, playerName = T.GetInboxInvoiceInfo(_G.InboxFrame.openMailID)
			if playerName then
				if invoiceType == "buyer" then
					_G.OpenMailArithmeticLine:SetPoint("TOP", "OpenMailInvoicePurchaser", "BOTTOMLEFT", 125, -5)
				elseif invoiceType == "seller" then
					_G.OpenMailArithmeticLine:SetPoint("TOP", "OpenMailInvoiceHouseCut", "BOTTOMRIGHT", -114, -22)
				elseif invoiceType == "seller_temp_invoice" then
					_G.OpenMailArithmeticLine:SetPoint("TOP", "OpenMailInvoicePurchaser", "BOTTOMLEFT", 125, -5)
				end
			end
		end
	end)
end

S:AddCallback("KuiMail", styleMail)