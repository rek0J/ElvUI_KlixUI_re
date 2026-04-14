local KUI, T, E, L, V, P, G = unpack(select(2, ...))
local KUIC = KUI:GetModule("KuiUnits")
local UF = E:GetModule("UnitFrames")

function KUIC:Configure_Castbar(frame)
	local castbar = frame.Castbar

	if castbar.backdrop and not castbar.isStyled then
		castbar.backdrop:Styling(false, false, true)
		castbar.isStyled = true
	end
end

function KUIC:InitCastBar()
	hooksecurefunc(UF, "Configure_Castbar", KUIC.Configure_Castbar)
end
