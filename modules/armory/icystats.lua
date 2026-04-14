local KUI, T, E, L, V, P, G = unpack(select(2, ...))
local KA = KUI:GetModule('KuiArmory')
local S = E:GetModule('Skins')
local LSM = E.LSM or E.Libs.LSM
local C_SpecializationInfo = _G.C_SpecializationInfo
local GetSpecialization = T.GetSpecialization or (C_SpecializationInfo and C_SpecializationInfo.GetSpecialization)
local GetSpecializationInfo = T.GetSpecializationInfo or (C_SpecializationInfo and C_SpecializationInfo.GetSpecializationInfo)
local gsub = string.gsub

-- Stats updated on Ice-Veins.com as of 14th of January 2020.
local StatTable = {
	["DEATHKNIGHT-250"] = L["Ilvl > Versatility > Haste > Critical Strike > Mastery"], -- Blood
	["DEATHKNIGHT-251"] = L["Strength > Critical Strike > Mastery > Versatility > Haste"], -- Frost
	["DEATHKNIGHT-252"] = L["Strength > Haste > Critical Strike = Versatility > Mastery"], -- Unholy

	["DRUID-102"] = L["Single: Haste = Critical Strike > Versatility > Mastery > Intellect \n Multi: Haste > Mastery > Critical Strike > Versatility > Intellect"], -- Balanced
	["DRUID-103"] = L["Critical Strike > Mastery > Versatility > Haste > Agility"], -- Feral
	["DRUID-104"] = L["Survival: Armor = Agility = Stam > Versatility > Mastery > Haste > Critical Strike \n Damage: Agility > Versatility >= Haste >= Critical Strike > Mastery"], -- Bear
	["DRUID-105"] = L["Raid: Intellect > Mastery = Haste = Critical Strike = Versatility \n Dungeon: Mastery = Haste > Versatility > Critical Strike > Intellect"], -- Heal

	["HUNTER-253"] = L["Solo: Agility > Critical Strike > Haste > Versatility > Mastery \n Multi: Agility > Critical Strike > Haste > Versatility > Mastery"], -- Beastmaster
	["HUNTER-254"] = L["Solo: Agility > Versatility > Mastery> Critical Strike > Haste \n Multi: Agility > Mastery > Versatility > Critical Strike > Haste"], -- Marksman
	["HUNTER-255"] = L["Solo: Agility > Haste > Critical Strike / Versatility > Mastery \n Multi: Agility > Haste > Critical Strike / Versatility > Mastery"], -- Survival

	["MAGE-62"] = L["Critical Strike > Haste > Mastery > Versatility > Intellect"], -- Arcan
	["MAGE-63"] = L["Single: Haste > Versatility > Mastery > Critical Strike > Intellect \n Multi: Mastery > Haste > Versatility > Critical Strike > Intellect "], -- Fire
	["MAGE-64"] = L["Critical Strike 33% > Haste > Versatility > Mastery > Intellect > Critical Strike 33+ \n No Ice Lance: Mastery > Critical Strike 33% > Versatility > Haste > Intellect > Critical Strike 33+"], -- Frost

	["MONK-268"] = L["Agility > Mastery > Critical Strike = Versatility = Haste"], -- Brewmaster
	["MONK-269"] = L["Weapon Damage > Agility > Versatility > Mastery > Critical Strike > Haste"], -- Windwalker
	["MONK-270"] = L["Raid: Critical Strike > Mastery = Versatility > Intellect > Haste \n Myth+: Intellect > Critical Strike = Mastery = Versatility >= Haste"], -- Mistweaver

	["PALADIN-65"] = L["Standard: Critical Strike > Haste > Versatility > Mastery > Intellect \n Awakening: Haste > Critical Strike > Versatility > Mastery > Intellect \n Glimmer of Light: Haste > Mastery > Critical Strike > Versatility > Intellect"], -- Holy
	["PALADIN-66"] = L["Strength > Haste > Mastery > Versatility > Critical Strike"], -- Protection
	["PALADIN-70"] = L["Standard: Haste = Critical Strike = Versatility = Mastery > Strength"], -- Retribution

	["PRIEST-256"] = L["Intellect > Haste > Critical Strike > Versatility > Mastery"], -- Diszi
	["PRIEST-257"] = L["Raid: Mastery = Critical Strike > Versatility > Intellect > Haste \n Dungeon: Critical Strike > Haste > Versatility > Intellect > Mastery"], -- Holy
	["PRIEST-258"] = L["Haste = Critical Strike > Mastery = Versatility > Intellect"], -- Shadow

	["ROGUE-259"] = L["Raid: Haste > Critical Strike > Mastery > Versatility > Agility \n Myth+: Critical Strike up to 35%-40% > Mastery > Versatility > Agility > Haste"], -- Assassination
	["ROGUE-260"] = L["Agility > Critical Strike = Versatility > Haste > Mastery"], -- Outlaw
	["ROGUE-261"] = L["Single: Agility > Critical Strike > Versatility > Mastery > Haste \n Multi: Agility > Mastery > Critical Strike > Versatility > Haste"], -- Subtlety

	["SHAMAN-262"] = L["Intellect > Versatility > Critical Strike > Haste > Mastery"], -- Elemental
	["SHAMAN-263"] = L["Standard: Haste > Critical Strike = Versatility > Mastery > Agility \n Primal: Mastery > Haste > Critical Strike = Versatility > Agility"], -- Enhancement
	["SHAMAN-264"] = L["(Healing) > Intellect > Critical Strike > Versatility > Haste = Mastery \n Damage Dealing: Intellect > Versatility = Haste > Critical Strike > Mastery"], -- Restoration

	["WARLOCK-265"] = L["Haste = Mastery > Critical Strike > Versatility > Intellect"], --  Affli
	["WARLOCK-266"] = L["Standard: Haste > Mastery > Critical Strike > Versatility > Intellect \n Explosive Potential: Critical Strike > Versatility > Mastery > Haste > Intellect"], -- Demo
	["WARLOCK-267"] = L["Mastery > Haste > Critical Strike = Versatility > Intellect"], -- Destro

	["WARRIOR-71"] = L["Haste > Critical Strike > Mastery > Versatility > Strength"], -- Arms
	["WARRIOR-72"] = L["Critical Strike > Mastery > Haste > Versatility > Strength"], -- Furor
	["WARRIOR-73"] = L["Haste> Versatility > Mastery > Critical Strike > Strength > Armor \n Myth+: Haste> Critical Strike > Versatility > Mastery > Strength > Armor"], -- Protection

	["DEMONHUNTER-577"] = L["Versatility > Critical Strike = Haste > Agility > Mastery"], -- Havoc
	["DEMONHUNTER-581"] = L["Agility > Haste = Versatility > Mastery > Critical Strike"], -- Vengeance
}

