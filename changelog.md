# Changelog.md

## 2026-05-29 - Performance, Taint und Debugger Verbesserungen

Diese Session fokussiert sich auf drei separate Problembereiche: einen Performance-Bug im MicroBar, einen `ADDON_ACTION_BLOCKED`-Taint-Fehler durch `CompactRaidFrameManager`, und eine umfassende Erweiterung des In-Game-Debuggers mit Cross-Attribution zwischen Performance-Monitor und Funktions-Tracer.

### Performance: MicroBar event-basierte Updates

- Die `OnUpdate`-Polling-Schleifen der Friends- und Guild-Buttons im MicroBar wurden entfernt. Diese liefen alle 5 Sekunden pro Button und verursachten permanenten Frame-Overhead ohne Anlass.
- Ersetzt durch event-basierte Updates via `FRIENDLIST_UPDATE` und `GUILD_ROSTER_UPDATE` — Counts werden jetzt nur noch aktualisiert, wenn sich die Daten tatsächlich ändern.
- `DELAY = 5`-Konstante entfernt.

### Taint-Fix: CompactRaidFrameManager ADDON_ACTION_BLOCKED

- Neues Modul `modules/tweaks/compactraidfix.lua` hinzugefügt, das den 9× wiederholten `ADDON_ACTION_BLOCKED`-Fehler behebt.
- **Root Cause:** KlixUI HereBeDragons feuert `PlayerZoneChanged`-Callback (tainted Context) → TomTom ruft `SetZoom` auf → CVar-Änderung → Blizzard `CompactRaidFrameManager_UpdateContainerVisibility` → `Show()` auf einem `SecureHandlerShowHideTemplate`-Frame → geblockt.
- **Warum der alte Fix nicht reichte:** `RegisterStateDriver("hide")` überschreibt die Sichtbarkeit über das sichere Attribut-System, aber erst *nachdem* `Show()` versucht wurde — der Block feuert bereits an der Call-Site.
- **Richtiger Fix:** `CompactRaidFrameManager_UpdateShown` und `CompactRaidFrameManager_UpdateContainerVisibility` werden durch No-Ops ersetzt, da ElvUI diese Frames durch sein eigenes Raid-Frame-System verwaltet. `RegisterStateDriver("hide")` bleibt als sicherer Fallback.
- Der Override läuft beim Load, bei `ADDON_LOADED` für `Blizzard_CompactRaidFrames`, bei `PLAYER_ENTERING_WORLD` und `PLAYER_REGEN_ENABLED` — damit werden Late-Loading und ElvUI-Re-Hooks nach Zone-Wechseln abgedeckt.
- ElvUI's `OnShow`/`OnHide`-Hooks auf den Frames werden entfernt und Frames über das sichere Attribut-System ausgeblendet.
- Zweiter Block-Pfad gefixt: `CompactUnitFrame_UpdateVisible` wird jetzt für `CompactRaidFrame*`-Unit-Frames per Wrapper unterdrückt — verhindert `CompactRaidFrame1:Show()` aus dem `CompactUnitFrame_UpdateAll`-Pfad. Der Wrapper wird nur einmal installiert und erhält das Original-Verhalten für alle anderen Compact-Frame-Typen.

### SyncConfiguredLists Aufräumen

- `SMB:SyncConfiguredLists` hat jetzt eine Phase-1-Cleanup-Schritt, der bedingungslos läuft (auch bevor Buttons gefunden wurden).
- **Phase 1a:** Entfernt veraltete `ignoreButtons`-Einträge aus älteren DB-Versionen.
- **Phase 1b:** Entfernt nicht-bevorzugte Alias-Einträge (z.B. `LIBDBICON10_KLIXUI` wenn `KLIXUI` der bevorzugte `displayKey` ist) — behebt doppelte Button-Einträge aus alten Installationen.
- Absturz-Fix in `UpdateButtonBar` wenn `self.Bar.SetBackdrop` auf manchen Classic-Clients nil ist (Guard hinzugefügt).

### Debugger: Cross-Attribution und Auto-Scan

