local KUI, T, E, L, V, P, G = unpack(select(2, ...))
local KTT = KUI:GetModule("KuiTooltip")
local PI = KUI:GetModule("ProgressInfo", true)
--local RI = KUI:GetModule("RealmInfo")

if not PI then return end -- MoP Classic: skip options if module missing

local function Tooltip()
	E.Options.args.KlixUI.args.modules.args.tooltip = {
		order = 32,
		type = "group",
		name = L["Tooltip"],
		childGroups = "tab",
		disabled = function() return not E.private.tooltip.enable end,
		get = function(info) return E.db.KlixUI.tooltip[ info[#info] ] end,
		set = function(info, value) E.db.KlixUI.tooltip[ info[#info] ] = value; E:StaticPopup_Show("PRIVATE_RL"); end,
		args = {
			header = {
				order = 1,
				type = "header",
				name = KUI:cOption(L["Tooltip"]),
			},
			general = {
				type = "group",
				name = L["General"],
				order = 2,
				guiInline = true,
				get = function(info) return E.db.KlixUI.tooltip[ info[#info] ] end,
				set = function(info, value) E.db.KlixUI.tooltip[ info[#info] ] = value; E:StaticPopup_Show("PRIVATE_RL"); end,
				args = {
					tooltip = {
						order = 1,
						type = "toggle",
						name = L["Tooltip"],
						desc = L["Change the visual appearance of the Tooltip.\nCredit: |cffff7d0aMerathilisUI|r"],
					},
					titleColor = {
						order = 2,
						type = "toggle",
						name = L["Title Color"],
						desc = L["Change the color of the title to something more cool!"],
						disabled = function() return not E.private.tooltip.enable or not E.db.KlixUI.tooltip.tooltip end,
						set = function(info, value) E.db.KlixUI.tooltip.titleColor = value end,
					},
					memberInfo = {
						order = 3,
						type = "toggle",
						name = L["LFG Member Info"],
						desc = L["Adds member info for the LFG group list tooltip."],
						set = function(info, value) E.db.KlixUI.tooltip.memberInfo = value end,
					},

					achievement = {
						order = 4,
						type = "toggle",
						name = ACHIEVEMENT_BUTTON,
						desc = L["Adds information to the tooltip, on which character you earned an achievement.\nCredit: |cffff7d0aMerathilisUI|r"],
						set = function(info, value) E.db.KlixUI.tooltip.achievement = value end,
					},

					keystone = {
						order = 5,
						type = "toggle",
						name = L["Keystone"],
						desc = L["Adds descriptions for mythic keystone properties to their tooltips."],
						hidden = function() return E.Mists end,
					},
				},
			},

			azerite = {
				type = "group",
				order = 3,
				name = L["Azerite"],
				disabled = function() return E.Mists or T.IsAddOnLoaded("AzeriteTooltip") end,
				hidden = function() return E.Mists or T.IsAddOnLoaded("AzeriteTooltip") end,
				get = function(info) return E.db.KlixUI.tooltip.azerite[ info[#info] ] end,
				set = function(info, value) E.db.KlixUI.tooltip.azerite[ info[#info] ] = value end,
				args = {
					enable = {
						order = 1,
						type = "toggle",
						name = L["Enable"],
						desc = L["Enable/disable the azerite tooltip."],
						set = function(info, value) E.db.KlixUI.tooltip.azerite[ info[#info] ] = value; E:StaticPopup_Show("PRIVATE_RL"); end,
					},
					space1 = {
						order = 2,
						type = "description",
						name = "",
					},
					space2 = {
						order = 3,
						type = "description",
						name = "",
					},
					RemoveBlizzard = {
						order = 4,
						type = "toggle",
						name = L["Remove Blizzard"],
						desc = L["Replaces the blizzard azerite tooltip text."],
						disabled = function() return not E.db.KlixUI.tooltip.azerite.enable end,
					},

					OnlySpec = {
						order = 5,
						type = "toggle",
						name = L["Specialization"],
						desc = L["Only show the traits for your current specialization."],
						disabled = function() return not E.db.KlixUI.tooltip.azerite.enable end,
					},
					Compact = {
						order = 6,
						type = "toggle",
						name = L["Compact"],
						desc = L["Only show icons in the azerite tooltip."],
						disabled = function() return not E.db.KlixUI.tooltip.azerite.enable end,
					},
				},
			},

			corruption = {
				type = "group",
				order = 4,
				name = L["Corruption"],
				disabled = function() return E.Mists or T.IsAddOnLoaded("CorruptionTooltips") end,
				hidden = function() return E.Mists or T.IsAddOnLoaded("CorruptionTooltips") end,
				get = function(info) return E.db.KlixUI.tooltip.corruption[ info[#info] ] end,
				set = function(info, value) E.db.KlixUI.tooltip.corruption[ info[#info] ] = value; E:StaticPopup_Show("PRIVATE_RL"); end,
				args = {
					enable = {
						order = 1,
						type = "toggle",
						name = L["Enable"],
						desc = L["Show the name and level of corruption on item tooltips."],
					},
					append = {
						order = 2,
						type = "toggle",
						name = L["Append"],
						desc = L["Swap position of the tooltip."],
						disabled = function() return not E.db.KlixUI.tooltip.corruption.enable end,
					},
					english = {
						order = 3,
						type = "toggle",
						name = L["English"],
						desc = L["Swap between English and native Corruption name."],
						disabled = function() return not E.db.KlixUI.tooltip.corruption.enable end,
					},
				},
			},

			progressInfo = {
				type = "group",
				name = L["Raid Progression"],
				order = 5,
				disabled = function() return E.Mists or not E.private.tooltip.enable or T.IsAddOnLoaded("RaiderIO") end,
				hidden = function() return E.Mists end,
				get = function(info) return E.db.KlixUI.tooltip.progressInfo[ info[#info] ] end,
				set = function(info, value) E.db.KlixUI.tooltip.progressInfo[ info[#info] ] = value end,
				args = {
					enable = {
						order = 1,
						type = 'toggle',
						name = L["Enable"],
						desc = L["Shows raid progress of a character in the tooltip.\n|cffff8000Note: The visibility of the raid progress can be changed in the display option.|r"],
					},

					space1 = {
						order = 2,
						type = "description",
						name = "",
					},

					space2 = {
						order = 3,
						type = "description",
						name = "",
					},

					display = {
						order = 4,
						type = "select",
						name = L["Display"],
						desc = L["Change how the raid progress should display in the tooltip."],
						disabled = function() return not E.db.KlixUI.tooltip.progressInfo.enable end,
						set = function(info, value) E.db.KlixUI.tooltip.progressInfo[ info[#info] ] = value; E:StaticPopup_Show("PRIVATE_RL"); end,
						values = {
							["ALWAYS"] = L["Always"],
							["SHIFT"] = L["Shift"],
						},
					},

					NameStyle = {
						order = 5,
						name = L["Name Style"],
						type = "select",
						set = function(info, value) E.db.KlixUI.tooltip.progressInfo[ info[#info] ] = value; T.table_wipe(PI.Cache) end,
						disabled = function() return not E.db.KlixUI.tooltip.progressInfo.enable end,
						values = {
							["LONG"] = L["Full"],
							["SHORT"] = L["Short"],
						},
					},

					DifStyle = {
						order = 6,
						name = L["Difficulty Style"],
						type = "select",
						set = function(info, value) E.db.KlixUI.tooltip.progressInfo[ info[#info] ] = value; T.table_wipe(PI.Cache) end,
						disabled = function() return not E.db.KlixUI.tooltip.progressInfo.enable end,
						values = {
							["LONG"] = L["Full"],
							["SHORT"] = L["Short"],
						},
					},

					Raids = {
						order = 7,
						type = "group",
						name = RAIDS,
						guiInline = true,
						get = function(info) return E.db.KlixUI.tooltip.progressInfo.raids[ info[#info] ] end,
						set = function(info, value) E.db.KlixUI.tooltip.progressInfo.raids[ info[#info] ] = value end,
						disabled = function() return not E.db.KlixUI.tooltip.progressInfo.enable end,
						args = {
							uldir = { order = 1, type = "toggle", name = KUI:GetMapInfo(1148 , "name") },
							dazaralor = { order = 2, type = "toggle", name = KUI:GetMapInfo(1358 , "name") },
							crucible = { order = 3, type = "toggle", name = KUI:GetMapInfo(1345 , "name") },
							eternalpalace = { order = 4, type = "toggle", name = KUI:GetMapInfo(1512 , "name") },
							nyalotha = { order = 5, type = "toggle", name = KUI:GetMapInfo(1580 , "name") },
						},
					},
				},
			},

			nameHover = {
				order = 6,
				type = "group",
				name = L["Name Hover"],
				desc = L["Shows the unit name, at the cursor, when hovering over a target."],
				get = function(info) return E.db.KlixUI.nameHover[ info[#info] ] end,
				set = function(info, value) E.db.KlixUI.nameHover[ info[#info] ] = value; E:StaticPopup_Show("PRIVATE_RL"); end,
				args = {
					enable = {
						order = 1,
						type = "toggle",
						name = L["Enable"],
					},

					space1 = {
						order = 2,
						type = "description",
						name = "",
					},

					space2 = {
						order = 3,
						type = "description",
						name = "",
					},

					guild = {
						order = 4,
						type = 'toggle',
						name = L["Guild Name"],
						desc = L["Shows the current mouseover units guild name."],
						disabled = function() return not E.db.KlixUI.nameHover.enable end,
						set = function(info, value) E.db.KlixUI.nameHover.guild = value end,
					},

					guildRank = {
						order = 5,
						type = 'toggle',
						name = L["Guild Rank"],
						desc = L["Shows the current mouseover units guild rank."],
						disabled = function() return not E.db.KlixUI.nameHover.enable or not E.db.KlixUI.nameHover.guild end,
						set = function(info, value) E.db.KlixUI.nameHover.guildRank = value end,
					},

					race = {
						order = 6,
						type = 'toggle',
						name = L["Level, Race & Class"],
						desc = L["Shows the current mouseover units level, race and class.\n|cffff8000Note: Holding down the shift key will display the gender aswell!|r"],
						disabled = function() return not E.db.KlixUI.nameHover.enable end,
						set = function(info, value) E.db.KlixUI.nameHover.race = value end,
					},

					space3 = {
						order = 7,
						type = "description",
						name = "",
					},

					realm = {
						order = 8,
						type = 'toggle',
						name = L["Realm Name"],
						desc = L["Shows the current mouseover units realm name when holding down the shift-key."],
						disabled = function() return not E.db.KlixUI.nameHover.enable end,
						set = function(info, value) E.db.KlixUI.nameHover.realm = value end,
					},

					realmAlways = {
						order = 9,
						type = 'toggle',
						name = L["Always Show Realm Name"],
						desc = L["Always show the current mouseover units realm name."],
						disabled = function() return not E.db.KlixUI.nameHover.enable or not E.db.KlixUI.nameHover.realm end,
						set = function(info, value) E.db.KlixUI.nameHover.realmAlways = value end,
					},

					titles = {
						order = 10,
						type = 'toggle',
						name = L["Titles"],
						desc = L["Shows the current mouseover units titles."],
						disabled = function() return not E.db.KlixUI.nameHover.enable end,
						set = function(info, value) E.db.KlixUI.nameHover.titles = value end,
					},

					font = {
						order = 11,
						type = 'select', dialogControl = 'LSM30_Font',
						name = L["Font"],
						values = function()
							return AceGUIWidgetLSMlists and AceGUIWidgetLSMlists.font or {}
						end,
						disabled = function() return not E.db.KlixUI.nameHover.enable end,
					},

					fontSize = {
						order = 12,
						type = "range",
						name = L["Size"],
						min = 4, max = 24, step = 1,
						disabled = function() return not E.db.KlixUI.nameHover.enable end,
					},

					fontOutline = {
						order = 13,
						type = "select",
						name = L["Font Outline"],
						values = {
							["NONE"] = NONE,
							["OUTLINE"] = "OUTLINE",
							["MONOCHROMEOUTLINE"] = "MONOCROMEOUTLINE",
							["THICKOUTLINE"] = "THICKOUTLINE",
						},
						disabled = function() return not E.db.KlixUI.nameHover.enable end,
					},
				},
			},		
		   },
	   }
T.table_insert(KUI.Config, Tooltip)
end
