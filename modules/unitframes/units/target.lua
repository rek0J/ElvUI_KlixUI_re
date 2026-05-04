local KUI, T, E, L, V, P, G = unpack(select(2, ...))
local KUF = KUI:GetModule("KuiUnits")
local UF = E:GetModule("UnitFrames")

function KUF:Update_TargetFrame(frame)
	KUF:StyleTransparentHealth(frame, "Target")
end

function KUF:InitTarget()
	if not E.db.unitframe.units.target.enable then return end

	hooksecurefunc(UF, "Update_TargetFrame", KUF.Update_TargetFrame)
end
