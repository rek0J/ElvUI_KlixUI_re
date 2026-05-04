local KUI, T, E, L, V, P, G = unpack(select(2, ...))
local KUF = KUI:GetModule("KuiUnits")
local UF = E:GetModule("UnitFrames")

function KUF:Update_BossFrames(frame)
	KUF:StyleTransparentHealth(frame, "Boss")
end

function KUF:InitBoss()
	if not E.db.unitframe.units.boss.enable then return end

	hooksecurefunc(UF, "Update_BossFrames", KUF.Update_BossFrames)
end
