local KUI, T, E, L, V, P, G = unpack(select(2, ...))
local UF = E.UnitFrames

local PlayerUnitFrame = _G.ElvUF_Player
local HookInstalled

local function GetPlayerUnitFrame()
	local frame = _G.ElvUF_Player or PlayerUnitFrame
	if frame and frame.ClassPower and frame.Power then
		PlayerUnitFrame = frame
		return frame
	end
end

local function Reposition(classbar)
	if not E.db.unitframe.units.player.power.detachFromFrame then return end
	if E.db.KlixUI.unitframes.powerBar ~= true or E.db.unitframe.units.player.enable ~= true or E.db.unitframe.units.player.power.enable ~= true then return end

	local frame = GetPlayerUnitFrame()
	if not frame or classbar ~= frame.ClassPower then
		return
	end

	if not frame.CLASSBAR_DETACHED then
		return --No need to reposition
	end

	local height = (frame.CLASSBAR_SHOWN and 19 or 30)
	if T.IsAddOnLoaded("Masque") and T.IsAddOnLoaded("Masque_KlixUI") then
		frame.Power:SetSize(244, height)
	else
		frame.Power:SetSize(245, height)
	end
end

local function ForceResourceBarUpdate()
	local frame = GetPlayerUnitFrame()
	if not frame or not frame.ClassPower then
		return
	end

	UF.ToggleResourceBar(frame.ClassPower)
end

local f = T.CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
f:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("UNIT_ENTERED_VEHICLE")
f:RegisterEvent("UNIT_ENTERING_VEHICLE")
f:RegisterEvent("UNIT_EXITED_VEHICLE")
f:RegisterEvent("UNIT_EXITING_VEHICLE")
f:RegisterEvent("PLAYER_GAINS_VEHICLE_DATA")
f:RegisterEvent("PLAYER_LOSES_VEHICLE_DATA")
f:RegisterEvent("UNIT_MODEL_CHANGED")
f:SetScript("OnEvent", function(self, event)
	if event == "PLAYER_ENTERING_WORLD" then
		self:UnregisterEvent(event)
	end

	if not HookInstalled then
		hooksecurefunc(UF, "ToggleResourceBar", Reposition)
		HookInstalled = true
	end

	ForceResourceBarUpdate()
end)
