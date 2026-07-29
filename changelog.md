# Changelog.md

## 2026-07-11 (Teil 5) - Crash-Fix: ADDON_ACTION_FORBIDDEN beim Talent-Entfernen

Live-Fehlerreport (2x): `RemoveTalent()` protected-function-Aufruf, ausgelöst über `Blizzard_TalentUI/Mists/Blizzard_TalentUI.lua OnAccept` (Pet-Talentbaum, alte Punkt-Vergabe-UI). Gleiche Fehlerklasse wie die Glyph-Popups: `modules/misc/confirmSP.lua`s Auto-Confirm blacklistet diesen Dialog gar nicht. Fehlender Key `"CONFIRM_REMOVE_TALENT"` ergänzt.

## 2026-07-11 (Teil 4) - Crash-Fix: type()-Shadowing in raidCD + echte Taint-Quelle für CompactRaidFrame gefunden

**`modules/cooldowns/raidCD.lua`** (14x): `GetChargeInfo` (Teil 3) rief `type(a)` auf — diese Datei hat aber `local _, type = T.IsInInstance()` auf Dateiebene (Zeile 40), was den globalen `type()`-Befehl für den kompletten Rest der Datei überschattet. Jeder Aufruf von `type(...)` unterhalb dieser Zeile trifft die lokale Variable statt der eingebauten Funktion. Auf `T.type` umgestellt (Toolkit-Wrapper, unbeeinflusst vom Shadowing).

**`libs/HereBeDragons/HereBeDragons-Pins-2.0.lua`**: Die eigentliche Taint-Quelle hinter den `CompactRaidFrame:Show()/Hide()`-Blockaden gefunden (in `compactraidfix.lua` als "TomTom/SetZoom" vermutet, ist aber unsere eigene mitgelieferte HereBeDragons-Pins-Bibliothek). `UpdateMinimapZoom()` macht auf Clients ohne `C_Minimap.GetViewRadius` (MoP Classic hat das offenbar nicht) einen doppelten `Minimap:SetZoom()`-Toggle zur Indoor/Outdoor-Erkennung, ausgelöst u.a. bei `MINIMAP_UPDATE_ZOOM`. Läuft das im selben UI-Update-Tick wie ein CompactRaidFrame-Layout-Update während des Kampfes, blockiert es die geschützten Show()/Hide()-Aufrufe. Mit `not InCombatLockdown()` abgesichert — Indoor/Outdoor-Erkennung pausiert im Kampf, läuft beim nächsten Zonenwechsel/Zoom-Event nach.

## 2026-07-11 (Teil 3) - Crash-Fix: raidCD Chargen-API + CompactRaidFrame-Taint-Lücke

**`modules/cooldowns/raidCD.lua`** (66x-Fehlerreport): `attempt to perform arithmetic on local 'start' (a nil value)` bei jedem Battle-Res-Charge-Update. Ursache: `T.GetSpellCharges` zeigt auf `C_Spell.GetSpellCharges`, das auf diesem Client EIN Table zurückgibt (`currentCharges`/`maxCharges`/`cooldownStartTime`/`cooldownDuration`/`chargeModRate`), nicht die alten Mehrfach-Rückgabewerte. Der Code hat `local curCharges, maxCharges, start, duration = T.GetSpellCharges(20484)` erwartet — `start`/`duration` waren dadurch immer `nil`. Neue `GetChargeInfo()`-Hilfsfunktion normalisiert beide API-Formen (prüft ob der erste Rückgabewert ein Table ist), an beiden betroffenen Stellen (`UpdateCharges`, `StartTimer`) eingesetzt.

**`modules/tweaks/compactraidfix.lua`**: `ADDON_ACTION_BLOCKED` bei `CompactRaidFrame6:Show()`. Der bestehende Fix (periodischer Sweep über `CompactRaidFrame1..40` bei GROUP_ROSTER_UPDATE etc.) hatte eine Race: Blizzards `CompactRaidFrameContainerMixin:GetUnitFrame` erzeugt neue `CompactRaidFrame<N>`-Buttons bedarfsgesteuert **auf dasselbe** `GROUP_ROSTER_UPDATE`-Event und verdrahtet sofort `CompactUnitFrame_SetUpdateAllEvent(frame, "GROUP_ROSTER_UPDATE")` darauf — wächst der Raid (z.B. auf 6 Member), kann das neue Frame NACH unserem Sweep entstehen und bleibt verdrahtet. Fix D: `CompactUnitFrame_SetUpdateAllEvent` selbst gehookt (`hooksecurefunc`) und für jedes `CompactRaidFrame<N>` sofort `UnregisterAllEvents()` nachgeschoben, unabhängig vom Timing des periodischen Sweeps. Quelle verifiziert gegen Blizzards `Blizzard_CompactRaidFrameContainer.lua`.

## 2026-07-11 (Teil 2) - Crash-Fix: ADDON_ACTION_FORBIDDEN beim Glyph-Wechsel

Live-Fehlerreport (3x): `PlaceGlyphInSocket()` protected-function-Aufruf via `!BugGrabber` → `ADDON_ACTION_FORBIDDEN`. `modules/misc/confirmSP.lua` (Auto-Confirm für Static Popups) blacklistet Dialoge, die geschützte Funktionen aufrufen, damit sie NICHT automatisch weggeklickt werden. Der Eintrag hieß `"REPLACE_GLYPH"` — dieser Dialog-Key existiert in der MoP-Glyph-UI aber gar nicht. Laut Blizzards `Blizzard_GlyphUI.lua` heißt der tatsächliche Dialog beim Glyph-Ersetzen `"CONFIRM_GLYPH_PLACEMENT"` (ruft `PlaceGlyphInSocket`) und beim Entfernen `"CONFIRM_REMOVE_GLYPH"` (ruft `RemoveGlyphFromSocket`) — beide bisher ungeblacklistet, wurden also vom Auto-Confirm-Timer angeklickt und lösten den geschützten Aufruf aus insecure Code aus. Blacklist-Key korrigiert und den Removal-Fall ergänzt.

## 2026-07-11 - Raid-Buff-Reminder: 5 Fallback-Slots pro Flask/Food

