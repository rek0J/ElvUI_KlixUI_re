local KUI, T, E, L, V, P, G = unpack(select(2, ...))
local KS = KUI:GetModule('KuiSkins')
local S = E:GetModule('Skins')
local TT = E:GetModule('Tooltip')
local LSM = E.Libs and E.Libs.LSM

-- Cache global variables
-- Lua functions
local _G = _G
local pairs = pairs
local gsub = string.gsub
-- WoW API
local IsAddOnLoaded = IsAddOnLoaded
-- GLOBALS:

local function StyleTooltipFrame(frame, forceStyle)
	if not frame or (frame.IsForbidden and frame:IsForbidden()) then return end

	if forceStyle and TT and TT.SetStyle then
		TT:SetStyle(frame)
	end

	if not frame.IsSkinned then
		frame:Styling()
		frame.IsSkinned = true
	end
end

local function StyleLibDBIconTooltipText(frame)
	if not frame or frame ~= _G.LibDBIconTooltip or not TT or not TT.db or not LSM then return end

	local name = frame.GetName and frame:GetName()
	if not name then return end

	local textFont = LSM:Fetch('font', TT.db.font)
	local textSize = TT.db.textFontSize
	local textOutline = TT.db.fontOutline
	local headerFont = LSM:Fetch('font', TT.db.headerFont)
	local headerSize = TT.db.headerFontSize
	local headerOutline = TT.db.headerFontOutline
	local hr, hg, hb = HIGHLIGHT_FONT_COLOR:GetRGB()

	local function NormalizeHeaderText(fontString)
		if not fontString or not fontString.GetText or not fontString.SetText then return end

		local text = fontString:GetText()
		if not text or text == '' then return end

		text = gsub(text, '|c%x%x%x%x%x%x%x%x', '')
		text = gsub(text, '|r', '')
		fontString:SetText(text)
	end

	for i = 1, frame:NumLines() do
		local left = _G[name.."TextLeft"..i]
		local right = _G[name.."TextRight"..i]

		if left and left.FontTemplate then
			if i == 1 then
				NormalizeHeaderText(left)
				left:FontTemplate(headerFont, headerSize, headerOutline)
				left:SetTextColor(hr, hg, hb)
			else
				left:FontTemplate(textFont, textSize, textOutline)
			end
		end

		if right and right.FontTemplate then
			if i == 1 then
				NormalizeHeaderText(right)
				right:FontTemplate(headerFont, headerSize, headerOutline)
				right:SetTextColor(hr, hg, hb)
			else
				right:FontTemplate(textFont, textSize, textOutline)
			end
		end
	end
end

local function Skintooltip()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.tooltip ~= true then return end

	-- tooltips
	local tooltips = {
		_G.GameTooltip,
		_G.FriendsTooltip,
		_G.ItemRefTooltip,
		_G.ItemRefShoppingTooltip1,
		_G.ItemRefShoppingTooltip2,
		_G.ItemRefShoppingTooltip3,
		_G.AutoCompleteBox,
		_G.ShoppingTooltip1,
		_G.ShoppingTooltip2,
		_G.ShoppingTooltip3,
		_G.FloatingBattlePetTooltip,
		_G.FloatingPetBattleAbilityTooltip,
		_G.FloatingGarrisonFollowerTooltip,
		_G.FloatingGarrisonFollowerAbilityTooltip,
		_G.PetBattlePrimaryUnitTooltip,
		_G.PetBattlePrimaryAbilityTooltip,
		_G.EventTraceTooltip,
		_G.FrameStackTooltip,
		_G.DatatextTooltip,
		_G.WarCampaignTooltip,
		_G.EmbeddedItemTooltip,
		_G.ReputationParagonTooltip,
		_G.ElvUISpellBookTooltip,
		_G.QuestScrollFrame.StoryTooltip,
		_G.QuestScrollFrame.CampaignTooltip,
		_G.QuestScrollFrame.WarCampaignTooltip,
		_G.DataTextTooltip,
		_G.LibDBIconTooltip,
	}

	for _, frame in pairs(tooltips) do
		if frame then
			StyleTooltipFrame(frame, frame == _G.LibDBIconTooltip)

			if frame == _G.LibDBIconTooltip and not frame.KlixUITooltipHooked then
				frame:HookScript("OnShow", function(self)
					StyleTooltipFrame(self, true)
					StyleLibDBIconTooltipText(self)
					T.C_Timer_After(0, function()
						if self and self.IsShown and self:IsShown() then
							StyleTooltipFrame(self, true)
							StyleLibDBIconTooltipText(self)
						end
					end)
				end)

				frame:HookScript("OnSizeChanged", function(self)
					if not (self and self.IsShown and self:IsShown()) then return end

					T.C_Timer_After(0, function()
						if self and self.IsShown and self:IsShown() then
							StyleTooltipFrame(self, true)
							StyleLibDBIconTooltipText(self)
						end
					end)
				end)

				frame.KlixUITooltipHooked = true
			end
		end
	end
end

S:AddCallback("KUIGameTooltip", Skintooltip)
