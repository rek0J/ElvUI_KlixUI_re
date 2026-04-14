local KUI, T, E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule('Skins')

local r, g, b = T.unpack(E["media"].rgbvaluecolor)

local function StyleCalendarFrame(frame)
	local target = frame and (frame.backdrop or frame)
	if target and target.Styling then
		target:Styling()
	end
end

local function styleCalendar()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.calendar ~= true or E.private.KlixUI.skins.blizzard.calendar ~= true then return end
	
	StyleCalendarFrame(_G.CalendarFrame)
	StyleCalendarFrame(_G.CalendarCreateEventFrame)
	StyleCalendarFrame(_G.CalendarViewHolidayFrame)
	StyleCalendarFrame(_G.CalendarViewEventFrame)

	for i = 1, 42 do
		local darkFrame = _G["CalendarDayButton"..i.."DarkFrame"]
		local bu = _G["CalendarDayButton"..i]
		if darkFrame then
			darkFrame:SetAlpha(.5)
		end
		if bu then
			bu:DisableDrawLayer("BACKGROUND")
			bu:SetHighlightTexture(E["media"].normTex)
			local hl = bu:GetHighlightTexture()
			if hl then
				hl:SetVertexColor(r, g, b, .2)
				hl.SetAlpha = KUI.dummy
				hl:SetPoint("TOPLEFT", -1, 1)
				hl:SetPoint("BOTTOMRIGHT")
			end
		end
	end

	for i = 1, 7 do
		local background = _G["CalendarWeekday"..i.."Background"]
		if background then
			background:SetAlpha(0)
		end
	end

	if _G.CalendarWeekdaySelectedTexture then
		_G.CalendarWeekdaySelectedTexture:SetDesaturated(true)
		_G.CalendarWeekdaySelectedTexture:SetVertexColor(r, g, b)
	end

	if _G.CalendarViewEventAcceptButton and _G.CalendarViewEventAcceptButton.flashTexture then
		_G.CalendarViewEventAcceptButton.flashTexture:SetTexture("")
	end
	if _G.CalendarViewEventTentativeButton and _G.CalendarViewEventTentativeButton.flashTexture then
		_G.CalendarViewEventTentativeButton.flashTexture:SetTexture("")
	end
	if _G.CalendarViewEventDeclineButton and _G.CalendarViewEventDeclineButton.flashTexture then
		_G.CalendarViewEventDeclineButton.flashTexture:SetTexture("")
	end

	local todayFrame = _G.CalendarTodayFrame and (_G.CalendarTodayFrame.backdrop or _G.CalendarTodayFrame)
	if todayFrame and todayFrame.SetBackdropBorderColor then
		todayFrame:SetBackdropBorderColor(r, g, b)
	end
end

S:AddCallbackForAddon("Blizzard_Calendar", "KuiCalendar", styleCalendar)
