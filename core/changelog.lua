local KUI, T, E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule('Skins')

local SOUNDKIT = SOUNDKIT
local PlaySound = PlaySound
local CLOSE = CLOSE
local DISABLED_FONT_COLOR = DISABLED_FONT_COLOR

local ChangeLogData = {
	"Changes:",
		"- MoP Classic compatibility and stability pass across core, options, maps, datatexts and skins",
		"- Fixed outdated ElvUI and KlixUI config calls, old option paths and missing defaults or guards",
		"- Fixed Bags, AutoButtons, MicroBar, SpecSwitch, Time, Talents and Professions related issues",
		"- Fixed Armory, IcyStats and CharacterStats integration for MoP spec, stats and tooltip paths",
		"- Fixed multiple Blizzard skin modules for MoP UI differences and retail-only hook paths",
		"- Restored Maps, World Map, Minimap styling and Square Minimap Buttons compatibility",
		"- Fixed layout, dropdown, game menu, locpanel, autolog and elite icon parenting issues",
		"- Added MoP-safe feature detection for retail-only APIs instead of hard Lua errors",
		" ", -- Section space!

	" ",

	"Notes:",
		"|cff00ffda- Detailed release notes are available in 'changelog.md'.|r",
		"|cff00ffda- Retail-only blocks without a safe MoP fallback are now skipped defensively instead of crashing.|r",
}

local function ModifiedString(string)
	local count = T.string_find(string, ":")
	local newString = string

	if count then
		local prefix = T.string_sub(string, 0, count)
		local suffix = T.string_sub(string, count + 1)
		local subHeader = T.string_find(string, "â€¢")

		if subHeader then newString = T.tostring("|cFFFFFF00".. prefix .. "|r" .. suffix) else newString = T.tostring("|cfff960d9" .. prefix .. "|r" .. suffix) end
	end

	for pattern in T.string_gmatch(string, "('.*')") do newString = newString:gsub(pattern, "|cFFFF8800" .. pattern:gsub("'", "") .. "|r") end
	return newString
end

local function GetChangeLogInfo(i)
	for line, info in T.pairs(ChangeLogData) do
		if line == i then return info end
	end
end

function KUI:CreateChangelog()
	local frame = T.CreateFrame("Frame", "KlixUIChangeLog", E.UIParent, 'BackdropTemplate')
	frame:Point("CENTER")
	frame:Size(600, 430)
	frame:CreateBackdrop("Transparent")
	frame:SetMovable(true)
	frame:EnableMouse(true)
	frame:RegisterForDrag("LeftButton")
	frame:SetScript("OnDragStart", frame.StartMoving)
	frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
	frame:SetClampedToScreen(true)
	frame.backdrop:Styling()

	local icon = T.CreateFrame("Frame", nil, frame, 'BackdropTemplate')
	icon:Point("BOTTOMLEFT", frame, "TOPLEFT", 0, 2)
	icon:Size(30, 30)
	icon:CreateBackdrop("Transparent")
	icon:Styling()

	icon.bg = icon:CreateTexture(nil, "ARTWORK")
	icon.bg:Point("TOPLEFT", 2, -2)
	icon.bg:Point("BOTTOMRIGHT", -2, 2)
	icon.bg:SetTexture(KUI.Logo)
	icon.bg:SetBlendMode("ADD")

	local title = T.CreateFrame("Frame", nil, frame, 'BackdropTemplate')
	title:Point("LEFT", icon, "RIGHT", 2, 0)
	title:Size(568, 30)
	title:CreateBackdrop("Transparent")
	title.backdrop:Styling()

	title.text = KUI:CreateText(title, "OVERLAY", 15, nil, "CENTER")
	title.text:Point("CENTER", title, 0, -1)
	title.text:SetText(KUI.Title.. "- ChangeLog version |cfff960d9"..KUI.Version)

	local close = T.CreateFrame("Button", nil, frame, "UIPanelButtonTemplate, BackdropTemplate")
	close:Point("BOTTOM", frame, "BOTTOM", 0, 10)
	close:SetText(CLOSE)
	close:Size(80, 20)
	close:SetScript("OnClick", function() frame:Hide() end)
	S:HandleButton(close)
	close:Disable()
	frame.close = close

	local warning = T.CreateFrame("Frame", nil, frame)
	warning:SetPoint("BOTTOMLEFT", frame, "TOPLEFT", 0, 34)
	warning:SetSize(600, 20)
	warning:CreateBackdrop("Transparent")
	warning:Styling()
	warning.text = warning:CreateFontString(nil, "OVERLAY")
	warning.text:SetPoint("CENTER", warning, 0, 1)
	warning.text:SetFont(E.media.normFont, 12, "OUTLINE")
	warning.text:SetText("|cffff0000WARNING: Delete your old ElvUI_KlixUI folder before installing v"..KUI.Version.."!!|r")
	KUI:CreatePulse(warning, 1, 1)
	warning:Show() -- Use this to toggle this frame!

	local countdown = KUI:CreateText(close, "OVERLAY", 12, nil, "CENTER")
	countdown:Point("LEFT", close.Text, "RIGHT", 3, 0)
	countdown:SetTextColor(DISABLED_FONT_COLOR:GetRGB())
	frame.countdown = countdown

	local offset = 4
	for i = 1, #ChangeLogData do
		local button = T.CreateFrame("Frame", "Button"..i, frame)
		button:SetSize(375, 16)
		button:Point("TOPLEFT", frame, "TOPLEFT", 5, -offset)

		if i <= #ChangeLogData then
			local string = ModifiedString(GetChangeLogInfo(i))

			button.Text = button:CreateFontString(nil, "OVERLAY")
			button.Text:SetFont(E.media.normFont, 12, "OUTLINE")
			button.Text:SetText(string)
			button.Text:Point("LEFT", 0, 0)
		end
		offset = offset + 16
	end
end

function KUI:CountDown()
	self.time = self.time - 1
	if self.time == 0 then
		KlixUIChangeLog.countdown:SetText("")
		KlixUIChangeLog.close:Enable()
		self:CancelAllTimers()
	else
		KlixUIChangeLog.countdown:SetText(T.string_format("(%s)", self.time))
	end
end

function KUI:ToggleChangeLog()
	if not KlixUIChangeLog then
		self:CreateChangelog()
	end
	T.PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF or 857)

	local fadeInfo = {}
	fadeInfo.mode = "IN"
	fadeInfo.timeToFade = 0.5
	fadeInfo.startAlpha = 0
	fadeInfo.endAlpha = 1
	E:UIFrameFade(KlixUIChangeLog, fadeInfo)

	self.time = 6
	self:CancelAllTimers()
	KUI:CountDown()
	self:ScheduleRepeatingTimer("CountDown", 1)
end

function KUI:CheckVersion(self)
	-- Don't show the frame if my install isn't finished
	--if E.db.KlixUI.installed == nil then return; end
	if not KUIDataDB["Version"] or (KUIDataDB["Version"] and KUIDataDB["Version"] ~= KUI.Version) then
		KUIDataDB["Version"] = KUI.Version
		KUI:ToggleChangeLog()
	end
end