`modules/reminder/raid.lua`: `flaskItem`/`foodItem` (je ein Item-Name) durch `flaskItems`/`foodItems` (je 5 Slots) ersetzt. Klick probiert die Slots der Reihe nach durch (`PickAvailableItem`) und bindet das secure Item-Attribut auf das erste tatsächlich in den Taschen vorhandene Item (`T.GetItemCount`) — fehlt Slot 1, wird automatisch Slot 2 genommen usw. Neu registriertes `BAG_UPDATE` (debounced über `T.C_Timer_After(0.2, ...)`, da es bei Loot/Taschen-Umsortierung dutzendfach hintereinander feuert) hält die Auswahl aktuell, während sich der Taschen-Inhalt ändert. `modules/reminder/options.lua`: neue `ItemSlotGroup`-Hilfsfunktion erzeugt je 5 Texteingaben für Flask/Food; `defaults/profile.lua` entsprechend auf Array-Defaults (`{ "", "", "", "", "" }`) umgestellt.

## 2026-07-10 (Teil 7) - Raid-Buff-Reminder: MoP-Daten korrigiert + Klick-zum-Buffen

**`modules/reminder/raid.lua`:**
- **Flask-IDs waren Legion/BfA/Shadowlands**, auf MoP Classic komplett falsch/nicht vorhanden. Ersetzt durch die vier echten MoP-Flasks: Flask of Spring Blossoms (114769, Int), Flask of the Earth (114770, Stam), Flask of the Warm Sun (114771, Agi), Flask of Winter's Bite (105696, Str).
- **Food-Erkennung umgestellt** von einer Liste von Spell-IDs (die alle aus Shadowlands stammten und auf MoP nicht existieren) auf Namensvergleich der Aura ("Well Fed") — jedes MoP-Food hat eine eigene Spell-ID pro Gericht, ein Name-Match deckt sie alle ab statt jede einzeln zu pflegen. Zeigt zusätzlich das Icon des tatsächlich aktiven Gerichts statt eines festen Icons.
- **Intellect/Stamina/AttackPower-Listen bereinigt**: BfA-War-Scroll-IDs (264760/264761/264764) und "Blood Pact" (6307, in MoP nicht mehr die Quelle des Stamina-Buffs) entfernt. Übrig: Arcane Intellect (1459), Power Word: Fortitude (21562), Battle Shout (6673) — alle drei MoP-gültig.
- **DefiledAugmentRune (Legion/Argus-Feature) existiert auf MoP Classic nicht** — Frame wird dort gar nicht mehr erzeugt und in `OnAuraChange` nicht mehr geprüft (`if not E.Mists then ... end`), Fensterbreite passt sich entsprechend an.
- **Klick-zum-Nutzen hinzugefügt** (Community-Wunsch): Flask-/Food-Icon sind jetzt sichere Buttons (`SecureActionButtonTemplate`); Klick nutzt das in den Optionen hinterlegte Item aus der Tasche (`flaskItem`/`foodItem`, freier Item-Name-Text, leer = kein Klick). Die drei Klassenbuff-Icons (Intellect/Stamina/AttackPower) casten automatisch den eigenen Buff, aber nur wenn die Spielerklasse dazu passt (Mage/Priest/Warrior) — für alle anderen bleibt das Icon rein informativ. Attribute werden ausschließlich außerhalb des Kampfes über `KUI:RunOutOfCombat` gesetzt (SetAttribute auf einem sicheren Button ist im Kampf verboten/tainted).
- Neue Optionsfelder `modules/reminder/options.lua`: "Flask Item Name" / "Food Item Name" (Texteingabe), inkl. Erklärungstext zum Klick-Verhalten. Defaults in `defaults/profile.lua` ergänzt (`flaskItem`/`foodItem` = "").

## 2026-07-10 (Teil 6) - Crash-Fix: reminder/raid.lua "Class Specific Buffs"

Live-Fehlerreport (415x): `raid.lua:123: attempt to index local 'frame' (a nil value)`, ausgelöst bei jedem `UNIT_AURA`. Ursache: `IntellectFrame`/`StaminaFrame`/`AttackPowerFrame` werden nur in `KRR:Initialize()` erzeugt, wenn `class` zu dem Zeitpunkt bereits `true` war. Wird "Class Specific Buffs" danach im Optionsmenü aktiviert (der Reload-Hinweis-Popup zwingt niemanden tatsächlich zum Reload), bleiben die Frames dauerhaft `nil`, während `OnAuraChange` bei jedem Aura-Wechsel trotzdem `CheckBuffList(IntellectFrame, ...)` aufruft. `CheckBuffList` in `modules/reminder/raid.lua` prüft jetzt zusätzlich `if not frame then return end`, bevor auf `frame.t` zugegriffen wird — unabhängig davon, ob der Nutzer den Reload-Hinweis tatsächlich befolgt.

## 2026-07-10 (Teil 5) - Unnötige Reload-Aufforderungen entfernt + chatClassColorOverride-Option

Durchsicht aller `options.lua`-Dateien auf `E:StaticPopup_Show("PRIVATE_RL")`: für jedes betroffene Setting geprüft, ob die zugehörige Funktion den Wert tatsächlich nur einmalig beim Initialize/Hook-Setup ausliest (Reload dann korrekt nötig) oder live in einem bereits laufenden Event-Handler/Hook neu einliest (Reload dann unnötig und wurde entfernt). ~35 Einzelfelder korrigiert, u.a. in `chat`, `blizzard` (blizzmove.remember), `talents` (borderGlow), `raidmarkers` (Quick-Mark-Tasten), `reminder` (raid alpha/glow, solo glow), `datatexts` (Profession-Datatext, Time-Datatext), `tooltip` (titleColor/memberInfo/achievement, nameHover-Unteroptionen), `quest` (Auto-Pilot- und Announce-Unteroptionen), `notification` (noSound/message/mail/vignette/invites/guildEvents/quickJoin), `cooldowns` (Pulse-Enable, Diminishing-Text, Enemy-CD-Optionen), `armory` (Enchant-/Socket-Glow-Enable), `actionbars` (Finishing-Move-Glow, Hearthstone-Delete, SpecEquipBar- und MicroBar-Unteroptionen), `maps` (Minimap-Glow/FadeIn/Mail-Sound/Button-Source, Location-Text) und `misc` (Bloodlust-Unteroptionen, Merchant-Itemlevel/Equipslot, diverse Auto-Toggles).

