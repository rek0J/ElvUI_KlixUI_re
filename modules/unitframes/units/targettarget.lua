local KUI, T, E, L, V, P, G = unpack(select(2, ...))
local KUF = KUI:GetModule("KuiUnits")
local UF = E:GetModule("UnitFrames")

function KUF:Update_TargetTargetFrame(frame)
	KUF:StyleTransparentHealth(frame, "TargetTarget")
end

function KUF:InitTargetTarget()
	if not E.db.unitframe.units.targettarget.enable then return end

	hooksecurefunc(UF, "Update_TargetTargetFrame", KUF.Update_TargetTargetFrame)
end
