local KUI, T, E, L, V, P, G = unpack(select(2, ...))
local KDB = KUI:GetModule("KuiDatabars")
local EDB = E:GetModule("DataBars")

local function DataBarTable()
	local ACH = E.Libs.ACH

    E.Options.args.KlixUI.args.modules.args.databars = {
        type = "group",
        name = L["DataBars"],
		get = function(info) return E.db.KlixUI.databars[ info[#info] ] end,
		set = function(info, value) E.db.KlixUI.databars[ info[#info] ] = value; E:StaticPopup_Show("PRIVATE_RL"); end,
        args = {
			name = ACH:Header(KUI:cOption(L["DataBars"]), 1),
			},
        }
end
T.table_insert(KUI.Config, DataBarTable)