function KA:CreateIcyStatFrame()
    local paperDoll = _G["PaperDollFrame"]
    if paperDoll and paperDoll:IsVisible() then
        if not IcyVeinStatFrame then
            local IcyVeinStatFrame = T.CreateFrame("Frame", "IcyVeinStatFrame", E.UIParent)
            IcyVeinStatFrame:CreateBackdrop("Transparent")
            IcyVeinStatFrame:SetFrameStrata("TOOLTIP")
            IcyVeinStatFrame:SetWidth(paperDoll:GetWidth()) 
			IcyVeinStatFrame:Styling()
			
    	    IcyVeinStatFrame.Text = IcyVeinStatFrame:CreateFontString(nil, "OVERLAY")
			IcyVeinStatFrame.Text:FontTemplate(LSM:Fetch('font', E.db.KlixUI.armory.stats.statFonts.font), E.db.KlixUI.armory.stats.statFonts.size, E.db.KlixUI.armory.stats.statFonts.outline)
			IcyVeinStatFrame.Text:SetTextColor(KUI.r, KUI.g, KUI.b)
			IcyVeinStatFrame.Text:ClearAllPoints()
			IcyVeinStatFrame.Text:SetAllPoints(IcyVeinStatFrame)
			IcyVeinStatFrame.Text:SetJustifyH("CENTER")
			IcyVeinStatFrame.Text:SetJustifyV("MIDDLE")

			local Close = T.CreateFrame("Button", "ISCloseButton", IcyVeinStatFrame)
			Close:SetPoint("TOPRIGHT", 0, 0)
			Close:SetSize(16 + ((E.PixelMode and 4) or 8), 16 + ((E.PixelMode and 4) or 8))
			S:HandleCloseButton(Close)
			Close:SetScript('OnClick', function(self) IcyVeinStatFrame:Hide(); KUI:Print(L["If you want to retoggle the stats panel, please do a reload or relog."]) end)
        end
        return true
    end
    return false
end

local function GetCurrentSpecID()
	if GetSpecialization and GetSpecializationInfo then
		local specIndex = GetSpecialization()
		if specIndex then
			local specID = GetSpecializationInfo(specIndex)
			if specID then
				return specID
			end
		end
	end

	return E.myspecID
end

function KA:UpdateIcyStatFrame()
    if KA:CreateIcyStatFrame() then
        local _, className = T.UnitClass("player")
        local sId = GetCurrentSpecID()
        local s = sId and StatTable[className .. "-" .. sId]
        if E.db.KlixUI.armory.statsPanel.customStats ~= "" then
			IcyVeinStatFrame.Text:SetText(E.db.KlixUI.armory.statsPanel.customStats)
		elseif s then
            s = gsub(s, "Strength", "Strength")
            s = gsub(s, "Agility", "Agility")
            s = gsub(s, "Intelligence", "Intellect")
            s = gsub(s, "Stamina", "Stamina")
            IcyVeinStatFrame.Text:SetText(s) 
        else
            IcyVeinStatFrame.Text:SetText("")
        end               
    end
end

function KA:UpdatePanel()
	if not KA:CreateIcyStatFrame() or not IcyVeinStatFrame then return end
	KA:UpdateIcyStatFrame(E.db.KlixUI.armory.statsPanel.customStats)
	IcyVeinStatFrame:SetHeight(E.db.KlixUI.armory.statsPanel.height)
	
	if E.db.KlixUI.armory.statsPanel.position == "TOP" then
		IcyVeinStatFrame:ClearAllPoints()
		IcyVeinStatFrame:SetPoint("BOTTOMRIGHT", _G["PaperDollFrame"], "TOPRIGHT", 0, 1)
        IcyVeinStatFrame:SetParent(_G["PaperDollFrame"])
        IcyVeinStatFrame:Show()
	else
		IcyVeinStatFrame:ClearAllPoints()
		IcyVeinStatFrame:SetPoint("TOPRIGHT", _G["PaperDollFrame"], "BOTTOMRIGHT", 0, -1)
		IcyVeinStatFrame:SetParent(_G["PaperDollFrame"])
        IcyVeinStatFrame:Show()
	end
end

function KA:SPELLS_CHANGED()
	KA:UpdateIcyStatFrame(E.db.KlixUI.armory.statsPanel.customStats)
end