Dabei zusätzlich vier echte Bugs gefunden und behoben (kein reines Reload-Thema, sondern die Optionen taten schlicht nichts):
- **`modules/cooldowns/enemyCD.lua`:** Tippfehler `EC.db.show_inpvpshow` statt `EC.db.show_inpvp` — die Option "Show In PvP" hat dadurch seit jeher nie funktioniert, da der Key im DB-Zugriff nicht existierte (immer `nil`/falsy). Korrigiert.
- **`modules/cooldowns/raidCD.lua`:** Wenn der Raid-Cooldown-Tracker deaktiviert ist (`enable = false`), lief `RC:Initialize()` nie und `RC.db` blieb `nil` — der unbedingt aktive `COMBAT_LOG_EVENT_UNFILTERED`-Handler hätte beim ersten passenden Encounter mit "attempt to index nil value (field 'db')" gecrasht. Mit `if not RC.db then return end` abgesichert.
- **`modules/maps/minimap.lua` + `minimaplocation.lua`:** Die komplette "Minimap Ping"-Option (zeigt den Namen dessen, der auf die Minimap geklickt hat) war tot — `MM:MiniMapPing()` wurde in `Initialize()` nie aufgerufen ("Find a way to fix this soonish") und selbst dann hätte `MM.pingpanel.text` gefehlt (die Zeile, die es erzeugt, war ebenfalls auskommentiert, `KS:CreateFS` existiert nirgends in der Codebase). Options-Gruppe ausgeblendet statt wirkungslose Regler zu zeigen. Der "Version" Eintrag der Location-Text-Auswahl (zeigt Addon-Version statt Zonenname an der Minimap) war dagegen nur auskommentiert, obwohl `KUI.Title`/`KUI.Version` echte, existierende Felder sind — einfach wiederhergestellt, jetzt funktionsfähig.
- **`modules/misc/options.lua`:** "Transmog Remover Button" nutzt `WardrobeTransmogFrame.ModelScene`, eine Retail-only-API — Option war auf MoP Classic sichtbar, obwohl der Code sich dort selbst schon abschaltet. Jetzt mit `E.Mists` ausgeblendet, analog zum bereits etablierten Stasis-Muster. `modules/misc/scrapper.lua`: Der komplette "Insert Scrap Button" (samt `enable`/`position`/`autoOpen`/`equipmentsets`/`azerite`/`boe`/`Itemlvl`/`Itemprint`/`specificilvl`) ist seit einer früheren Umstellung auf reine Itemlevel-Anzeige (`SCRAP:CreateScrapButton()` in `Initialize()` ist auskommentiert) funktionslos — noch nicht bereinigt, nur zur Kenntnis: die Options-Gruppe zeigt aktuell Regler ohne Wirkung.

Zusätzlich neue Option auf Wunsch: **`modules/chat/options.lua`** — "Class Colors in Chat" Toggle, steuert `/console SET chatClassColorOverride` per `T.GetCVar`/`T.SetCVar` (0 = Klassenfarben an, 1 = aus), keine Reload nötig (CVar wirkt sofort).

Methodik pro Fund: Modul-Quelldatei gesucht, geprüft ob der Wert (a) nur beim einmaligen `Initialize()`/Hook-Install gelesen wird (→ Reload bleibt nötig) oder (b) frisch bei jedem Event/Hook-Aufruf gelesen wird (→ Reload raus, ggf. durch Aufruf der bereits vorhandenen Live-Update-Funktion ersetzt, nie neu erfunden). `luac -p` über alle geänderten Dateien lief fehlerfrei.

## 2026-07-10 (Teil 4) - options.lua Restdurchsicht + Toasts-Optionsmenü-Abgleich

Letzte verbleibende `options.lua`-Dateien durchgesehen: `tooltip`, `unitframes`, `locpanel`, `toasts`, `maps`, `datatexts`, `notification`, `addonpanel`. Damit ist jede `options.lua` der Codebase geprüft.

- **`modules/toasts/options.lua`:** Vier Toast-Typ-Gruppen (`garrison_6_0` "Garrison"/WoD, `garrison_7_0` "Class Hall"/Legion, `garrison_8_0` "War Effort"/BfA, `world` "World Quest"/Legion+) waren im Optionsmenü uneingeschränkt anwähl- und sichtbar, obwohl `modules/toasts/toasts.lua` sie zur Laufzeit bereits sauber über `HasGarrisonToastSupport()`/`HasWorldToastSupport()` deaktiviert (beide Funktionen prüfen auf `T.C_Garrison_*`/`QuestUtils_IsQuestWorldQuest`, die auf MoP Classic nicht existieren — Garrisons/Class Hall/War Effort/World Quests sind WoD- bzw. Legion+-Content). Kein Crash-Risiko, aber genau der stehende Options-Menü-Mismatch: der Nutzer sieht vier komplette Toast-Kategorien, die nie feuern können. Alle vier Gruppen jetzt mit `disabled = function() return not E.Retail end` / `hidden = function() return not E.Retail end` versehen (gleiches Muster wie `vignette`/`quickJoin` in `notification/options.lua` und `invasions` in `datatexts/options.lua`). `transmog` (seit Patch 4.3, prä-MoP) und `archaeology` (seit Cataclysm) bleiben unverändert sichtbar, da sie auf MoP Classic tatsächlich funktionieren.
- Restliche Dateien (`tooltip`, `unitframes`, `locpanel`, `maps`, `datatexts`, `notification`, `addonpanel`) bereits korrekt `E.Mists`/`E.Retail`-abgesichert vorgefunden — keine weiteren Änderungen nötig.

## 2026-07-10 (Teil 3) - skins/blizzard/ komplett durchgesehen (alle ~49 geladenen Dateien)

