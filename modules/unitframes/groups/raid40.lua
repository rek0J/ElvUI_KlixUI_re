local KUI, T, E, L, V, P, G = unpack(select(2, ...))
local KUF = KUI:GetModule("KuiUnits")
local UF = E:GetModule("UnitFrames")

function KUF:Update_Raid40Frames(frame)
	KUF:StyleTransparentHealth(frame, "Raid40")
end

function KUF:InitRaid40()
	local units = E.db.unitframe and E.db.unitframe.units
	local raid = units and (units.raid3 or units.raid40)
	if not raid or not raid.enable or not UF.Update_Raid40Frames then return end

	hooksecurefunc(UF, "Update_Raid40Frames", KUF.Update_Raid40Frames)
end
