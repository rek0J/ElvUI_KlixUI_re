local KUI, T, E, L, V, P, G = unpack(select(2, ...))
local KUF = KUI:GetModule("KuiUnits")
local UF = E:GetModule("UnitFrames")

function KUF:Update_PartyFrames(frame)
	KUF:StyleTransparentHealth(frame, "Party")
end

function KUF:InitParty()
	if not E.db.unitframe.units.party.enable then return end

	hooksecurefunc(UF, "Update_PartyFrames", KUF.Update_PartyFrames)
end
