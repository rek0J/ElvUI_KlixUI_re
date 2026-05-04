local KUI, T, E, L, V, P, G = unpack(select(2, ...))
local FK = KUI:NewModule("FocusKey")

function FK:Initialize()
	if not E.db.KlixUI.unitframes.focusKey.enable then return end
	
	local f = T.CreateFrame("CheckButton", "KuiFocusButton", E.UIParent, "SecureActionButtonTemplate")
	f:SetAttribute("type1","macro")
	f:SetAttribute("macrotext","/focus mouseover")
	KUI:RunOutOfCombat("FocusKey:SetOverrideBindingClick", function()
		T.SetOverrideBindingClick(KuiFocusButton, true, E.db.KlixUI.unitframes.focusKey.focusButton1.."-BUTTON"..E.db.KlixUI.unitframes.focusKey.focusButton2, "KuiFocusButton")
	end)
end

KUI:RegisterModule(FK:GetName())
