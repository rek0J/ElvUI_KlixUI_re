local KUI, T, E, L, V, P, G = unpack(select(2, ...))
local lib = LibStub("LibElv-GameMenu-1.0")

function KUI:BuildGameMenu()
	if not E.db.KlixUI.general.GameMenuButton then return end
	if not E.Retail and not E.TBC then return end -- MoP Classic: ElvUI already manages the game menu button/layout here

	local toggleOptions = E.ToggleOptionsUI or E.ToggleOptions
	local buttons = {
		[1] = {
			["name"] = "GameMenu_KUIConfig",
			["text"] = KUI.Title,
			["func"] = function()
				if toggleOptions then
					toggleOptions(E)
				end

				LibStub("AceConfigDialog-3.0-ElvUI"):SelectGroup("ElvUI", "KlixUI")
				T.HideUIPanel(_G["GameMenuFrame"])
			end,
		},
	}
	for i = 1, #buttons do
		lib:AddMenuButton(buttons[i])
	end

	lib:UpdateHolder()
end
