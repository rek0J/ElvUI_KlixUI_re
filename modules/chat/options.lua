local KUI, T, E, L, V, P, G = unpack(select(2, ...))
local KC = KUI:GetModule("KuiChat")
local CH = E:GetModule("Chat")

if E.db.KlixUI == nil then E.db.KlixUI = {} end

local function ChatTable()
	E.Options.args.KlixUI.args.modules.args.chat = {
		order = 7,
		type = 'group',
		name = L['Chat'],
		get = function(info) return E.db.KlixUI.chat[ info[#info] ] end,
		set = function(info, value) E.db.KlixUI.chat[ info[#info] ] = value; E:StaticPopup_Show("PRIVATE_RL"); end,		
		args = {
			name = {
				order = 1,
				type = "header",
				name = KUI:cOption(L['Chat']),
			},

			chatButton = {
				order = 2,
				type = "toggle",
				name = L["Chat Menu"],
				desc = L["Create a chat button to increase the chat size."],
			},

			hidePlayerBrackets = {
				order = 3,
				type = "toggle",
				name = L["Hide Player Brackets"],
				desc = L["Removes brackets around the person who posts a chat message."],
				set = function(info, value) E.db.KlixUI.chat[ info[#info] ] = value end,
			},

			hideChat = {
				order = 4,
				type = "toggle",
				name = L["Hide Community Chat"],
				desc = L["Adds an overlay to the Community Chat. Useful for streamers."],
				set = function(info, value) E.db.KlixUI.chat[ info[#info] ] = value end,
			},

			emotes = {
				order = 5,
				type = "toggle",
				name = L["Emotes"],
			},

			classColorOverride = {
				order = 6,
				type = "toggle",
				name = L["Class Colors in Chat"],
				desc = L["Show player names in chat using their class color. Disabling this forces the default chat color (CVar: chatClassColorOverride)."],
				get = function() return T.GetCVar("chatClassColorOverride") == "0" end,
				set = function(info, value) T.SetCVar("chatClassColorOverride", value and "0" or "1") end,
			},

		-- Chat Separators
			separators = {
				order = 6,
				type = "group",
				name = L["Chat Separators"],
				guiInline = true,
				args = {
					chatTabSeparator = {
						order = 1,
						type = "select",
						name = L["Chat Tab Separators"],
						desc = L["Add a thin black line below chat tabs to separate them from chat messages."],
						get = function(info) return E.db.KlixUI.chat.chatTabSeparator end,
						set = function(info, value) E.db.KlixUI.chat.chatTabSeparator = value; KUI:GetModule('KuiLayout'):ToggleChatSeparators(); end,
						values = {
							['HIDEBOTH'] = L['Hide Both'],
							['SHOWBOTH'] = L['Show Both'],
							['LEFTONLY'] = L['Left Only'],
							['RIGHTONLY'] = L['Right Only'],
						},
					},
				},
			},

        -- ChatFade - thx Merathilis Credits fgprodigal (RayUI)
			chatFade = {
				order = 8,
				type = "group",
				name = L["Fade Chat"],
				guiInline = true,
				get = function(info) return E.db.KlixUI.chat.chatFade[ info[#info] ] end,
				set = function(info, value) E.db.KlixUI.chat.chatFade[ info[#info] ] = value; KC:Configure_ChatFade() end,
				args = {
					enable = {
						order = 1,
						type = "toggle",
						name = L["Enable"],
					},
					timeout = {
						order = 2,
						type = "range",
						min = 5, max = 60, step = 1,
						name = L["Auto hide timeout"],
						desc = L["Seconds before fading chat panel"],
						disabled = function() return not E.db.KlixUI.chat.chatFade.enable end
					},

					minAlpha = {
						order = 3,
						type = "range",
						min = 0, max = 1, step = 0.01,
						name = L["Min Alpha"],
						disabled = function() return not E.db.KlixUI.chat.chatFade.enable end
					},

					fadeOutTime = {
						order = 4,
						type = "range",
						min = 0.1, max = 2, step = 0.01,
						name = L["Fadeout duration"],
						disabled = function() return not E.db.KlixUI.chat.chatFade.enable end,
					},

				},
			},

                    -- Filter
			filter = {
				order = 20,
				type = "group",
				name = L["Filter"],
				guiInline = true,
				get = function(info) return E.db.KlixUI.chat.filter[ info[#info] ] end,
				set = function(info, value) E.db.KlixUI.chat.filter[ info[#info] ] = value; E:StaticPopup_Show("PRIVATE_RL"); end,
				args = {
					enable = {
						order = 1,
						type = "toggle",
						name = L["Enable"],
					},
					damagemeter = {
						order = 2,
						type = "toggle",
						name = L["Damage Meter Filter"],
						disabled = function() return not E.db.KlixUI.chat.filter.enable end,
					}
				},
			},
			
		-- RightClickMenu	
			rightclickmenu = {
				order = 9,
				type = "group",
				name = L["Right-Click Menu"],
				guiInline = true,
				get = function(info) return E.db.KlixUI.chat.rightclickmenu[ info[#info] ] end,
				set = function(info, value) E.db.KlixUI.chat.rightclickmenu[ info[#info] ] = value; E:StaticPopup_Show("PRIVATE_RL") end,
				args = {
					enable = {
						order = 1,
						type = "toggle",
						name = L["Enable"],
						desc = L["Enhances the chat character right-click menu with new features."],
					},
				},
			},
		},
	}
end

tinsert(KUI.Config, ChatTable)