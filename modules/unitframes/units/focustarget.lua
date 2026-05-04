local KUI, T, E, L, V, P, G = unpack(select(2, ...))
local KUF = KUI:GetModule("KuiUnits")
local UF = E:GetModule("UnitFrames")

function KUF:Update_FocusTargetFrame(frame)
	KUF:StyleTransparentHealth(frame, "FocusTarget")
end

function KUF:InitFocusTarget()
	if not E.db.unitframe.units.focustarget.enable then return end

	hooksecurefunc(UF, "Update_FocusTargetFrame", KUF.Update_FocusTargetFrame)
end
