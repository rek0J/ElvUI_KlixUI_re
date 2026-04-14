local KUI, T, E, L, V, P, G = unpack(select(2, ...))
local KUF = KUI:GetModule("KuiUnits")
local UF = E:GetModule('UnitFrames')
local LSM = E.LSM or E.Libs.LSM

-- Raid
function KUF:ChangeRaidHealthBarTexture()
	local header = _G['ElvUF_Raid']
	local bar = LSM:Fetch("statusbar", E.db.KlixUI.unitframes.textures.health)
	if not header then return end -- MoP Classic: skip if header is missing
	for i = 1, header:GetNumChildren() do
		local group = T.select(i, header:GetChildren())

		for j = 1, group:GetNumChildren() do
			local unitbutton = T.select(j, group:GetChildren())
			if unitbutton.Health then
				if not unitbutton.Health.isTransparent or (unitbutton.Health.isTransparent and E.db.KlixUI.unitframes.textures.ignoreTransparency) then
					unitbutton.Health:SetStatusBarTexture(bar)
				end
			end
		end
	end
end
hooksecurefunc(UF, 'Update_RaidFrames', KUF.ChangeRaidHealthBarTexture)

-- Raid-40
function KUF:ChangeRaid40HealthBarTexture()
	local header = _G['ElvUF_Raid40']
	local bar = LSM:Fetch("statusbar", E.db.KlixUI.unitframes.textures.health)
	if not header then return end -- MoP Classic: skip if header is missing
	for i = 1, header:GetNumChildren() do
		local group = T.select(i, header:GetChildren())

		for j = 1, group:GetNumChildren() do
			local unitbutton = T.select(j, group:GetChildren())
			if unitbutton.Health then
				if not unitbutton.Health.isTransparent or (unitbutton.Health.isTransparent and E.db.KlixUI.unitframes.textures.ignoreTransparency) then
					unitbutton.Health:SetStatusBarTexture(bar)
				end
			end
		end
	end
end

if UF.Update_Raid40Frames then
	hooksecurefunc(UF, 'Update_Raid40Frames', KUF.ChangeRaid40HealthBarTexture)
end

-- Party
function KUF:ChangePartyHealthBarTexture()
	local header = _G['ElvUF_Party']
	local bar = LSM:Fetch("statusbar", E.db.KlixUI.unitframes.textures.health)
	if not header then return end -- MoP Classic: skip if header is missing
	for i = 1, header:GetNumChildren() do
		local group = T.select(i, header:GetChildren())
		for j = 1, group:GetNumChildren() do
			local unitbutton = T.select(j, group:GetChildren())
			if unitbutton.Health then
				if not unitbutton.Health.isTransparent or (unitbutton.Health.isTransparent and E.db.KlixUI.unitframes.textures.ignoreTransparency) then
					unitbutton.Health:SetStatusBarTexture(bar)
				end
			end
		end
	end
end
hooksecurefunc(UF, 'Update_PartyFrames', KUF.ChangePartyHealthBarTexture)

function KUF:ChangeHealthBarTexture()
	KUF:ChangeRaidHealthBarTexture()
	KUF:ChangeRaid40HealthBarTexture()
	KUF:ChangePartyHealthBarTexture()
end
if UF.Update_Raid40Frames and KUF.ChangeRaid40HealthBarTexture then
	hooksecurefunc(UF, 'Update_Raid40Frames', KUF.ChangeRaid40HealthBarTexture)
end -- MoP Classic: only hook if function exists

hooksecurefunc(UF, 'Update_StatusBars', KUF.ChangeHealthBarTexture)
