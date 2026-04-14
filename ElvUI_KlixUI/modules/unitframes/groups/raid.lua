local KUI, T, E, L, V, P, G = unpack(select(2, ...))
local KUF = KUI:GetModule("KuiUnits")
local UF = E:GetModule("UnitFrames")

function KUF:Update_RaidFrames(frame)
	local db = E.db.unitframe

	-- Only looks good on Transparent
	if db.colors.transparentHealth then
		if frame and frame.Health and not frame.isStyled then
			if E.db.KlixUI.unitframes.style then
				frame.Health:Styling(false, false, true)
				frame.isStyled = true
			end
		end
	end
end

function KUF:InitRaid()
	local units = E.db.unitframe and E.db.unitframe.units
	local raid = units and (units.raid1 or units.raid)
	if not raid or not raid.enable or not UF.Update_RaidFrames then return end

	hooksecurefunc(UF, "Update_RaidFrames", KUF.Update_RaidFrames)
end
