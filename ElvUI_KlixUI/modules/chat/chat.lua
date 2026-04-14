local KUI, T, E, L, V, P, G = unpack(select(2, ...))
local KC = KUI:NewModule("KuiChat", "AceEvent-3.0", "AceHook-3.0", "AceTimer-3.0")
local KS = KUI:GetModule('KuiSkins')
local CH = E:GetModule('Chat')
local LO = E:GetModule('Layout')

-- Cache global variables
-- Lua functions
local _G = _G
local pairs, unpack = pairs, unpack
local format = format
local time = time
local BetterDate = BetterDate
local gsub = string.gsub
-- WoW API / Variable
local CreateFrame = CreateFrame
local ChatTypeInfo = ChatTypeInfo
local GetItemIcon = GetItemIcon
local GetRealmName = GetRealmName
local GUILD_MOTD = GUILD_MOTD
local hooksecurefunc = hooksecurefunc
local UIParent = UIParent
local IsAddOnLoaded = IsAddOnLoaded

-- GLOBALS: CHAT_FRAMES, ChatTypeInfo, COMMUNITIES_FRAME_DISPLAY_MODES

local r, g, b = unpack(E["media"].rgbvaluecolor)

-- Place the new chat frame
function KC:UpdateEditboxAnchors()
	for _, frameName in pairs(CHAT_FRAMES) do
		local frame = _G[frameName..'EditBox']
		if not frame then break; end
		frame:ClearAllPoints()
		if E.db.datatexts.leftChatPanel and E.db.chat.editBoxPosition == 'BELOW_CHAT' then
			frame:SetAllPoints(LeftChatDataPanel)
		elseif E.db.KlixUI.datatexts.chat.enable and KuiDummyChat and E.db.KlixUI.datatexts.chat.editBoxPosition == 'BELOW_CHAT' then
			frame:SetAllPoints(KuiDummyChat)
		elseif E.ActionBars.Initialized and E.db.actionbar.bar1.backdrop == true and E.db.KlixUI.datatexts.chat.editBoxPosition == 'EAB_1' then
			KUI:GetModule('KuiLayout'):PositionEditBoxHolder(ElvUI_Bar1)
			frame:SetAllPoints(KuiDummyEditBoxHolder)
		elseif E.ActionBars.Initialized and E.db.actionbar.bar2.backdrop == true and E.db.KlixUI.datatexts.chat.editBoxPosition == 'EAB_2' then
			KUI:GetModule('KuiLayout'):PositionEditBoxHolder(ElvUI_Bar2)
			frame:SetAllPoints(KuiDummyEditBoxHolder)
		else
			frame:SetAllPoints(LeftChatTab)
		end
	end
end

local CreatedFrames = 0;

local function Style(self, frame)
	CreatedFrames = frame:GetID()
end


local ChatFrame_SystemEventHandler = ChatFrame_SystemEventHandler
local ChatFrame_AddMessageEventFilter = ChatFrame_AddMessageEventFilter

function KC:RemoveCurrentRealmName(msg, author, ...)
	local realmName = gsub(GetRealmName(), " ", "")

	if msg and msg:find("-" .. realmName) then
		return false, gsub(msg, "%-"..realmName, ""), author, ...
	end
end

--Replacement of chat tab position and size function
local PixelOff = E.PixelMode and 33 or 27

