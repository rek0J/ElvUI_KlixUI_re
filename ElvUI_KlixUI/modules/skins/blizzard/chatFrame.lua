local KUI, T, E, L, V, P, G = unpack(select(2, ...))
local KS = KUI:GetModule('KuiSkins')
local S = E:GetModule('Skins')

local _G = _G
local pairs = pairs
local hooksecurefunc = hooksecurefunc

local function SafeStyle(frame)
	if not frame or (frame.IsForbidden and frame:IsForbidden()) then return end
	if frame.Styling then
		frame:Styling()
	end
end

local function styleChatFrame()
	if E.private.chat.enable ~= true then return; end

	local VoiceChatPromptActivateChannel = _G["VoiceChatPromptActivateChannel"]
	if VoiceChatPromptActivateChannel and not (VoiceChatPromptActivateChannel.IsForbidden and VoiceChatPromptActivateChannel:IsForbidden()) then
		KS:CreateBD(VoiceChatPromptActivateChannel)
		SafeStyle(VoiceChatPromptActivateChannel)
	end

	local VoiceChatChannelActivatedNotification = _G.VoiceChatChannelActivatedNotification
	if VoiceChatChannelActivatedNotification and not (VoiceChatChannelActivatedNotification.IsForbidden and VoiceChatChannelActivatedNotification:IsForbidden()) then
		KS:CreateBD(VoiceChatChannelActivatedNotification)
		SafeStyle(VoiceChatChannelActivatedNotification)
	end

	-- Revert my Styling function on these buttons
	if E.db.chat.pinVoiceButtons and not E.db.chat.hideVoiceButtons then

			if _G.ChatFrameToggleVoiceDeafenButton then
				_G.ChatFrameToggleVoiceDeafenButton:StripTextures()
			end

			if _G.ChatFrameToggleVoiceMuteButton then
				_G.ChatFrameToggleVoiceMuteButton:StripTextures()
			end
		else
		--ElvUI ChatButtonHolder
			if _G.ChatButtonHolder then
				SafeStyle(_G.ChatButtonHolder)
			end
		end

	do
		local ChatMenus = {
			_G.ChatMenu,
			_G.EmoteMenu,
			_G.LanguageMenu,
			_G.VoiceMacroMenu,
		}

		for _, menu in pairs(ChatMenus) do
			if menu then
				SafeStyle(menu)
			end
		end
	end
end

S:AddCallback("KuiChat", styleChatFrame)