- Timing von `GetTime()` (10 ms Auflösung) auf `debugprofilestop()` umgestellt für Sub-Millisekunden-Präzision in `/kuidbg trace` und `/kuidbg perf`.
- Rolling Ring Buffer (20 Einträge) zwischen Tracer und Performance-Monitor geteilt — jede Spike-Zeile zeigt jetzt, welche KlixUI-Funktion in diesem Frame lief.
- `/kuidbg trace` scannt automatisch alle global benannten `KUI_*` / `KlixUI*`-Frames statt nur einer festen Liste; instrumentiert zusätzlich RaidCD, EnemyCD, DiminishCD, PulseCD, Announcer, MicroBar, RaidMarkers Modul-Frames und `SMB:SyncConfiguredLists`.
- `TraceStop`-Report ist jetzt nach Gesamtzeit absteigend sortiert — der schlimmste Verursacher steht oben.
- `TraceWrapEvent` hinzugefügt, der den Event-Namen im Label mitführt (`FunctionName[EVENT_NAME]`).
- Kombinierter `/kuidbg perf` + `/kuidbg trace` Workflow ist in `/kuidbg help` dokumentiert.

### Status

- Alle Änderungen dieser Session sind lokal (noch kein Commit).
- Die 9× `ADDON_ACTION_BLOCKED`-Fehler sollten nach `/reload` weg sein.
- MicroBar-OnUpdate-Overhead ist eliminiert.
- Debugger ist bereit für erweiterte Performance-Diagnose.

## 2026-04-15 - Character Frame, Toasts and MoP UI Follow-up

This update continues the MoP Classic port with a narrower follow-up pass on the character frame, the Armory/Stats panel, toast notifications, LibDBIcon/minimap tooltip behavior, and Blizzard UI skin guards. The goal remained conservative: keep working legacy pieces, disable broken retail-only overlays on MoP, and replace missing APIs with client-safe fallbacks.

### Armory, character frame and talents

- Disabled the incompatible `ElvUI_BetterTalentFrame` overlay on MoP Classic instead of leaving the replacement talent UI in a half-broken state with `Unknown Talent` entries and incorrect extra spec tabs.
- Disabled the additional KlixUI Blizzard talent skin on MoP so the native ElvUI Mists talent skin keeps ownership of specialization buttons and spec icons.
- Disabled the old KlixUI custom CharacterStats override on MoP Classic and left the native Blizzard character stats pane active, because the legacy override was conflicting with the MoP character stat categories and leaving the values area effectively broken.
- Added a MoP-safe early return in `modules/armory/stats.lua` so the old custom stat category rebuild and scrollframe reparenting no longer run on the MoP client.
- Updated the Armory options to reflect that the old custom stats override is intentionally unavailable on MoP Classic.
- Reworked the Armory top stats panel anchoring so it now follows the full `CharacterFrame` width instead of only the PaperDoll subframe width.
- Updated the top stats panel anchor parent so it stays attached to the actual character frame layout instead of drifting during frame updates.
- Added safe hide/show behavior for the top stats panel when the PaperDoll page is hidden.
- Stopped showing the outdated retail default stat priority text on MoP Classic when no custom text is configured.
- Clarified the `Custom Stat Priority Text` option so MoP users can now intentionally provide their own stat priority string instead of inheriting wrong retail defaults.

### Toasts and gameplay-related MoP API fixes

- Added new toast options:
  - `Hold On Mouseover`
  - `Achievement Icon Source`
  - `Use MoP Fallback Icons`
- Added a dedicated achievement icon resolver so achievement toasts can fall back more gracefully on MoP when badge/icon data is incomplete.
- Guarded Garrison/Follower tooltip handling in the toast module so unsupported WoD-era systems do not fire nil errors on MoP Classic.
- Fixed recipe toast handling so missing `C_TradeSkillUI.GetTradeSkillLineForRecipe` / trade-skill texture paths no longer crash the `NEW_RECIPE_LEARNED` event.
- Added icon/name fallback handling for currency toasts so MoP currencies such as Ironpaw Tokens no longer appear with missing icon and missing text.
- Fixed `modules/combattext/combattext.lua` so the module no longer depends on a missing `T.C_NamePlate_GetNamePlateForUnit` wrapper and safely falls back to the real MoP nameplate API.
- Fixed `modules/tweaks/speedyloot.lua` to use a MoP-safe loot method lookup path instead of hard-failing on the wrong API wrapper.
- Fixed `modules/misc/misc.lua` gossip and specialization helper paths by replacing nil cached modern lookups with MoP-safe global/API fallbacks.

### Minimap buttons and tooltip follow-up

