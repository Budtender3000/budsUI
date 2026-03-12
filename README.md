 # budsUI

<div align="center">
  <img src="Media/assets/budsui_logo.png" alt="budsUI Logo" width="800" />
</div>

A comprehensive, full UI-replacement AddOn for **World of Warcraft 3.3.5 (Wrath of the Lich King)**, built for the [Ascension.gg](https://ascension.gg) classless server.

**Based on [KkthnxUI](https://github.com/kkthnx-wow/KkthnxUI) by Josh "Kkthnx" Russell & Shestak**  
**Port & Customization by [Budtender3000](https://github.com/Budtender3000)**

---

## ⚠️ Development Status

> **Version 0.2.0 — Active Development**

- Tested sporadically; may contain bugs and unexpected behaviour
- Features and APIs are subject to change
- Always back up your `WTF/` folder before updating
- Report bugs via [GitHub Issues](https://github.com/Budtender3000/budsUI/issues)

---

## Features

| Category | What it does |
|---|---|
| **Unit Frames** | Tweaks to Blizzard Player/Target/Focus/Party/Pet/Arena frames |
| **Action Bars** | Custom bars (Bar 1–5, Pet, Shapeshift, Totem) with range & cooldown highlighting |
| **Chat** | Restyled chat frames, copy-chat/URL, filters, sounds, TellTarget |
| **Tooltips** | Item level, spell ID, PvP rating, instance lock info and more |
| **Buffs** | Restyled buff frame with aura-source tracking |
| **Maps** | Minimap styling, FarmMode, right-click menu, button collector |
| **Loot** | Auto-confirm, auto-greed, group loot, loot filter |
| **Skins** | Blizzard & third-party frame skins (DBM, Recount, Skada, WeakAuras) |
| **Misc** | AFK camera, durability warning, aura tracker (Filger), garbage collection, PulseCD |
| **Automation** | Auto-invite, auto-release, decline duel, combat logging, auto-repair/sell greys |
| **Announcements** | Interrupt/sapped/pull countdown announcements, feast & portal alerts |
| **Data Text** | Battleground, location, and stats info bars |
| **Class Modules** | Hunter utilities, Shaman Maelstrom Weapon counter |
| **Configuration** | In-game GUI via `budsUI_Config` (optional companion AddOn) |

---

## Installation

1. Download the latest release from [GitHub Releases](https://github.com/Budtender3000/budsUI/releases)
2. Extract the ZIP and copy **both** subfolders into your AddOns directory:
   ```
   World of Warcraft/Interface/AddOns/budsUI/
   World of Warcraft/Interface/AddOns/budsUI_Config/
   ```
3. Launch the game and log in — an installation wizard runs automatically on first login
4. Use `/buds` to open the configuration panel at any time

> **Note:** Configuration changes require a UI reload (`/rl`) to take effect — there is no runtime toggle system.

---

## Slash Commands

| Command | Description |
|---|---|
| `/buds` · `/uihelp` | Open configuration GUI / show help |
| `/rl` · `/reloadui` | Reload the UI |
| `/rc` | Perform a Ready Check |
| `/gm` | Open the GM ticket/help frame |
| `/boost` · `/boostui` | Set video settings to minimum (performance mode) |
| `/align` · `/grid` | Toggle alignment grid (positioning aid) |
| `/luaerror on\|off` | Toggle Lua error display |
| `/rd` | Disband group |
| `/ss` · `/spec` | Switch specialisation |
| `/toraid` · `/convert` | Convert party to raid |
| `/teleport` | Teleport in/out of instance |
| `/cc` · `/clearchat` | Clear chat window |
| `/resetui` | Reset UI to defaults |
| `/installui` | Re-run the installation wizard |
| `/addons` | Open the AddOn list |
| `/moveui` | Toggle frame movers (drag to reposition) |
| `/moveui reset` | Reset all frame positions to default |
| `/frame` | Frame inspector (name, parent, size, strata) |
| `/framelist` | Frame stack inspector with chat-copy support |
| `/texlist` | List textures on the frame under the cursor |
| `/patch` · `/version` | Show game version and build info |

---

## Architecture

### Engine Pattern (`Core/Init.lua`)

Every file shares a single engine namespace unpacked as four values:

```lua
local K, C, L, _ = select(2, ...):unpack()
```

| Variable | Type | Purpose |
|---|---|---|
| `K` | Frame | The "Kernel" — event bus, utilities, the main addon object. Also a real `CreateFrame("Frame")` that receives events. |
| `C` | Table | Config — all settings from `Config/Settings.lua` |
| `L` | Table | Locale strings (enUS / deDE) |
| `_` | Table | Taint-prevention slot (unused globals go here) |

The global alias `budsUI = Engine` allows external AddOns to interact with the engine. Player info is stored directly on the kernel frame: `K.Name`, `K.Class`, `K.Realm`, `K.Color`, `K.Version`, `K.ScreenWidth`, etc.

### Load Order (`budsUI.xml`)

The load order is **implicit** — there is no explicit dependency system. The XML file determines the exact sequence (82 Lua files):

1. `Core/Init.lua` — Engine bootstrap
2. Locales (enUS, deDE)
3. Config (Settings, Positions, Fonts, Profiles)
4. `Core/GUI.lua`, `Core/PixelPerfect.lua`
5. Internal libs (oGlow, LibStub, CallbackHandler-1.0, LibSharedMedia-3.0)
6. `Media/Media.lua`, `Core/Colors.lua`
7. Config filter tables (Announcements, ChatSpam, Errors, FilgerSpells, Nameplates, NeedItems)
8. Core modules (API, Functions, Animation, Install, Disable, Commands, WTF, Kill, CheckVersion, Border, Developer, Panels, Temp)
9. Feature modules (UnitFrames, Misc, ActionBars, Announcements, Automation, Blizzard, Buffs, Chat, Class, DataText, Loot, Maps, Quests, Skins, Tooltip)
10. `Core/Movers.lua` — **must load last** (requires all frame anchors to exist)

### Configuration (`Config/Settings.lua`)

All settings are static Lua tables under `C["ModuleName"]` (~100 options across 20+ groups). A UI reload is required for changes to take effect.

**SavedVariables:**

| Variable | Scope | Purpose |
|---|---|---|
| `SavedOptions` | Global | Addon-wide options |
| `SavedOptionsPerChar` | Per-Character | Install flag, AutoInvite, BarsLocked, SplitBars, etc. |
| `SavedPositions` | Per-Character | Frame positions (Mover system) |
| `GUIConfigSettings` | Global (budsUI_Config) | GUI config overrides |
| `GUIConfig` | Per-Char (budsUI_Config) | Character-specific GUI overrides |
| `GUIConfigAll` | Global (budsUI_Config) | Per-realm/per-char toggle matrix |

### API Extension (`Core/API.lua`)

Injects helper methods into **all** existing Blizzard frame objects via metatable extension (using `EnumerateFrames()`). Key additions:

- **Layout helpers:** `SetOutside()`, `SetInside()`
- **Visuals:** `CreateBackdrop()`, `CreateBorder()`, `CreateOverlay()`, `CreatePixelShadow()`, `SetTemplate()`
- **Utilities:** `FontString()`, `Kill()`, `StripTextures()`, `StyleButton()`, `CreatePanel()`

> **⚠ Warning:** This is a global metatable modification. Any other AddOn that defines methods with the same names (`Kill`, `SetTemplate`, `StripTextures`, etc.) will collide.

### Utility Library (`Core/Functions.lua`)

| Function | Description |
|---|---|
| `K.ShortValue(n)` | Format large numbers (1k, 1m; 万/亿 for zh-CN) |
| `K.RGBToHex(r,g,b)` | Convert RGB to hex colour string |
| `K.FormatMoney(copper)` | Format copper into g/s/c |
| `K.GetTimeInfo(s)` | Convert seconds to days/hours/minutes/seconds |
| `K.Delay(delay, func)` | Deferred function call via OnUpdate frame |
| `K.Round(n, dec)` | Round to decimal places |
| `K.ShortenString(str, n, dots)` | UTF-8-aware string truncation |
| `K.CheckChat(warning)` | Determine correct chat channel (RAID/PARTY/SAY) |
| `CheckRole()` | Auto-detect player role (Tank/Melee/Caster) via buffs & stats |
| `K.Mult` | Pixel-perfect scale multiplier (`768 / screenHeight / UIScale`) |

### Addon Conflict Detection (`Core/Disable.lua`)

budsUI automatically disables its own features when competing AddOns are detected:

| Feature | Disabled when these AddOns are loaded |
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

## Module Overview

### ActionBars (16 files)
Full custom ActionBar system (Bar 1–5, Pet, Shapeshift, Totem) with range colouring, cooldown text, hotkey display, and split-bar layout option.

### Announcements (6 files)
Situational chat announcements: BadGear, FeastsAndPortals, Interrupt, PullCountdown, SaySapped, Spells — using `K.CheckChat()` for automatic channel selection.

### Automation (7 files)
AutoInvite, AutoRelease, DeclineDuel, LoggingCombat, Screenshots, SellGreyRepair, TabBinder.

### Blizzard (14 files)
Reskinning of Blizzard frames: Achievements, Bags, CombatText, DarkTextures, Durability, Errors, ExpBar, Fonts, Nameplates, and more. Includes `BlizzBugsSuck` — fixes for known Blizzard client bugs.

### Buffs (2 files)
Restyled buff frame with class-colour borders and aura-source (`CastBy`) tracking.

### Chat (9 files)
ChatFrames, ChatTabs, CopyChat, CopyUrl, Filters, MouseScroll, Sounds, SpamageMeters, TellTarget.

### Class (2 files)
Hunter utilities and Shaman Maelstrom Weapon stack counter.

### DataText (3 files)
Battleground stats, location info, and performance/stats data bars.

### Loot (6 files)
Auto-confirm BoP, auto-greed, group loot frames, loot filter.

### Maps (5 files)
Minimap restyling, FarmMode, right-click menu, button collector, ping notifications.

### Misc (18 files)
AFK camera, AlreadyKnown item overlay, aura tracker (Filger), durability warning, garbage collector, PulseCD cooldown flash, and more.

### Quests (4 files)
Quest log enhancements and quest tracking improvements.

### Skins (via XML includes)
Addon skins (DBM, Recount, Skada, Spy, WeakAuras) and Blizzard frame skins.

### Tooltip (12 files)
Achievement tooltips, HyperLink preview, InstanceLock, ItemCount, ItemIcons, ItemLevel, MultiItemRef, PvPRating, SpellID, Talents, and full tooltip restyling.

### UnitFrames (7 files)
Auras, CastBars, EnhancedFrames, HealthMinMax, Layout, PowerBar, SmoothBars — **disabled by default** (see Known Issues).

---

## Dependencies

### Bundled Libraries (`Libs/`)

| Library | Purpose |
|---|---|
| `LibStub` | Standard AddOn library management |
| `CallbackHandler-1.0` | Event system for libraries |
| `LibSharedMedia-3.0` | Shared fonts and texture registry |
| `oGlow` | Item quality glow effects |

### Optional External AddOns

`budsUI_Config` is strongly recommended for configuration. The following AddOns are detected and integrated when present:

- `Blizzard_CombatText`, `Blizzard_DebugTools`
- `CLCRet`, `DBM-Core`, `Recount`, `Skada`, `Spy`, `WeakAuras`

`Core/WTF.lua` pre-configures profiles for Grid, Bartender4, ButtonFacade, ThreatPlates, ClassTimer, and Nameplates on first install.

---

## Known Issues & Caveats

> These are documented quirks developers and users should be aware of.

### Confirmed Bugs

> No high-priority bugs are currently confirmed. [Report issues on GitHub](https://github.com/Budtender3000/budsUI/issues).

### Other Caveats

1. **Unit Frames disabled by default** — `C.Unitframe.Enable = false` in `Config/Settings.lua`. Enable manually before first use. (Filger is also auto-disabled when UnitFrames are off.)
2. **Metatable injection** (`Core/API.lua`) — Methods are injected globally across all frames. May conflict with other AddOns using the same method names.
3. **Frame enumeration on load** — `Core/API.lua` loops over all existing frames at load time. May increase load time in environments with many frames.
4. **Lua errors hidden by default** — The installer sets `scriptErrors=0`. Use `/luaerror on` during development.
5. **`K.Delay` memory note** — Active cleanup is implemented; cancelled delays are removed from the `waitTable` immediately.
6. **WTF.lua profile keys** — Profile keys are now dynamically generated based on `UnitName` and `GetRealmName`.
7. **`CheckRole()` is heuristic** — Role detection uses stat comparison and buff checks. Hybrid classes may be misidentified. Registers `UNIT_AURA` globally (fires on every aura update).
8. **No error handling** — Almost no `pcall` usage in the entire addon. A single Lua error in a critical file can cascade.
9. **Settings only apply after reload** — There is no runtime toggle mechanism. Every change requires `/rl`.

---

## Key Files Reference

| File | Priority | Description |
|---|---|---|
| `Core/Init.lua` | ⭐⭐⭐ | Engine bootstrap — start here |
| `Core/API.lua` | ⭐⭐⭐ | All reusable frame methods (metatable injection) |
| `Core/Functions.lua` | ⭐⭐⭐ | Utility library |
| `Config/Settings.lua` | ⭐⭐⭐ | All configuration options (~100 settings) |
| `Config/Positions.lua` | ⭐⭐ | Pixel-accurate frame positions |
| `Core/Install.lua` | ⭐⭐ | First-run setup & SavedVariables |
| `Core/Commands.lua` | ⭐⭐ | All slash commands |
| `Core/Disable.lua` | ⭐⭐ | Addon conflict detection & feature toggles |
| `Core/Movers.lua` | ⭐⭐ | Frame-positioning GUI (must load last) |
| `Modules/UnitFrames/Layout.lua` | ⭐⭐ | Core of the unit frame system |
| `budsUI.xml` | ⭐⭐ | Load order = implicit dependencies |
| `Core/WTF.lua` | ⭐ | Third-party AddOn profile configuration |

---

## Project Scope

- **Total size:** ~15,000–20,000 lines of Lua across 82 files
- **Interface level:** `30300` (WoW 3.3.0 / WotLK)
- **Locales:** English (enUS), German (deDE)
- **Heritage:** Fork of KkthnxUI adapted for Ascension.gg's classless server

---

## Credits

- **Original UI:** [KkthnxUI](https://github.com/kkthnx-wow/KkthnxUI) by Josh "Kkthnx" Russell & Shestak
- **3.3.5 Port & Customization:** [Budtender3000](https://github.com/Budtender3000)
- **License:** MIT (see `Licenses/` folder)

---

## Support

- **GitHub:** [Budtender3000/budsUI](https://github.com/Budtender3000/budsUI)
- **Issues:** [Report via GitHub Issues](https://github.com/Budtender3000/budsUI/issues)

This project is licensed under the **MIT License**. budsUI is a derivative work of KkthnxUI, maintaining the original MIT license.  
See `Licenses/KkthnxUI` for the original license text.