- **`modules/skins/blizzard/mail.lua`:** `T.select(i, SendMailFrame:GetRegions()):Hide()` in einer Schleife (Index 4-7) sowie eine weitere Stelle für `SendMailScrollFrame` — falls der Frame weniger Regionen hat als erwartet, liefert `select` nichts zurück und der Methodenaufruf auf "nichts" crasht. Die Datei markierte diesen Bereich selbst schon als "Retail-only frame guard", aber nur teilweise abgesichert. Auf sichere Tabellen-Indizierung mit Existenzprüfung umgestellt.
- **`modules/skins/blizzard/questframe.lua`:** `UpdateGreetingFrame` (Kommentar: "Copied from ElvUI") rief `_G.QuestFrameGreetingPanel.titleButtonPool:EnumerateActive()` ungeprüft auf — ein Retail-Button-Pool-Muster, das MoP Classics Begrüßungs-Panel wahrscheinlich nicht hat. Feuert bei jedem Mehrfach-Quest-Gespräch mit einem NPC. Dieselbe Datei sichert das strukturell identische `spellHeaderPool` weiter unten bereits korrekt ab — hier wurde es übersehen. Jetzt mit derselben Existenzprüfung abgesichert.
- **`modules/skins/blizzard/lfgList.lua`:** Komplette Datei geht ungeprüft von `_G.LFGListFrame` aus (Premade Groups/Group Finder, Legion+, existiert vermutlich nicht auf MoP Classic) und läuft über das generische `S:AddCallback` statt über `AddCallbackForAddon` — kein Addon-Load-Gate wie bei vergleichbaren Dateien. Mit `if not LFGListFrame then return end` abgesichert (Konsistent mit `auctionhouse.lua`s Muster).
- **`modules/skins/blizzard/lfguild.lua` und `lookingforguildUI.lua` (zwei nahezu identische, beide geladene Dateien):** Beide riefen `DUI:ReskinRole(...)` auf — `DUI` ist nirgendwo in der gesamten Codebase definiert (in `gossip.lua` kommt derselbe Name nur in einer auskommentierten Zeile vor). Die tote Schwesterdatei `guildrecruitmentUI.lua` zeigt das korrekte Muster: `KUI:ReskinRole(...)`, eine echte in `toolkit.lua` definierte Methode. In beiden Dateien korrigiert. Hinweis: Beide Dateien sind inhaltlich Duplikate (gleicher Code, gleicher Callback-Name "KuiLookingForGuild") — nicht zusammengelegt, um nicht unaufgefordert eine Datei zu löschen, aber als Aufräum-Kandidat notiert.
- **`modules/skins/blizzard/dressingroom.lua`:** Der eigene "Undress"-Button nutzt `DressUpFrame.ModelScene:GetPlayerActor():Undress()` — die moderne Legion+-Actor/ModelScene-API. Button wurde bisher unbedingt erstellt; ein Klick darauf hätte gecrasht, da MoP Classics DressUpFrame kein `ModelScene`-Feld hat. Button-Erzeugung jetzt hinter einer Existenzprüfung auf `DressUpFrame.ModelScene`.
- Alle übrigen ~40 Dateien geprüft (u.a. `achievement`, `auctionhouse`, `friends`, `gbank`, `communities`, `voidstorage`, `itemupgrade`, `spellbook`, `merchant`, `paperdollFrame`, `encounterjournal`, `inspect`, `calendar`, `blackmarket`, `channels`, `chatFrame`, `debug`, `guildcontrol`, `help`, `macro`, `taxi`, `stacksplit`, `timemanager`, `binding`, `archaeology`, `addonmanager`, `BNet`, `itemText`) — unauffällig, durchgehend korrekt über `S:AddCallback`/`AddCallbackForAddon` plus Existenzprüfungen abgesichert.

## 2026-07-10 (Teil 2) - skins/addons/ komplett durchgesehen

Alle 15 Dateien in `modules/skins/addons/` durchgesehen (aktiv nur, wenn das jeweilige Fremd-Addon installiert ist). Zwei weitere Treffer aus der bereits bekannten Fehlerklasse (ungeprüfter Aufruf einer nicht in `toolkit.lua` gewrappten Funktion), die beim ursprünglichen `T.C_*`-Abgleich schon als "undefiniert" auffielen, aber noch nicht bereinigt waren:

- **`modules/skins/addons/Baggins.lua`:** Drei Aufrufstellen in den `UpdateItemButton`/`CloseAllBags`-Hooks ohne Existenzprüfung: `T.C_AzeriteEmpoweredItem_IsAzeriteEmpoweredItemByID` (Azerite existiert nicht in MoP Classic), `T.C_NewItems_IsNewItem`, `T.C_NewItems_ClearAll`. Crasht bei jedem Bag-Update bzw. Bags-schließen für jeden Nutzer mit installiertem Baggins und aktiviertem Baggins-Skin. Alle drei abgesichert.
- **`modules/skins/addons/Hekili.lua`:** `_G["Hekili_Primary_B"..i].ishadow` (und das AOE-/Interrupts-/Defensives-Pendant) indiziert dieselbe Globale erneut, ohne die direkt davor durchgeführte Existenzprüfung zu wiederholen — crasht, sobald Hekili weniger Buttons erzeugt hat als die Schleife durchläuft. Abgesichert.

Restliche 13 Dateien geprüft und unauffällig (durchgehend über `S:AddCallbackForAddon(...)` gegen das jeweilige Fremd-Addon abgesichert).

## 2026-07-10 (Nachtrag) - cinematic.lua: GameMovieFinished existiert nicht auf diesem Client

Live-Fehlerreport bestätigt: `GameMovieFinished` existiert auf diesem Client nicht als globale Funktion. Betrifft zwei Stellen in `modules/tweaks/cinematic.lua`:

- Die in Teil 2 (2026-07-09) nach Dateiebene verschobene `hooksecurefunc(_G, "GameMovieFinished", ...)`-Zeile lief seitdem unbedingt bei jedem Laden und crashte sofort ("GameMovieFinished is not a function"). Jetzt mit `if type(_G.GameMovieFinished) == "function" then ... end` abgesichert — genau das Muster, das an anderer Stelle in dieser Session bereits für denselben Fehlertyp etabliert wurde, hier aber übersehen wurde.
- `T.GameMovieFinished()` beim Abbrechen eines Movies (Zeile 16) hätte aus demselben Grund gecrasht (Toolkit reicht das fehlende Global unverändert durch: `T.GameMovieFinished = GameMovieFinished`). Mit `if T.GameMovieFinished then ... end` abgesichert.

## 2026-07-09 (Teil 2) - Datei-für-Datei-Nachkontrolle: cooldowns, tweaks, unitframes

Fortsetzung der Nachkontrolle aus Teil 1, diesmal Datei für Datei durch `bags`, `chat`, `cooldowns`, `tweaks`, `databars`, `datatexts`, `misc` und `unitframes`. Zusätzlich `luac -p` über alle 365 Lua-Dateien der Addon (ohne Ausnahme) laufen lassen — bestätigt, dass es keine weiteren Syntaxfehler gibt.

