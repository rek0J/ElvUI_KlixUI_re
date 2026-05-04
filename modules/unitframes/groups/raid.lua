local KUI, T, E, L, V, P, G = unpack(select(2, ...))
local KUF = KUI:GetModule("KuiUnits")
local UF = E:GetModule("UnitFrames")

function KUF:Update_RaidFrames(frame)
	KUF:StyleTransparentHealth(frame, "Raid")
end

function KUF:InitRaid()
	local units = E.db.unitframe and E.db.unitframe.units
	local raid = units and (units.raid1 or units.raid)
	if not raid or not raid.enable or not UF.Update_RaidFrames then return end

	hooksecurefunc(UF, "Update_RaidFrames", KUF.Update_RaidFrames)
end
