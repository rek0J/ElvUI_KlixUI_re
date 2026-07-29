local KUI, T, E, L, V, P, G = unpack(select(2, ...))
local HM = KUI:NewModule("HealerMana", "AceEvent-3.0")

local function UpdateMana()
    if T.IsInRaid() then
		return
    elseif T.IsInGroup() then
        local header = _G['ElvUF_Party']
        if not header then return end

        for i = 1, header:GetNumChildren() do
            local group = T.select(i, header:GetChildren())
            if group then
                for j = 1, group:GetNumChildren() do
                    local unitbutton = T.select(j, group:GetChildren())
                    if unitbutton and unitbutton.Power and unitbutton.unit then
                        local role = T.UnitGroupRolesAssigned(unitbutton.unit)
                        unitbutton.Power:SetShown(role == "HEALER")
                    end
                end
            end
        end
    end
end

function HM:Initialize()
	if not E.db.unitframe.units.party.enable or not E.db.KlixUI.unitframes.healerMana or T.IsAddOnLoaded("ElvUI_HealerMana") then return end
	
	self:RegisterEvent("PLAYER_ENTERING_WORLD", UpdateMana)
	self:RegisterEvent("GROUP_ROSTER_UPDATE", UpdateMana)
	self:RegisterEvent("INSPECT_READY", UpdateMana)
end

KUI:RegisterModule(HM:GetName())
