local E, _, V, P, G = unpack(ElvUI)
local locale = (E.global.general.locale and E.global.general.locale ~= "auto") and E.global.general.locale or GetLocale()
local L = E.Libs.ACL:GetLocale('ElvUI', locale)
local EP = LibStub("LibElvUIPlugin-1.0")
local addon, Engine = ...

local KUI = E.Libs.AceAddon:NewAddon(addon, "AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0", "AceTimer-3.0")

-- TEST

KUI.IsMoP = true -- oder aus toc/build sauber ableiten
KUI.Features = KUI.Features or {}

KUI.Features.ScrappingMachine = _G.C_ScrappingMachineUI ~= nil
KUI.Features.Garrison = _G.C_Garrison ~= nil or _G.GarrisonMissionFrame ~= nil
KUI.Features.Azerite = _G.C_AzeriteItem ~= nil
KUI.Features.Wardrobe = _G.WardrobeCollectionFrame ~= nil
KUI.Features.Communities = _G.CommunitiesFrame ~= nil

KUI.dummy = function() return end
KUI.Config = {}
KUI.RegisteredModules = {}
KUI.styling = {}
KUI.iconShadow = {}
KUI.softGlow = {}
KUI.MinimapButtonName = "KlixUI"
KUI.Title = string.format('|cfff960d9%s |r', 'KlixUI')
KUI.Version = GetAddOnMetadata('ElvUI_KlixUI', 'Version')
KUI.Logo = [[Interface\AddOns\ElvUI_KlixUI\media\textures\KlixUILogo.tga]]
KUI.MBL = "Interface\\AddOns\\ElvUI_KlixUI\\media\\textures\\KlixMB.blp"
KUI.MBL1 = "Interface\\AddOns\\ElvUI_KlixUI\\media\\textures\\KlixMB1.blp"
KUI.ElvUIV = tonumber(E.version)
KUI.ElvUIX = tonumber(GetAddOnMetadata("ElvUI_KlixUI", "X-ElvVersion"))
BINDING_HEADER_KLIXUI = KUI.Title
BINDING_HEADER_KLIXUI_RAIDFLARE = KUI.Title..' Raid Flare'
BINDING_HEADER_KLIXUI_GAME_MENU = KUI.Title..' '..MAINMENU_BUTTON
BINDING_HEADER_KLIXUI_EMBED = KUI.Title..' Embed'
BINDING_NAME_KLIXUI_GAME_MENU = MAINMENU_BUTTON
BINDING_NAME_KLIXUI_HIDE_EMBED = 'Hide Embed Window'
BINDING_NAME_KLIXUI_SHOW_EMBED = 'Show Embed Window'
KUI.WoWPatch, KUI.WoWBuild, KUI.WoWPatchReleaseDate, KUI.TocVersion = GetBuildInfo()
KUI.WoWBuild = tonumber(KUI.WoWBuild)
KUI.Discord = "https://discord.gg/GbQbDRX"




-- Create toolkit table
local Toolkit = {}

Engine[1] = KUI
Engine[2] = Toolkit
Engine[3] = E
Engine[4] = L
Engine[5] = V
Engine[6] = P
Engine[7] = G
_G[addon] = Engine

