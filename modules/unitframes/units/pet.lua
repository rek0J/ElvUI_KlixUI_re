local KUI, T, E, L, V, P, G = unpack(select(2, ...))
local KUF = KUI:GetModule("KuiUnits")
local UF = E:GetModule("UnitFrames")

function KUF:Update_PetFrame(frame)
	KUF:StyleTransparentHealth(frame, "Pet")
end

function KUF:InitPet()
	if not E.db.unitframe.units.pet.enable then return end

	hooksecurefunc(UF, "Update_PetFrame", KUF.Update_PetFrame)
end