- **`modules/cooldowns/raidCD.lua` reaktiviert:** War in `load_cooldowns.xml` auskommentiert wegen eines echten Syntaxfehlers (`function(T.time)` — Tabellenzugriff ist kein gültiger Parametername) plus eines Tippfehlers (`IT.sInGroup()` statt `T.IsInGroup()`, vertauschte Buchstaben). Die Spell-Liste (Rebirth, Soulstone, Healing Tide Totem, Ironbark, Life Cocoon, Rallying Cry, Smoke Bomb …) ist bereits MoP-korrekt, keine Legion+-Fähigkeiten. Beide Bugs gefixt, `cooldowns.raid`-Default-Tabelle in `defaults/profile.lua` ergänzt (fehlte komplett, hätte `RC:Initialize()` beim Laden zum Absturz gebracht), zugehörige Options-Gruppe in `modules/cooldowns/options.lua` war ebenfalls auskommentiert und wurde mitreaktiviert (inkl. eines doppelten `space1`-Keys, jetzt `space1`/`space2`).
- **`modules/tweaks/cinematic.lua`:** `hooksecurefunc(_G, "GameMovieFinished", ...)` stand innerhalb des Event-Handlers statt einmalig auf Dateiebene — bei jedem CINEMATIC_START/STOP/PLAY_MOVIE/QUEST_COMPLETE/TALKINGHEAD-Event (während Sound stummgeschaltet) kam ein weiterer Hook hinzu, da `hooksecurefunc` keine Duplikate erkennt. Verschoben auf Dateiebene, läuft jetzt nur einmal.
- **`modules/unitframes/elements/healerMana.lua`:** Griff auf Partymitglieder-Frames über einen frei erfundenen globalen Namen zu (`ElvUF_PartyGroup1UnitButton`..i), der nirgendwo sonst in der Codebase vorkommt — jede andere Datei (`health.lua`, `power.lua`, `unitframes.lua`) läuft stattdessen über `_G['ElvUF_Party']:GetChildren()`. `frame` war dadurch immer `nil`, `frame.Power:Hide()` crashte bei jedem `GROUP_ROSTER_UPDATE` (Feature ist standardmäßig deaktiviert, aber garantiert kaputt sobald aktiviert). Auf das etablierte Header/Children-Muster umgestellt.
- **`modules/unitframes/elements/roleIcons.lua`:** `specNameToRole[classToken][talentSpec]` ohne Prüfung, ob `specNameToRole[classToken]` existiert — die Tabelle bleibt auf MoP Classic absichtlich leer (kein `GetSpecializationInfoForClassID`). Nur erreichbar in Battleground-Scoreboard-Lookups, aber potenzieller Crash. Existenzprüfung ergänzt.
- **`modules/databars/load_databars.xml`:** `azerite.lua`/`honor.lua`/`paragonRep.lua` (2019, retail-only) und `experience.lua`/`reputation.lua`/`questXP.lua` (April 2026, "KlixUI Revived") sind bewusste frühere Entscheidungen des Autors, keine Bugs — jetzt mit Kommentar dokumentiert statt stillschweigend zu fehlen, nichts am Verhalten geändert.

## 2026-07-09 - Phase 5 Kompatibilität, AutoButtons-Rework und Bugfixes

Dieses Update deckt Änderungen ab, die im letzten Commit ("big update for p5") bereits im Code enthalten waren, aber noch nicht im Changelog dokumentiert waren, plus drei zusätzliche Bugfixes, die bei der Nachkontrolle gefunden wurden. Interface-Version auf `50504` (Phase 5) angehoben.

### Core: Phase-5-Globals aus C_AddOns / C_CVar / C_SpecializationInfo / C_Spell wiederhergestellt

- `core/core.lua` stellt `GetAddOnMetadata`, `IsAddOnLoaded`, `GetAddOnEnableState`, `DisableAddOn`, `EnableAddOn`, `GetAddOnInfo`, `GetSpecialization` u.a. wieder her, falls Phase 5 diese Globals entfernt hat, mit Fallback auf das alte Global wenn `C_AddOns`/`C_SpecializationInfo` zwar existiert, das jeweilige Feld aber (noch) fehlt.
- **Bug gefunden und gefixt:** Der `GetAddOnEnableState`-Override hat `C_AddOns.GetAddOnEnableState` ungeprüft in einen Upvalue kopiert und das globale `GetAddOnEnableState` bedingungslos überschrieben — anders als alle Nachbarzeilen, die konsequent `C_AddOns.X or X` verwenden. Falls dieses Feld auf dem Client fehlt, wäre das globale `GetAddOnEnableState` durch eine Funktion ersetzt worden, die `nil(...)` aufruft und bei jedem Aufruf (u.a. aus `toolkit.lua` und `compatibility.lua`) crasht. Jetzt mit `if C_AddOns.GetAddOnEnableState then ... end` abgesichert wie alle anderen.
- `core/toolkit.lua`: `GetCVar`/`SetCVar`/`GetCVarBool` gehen jetzt zuerst über `C_CVar`, `GetSpellInfo`/`GetSpellCooldown`/`GetSpellCharges`/`GetSpellTexture` über `C_Spell`, `GetItemCooldown` über `C_Container`, `GetItemSpell` über `C_Item` — jeweils mit Fallback auf das alte Global.

### CompactRaidFrame-Taint-Fix: Ansatz ersetzt

- Der am 2026-05-29 dokumentierte `CompactUnitFrame_UpdateVisible`-Wrapper (globaler Funktions-Override) wurde ersetzt durch `UnregisterAllEvents()` auf `CompactRaidFrame1`..`40` direkt. Grund: Ein globaler Funktions-Override betrifft potenziell auch Nameplate- oder Fremd-Addon-Aufrufe derselben Funktion; das Abmelden der Events auf den betroffenen Frames selbst hat denselben Effekt (der Blizzard-`OnEvent`-Handler, der `Show()` auslöst, feuert nie) bei kleinerer Taint-Oberfläche.
- Zusätzlich wird jetzt auch auf `GROUP_ROSTER_UPDATE` reagiert, damit der Fix nach Roster-Änderungen (neu erzeugte Compact-Frames) erneut angewendet wird.

