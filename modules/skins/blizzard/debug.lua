local KUI, T, E, L, V, P, G = unpack(select(2, ...))
local KS = KUI:GetModule('KuiSkins')
local S = E:GetModule('Skins')

-- Cache global variables
-- Lua functions
local _G = _G
local select, unpack = select, unpack
-- WoW API
local hooksecurefunc = hooksecurefunc
-- GLOBALS:

local r, g, b = T.unpack(E["media"].rgbvaluecolor)

local function reskinTableAttribute(frame)
	frame:Styling()
end

local function styleDebugTools()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.debug ~= true or E.private.KlixUI.skins.blizzard.debug ~= true then return end

	local EventTraceFrame = _G.EventTraceFrame
	EventTraceFrame:Styling()

	-- Table Attribute Display
	reskinTableAttribute(_G.TableAttributeDisplay)

	hooksecurefunc(_G.TableInspectorMixin, "InspectTable", function(self)
		reskinTableAttribute(self)
	end)
end

S:AddCallbackForAddon("Blizzard_DebugTools", "KuiDebugTools", styleDebugTools)