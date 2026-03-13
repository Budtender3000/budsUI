# budsUI

<div align="center">
  <img src="budsUI/Media/assets/budsui_logo.png" alt="budsUI Logo" width="400">
</div>

A complete UI replacement for **World of Warcraft 3.3.5 (Wrath of the Lich King)**, specifically developed for the [Ascension.gg](https://ascension.gg) classless server.

**Based on [KkthnxUI](https://github.com/kkthnx-wow/KkthnxUI) by Josh "Kkthnx" Russell & Shestak**  
**Port & Customization by [Budtender3000](https://github.com/Budtender3000)**

---

## ⚠️ Development Status

> **Version 0.3.0 — Active Development**

- Sparsely tested; may contain bugs and unexpected behavior
- Features and APIs are subject to change
- Always back up your `WTF/` folder before updates
- Please report bugs via [GitHub Issues](https://github.com/Budtender3000/budsUI/issues)

---

## What is budsUI?

budsUI replaces and enhances nearly all standard Blizzard UI elements: UnitFrames, ActionBars, Chat, Tooltips, Minimap, Buffs, Loot system, and more. It offers a modern, customizable interface with **~100 configuration options** across **20+ module groups**.

**The Problem:** Blizzard's default UI is outdated, inflexible, and not optimized for modern playstyles.  
**The Solution:** budsUI modernizes the interface and adds Quality-of-Life features.

---

## Features Overview

| Category | What it does |
|---|---|
| **Unit Frames** | Adjustments to Blizzard Player/Target/Focus/Party/Pet/Arena frames (disabled by default) |
| **Action Bars** | 5 custom bars + Pet + Shapeshift + Totem with range coloring & cooldown text |
| **Chat** | Restyled chat frames, copy-chat/URL, filter, sounds, TellTarget |
| **Tooltips** | Item level, Spell ID, PvP rating, Instance-Lock info, and more |
| **Buffs** | Restyled buff frame with aura source tracking and class color borders |
| **Maps** | Minimap styling, FarmMode, right-click menu, button collector |
| **Loot** | Auto-confirm, auto-greed, group-loot, loot filter |
| **Skins** | Blizzard & third-party frame skins (DBM, Recount, Skada, WeakAuras) |
| **Misc** | AFK camera, durability warning, aura tracker (Filger), PulseCD |
| **Automation** | Auto-invite, auto-release, decline-duel, combat logging, auto-repair/sell-greys |
| **Announcements** | Interrupt/Sapped/Pull countdown announcements, feast & portal alerts |
| **Data Text** | Battleground, location, and stats info bars |
| **Class Modules** | Hunter utilities, Shaman Maelstrom Weapon counter |
| **Configuration** | In-game GUI via `budsUI_Config` (optional companion addon) |


## Installation

1. Download the latest version from [GitHub Releases](https://github.com/Budtender3000/budsUI/releases)
2. Extract the ZIP file and copy **both** subfolders into your AddOns directory:
   ```
   World of Warcraft/Interface/AddOns/budsUI/
   World of Warcraft/Interface/AddOns/budsUI_Config/
   ```
3. Start the game and log in — an installation wizard runs automatically on the first login
4. Use `/buds` to open the configuration panel at any time

> **Important:** Configuration changes require a UI reload (`/rl`) — there is no runtime toggle system.

### Minimum Requirements

- **Screen Width:** At least 1200px (the addon automatically disables itself at smaller resolutions)
- **WoW Version:** 3.3.5 (Wrath of the Lich King)
- **Server:** Optimized for Ascension.gg classless server

---

## Slash Commands

| Command | Description |
|---|---|
| `/buds` · `/uihelp` | Open configuration GUI / Show help |
| `/rl` · `/reloadui` | Reload UI |
| `/rc` | Perform Ready Check |
| `/gm` | Open GM ticket/help frame |
| `/boost` · `/boostui` | Set video settings to minimum (performance mode) |
| `/align` · `/grid` | Toggle alignment grid (positioning aid) |
| `/luaerror on\|off` | Toggle Lua error display |
| `/rd` | Disband group |
| `/ss` · `/spec` | Change specialization |
| `/toraid` · `/convert` | Convert party to raid |
| `/teleport` | Teleport in/out of instance |
| `/cc` · `/clearchat` | Clear chat window |
| `/resetui` | Reset UI to defaults |
| `/installui` | Run installation wizard again |
| `/addons` | Open addon list |
| `/moveui` | Toggle frame movers (drag-to-reposition) |
| `/moveui reset` | Reset all frame positions |
| `/frame` | Frame inspector (Name, Parent, Size, Strata) |
| `/framelist` | Frame stack inspector with chat-copy support |
| `/texlist` | List textures on the frame under the cursor |
| `/patch` · `/version` | Show game version and build info |

---

## Architecture

### Engine Pattern (`Core/Init.lua`)

All 82 Lua files share a common namespace via an "Engine" object:

```lua
local K, C, L, _ = select(2, ...):unpack()
```

| Variable | Type | Purpose |
|---|---|---|
| `K` | Frame | The "Kernel" — event bus, utilities, player info. Also a real `CreateFrame("Frame")` that receives events. |
| `C` | Table | Config — all settings from `Config/Settings.lua` |
| `L` | Table | Locale strings (enUS / deDE) |
| `_` | Table | Taint prevention slot (unused globals) |

The global alias `budsUI = Engine` allows external addons to access the engine. Player data is stored directly on the kernel: `K.Name`, `K.Class`, `K.Realm`, `K.Color`, `K.Version`, `K.ScreenWidth`, etc.

### Load Order (`budsUI.xml`)

The load order is **implicit** — there is no explicit dependency system. The XML file determines the exact sequence (82 Lua files):

1. `Core/Init.lua` — Engine bootstrap
2. Locales (enUS, deDE)
3. Config (Settings, Positions, Fonts, Profiles)
4. `Core/GUI.lua`, `Core/PixelPerfect.lua`
5. Internal Libs (oGlow, LibStub, CallbackHandler-1.0, LibSharedMedia-3.0)
6. `Media/Media.lua`, `Core/Colors.lua`
7. Config filter tables (Announcements, ChatSpam, Errors, FilgerSpells, Nameplates, NeedItems)
8. Core modules (API, Functions, Animation, Install, Disable, Commands, WTF, Kill, CheckVersion, Border, Developer, Panels, Temp)
9. Feature modules (UnitFrames, Misc, ActionBars, Announcements, Automation, Blizzard, Buffs, Chat, Class, DataText, Loot, Maps, Quests, Skins, Tooltip)
10. `Core/Movers.lua` — **must load last** (requires all frame anchors)


### Configuration (`Config/Settings.lua`)

All settings are static Lua tables under `C["ModuleName"]` (~100 options across 20+ groups). A UI reload is required for changes to take effect.

**SavedVariables:**

| Variable | Scope | Purpose |
|---|---|---|
| `SavedOptions` | Global | Addon-wide options |
| `SavedOptionsPerChar` | Per-Character | Install flag, AutoInvite, BarsLocked, SplitBars, etc. |
| `SavedPositions` | Per-Character | Frame positions (mover system) |
| `GUIConfigSettings` | Global (budsUI_Config) | GUI config overrides |
| `GUIConfig` | Per-Char (budsUI_Config) | Character-specific GUI overrides |
| `GUIConfigAll` | Global (budsUI_Config) | Per-realm/per-char toggle matrix |

### API Extension (`Core/API.lua`)

Injects helper methods into **all** existing Blizzard frame objects via metatable extension (using `EnumerateFrames()`). Important additions:

- **Layout Helpers:** `SetOutside()`, `SetInside()`
- **Visuals:** `CreateBackdrop()`, `CreateBorder()`, `CreateOverlay()`, `CreatePixelShadow()`, `SetTemplate()`
- **Utilities:** `FontString()`, `Kill()`, `StripTextures()`, `StyleButton()`, `CreatePanel()`

> **⚠ Warning:** This is a global metatable modification. Any other addon that defines methods with the same names (`Kill`, `SetTemplate`, `StripTextures`, etc.) will collide.

### Utility Library (`Core/Functions.lua`)

| Function | Description |
|---|---|
| `K.ShortValue(n)` | Formats large numbers (1k, 1m; 万/亿 for zh-CN) |
| `K.RGBToHex(r,g,b)` | Converts RGB to Hex color string |
| `K.FormatMoney(copper)` | Formats copper to g/s/c |
| `K.GetTimeInfo(s)` | Converts seconds to days/hours/minutes/seconds |
| `K.Delay(delay, func)` | Delayed function call via OnUpdate frame |
| `K.Round(n, dec)` | Rounds to decimal places |
| `K.ShortenString(str, n, dots)` | UTF-8-aware string truncation |
| `K.CheckChat(warning)` | Determines correct chat channel (RAID/PARTY/SAY) |
| `CheckRole()` | Auto-detects player role (Tank/Melee/Caster) via buffs & stats |
| `K.Mult` | Pixel-perfect scale multiplier (`768 / screenHeight / UIScale`) |

### Addon Conflict Detection (`Core/Disable.lua`)

budsUI automatically disables its own features when competing addons are detected:

| Feature | Disabled when these addons are loaded |
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

## Modules in Detail

### ActionBars (16 files)
Full custom action bar system (Bar 1–5, Pet, Shapeshift, Totem) with range coloring, cooldown text, hotkey display, and split bar layout option.

**Features:**
- State driver system for automatic bar switching based on class/form/bonus bar
- Out-of-range coloring (red), Out-of-mana coloring (blue)
- Cooldown text overlay on all buttons
- Toggle mode for bar visibility

### Announcements (6 files)
Situational chat announcements:
- **BadGear:** Warns about poor gear
- **FeastsAndPortals:** Announcement of feasts & portals
- **Interrupt:** Interrupt announcements
- **PullCountdown:** Pull countdown
- **SaySapped:** "I'm sapped" message
- **Spells:** Spell cast announcements

Uses `K.CheckChat()` for automatic channel selection (RAID/PARTY/SAY).

### Automation (7 files)
- **AutoInvite:** Auto-invite on keyword (default: "inv")
- **AutoRelease:** Auto-release on death
- **DeclineDuel:** Automatically decline duels
- **LoggingCombat:** Automatic combat logging
- **Screenshots:** Auto-screenshots for achievements
- **SellGreyRepair:** Auto-sell gray items + auto-repair (Guild Bank support)
- **TabBinder:** Tab key for target switching


### Blizzard (14 files)
Reskinning of Blizzard frames: Achievements, Bags, CombatText, DarkTextures, Durability, Errors, ExpBar, Fonts, Nameplates, and more.

**Specialties:**
- **BlizzBugsSuck.lua:** Fixes for known Blizzard client bugs
- **DarkTextures:** Dark textures for UI elements
- **Errors:** Error message filtering (Black/White list)

### Buffs (2 files)
- **AuraSource:** Shows source of buffs/debuffs (CastBy)
- **BuffFrame:** Restyled buff frame with class color borders

### Chat (9 files)
- **ChatFrames:** Restyling of chat frames
- **ChatTabs:** Tab styling
- **CopyChat:** Chat copy function
- **CopyUrl:** URL recognition and copy function
- **Filters:** Spam filter
- **MouseScroll:** Mouse wheel scrolling
- **Sounds:** Chat sounds (Whisper, etc.)
- **SpamageMeters:** Damage meter spam filter
- **TellTarget:** `/tt` command for Tell-to-Target

### Class (2 files)
- **Hunter.lua:** Hunter utilities
- **Shaman.lua:** Maelstrom Weapon stack counter
  - Custom animations: Pop, Pulse, Fade-Out
  - 10 textures: maelstrom1.blp to maelstrom10.blp (one per stack)
  - Blizzard overlay suppression: Suppresses Blizzard's spell activation overlay
  - Configurable: Size, Pulse threshold (default: 5 stacks)
  - **⚠️ Ascension-specific:** Loads for all classes due to Ascension's classless system
  - Spell ID: 1153817 (Ascension: Maelstrom Weapon)

### DataText (3 files)
- **Battleground:** BG stats
- **Location:** Location info
- **Stats:** Performance/stats data (FPS, latency, etc.)

### Loot (6 files)
- **AutoConfirm:** Auto-confirm for BoP items
- **AutoGreed:** Auto-greed
- **GroupLoot:** Group-loot frames
- **Loot:** Loot-frame restyling
- **LootFilter:** Loot filter
- **MasterLoot:** Master-loot utilities

### Maps (5 files)
- **MiniMap:** Minimap restyling
- **ButtonCollect:** Collects minimap buttons in a dropdown
- **FarmMode:** Enlarged minimap for farming
- **RightClick:** Right-click menu
- **WhoPinged:** Shows who pinged on the minimap

### Misc (18 files)
- **AFKSpin:** AFK camera rotation
- **AlreadyKnown:** Item overlay for already known recipes/pets/mounts
- **Durability:** Durability warning
- **Filger:** Aura tracker (buff/debuff/cooldown tracking)
  - Based on Filger by Nils Ruesch (editors: Affli/SinaC/Ildyria)
  - Configurable: Buff size, Cooldown size, PvP size, Test mode
  - Filter tables: `Config/Filters/FilgerSpells.lua`
- **GarbageCollect:** Automatic garbage collection
- **PulseCD:** Cooldown flash animation on spell procs
- **SlotItemLevel:** Item level on slots
- **SpeedyLoad:** Faster addon loading
- **WarmaneAHFix:** Fix for Warmane auction house

### Quests (4 files)
- **AutoCollapse:** Auto-collapse of quest log
- **QuestLog:** Quest log enhancements
- **WatchFrame:** Quest tracker improvements
- **WowheadLink:** Wowhead link generator

### Skins (via XML Includes)
- **Addon skins:** DBM, Recount, Skada, Spy, WeakAuras
- **Blizzard skins:** Various Blizzard frames

### Tooltip (12 files)
- **Achievement:** Achievement tooltips
- **HyperLink:** HyperLink preview
- **InstanceLock:** Instance-Lock info
- **ItemCount:** Item count in tooltip
- **ItemIcons:** Item icons in tooltip
- **ItemLevel:** Item level in tooltip
- **MultiItemRef:** Multi-Item-Ref support
- **PvPRating:** PvP rating in tooltip
- **SpellID:** Spell ID in tooltip
- **Talents:** Talent info in tooltip
- **Tooltip.lua:** Main tooltip restyling

### UnitFrames (7 files)
- **⚠️ DISABLED BY DEFAULT:** `C.Unitframe.Enable = false` in Settings.lua
- **Auras:** Aura display on UnitFrames
- **CastBars:** Castbar styling
- **EnhancedFrames:** Advanced frame features
- **HealthMinMax:** Min/Max health display
- **Layout.lua:** Core of the UnitFrame system
- **PowerBar:** PowerBar styling
- **SmoothBars:** Smooth-bar animations
- **⚠️ Filger is automatically disabled when UnitFrames are off**


---

## Dependencies

### Bundled Libraries (`Libs/`)

| Library | Purpose |
|---|---|
| `LibStub` | Standard addon library management |
| `CallbackHandler-1.0` | Event system for libraries |
| `LibSharedMedia-3.0` | Shared fonts & texture registry |
| `oGlow` | Item quality glow effects (bags, bank, etc.) |

**oGlow Architecture:** Pipe-Filter-Display pattern
- **Pipes:** Bag, Bank, Char, GBank, Inspect, Loot, Mail, Merchant, Trade, TradeSkill
- **Filters:** Quality (item quality)
- **Displays:** Border (glow border around items)

### Optional External Addons

**budsUI_Config** (highly recommended)
- Purpose: In-game config GUI
- SavedVariables: `GUIConfigSettings` (global), `GUIConfig` (per-char), `GUIConfigAll` (global)
- **⚠️ Not in the repo:** Separate addon, not part of budsUI

**Detected & Integrated Addons:**
- **Blizzard:** `Blizzard_CombatText`, `Blizzard_DebugTools`
- **Skins:** `CLCRet`, `DBM-Core`, `Recount`, `Skada`, `Spy`, `WeakAuras`
- **Profile Config:** Grid, Bartender4, ButtonFacade, ThreatPlates, ClassTimer, Nameplates (via `Core/WTF.lua`)

---

## Known Issues & Limitations

### Confirmed Bugs

> Currently no high-priority bugs confirmed. [Report bugs via GitHub Issues](https://github.com/Budtender3000/budsUI/issues).

### Important Notes

1. **UnitFrames Disabled by Default** — `C.Unitframe.Enable = false` in `Config/Settings.lua`. Must be manually enabled. (Filger is automatically disabled when UnitFrames are off.)

2. **Metatable Injection** (`Core/API.lua`) — Methods are injected globally across all frames. May collide with other addons using the same method names.

3. **Frame Enumeration on Load** — `Core/API.lua` iterates through all existing frames on load. May increase loading time in environments with many frames.

4. **Lua Errors Hidden by Default** — The installer sets `scriptErrors=0`. Use `/luaerror on` during development.

5. **`K.Delay` Memory Note** — Active cleanup is implemented; canceled delays are immediately removed from the `waitTable`.

6. **WTF.lua Profile Keys** — Profile keys are generated dynamically based on `UnitName` and `GetRealmName`. Profiles may be lost if realms are renamed.

7. **`CheckRole()` is Heuristic** — Role detection uses stat comparison and buff checks. Hybrid classes may be misidentified. Registers `UNIT_AURA` globally (fires on every aura update).

8. **No Error Handling** — Almost no `pcall` usage throughout the addon. A single Lua error in critical files can cascade.

9. **Settings Active Only After Reload** — There is no runtime toggle mechanism. Every change requires `/rl`.

10. **Screen Width Check** — Addon disables itself completely if `K.ScreenWidth < 1200`. No warning beforehand.

### Specialties & Hacks

**Metatable Injection (Core/API.lua)**
- Global frame extension: All existing frames are iterated via `EnumerateFrames()` and extended with custom methods
- **⚠️ RISK:** Other addons with same method names will collide
- **Performance Impact:** Frame enumeration on load increases loading time

**Delay System (Core/Functions.lua)**
- `K.Delay(delay, func)`: Delayed function calls via OnUpdate frame
- `waitTable`: Global table for all delayed calls
- Active Cleanup: Canceled delays are immediately removed from waitTable

**Role Detection (Core/Functions.lua)**
- Heuristic: Detects role (Tank/Melee/Caster) via buff checks & stat comparison
- Tank detection: Paladin (Righteous Fury), Warrior (Defensive Stance), DK (Frost Presence), Druid (Bear Form)
- Melee vs Caster: Compares Attack Power vs Intellect
- **⚠️ PROBLEM:** Hybrid classes may be misidentified

**Shaman Maelstrom Weapon Tracker (Modules/Class/Shaman.lua)**
- Blizzard overlay suppression: Hooks `SpellActivationOverlayFrame.ShowOverlay` to suppress Blizzard's overlay
- Texture switching: Shows only the current stack texture (1-10), hides all others
- Animations: Pop (on stack increase), Pulse (at 5+ stacks), Fade-Out (at 0 stacks)
- **⚠️ Ascension-specific:** Spell ID 1153817 is Ascension-specific

**Auto-Repair & Sell-Grey (Modules/Automation/SellGreyRepair.lua)**
- Guild Bank support: Uses Guild Bank for repair if available and group > 5 players
- Item rarity check: Sells only items with `itemRarity == 0` (gray)
- **⚠️ No error handling:** No `pcall` - errors in GetItemInfo can crash the script


---

## Important File Reference

| File | Priority | Description |
|---|---|---|
| `Core/Init.lua` | ⭐⭐⭐ | Engine bootstrap — start here |
| `Core/API.lua` | ⭐⭐⭐ | All reusable frame methods (Metatable injection) |
| `Core/Functions.lua` | ⭐⭐⭐ | Utility library |
| `Config/Settings.lua` | ⭐⭐⭐ | All configuration options (~100 settings) |
| `Config/Positions.lua` | ⭐⭐ | Pixel-perfect frame positions |
| `Core/Install.lua` | ⭐⭐ | Initial installation & SavedVariables |
| `Core/Commands.lua` | ⭐⭐ | All slash commands |
| `Core/Disable.lua` | ⭐⭐ | Addon conflict detection & feature toggles |
| `Core/Movers.lua` | ⭐⭐ | Frame positioning GUI (must load last) |
| `Modules/UnitFrames/Layout.lua` | ⭐⭐ | Core of the UnitFrame system |
| `budsUI.xml` | ⭐⭐ | Load order = implicit dependencies |
| `Core/WTF.lua` | ⭐ | Third-party addon profile configuration |

---

## Project Scope

- **Total Size:** ~15,000–20,000 lines of Lua across 82 files
- **Interface Level:** `30300` (WoW 3.3.0 / WotLK)
- **Locales:** English (enUS), German (deDE)
- **Origin:** Fork of KkthnxUI adapted for Ascension.gg's classless server

---

## Configuration

### Config Structure

All settings are located in `Config/Settings.lua` and organized into the following groups:

- **Media:** Colors, fonts, textures, sounds
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
- **MoverPositions:** Frame positions

### Profile System

The profile system (`Config/Profiles.lua`) supports:
- **Per-Class Config:** Overrides general config
- **Per-Character Name Config:** Overrides general & class
- **Per-Max-Level Config:** Overrides general, class & name
- **Budtender Preset:** `Config/BudtenderPreset.lua` (hardcoded preset)

**⚠️ Currently Empty:** Only placeholder code, no active overrides.

### Frame Positioning

The mover system (`Core/Movers.lua`) enables drag-and-drop positioning of 27 UI elements:
- ActionBars, Buffs, Minimap, UnitFrames, Castbars, PowerBar, etc.
- Positions are stored in `SavedPositions` (per-char)
- `/moveui` activates movers, `/moveui reset` resets positions
- **⚠️ Combat Lock:** Does not work in combat

---

## Usage

### First Steps

1. **Installation:** Follow the installation instructions above
2. **Wizard:** On the first login, the installation wizard runs automatically
3. **Configuration:** Open `/buds` for the config GUI (requires `budsUI_Config`)
4. **Customization:** Use `/moveui` to move UI elements
5. **Reload:** Always execute `/rl` after changes

### Important Commands for Daily Use

- `/rl` — Reload UI after config changes
- `/moveui` — Move UI elements
- `/align` — Grid for precise positioning
- `/buds` — Open config GUI

### Tips & Tricks

- **Performance Mode:** `/boost` sets video settings to minimum
- **Frame Debugging:** `/frame` shows info about frame under cursor
- **Copy Chat:** Right-click on chat tab for copy function
- **Auto-Invite:** Whisper "inv" (or configured keyword) for auto-invite
- **Auto-Repair:** Open vendor with Guild Bank access for auto-repair via Guild Bank


---

## Development & Contributing

### Code Quality

**Strengths:**
- Comprehensive feature set (~100 configuration options)
- Good addon conflict detection
- Pixel-perfect scaling
- Flexible frame positioning
- Well-maintained CHANGELOG

**Weaknesses:**
- No error handling (almost no `pcall`)
- Metatable injection risk
- Implicit dependencies (XML order only)
- Little documentation
- No tests
- Inconsistent naming conventions

**Critical Areas:**
- `Core/API.lua` (Metatable injection)
- `Core/Functions.lua` (CheckRole UNIT_AURA spam)
- `Core/Init.lua` (Engine bootstrap)
- Load order (XML-based, error-prone)

### Potential for Improvement

1. **Error Handling:** `pcall` for critical functions
2. **Abstraction:** Abstract Bar1-5 into a generic bar factory
3. **Documentation:** Inline docs, API docs, developer guide
4. **Tests:** Unit tests for core functions
5. **Localization:** Localize all strings, implement fallback
6. **Profile System:** Complete profile system with import/export
7. **Runtime Toggles:** Make some settings changeable without reload
8. **Dependency System:** Explicit dependencies instead of XML order
9. **Modularization:** Clearer module separation, less global state
10. **Performance:** Reduce UNIT_AURA spam, implement throttling

### Contributing

Contributions are welcome! Please note:

1. **Fork & Pull Request:** Fork the repo, make your changes, create a pull request
2. **Code Style:** Try to maintain the existing code style
3. **Testing:** Test your changes thoroughly on Ascension.gg
4. **Documentation:** Update README.md and CHANGELOG.md
5. **Issues:** Use GitHub Issues for bug reports and feature requests

### Developer Mode

Activate Developer Mode in `Config/Settings.lua`:

```lua
C.General.DeveloperMode = true
```

This activates:
- Lua error display
- Additional debug output
- Frame inspector tools

---

## Performance Considerations

### Optimizations

- **Metatable Injection:** Once on load, no overhead thereafter
- **Delay System:** Optimized with active cleanup
- **Frame Enumeration:** Can be slow with many frames

### Known Performance Issues

- **UNIT_AURA Spam:** `CheckRole()` registers globally, fires often
- **oGlow:** Pipe-Filter system is relatively complex for simple functionality
- **Many Active Delays:** Can cause memory overhead

### Maintainability

- **Monolithic Structure:** 82 files, no clear module separation
- **Implicit Dependencies:** XML order only, no explicit declaration
- **Global State:** Lots of global state in `K`, `C`, `L`
- **Hard to Test:** No unit tests, no test infrastructure
- **Hard to Extend:** New features often require changes in multiple files

---

## Security & Taint

- **Protected Frame Checks:** `if object:IsProtected() then return end` in API.lua
- **Taint Prevention Slot:** `_` in engine unpacking
- **⚠️ Metatable Injection Risk:** Can cause taint if not careful
- **⚠️ No Sandbox:** No protection against malicious code in config files

---

## Localization

- **2 Locales:** enUS (English), deDE (German)
- **L-Table:** All strings in `Locales/enUS.lua`, `Locales/deDE.lua`
- **⚠️ Incomplete:** Many strings are hardcoded, not localized
- **⚠️ No Fallback:** If string is missing, nil is displayed

---

## Ascension.gg Specifics

- **Classless Support:** Shaman module loads for all classes
- **Custom Spell IDs:** Maelstrom Weapon = 1153817 (Ascension-specific)
- **⚠️ Not Portable:** Code is heavily tailored for Ascension

---

## Credits

- **Original UI:** [KkthnxUI](https://github.com/kkthnx-wow/KkthnxUI) by Josh "Kkthnx" Russell & Shestak
- **3.3.5 Port & Customization:** [Budtender3000](https://github.com/Budtender3000)
- **Filger:** Based on Filger by Nils Ruesch (editors: Affli/SinaC/Ildyria)
- **oGlow:** Item quality glow library

### Licenses

This project is licensed under the **MIT License**. budsUI is a derivative work of KkthnxUI and retains the original MIT license.

See `Licenses/` folder for full license texts:
- `Licenses/KkthnxUI` — Original KkthnxUI license
- `Licenses/ShestakUI` — ShestakUI license
- `Licenses/TukUI` — TukUI license
- `Licenses/ElvUI` — ElvUI license
- `Licenses/oUF` — oUF license

---

## Support

- **GitHub:** [Budtender3000/budsUI](https://github.com/Budtender3000/budsUI)
- **Issues:** [Bug reports via GitHub Issues](https://github.com/Budtender3000/budsUI/issues)
- **Changelog:** See [CHANGELOG.md](CHANGELOG.md) for version history

---

## Conclusion

budsUI is a comprehensive, feature-rich UI addon for WoW 3.3.5 with ~15,000-20,000 lines of Lua code across 82 files. The architecture is based on a unique engine pattern with global namespace sharing. The addon is well-structured into core and feature modules but has some technical debt and potential for improvement.

**The addon is production-ready for the Ascension.gg server, but not without risks. Significant adaptation would be required for other servers or WoW versions.**

---

**Have fun with budsUI! 🎮**
