local KUI, T, E, L, V, P, G = unpack(select(2, ...))
local KS = KUI:GetModule('KuiSkins')

local SupportedProfiles = {
	{'AddOnSkins', 'AddOnSkins'},
	{'BigWigs', 'BigWigs'},
	{'DBM-Core', 'Deadly Boss Mods'},
	{'Details', 'Details'},
	{'ElvUI_SLE', 'Shadow & Light'},
	{"ls_Toasts", "ls_Toasts"},
	{"Masque", "Masque"},
	{"ProjectAzilroka", "ProjectAzilroka"},
	{'XIV_Databar', 'XIV_Databar'},
}

local DecorAddons = {
	{"ActionBarProfiles", L["ActionBarProfiles"], "abp"},
	{"Baggins", L["Baggins"], "ba"},
	{"BigWigs", L["BigWigs"], "bw"},
	{"BugSack", L["BugSack"], "bs"},
	{"ElvUI_SLE", L["Shadow & Light"], "sle"},
	{"ls_Toasts", L["ls_Toasts"], "ls"},
	--{"Hekili", L["Hekili"], "hk"},
	{"Clique", L["Clique"], "cl"},		
	{"EventTracker", L["EventTracker"], "et"},
	{"cargBags_Nivaya", L["cargBags_Nivaya"], "cbn"},
	{"TextureBrowser", L["TextureBrowser"], "tb"},
	{"ProjectAzilroka", L["ProjectAzilroka"], "pa"},
	{"WeakAuras", L["WeakAuras"], "wa"},
	{"XIV_Databar", L["XIV_Databar"], "xiv"},
}

local profileString = T.string_format('|cfffff400%s |r', L['KlixUI successfully created and applied profile(s) for:'])