### AutoButtons (Quest-/Slot-Auto-Use-Leiste): Secure-Click überarbeitet

- **Root Cause:** `type="item"` und `type="click"+clickbutton` liefen auf diesem Client beide ins Leere, obwohl die Attribute korrekt gesetzt waren — die Bag-UI befüllt die alten Slot-Globals nicht mehr, und natives `item`-Dispatch tut nichts. Durch isoliertes `/run`-Testen verifiziert.
- **Fix:** Umstellung auf `type1="macro"` + `macrotext="/use <slotID>"` bzw. `"/use item:<id>"` — derselbe Mechanismus, den Blizzards eigene Paperdoll-Slot-Buttons intern verwenden. Attribute werden jetzt pro Maustaste (`type1`) statt generisch (`type`) gesetzt, `RegisterForClicks` läuft auf `"AnyDown"` statt `"AnyUp"`.
- `AutoButton.Overlay` (Glow-Layer) ist jetzt ein `Frame` statt `Button` und explizit `EnableMouse(false)` — hat vorher Klicks abgefangen, bevor sie den darunterliegenden SecureActionButton erreichten.
- `E:RegisterCooldown` bekam den Cooldown-Typ vorher über ein nicht existentes `cooldown.CooldownOverride`-Feld statt über das zweite Funktionsargument — Cooldowns liefen dadurch stillschweigend unter der falschen Kategorie. Jetzt `E:RegisterCooldown(AutoButton.Cooldown, 'actionbar')`.
- Quest-Item-Buttons tracken jetzt zusätzlich `itemLink` statt nur `itemID`.
- `GetWatchedQuestData` nutzt `C_QuestLog.GetInfo` nicht mehr mit einem Watch-Index (die API erwartet einen Quest-Log-Index) — geht ausschließlich über `GetQuestIndexForWatch`, inklusive Debug-Ausgabe wenn die Auflösung fehlschlägt.
- Tooltip-Anzeige für reine Item-Buttons nutzt `SetHyperlink` statt des Dragonflight-only `GameTooltip:SetItemByID`.
- Neuer, standardmäßig deaktivierter Klick-Debugger: `/kuidbg abclick` (Toggle), `/kuidbg abtest <itemID>`, `/kuidbg autobuttons`.

### Raid-Reminder: Buff-Check dedupliziert

- `OnAuraChange` bestand aus sechs fast identischen kopierten Scan-Blöcken (Flask/Food/Rune/Intellect/Stamina/AP) — zusammengefasst in `PlayerHasAura`/`SpellIcon`/`ApplyBuffState`/`CheckBuffList`. Gleiches Verhalten, ca. 90 Zeilen Duplikat entfernt.
- Aura-Lookup läuft jetzt über `C_UnitAuras.GetPlayerAuraBySpellID`/`GetAuraDataByIndex` statt über das entfernte `AuraUtil.FindAuraByName`-Global.

### Solo-Reminder: Tippfehler behoben

- `modules/reminder/solo.lua`: `PlayerHasFilteredDebuff` hat nach Aura-Typ `"HAKSRFUL"` (Tippfehler) statt `"HARMFUL"` gesucht — Debuff-Reminder haben dadurch nie etwas gefunden. Behoben; beide Aura-Scans prüfen jetzt zusätzlich, ob `GetSpellInfo` `nil` liefert, bevor sie weiterscannen.

### Minimap-Buttons: LFG-/Gruppensuche-Schutz

- Explizite Ignore-Liste plus Namens-Pattern-Matching (`LFGMinimapFrame`, `QueueStatus`, `GroupFinder`, `RaidBrowser` etc.), damit der Minimap-Button-Collector keine Gruppensuche-/LFG-Frames mehr einsammelt, die auf der Standard-Minimap bleiben müssen.

### Nil-Guards in mehreren Modulen

- `misc.lua`, `objectivetracker.lua`, `media.lua`: Hooks auf `VehicleSeatIndicator_SetUpVehicle`/`ObjectiveTracker_Update` prüfen jetzt, ob die Funktion überhaupt existiert, bevor `hooksecurefunc` läuft.
- `mail.lua`: `OpenMailFrameIcon:Hide()` abgesichert (Region existiert auf diesem Client in manchen Pfaden nicht).
- `addonpanel.lua`: Klick-Handler auf `GameMenuButtonAddons` abgesichert.
- `chat.lua`: Fallback auf `ChatFrame_SystemEventHandler` prüft jetzt Existenz statt sie vorauszusetzen.
- `confirmSP.lua`: `REPLACE_GLYPH` zur Popup-Blacklist hinzugefügt (ruft das geschützte `PlaceGlyphInSocket` auf).
- `merchant.lua`: `LE_ITEM_CLASS_RECIPE`-Konstante fällt auf `Enum.ItemClass.Recipe` bzw. den Literal `9` zurück, falls die `LE_ITEM_CLASS_*`-Globals auf diesem Client fehlen.
- `guild.lua`/`Filters.lua`: ungenutzte lokale `GetCVar`/`SetCVar`/`GetCVarBool`-Upvalues entfernt, die die Toolkit-Wrapper verschattet haben.
- `actionbars.lua`: `NUM_STANCE_SLOTS` gegen `nil` abgesichert; `LibButtonGlow-1.0`-Override-Reihenfolge gefixt — `HideOverlayGlow` war vorher *innerhalb* von `ShowOverlayGlow` definiert und existierte dadurch erst, nachdem `ShowOverlayGlow` mindestens einmal gelaufen war (Fremd-Addons, die zuerst `HideOverlayGlow` aufrufen, bekamen einen nil-Call). Jetzt beide auf oberster Ebene definiert.
- `specandequipBar.lua`: `CreateTexture(..., "ActionBarFlyoutButton-ArrowUp")` entfernt — der dritte Parameter von `CreateTexture` ist ein vererbtes XML-Template, kein Atlas-Name, und konnte beim Laden fehlschlagen. Nachkontrolle ergab, dass der Ersatz den Pfeil komplett unsichtbar ließ; per `pcall(...:SetAtlas(...))` nachgerüstet, damit der Flyout-Pfeil wieder sichtbar ist, ohne bei fehlendem Atlas einen Ladefehler zu riskieren.
- `LibElv-GameMenu-1.0.lua`: `GameMenuButtonHelp`-Referenz (auf Phase 5 umbenannt/entfernt) fällt jetzt auf `GameMenuButtonLogout`/`GameMenuButtonOptions`/feste Maße zurück.

