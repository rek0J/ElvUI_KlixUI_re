# Changelog

## 2026-04-13 - MoP Classic Porting Update

This update focuses on getting the retail-oriented ElvUI_KlixUI codebase running safely on WoW MoP Classic with minimal, conservative changes. The goal was stability and compatibility, not refactoring or feature redesign.

### Core and configuration

- Updated old ElvUI config entry points to the current valid paths, including `ToggleOptionsUI` replacements and safer option opening flow.
- Fixed multiple AceConfig and options-tree issues caused by outdated custom parameters, old ElvUI option paths, and missing option subtables.
- Added defensive defaults and guards for partially migrated saved variables instead of letting config panels hard-error.
- Added MoP-safe toolkit fallbacks where old wrappers pointed at missing globals.

### Bags and item handling

- Fixed the ElvUI Bags hook path so KlixUI only hooks ElvUI bags when ElvUI bags are actually active.
- Added safe guards for Baganator vs ElvUI Bags selection so the ElvUI bag hook block no longer runs on the wrong bag system.
- Replaced outdated bag API assumptions in the connected hook block with MoP-safe access.
- Hardened related slot and bank frame setup to avoid nil access during initialization.

### Layout and datatext panels

- Fixed KlixUI custom datatext panel initialization so `KuiLeftChatDTPanel` and `KuiRightChatDTPanel` receive valid font defaults.
- Ensured panel settings are initialized before `UpdatePanelInfo()` is called.
- Fixed missing `LoadedInfo` font values so ElvUI datatext layout no longer crashes on nil font data.

### Datatexts

- Fixed `Time (KUI)` world PvP and calendar paths by guarding missing APIs and skipping unsupported info blocks safely.
- Fixed `Spec Switch (KUI)` specialization name resolution and added a consistent menu-opening helper for MoP/ElvUI menu APIs.
- Fixed professions click-path fallout by repairing the downstream TradeSkill and Archaeology consumers instead of disabling the datatext.

### Actionbars

- Fixed `AutoButtons` quest watch handling for MoP by falling back from modern `C_QuestLog` calls to classic quest watch APIs.
- Fixed item quality color handling so missing quality RGB values no longer crash border coloring.
- Added safer handling for tracking, mail and queue minimap button capture in the Square Minimap Buttons bar.
- Fixed the MicroBar config button to use the current ElvUI options API.

### Maps, minimap and world map

- Repaired the Maps options branch so outdated ElvUI option injections no longer abort the remaining KlixUI module options.
- Fixed Minimap location holder resolution for current ElvUI frame names.
- Hardened Minimap styling against optional Blizzard frames missing on MoP.
- Restored the `worldmap.lua` load path and made the KlixUI world map options visible again when the module is actually present.
- Fixed the world map reveal path by using safe `C_Map` and `C_MapExplorationInfo` access with `mapID` fallback when `GetMapArtID` is unavailable.
- Fixed the world map scale/cursor override so map dragging and zoom work again instead of breaking the scroll container.
- Fixed Square Minimap Buttons startup so the bar is populated immediately, legacy MoP defaults migrate sensibly, and the bar no longer starts invisible by default.
- Fixed Tracking button parenting and border handling in the minimap button bar for MoP frame structure.

### Armory, stats and talents

- Fixed Armory option injection for the current ElvUI option tree.
- Fixed `IcyStats` vertical justification and specialization resolution for MoP.
- Disabled incompatible CharacterStats drag/save behavior after KlixUI category manipulation so Blizzard stat category order saving no longer errors.
- Fixed talent tooltip setup so empty cached talent entries no longer pass invalid data to `GameTooltip:SetTalent()`.

### Blizzard skins

- Fixed or guarded multiple retail-only skin paths across Blizzard modules, including Achievement, Calendar, Collectables, Encounter Journal, PvP and TradeSkill.
- Removed or skipped unsupported retail-only options such as Scrapping and Communities on MoP instead of leaving invalid option definitions active.
- Added safe hook guards where KlixUI was hooking functions or object methods that do not exist on MoP.

### Miscellaneous fixes

- Fixed old panel callback names in misc options to the real current ElvUI layout methods.
- Fixed LocPanel slider ranges by using the correct screen width field and guarding min/max values.
- Fixed AutoLog map lookup handling and protected it against missing map info.
- Fixed Game Menu model handling so invalid file data IDs are no longer sent through the wrong model API.
- Fixed dropdown parent resolution in the KlixUI dropmenu path.
- Fixed EliteIcon parenting so target changes no longer pass an invalid parent to `SetParent()`.

### Compatibility approach

- Retail-only blocks without a safe MoP fallback are now skipped defensively instead of hard-failing.
- Existing structure was preserved wherever possible; the work focused on nil guards, feature detection, safe fallbacks and minimal path corrections.

### Known limitations

- Some retail-only features remain intentionally disabled or guarded on MoP Classic when no clean legacy equivalent exists.
- If a remaining issue appears in the World Map or Blizzard skin modules, it is most likely another isolated UI-structure difference rather than a general module loader failure.