function KUI:RegisterModule(name)
	if self.initialized then
		local mod = self:GetModule(name)
		if (mod and mod.Initialize) then
			mod:Initialize()
		end
	else
		self["RegisteredModules"][#self["RegisteredModules"] + 1] = name
	end
end

function KUI:InitializeModules()
	for _, moduleName in Toolkit.pairs(KUI.RegisteredModules) do
		local mod = self:GetModule(moduleName)
		if mod.Initialize then
			mod:Initialize()
		else
			KUI:Print("Module <" .. moduleName .. "> is not loaded.")
		end
	end
end

function KUI:AddOptions()
	for _, func in Toolkit.ipairs(KUI.Config) do
		func()
	end
end

function KUI:DasOptions()
	local ACD = LibStub("AceConfigDialog-3.0-ElvUI", true)
	local status = ACD and ACD.Status and ACD.Status.ElvUI
	if status and status.status and status.status.groups then
		status.status.groups.selected = "KlixUI"
	end

	local toggleOptions = E.ToggleOptions or E.ToggleOptionsUI
	if toggleOptions then
		toggleOptions(E, "KlixUI")
	end

	if ACD then
		ACD:SelectGroup("ElvUI", "KlixUI")
	end
end

-- Copied from ElvUI
function KUI:ErrorOn(msg)
	msg = Toolkit.string_lower(msg)
	if (msg == 'on') then
		Toolkit.DisableAllAddOns()
		Toolkit.EnableAddOn("ElvUI")
		Toolkit.EnableAddOn("ElvUI_Options")
		Toolkit.EnableAddOn("ElvUI_KlixUI")
		Toolkit.SetCVar("scriptErrors", 1)
		Toolkit.ReloadUI()
	elseif (msg == 'off') then
		Toolkit.SetCVar("scriptErrors", 0)
		KUI:Print("Lua errors off.")
	else
		KUI:Print("/kuierror on - /kuierror off")
	end
end

function KUI:LoadCommands()
	self:RegisterChatCommand("kui", "DasOptions")
	self:RegisterChatCommand("klix", "DasOptions")
	self:RegisterChatCommand("klixui", "DasOptions")
	self:RegisterChatCommand("kuierror", "ErrorOn")
	self:RegisterChatCommand("kuidbg", "DebugCommand")
	self:RegisterChatCommand("kuidebug", "DebugCommand")
end



function KUI:Init()
	self.initialized = true
	
	-- ElvUI versions check
	if KUI.ElvUIV < KUI.ElvUIX then
		E:StaticPopup_Show("VERSION_MISMATCH")
		return -- If ElvUI Version is outdated stop right here. So things don't get broken.
	end

	-- Create empty saved vars if they doesn't exist
	if not KUIDataDB then
		KUIDataDB = {}
	end

	if not KUIDataPerCharDB then
		KUIDataPerCharDB = {}
	end
	
	self:InitializeModules()
	self:AddMoverCategories()
	self:SetupProfileCallbacks()
	self:RegisterKuiMedia()
	self:LoadCommands()

	if E.db.KlixUI.general.splashScreen then
		self:SplashScreen()
	end
	if E.db.KlixUI.general.GameMenuButton then
		self:BuildGameMenu()
	end
	
	-- Check version for changelog popup!
	E:Delay(6, function()
		self:CheckVersion()
	end)
	
	local kuiInstallComplete = E.private.KlixUI and E.private.KlixUI.install_complete
	local shouldQueueInstall = E.private.install_complete == E.version and (E.db.KlixUI.installed == nil or kuiInstallComplete ~= KUI.Version)

	-- Initiate installation process if ElvUI install is complete and our plugin install has not yet been run
	if shouldQueueInstall then
		E:GetModule("PluginInstaller"):Queue(KUI.installTable)
	end

	-- run the setup when ElvUI install is finished and again when a profile gets deleted.
	local profileKey = ElvDB.profileKeys[E.myname..' - '..E.myrealm]
	if shouldQueueInstall or (ElvDB.profileKeys and profileKey == nil) then
		E:GetModule("PluginInstaller"):Queue(KUI.installTable)
	end
	
	if E.db.KlixUI.general.loginMessage then
		Toolkit.print(KUI.Title..Toolkit.string_format('v|cfff960d9%s|r', KUI.Version)..L[' is loaded. For any issues or suggestions, please visit ']..KUI:PrintURL('https://discord.gg/GbQbDRX'))
	end
	
	-- Insert our options table when ElvUI config is loaded
	EP:RegisterPlugin(addon, self.AddOptions)
end



E.Libs.EP:HookInitialize(KUI, KUI.Init)
