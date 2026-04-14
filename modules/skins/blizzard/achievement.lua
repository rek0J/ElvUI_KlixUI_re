local KUI, T, E, L, V, P, G = unpack(select(2, ...))
local KS = KUI:GetModule('KuiSkins')
local S = E:GetModule('Skins')

local r, g, b = T.unpack(E["media"].rgbvaluecolor)

local function styleAchievement()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.achievement ~= true or E.private.KlixUI.skins.blizzard.achievement ~= true then return end

	if _G.AchievementFrame.backdrop then
		_G.AchievementFrame.backdrop:Styling()
	end

	-- Hide the ElvUI default backdrop
	if _G.AchievementFrameCategoriesContainer.backdrop then
		_G.AchievementFrameCategoriesContainer.backdrop:Hide()
	end

	for i = 1, 7 do
		local bu = _G["AchievementFrameAchievementsContainerButton"..i]
		-- Hide ElvUI's backdrop
		if bu and bu.backdrop then
			KS:CreateGradient(bu.backdrop)
		end
	end

	hooksecurefunc("AchievementButton_DisplayAchievement", function(button, category, achievement)
		local _, _, _, completed = T.GetAchievementInfo(category, achievement)
		if completed then
			if button.accountWide and button.label then
				button.label:SetTextColor(0, .6, 1)
			elseif button.label then
				button.label:SetTextColor(.9, .9, .9)
			end
		else
			if button.accountWide and button.label then
				button.label:SetTextColor(0, .3, .5)
			elseif button.label then
				button.label:SetTextColor(.65, .65, .65)
			end
		end
	end)

	hooksecurefunc("AchievementObjectives_DisplayCriteria", function(objectivesFrame, id)
		for i = 1, T.GetAchievementNumCriteria(id) do
			local name = _G["AchievementFrameCriteria"..i.."Name"]
			if name and T.select(2, name:GetTextColor()) == 0 then
				name:SetTextColor(1, 1, 1)
			end

			local bu = _G["AchievementFrameMeta"..i]
			if bu and bu.label and T.select(2, bu.label:GetTextColor()) == 0 then
				bu.label:SetTextColor(1, 1, 1)
			end
		end
	end)

	hooksecurefunc("AchievementFrameSummary_UpdateAchievements", function()
		for i = 1, _G.ACHIEVEMENTUI_MAX_SUMMARY_ACHIEVEMENTS do
			local bu = _G["AchievementFrameSummaryAchievement"..i]
			if bu and not bu.reskinned then
				-- Hide ElvUI's backdrop
				if bu.backdrop then
					KS:CreateGradient(bu.backdrop)
				end
				bu.reskinned = true
			end
		end
	end)

	for i = 1, 12 do
		local label = _G["AchievementFrameSummaryCategoriesCategory"..i.."Label"]
		if label then
			label:SetTextColor(1, 1, 1)
		end
	end

	if _G.AchievementFrameSummaryCategoriesStatusBarTitle then
		_G.AchievementFrameSummaryCategoriesStatusBarTitle:SetTextColor(1, 1, 1)
	end

	if _G.AchievementFrame.searchBox and _G.AchievementFrameAchievementsContainer then
		_G.AchievementFrame.searchBox:ClearAllPoints()
		_G.AchievementFrame.searchBox:SetPoint("BOTTOMRIGHT", _G.AchievementFrameAchievementsContainer, "TOPRIGHT", -2, -2)
		_G.AchievementFrame.searchBox:SetSize(100, 20)
	end
end

S:AddCallbackForAddon("Blizzard_AchievementUI", "KuiAchievement", styleAchievement)
