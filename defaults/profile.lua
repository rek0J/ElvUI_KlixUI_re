local KUI, T, E, L, V, P, G = unpack(select(2, ...))

if P["KlixUI"] == nil then P["KlixUI"] = {} end

P['KlixUI'] = {
	-- General
    ['general'] = {
        ["loginMessage"] = true,
		["GameMenuScreen"] = true, -- Enable the Styles GameMenu
		["GameMenuButton"] = true, -- Enable the KlixUI GameMenu Button
		["AFK"] = true,
		["AFKChat"] = true,
		["splashScreen"] = true,
		["Movertransparancy"] = .75,
		["style"] = "ALL", -- Styling function
		["iconShadow"] = true, -- Icon Styling function
		['shadowOverlay'] = { -- Screen overlay
			["enable"] = true,
			["alpha"] = 25,
		},
		['minimap'] = {
			["hide"] = false,
		},
		["teamStats"] = true,
    },
	
	-- ActionBars
	['actionbars'] = {
		['hearthstone'] = {
			["enable"] = true,
			["delete"] = false,
		},
		['SEBar'] = {
			["enable"] = true,
			["borderGlow"] = true,
			["mouseover"] = false,
			["malpha"] = 1,
			["hideInCombat"] = false,
			["hideInOrderHall"] = false,
		},
		['glow'] = {
			["enable"] = true,
			["finishMove"] = true,
			["color"] = {r = 0.95, g = 0.95, b = 0.32, a = 1},
			["number"] = 8,
			["frequency"] = 0.45,
			["length"] = 8,
			["thickness"] = 2,
			["xOffset"] = 0,
			["yOffset"] = 0,
		},
		['autoButtons'] = {
			["enable"] = false,
			bindFont = "Expressway",
			countFont = "Expressway",
			bindFontSize = 18,
			countFontSize = 18,
			slotAutoButtons = {
				enable = true,
				slotBBColorByItem = true,
				slotBBColor = {r = 1, g = 1, b = 1, a = 1},
				slotSpace = 1,
				slotDirection = "RIGHT",
				slotNum = 5,
				slotPerRow = 5,
				slotSize = 35,
			        inheritGlobalFade = false,
			},
			questAutoButtons = {
				enable = true,
				questBBColorByItem = true,
				questBBColor = {r = 1, g = 1, b = 1, a = 1},
				questSpace = 1,
				questDirection = "RIGHT",
				questNum = 5,
				questPerRow = 5,
				questSize = 35,
			        inheritGlobalFade = false,
			},
			whiteList = {
				[90006] = true, -- Wu Kao Smoke Bomb
				[86534] = true,
				[86536] = true,
				[76097] = true, -- Master Healing Potion
				[76098] = true, -- Master Mana Potion
				[5512] = true, -- Healthstone
				[36799] = true, -- Mana Gem
				[81901] = true, -- Brilliant Mana Gem
				[76089] = true, -- Virmen's Bite
				[76090] = true, -- Potion of the Mountains
				[76093] = true, -- Potion of the Jade Serpent
				[76094] = true, -- Alchemist's Rejuvenation
				[76095] = true, -- Potion of Mogu Power
				[86125] = true, -- Kafa Press
				[86569] = true, -- Crystal of Insanity
				[118922] = true, -- Oralius' Whispering Crystal
				[127843] = true,
				[49040] = true, -- Jeeves
				[132514] = true, -- Auto-Hammer

			        -- Professions (Bfa)
			        [164733] = true, -- Synchronous Thread
			        [164978] = true, -- Mallet of Thunderous Skins
							
				--Guild and Honor
			        [63359] = true, -- Banner of Cooperation
			        [64398] = true, -- Standard of Unity
			        [64399] = true, -- Battle Standard of Coordination
			        [18606] = true, -- Alliance Battle Standard
			        [64400] = true, -- Banner of Cooperation
			        [64401] = true, -- Standard of Unity
			        [64402] = true, -- Battle Standard of Coordination
			        [18607] = true, -- Horde Battle Standard
							
				--WOD
				[116266] = true,
				[116276] = true,
				[116268] = true,
				[116271] = true,
				[118711] = true,
				[118704] = true,
				[109217] = true,
				[109218] = true,
				[109219] = true,
				[109220] = true,
				[109221] = true,
				[109222] = true,
				[109223] = true,
				[118269] = true, -- Greenskin Apple
				[122453] = true, -- Commander's Draenic Agility Potion
				[122451] = true,
				[122454] = true,
				[122452] = true,
				[122455] = true,
				[122456] = true,
				[116411] = true, -- Scroll of Protection
							
				--Legion
				[118330] = true, -- Pile of Weapons
				[122100] = true, -- Soul Gem
				[127030] = true, -- Granny"s Flare Grenades
				[127295] = true, -- Blazing Torch
				[128651] = true, -- Critter Hand Cannon
				[128772] = true, -- Branch of the Runewood
				[129161] = true, -- Stormforged Horn
				[129725] = true, -- Smoldering Torch
				[131931] = true, -- Khadgar"s Wand
				[133756] = true, -- Fresh Mound of Flesh
				[133882] = true, -- Trap Rune
				[133897] = true, -- Telemancy Beacon
				[133925] = true, -- Fel Lash
				[133999] = true, -- Inert Crystal
				[136605] = true, -- Solendra"s Compassion
				[137299] = true, -- Nightborne Spellblad
				[138146] = true, -- Rediant Ley Crystal
				[140916] = true, -- Satchel of Locklimb Powder
				[109076] = true, -- Goblin Glider Kit
				[147707] = true, -- Repurposed Fel Focuser
				[142117] = true, -- Potion of Prolonged Power
				[153023] = true, -- Lightforged Augment Rune
							
				--BFA
			    [169451] = true, -- Abyssal Healing Potion
				[152494] = true, -- Coastal Healing Potion
				[152495] = true, -- Coastal Mana Potion
			    [160053] = true, -- Battle-Scarred Augment Rune
				[163224] = true, -- Battle Potion of Strength
				[163223] = true, -- Battle Potion of Agility
				[163222] = true, -- Battle Potion of Intellect
				[163225] = true, -- Battle Potion of Stamina
				[168500] = true, -- Superior Battle Potion of Strength
				[168489] = true, -- Superior Battle Potion of Agility
				[168498] = true, -- Superior Battle Potion of Intellect
				[168499] = true, -- Superior Battle Potion of Stamina
			    [169299] = true, -- Potion of Unbridled Fury
			},
			blackList = {},
			blackitemID = "",
			whiteItemID = "",
		},
	},
	
	-- AddonPanel
	['addonpanel'] = {
		["Enable"] = true,
		["NumAddOns"] = 25,
		['FrameWidth'] = 550,
		['Font'] = "Expressway",
		['FontSize'] = 12,
		['FontFlag'] = "OUTLINE",
		['ButtonHeight'] = 15,
		['ButtonWidth'] = 15,
		['CheckColor'] = {249/255, 96/255, 217/255},
		['ClassColor'] = true,
		['CheckTexture'] = "Klix",
		['FontColor'] = 2,
		['FontCustomColor'] = {r = 1, g = 1, b = 1},
	},
	
	-- Announcement System
	['announcement'] = {
		["enable"] = true,
		['interrupt'] = {
			["enable"] = true,
			["only_instance"] = true,
			["player"] = {
				["enable"] = true,
				["text"] = L["I interrupted %target%\'s %target_spell%!"],
				["channel"] = {
					["solo"] = "SELF",
					["party"] = "PARTY",
					["instance"] = "INSTANCE_CHAT",
					["raid"] = "RAID",
				},
			},
			['others'] = {
				["enable"] = false,
				["text"] = L["%player% interrupted %target%\'s %target_spell%!"],
				["channel"] = {
					["party"] = "EMOTE",
					["instance"] = "NONE",
					["raid"] = "NONE",
				},
			},
		},
		['utility_spells'] = {
			["enable"] = true,
			["channel"] = {
				["solo"] = "SELF",
				["party"] = "PARTY",
				["instance"] = "INSTANCE_CHAT",
				["raid"] = "RAID",
			},
			['spells'] = {
				['ritual_of_summoning'] = {
					["enable"] = true,
					["id"] = 698,
					["player_cast"] = false,
					["use_raid_warning"] = true,
					["text"] = L["%player% is casting %spell%, please assist!"],
				},
				['create_soulwell'] = {
					["enable"] = true,
					["id"] = 29893,
					["player_cast"] = false,
					["use_raid_warning"] = true,
					["text"] = L["%player% is handing out cookies, go and get one!"],
				},
				['moll_e'] = {
					["enable"] = true,
					["id"] = 54710,
					["player_cast"] = false,
					["use_raid_warning"] = true,
					["text"] = L["%player% puts %spell%"],
				},
				['katy_stampwhistle'] = {
					["enable"] = true,
					["id"] = 261602,
					["player_cast"] = false,
					["use_raid_warning"] = true,
					["text"] = L["%player% used %spell%"],
				},
				['conjure_refreshment'] = {
					["enable"] = true,
					["id"] = 190336,
					["player_cast"] = false,
					["use_raid_warning"] = true,
					["text"] = L["%player% casted %spell%, today's special is Anchovy Pie!"],
				},
				['feasts'] = {
					["enable"] = true,
					["player_cast"] = false,
					["use_raid_warning"] = true,
					["text"] = L["OMG, wealthy %player% puts %spell%!"],
				},
				['bots'] = {
					["enable"] = true,
					["player_cast"] = false,
					["use_raid_warning"] = true,
					["text"] = L["%player% puts %spell%"],
				},
				['toys'] = {
					["enable"] = true,
					["player_cast"] = false,
					["use_raid_warning"] = true,
					["text"] = L["%player% puts %spell%"],
				},
				['portals'] = {
					["enable"] = true,
					["player_cast"] = false,
					["use_raid_warning"] = true,
					["text"] = L["%player% opened %spell%!"],
				},
			}
		},
		
		['combat_spells'] = {
			["enable"] = true,
			['combat_resurrection'] = {
				["enable"] = true,
				["player_cast"] = false,
				["use_raid_warning"] = false,
				["text"] = L["%player% casted %spell% -> %target%"],
				['channel'] = {
					["solo"] = "EMOTE",
					["party"] = "PARTY",
					["instance"] = "INSTANCE_CHAT",
					["raid"] = "RAID",
				},
			},
			
			['threat_transfer'] = {
				["enable"] = true,
				["player_cast"] = true,
				["target_is_me"] = true,
				["only_target_is_not_tank"] = true,
				["use_raid_warning"] = false,
				["text"] = L["%player% casted %spell% -> %target%"],
				['channel'] = {
					["solo"] = "EMOTE",
					["party"] = "PARTY",
					["instance"] = "INSTANCE_CHAT",
					["raid"] = "RAID",
				},
			},
		},
		
		['taunt_spells'] = {
			["enable"] = true,
			["player"] = {
				['player'] = {
					["enable"] = false,
					["success_text"] = L["I taunted %target% successfully!"],
					["provoke_all_text"] = L["I taunted all enemies in 10 yards!"],
					["failed_text"] = L["I failed on taunting %target%!"],
					["success_channel"] = {
						["solo"] = "EMOTE",
						["party"] = "PARTY",
						["instance"] = "INSTANCE_CHAT",
						["raid"] = "RAID",
					},
					['failed_channel'] = {
						["solo"] = "EMOTE",
						["party"] = "PARTY",
						["instance"] = "INSTANCE_CHAT",
						["raid"] = "RAID",
					},
				},
				
				['pet'] = {
					["enable"] = false,
					["success_text"] = L["My %pet_role% %pet% taunted %target% successfully!"],
					["failed_text"] = L["My %pet_role% %pet% failed on taunting %target%!"],
					['success_channel'] = {
						["solo"] = "EMOTE",
						["party"] = "PARTY",
						["instance"] = "INSTANCE_CHAT",
						["raid"] = "RAID",
					},
					['failed_channel'] = {
						["solo"] = "EMOTE",
						["party"] = "PARTY",
						["instance"] = "INSTANCE_CHAT",
						["raid"] = "RAID",
					},
				},
			},
			
			['others'] = {
				["player"] = {
					["enable"] = false,
					["success_text"] = L["%player% taunted %target% successfully!"],
					["provoke_all_text"] = L["%player% taunted all enemies in 10 yards!"],
					["failed_text"] = L["%player% failed on taunting %target%!"],
					['success_channel'] = {
						["solo"] = "NONE",
						["party"] = "NONE",
						["instance"] = "NONE",
						["raid"] = "NONE",
					},
					['failed_channel'] = {
						["solo"] = "NONE",
						["party"] = "SELF",
						["instance"] = "SELF",
						["raid"] = "SELF",
					},
				},
				
				['pet'] = {
					["enable"] = false,
					["success_text"] = L["%player%\'s %pet_role% %pet% taunted %target% successfully!"],
					["failed_text"] = L["%player%\'s %pet_role% %pet% failed on taunting %target%!"],
					['success_channel'] = {
						["solo"] = "NONE",
						["party"] = "NONE",
						["instance"] = "NONE",
						["raid"] = "NONE",
					},
					['failed_channel'] = {
						["solo"] = "NONE",
						["party"] = "SELF",
						["instance"] = "SELF",
						["raid"] = "SELF",
					},
				},
			},
		},
		
		['thanks'] = {
			["goodbye"] = {
				["enable"] = true,
				["text"] = L["Thanks all!"],
				['channel'] = {
					["party"] = "PARTY",
					["instance"] = "INSTANCE_CHAT",
					["raid"] = "RAID",
				},
			},
			
			['resurrection'] = {
				["enable"] = true,
				["text"] = L["%target%, thank you for using %spell% to revive me. :)"],
				['channel'] = {
					["solo"] = "WHISPER",
					["party"] = "WHISPER",
					["instance"] = "WHISPER",
					["raid"] = "WHISPER",
				},
			},
		},
	},
	
	-- Armory
	['armory'] = {
		["enable"] = true,
		--["azeritebtn"] = true,
		["naked"] = true,
		["classCrests"] = true,
		['backdrop'] = {
			["selectedBG"] = "NONE",
			["customAddress"] = "",
			["overlay"] = false,
			["alpha"] = .3,
		},
		
		['durability'] = {
			["enable"] = true,
			["onlydamaged"] = true,
			["font"] = "Expressway",
			["textSize"] = 11,
			["fontOutline"] = "OUTLINE",
		},
		
		['ilvl'] = {
			["enable"] = true,
			["font"] = "Expressway",
			["textSize"] = 12,
			["fontOutline"] = "OUTLINE",
			["colorStyle"] = "RARITY",
			["color"] = {r = 1, g = 1, b = 0},
		},
		
		['stats'] = {
			["IlvlFull"] = true,
			["IlvlColor"] = true,
			["AverageColor"] = {r = 0, g = 1, b = .59},
			["OnlyPrimary"] = true,
			["ItemLevel"] = {
				["font"] = "Expressway",
				["size"] = 20,
				["outline"] = "OUTLINE",
			},

			['statFonts'] = {
				["font"] = "Expressway",
				["size"] = 12,
				["outline"] = "OUTLINE",
			},
			
			['catFonts'] = {
				["font"] = "Gotham Narrow",
				["size"] = 12,
				["outline"] = "OUTLINE",
			},
			
			['List'] = {
				["HEALTH"] = false,
				["POWER"] = false,
				["ALTERNATEMANA"] = false,
				["ATTACK_DAMAGE"] = false,
				["ATTACK_AP"] = false,
				["ATTACK_ATTACKSPEED"] = false,
				["SPELLPOWER"] = false,
				["ENERGY_REGEN"] = false,
				["RUNE_REGEN"] = false,
				["FOCUS_REGEN"] = false,
				["MOVESPEED"] = false,
			},
		},
		
		['gradient'] = {
			["enable"] = true,
			["colorStyle"] = "VALUE",
			["color"] = {r = 1, g = 1, b = 0},
			["alpha"] = 0.5,
		},
		
		['indicators'] = {
			["enchant"] = {
				["enable"] = true,
				["glow"] = {
					["enable"] = false,
					["style"] = "AutoCast",
					["color"] = {r = 255/255, g = 0/255, b = 204/255, a = 1},
				},
			},
			
			['socket'] = {
				["enable"] = true,
				['glow'] = {
					["enable"] = false,
					["style"] = "AutoCast",
					["color"] = {r = 255/255, g = 0/255, b = 17/255, a = 1},
				},
			},
			['transmog'] = {
				["enable"] = true,
			},
			['illusion'] = {
				["enable"] = true,
			},
		},
		
		['statsPanel'] = {
			["enable"] = true,
			["height"] = 45,
			["position"] = "TOP",
			["customStats"] = "",
		},
	},
	
	-- Bags
	['bags'] = {
		["itemSelect"] = {
			["enable"] = true,
			["displayProgressFrame"] = true,
			["listHandledItems"] = false,
			["processInterval"] = 0.2,
			["processQuestItems"] = 0,
			["processBoEItems"] = 1,
			["thresholdBoE"] = 0,
			["processMissingMogBoE"] = false,
			["processCraftingReagents"] = true,
		},
	},
	
	-- Better Reputation Colors
	['betterreputationcolors'] = {
		[1] = {r = 0.63, g = 0, b = 0},
		[2] = {r = 0.63, g = 0, b = 0},
		[3] = {r = 0.63, g = 0, b = 0},
		[4] = {r = 0.82, g = 0.67, b = 0},
		[5] = {r = 0.32, g = 0.67, b = 0},
		[6] = {r = 0.32, g = 0.67, b = 0},
		[7] = {r = 0.32, g = 0.67, b = 0},
		[8] = {r = 0, g = 0.75, b = 0.44},
	},
	
	-- Blizzard
	['blizzard'] = {
		["rumouseover"] = false,
		["errorframe"] = {
			["height"] = 60,
			["width"] = 512,
		},
	},
	
	-- Chat
		['chat'] = {
	        ["hideChat"] = false,
			["chatButton"] = true,	
			["hidePlayerBrackets"] = false,	
			["emotes"] = true,
			["chatBar"] = false,
	
		['filter'] = {
			["enable"] = true,
		        ["keywords"] = "",
	          	["blockAddOnAlerts"] = true,
		        ["damagemeter"] = true,
			},

        ['chatFade'] = {
	        ["enable"] = true,
	        	["minAlpha"] = 0.33,
	        	["timeout"] = 20,
		        fadeOutTime = 0.65
	        },

		['rightclickmenu'] = {
			["enable"] = true,
		},
			
		['chatTabSeparator'] = "HIDEBOTH",
	},
	
	-- Combat Text
	['combattext'] = {
        ["enable"] = true,
        ["xOffset"] = 0,
        ["yOffset"] = 0,
        ["xOffsetPersonal"] = 0,
        ["yOffsetPersonal"] = -100,
        ["font"] = "Expressway",
        ["fontFlag"] = "OUTLINE",
        ["fontShadow"] = false,
        ["damageColor"] = true,
        ["defaultColor"] = "ffff00",
        ["truncate"] = true,
        ["truncateLetter"] = true,
        ["commaSeperate"] = true,
        ['sizing'] = {
            ["crits"] = true,
            ["critsScale"] = 1.5,
            ["miss"] = false,
            ["missScale"] = 1.5,
            ["smallHits"] = true,
            ["smallHitsScale"] = 0.66,
			["smallHitsHide"] = false,
            ["autoattackcritsizing"] = true,
        },
		
        ['animations'] = {
            ["ability"] = "fountain",
			["crit"] = "verticalUp",
            ["miss"] = "verticalUp",
            ["autoattack"] = "fountain",
            ["autoattackcrit"] = "verticalUp",
        },
		
        ['animationsPersonal'] = {
            ["normal"] = "rainfall",
            ["crit"] = "verticalUp",
            ["miss"] = "verticalUp",
        },
		
        ['formatting'] = {
            ["size"] = 20,
            ["icon"] = "right",
            ["alpha"] = 1,
        },
		
        ['useOffTarget'] = true,
        ['offTargetFormatting'] = {
            ["size"] = 15,
            ["icon"] = "right",
            ["alpha"] = 0.5,
        },
    },
	
	-- Cooldowns
	['cooldowns'] = {
		["dimishing"] = {
			["enable"] = true,
			["text"] = {
				["enable"] = false,
				["font"] = "Expressway",
				["fontSize"] = 12,
				["fontOutline"] = "OUTLINE",
			},
		},

		['pulse'] = {
			["enable"] = false,
			["fadeInTime"] = 0.3,
			["fadeOutTime"] = 0.6,
			["maxAlpha"] = 0.8,
			["animScale"] = 1.5,
			["iconSize"] = 50,
			["holdTime"] = 0.3,
			["enablePet"] = false,
			["showSpellName"] = false,
			["x"] = UIParent:GetWidth()/2,
			["y"] = UIParent:GetHeight()/2,
		},
		
		['enemy'] = {
			["enable"] = true,
			["size"] = 30,
			["direction"] = "RIGHT",
			["show_always"] = false,
			["show_inpvp"] = false,
			["show_inarena"] = true,
		},

	},
	
	-- DataBars
	['databars'] = {
		["enable"] = true,
		["style"] = true,
		["experienceBar"] = {
			["capped"] = true,
			["progress"] = true,
			["xpColor"] = {r = 0, g = 0.4, b = 1, a = 0.8},
			["restColor"] = {r = 1, g = 0, b = 1, a = 0.2},
		},
		
		['reputationBar'] = {
			["capped"] = true,
			["progress"] = true,
			["color"] = "ascii",
			--["textFormat"] = "Paragon",
			["autotrack"] = true,
		},
		
		['honorBar'] = {
			["progress"] = true,
			["color"] = {r = 240/255, g = 114/255, b = 65/255},
		},
		
		['azeriteBar'] = {
			["progress"] = true,
			["color"] = {r = 0.901, g = 0.8, b = 0.601},
		},
		
		['questXP'] = {
			["enable"] = true,
			["IncludeIncomplete"] = false,
			["CurrentZoneOnly"] = false,
			["Color"] = {r = 217/255, g = 217/255, b = 0},
		},
		
		['paragon'] = {
			["enable"] = true,
			["text"] = "PARAGON",
			["color"] = {r = 0, g = 0.5, b = 0.9},
		},
	},
	
	-- Datatexts
	['datatexts'] = {
		["chat"] = {
			["enable"] = true,
			["transparent"] = true,
			["editBoxPosition"] = "BELOW_CHAT",
			["backdrop"] = true,
			["style"] = true,
			["showChatDt"] = "SHOWBOTH",
		},
	},
	
	-- DataTexts Continue
	['timeDT'] = {
		["size"] = 1.2,
		["date"] = true,
		["invasions"] = true,
		["played"] = true,
	},

	['profDT'] = {
		["prof"] = "prof1",
		["hint"] = true,
	},

	['titlesDT'] = {
		["useName"] = true,
	},
	
	-- Enhanced Friends List
	['efl'] = {
		["enable"] = true,
		["NameFont"] = "Expressway",
		["NameFontSize"] = 11,
		["NameFontFlag"] = "OUTLINE",
		["InfoFont"] = "Expressway",
		["InfoFontSize"] = 10,
		["InfoFontFlag"] = "OUTLINE",
		["GameIconPack"] = "Launcher",
		["StatusIconPack"] = "D3",
	},
	
	-- GameMenu (chat)
	['gamemenu'] = { 
		["color"] = 2,
		["customColor"] = {r = .9, g = .7, b = 0},
	},
	
	-- LocationPanel
	['locPanel'] = {
		["enable"] = false,
		["style"] = true,
		["autowidth"] = false,
		["width"] = 300,
		["height"] = 21,
		["spacing"] = -1,
		["linkcoords"] = true,
		["template"] = "Transparent",
		["blizzText"] = true,
		["font"] = "Expressway",
		["fontSize"] = 11,
		["fontOutline"] = "OUTLINE",
		["throttle"] = 0.2,
		["format"] = "%.0f",
		["zoneText"] = true,
		["colorType"] = "CLASSCOLOUR",
		["colorType_Coords"] = "DEFAULT",
		["customColor"] = {r = 1, g = 1, b = 1 },
		["customColor_Coords"] = {r = 1, g = 1, b = 1 },
		["combathide"] = false,
		["orderhallhide"] = false,
		["hidecoords"] = false,
		["hidecoordsInInstance"] = true,
		["mouseover"] = false,
		["malpha"] = 1,
		["displayOther"] = "RLEVEL",
		["showicon"] = true,
		["showEngineer"] = true,
		["dtshow"] = true,
		['portals'] = {
			["enable"] = true,
			["HSplace"] = true,
			["customWidth"] = false,
			["customWidthValue"] = 200,
			["justify"] = "LEFT",
			["cdFormat"] = "DEFAULT",
			["ignoreMissingInfo"] = false,
			["showHearthstones"] = true,
			["hsPrio"] = "54452,64488,93672,142542,162973,163045,165669,165670,165802,166746,166747,168907,172179,184353",
			["showToys"] = true,
			["showSpells"] = true,
			["showEngineer"] = true,
		},
		['tooltip'] = {
			["tt"] = true,
			["ttcombathide"] = true,
			["tthint"] = true,
			["ttst"] = true,
			["ttlvl"] = true,
			["fish"] = true,
			["petlevel"] = true,
			["ttinst"] = true,
			["ttreczones"] = true,
			["ttrecinst"] = true,
			["ttcoords"] = true,
			["curr"] = true,
			["prof"] = true,
			["profcap"] = false,
			["tthideraid"] = false,
			["tthidepvp"] = false,
		},
	},
	
	-- Loot
	['loot'] = {
		['bonusFilter'] = {
			[14] = {
				["*"] = false,
			},
			[15] = {
				["*"] = false,
			},
			[16] = {
				["*"] = false,
			},
			[17] = {
				["*"] = false,
			},
			[23] = false,
			[8] = false,
			["disableKeystoneLevelToggle"] = false,
			["disableKeystoneLevel"] = 0,
		},
	},
	
	-- Maps
	['maps'] = {
		['minimap'] = {
			["rectangle"] = false,
			["styleButton"] = true,
			["styleLFG"] = false,
			["glow"] = true,
			["glowAlways"] = false,
			["hideincombat"] = false,
			["fadeindelay"] = 5,
			['topbar'] = {
				["locationdigits"] = 1,
				["locationtext"] = "VERSION",
			},
			['blip'] = {
				["enabled"] = false,
			},
			['mail'] = {
				["enhanced"] = true,
				["sound"] = true,
				["hide"] = false,
			},

			['buttons'] = {
				["enable"] = true,
				["barMouseOver"] = false,
				["backdrop"] = true,
				["hideInCombat"] = false,
				["iconSize"] = 26,
				["buttonsPerRow"] = 6,
				["buttonSpacing"] = 2,
				["sortBy"] = "BY_FILTERING",
				["buttonSource"] = "ALL",
				["growthDirection"] = "RIGHT_DOWN",
				["visibility"] = "[petbattle] hide; show",
				["moveTracker"] = true,
				["moveQueue"] = false,
				["moveMail"] = true,
				["hideGarrison"] = false,
				["moveGarrison"] = false,
				["useCustomPosition"] = false,
				["dockToMinimap"] = true,
				["point"] = "TOPRIGHT",
				["relativePoint"] = "BOTTOMRIGHT",
				["xOffset"] = 0,
				["yOffset"] = -2,
				["enableCollapse"] = true,
				["collapsed"] = false,
				["collapsedButtons"] = "KLIXUI",
				["whitelist"] = "",
				["blacklist"] = "MAIL,TRACKING,QUEUE",
				["knownButtons"] = "",
			},

			['ping'] = {
				["enable"] = true,
				["position"] = "TOP",
				["xOffset"] = 0,
				["yOffset"] = -20,
			},

			['coords'] = {
				["enable"] = false,
				["display"] = "SHOW",
				["position"] = "BOTTOM",
				["xOffset"] = 0,
				["yOffset"] = 20,
				["format"] = "%.0f",
				["font"] = "Expressway",
				["fontSize"] = 12,
				["fontOutline"] = "OUTLINE",
				["throttle"] = 0.2,
				["color"] = {r = 1,g = 1,b = 1},
			},

			['cardinalPoints'] = {
				["enable"] = true,
				["north"] = true,
				["east"] = true,
				["south"] = true,
				["west"] = true,
				["Font"] = "Expressway",
				["FontSize"] = 12,
				["FontOutline"] = "OUTLINE",
				["color"] = 2,
				["customColor"] = { r = 255/255, g = 227/255, b = 35/255 },
			},
		},

		['worldmap'] = {
			["scale"] = 1,
			["worldquests"] = true,
			["reveal"] = {
				["enable"] = true,
				["overlay"] = true,
				["overlayColor"] = { r = 249/255, g = 96/255, b = 217/255, a = 1 },
			},
		},
	},
	
	-- Media
	['media'] = {
		['fonts'] = {
			["zone"] = {
				["font"] = "Expressway",
				["size"] = 32,
				["outline"] = "OUTLINE",
				["width"] = 512,
			},
			["subzone"] = {
				["font"] = "Expressway",
				["size"] = 25,
				["outline"] = "OUTLINE",
				["offset"] = 0,
				["width"] = 512,
			},
			["pvp"] = {
				["font"] = "Expressway",
				["size"] = 22,
				["outline"] = "OUTLINE",
				["width"] = 512,
			},
			["mail"] = {
				["font"] = "Expressway",
				["size"] = 12,
				["outline"] = "NONE",
			},
			["editbox"] = {
				["font"] = "Expressway",
				["size"] = 12,
				["outline"] = "NONE",
			},
			["gossip"] = {
				["font"] = "Expressway",
				["size"] = 12,
				["outline"] = "NONE",
			},
			["objective"] = {
				["font"] = "Expressway",
				["size"] = 12,
				["outline"] = "OUTLINE",
			},
			["objectiveHeader"] = {
				["font"] = "Expressway",
				["size"] = 16,
				["outline"] = "OUTLINE",
			},
			["questFontSuperHuge"] = {
				["font"] = "Expressway",
				["size"] = 24,
				["outline"] = "OUTLINE",
			},
		},
	},
	
	-- MicroBar
	['microBar'] = {
		["enable"] = false,
		['scale'] = 1.0,
		["hideInCombat"] = false,
		["hideInOrderHall"] = false,
		['highlight'] = {
			["enable"] = true,
			["buttons"] = false,
		},
		['text'] = {
			["buttons"] = {
				["position"] = "BOTTOM",
			},
			['friends'] = {
				["enable"] = true,
				["textSize"] = 12,
				["xOffset"] = 0,
				["yOffset"] = 5,
			},
			['guild'] = {
				["enable"] = true,
				["textSize"] = 12,
				["xOffset"] = 0,
				["yOffset"] = 5,
			},
			['colors'] = {
				["customColor"] = 1,
				["userColor"] = { r = 1, g = 1, b = 1 },
			},
		},
	},
	
	-- Miscellaneous
	['misc'] = {
		["combatState"] = true,
		["skillGains"] = false,
		["gmotd"] = true,
		["buyall"] = true,
		["talkingHead"] = false,
		["whistleLocation"] = true,
		["whistleSound"] = true,
		["toggleSoundCustom"] = false,
		["whistleSoundCustom"] = "",
		["lootSound"] = true,
		["transmog"] = true,
		["leaderSound"] = true,
		["cursorFlash"] = {
			["enable"] = true,
			["alpha"] = 0.50,
			["color"] = { r = KUI.r, g = KUI.g, b = KUI.b },
			["visibility"] = "ALWAYS",
		},
		['alreadyknown'] = {
			["enable"] = true,
			["color"] = { r = 0, g = 1, b = 0 },
		},
		["AFKPetModel"] = {
			["pet"] = "",
			["animation"] = 0,
			["modelScale"] = 1,
			["facing"] = 15,
		},
		["vehicleSeat"] = {
			["missing"] = true,
		},
		["merchant"] = {
			["style"] = true,
			["subpages"] = 2,
			["itemlevel"] = true,
			["equipslot"] = true,
		},
		["bloodlust"] = {
			["enable"] = true,
			["sound"] = true,
			["text"] = true,
			["faction"] = "HORDE",
			["customSound"] = "",
			["SoundOverride"] = false,
			["UseCustomVolume"] = false,
			["CustomVolume"] = 40,
		},
		["easyCurve"] = {
			["enable"] = true,
			["override"] = false,
			["whispersAchievement"] = false,
			["whispersKeystone"] = false,
		},
		["auto"] = {
			["keystones"] = true,
			["gossip"] = true,
			["auction"] = true,
			["skipAA"] = true,
			["teleportation"] = true,
			["workorder"] = {
				["orderhall"] = false,
				["nomi"] = false,
			},
			["invite"] = {
                ["enable"] = true,
                ["ainvkeyword"] = "321",
                ["inviteRank"] = {},
            },
			["screenshot"] = {
				["enable"] = false,
			},
			["rolecheck"] = {
				["enable"] = true,
				["confirm"] = true,
				["timewalking"] = true,
				["love"] = true,
				["halloween"] = true,
			},
		},
		["panels"] = {
			["top"] = {
				["show"] = false,
				["style"] = true,
				["transparency"] = true,
				["height"] = 12
			},
			["bottom"] = {
				["show"] = false,
				["style"] = true,
				["transparency"] = true,
				["height"] = 12
			},
		},
		["scrapper"] = {
			["enable"] = true,
			["position"] = "BOTTOM",
			["autoOpen"] = true,
			["equipmentsets"] = true,
			["azerite"] = false,
			["boe"] = false,
			["Itemlvl"] = false,
			["Itemprint"] = true,
			["specificilvl"] = false,
			["specificilvlbox"] = "",
			["itemlevel"] = {
				["enable"] = true,
				["fontSize"] = 12,
				["fontOutline"] = "OUTLINE",
			},
		},
		['zoom'] = {
			["increment"] = 5,
			["speed"] = 50,
			["distance"] = 39,
		},

		['autolog'] = {
			["enable"] = false,
			["curLogging"] = false,
			["allraids"] = false,
			["dungeons"] = false,
			["mythicdungeons"] = false,
			["mythiclevel"] = 10,
			["challenge"] = false,
			["chatwarning"] = true,
			["flex"] = nil,
			["raids10"] = nil,
			["raids25"] = nil,
			["raids10h"] = nil,
			["raids25h"] = nil,
			["lfr"] = {["81UDI"] = false, ["82BDZ"] = false, ["83COS"] = false, ["84ETP"] = false, ["85NYA"] = false},
			["normal"] = {["81UDI"] = true, ["82BDZ"] = true, ["83COS"] = true, ["84ETP"] = true, ["85NYA"] = true},
			["heroic"] = {["81UDI"] = true, ["82BDZ"] = true, ["83COS"] = true, ["84ETP"] = true, ["85NYA"] = true},
			["mythic"] = {["81UDI"] = true, ["82BDZ"] = true, ["83COS"] = true, ["84ETP"] = true, ["85NYA"] = true},
		},
		
		['CA'] = {
			["enable"] = true,
			["nextSound"] = 1,
			["soundProbabilityPercent"] = 10,
			["passiveMode"] = true,
			["intervalProbability"] = 900,
		},
		
		["popupsEnable"] = true, -- Needs to be seperate, else the config fuck up!
		['popups'] = {
			["ABANDON_QUEST"] = true,
			["ABANDON_QUEST_WITH_ITEMS"] = true,
			["ACTIVATE_FOLLOWER"] = true,
			["AUTOEQUIP_BIND"] = true,
			["BID_BLACKMARKET"] = false,
			["BUYEMALL_CONFIRM"] = false,
			["CONFIM_BEFORE_USE"] = false,
			["CONFIRM_ACCEPT_SOCKETS"] = true,
			["CONFIRM_BINDER"] = false,
			["CONFIRM_BUY_BANK_SLOT"] = true,
			["CONFIRM_BUY_REAGENTBANK_TAB"] = true,
			["CONFIRM_DELETE_EQUIPMENT_SET"] = true,
			["CONFIRM_DELETE_SELECTED_MACRO"] = true,
			["CONFIRM_DELETE_TRANSMOG_OUTFIT"] = true,
			["CONFIRM_FOLLOWER_TEMPORARY_ABILITY"] = true,
			["CONFIRM_FOLLOWER_UPGRADE"] = true,
			["CONFIRM_HIGH_COST_ITEM"] = false, 
			["CONFIRM_LEARN_SPEC"] = true,
			["CONFIRM_LEAVE_INSTANCE_PARTY"] = true,
			["CONFIRM_MAIL_ITEM_UNREFUNDABLE"] = false,
			["CONFIRM_MERCHANT_TRADE_TIMER_REMOVAL"] = true,
			["CONFIRM_PLAYER_CHOICE"] = true,
			["CONFIRM_PURCHASE_NONREFUNDABLE_ITEM"] = false,
			["CONFIRM_PURCHASE_TOKEN_ITEM"] = true,
			["CONFIRM_RECRUIT_FOLLOWER"] = true,
			["CONFIRM_REFUND_TOKEN_ITEM"] = true,
			["CONFIRM_RELIC_REPLACE"] = false,
			["CONFIRM_REMOVE_FRIEND"] = true,
			["CONFIRM_RESET_INSTANCES"] = true,
			["CONFIRM_RESET_TO_DEFAULT_KEYBINDINGS"] = true,
			["CONFIRM_SAVE_EQUIPMENT_SET"] = true,
			["CONFIRM_SUMMON"] = false,
			["CONFIRM_UPGRADE_ITEM"] = true,
			["DANGEROUS_MISSIONS"] = true,
			["DEACTIVATE_FOLLOWER"] = true,
			["DEATH"] = false,
			["DELETE_GOOD_ITEM"] = false,
			["DELETE_ITEM"] = false,
			["DELETE_QUEST_ITEM"] = false,
			["EQUIP_BIND"] = true,
			["EQUIP_BIND_TRADEABLE"] = false,
			["GOSSIP_CONFIRM"] = true,
			["GROUP_ABANDON_CONFIRMATION"] = true,
			["GROUP_INVITE"] = true,
			["GROUP_INVITE_CONFIRMATION"] = true,
			["LFG_OFFER_CONTINUE"] = true,
			["LOOT_BIND"] = true,
			["LOOT_BIND_CONFIRM"] = true,
			["NOT_ENOUGH_POWER_ARTIFACT_RESPEC"] = true,
			["MOGIT_PREVIEW_CLOSE"] = true,
			["ORDER_HALL_TALENT_RESEARCH"] = false,
			["OUTFITTER_CONFIRM_SET_CURRENT"] = true,
			["PARTY_INVITE"] = false,
			["PETBM_DELETE_TEAM"] = true,
			["PREMADEFILTER_CONFIRM_CLOSE"] = true,
			["RECOVER_CORPSE"] = false,
			["RESURRECT_NO_TIMER"] = false,
			["SEND_MONEY"] = false,
			["TALENTS_INVOLUNTARILY_RESET"] = true,
			["TRADE_POTENTIAL_REMOVE_TRANSMOG"] = true,
			["TRANSMOG_APPLY_WARNING"] = false,
			["VOID_DEPOSIT_CONFIRM"] = false,
			["VOID_STORAGE_DEPOSIT_CONFIRMATION"] = false,
			["LFG_LIST_ENTRY_EXPIRED_TOO_MANY_PLAYERS"] = false,
			["CALENDAR_ERROR"] = false,
			["CONFIRM_REPORT_SPAM_CHAT"] = false,
			["BATTLE_PET_PUT_IN_CAGE"] = false,
			["WORLD_QUEST_ENTERED_PROMT"] = false,
			["EXPERIMENTAL_CVAR_WARNING"] = false,
			["CONFIRM_RELIC_TALENT"] = false,
			["CONFIRM_SUMMON"] = false,
			["BUYOUT_AUCTION"] = false,
			["CONFIRM_PROFESSION"] = true,
			["CLIENT_RESTART_ALERT"] = true,
			["CONFIRM_AZERITE_EMPOWERED_SELECT_POWER"] = true,
			["PETRENAMECONFIRM"] = true,
		},
	},
	
	-- Notification
	['notification'] = {
		["enable"] = true,
		["width"] = 300,
		["height"] = 50,
		["fontSize"] = 9,
		["raid"] = false,
		["noSound"] = false,
		["message"] = false,
		["mail"] = true,
		["vignette"] = true,
		["invites"] = true,
		["guildEvents"] = true,
		["quickJoin"] = true,
	},
	
	-- Professions
	['professions'] = {
		["tabs"] = true
	},
	
	-- PvP
	['pvp'] = {
		["killStreaks"] = true,
		["autorelease"] = true,
		["rebirth"] = true,
		["duels"] = {
			["regular"] = false,
			["pet"] = false,
			["announce"] = false,
		},
	},
	
	-- Quest
	['quest'] = {
		["objectiveProgress"] = true,
		["auto"] = {
			["enable"] = false,
			["diskey"] = 2,
			["accept"] = true,
			["complete"] = true,
			["dailiesonly"] = false,
			["pvp"] = true,
			["escort"] = true,
			["inraid"] = true,
			["greeting"] = true,
			["reward"] = false,
		},
		
		["announce"] = {
			["enable"] = false,
			["noDetail"] = false,
			["instance"] = false,
			["raid"] = false,
			["party"] = false,
			["solo"] = true,
			["ignore_supplies"] = true,
		},
		
		["smart"] = {
			["enable"] = false,
			["RemoveComplete"] = false,
			["AutoRemove"] = true,
			["AutoSort"] = true,
			["ShowDailies"] = false,
		},
		
		["visibility"] = {
			["enable"] = false,
			["bg"] = "COLLAPSED",
			["arena"] = "COLLAPSED",
			["dungeon"] = "FULL",
			["raid"] = "COLLAPSED",
			["scenario"] = "FULL",
			["rested"] = "FULL",
			["garrison"] = "FULL",
			["orderhall"] = "FULL",
			["combat"] = "NONE",
		},
	},
	
	-- Raid Marker Bar
	['raidmarkers'] = {
		["enable"] = true,
		["visibility"] = "INPARTY",
		["customVisibility"] = "[noexists, nogroup] hide; show",
		["backdrop"] = true,
		["buttonSize"] = 20,
		["spacing"] = 2,
		["orientation"] = "HORIZONTAL",
		["modifier"] = "shift-",
		["reverse"] = false,
		["raidicons"] = "Anime",
		["mouseover"] = false,
		["notooltip"] = false,
		["quickmark"] = {
			["enable"] = true,
			["markingButton1"] = 'alt',
			["markingButton2"] = 'LeftButton',
		},
		
		['automark'] = {
			["enable"] = false,
			["tankMark"] = 2,
			["healerMark"] = 5,
		},
	},
	
	-- Reminders
	['reminder'] = {
		["solo"] = {
			["enable"] = true,
			["size"] = 30,
			["strata"] = "LOW",
			["glow"] = true,
		},
		
		['raid'] = {
			["enable"] = false,
			["visibility"] = "INPARTY",
			["class"] = false,
			["alpha"] = 0.3,
			["size"] = 26,
			["backdrop"] = true,
			["glow"] = true,
			["customVisibility"] = "[noexists, nogroup] hide; show",
		},
	},
	
	-- Talents 
	['talents'] = {
		["enable"] = true,
		["borderGlow"] = true,
		["DefaultToTalentsTab"] = true,
		["AutoHidePvPTalents"] = false,
	},
	
	-- Toasts
	["toasts"] = {
		["enable"] = true,
		["growth_direction"] = "DOWN",
		["max_active_toasts"] = 6,
		["sfx_enabled"] = true,
		["fadeout_delay"] = 2.8,
		["hold_on_mouseover"] = true,
		["scale"] = 1.1,
		["colored_names_enabled"] = true,
		["achievement_enabled"] = true,
		["achievement_icon_source"] = "ACHIEVEMENT",
		["use_mop_fallback_icons"] = true,
		["archaeology_enabled"] = true,
		["garrison_6_0_enabled"] = false,
		["garrison_7_0_enabled"] = true,
		["garrison_8_0_enabled"] = true,
		["instance_enabled"] = true,
		["loot_special_enabled"] = true,
		["loot_common_enabled"] = true,
		["loot_common_quality_threshold"] = 1,
		["loot_currency_enabled"] = true,
		--["loot_gold_enabled"] = true,
		--["loot_gold_threshold"] = 1,
		["recipe_enabled"] = true,
		["world_enabled"] = true,
		["transmog_enabled"] = true,
		["dnd"] = {
			["achievement"] = false,
			["archaeology"] = false,
			["garrison_6_0"] = false,
			["garrison_7_0"] = true,
			["garrison_8_0"] = true,
			["instance"] = false,
			["loot_special"] = false,
			["loot_common"] = false,
			["loot_currency"] = false,
			--["loot_gold"] = false,
			["recipe"] = false,
			["world"] = false,
			["transmog"] = false,
		},
	},
	
	-- ToolTip
	['tooltip'] = {
		["tooltip"] = true,
	        ["tooltipIcon"] = true,
	        ["factionIcon"] = true,
	        ["petIcon"] = true,
		["titleColor"] = true,
		["memberInfo"] = true,
		["achievement"] = true,
		["keystone"] = true,
		['azerite'] = {
			["enable"] = true,
			["RemoveBlizzard"] = true,
			["OnlySpec"] = false,
			["Compact"] = false,
		},
		
		['corruption'] = {
			["enable"] = true,
			["append"] = true,
			["english"] = false,
		},
		
		['progressInfo'] = {
			["enable"] = true,
			["display"] = "SHIFT",
			["NameStyle"] = "SHORT",
			["DifStyle"] = "SHORT",
			["raids"] = {
				["uldir"] = false,
				["dazaralor"] = false,
				["crucible"] = false,
				["eternalpalace"] = false,
				["nyalotha"] = true,
			},
		},
	},
	
	-- NameHover
	['nameHover'] = {
		["enable"] = true,
		["guild"] = false,
		["guildRank"] = false,
		["race"] = false,
		["realm"] = true,
		["realmAlways"] = false,
		["titles"] = true,
		["font"] = "Expressway",
		["fontSize"] = 7,
		["fontOutline"] = "OUTLINE",
	},
	
	-- UnitFrames
	['unitframes'] = {
		["style"] = false,
		["powerBar"] = true,
		["healerMana"] = false,
		["AuraIconSpacing"] = {
			["spacing"] = 1,
			["units"] = {
				["player"] = true,
				["target"] = true,
				["targettarget"] = true,
				["targettargettarget"] = true,
				["focus"] = true,
				["focustarget"] = true,
				["pet"] = true,
				["pettarget"] = true,
				["arena"] = true,
				["boss"] = true,
				["party"] = true,
				["raid"] = true,
				["raid40"] = true,
				["raidpet"] = true,
				["tank"] = true,
				["assist"] = true,
			},
		},
		['textures'] = {
			['health'] = E.db.unitframe.statusbar,
			['ignoreTransparency'] = false,
			['power'] = E.db.unitframe.statusbar,
			['castbar'] = E.db.unitframe.statusbar,
		},
		['castbar'] = {
			['text'] = {
				['ShowInfoText'] = true,
				['castText'] = true,
				['forceTargetText'] = false,
				['player'] = {
					['yOffset'] = 0,
					['textColor'] = {r = 1, g = 1, b = 1, a = 1},
				},
				['target'] = {
					['yOffset'] = 0,
					['textColor'] = {r = 1, g = 1, b = 1, a = 1},
				},
			},
		},
		
		['eliteicon'] = {
			["enable"] = true,
			["size"] = 22,
			["point"] = "CENTER",
			["relativePoint"] = "TOPRIGHT",
			["xOffset"] = -1,
			["yOffset"] = 0,
			["strata"] = '3-MEDIUM',
			["level"] = 12,
		},
		
		['attackicon'] = {
			["enable"] = true,
			["size"] = 22,
			["point"] = "CENTER",
			["relativePoint"] = "TOPLEFT",
			["xOffset"] = 1,
			["yOffset"] = 0,
			["strata"] = '3-MEDIUM',
			["level"] = 12,
		},
		
		['icons'] = {
			["role"] = "SupervillainUI",
			["rdy"] = "BenikUI",
			["klixri"] = true,
		},
	},
}

-- Datatexts
P.datatexts.panels.KuiLeftChatDTPanel = {
	[1] = 'Spec Switch (KUI)',
	[2] = 'Item Level (KUI)',
	[3] = 'Durability',
}

P.datatexts.panels.KuiRightChatDTPanel = {
	[1] = 'System',
	[2] = 'Bags',
	[3] = 'Gold',
}
