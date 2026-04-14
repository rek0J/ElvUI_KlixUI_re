local KUI, T, E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule('Skins')

local function styleTradeSkill()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.tradeskill ~= true or E.private.KlixUI.skins.blizzard.tradeskill ~= true then return end

	-- MainFrame
	local frame = _G.TradeSkillFrame
	if not frame then return end
	frame:Styling()

	if frame.bg1 then
		frame.bg1:Hide()
	end

	if frame.bg2 then
		frame.bg2:Hide()
	end

	-- Reposition Optional Reagentlist due to TradeTabs
	local optionalReagents = frame.OptionalReagentList
	if optionalReagents then
		optionalReagents:ClearAllPoints()
		optionalReagents:SetPoint("BOTTOMLEFT", frame, "BOTTOMRIGHT", 40, 0)
		optionalReagents:Styling()
	end
end

S:AddCallbackForAddon("Blizzard_TradeSkillUI", "KuiTradeSkill", styleTradeSkill)
