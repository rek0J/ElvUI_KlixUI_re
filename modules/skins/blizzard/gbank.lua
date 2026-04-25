local KUI, T, E, L, V, P, G = unpack(select(2, ...))
local KS = KUI:GetModule('KuiSkins')
local S = E:GetModule('Skins')

local _G = _G

local function GetNumericGlobal(name, fallback)
	local value = _G[name]
	return type(value) == "number" and value or fallback
end

local function CountGuildBankColumns()
	local columns = 0

	for i = 1, 12 do
		if _G["GuildBankColumn"..i] then
			columns = i
		end
	end

	return columns > 0 and columns or GetNumericGlobal("NUM_GUILDBANK_COLUMNS", 7)
end

local function CountGuildBankColumnSlots()
	local slots = 0

	for j = 1, 20 do
		if _G["GuildBankColumn1Button"..j] then
			slots = j
		end
	end

	return slots > 0 and slots or GetNumericGlobal("NUM_SLOTS_PER_GUILDBANK_GROUP", 14)
end

local function styleGBank()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.gbank ~= true or E.private.KlixUI.skins.blizzard.gbank ~= true then return end

	if _G.GuildBankFrame then
		_G.GuildBankFrame:Styling()
	end
	if _G.GuildBankPopupFrame then
		_G.GuildBankPopupFrame:Styling()
	end

	for i = 1, 4 do
		local tab = _G["GuildBankFrameTab"..i]
		if tab then
			if i ~= 1 then
				local previousTab = _G["GuildBankFrameTab"..i-1]
				if previousTab then
					tab:SetPoint("LEFT", previousTab, "RIGHT", -15, 0)
				end
			end
		end
	end

	for i = 1, GetNumericGlobal("MAX_GUILDBANK_TABS", 8) do
		local button = _G["GuildBankTab"..i.."Button"]
		if button then
			local a1, p, a2, x, y = button:GetPoint()
			if a1 then
				button:SetPoint(a1, p, a2, (x or 0) + E.mult, y or 0)
			end
		end
	end

	if _G.GuildBankFrame and _G.GuildBankFrame.inset then
		_G.GuildBankFrame.inset:Hide()
	end

	for i = 1, CountGuildBankColumns() do
		for j = 1, CountGuildBankColumnSlots() do
			local button = _G["GuildBankColumn"..i.."Button"..j]
			if button then
				if button.CreateBackdrop then
					button:CreateBackdrop("Transparent")
				end
				if KS and KS.CreateGradient then
					KS:CreateGradient(button)
				end
			end
		end
	end
end

S:AddCallbackForAddon("Blizzard_GuildBankUI", "KuiGuildBank", styleGBank)
