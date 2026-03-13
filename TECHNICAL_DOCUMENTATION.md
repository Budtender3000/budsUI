# budsUI

<div align="center">
  <img src="budsUI/Media/assets/budsui_logo.png" alt="budsUI Logo" width="400">
</div>

Ein vollständiger UI-Ersatz für **World of Warcraft 3.3.5 (Wrath of the Lich King)**, speziell entwickelt für den [Ascension.gg](https://ascension.gg) classless Server.

**Basiert auf [KkthnxUI](https://github.com/kkthnx-wow/KkthnxUI) von Josh "Kkthnx" Russell & Shestak**  
**Port & Anpassung von [Budtender3000](https://github.com/Budtender3000)**

---

## ⚠️ Entwicklungsstatus

> **Version 0.3.0 — Aktive Entwicklung**

- Sporadisch getestet; kann Bugs und unerwartetes Verhalten enthalten
- Features und APIs können sich ändern
- Sichere immer deinen `WTF/`-Ordner vor Updates
- Bugs bitte via [GitHub Issues](https://github.com/Budtender3000/budsUI/issues) melden

---

## Was ist budsUI?

budsUI ersetzt und erweitert nahezu alle Standard-UI-Elemente von Blizzard: UnitFrames, ActionBars, Chat, Tooltips, Minimap, Buffs, Loot-System und mehr. Es bietet ein modernes, anpassbares Interface mit **~100 Konfigurationsoptionen** über **20+ Modulgruppen**.

**Das Problem:** Blizzards Standard-UI ist veraltet, unflexibel und nicht für moderne Spielstile optimiert.  
**Die Lösung:** budsUI modernisiert das Interface und fügt Quality-of-Life-Features hinzu.

---

## Features im Überblick

| Kategorie | Was es macht |
|---|---|
| **Unit Frames** | Anpassungen an Blizzard Player/Target/Focus/Party/Pet/Arena Frames (standardmäßig deaktiviert) |
| **Action Bars** | 5 Custom-Bars + Pet + Shapeshift + Totem mit Range-Färbung & Cooldown-Text |
| **Chat** | Restyled Chat-Frames, Copy-Chat/URL, Filter, Sounds, TellTarget |
| **Tooltips** | Item-Level, Spell-ID, PvP-Rating, Instance-Lock-Info und mehr |
| **Buffs** | Restyled Buff-Frame mit Aura-Source-Tracking und Klassen-Farb-Borders |
| **Maps** | Minimap-Styling, FarmMode, Rechtsklick-Menü, Button-Collector |
| **Loot** | Auto-Confirm, Auto-Greed, Group-Loot, Loot-Filter |
| **Skins** | Blizzard & Third-Party-Frame-Skins (DBM, Recount, Skada, WeakAuras) |
| **Misc** | AFK-Kamera, Durability-Warnung, Aura-Tracker (Filger), PulseCD |
| **Automation** | Auto-Invite, Auto-Release, Decline-Duel, Combat-Logging, Auto-Repair/Sell-Greys |
| **Announcements** | Interrupt/Sapped/Pull-Countdown-Ankündigungen, Feast & Portal-Alerts |
| **Data Text** | Battleground-, Standort- und Stats-Info-Bars |
| **Klassen-Module** | Hunter-Utilities, Shaman Maelstrom Weapon Counter |
| **Konfiguration** | In-Game-GUI via `budsUI_Config` (optionales Companion-Addon) |


## Installation

1. Lade die neueste Version von [GitHub Releases](https://github.com/Budtender3000/budsUI/releases) herunter
2. Entpacke die ZIP-Datei und kopiere **beide** Unterordner in dein AddOns-Verzeichnis:
   ```
   World of Warcraft/Interface/AddOns/budsUI/
   World of Warcraft/Interface/AddOns/budsUI_Config/
   ```
3. Starte das Spiel und logge dich ein — ein Installations-Wizard läuft automatisch beim ersten Login
4. Nutze `/buds` um das Konfigurations-Panel jederzeit zu öffnen

> **Wichtig:** Konfigurations-Änderungen erfordern einen UI-Reload (`/rl`) — es gibt kein Runtime-Toggle-System.

### Mindestanforderungen

- **Bildschirmbreite:** Mindestens 1200px (das Addon deaktiviert sich automatisch bei kleineren Auflösungen)
- **WoW-Version:** 3.3.5 (Wrath of the Lich King)
- **Server:** Optimiert für Ascension.gg classless Server

---

## Slash-Commands

| Command | Beschreibung |
|---|---|
| `/buds` · `/uihelp` | Konfigurations-GUI öffnen / Hilfe anzeigen |
| `/rl` · `/reloadui` | UI neu laden |
| `/rc` | Ready Check durchführen |
| `/gm` | GM-Ticket/Hilfe-Frame öffnen |
| `/boost` · `/boostui` | Video-Einstellungen auf Minimum (Performance-Modus) |
| `/align` · `/grid` | Alignment-Grid umschalten (Positionierungs-Hilfe) |
| `/luaerror on\|off` | Lua-Error-Anzeige umschalten |
| `/rd` | Gruppe auflösen |
| `/ss` · `/spec` | Spezialisierung wechseln |
| `/toraid` · `/convert` | Party zu Raid konvertieren |
| `/teleport` | In/aus Instanz teleportieren |
| `/cc` · `/clearchat` | Chat-Fenster leeren |
| `/resetui` | UI auf Defaults zurücksetzen |
| `/installui` | Installations-Wizard erneut ausführen |
| `/addons` | Addon-Liste öffnen |
| `/moveui` | Frame-Movers umschalten (Drag-to-Reposition) |
| `/moveui reset` | Alle Frame-Positionen zurücksetzen |
| `/frame` | Frame-Inspector (Name, Parent, Size, Strata) |
| `/framelist` | Frame-Stack-Inspector mit Chat-Copy-Support |
| `/texlist` | Texturen auf Frame unter Cursor auflisten |
| `/patch` · `/version` | Game-Version und Build-Info anzeigen |

---

## Architektur

### Engine-Pattern (`Core/Init.lua`)

Alle 82 Lua-Dateien teilen sich einen gemeinsamen Namespace über ein "Engine"-Objekt:

```lua
local K, C, L, _ = select(2, ...):unpack()
```

| Variable | Typ | Zweck |
|---|---|---|
| `K` | Frame | Der "Kernel" — Event-Bus, Utilities, Spieler-Info. Auch ein echtes `CreateFrame("Frame")` das Events empfängt. |
| `C` | Table | Config — alle Settings aus `Config/Settings.lua` |
| `L` | Table | Locale-Strings (enUS / deDE) |
| `_` | Table | Taint-Prevention-Slot (ungenutzte Globals) |

Der globale Alias `budsUI = Engine` ermöglicht externen Addons Zugriff auf die Engine. Spieler-Daten werden direkt am Kernel gespeichert: `K.Name`, `K.Class`, `K.Realm`, `K.Color`, `K.Version`, `K.ScreenWidth`, etc.

### Ladereihenfolge (`budsUI.xml`)

Die Ladereihenfolge ist **implizit** — es gibt kein explizites Dependency-System. Die XML-Datei bestimmt die exakte Sequenz (82 Lua-Dateien):

1. `Core/Init.lua` — Engine-Bootstrap
2. Locales (enUS, deDE)
3. Config (Settings, Positions, Fonts, Profiles)
4. `Core/GUI.lua`, `Core/PixelPerfect.lua`
5. Interne Libs (oGlow, LibStub, CallbackHandler-1.0, LibSharedMedia-3.0)
6. `Media/Media.lua`, `Core/Colors.lua`
7. Config-Filter-Tabellen (Announcements, ChatSpam, Errors, FilgerSpells, Nameplates, NeedItems)
8. Core-Module (API, Functions, Animation, Install, Disable, Commands, WTF, Kill, CheckVersion, Border, Developer, Panels, Temp)
9. Feature-Module (UnitFrames, Misc, ActionBars, Announcements, Automation, Blizzard, Buffs, Chat, Class, DataText, Loot, Maps, Quests, Skins, Tooltip)
10. `Core/Movers.lua` — **muss zuletzt laden** (benötigt alle Frame-Anchors)


### Konfiguration (`Config/Settings.lua`)

Alle Einstellungen sind statische Lua-Tabellen unter `C["ModuleName"]` (~100 Optionen über 20+ Gruppen). Ein UI-Reload ist erforderlich, damit Änderungen wirksam werden.

**SavedVariables:**

| Variable | Scope | Zweck |
|---|---|---|
| `SavedOptions` | Global | Addon-weite Optionen |
| `SavedOptionsPerChar` | Per-Character | Install-Flag, AutoInvite, BarsLocked, SplitBars, etc. |
| `SavedPositions` | Per-Character | Frame-Positionen (Mover-System) |
| `GUIConfigSettings` | Global (budsUI_Config) | GUI-Config-Overrides |
| `GUIConfig` | Per-Char (budsUI_Config) | Character-spezifische GUI-Overrides |
| `GUIConfigAll` | Global (budsUI_Config) | Per-Realm/Per-Char-Toggle-Matrix |

### API-Erweiterung (`Core/API.lua`)

Injiziert Hilfsmethoden in **alle** existierenden Blizzard-Frame-Objekte via Metatable-Erweiterung (mittels `EnumerateFrames()`). Wichtige Ergänzungen:

- **Layout-Helfer:** `SetOutside()`, `SetInside()`
- **Visuals:** `CreateBackdrop()`, `CreateBorder()`, `CreateOverlay()`, `CreatePixelShadow()`, `SetTemplate()`
- **Utilities:** `FontString()`, `Kill()`, `StripTextures()`, `StyleButton()`, `CreatePanel()`

> **⚠ Warnung:** Dies ist eine globale Metatable-Modifikation. Jedes andere Addon, das Methoden mit denselben Namen definiert (`Kill`, `SetTemplate`, `StripTextures`, etc.), wird kollidieren.

### Utility-Bibliothek (`Core/Functions.lua`)

| Funktion | Beschreibung |
|---|---|
| `K.ShortValue(n)` | Formatiert große Zahlen (1k, 1m; 万/亿 für zh-CN) |
| `K.RGBToHex(r,g,b)` | Konvertiert RGB zu Hex-Farbstring |
| `K.FormatMoney(copper)` | Formatiert Kupfer zu g/s/c |
| `K.GetTimeInfo(s)` | Konvertiert Sekunden zu Tage/Stunden/Minuten/Sekunden |
| `K.Delay(delay, func)` | Verzögerter Funktionsaufruf via OnUpdate-Frame |
| `K.Round(n, dec)` | Rundet auf Dezimalstellen |
| `K.ShortenString(str, n, dots)` | UTF-8-aware String-Kürzung |
| `K.CheckChat(warning)` | Bestimmt korrekten Chat-Kanal (RAID/PARTY/SAY) |
| `CheckRole()` | Auto-Erkennung der Spielerrolle (Tank/Melee/Caster) via Buffs & Stats |
| `K.Mult` | Pixel-Perfect-Scale-Multiplikator (`768 / screenHeight / UIScale`) |

### Addon-Konflikt-Erkennung (`Core/Disable.lua`)

budsUI deaktiviert automatisch eigene Features, wenn konkurrierende Addons erkannt werden:

| Feature | Deaktiviert wenn diese Addons geladen sind |
|---|---|
| Minimap | SexyMap, wMinimap |
| Unit Frames | Stuf, PitBull4, ShadowedUnitFrames, XPerl |
| Nameplates | TidyPlates, Aloft, dNamePlates, caelNamePlates |
| Action Bars | Dominos, Bartender4, RazerNaga |
| Bags | AdiBags, ArkInventory, cargBags, Bagnon, Combuctor, TBag, BaudBag |
| Chat | Prat-3.0, Chatter |
| Tooltip | TipTac, FreebTip, bTooltip, PhoenixTooltip, Icetip, rTooltip |
| Misc | QuestHelper, GnomishVendorShrinker, AlreadyKnown, BadBoy, NiceBubbles, ChatSounds, Doom_CooldownPulse |

---

## Module im Detail

### ActionBars (16 Dateien)
Vollständiges Custom-ActionBar-System (Bar 1–5, Pet, Shapeshift, Totem) mit Range-Färbung, Cooldown-Text, Hotkey-Anzeige und Split-Bar-Layout-Option.

**Features:**
- State-Driver-System für automatischen Bar-Wechsel basierend auf Klasse/Form/Bonus-Bar
- Out-of-Range-Färbung (rot), Out-of-Mana-Färbung (blau)
- Cooldown-Text-Overlay auf allen Buttons
- Toggle-Modus für Bar-Visibility

### Announcements (6 Dateien)
Situationsabhängige Chat-Ankündigungen:
- **BadGear:** Warnt bei schlechter Ausrüstung
- **FeastsAndPortals:** Ankündigung von Festmahlen & Portalen
- **Interrupt:** Interrupt-Ankündigungen
- **PullCountdown:** Pull-Countdown
- **SaySapped:** "Ich bin gesappt"-Nachricht
- **Spells:** Spell-Cast-Ankündigungen

Nutzt `K.CheckChat()` für automatische Kanal-Wahl (RAID/PARTY/SAY).

### Automation (7 Dateien)
- **AutoInvite:** Auto-Invite bei Keyword (default: "inv")
- **AutoRelease:** Auto-Release bei Tod
- **DeclineDuel:** Automatisches Ablehnen von Duellen
- **LoggingCombat:** Automatisches Combat-Logging
- **Screenshots:** Auto-Screenshots bei Achievements
- **SellGreyRepair:** Auto-Verkauf grauer Items + Auto-Repair (Guild-Bank-Support)
- **TabBinder:** Tab-Taste für Target-Switching


### Blizzard (14 Dateien)
Reskinning von Blizzard-Frames: Achievements, Bags, CombatText, DarkTextures, Durability, Errors, ExpBar, Fonts, Nameplates und mehr.

**Besonderheiten:**
- **BlizzBugsSuck.lua:** Fixes für bekannte Blizzard-Client-Bugs
- **DarkTextures:** Dunkle Texturen für UI-Elemente
- **Errors:** Error-Message-Filtering (Black/White-List)

### Buffs (2 Dateien)
- **AuraSource:** Zeigt Quelle von Buffs/Debuffs (CastBy)
- **BuffFrame:** Restyled Buff-Frame mit Klassen-Farb-Borders

### Chat (9 Dateien)
- **ChatFrames:** Restyling der Chat-Frames
- **ChatTabs:** Tab-Styling
- **CopyChat:** Chat-Kopier-Funktion
- **CopyUrl:** URL-Erkennung und Kopier-Funktion
- **Filters:** Spam-Filter
- **MouseScroll:** Mausrad-Scrolling
- **Sounds:** Chat-Sounds (Whisper, etc.)
- **SpamageMeters:** Damage-Meter-Spam-Filter
- **TellTarget:** `/tt`-Command für Tell-to-Target

### Class (2 Dateien)
- **Hunter.lua:** Hunter-Utilities
- **Shaman.lua:** Maelstrom Weapon Stack-Counter
  - Custom-Animationen: Pop, Pulse, Fade-Out
  - 10 Texturen: maelstrom1.blp bis maelstrom10.blp (eine pro Stack)
  - Blizzard-Overlay-Suppression: Unterdrückt Blizzards Spell-Activation-Overlay
  - Konfigurierbar: Größe, Pulse-Threshold (default: 5 Stacks)
  - **⚠️ Ascension-spezifisch:** Lädt für alle Klassen wegen Ascension's classless System
  - Spell-ID: 1153817 (Ascension: Maelstrom Weapon)

### DataText (3 Dateien)
- **Battleground:** BG-Stats
- **Location:** Standort-Info
- **Stats:** Performance/Stats-Daten (FPS, Latenz, etc.)

### Loot (6 Dateien)
- **AutoConfirm:** Auto-Confirm für BoP-Items
- **AutoGreed:** Auto-Greed
- **GroupLoot:** Group-Loot-Frames
- **Loot:** Loot-Frame-Restyling
- **LootFilter:** Loot-Filter
- **MasterLoot:** Master-Loot-Utilities

### Maps (5 Dateien)
- **MiniMap:** Minimap-Restyling
- **ButtonCollect:** Sammelt Minimap-Buttons in einem Dropdown
- **FarmMode:** Vergrößerte Minimap für Farming
- **RightClick:** Rechtsklick-Menü
- **WhoPinged:** Zeigt an, wer auf Minimap gepingt hat

### Misc (18 Dateien)
- **AFKSpin:** AFK-Kamera-Rotation
- **AlreadyKnown:** Item-Overlay für bereits bekannte Rezepte/Pets/Mounts
- **Durability:** Durability-Warnung
- **Filger:** Aura-Tracker (Buff/Debuff/Cooldown-Tracking)
  - Basiert auf Filger by Nils Ruesch (editors: Affli/SinaC/Ildyria)
  - Konfigurierbar: Buff-Size, Cooldown-Size, PvP-Size, Test-Mode
  - Filter-Tabellen: `Config/Filters/FilgerSpells.lua`
- **GarbageCollect:** Automatische Garbage-Collection
- **PulseCD:** Cooldown-Flash-Animation bei Spell-Procs
- **SlotItemLevel:** Item-Level auf Slots
- **SpeedyLoad:** Schnelleres Addon-Laden
- **WarmaneAHFix:** Fix für Warmane-Auktionshaus

### Quests (4 Dateien)
- **AutoCollapse:** Auto-Collapse von Quest-Log
- **QuestLog:** Quest-Log-Enhancements
- **WatchFrame:** Quest-Tracker-Improvements
- **WowheadLink:** Wowhead-Link-Generator

### Skins (via XML-Includes)
- **Addon-Skins:** DBM, Recount, Skada, Spy, WeakAuras
- **Blizzard-Skins:** Verschiedene Blizzard-Frames

### Tooltip (12 Dateien)
- **Achievement:** Achievement-Tooltips
- **HyperLink:** HyperLink-Preview
- **InstanceLock:** Instance-Lock-Info
- **ItemCount:** Item-Count in Tooltip
- **ItemIcons:** Item-Icons in Tooltip
- **ItemLevel:** Item-Level in Tooltip
- **MultiItemRef:** Multi-Item-Ref-Support
- **PvPRating:** PvP-Rating in Tooltip
- **SpellID:** Spell-ID in Tooltip
- **Talents:** Talent-Info in Tooltip
- **Tooltip.lua:** Haupt-Tooltip-Restyling

### UnitFrames (7 Dateien)
- **⚠️ STANDARDMÄSSIG DEAKTIVIERT:** `C.Unitframe.Enable = false` in Settings.lua
- **Auras:** Aura-Anzeige auf UnitFrames
- **CastBars:** Castbar-Styling
- **EnhancedFrames:** Erweiterte Frame-Features
- **HealthMinMax:** Min/Max-Health-Anzeige
- **Layout.lua:** Kern des UnitFrame-Systems
- **PowerBar:** PowerBar-Styling
- **SmoothBars:** Smooth-Bar-Animationen
- **⚠️ Filger wird automatisch deaktiviert wenn UnitFrames aus sind**


---

## Abhängigkeiten

### Gebündelte Bibliotheken (`Libs/`)

| Bibliothek | Zweck |
|---|---|
| `LibStub` | Standard-Addon-Library-Management |
| `CallbackHandler-1.0` | Event-System für Libraries |
| `LibSharedMedia-3.0` | Shared Fonts & Texture Registry |
| `oGlow` | Item-Quality-Glow-Effekte (Taschen, Bank, etc.) |

**oGlow-Architektur:** Pipe-Filter-Display-Pattern
- **Pipes:** Bag, Bank, Char, GBank, Inspect, Loot, Mail, Merchant, Trade, TradeSkill
- **Filters:** Quality (Item-Qualität)
- **Displays:** Border (Glow-Border um Items)

### Optionale externe Addons

**budsUI_Config** (stark empfohlen)
- Zweck: In-Game-Config-GUI
- SavedVariables: `GUIConfigSettings` (global), `GUIConfig` (per-char), `GUIConfigAll` (global)
- **⚠️ Nicht im Repo:** Separates Addon, nicht Teil von budsUI

**Erkannte & integrierte Addons:**
- **Blizzard:** `Blizzard_CombatText`, `Blizzard_DebugTools`
- **Skins:** `CLCRet`, `DBM-Core`, `Recount`, `Skada`, `Spy`, `WeakAuras`
- **Profile-Config:** Grid, Bartender4, ButtonFacade, ThreatPlates, ClassTimer, Nameplates (via `Core/WTF.lua`)

---

## Bekannte Probleme & Einschränkungen

### Bestätigte Bugs

> Aktuell keine High-Priority-Bugs bestätigt. [Bugs via GitHub Issues melden](https://github.com/Budtender3000/budsUI/issues).

### Wichtige Hinweise

1. **UnitFrames standardmäßig deaktiviert** — `C.Unitframe.Enable = false` in `Config/Settings.lua`. Muss manuell aktiviert werden. (Filger wird automatisch deaktiviert wenn UnitFrames aus sind.)

2. **Metatable-Injection** (`Core/API.lua`) — Methoden werden global über alle Frames injiziert. Kann mit anderen Addons kollidieren, die dieselben Methodennamen verwenden.

3. **Frame-Enumeration beim Laden** — `Core/API.lua` durchläuft alle existierenden Frames beim Laden. Kann die Ladezeit in Umgebungen mit vielen Frames erhöhen.

4. **Lua-Errors standardmäßig versteckt** — Der Installer setzt `scriptErrors=0`. Nutze `/luaerror on` während der Entwicklung.

5. **`K.Delay` Memory-Note** — Active Cleanup ist implementiert; gecancelte Delays werden sofort aus der `waitTable` entfernt.

6. **WTF.lua Profile-Keys** — Profile-Keys werden dynamisch basierend auf `UnitName` und `GetRealmName` generiert. Bei Realm-Umbenennungen können Profile verloren gehen.

7. **`CheckRole()` ist heuristisch** — Rollen-Erkennung nutzt Stat-Vergleich und Buff-Checks. Hybrid-Klassen können falsch erkannt werden. Registriert `UNIT_AURA` global (feuert bei jedem Aura-Update).

8. **Kein Error-Handling** — Fast kein `pcall`-Usage im gesamten Addon. Ein einzelner Lua-Error in kritischen Dateien kann kaskadieren.

9. **Settings nur nach Reload aktiv** — Es gibt kein Runtime-Toggle-Mechanismus. Jede Änderung erfordert `/rl`.

10. **Screen-Width-Check** — Addon deaktiviert sich komplett wenn `K.ScreenWidth < 1200`. Keine Warnung vorher.

### Besonderheiten & Hacks

**Metatable-Injection (Core/API.lua)**
- Globale Frame-Erweiterung: Alle existierenden Frames werden via `EnumerateFrames()` durchlaufen und mit Custom-Methoden erweitert
- **⚠️ RISIKO:** Andere Addons mit gleichen Methodennamen kollidieren
- **Performance-Impact:** Frame-Enumeration beim Laden erhöht Ladezeit

**Delay-System (Core/Functions.lua)**
- `K.Delay(delay, func)`: Verzögerte Funktionsaufrufe via OnUpdate-Frame
- `waitTable`: Globale Tabelle für alle verzögerten Aufrufe
- Active Cleanup: Gecancelte Delays werden sofort aus waitTable entfernt

**Role-Detection (Core/Functions.lua)**
- Heuristisch: Erkennt Rolle (Tank/Melee/Caster) via Buff-Checks & Stat-Vergleich
- Tank-Detection: Paladin (Righteous Fury), Warrior (Defensive Stance), DK (Frost Presence), Druid (Bear Form)
- Melee vs Caster: Vergleicht Attack-Power vs Intellect
- **⚠️ PROBLEM:** Hybrid-Klassen können falsch erkannt werden

**Shaman Maelstrom Weapon Tracker (Modules/Class/Shaman.lua)**
- Blizzard-Overlay-Suppression: Hookt `SpellActivationOverlayFrame.ShowOverlay` um Blizzards Overlay zu unterdrücken
- Texture-Switching: Zeigt nur die aktuelle Stack-Texture (1-10), versteckt alle anderen
- Animationen: Pop (bei Stack-Erhöhung), Pulse (bei 5+ Stacks), Fade-Out (bei 0 Stacks)
- **⚠️ Ascension-spezifisch:** Spell-ID 1153817 ist Ascension-spezifisch

**Auto-Repair & Sell-Grey (Modules/Automation/SellGreyRepair.lua)**
- Guild-Bank-Support: Nutzt Guild-Bank für Repair wenn verfügbar und Gruppe > 5 Spieler
- Item-Rarity-Check: Verkauft nur Items mit `itemRarity == 0` (grau)
- **⚠️ Keine Fehlerbehandlung:** Kein `pcall` - Fehler bei GetItemInfo können crashen


---

## Wichtige Dateien-Referenz

| Datei | Priorität | Beschreibung |
|---|---|---|
| `Core/Init.lua` | ⭐⭐⭐ | Engine-Bootstrap — hier starten |
| `Core/API.lua` | ⭐⭐⭐ | Alle wiederverwendbaren Frame-Methoden (Metatable-Injection) |
| `Core/Functions.lua` | ⭐⭐⭐ | Utility-Bibliothek |
| `Config/Settings.lua` | ⭐⭐⭐ | Alle Konfigurationsoptionen (~100 Settings) |
| `Config/Positions.lua` | ⭐⭐ | Pixel-genaue Frame-Positionen |
| `Core/Install.lua` | ⭐⭐ | Erst-Installation & SavedVariables |
| `Core/Commands.lua` | ⭐⭐ | Alle Slash-Commands |
| `Core/Disable.lua` | ⭐⭐ | Addon-Konflikt-Erkennung & Feature-Toggles |
| `Core/Movers.lua` | ⭐⭐ | Frame-Positionierungs-GUI (muss zuletzt laden) |
| `Modules/UnitFrames/Layout.lua` | ⭐⭐ | Kern des UnitFrame-Systems |
| `budsUI.xml` | ⭐⭐ | Ladereihenfolge = implizite Dependencies |
| `Core/WTF.lua` | ⭐ | Third-Party-Addon-Profil-Konfiguration |

---

## Projekt-Umfang

- **Gesamtgröße:** ~15.000–20.000 Zeilen Lua über 82 Dateien
- **Interface-Level:** `30300` (WoW 3.3.0 / WotLK)
- **Locales:** English (enUS), German (deDE)
- **Herkunft:** Fork von KkthnxUI angepasst für Ascension.gg's classless Server

---

## Konfiguration

### Config-Struktur

Alle Einstellungen befinden sich in `Config/Settings.lua` und sind in folgende Gruppen organisiert:

- **Media:** Farben, Fonts, Texturen, Sounds
- **ActionBar:** ButtonSize, ButtonSpace, BottomBars, RightBars, etc.
- **Announcements:** Bad_Gear, Feasts, Interrupt, etc.
- **Automation:** AutoInvite, DeclineDuel, LoggingCombat, etc.
- **Bag:** BagColumns, BankColumns, ButtonSize, etc.
- **Blizzard:** Capturebar, ClassColor, DarkTextures, etc.
- **Aura:** BuffSize, CastBy, ClassColorBorder, etc.
- **Chat:** Height, Width, Fading, Filter, etc.
- **Cooldown:** FontSize, Threshold, etc.
- **Error:** Black, White, Combat
- **Filger:** BuffsSize, CooldownSize, PvPSize, TestMode, etc.
- **General:** AutoScale, UIScale, WelcomeMessage, DeveloperMode, etc.
- **Loot:** ConfirmDisenchant, AutoGreed, LootFilter, etc.
- **Minimap:** CollectButtons, Ping, Size, etc.
- **Misc:** AFKCamera, AlreadyKnown, Armory, etc.
- **Nameplate:** Height, Width, AuraSize, Combat, etc.
- **PowerBar:** Combo, Maelstrom, Mana, Rage, Rune, etc.
- **PulseCD:** Size, Sound, AnimationScale, Threshold, etc.
- **Skins:** Spy, ChatBubble, CLCRet, DBM, Recount, Skada, WeakAuras, etc.
- **Tooltip:** Scale, Achievements, Cursor, ItemLevel, SpellID, Talents, etc.
- **Unitframe:** ComboFrame, SmoothBars, CastBarScale, Enable, etc.
- **MoverPositions:** Frame-Positionen

### Profil-System

Das Profil-System (`Config/Profiles.lua`) unterstützt:
- **Per-Class-Config:** Überschreibt General-Config
- **Per-Character-Name-Config:** Überschreibt General & Class
- **Per-Max-Level-Config:** Überschreibt General, Class & Name
- **Budtender-Preset:** `Config/BudtenderPreset.lua` (hardcoded Preset)

**⚠️ Aktuell leer:** Nur Platzhalter-Code, keine aktiven Overrides.

### Frame-Positionierung

Das Mover-System (`Core/Movers.lua`) ermöglicht Drag-and-Drop-Positionierung von 27 UI-Elementen:
- ActionBars, Buffs, Minimap, UnitFrames, Castbars, PowerBar, etc.
- Positionen werden in `SavedPositions` (per-char) gespeichert
- `/moveui` aktiviert Movers, `/moveui reset` setzt zurück
- **⚠️ Combat-Lock:** Funktioniert nicht im Kampf

---

## Verwendung

### Erste Schritte

1. **Installation:** Folge den Installations-Anweisungen oben
2. **Wizard:** Beim ersten Login läuft der Installations-Wizard automatisch
3. **Konfiguration:** Öffne `/buds` für die Config-GUI (erfordert `budsUI_Config`)
4. **Anpassung:** Nutze `/moveui` um UI-Elemente zu verschieben
5. **Reload:** Nach Änderungen immer `/rl` ausführen

### Wichtige Befehle für den Alltag

- `/rl` — UI neu laden nach Config-Änderungen
- `/moveui` — UI-Elemente verschieben
- `/align` — Grid für präzise Positionierung
- `/buds` — Config-GUI öffnen

### Tipps & Tricks

- **Performance-Modus:** `/boost` setzt Video-Einstellungen auf Minimum
- **Frame-Debugging:** `/frame` zeigt Info über Frame unter Cursor
- **Chat kopieren:** Rechtsklick auf Chat-Tab für Copy-Funktion
- **Auto-Invite:** Flüstere "inv" (oder konfiguriertes Keyword) für Auto-Invite
- **Auto-Repair:** Öffne Händler mit Guild-Bank-Zugriff für Auto-Repair via Guild-Bank


---

## Entwicklung & Beitragen

### Code-Qualität

**Stärken:**
- Umfangreiches Feature-Set (~100 Konfigurationsoptionen)
- Gute Addon-Konflikt-Erkennung
- Pixel-Perfect-Scaling
- Flexible Frame-Positionierung
- Gut gepflegter CHANGELOG

**Schwächen:**
- Kein Error-Handling (fast kein `pcall`)
- Metatable-Injection-Risiko
- Implizite Dependencies (nur XML-Reihenfolge)
- Wenig Dokumentation
- Keine Tests
- Inkonsistente Namenskonventionen

**Kritische Bereiche:**
- `Core/API.lua` (Metatable-Injection)
- `Core/Functions.lua` (CheckRole UNIT_AURA-Spam)
- `Core/Init.lua` (Engine-Bootstrap)
- Ladereihenfolge (XML-basiert, fehleranfällig)

### Verbesserungspotenzial

1. **Error-Handling:** `pcall` für kritische Funktionen
2. **Abstraktion:** Bar1-5 in generische Bar-Factory abstrahieren
3. **Dokumentation:** Inline-Docs, API-Docs, Developer-Guide
4. **Tests:** Unit-Tests für Core-Funktionen
5. **Lokalisierung:** Alle Strings lokalisieren, Fallback implementieren
6. **Profil-System:** Vollständiges Profil-System mit Import/Export
7. **Runtime-Toggles:** Einige Settings ohne Reload änderbar machen
8. **Dependency-System:** Explizite Dependencies statt XML-Reihenfolge
9. **Modularisierung:** Klarere Modul-Trennung, weniger globaler State
10. **Performance:** UNIT_AURA-Spam reduzieren, Throttling implementieren

### Beitragen

Beiträge sind willkommen! Bitte beachte:

1. **Fork & Pull Request:** Fork das Repo, mache deine Änderungen, erstelle einen Pull Request
2. **Code-Style:** Versuche den bestehenden Code-Style beizubehalten
3. **Testing:** Teste deine Änderungen gründlich auf Ascension.gg
4. **Dokumentation:** Aktualisiere README.md und CHANGELOG.md
5. **Issues:** Nutze GitHub Issues für Bug-Reports und Feature-Requests

### Entwickler-Modus

Aktiviere den Developer-Mode in `Config/Settings.lua`:

```lua
C.General.DeveloperMode = true
```

Dies aktiviert:
- Lua-Error-Anzeige
- Zusätzliche Debug-Ausgaben
- Frame-Inspector-Tools

---

## Performance-Überlegungen

### Optimierungen

- **Metatable-Injection:** Einmalig beim Laden, danach kein Overhead
- **Delay-System:** Optimiert mit Active Cleanup
- **Frame-Enumeration:** Kann bei vielen Frames langsam sein

### Bekannte Performance-Probleme

- **UNIT_AURA-Spam:** `CheckRole()` registriert global, feuert oft
- **oGlow:** Pipe-Filter-System ist relativ komplex für einfache Funktionalität
- **Viele aktive Delays:** Können Memory-Overhead verursachen

### Wartbarkeit

- **Monolithische Struktur:** 82 Dateien, keine klare Modul-Trennung
- **Implizite Dependencies:** Nur XML-Reihenfolge, keine explizite Deklaration
- **Globaler State:** Viel globaler State in `K`, `C`, `L`
- **Schwer zu testen:** Keine Unit-Tests, keine Test-Infrastruktur
- **Schwer zu erweitern:** Neue Features erfordern oft Änderungen in mehreren Dateien

---

## Sicherheit & Taint

- **Protected-Frame-Checks:** `if object:IsProtected() then return end` in API.lua
- **Taint-Prevention-Slot:** `_` in Engine-Unpacking
- **⚠️ Metatable-Injection-Risiko:** Kann Taint verursachen wenn nicht vorsichtig
- **⚠️ Keine Sandbox:** Kein Schutz vor bösartigem Code in Config-Dateien

---

## Lokalisierung

- **2 Locales:** enUS (English), deDE (German)
- **L-Table:** Alle Strings in `Locales/enUS.lua`, `Locales/deDE.lua`
- **⚠️ Unvollständig:** Viele Strings sind hardcoded, nicht lokalisiert
- **⚠️ Keine Fallback:** Wenn String fehlt, wird nil angezeigt

---

## Ascension.gg-Spezifika

- **Classless-Support:** Shaman-Modul lädt für alle Klassen
- **Custom-Spell-IDs:** Maelstrom Weapon = 1153817 (Ascension-spezifisch)
- **⚠️ Nicht portierbar:** Code ist stark auf Ascension zugeschnitten

---

## Credits

- **Original UI:** [KkthnxUI](https://github.com/kkthnx-wow/KkthnxUI) von Josh "Kkthnx" Russell & Shestak
- **3.3.5 Port & Anpassung:** [Budtender3000](https://github.com/Budtender3000)
- **Filger:** Basiert auf Filger by Nils Ruesch (editors: Affli/SinaC/Ildyria)
- **oGlow:** Item-Quality-Glow-Library

### Lizenzen

Dieses Projekt ist unter der **MIT-Lizenz** lizenziert. budsUI ist ein abgeleitetes Werk von KkthnxUI und behält die ursprüngliche MIT-Lizenz bei.

Siehe `Licenses/`-Ordner für vollständige Lizenz-Texte:
- `Licenses/KkthnxUI` — Original KkthnxUI-Lizenz
- `Licenses/ShestakUI` — ShestakUI-Lizenz
- `Licenses/TukUI` — TukUI-Lizenz
- `Licenses/ElvUI` — ElvUI-Lizenz
- `Licenses/oUF` — oUF-Lizenz

---

## Support

- **GitHub:** [Budtender3000/budsUI](https://github.com/Budtender3000/budsUI)
- **Issues:** [Bug-Reports via GitHub Issues](https://github.com/Budtender3000/budsUI/issues)
- **Changelog:** Siehe [CHANGELOG.md](CHANGELOG.md) für Versions-Historie

---

## Fazit

budsUI ist ein umfangreiches, funktionsreiches UI-Addon für WoW 3.3.5 mit ~15.000-20.000 Zeilen Lua-Code über 82 Dateien. Die Architektur basiert auf einem einzigartigen Engine-Pattern mit globalem Namespace-Sharing. Das Addon ist gut strukturiert in Core- und Feature-Module, hat aber einige technische Schulden und Verbesserungspotenzial.

**Das Addon ist produktionsreif für den Ascension.gg-Server, aber nicht ohne Risiken. Für andere Server oder WoW-Versionen wäre erhebliche Anpassung erforderlich.**

---

**Viel Spaß mit budsUI! 🎮**
