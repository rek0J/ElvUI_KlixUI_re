local KUI, T, E, L, V, P, G = unpack(select(2, ...))
local KUF = KUI:GetModule("KuiUnits")
local UF = E:GetModule("UnitFrames")

function KUF:Update_PlayerFrame(frame)
	local db = E.db.KlixUI.unitframes

	-- Only looks good on Transparent
	if E.db.unitframe.colors.transparentHealth then
		if frame and frame.Health and not frame.isStyled then
			if E.db.KlixUI.unitframes.style then
				frame.Health:Styling(false, false, true)
				frame.isStyled = true
			end
		end
	end
end

function KUF:InitPlayer()
	if not E.db.unitframe.units.player.enable then return end

	hooksecurefunc(UF, "Update_PlayerFrame", KUF.Update_PlayerFrame)
end