local KUI, T, E, L, V, P, G = unpack(select(2, ...))
local KBT = KUI:GetModule("KuiBetterTalents")

local function BetterTalentsTable()
	E.Options.args.KlixUI.args.modules.args.talents = {
		type = "group",
		name = L["Talents"],
		order = 29,
		disabled = function() return E.Mists end,
		args = {
			name = {
				order = 1,
				type = "header",
				name = KUI:cOption(L["Talents"]),
			},
			mistsNotice = {
				order = 2,
				type = "description",
				name = E.Mists and L["This module is disabled on MoP Classic because the KlixUI Better Talents overlay is not compatible with the native MoP talent frame."] or "",
			},
			gototalents = {
				order = 3,
				type = "execute",
				name = L["Toggle Talent Frame"],
				func = function()
					local toggleOptions = E.ToggleOptions or E.ToggleOptionsUI
					T.ToggleTalentFrame()
					if toggleOptions then
						toggleOptions(E)
					end
				end,
			},
			space1 = {
				order = 4,
				type = "description",
				name = "",
			},
			space2 = {
				order = 5,
				type = "description",
				name = "",
			},
			enable = {
				order = 6,
				type = "toggle",
				name = L["Enable"],
				desc = L["Enable/disable the |cfff960d9KlixUI|r Better Talents Frame."],
				get = function(info) return E.db.KlixUI.talents.enable end,
				set = function(info, value) E.db.KlixUI.talents.enable = value; E:StaticPopup_Show("PRIVATE_RL"); end,
			},
			space1 = {
				order = 7,
				type = "description",
				name = "",
			},
			borderGlow = {
				order = 8,
				type = "toggle",
				name = L["Border Glow"],
				desc = L["Shows an animated border glow for the currently selected talents."],
				disabled = function() return not E.db.KlixUI.talents.enable end,
				get = function(info) return E.db.KlixUI.talents.borderGlow end,
				set = function(info, value) E.db.KlixUI.talents.borderGlow = value; KBT:Update() end,
			},
			DefaultToTalentsTab = {
				order = 9,
				type = "toggle",
				name = L["Default to Talents Tab"],
				desc = L["Defaults to the talents tab of the talent frame on login. By default WoW shows you the specialization tab."],
				disabled = function() return not E.db.KlixUI.talents.enable end,
				get = function(info)
					return E.db.KlixUI.talents.DefaultToTalentsTab
				end,
				set = function(info, value)
					E.db.KlixUI.talents.DefaultToTalentsTab = value
				end,
			},
			AutoHidePvPTalents = {
				order = 10,
				type = "toggle",
				name = L["Auto Hide PvP Talents"],
				desc = L["Closes the PvP talents flyout on login. PvP talents and warmode flag are still accessible by manually opening the PvP talents flyout."],
				disabled = function() return not E.db.KlixUI.talents.enable end,
				get = function(info)
					return E.db.KlixUI.talents.AutoHidePvPTalents
				end,
				set = function(info, value)
					E.db.KlixUI.talents.AutoHidePvPTalents = value
				end,
			},
		},
	}
end
T.table_insert(KUI.Config, BetterTalentsTable)
