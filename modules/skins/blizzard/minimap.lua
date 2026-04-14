local KUI, T, E, L, V, P, G = unpack(select(2, ...))
local KS = KUI:GetModule('KuiSkins')
local S = E:GetModule('Skins')

local function styleMinimap()
	if E.private.skins.blizzard.enable ~= true or E.private.KlixUI.skins.blizzard.minimap ~= true or E.private.general.minimap.enable ~= true then return end
	if E.Mists then return end
	
	local Minimap = _G.Minimap 
	if not Minimap or (Minimap.IsForbidden and Minimap:IsForbidden()) then return end

	Minimap:Styling(true, true, false, 180, 180, .75)

	if E.db.KlixUI.maps.minimap.styleLFG then
		-- QueueStatus Button
		if _G.QueueStatusMinimapButtonBorder then
			_G.QueueStatusMinimapButtonBorder:Hide()
		end
		if _G.QueueStatusMinimapButtonIconTexture then
			_G.QueueStatusMinimapButtonIconTexture:SetTexture(nil)
		end

		local queueIcon = Minimap:CreateTexture(nil, "ARTWORK")
		queueIcon:Point("CENTER", _G.QueueStatusMinimapButton)
		queueIcon:Size(40, 40)
		queueIcon:SetTexture("Interface\\Minimap\\Dungeon_Icon")

		local anim = queueIcon:CreateAnimationGroup()
		anim:SetLooping("REPEAT")
		anim.rota = anim:CreateAnimation("Rotation")
		anim.rota:SetDuration(2)
		anim.rota:SetDegrees(360)

		hooksecurefunc("QueueStatusFrame_Update", function()
			queueIcon:SetShown(_G.QueueStatusMinimapButton:IsShown())
		end)
		hooksecurefunc("EyeTemplate_StartAnimating", function() anim:Play() end)
		hooksecurefunc("EyeTemplate_StopAnimating", function() anim:Stop() end)
	end

	-- Difficulty Flags
	local flags = {"MiniMapInstanceDifficulty", "GuildInstanceDifficulty", "MiniMapChallengeMode"}
	for _, v in T.pairs(flags) do
		local flag = _G[v]
		if flag and not (flag.IsForbidden and flag:IsForbidden()) then
			flag:SetScale(.75)
		end
	end
end

S:AddCallback("KuiSkinMinimap", styleMinimap)
