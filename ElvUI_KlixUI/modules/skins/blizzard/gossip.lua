local KUI, T, E, L, V, P, G = unpack(select(2, ...))
local KS = KUI:GetModule('KuiSkins')
local S = E:GetModule('Skins')

-- Cache global variables
-- Lua functions
local _G = _G
local select, unpack = select, unpack
local gsub = string.gsub
-- WoW API / Variables
local C_Timer_After = C_Timer.After
local hooksecurefunc = hooksecurefunc
-- GLOBALS:

local r, g, b = T.unpack(E["media"].rgbvaluecolor)

local function styleGossip()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.gossip ~= true or E.private.KlixUI.skins.blizzard.gossip ~= true then return end

	local GossipFrame = _G.GossipFrame
	GossipFrame:Styling()

	if _G.GossipGreetingScrollFrame then
		_G.GossipGreetingScrollFrame:StripTextures()
		if _G.GossipGreetingScrollFrame.backdrop then
			_G.GossipGreetingScrollFrame.backdrop:Hide()
		end
		if not E.private.skins.parchmentRemoverEnable and _G.GossipGreetingScrollFrame.spellTex then
			_G.GossipGreetingScrollFrame.spellTex:SetTexture('') -- Remove Parchement
		end
	end -- MoP Classic: GossipGreetingScrollFrame may not exist, skip if missing

	if GossipFrame.buttons and next(GossipFrame.buttons) then
		for _, button in ipairs(GossipFrame.buttons) do
			local str = button:GetFontString()
			if str then str:SetTextColor(1, 1, 1) end
		end
	end

	if _G.GossipGreetingText then
		_G.GossipGreetingText:SetTextColor(1, 1, 1)
	end -- MoP Classic: GossipGreetingText may not exist, skip if missing

	if GossipFrameUpdate then
		hooksecurefunc("GossipFrameUpdate", function()
			if GossipFrame.buttons and next(GossipFrame.buttons) then
				for _, button in ipairs(GossipFrame.buttons) do
					local str = button:GetFontString()
					if str then
						str:SetTextColor(1, 1, 1)
						local text = str:GetText()
						if text and strfind(text, '|cff000000') then
							str:SetText(gsub(text, '|cff000000', '|cffffe519'))
						end
					end
				end
			end
		end)
	end -- MoP Classic: only hook if function exists

	-- Guard for missing Blizzard global
	if _G.NPCFriendshipStatusBar then
		_G.NPCFriendshipStatusBar:GetRegions():Hide()
		if _G.NPCFriendshipStatusBarNotch1 then
			_G.NPCFriendshipStatusBarNotch1:SetColorTexture(0, 0, 0)
			_G.NPCFriendshipStatusBarNotch1:SetSize(1, 16)
		end
		if _G.NPCFriendshipStatusBarNotch2 then
			_G.NPCFriendshipStatusBarNotch2:SetColorTexture(0, 0, 0)
			_G.NPCFriendshipStatusBarNotch2:SetSize(1, 16)
		end
		if _G.NPCFriendshipStatusBarNotch3 then
			_G.NPCFriendshipStatusBarNotch3:SetColorTexture(0, 0, 0)
			_G.NPCFriendshipStatusBarNotch3:SetSize(1, 16)
		end
		if _G.NPCFriendshipStatusBarNotch4 then
			_G.NPCFriendshipStatusBarNotch4:SetColorTexture(0, 0, 0)
			_G.NPCFriendshipStatusBarNotch4:SetSize(1, 16)
		end
		local region = select(7, _G.NPCFriendshipStatusBar:GetRegions())
		if region then region:Hide() end
		if _G.NPCFriendshipStatusBar.icon then
			_G.NPCFriendshipStatusBar.icon:SetPoint("TOPLEFT", -30, 7)
		end
		if KS and KS.CreateBDFrame then
			KS:CreateBDFrame(_G.NPCFriendshipStatusBar, .25)
		end
	end

	--DUI.NPC:Register(GossipFrame)
	--hooksecurefunc("GossipTitleButton_OnClick", function() KUI.NPC:PlayerTalksFirst() end)
end

S:AddCallback("KuiGossip", styleGossip)