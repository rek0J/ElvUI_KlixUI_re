-------------------------------------------------------------------------------
-- Credits: WhistledAway - Dethanyel
-------------------------------------------------------------------------------
local KUI, T, E, L, V, P, G = unpack(select(2, ...))
local WM = KUI:NewModule("WhistleMaster", "AceEvent-3.0", "AceHook-3.0", "AceTimer-3.0")
local HBD = LibStub("HereBeDragons-2.0", true)
local HBDPins = LibStub("HereBeDragons-Pins-2.0", true)
if not HBD or not HBDPins then return end -- MoP Classic: skip if missing


local match, find = string.match, string.find
local FlightPointDataProviderMixin, Enum, WorldMapFrame, GameTooltip = _G.FlightPointDataProviderMixin, _G.Enum, _G.WorldMapFrame, _G.GameTooltip
local BACKPACK_CONTAINER, NUM_BAG_SLOTS = _G.BACKPACK_CONTAINER, _G.NUM_BAG_SLOTS

-- Flight Master's Whistle Item ID
WM.FMW_ID = 141605

-- Continents where the FMW can be used
WM.SupportedZones = {
  -- Legion
  [630] = { name = "Azsuna", reqLevel = 110 },
  [634] = { name = "Stormheim", reqLevel = 110 },
  [641] = { name = "Val'sharah", reqLevel = 110 },
  [646] = { name = "Broken Shore", reqLevel = 110 },
  [650] = { name = "Highmountain", reqLevel = 110 },
  [680] = { name = "Suramar", reqLevel = 110 },
  [830] = { name = "Krokuun", reqLevel = 110 },
  [882] = { name = "Mac'Aree", reqLevel = 110 },
  [885] = { name = "Antoran Wastes", reqLevel = 110 },

  -- BFA
  [862] = { name = "Zuldazar", reqLevel = 120 },
  [863] = { name = "Nazmir", reqLevel = 120 },
  [864] = { name = "Vol'dun", reqLevel = 120 },
  [895] = { name = "Tiragarde Sound", reqLevel = 120 },
  [896] = { name = "Drustvar", reqLevel = 120 },
  [942] = { name = "Stormsong Valley", reqLevel = 120 },
  [1355] = { name = "Nazjatar", reqLevel = 120 },
  [1462] = { name = "Mechagon Island", reqLevel = 120 }
}

-- Variables
local currentMapID = -1     -- map where the player is, such as Boralus
local currentZoneMapID = -1 -- map of the actual zone, such as Tiragarde Sound
local playerHasWhistle = false
local pinsNeedUpdate = false
local taxiNodeCache = {}
local nearestTaxis = {}

local whistleMaster = T.CreateFrame("Frame", KUI.Title.."WhistleMaster")

local function colorText(s)
  return T.string_format("|cfff960d9%s|r", s)
end

-- Returns true if the player can use the flight master's whistle.
local function whistleCanBeUsed()
  local zoneInfo = currentZoneMapID and WM.SupportedZones[currentZoneMapID]
  return
    playerHasWhistle and
    not T.IsIndoors() and
    zoneInfo and
    zoneInfo.reqLevel <= T.UnitLevel("PLAYER")
end

local timer = 0
local function OnUpdateHandler(whistleMaster, elapsed)
    timer = timer + elapsed
    if (timer >= 1) then
      WM:UpdateTaxis()
      timer = 0
    end
    WM:UpdatePins()
end
whistleMaster:SetScript("OnUpdate", OnUpdateHandler)

function WM:BAG_UPDATE()
	for bag = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
        for slot = 1, T.GetContainerNumSlots(bag) do
			local itemID = T.GetContainerItemID(bag, slot)
			if itemID and (itemID == WM.FMW_ID) then
				playerHasWhistle = true
				return
			end
        end
	end
	playerHasWhistle = false
end

function WM:HereBeDragonsCall()
  -- Ignore nodes with these textureKitPrefix entries
  local TEXTURE_KIT_PREFIX_IGNORE = {
    FlightMaster_Ferry = true
  }

	-- Returns the map info of the parent zone based on a uiMapID.
	local function getZoneMapInfo(uiMapID)
    local mapInfo = T.C_Map_GetMapInfo(uiMapID)
    if not mapInfo then return end

    -- Return if current map will not have a parent zone
    if (mapInfo.mapType < Enum.UIMapType.Zone) then return end

    -- Crawl back through maps to get parent zone
    while mapInfo.mapType >= Enum.UIMapType.Zone do
      local parentInfo = T.C_Map_GetMapInfo(mapInfo.parentMapID)
      if not parentInfo then return end

      -- break if parent map is < zone type
      if parentInfo.mapType >= Enum.UIMapType.Zone then
        mapInfo = parentInfo
      else
        break
      end
    end

    if mapInfo.mapType == Enum.UIMapType.Zone then return mapInfo end
  end

  local function updateTaxiNodeCache(mapInfo)
    local nodes = T.C_TaxiMap_GetTaxiNodesForMap(mapInfo.mapID)
    if not nodes or (#nodes == 0) then return end

    local factionGroup = T.UnitFactionGroup("PLAYER")

    for _, node in T.next, nodes do
      if FlightPointDataProviderMixin:ShouldShowTaxiNode(factionGroup, node) then
        if
          -- Only add nodes in the current zone
          node.name:find(mapInfo.name, 1, true) and
          -- Ignore nodes with certain textureKitPrefix entries
          not TEXTURE_KIT_PREFIX_IGNORE[node.textureKitPrefix]
        then
          taxiNodeCache[#taxiNodeCache+1] = node
        end
      end
    end
  end

  -- HBD Callback
  HBD.RegisterCallback(WM, "PlayerZoneChanged", function(_, mapID)
    for k in next, taxiNodeCache do taxiNodeCache[k] = nil end
    for k in next, nearestTaxis do nearestTaxis[k] = nil end

    if not mapID then return end
    currentMapID = mapID

    local mapInfo = getZoneMapInfo(mapID)
    if not mapInfo then return end

    -- Return if zone not supported
    if not WM.SupportedZones[mapInfo.mapID] then return end
    currentZoneMapID = mapInfo.mapID

    updateTaxiNodeCache(mapInfo)
  end)
end

-- ============================================================================
-- Pin Pool
-- ============================================================================
