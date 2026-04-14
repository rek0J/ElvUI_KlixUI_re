local KUI, T, E, L, V, P, G = unpack(select(2, ...))
local KDT = KUI:GetModule("KuiDataTexts")
local DT = E:GetModule("DataTexts")
local LO = E:GetModule("Layout")

if E.db.KlixUI == nil then E.db.KlixUI = {} end

local function Datatexts()
	E.Options.args.KlixUI.args.modules.args.datatexts = {
		order = 11,
		type = "group",
		name = L["DataTexts"],
		childGroups = "tab",
		args = {
			name = {
				order = 1,
				type = 'header',
				name = KUI:cOption(L['DataTexts']),
			},
			intro = {
				order = 2,
				type = 'description',
				name = L["DT_DESC"],
			},
			space3 = {
				order = 3,
				type = "description",
				name = "",
			},
			general = {
				order = 4,
				type = "group",
				name = L["General"],
				args = {
				},
			},
			chat = {
				order = 10,
				type = 'group',
				name = L["Chat"],
				args = {
					enable = {
						order = 1,
						type = 'toggle',
						name = L["Enable"],
						desc = L['Show/Hide Chat DataTexts. ElvUI chat datatexts must be disabled'],
						get = function(info) return E.db.KlixUI.datatexts.chat[ info[#info] ] end,
						set = function(info, value) E.db.KlixUI.datatexts.chat[ info[#info] ] = value; LO:ToggleChatPanels(); end,
					},
					space1 = {
						order = 2,
						type = 'description',
						name = '',
					},
					space2 = {
						order = 3,
						type = "description",
						name = "",
					},
					transparent = {
						order = 4,
						type = 'toggle',
						name = L['Panel Transparency'],
						disabled = function() return not E.db.KlixUI.datatexts.chat.enable end,
						get = function(info) return E.db.KlixUI.datatexts.chat[ info[#info] ] end,
						set = function(info, value) E.db.KlixUI.datatexts.chat[ info[#info] ] = value; KUI:GetModule('KuiLayout'):ToggleTransparency(); end,
					},
					backdrop = {
						order = 5,
						type = 'toggle',
						name = L['Backdrop'],
						disabled = function() return not E.db.KlixUI.datatexts.chat.enable end,
						get = function(info) return E.db.KlixUI.datatexts.chat[ info[#info] ] end,
						set = function(info, value) E.db.KlixUI.datatexts.chat[ info[#info] ] = value; KUI:GetModule('KuiLayout'):ToggleTransparency(); end,
					},
					style = {
						order = 6,
						type = 'toggle',
						name = L["|cfff960d9KlixUI|r Style"],
						disabled = function() return not E.db.KlixUI.datatexts.chat.enable end,
						get = function(info) return E.db.KlixUI.datatexts.chat[ info[#info] ] end,
						set = function(info, value) E.db.KlixUI.datatexts.chat[ info[#info] ] = value; KUI:GetModule('KuiLayout'):Styles(); E:StaticPopup_Show('PRIVATE_RL'); end,
					},
					editBoxPosition = {
						order = 6,
						type = 'select',
						name = L['Chat EditBox Position'],
						desc = L['Position of the Chat EditBox, if datatexts are disabled this will be forced to be above chat.'],
						values = {
							['BELOW_CHAT'] = L['Below Chat'],
							['ABOVE_CHAT'] = L['Above Chat'],
							['MIDDLE_DT'] = L['Middle Datatext'],
							['EAB_1'] = L['Actionbar 1'],
							['EAB_2'] = L['Actionbar 2'],
						},
						disabled = function() return not E.db.KlixUI.datatexts.chat.enable end,
						get = function(info) return E.db.KlixUI.datatexts.chat[ info[#info] ] end,
						set = function(info, value) E.db.KlixUI.datatexts.chat[ info[#info] ] = value; E:GetModule('Chat'):UpdateEditboxAnchors() end,
					},
					showChatDt = {
						order = 7,
						type = 'select',
						name = L["Visibility"],
						values = {
							['SHOWBOTH'] = L["Show Both"],
							['LEFT'] = L["Left Only"],
							['RIGHT'] = L["Right Only"],
						},
						disabled = function() return not E.db.KlixUI.datatexts.chat.enable end,
						get = function(info) return E.db.KlixUI.datatexts.chat[ info[#info] ] end,
						set = function(info, value) E.db.KlixUI.datatexts.chat[ info[#info] ] = value; LO:ToggleChatPanels(); E:GetModule('Chat'):UpdateEditboxAnchors() end,
					},
				},
			},
			DataTexts = {
				order = 11,
				type = "group",
				name = L["Other DataTexts"],
				args = {
					KUIProfDT = {
						order = 1,
						type = "group",
						name = L["Professions Datatext"],
						get = function(info) return E.db.KlixUI.profDT[info[#info]] end,
						set = function(info, value) E.db.KlixUI.profDT[info[#info]] = value; DT:LoadDataTexts() end,
						args = {
							prof = {
								type = "select",
								order = 1,
								name = L["Professions"],
								desc = L["Select which profession to display."],
								values = function()
									local prof1, prof2, archy, fishing, cooking = T.GetProfessions()
									local profValues = {}
									if prof1 ~= nil then profValues['prof1'] = DT:GetProfessionName(prof1) end
									if prof2 ~= nil then profValues['prof2'] = DT:GetProfessionName(prof2) end
									if archy ~= nil then profValues['archy'] = DT:GetProfessionName(archy) end
									if fishing ~= nil then profValues['fishing'] = DT:GetProfessionName(fishing) end
									if cooking ~= nil then profValues['cooking'] = DT:GetProfessionName(cooking) end
									T.table_sort(profValues)
									return profValues
								end,
							},
							hint = {
								type = "toggle",
								order = 2,
								name = L["Show Hint"],
								desc = L["Show the hint in the tooltip."],
							},
						},
					},

					KUITimeDT = {
						order = 2,
						type = "group",
						name = L["Time Datatext"],
						get = function(info) return E.db.KlixUI.timeDT[ info[#info] ] end,
						set = function(info, value) E.db.KlixUI.timeDT[ info[#info] ] = value; E:StaticPopup_Show("PRIVATE_RL") end,
						args = {
							size = {
								order = 1,
								type = "range",
								name = L["Clock Size"],
								desc = L["Change the size of the time datatext individually from other datatexts."],
								min = 0.1, max = 3, step = 0.1,
							},
							date = {
								order = 2,
								type = "toggle",
								name = L["Date Condensed"],
								desc = L["Display a condensed version of the current date."],
							},
							invasions = {
								order = 3,
								type = "toggle",
								name = L["Invasions"],
								desc = L["Display upcomming and current Legion and BfA invasions in the time datatext tooltip."],
							},
							played = {
								order = 4,
								type = "toggle",
								name = L["Time Played"],
								desc = L["Display session, level and total time played in the time datatext tooltip."],
							},
						},
					},
					KUITitleDT = {
						order = 4,
						type = "group",
						name = L["Titles Datatext"],
						get = function(info) return E.db.KlixUI.titlesDT[info[#info]] end,
						set = function(info, value) E.db.KlixUI.titlesDT[info[#info]] = value; DT:LoadDataTexts() end,
						args = {
							useName = {
								order = 1,
								type = "toggle",
								name = L["Use Character Name"],
								desc = L["Use your character's class color and name in the tooltip."],
							},
						},
					},
				},
			},
			--panels = {
				--order = 10,
				--type = "group",
				--name = KUI:cOption(L["DataTexts"]),
				--guiInline = true,
				--args = {},
			--},

			gotodatatexts = {
				order = 11,
				type = "execute",
				name = L["ElvUI DataTexts"],
				func = function() LibStub("AceConfigDialog-3.0-ElvUI"):SelectGroup("ElvUI", "datatexts") end,
			},
		},
	}
	
	--local datatexts = {}
	--for name, _ in T.pairs(DT.RegisteredDataTexts) do
		--datatexts[name] = name
	--end
	--datatexts[""] = NONE

	--local table = E.Options.args.KlixUI.args.datatexts.args.panels.args
	--local i = 0
	--for pointLoc, tab in T.pairs(P.KlixUI.datatexts.panels) do
		--i = i + 1
		--if not _G[pointLoc] then table[pointLoc] = nil; return; end
		--if type(tab) == "table" then
			--table[pointLoc] = {
				--type = "group",
				--args = {},
				--name = L[pointLoc] or pointLoc,
				--guiInline = true,
				--order = i,
			--}
			--for option, value in T.pairs(tab) do
				--table[pointLoc].args[option] = {
					--type = "select",
					--name = L[option] or option:upper(),
					--values = datatexts,
					--get = function(info) return E.db.KlixUI.datatexts.panels[pointLoc][ info[#info] ] end,
					--set = function(info, value) E.db.KlixUI.datatexts.panels[pointLoc][ info[#info] ] = value; DT:LoadDataTexts() end,
				--}
			--end
		--elseif type(tab) == "string" then
			--table[pointLoc] = {
				--type = "select",
				--name = L[pointLoc] or pointLoc,
				--values = datatexts,
				--get = function(info) return E.db.KlixUI.datatexts.panels[pointLoc] end,
				--set = function(info, value) E.db.KlixUI.datatexts.panels[pointLoc] = value; DT:LoadDataTexts() end,
				--T.print(pointLoc)
			--}
		--end
	--end
end
T.table_insert(KUI.Config, Datatexts)

local function injectElvUIDataTextsOptions()
	E.Options.args.datatexts.args.general.args.spacer1 = {
		order = 21,
		type = 'description',
		name = '',
	}

	E.Options.args.datatexts.args.general.args.spacer2 = {
		order = 22,
		type = 'header',
		name = '',
	}
	
	E.Options.args.datatexts.args.general.args.gotoklixui = {
		order = 23,
		type = "execute",
		name = KUI:cOption(L["KlixUI DataTexts"]),
		func = function() LibStub("AceConfigDialog-3.0-ElvUI"):SelectGroup("ElvUI", "KlixUI", "modules", "datatexts") end,
	}
end
T.table_insert(KUI.Config, injectElvUIDataTextsOptions)