### Nachkontrolle: systematischer Abgleich aller `T.C_*`-Aufrufstellen gegen toolkit.lua

Ausgehend vom oben dokumentierten `GetAddOnEnableState`-Fund wurde derselbe Fehlertyp systematisch für die ganze Codebase gesucht: alle `T.C_*`-Aufrufe in `modules/` und `core/` gegen die tatsächlich in `toolkit.lua` definierten `T.X`-Namen abgeglichen (Diff von ~800 Aufrufstellen gegen ~700 Definitionen), jeder verdächtige Treffer einzeln gegen seine Ladekette (`load_*.xml`) und seinen Aufrufkontext geprüft. Ergebnis: die meisten Treffer waren bereits korrekt mit Existenz-Checks abgesichert oder inaktiver/unerreichbarer Code (auskommentierte XML-Includes, tote lokale Funktionen); die folgenden waren echte, erreichbare Bugs.

- **`core/core.lua`:** `KUI.IsMoP = true` war ein hartkodierter Platzhalter (Kommentar: "oder aus toc/build sauber ableiten"). Ersetzt durch `KUI.IsMoP = E.Mists` — dasselbe von ElvUI bereitgestellte Flag, das im Rest der Codebase bereits ~40-mal verwendet wird, statt eine zweite, abweichende Erkennung einzuführen.
- **`modules/tooltip/tooltip.lua` (kritisch):** `hooksecurefunc("LFGListUtil_SetSearchEntryTooltip", ...)` lief unbedingt auf oberster Code-Ebene der Datei, ohne Enable-Check oder Existenzprüfung. `LFGListUtil_SetSearchEntryTooltip` gehört zum retail-only Premade-Groups-Browser (Legion+) und existiert auf MoP Classic voraussichtlich nicht — `hooksecurefunc` auf eine nicht existente globale Funktion wirft sofort einen Fehler, und zwar *vor* der Definition von `KTT:Initialize()` weiter unten in derselben Datei, was das gesamte Tooltip-Modul bei jedem Login/Reload hätte lahmlegen können. Jetzt mit `if _G.LFGListUtil_SetSearchEntryTooltip then ... end` abgesichert.
- **`modules/quest/questtracker.lua`:** `QT:ChangeState` (läuft bei jedem Kampf-Ein/Austritt und Zonenwechsel) rief `T.C_Garrison_IsPlayerInGarrison(2)`/`(3)` ohne Existenzprüfung auf. Garrison/Order Halls existieren nicht in MoP Classic, der Aufruf war `nil(...)` und crashte bei jedem State-Wechsel des Quest-Trackers. Jetzt mit `T.C_Garrison_IsPlayerInGarrison and ...` abgesichert.
- **`modules/bags/itemselect.lua`:** `IsAppearanceCollected` rief `T.C_TransmogCollection_GetItemInfo`/`GetAppearanceSourceInfo` ungeprüft auf (Transmog-Collection-System ist Legion+, existiert nicht in MoP Classic; der `C_TransmogCollection`-Wrapper in `toolkit.lua` ist bewusst deaktiviert). Reproduzierbarer Crash beim Shift-Klick-Vendor/Delete-Feature auf BoE-Rüstungsteile (Modul standardmäßig aktiviert). Jetzt mit früher Existenzprüfung abgesichert (`return true`, da es auf MoP Classic nichts zu prüfen gibt).
- **`modules/skins/blizzard/guild.lua`:** Tippfehler `T._G.HybridScrollFrame_GetOffset(...)` statt `T.HybridScrollFrame_GetOffset(...)` — `T` hat kein `_G`-Feld, also crashte jeder `GuildRoster_UpdateTradeSkills`-Hook (Gilden-Handwerks-Tab). Korrigiert.
- **`modules/misc/scrapper.lua`:** `local itemLocation = itemLocation or _G.ItemLocation:CreateEmpty()` lief unbedingt beim Laden, unabhängig von Combat/Feature-Verfügbarkeit. Jetzt hinter dem bereits vorhandenen `KUI.Features.ScrappingMachine`-Flag abgesichert.
- **`modules/quest/objectiveprogress.lua`:** Der eigentliche `LOP:GetNPCWeightByCurrentQuests(...)`-Aufruf war auskommentiert, aber die folgende Zeile `if not weightsTable then return end` referenzierte dadurch eine nie gesetzte globale Variable statt eines Locals — funktionierte "zufällig" (immer früher Return), aber unklar und ohne Begründung. Jetzt mit explizitem Kommentar und Guard auf `T.C_TaskQuest_GetQuestInfoByQuestID` (World Quests, nicht in MoP Classic vorhanden) sauber dokumentiert.
- **`core/toolkit.lua`:** `C_PetJournal`-Namespace war Teil der pauschalen "Retail-only"-Deaktivierungsliste, ist aber tatsächlich natives MoP-Content (Pet Battles/Pet Journal seit Patch 5.0.4) — fälschlich mitdeaktiviert. Reaktiviert (`rawget(_G, "C_PetJournal")`) und die 7 tatsächlich verwendeten Methoden verdrahtet (`FindPetIDByName`, `GetPetInfoByIndex`, `GetPetInfoBySpeciesID`, `GetNumCollectedInfo`, `SetAllPetSourcesChecked`, `SetAllPetTypesChecked`, `SetFilterChecked`). Behebt u.a. einen ungeprüften Crash in `modules/misc/options.lua` (AFK-Begleiter-Namensfeld in den Optionen).
- **`core/toolkit.lua`:** `GetActionTexture` und `GetPetActionCooldown` fehlten schlicht in der Wrapper-Tabelle (alte, klassische APIs, kein Retail-Bezug) — betraf `modules/cooldowns/pulseCD.lua` beim Verfolgen von Pet-Actions auf der Pulse-Cooldown-Anzeige. Ergänzt.

Alle geänderten Dateien mit `luac -p` syntaktisch geprüft (keine Fehler).

## 2026-07-09 (Teil 3) - Weitere Nachkontrolle: quest, unitframes-Rest, blizzard, locpanel, armory, addonpanel, raidmarkers

