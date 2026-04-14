local KUI, T, E, L, V, P, G = unpack(select(2, ...))
local DB = E:GetModule('DataBars')
local KDB = KUI:NewModule('KuiDatabars')

--Cache global variables
--Lua functions
local _G = _G
local pairs = pairs
--WoW API / Variables
local C_Timer_After = C_Timer.After
-- GLOBALS:

function KDB:StyleBackdrops()
	for _, bar in pairs(DB.StatusBars) do
		if bar and bar.db.enable then
			if bar.backdrop then
				bar.backdrop:Styling()
		end
	end
	end
end

function KDB:Initialize()
	local db = E.db.KlixUI.databars
	KUI:RegisterDB(self, 'databars')

	T.C_Timer_After(1, KDB.StyleBackdrops)	
end

KUI:RegisterModule(KDB:GetName())