local function PositionChat(self, override)
	if ((InCombatLockdown() and not override and self.initialMove) or (IsMouseButtonDown("LeftButton") and not override)) then return end
	if not RightChatPanel or not LeftChatPanel then return; end
	if E.private.chat.enable ~= true then return end
	if not E.db.KlixUI.datatexts.chat.enable then return end

	local BASE_OFFSET = 60
	if E.PixelMode then
		BASE_OFFSET = BASE_OFFSET - 3
	end
	local chat, id, tab, isDocked
	for i=1, CreatedFrames do
		chat = _G[format("ChatFrame%d", i)]
		id = chat:GetID()
		tab = _G[format("ChatFrame%sTab", i)]
		isDocked = chat.isDocked

		if chat:IsShown() and not (id > NUM_CHAT_WINDOWS) and id == CH.RightChatWindowID then
			chat:ClearAllPoints()
			if E.db.datatexts.rightChatPanel then
				chat:Point("BOTTOMRIGHT", RightChatDataPanel, "TOPRIGHT", 10, 3)
			else
				BASE_OFFSET = BASE_OFFSET - 24
				chat:Point("BOTTOMLEFT", RightChatPanel, "BOTTOMLEFT", 4, 4)
			end
			if id ~= 2 then
				chat:Size((E.db.chat.separateSizes and E.db.chat.panelWidthRight or E.db.chat.panelWidth) - 10, ((E.db.chat.separateSizes and E.db.chat.panelHeightRight or E.db.chat.panelHeight) - PixelOff))
			end
		elseif not isDocked and chat:IsShown() then
			chat:SetAlpha(1)
		else
			if id ~= 2 and not (id > NUM_CHAT_WINDOWS) then
				BASE_OFFSET = BASE_OFFSET - 24
				chat:Point("BOTTOMLEFT", LeftChatPanel, "BOTTOMLEFT", 4, 4)
				chat:Size(E.db.chat.panelWidth - 10, E.db.chat.panelHeight - PixelOff)
			end
		end
	end
end

function KC:AddMessage(msg, infoR, infoG, infoB, infoID, accessID, typeID, isHistory, historyTime)
	local historyTimestamp --we need to extend the arguments on AddMessage so we can properly handle times without overriding
	if isHistory == "ElvUI_ChatHistory" then historyTimestamp = historyTime end

	if (CH.db.timeStampFormat and CH.db.timeStampFormat ~= 'NONE' ) then
		local timeStamp = BetterDate(CH.db.timeStampFormat, historyTimestamp or time());
		timeStamp = gsub(timeStamp, ' $', '') --Remove space at the end of the string
		timeStamp = timeStamp:gsub('AM', ' AM')
		timeStamp = timeStamp:gsub('PM', ' PM')
		if CH.db.useCustomTimeColor then
			local color = CH.db.customTimeColor
			local hexColor = E:RGBToHex(color.r, color.g, color.b)
			msg = format("%s[%s]|r %s", hexColor, timeStamp, msg)
		else
			msg = format("[%s] %s", timeStamp, msg)
		end
	end

	if CH.db.copyChatLines then
		msg = format('|Hcpl:%s|h%s|h %s', self:GetID(), [[|TInterface\AddOns\ElvUI\media\textures\ArrowRight:14|t]], msg)
	end

	if E.db.KlixUI.chat.hidePlayerBrackets then
		msg = gsub(msg, "(|HB?N?player.-|h)%[(.-)%]|h", "%1%2|h")
	end

	self.OldAddMessage(self, msg, infoR, infoG, infoB, infoID, accessID, typeID)
end

function CH:AddMessage(msg, ...)
	return KC.AddMessage(self, msg, ...)
end

function CH:ChatFrame_SystemEventHandler(chat, event, message, ...)
	if event == "GUILD_MOTD" then
		if message and message ~= "" then
			local info = ChatTypeInfo["GUILD"]
			local GUILD_MOTD = "GMOTD"
			chat:AddMessage(format('|cff00c0fa%s|r: %s', GUILD_MOTD, message), info.r, info.g, info.b, info.id)
		end
		return true
	else
		return ChatFrame_SystemEventHandler(chat, event, message, ...)
	end
end

