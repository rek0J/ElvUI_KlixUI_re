local KUI, T, E, L, V, P, G = unpack(select(2, ...))
local KUF = KUI:GetModule("KuiUnits")
local UF = E:GetModule("UnitFrames")

function KUF:Update_PlayerFrame(frame)
	KUF:StyleTransparentHealth(frame, "Player")
end

function KUF:InitPlayer()
	if not E.db.unitframe.units.player.enable then return end

	hooksecurefunc(UF, "Update_PlayerFrame", KUF.Update_PlayerFrame)
end