- Continued the Square Minimap Buttons follow-up work and restored the newer filter-driven settings after the user-reset minimap button file was brought back into the repo.
- Kept support for:
  - filter ordering via `By Filtering`
  - `Whitelist`, `Blacklist`, and `Collapsed Buttons`
  - collapse button, button source, growth direction, docking and custom position options
- Fixed the KlixUI broker naming split so the internal broker name is stable for filtering while the visible display label can remain styled separately.
- Fixed the special `KLIXUI` token case in collapsed button handling by normalizing alias/token matching more aggressively.
- Added and kept the in-game minimap button debugger for inspecting real frame state, icon regions, texture slots and filter tokens.
- Reworked the tooltip styling path for LibDBIcon/minimap button tooltips so these tooltips are styled through the proper KlixUI tooltip path instead of inheriting inconsistent AddOnSkins/default-only results.
- Added a dedicated `LibDBIconTooltip` skin pass so standard minimap button tooltips now follow the same general KlixUI tooltip family as normal tooltips and the working WeakAuras broker case.

### Blizzard skins, movers and MoP guards

- Added a MoP-safe guard in `modules/skins/addons/WeakAurasOptions.lua` so the old `WeakAuras.OptionsFrame()` path no longer crashes when WeakAurasOptions uses a different frame creation path.
- Fixed the quest frame skin to stop assuming `spellTex` always exists on MoP Classic quest subframes.
- Added MoP-safe guards/disable paths for additional Blizzard skin modules that were still assuming later-client frame structures, including:
  - Trade
  - Trainer
  - Talent
- Adjusted the Blizzard movable-frame module to stop spamming missing-frame messages for frames that simply do not exist on this client.
- Improved the Blizzard movable-frame anchor/session handling so temporary frame positions are preserved more safely across Blizzard-driven `SetPoint` resets instead of immediately snapping back to defaults.
- Fixed the `KlixUI > Medien` slider range issue by guarding the dynamic width slider max values so the AceGUI slider never receives an invalid `max < min` range on this client.

### Notes

- On MoP Classic, the top Armory stat-priority panel now expects user-supplied custom text if you want spec recommendations shown there. The old retail priority defaults are intentionally no longer used on this client.
- Several extra KlixUI overlays that replaced native Blizzard panes were deliberately disabled on MoP when the underlying data model or frame structure did not match cleanly enough for a minimal fix.

## 2026-04-14 - Minimap Buttons and CombatText Follow-up

This update continues the MoP Classic stabilization work with a narrow focus on the Square Minimap Buttons bar, MoP-safe combat text nameplate access, and cleanup of the current porting/debug workflow.

### Combat text

- Fixed the nameplate lookup path in `modules/combattext/combattext.lua` so KlixUI no longer depends on the missing `T.C_NamePlate_GetNamePlateForUnit` wrapper.
- Added a safe fallback to `C_NamePlate.GetNamePlateForUnit` when the toolkit wrapper is unavailable on MoP Classic.
- Prevented repeated scrolling combat text errors from firing during damage events when a nameplate anchor is requested.

### Square Minimap Buttons

- Reworked the Square Minimap Buttons option handling so the newer filter-driven settings are wired back into the live module logic.
- Restored working support for:
  - `Sort By`, including `By Filtering`
  - `Whitelist`, `Blacklist` and `Collapsed Buttons`
  - collapse toggle and start-collapsed behavior
  - `Button Source`
  - `Growth Direction`
  - optional position overrides and minimap docking
- Added token parsing, alias matching and stable filter-order handling so button order can follow the configured filter lists instead of falling back to simple name sorting.
- Improved Blizzard button registration for the minimap button bar by treating Tracking, Mail, Queue and Garrison buttons as explicit button tokens.
- Added live debug support for the minimap button module so button state, texture regions and filter state can be inspected directly in game.

### Minimap button rendering status

- Narrowed the remaining icon issue down to the LibDBIcon render path instead of button discovery or registration.
- Confirmed via in-game debug output that the real addon icon textures are found and attached to the minimap button frames.
- Removed the incorrect assumption that the icon source was missing; the remaining work is isolated to the final visual render path for the Square Minimap Buttons bar.

### Porting notes

- Continued the conservative MoP Classic porting approach: keep the existing structure, prefer feature detection and fallback APIs, and avoid broad refactors while isolating retail-specific assumptions.

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