-- Hide communities Chat - thx Nnogga
local commOpen = CreateFrame("Frame", nil, UIParent)
commOpen:RegisterEvent("ADDON_LOADED")
commOpen:RegisterEvent("CHANNEL_UI_UPDATE")
commOpen:SetScript("OnEvent", function(self, event, addonName)
	if event == "ADDON_LOADED" and addonName == "Blizzard_Communities" then
		--create overlay
		local f = CreateFrame("Button", nil, UIParent)
		f:SetFrameStrata("HIGH")

		f.tex = f:CreateTexture(nil, "BACKGROUND")
		f.tex:SetAllPoints()
		f.tex:SetColorTexture(0.1, 0.1, 0.1, 1)

		f.text = f:CreateFontString()
		f.text:FontTemplate(nil, 20, "OUTLINE")
		f.text:SetShadowOffset(-2, 2)
		f.text:SetText(L["Chat Hidden. Click to show"])
		f.text:SetTextColor(r, g, b)
		f.text:SetJustifyH("CENTER")
		f.text:SetJustifyV("MIDDLE")
		f.text:Height(20)
		f.text:Point("CENTER", f, "CENTER", 0, 0)

		f:EnableMouse(true)
		f:RegisterForClicks("AnyUp")
		f:SetScript("OnClick",function(...)
			f:Hide()
		end)

		--toggle
		local function toggleOverlay()
			if _G.CommunitiesFrame:GetDisplayMode() == COMMUNITIES_FRAME_DISPLAY_MODES.CHAT and E.db.KlixUI.chat.hideChat then
				f:SetAllPoints(_G.CommunitiesFrame.Chat.InsetFrame)
				f:Show()
			else
				f:Hide()
			end
		end

		local function hideOverlay()
			f:Hide()
		end
		toggleOverlay() --run once

		--hook
		hooksecurefunc(_G.CommunitiesFrame, "SetDisplayMode", toggleOverlay)
		hooksecurefunc(_G.CommunitiesFrame, "Show", toggleOverlay)
		hooksecurefunc(_G.CommunitiesFrame, "Hide", hideOverlay)
		hooksecurefunc(_G.CommunitiesFrame, "OnClubSelected", toggleOverlay)
	end
end)

local function AddIcon(link)
	local texture = GetItemIcon(link)

	return "\124T"..texture..":12:12:0:0:64:64:5:59:5:59\124t"..link
end

function KC:CreateChatLootIcons(_, message, ...)
	if IsAddOnLoaded("ChatLinkIcons") then return end

	message = message:gsub("(\124c%x+\124Hitem:.-\124h\124r)", AddIcon)

	return false, message, ...
end

function KC:Initialize()
	if E.private.chat.enable ~= true then return; end

	local db = E.db.KlixUI.chat
	KUI:RegisterDB(self, "chat")

	_G["ERR_FRIEND_ONLINE_SS"] = "[%s] "..L["has come |cff298F00online|r."]
	_G["ERR_FRIEND_OFFLINE_S"] = "[%s] "..L["has gone |cffff0000offline|r."]

	_G["BN_INLINE_TOAST_FRIEND_ONLINE"] = "[%s]"..L[" has come |cff298F00online|r."]
	_G["BN_INLINE_TOAST_FRIEND_OFFLINE"] = "[%s]"..L[" has gone |cffff0000offline|r."]
	
	_G["GUILD_MOTD_TEMPLATE"] = L["|cfff960d9GMOTD:|r %s"]

	self.UpdateEditboxAnchors()	
	hooksecurefunc(CH, "PositionChats", PositionChat)
	hooksecurefunc(CH, "UpdateEditboxAnchors", KC.UpdateEditboxAnchors)
	hooksecurefunc(CH, "StyleChat", Style)

	-- Remove the Realm Name from system messages
	ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", KC.RemoveCurrentRealmName)

	-- Chat Icons for loot
	ChatFrame_AddMessageEventFilter("CHAT_MSG_LOOT", KC.CreateChatLootIcons)

	self:EasyChannel()
	self:ChatFilter()
	self:DamageMeterFilter()
	self:LoadChatFade()

	--Custom Emojis
	local t = "|TInterface\\AddOns\\ElvUI_KlixUI\\media\\textures\\chatEmojis\\%s:16:16|t"

	-- Twitch Emojis
	CH:AddSmiley(':monkaomega:', format(t, 'monkaomega'))
	CH:AddSmiley(':salt:', format(t, 'salt'))
end

function KC:Configure_All()
	self:Configure_ChatFade()
end

KUI:RegisterModule(KC:GetName())