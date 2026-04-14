local KUI, T, E, L, V, P, G = unpack(select(2, ...))
local KUF = KUI:GetModule("KuiUnits")
local UF = E:GetModule('UnitFrames')
local LSM = E.LSM or E.Libs.LSM

local function GetPowerBarTexture()
	local texture = E.db.KlixUI.unitframes.textures.power
	if type(texture) ~= "string" then
		texture = E.db.unitframe.statusbar
	end

	return LSM:Fetch("statusbar", texture)
end

local function UpdatePowerTexture(unitframe, bar)
	if unitframe and unitframe.Power and not unitframe.Power.isTransparent then
		unitframe.Power:SetStatusBarTexture(bar)
	end
end

local function UpdateHeaderPowerTexture(header, bar)
	if not header then return end

	for i = 1, header:GetNumChildren() do
		local group = T.select(i, header:GetChildren())
		UpdatePowerTexture(group, bar)

		if group then
			for j = 1, group:GetNumChildren() do
				local unitbutton = T.select(j, group:GetChildren())
				UpdatePowerTexture(unitbutton, bar)
			end
		end
	end
end

function KUF:Configure_Power(frame)
	local power = frame.Power

	if power and not power.isStyled then
		if E.db.KlixUI.unitframes.style then
			power:Styling(false, false, true)
			power.isStyled = true
		end
	end

	if frame.USE_POWERBAR then
		if frame.POWERBAR_DETACHED then
			if frame.POWER_VERTICAL then
				power:SetOrientation('VERTICAL')
			else
				power:SetOrientation('HORIZONTAL')
			end
			if power.backdrop.shadow then
				power.backdrop.shadow:Show()
			end
		else
			if power.backdrop.shadow then
				power.backdrop.shadow:Hide()
			end
		end
	end
end

-- Units
function KUF:ChangeUnitPowerBarTexture()
	local bar = GetPowerBarTexture()
	for _, unitframe in T.pairs(UF.units) do
		UpdatePowerTexture(unitframe, bar)
	end
end
hooksecurefunc(UF, "Update_AllFrames", KUF.ChangeUnitPowerBarTexture)

-- Raid
function KUF:ChangeRaidPowerBarTexture()
	local header = _G['ElvUF_Raid']
	local bar = GetPowerBarTexture()
	UpdateHeaderPowerTexture(header, bar)
end
hooksecurefunc(UF, 'Update_RaidFrames', KUF.ChangeRaidPowerBarTexture)

-- Raid-40

function KUF:ChangeRaid40PowerBarTexture()
	local header = _G['ElvUF_Raid40']
	if not header then return end -- MoP Classic: skip if header is missing
	local bar = GetPowerBarTexture()
	UpdateHeaderPowerTexture(header, bar)
end

if UF.Update_Raid40Frames then
	hooksecurefunc(UF, 'Update_Raid40Frames', KUF.ChangeRaid40PowerBarTexture)
end -- MoP Classic: only hook if function exists

-- Party
function KUF:ChangePartyPowerBarTexture()
	local header = _G['ElvUF_Party']
	local bar = GetPowerBarTexture()
	UpdateHeaderPowerTexture(header, bar)
end
hooksecurefunc(UF, 'Update_PartyFrames', KUF.ChangePartyPowerBarTexture)

-- Arena
function KUF:ChangeArenaPowerBarTexture()
	local bar = GetPowerBarTexture()
	for i = 1, 5 do
		local unitbutton = _G["ElvUF_Arena"..i]
		UpdatePowerTexture(unitbutton, bar)
	end
end
hooksecurefunc(UF, 'Update_ArenaFrames', KUF.ChangeArenaPowerBarTexture)

-- Boss
function KUF:ChangeBossPowerBarTexture()
	local bar = GetPowerBarTexture()
	for i = 1, 5 do
		local unitbutton = _G["ElvUF_Boss"..i]
		UpdatePowerTexture(unitbutton, bar)
	end
end
hooksecurefunc(UF, 'Update_BossFrames', KUF.ChangeBossPowerBarTexture)


function KUF:ChangePowerBarTexture()
	KUF:ChangeUnitPowerBarTexture()
	KUF:ChangeRaidPowerBarTexture()
	KUF:ChangeRaid40PowerBarTexture()
	KUF:ChangePartyPowerBarTexture()
	KUF:ChangeArenaPowerBarTexture()
	KUF:ChangeBossPowerBarTexture()
end
hooksecurefunc(UF, 'Update_StatusBars', KUF.ChangePowerBarTexture)

function KUF:InitPower()
	hooksecurefunc(UF, "Configure_Power", KUF.Configure_Power)
end