local function SkinsTable()
	E.Options.args.KlixUI.args.skins = {
		order = 100,
		type = "group",
		name = L["Skins & AddOns"],
		childGroups = 'tab',
		args = {
			name = {
				order = 1,
				type = "header",
				name = KUI:cOption(L["Skins & AddOns"]),
			},
			general = {
				order = 2,
				type = "group",
				name = L["General"],
				args = {
					style = {
						order = 1,
						type = "select",
						name = L["|cfff960d9KlixUI|r Style |cffff8000(Beta)|r"],
						desc = L["Creates decorative squares, a gradient and a shadow overlay on some frames.\n"],
						get = function(info) return E.db.KlixUI.general[ info[#info] ] end,
						set = function(info, value) E.db.KlixUI.general[ info[#info] ] = value; E:StaticPopup_Show("PRIVATE_RL") end,
						values = {
							["ALL"] = L["All"],
							["SQUARES"] = L["Only Squares"],
							["SHADOW"] = L["Only Shadow"],
							["NONE"] = NONE,
						},
					},
					
					iconShadow = {
						order = 2,
						type = "toggle",
						name = L["|cfff960d9KlixUI|r Icon Shadow"],
						desc = L["Creates a shadow overlay around various icons.\n|cffff8000Note: There is still some icons that miss the shadow overlay, i'm working on them!|r"],
						disabled = function() return T.IsAddOnLoaded("Masque") end,
						get = function(info) return E.db.KlixUI.general[ info[#info] ] end,
						set = function(info, value) E.db.KlixUI.general[ info[#info] ] = value; E:StaticPopup_Show("PRIVATE_RL") end,
					},
					
					vehicleButton = {
						order = 3,
						type = "toggle",
						name = L["KlixUI Vehicle"],
						desc = L["Redesign the standard vehicle button with a custom one."],
						get = function(info) return E.private.KlixUI.skins[ info[#info] ] end,
						set = function(info, value) E.private.KlixUI.skins[ info[#info] ] = value; E:StaticPopup_Show("PRIVATE_RL") end,
					},
					
					WAIconCooldown = {
						order = 4,
						type = "toggle",
						name = L["Weakauras Icon Cooldown"],
						desc = L["Show the ElvUI cooldown on the weakauras icons."],
						disabled = function() return not T.IsAddOnLoaded("WeakAuras") end,
						get = function(info) return E.private.KlixUI.skins[ info[#info] ] end,
						set = function(info, value) E.private.KlixUI.skins[ info[#info] ] = value; E:StaticPopup_Show("PRIVATE_RL") end,
					},
					
					shadowOverlay = {
						order = 5,
						type = "group",
						name = L["Shadow Overlay"],
						guiInline = true,
						get = function(info) return E.db.KlixUI.general.shadowOverlay[ info[#info] ] end,
						set = function(info, value) E.db.KlixUI.general.shadowOverlay[ info[#info] ] = value; E:StaticPopup_Show("PRIVATE_RL") end,
						args = {
							enable = {
								order = 1,
								type = "toggle",
								name = L["Enable"],
								desc = L["Creates a shadow overlay around the whole screen for a more darker finish."],
							},
							alpha = {
								order = 2,
								type = "range",
								name = L["Shadow Level"],
								desc = L["Change the dark finish of the shadow overlay."],
								min = 1, max = 100, step = 1,
								disabled = function() return not E.db.KlixUI.general.shadowOverlay.enable end,
								set = function(info, value) E.db.KlixUI.general.shadowOverlay[ info[#info] ] = value; KUI:GetModule("KuiLayout"):SetShadowLevel(value) end,
							},
						},
					},
				},
			},
		},
	}

	E.Options.args.KlixUI.args.skins.args.addonskins = {
		order = 6,
		type = "group",
		name = L["Addon Skins"],
		get = function(info) return E.private.KlixUI.skins.addonSkins[ info[#info] ] end,
		set = function(info, value) E.private.KlixUI.skins.addonSkins[ info[#info] ] = value; E:StaticPopup_Show("PRIVATE_RL") end,
		args = {
			info = {
				order = 1,
				type = "description",
				name = L["KUI_ADDONSKINS_DESC"],
			},
			space1 = {
				order = 2,
				type = "description",
				name = "",
			},
		},
	}

	local addorder = 3
	for i, v in T.ipairs(DecorAddons) do
		local addonName, addonString, addonOption, Notes = T.unpack(v)
		E.Options.args.KlixUI.args.skins.args.addonskins.args[addonOption] = {
			order = addorder + 1,
			type = "toggle",
			name = addonString,
                        desc = format('%s '..addonString..' %s', L["Enable/Disable"], L["decor."]),
			disabled = function() return not T.IsAddOnLoaded(addonName) end,
		}
	end
	
	local blizzOrder = 5
	E.Options.args.KlixUI.args.skins.args.blizzard = {
		order = blizzOrder + 1,
		type = "group",
		name = L["Blizzard Skins"],
		get = function(info) return E.private.KlixUI.skins.blizzard[ info[#info] ] end,
		set = function(info, value) E.private.KlixUI.skins.blizzard[ info[#info] ] = value; E:StaticPopup_Show("PRIVATE_RL") end,
		args = {
			info = {
				order = 1,
				type = "description",
				name = L["KUI_SKINS_DESC"],
			},
			space1 = {
				order = 2,
				type = "description",
				name = "",
			},
			gotoskins = {
				order = 3,
				type = "execute",
				name = L["ElvUI Skins"],
				func = function() LibStub("AceConfigDialog-3.0-ElvUI"):SelectGroup("ElvUI", "skins") end,
			},
			space2 = {
				order = 4,
				type = "description",
				name = "",
			},
			encounterjournal = {
				type = "toggle",
				name = ENCOUNTER_JOURNAL,
				disabled = function () return not E.private.skins.blizzard.enable or not E.private.skins.blizzard.encounterjournal end
			},
			spellbook = {
				type = "toggle",
				name = SPELLBOOK,
				disabled = function() return not E.private.skins.blizzard.enable or not E.private.skins.blizzard.spellbook end,
			},
			character = {
				type = "toggle",
				name = L["Character Frame"],
				disabled = function() return E.Mists or not E.private.skins.blizzard.enable or not E.private.skins.blizzard.character end,
				hidden = function() return E.Mists end,
			},
			gossip = {
				type = "toggle",
				name = L["Gossip Frame"],
				disabled = function() return not E.private.skins.blizzard.enable or not E.private.skins.blizzard.gossip end,
			},
			quest = {
				type = "toggle",
				name = L["Quest Frames"],
				disabled = function() return not E.private.skins.blizzard.enable or not E.private.skins.blizzard.quest end,
			},
			questChoice = {
				type = "toggle",
				name = L["Quest Choice"],
				disabled = function() return not E.private.skins.blizzard.enable or not E.private.skins.blizzard.questChoice end,
			},
			garrison = {
				type = "toggle",
				name = _G.GARRISON_LOCATION_TOOLTIP,
				disabled = function() return E.Mists or not E.private.skins.blizzard.enable or not E.private.skins.blizzard.garrison end,
				hidden = function() return E.Mists end,
			},
			orderhall = {
				type = "toggle",
				name = L["Orderhall"],
				disabled = function() return E.Mists or not E.private.skins.blizzard.enable or not E.private.skins.blizzard.orderhall end,
				hidden = function() return E.Mists end,
			},
			talent = {
				type = "toggle",
				name = _G.TALENTS,
				disabled = function() return E.Mists or not E.private.skins.blizzard.enable or not E.private.skins.blizzard.talent end,
				hidden = function() return E.Mists end,
			},
			auctionhouse = {
				type = "toggle",
				name = _G.AUCTIONS,
				disabled = function() return E.Mists or not E.private.skins.blizzard.enable or not E.private.skins.blizzard.auctionhouse end,
				hidden = function() return E.Mists end,
			},
			friends = {
				type = "toggle",
				name = _G.FRIENDS,
				disabled = function() return not E.private.skins.blizzard.enable or not E.private.skins.blizzard.friends end,
			},
			contribution = {
				type = "toggle",
				name = L["Contribution"],
				disabled = function() return E.Mists or not E.private.skins.blizzard.enable or not E.private.skins.blizzard.contribution end,
				hidden = function() return E.Mists end,
			},
			artifact = {
				type = "toggle",
				name = _G.ITEM_QUALITY6_DESC,
				disabled = function() return E.Mists or not E.private.skins.blizzard.enable or not E.private.skins.blizzard.artifact end,
				hidden = function() return E.Mists end,
			},
			collections = {
				type = "toggle",
				name = _G.COLLECTIONS,
				disabled = function() return not E.private.skins.blizzard.enable or not E.private.skins.blizzard.collections end,
			},
			calendar = {
				type = "toggle",
				name = L["Calendar Frame"],
				disabled = function() return not E.private.skins.blizzard.enable or not E.private.skins.blizzard.calendar end,
			},
			merchant = {
				type = "toggle",
				name = L["Merchant Frame"],
				disabled = function() return not E.private.skins.blizzard.enable or not E.private.skins.blizzard.merchant end,
			},
			worldmap = {
				type = "toggle",
				name = _G.WORLD_MAP,
				disabled = function() return E.Mists or not E.private.skins.blizzard.enable or not E.private.skins.blizzard.worldmap end,
				hidden = function() return E.Mists end,
			},
			pvp = {
				type = "toggle",
				name = L["PvP Frames"],
				disabled = function() return not E.private.skins.blizzard.enable or not E.private.skins.blizzard.pvp end,
			},
			achievement = {
				type = "toggle",
				name = _G.ACHIEVEMENTS,
				disabled = function() return not E.private.skins.blizzard.enable or not E.private.skins.blizzard.achievement end,
			},
			tradeskill = {
				type = "toggle",
				name = _G.TRADESKILLS,
				disabled = function() return not E.private.skins.blizzard.enable or not E.private.skins.blizzard.tradeskill end,
			},
			lfg = {
				type = "toggle",
				name = _G.LFG_TITLE,
				disabled = function() return not E.private.skins.blizzard.enable or not E.private.skins.blizzard.lfg end,
			},
			lfguild = {
				type = "toggle",
				name = L["LF Guild Frame"],
				disabled = function() return not E.private.skins.blizzard.enable or not E.private.skins.blizzard.lfguild end,
			},
			talkinghead = {
				type = "toggle",
				name = L["TalkingHead"],
				disabled = function() return E.Mists or not E.private.skins.blizzard.enable or not E.private.skins.blizzard.talkinghead end,
				hidden = function() return E.Mists end,
			},
			guild = {
				type = "toggle",
				name = _G.GUILD,
				disabled = function() return not E.private.skins.blizzard.enable or not E.private.skins.blizzard.guild end,
			},
			objectiveTracker = {
				type = "toggle",
				name = _G.OBJECTIVES_TRACKER_LABEL,
				disabled = function() return E.Mists or not E.private.skins.blizzard.enable or not E.private.skins.blizzard.objectiveTracker end,
				hidden = function() return E.Mists end,
			},
			addonManager = {
				type = "toggle",
				name = L["AddOn Manager"],
				disabled = function() return not E.private.skins.blizzard.enable or not E.private.skins.blizzard.addonManager end,
			},
			mail = {
				type = "toggle",
				name =  L["Mail Frame"],
				disabled = function() return not E.private.skins.blizzard.enable or not E.private.skins.blizzard.mail end,
			},
			raid = {
				type = "toggle",
				name = L["Raid Frame"],
				disabled = function() return E.Mists or not E.private.skins.blizzard.enable or not E.private.skins.blizzard.raid end,
				hidden = function() return E.Mists end,
			},
			dressingroom = {
				type = "toggle",
				name = _G.DRESSUP_FRAME,
				disabled = function() return not E.private.skins.blizzard.enable or not E.private.skins.blizzard.dressingroom end,
			},
			timemanager = {
				type = "toggle",
				name = _G.TIMEMANAGER_TITLE,
				disabled = function() return not E.private.skins.blizzard.enable or not E.private.skins.blizzard.timemanager end,
			},
			blackmarket = {
				type = "toggle",
				name = _G.BLACK_MARKET_AUCTION_HOUSE,
				disabled = function() return not E.private.skins.blizzard.enable or not E.private.skins.blizzard.bmah end,
			},
			guildcontrol = {
				type = "toggle",
				name = L["Guild Control Frame"],
				disabled = function() return not E.private.skins.blizzard.enable or not E.private.skins.blizzard.guildcontrol end,
			},
			macro = {
				type = "toggle",
				name = _G.MACROS,
				disabled = function() return not E.private.skins.blizzard.enable or not E.private.skins.blizzard.macro end,
			},
			binding = {
				type = "toggle",
				name = _G.KEY_BINDING,
				disabled = function() return not E.private.skins.blizzard.enable or not E.private.skins.blizzard.binding end,
			},
			gbank = {
				type = "toggle",
				name = _G.GUILD_BANK,
				disabled = function() return not E.private.skins.blizzard.enable or not E.private.skins.blizzard.gbank end,
			},
			taxi = {
				type = "toggle",
				name = _G.FLIGHT_MAP,
				disabled = function() return not E.private.skins.blizzard.enable or not E.private.skins.blizzard.taxi end,
			},
			help = {
				type = "toggle",
				name = L["Help Frame"],
				disabled = function() return not E.private.skins.blizzard.enable or not E.private.skins.blizzard.help end,
			},
			loot = {
				type = "toggle",
				name = L["Loot Frames"],
				disabled = function() return not E.private.skins.blizzard.enable or not E.private.skins.blizzard.loot end,
			},
			warboard = {
				type = "toggle",
				name = L["Warboard"],
				disabled = function() return E.Mists or not E.private.skins.blizzard.enable or not E.private.skins.blizzard.warboard end,
				hidden = function() return E.Mists end,
			},
			deathRecap = {
				type = "toggle",
				name = _G.DEATH_RECAP_TITLE,
				disabled = function() return E.Mists or not E.private.skins.blizzard.enable or not E.private.skins.blizzard.deathRecap end,
				hidden = function() return E.Mists end,
			},
			channels = {
				type = "toggle",
				name = _G.CHANNELS,
				disabled = function() return not E.private.skins.blizzard.enable or not E.private.skins.blizzard.channels end,
			},
			communities = {
				type = "toggle",
				name = _G.COMMUNITIES,
				disabled = function() return not E.private.skins.blizzard.enable or not E.private.skins.blizzard.communities end,
			},
			challenges = {
				type = "toggle",
				name = _G.CHALLENGES,
				disabled = function() return E.Mists or not E.private.skins.blizzard.enable end, -- No ElvUI skin yet
				hidden = function() return E.Mists end,
			},
			azerite = {
				type = "toggle",
				name = L["AzeriteUI"],
				disabled = function() return E.Mists or not E.private.skins.blizzard.enable or not E.private.skins.blizzard.azerite end,
				hidden = function() return E.Mists end,
			},
			AzeriteRespec = {
				type = "toggle",
				name = _G.AZERITE_RESPEC_TITLE,
				disabled = function() return E.Mists or not E.private.skins.blizzard.enable or not E.private.skins.blizzard.azeriteRespec end,
				hidden = function() return E.Mists end,
			},
			IslandQueue = {
				type = "toggle",
				name = _G.ISLANDS_HEADER,
				disabled = function() return E.Mists or not E.private.skins.blizzard.enable or not E.private.skins.blizzard.islandQueue end,
				hidden = function() return E.Mists end,
			},
			IslandsPartyPose = {
				type = "toggle",
				name = L["Island Party Pose"],
				disabled = function() return E.Mists or not E.private.skins.blizzard.enable or not E.private.skins.blizzard.islandsPartyPose end,
				hidden = function() return E.Mists end,
			},
			minimap = {
				type = "toggle",
				name = L["Minimap"],
				disabled = function() return E.Mists or not E.private.skins.blizzard.enable end,
				hidden = function() return E.Mists end,
			},
			Scrapping = {
				type = "toggle",
				name = _G.SCRAP_BUTTON,
				disabled = function() return E.Mists or not E.private.skins.blizzard.enable or not E.private.skins.blizzard.scrapping end,
				hidden = function() return E.Mists end,
			},
			trainer = {
				type = "toggle",
				name = L["Trainer Frame"],
				disabled = function() return E.Mists or not E.private.skins.blizzard.enable or not E.private.skins.blizzard.trainer end,
				hidden = function() return E.Mists end,
			},
			debug = {
				type = "toggle",
				name = L["Debug Tools"],
				disabled = function() return not E.private.skins.blizzard.enable or not E.private.skins.blizzard.debug end,
			},
			inspect = {
				type = "toggle",
				name = _G.INSPECT,
				disabled = function() return not E.private.skins.blizzard.enable or not E.private.skins.blizzard.inspect end,
			},
			socket = {
				type = "toggle",
				name = L["Socket Frame"],
				disabled = function() return not E.private.skins.blizzard.enable or not E.private.skins.blizzard.socket end,
			},
			itemUpgrade = {
				type = "toggle",
				name = L["Item Upgrade"],
				disabled = function() return not E.private.skins.blizzard.enable or not E.private.skins.blizzard.itemUpgrade end,
			},
			trade = {
				type = "toggle",
				name = L["Trade"],
				disabled = function() return E.Mists or not E.private.skins.blizzard.enable or not E.private.skins.blizzard.trade end,
				hidden = function() return E.Mists end,
			},
			voidstorage = {
				type = "toggle",
				name = _G.VOID_STORAGE,
				disabled = function() return not E.private.skins.blizzard.enable or not E.private.skins.blizzard.voidstorage end,
			},
			AlliedRaces = {
				type = "toggle",
				name = L["Allied Races"],
				disabled = function() return E.Mists or not E.private.skins.blizzard.enable or not E.private.skins.blizzard.alliedRaces end,
				hidden = function() return E.Mists end,
			},
			GMChat = {
				type = "toggle",
				name = L["GM Chat"],
				disabled = function() return not E.private.skins.blizzard.enable or not E.private.skins.blizzard.gmChat end,
			},
			Archaeology = {
				type = "toggle",
				name = L["Archaeology Frame"],
				disabled = function() return not E.private.skins.blizzard.enable or not E.private.skins.blizzard.archaeology end,
			},
			AzeriteEssence = {
				type = "toggle",
				name = L["Azerite Essence"],
				disabled = function() return E.Mists or not E.private.skins.blizzard.enable or not E.private.skins.blizzard.azeriteEssence end,
				hidden = function() return E.Mists end,
			},
			ItemInteraction = {
				type = "toggle",
				name = L["Item Interaction"],
				disabled = function() return E.Mists or not E.private.skins.blizzard.enable or not E.private.skins.blizzard.itemInteraction end,
				hidden = function() return E.Mists end,
			},
			animaDiversion = {
				type = "toggle",
				name = L["Anima Diversion"],
				disabled = function() return E.Mists or not E.private.skins.blizzard.enable or not E.private.skins.blizzard.animaDiversion end,
				hidden = function() return E.Mists end,
			},
			soulbinds = {
				type = "toggle",
				name = L["Soulbinds"],
				disabled = function() return E.Mists or not E.private.skins.blizzard.enable or not E.private.skins.blizzard.soulbinds end,
				hidden = function() return E.Mists end,
			},
			covenantSanctum = {
				type = "toggle",
				name = L["Covenant Sanctum"],
				disabled = function() return E.Mists or not E.private.skins.blizzard.enable or not E.private.skins.blizzard.covenantSanctum end,
				hidden = function() return E.Mists end,
			},
			covenantPreview = {
				type = "toggle",
				name = L["Covenant Preview"],
				disabled = function() return E.Mists or not E.private.skins.blizzard.enable or not E.private.skins.blizzard.covenantPreview end,
				hidden = function() return E.Mists end,
			},
			playerChoice = {
				type = "toggle",
				name = L["Player Choice"],
				disabled = function() return E.Mists or not E.private.skins.blizzard.enable or not E.private.skins.blizzard.playerChoice end,
				hidden = function() return E.Mists end,
			},
		},
	}

	if E.Mists then
		local retailOnlyOptions = {
			'communities',
			'challenges',
			'azerite',
			'AzeriteRespec',
			'IslandQueue',
			'IslandsPartyPose',
			'Scrapping',
			'AlliedRaces',
			'AzeriteEssence',
			'ItemInteraction',
			'animaDiversion',
			'soulbinds',
			'covenantSanctum',
			'covenantPreview',
			'playerChoice',
		}

		for _, option in T.ipairs(retailOnlyOptions) do
			E.Options.args.KlixUI.args.skins.args.blizzard.args[option] = nil
		end
	end
	
	E.Options.args.KlixUI.args.skins.args.profiles = {
		order = 7,
		type = "group",
		name = L["Addon Profiles"],
		args = {
			info = {
				order = 1,
				type = "description",
				name = L["KUI_PROFILE_DESC"],
			},
		},
	}
	
	local optionOrder = 1
	for i, v in T.ipairs(SupportedProfiles) do
		local addon, addonName = T.unpack(v)
		E.Options.args.KlixUI.args.skins.args.profiles.args[addon] = {
			order = optionOrder + 1,
			type = 'execute',
			name = addonName,
			desc = L['This will create and apply profile for ']..addonName,
			func = function()
				if addon == 'DBM-Core' then
					KUI:LoadDBMProfile()
					E:StaticPopup_Show('PRIVATE_RL')
				elseif addon == 'BigWigs' then
					KUI:LoadBigWigsProfile()
					E:StaticPopup_Show('PRIVATE_RL')
				elseif addon == 'Details' then
					KUI:LoadDetailsProfile()
					E:StaticPopup_Show('PRIVATE_RL')
				elseif addon == 'ElvUI_SLE' then
					KUI:LoadSLEProfile()
					E:StaticPopup_Show('PRIVATE_RL')
				elseif addon == 'XIV_Databar' then
					KUI:LoadXIVProfile()
					E:StaticPopup_Show('PRIVATE_RL')
				elseif addon == 'AddOnSkins' then
					KUI:LoadAddOnSkinsProfile()
					E:StaticPopup_Show('PRIVATE_RL')
				elseif addon == 'ls_Toasts' then
					KUI:LoadLSProfile()
					E:StaticPopup_Show('PRIVATE_RL')
				elseif addon == 'Masque' then
					KUI:LoadMasqueProfile()
					E:StaticPopup_Show('PRIVATE_RL')
				elseif addon == 'ProjectAzilroka' then
					KUI:LoadPAProfile()
					E:StaticPopup_Show('PRIVATE_RL')
				end
				T.print(profileString..addonName)
			end,
			disabled = function() return not T.IsAddOnLoaded(addon) end,
		}
	end
end
T.table_insert(KUI.Config, SkinsTable)
