local KUI, T, E, L, V, P, G = unpack(select(2, ...))
local KDT = KUI:NewModule('KuiDataTexts', 'AceEvent-3.0')
local DT = E:GetModule('DataTexts')

local hooksecurefunc = hooksecurefunc

function KDT:Initialize()

	hooksecurefunc(DT, "UpdatePanelInfo", function(DT, panelName, panel)
		if not panel then return end
		local db = panel.db or P.datatexts.panels[panelName] and DT.db.panels[panelName]
		if not db then return end

		-- Need to find a way to hide my styling if changing the option from a panel
		if panel and not panel.styled then
			if db.backdrop then
				panel:Styling()
			end
			panel.styled = true
		end
	end)
end

KUI:RegisterModule(KDT:GetName())