local KUI, T, E, L, V, P, G = unpack(select(2, ...))
local KUF = KUI:GetModule("KuiUnits")
local UF = E:GetModule("UnitFrames")

function KUF:Update_FocusFrame(frame)
	KUF:StyleTransparentHealth(frame, "Focus")
end

function KUF:InitFocus()
	if not E.db.unitframe.units.focus.enable then return end

	hooksecurefunc(UF, "Update_FocusFrame", KUF.Update_FocusFrame)
end
