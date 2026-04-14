local KUI, T, E, L, V, P, G = unpack(select(2, ...))

local C_DateAndTime_GetCurrentCalendarTime = T.C_DateAndTime_GetCurrentCalendarTime or (_G.C_DateAndTime and _G.C_DateAndTime.GetCurrentCalendarTime)

local function HideSplashScreen()
	KlixUISplashScreen:Hide()
end

local function FadeSplashScreen()
	E:Delay(2, function()
		E:UIFrameFadeOut(KlixUISplashScreen, 2, 1, 0)
		KlixUISplashScreen.fadeInfo.finishedFunc = HideSplashScreen
	end)
end

function KUI:ShowSplashScreen()
	E:UIFrameFadeIn(KlixUISplashScreen, 4, 0, 1)
	KlixUISplashScreen.fadeInfo.finishedFunc = FadeSplashScreen
end

local function GetCurrentCalendarTime()
	if C_DateAndTime_GetCurrentCalendarTime then
		return C_DateAndTime_GetCurrentCalendarTime()
	end

	local now = T.date("*t")
	return now and { weekday = now.wday } or nil
end

local function CreateSplashScreen()
	local f = T.CreateFrame("Frame", "KlixUISplashScreen", E.UIParent)
	f:Size(300, 150)
	f:Point("CENTER", 0, 150)
	f:SetFrameStrata("TOOLTIP")
	f:SetAlpha(0)
	f:Hide()

	f.bg = f:CreateTexture(nil, "BACKGROUND")
	f.bg:SetTexture([[Interface\LevelUp\LevelUpTex]])
	f.bg:Point("BOTTOM")
	f.bg:Size(400, 240)
	f.bg:SetTexCoord(0.00195313, 0.63867188, 0.03710938, 0.23828125)
	f.bg:SetVertexColor(1, 1, 1, 0.7)

	f.lineTop = f:CreateTexture(nil, "BACKGROUND")
	f.lineTop:SetDrawLayer("BACKGROUND", 2)
	f.lineTop:SetTexture([[Interface\LevelUp\LevelUpTex]])
	f.lineTop:Point("TOP")
	f.lineTop:Size(418, 7)
	f.lineTop:SetTexCoord(0.00195313, 0.81835938, 0.01953125, 0.03320313)

	f.lineBottom = f:CreateTexture(nil, "BACKGROUND")
	f.lineBottom:SetDrawLayer("BACKGROUND", 2)
	f.lineBottom:SetTexture([[Interface\LevelUp\LevelUpTex]])
	f.lineBottom:Point("BOTTOM")
	f.lineBottom:Size(418, 7)
	f.lineBottom:SetTexCoord(0.00195313, 0.81835938, 0.01953125, 0.03320313)

	f.logo = f:CreateTexture(nil, 'OVERLAY')
	f.logo:Size(125, 120)
	f.logo:SetTexture('Interface\\AddOns\\ElvUI_KlixUI\\media\\textures\\KlixUILogo.tga')
	f.logo:Point('CENTER', f, 'CENTER', 0, 4)
	
	f.version = KUI:CreateText(f, "OVERLAY", 16, nil, "CENTER")
	f.version:FontTemplate(nil, 16, nil)
	f.version:Point("BOTTOM", f.logo, "BOTTOM", 0, -12)
	f.version:SetFormattedText("v%s", KUI.Version)
	f.version:SetTextColor(249/255, 96/255, 217/255, 1)
end

function KUI:SplashScreen()
	if not E.db.KlixUI.general.splashScreen then return end
	
	CreateSplashScreen()
	
	local db = E.private.KlixUI.session
	local date = GetCurrentCalendarTime()
	local presentWeekday = date and date.weekday
	if not db or not presentWeekday then return end
    if presentWeekday == db.day then return end
	E:Delay(6, function()
        KUI:ShowSplashScreen()
    end)
    db.day = presentWeekday
end
