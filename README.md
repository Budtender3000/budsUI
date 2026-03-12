# budsUI

<div align="center">
  <img src="Media/assets/budsui_logo.png" alt="budsUI Logo" width="800" />
</div>

A comprehensive, full UI-replacement AddOn for **World of Warcraft 3.3.5 (Wrath of the Lich King)**, built for the [Ascension.gg](https://ascension.gg) server.

**Based on [KkthnxUI](https://github.com/kkthnx-wow/KkthnxUI) by Josh "Kkthnx" Russell & Shestak**  
**Port & Customization by [Budtender3000](https://github.com/Budtender3000)**

---

## ⚠️ Development Status

> **Version 0.1.0-alpha — Active Development**

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
| **Skins** | Blizzard & third-party frame skins |
| **Misc** | AFK camera, durability warning, aura tracker (Filger), garbage collection, PulseCD |
| **Automation** | Auto-invite, auto-release, decline duel, combat logging, auto-repair/sell greys |
| **Announcements** | Interrupt/sapped/pull countdown announcements, feast & portal alerts |
| **Data Text** | Battleground, location, and stats info bars |
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

---

## Architecture

### Engine Pattern (`Core/Init.lua`)

Every file shares a single engine namespace unpacked as four values:

```lua
local K, C, L, _ = select(2, ...):unpack()
```

| Variable | Type | Purpose |
|---|---|---|
| `K` | Frame | The "Kernel" — event bus, utilities, the main addon object |
| `C` | Table | Config — all settings from `Config/Settings.lua` |
| `L` | Table | Locale strings (enUS / deDE) |
| `_` | Table | Taint-prevention slot (unused globals go here) |

The global alias `budsUI = Engine` allows external AddOns to interact with the engine.

### Load Order (`budsUI.xml`)

1. `Core/Init.lua` — Engine bootstrap
2. Locales (enUS, deDE)
3. Config (Settings, Positions, Fonts, Profiles)
4. Internal libs (oGlow, LibStub, CallbackHandler-1.0, LibSharedMedia-3.0)
5. Media (textures, fonts, sounds)
6. Core modules (API, Functions, Colors, Animation, Panels, Commands, …)
7. Feature modules (UnitFrames, ActionBars, Chat, Tooltip, …)
8. `Core/Movers.lua` — frame-positioning GUI (must load last)

### Configuration (`Config/Settings.lua`)

All settings are static Lua tables under `C["ModuleName"]`. A UI reload is required for changes to take effect. Per-character options and frame positions are stored in `SavedOptionsPerChar` / `SavedPositions`; global options in `SavedOptions`.

### API Extension (`Core/API.lua`)

Injects helper methods into all existing Blizzard frame objects via metatable extension. Key additions:

- **Layout helpers:** `SetOutside()`, `SetInside()`
- **Visuals:** `CreateBackdrop()`, `CreateBorder()`, `CreateOverlay()`, `CreatePixelShadow()`, `SetTemplate()`
- **Utilities:** `FontString()`, `Kill()`, `StripTextures()`, `StyleButton()`, `CreatePanel()`

### Utility Library (`Core/Functions.lua`)

| Function | Description |
|---|---|
| `K.ShortValue(n)` | Format large numbers (1k, 1m; 万/亿 for zh-CN) |
| `K.RGBToHex(r,g,b)` | Convert RGB to hex colour string |
| `K.FormatMoney(copper)` | Format copper into g/s/c |
| `K.GetTimeInfo(s)` | Convert seconds to days/hours/minutes/seconds |
| `K.Delay(delay, func)` | Deferred function call via OnUpdate frame |
| `K.Round(n, dec)` | Round to decimal places |
| `CheckRole()` | Auto-detect player role (Tank/Melee/Caster) via buffs & stats |
| `K.Mult` | Pixel-perfect scale multiplier (`768 / screenHeight / UIScale`) |

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

> These are documented quirks developers should be aware of.

1. **Unit Frames disabled by default** — `C.Unitframe.Enable = false` in `Config/Settings.lua`. Enable manually before first use.
2. **Metatable injection** (`Core/API.lua`) — Methods are injected globally across all frames. May conflict with other AddOns using the same method names (`SetTemplate`, `Kill`, etc.).
3. **Frame enumeration on load** — `Core/API.lua` loops over all existing frames at load time to inject the API. May slightly increase load time in environments with many frames.
4. **Lua errors hidden by default** — The installer sets `scriptErrors=0`. Use `/luaerror on` during development.
5. **`K.Delay` memory note** — Cancelled delays are not actively cleaned from `waitTable`; they are cleared lazily on traversal. In high-load scenarios with many delays, memory usage may creep up.
6. **WTF.lua profile keys** — Several third-party AddOn profile keys still reference `"Kkthnx - Lordaeron"` (the original author's character name). If third-party AddOns fail to load their pre-configured profiles, check and update these keys in `Core/WTF.lua`.
7. **`CheckRole()` is heuristic** — Role detection uses stat comparison (INT vs AP/AGI) and buff checks. Hybrid classes may be misidentified.

---

## Key Files Reference

| File | Priority | Description |
|---|---|---|
| `Core/Init.lua` | ⭐⭐⭐ | Engine bootstrap — start here |
| `Core/API.lua` | ⭐⭐⭐ | All reusable frame methods |
| `Core/Functions.lua` | ⭐⭐⭐ | Utility library |
| `Config/Settings.lua` | ⭐⭐⭐ | All configuration options |
| `Config/Positions.lua` | ⭐⭐ | Pixel-accurate frame positions |
| `Core/Install.lua` | ⭐⭐ | First-run setup & SavedVariables |
| `Core/Commands.lua` | ⭐⭐ | All slash commands |
| `Modules/UnitFrames/Layout.lua` | ⭐⭐ | Core of the unit frame system |
| `budsUI.xml` | ⭐⭐ | Load order = implicit dependencies |
| `Core/WTF.lua` | ⭐ | Third-party AddOn profile configuration |

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
