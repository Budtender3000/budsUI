# Changelog

All notable changes to budsUI will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.7.1] - 2026-03-27

### Fixed
- **Settings Persistence (Issue #1):** Fixed critical bug where settings were not being saved for new users or characters without an assigned profile. The addon now automatically creates a "Default" profile on first load, ensuring all configuration changes are properly persisted across reloads.

## [0.7.0] - 2026-03-20

### Added
- **Profile System Overhaul:** Complete redesign of the profile management architecture.
  - **Character-Specific Profiles:** Settings are now stored in a new `budsUIData` structure, allowing for independent character configurations.
  - **Dynamic Management UI:** Added a dedicated profile menu for creating, deleting, and switching between saved profiles.
  - **Import/Export:** Implemented a string-based profile sharing system with optimized serialization to prevent memory overflows.
- **Install Wizard Localization:** Full support for English (`enUS`) and German (`deDE`) client locales.
- **Developer Mode:** Added a new configuration option in the "General" menu to enable Developer Mode features and warnings.
- **Movable Bags & Bank:** Bag and bank frames are now always draggable without the Shift-key requirement. Positions persist via `SetUserPlaced`.
- **Install Wizard UX:** Added clear instructions to the final reload popup, guiding users to type `/buds` to customize their interface.

### Changed
- **Profile Reset Refinement:** The `/resetui` command and wizard completion now only wipe the currently **active** profile, preserving other saved profiles.
- **Data Persistence:** Transitioned from legacy `SavedOptions` to the more robust `budsUIData` format for character-specific settings.
- **Pixel Perfect:** Removed multisample enforcement and implemented more robust screen resolution retrieval logic.
- **Slider UI:** Refactored configuration sliders to use themed backdrops for better visual consistency.
- **Profile Groups:** Reordered `ALLOWED_GROUPS` in the profile management system for better logical categorization.
- **Profile Export UI:** Removed redundant "Copy" buttons in favor of standard Ctrl+C / Ctrl+V instructions; optimized button layout and alignment.

### Fixed
- **DBM Skinning:** Fixed potential nil-value crashes and removed custom unit frame aura positioning for better compatibility with modern DBM versions.
- **Profile Export Error:** Resolved a "memory allocation error: block too big" that occurred when exporting profiles with large data sets.
- **Chat Position Persistence:** Fixed an issue where the Chat frame would reset to its default position after a reload even if moved via `/moveui`.
- **Action Bar Overlap:** Fixed a visual bug where the toggle buttons for right bars would overlap when switching bar counts.
- **AutoInvite Logic:** Fixed a return value bug in the AutoInvite module.
- **SavedVariables:** Ensured all modules correctly declare their SavedVariables in `.toc` files for reliable persistence.
- **Localization Strings:** Cleaned up and updated strings for multisample and font replacement settings.

## [0.6.7] - 2026-03-20

### Changed
- **Unitframe Integration:** Fully combined the "budsUI Layout" and "Modified Blizzard unitframe graphics" (Fatbars) into a single, permanent core UI configuration. The Enhanced Fatbars are now unconditionally active, eliminating legacy layout fragmentation.
- **Config UI Improvements:** Swapped out text `EditBox`es for fluid `Slider` inputs in the Unitframes options menu for settings like `Scale`, `CastBarScale`, and `AuraSize`.
- **Unitframe Compatibility:** Converted all Core features to depend directly on checking the client for competing Addons (e.g. `ShadowedUnitFrames`, `PitBull4`, `XPerl`) rather than internal layout booleans.

### Fixed
- **Missing Frames Crash:** Resolved a startup error affecting `Filger.lua` by stripping stale `C.Unitframe.Enable` config blocks from `FilgerSpells.lua`.

## [0.6.6] - 2026-03-20

### Fixed
- **WoW 3.3.5 API Compatibility:** 
  - Replaced `PLAYER_EQUIPMENT_CHANGED` with `UNIT_INVENTORY_CHANGED` for proper 3.3.5 support in the ItemLevel module.
  - Replaced `table.wipe()` with the correct WoW API function `wipe()` across all modules (Announcements, Automation, Misc).
  - Improved general stability with better nil-checks for API returns.

## [0.6.3] - 2026-03-17

### Added
- **Major Refactoring (Phases 1-3):** Merged comprehensive performance and stability improvements.
- **Error Handling System:** Added `SafeEventHandler` and `SafeOnUpdate` wrappers to prevent addon crashes, with a dedicated error log viewer (`/budsuierrors`).
- **Config Validation:** Implemented a runtime configuration validation system with type and range checks for 25+ options.
- **Spell Info Caching:** Added a caching layer for `GetSpellInfo` to significantly reduce CPU overhead.

### Changed
- **Performance:** Implemented `UNIT_AURA` event throttling (reducing event spam by up to 70%) and optimized Nameplate `OnUpdate` loops via batch processing.
- **Memory Management:** Added proper event unregistration and cleanup mechanisms to the `Kill` and `K.Delay` systems.

### Fixed
- **Secure Frame Protection:** Resolved multiple taint issues affecting `PetFrame`, `TargetFrameToT`, and Raid frames during combat.
- **Castbars:** Fixed castbar anchor initialization and added position locking/restore mechanisms.

## [0.6.2] - 2026-03-15

### Added
- **Mascot UI Element:** Added custom "Buds" mascot texture with tooltip to the configuration panel.
- **Asset Paths:** Implemented dynamic `K.Directory` detection ensuring asset paths work regardless of the folder name.

### Changed
- **Visuals:** Refined border texture alpha handling and updated documentation attributions.

[Unreleased]: https://github.com/Budtender3000/budsUI/compare/v0.7.0...HEAD
[0.7.0]: https://github.com/Budtender3000/budsUI/compare/v0.6.7...v0.7.0
[0.6.7]: https://github.com/Budtender3000/budsUI/compare/v0.6.6...v0.6.7
[0.6.6]: https://github.com/Budtender3000/budsUI/compare/v0.6.3...v0.6.6
[0.6.3]: https://github.com/Budtender3000/budsUI/compare/v0.6.2...v0.6.3
[0.6.2]: https://github.com/Budtender3000/budsUI/compare/v0.6.1...v0.6.2