Fortsetzung Datei für Datei. Den `T.C_*`-Abgleich aus Teil 2 auf **alle** `T.X`-Namen ausgeweitet (nicht nur `C_*`), um systematisch nach demselben Fehlertyp zu suchen — keine weiteren echten Treffer über die bereits bekannten (bereits abgesicherten/toten) hinaus.

- **`modules/quest/smartquest.lua`:** `self.areaID = areaID` referenzierte eine nie gesetzte globale Variable statt `T.C_Map_GetBestMapForUnit("player")` neu zu berechnen (wie in der Zeile direkt darüber für `self.inInstance` und wie an der Stelle, die dieselbe Zuweisung ursprünglich schon einmal korrekt macht). Nach einem "Reschedule"-Durchlauf wurde dadurch `self.areaID` auf `nil` gesetzt, was die "aktuelle Zone"-Auto-Tracking-Logik des Smart Quest Trackers verfälscht. Korrigiert.
- **`modules/addonpanel/addonpanel.lua`:** `dialog.text = T..string_format(...)` — Doppelpunkt-Tippfehler: verkettet die Tabelle `T` mit dem Rückgabewert eines nicht existenten globalen `string_format`, garantierter Crash beim Löschen eines Addon-Profils im Addon Control Panel. Korrigiert zu `T.string_format(...)`. Codebase-weit nach demselben Muster (`T..` statt `T.`) gesucht — keine weiteren Treffer.
- Geprüft und für unbedenklich befunden: `modules/blizzard/blizzard.lua`, `modules/locpanel/locpanel.lua` + `tooltip.lua`, `modules/armory/armory.lua` + `icystats.lua`, `modules/raidmarkers/raidmarkers.lua` + `quickmark.lua`, `modules/quest/questannounce.lua` + `questauto.lua`, restliche `modules/unitframes/` (units/, groups/, options.lua), `modules/maps/mail.lua` + `minimaplocation.lua`.

## 2026-07-09 (Teil 4) - reminder/solo.lua nachgezogen, notification/reminder/raid geprüft

- **`modules/reminder/solo.lua`:** Nutzte noch `T.AuraUtil_FindAuraByName`, obwohl `modules/reminder/raid.lua` (siehe Teil 1) bereits dokumentiert, dass `AuraUtil.FindAuraByName` auf diesem Client nicht mehr existiert und durch `C_UnitAuras` ersetzt wurde — `raid.lua` wurde damals umgestellt, `solo.lua` nicht. Jeder Buff-/Debuff-Check im persönlichen Reminder-Modul (`PlayerHasFilteredBuff`/`PlayerHasFilteredDebuff`) war dadurch entweder ein Crash oder (falls `AuraUtil` als leere Dummy-Tabelle durchgereicht wird) ein stiller Totalausfall der Erkennung. Auf dasselbe `C_UnitAuras.GetPlayerAuraBySpellID`/`GetAuraDataByIndex`-Muster wie `raid.lua` umgestellt. Codebase-weit nach verbliebenen `AuraUtil.FindAuraByName`-Aufrufen gesucht — keine mehr vorhanden.
- Geprüft und für unbedenklich befunden: `modules/notification/notification.lua` (bereits durchgängig mit `HasXSupport()`-Guards abgesichert), `modules/reminder/raid.lua` (die Dedup-Fixes aus Teil 1 sind sauber).

## 2026-07-10 - Kritisch: unbedingter Login-Crash in chat/Filters.lua und trade.lua; Options-Menü an Stasis angeglichen

- **`modules/chat/Filters.lua` (kritisch, immer geladen):** `local C_FriendList_IsFriend = C_FriendList.IsFriend` und `local C_BattleNet_GetGameAccountInfoByGUID = C_BattleNet.GetGameAccountInfoByGUID` liefen ungeprüft auf oberster Dateiebene — noch vor jeder Funktion, jedem Feature-Toggle. Falls `C_FriendList`/`C_BattleNet` auf diesem Client fehlen, crasht das bei **jedem einzelnen Login**, für jeden Nutzer, ohne Opt-out (chat/ wird immer geladen). Mit `_G.C_FriendList and _G.C_FriendList.IsFriend` usw. abgesichert, Aufrufstelle in `GetFilterResult` ebenfalls.
- **`modules/skins/blizzard/trade.lua` (kritisch, immer geladen):** identisches Muster — dieselben zwei Zeilen ungeprüft auf Dateiebene, *vor* dem `if E.Mists then return end`-Guard der eigentlichen Style-Funktion weiter unten. Der Guard in der Funktion hat also nie gegriffen, weil der Crash schon beim Laden der Datei passiert wäre. Selbe Absicherung angewendet.
- Codebase-weit nach demselben Muster gesucht (`local X = C_Namespace.Method` bzw. `_G.C_Namespace.Method` ohne Existenzprüfung, auf oberster Dateiebene) — alle weiteren Treffer waren entweder bereits abgesichert (z.B. `local C_Foo = _G.C_Foo or {}` eine Zeile darüber) oder in bereits deaktivierten/nicht geladenen Dateien (worldquests/, auskommentierte skins/blizzard-Einträge).

### Options-Menü an Stasis-Entscheidungen angeglichen

Neue Vorgabe: wenn eine Funktion in Stasis gesetzt/deaktiviert wird und dazu eine Option im Menü existiert, muss diese Option ausgeblendet oder ausgegraut werden — sonst wirkt sie im Options-Menü aktiv, tut aber nichts.

- `modules/quest/options.lua`: "Objective Progress"-Toggle (hängt an `C_TaskQuest`, existiert nicht auf MoP Classic) jetzt mit `disabled`/`hidden = function() return E.Mists end` versehen, Beschreibungstext erklärt warum.
- `modules/skins/options.lua`: sechs Blizzard-Skin-Toggles (`character`, `talent`, `raid`, `minimap`, `trainer`, `trade`) hatten bereits seit früheren Sessions ein `if E.Mists then return end` in ihrer jeweiligen Style-Funktion (`modules/skins/blizzard/*.lua`), das Options-Menü zeigte sie aber weiterhin als aktivierbar an. Alle sechs jetzt mit `E.Mists`-`disabled`/`hidden` versehen, konsistent mit dem bereits vorhandenen Muster beim Scrapper-Azerite-Toggle.

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
