local KUI, T, E, L, V, P, G = unpack(select(2, ...))
local KS = KUI:GetModule('KuiSkins')
local S = E:GetModule('Skins')

-- Cache global variables
-- Lua functions
local _G = _G
local unpack = unpack
-- WoW API / Variables
local hooksecurefunc = hooksecurefunc
local C_BattleNet_GetGameAccountInfoByGUID = C_BattleNet.GetGameAccountInfoByGUID
local C_FriendList_IsFriend = C_FriendList.IsFriend
local IsGuildMember = IsGuildMember
local UnitGUID = UnitGUID
-- GLOBALS:

	local function reskinButton(bu)
		bu:SetNormalTexture("")
		bu:SetPushedTexture("")
		bu.icon:SetTexCoord(T.unpack(E.TexCoords))
		bu.IconBorder:SetAlpha(0)
		bu:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
	end

local function styleTradeFrame()
	if E.Mists then return end
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.trade ~= true or E.private.KlixUI.skins.blizzard.trade ~= true then return end

	local TradeFrame = _G.TradeFrame
    if TradeFrame.backdrop then
        TradeFrame.backdrop:Styling()
    end -- MoP Classic: Only style if backdrop exists

	_G.TradePlayerInputMoneyFrameSilver:SetPoint("LEFT", _G.TradePlayerInputMoneyFrameGold, "RIGHT", 1, 0)
	_G.TradePlayerInputMoneyFrameCopper:SetPoint("LEFT", _G.TradePlayerInputMoneyFrameSilver, "RIGHT", 1, 0)

	for i = 1, _G.MAX_TRADE_ITEMS do
		_G["TradePlayerItem"..i.."SlotTexture"]:Hide()
		_G["TradePlayerItem"..i.."NameFrame"]:Hide()
		_G["TradeRecipientItem"..i.."SlotTexture"]:Hide()
		_G["TradeRecipientItem"..i.."NameFrame"]:Hide()

		if _G["TradePlayerItem"..i.."ItemButton"].bg then _G["TradePlayerItem"..i.."ItemButton"].bg:SetTemplate("Transparent") end
		if _G["TradePlayerItem"..i.."ItemButton"].bg then KS:CreateGradient(_G["TradePlayerItem"..i.."ItemButton"].bg) end
		if _G["TradeRecipientItem"..i.."ItemButton"].bg then _G["TradeRecipientItem"..i.."ItemButton"].bg:SetTemplate("Transparent") end
		if _G["TradeRecipientItem"..i.."ItemButton"].bg then KS:CreateGradient(_G["TradeRecipientItem"..i.."ItemButton"].bg) end

		reskinButton(_G["TradePlayerItem"..i.."ItemButton"])
		reskinButton(_G["TradeRecipientItem"..i.."ItemButton"])
	end

	-- Display text on the TradeFrame if unit is a known person
	local infoText = KUI:CreateText(TradeFrame, "OVERLAY", 16, "")
	infoText:ClearAllPoints()
	infoText:SetPoint("TOP", _G["TradeFrameRecipientNameText"], "BOTTOM", 0, -5)

	local function UpdateColor()
		local guid = UnitGUID("NPC")
		if not guid then return end
		local text = "|cffff0000"..L["Stranger"]

		if C_BattleNet_GetGameAccountInfoByGUID(guid) or C_FriendList_IsFriend(guid) then
			text = "|cffffff00".._G.FRIEND
		elseif IsGuildMember(guid) then
			text = "|cff00ff00".._G.GUILD
		end
		infoText:SetText(text)
	end

	hooksecurefunc("TradeFrame_Update", UpdateColor)
end
S:AddCallback("KuiTradeFrame", styleTradeFrame)
