# Changelog

All notable changes to budsUI will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Fixed
- **DataText Module - Critical Bug Fixes:**
  - Fixed logic bug in Battleground.lua where unknown battlegrounds incorrectly displayed WSG statistics
  - Fixed global variable pollution in Stats.lua (ms_combined now properly scoped)
  - Removed misleading garbage collection message in Stats.lua
  - Added nil-checks for API returns in Location.lua and Battleground.lua to prevent errors during zone transitions
  - Removed duplicate function calls in Battleground.lua and Stats.lua

### Changed
- **DataText Module - Performance Improvements:**
  - Optimized Battleground statistics loop with early break (50-95% performance improvement in 40-player battlegrounds)
  - Improved LFD toggle behavior in Stats.lua by removing redundant calls

## [0.6.0] - 2026-03-13

### Added
- Mouse wheel zoom functionality for World Map with scale clamping.
- Movable and scalable World Map with persistent settings across sessions.
- Enhanced skinning for chat bubbles, FrameStack, and various UI elements.
- German localized versions for README and technical documentation.
- Ascension WoW support to the Shaman Maelstrom module with configurable spell IDs.

### Changed
- Refined default UI skin settings for improved visual consistency.
- Standardized documentation in English with clear localization paths.

### Fixed
- Restored missing v0.4.0 section in CHANGELOG.md.

## [0.5.0] - 2026-03-13

### Added
- Clamp UI scale calculation to prevent extreme values
- Named constants for chat channel assignments for better readability
- New UI screenshot section in README.md
- New walkthrough artifact for better progress tracking

### Changed
- Improved Filger frame creation and spell definitions
- Added configuration validation for better stability
- Enhanced spell info error handling
- Relocated screenshot section in README.md for better visibility

### Removed
- Deprecated `InstallUI` function (replaced by the new multi-step wizard)

## [0.4.0] - 2026-03-13

### Added
- "Save to BudtenderPreset.lua" button in Profile Settings (Developer Mode only)
- Exports current settings to SavedVariables for external script processing
- `export_budtender_preset.sh` script to automatically update BudtenderPreset.lua from SavedVariables
- `EXPORT_PRESET_README.md` with detailed instructions for the export workflow

### Changed
- Redesigned installation wizard with multi-step interface
- Added budsUI logo to installation wizard
- Split 40+ CVARs into 6 logical installation steps:
  - Step 1: Interface settings (action bars, quests, loot)
  - Step 2: Graphics & Camera (UI scale, camera distance, screenshots)
  - Step 3: Combat & Tooltips (buffs, threat, nameplates)
  - Step 4: Chat settings (scroll, style, filters)
  - Step 5: Chat windows layout (3 windows with custom message groups)
  - Step 6: Miscellaneous (minimap, tips, tutorials)
- Installation wizard now shows progress bar and step-by-step descriptions
- Added skip option during installation
- Improved user experience with back/forward navigation through steps

## [0.3.0] - 2026-03-13

### Added
- Automatic profile creation when modifying "Budtender Preset"
- Reset-to-default option for the "Budtender Preset" profile
- Comprehensive profile management system with dedicated UI for creating, selecting, and managing character-specific settings
- Ability to save current settings to profiles

### Changed
- Standardized default profile to 'Default'
- Improved installation logic for UI scale and chat addon detection
- Reworked profile management to use a hardcoded Budtender Preset
- Migrated various settings to character-specific saved options
- Updated reload UI message
- Refactored target cast bar styling
- Increased logo width in README for better display
- Trimmed excess transparency from logo

### Fixed
- Castbar anchors now initialize with valid dimensions
- Locked Blizzard castbar positions to prevent drift
- Removed duplicate mover entry

## [0.2.0] - 2026-03-10

### Added
- Maelstrom Weapon tracker for Shaman with new UI, animations, and configuration options
- Combat state checks for zone changes
- Spell ID checks with lookup tables

### Changed
- Refactored delay and minimap configuration
- Simplified font styles
- Expanded documentation with new slash commands and API details
- Optimized cooldown text scaling
- Refined pet bar event handling
- Refactored toggle bar mouse interaction logic
- Optimized table item removal and wait function
- Implemented grid visibility toggle
- Removed unused border object tracking
- Refined bag item handling
- Throttled nameplate updates
- Optimized data text refresh
- Improved smooth bar scanning for better performance
- Refactored reputation commendation caching
- Improved bag item search logic
- Cleaned up durability module variables
- Optimized Maelstrom Weapon stack detection and display logic
- Suppressed Blizzard's overlay

### Fixed
- Throttled 'Already Known' tooltip scans to reduce CPU usage
- Cached auras for Filger to improve performance
- Optimized WatchFrame updates
- Refined group loot item tooltip behavior
- Conditionally update Battleground data text in PvP only
- Optimized Stats data text updates and tooltip logic
- Improved buff duration formatting
- Refactored item info extraction for grey selling
- Optimized target name retrieval

[Unreleased]: https://github.com/Budtender3000/budsUI/compare/v0.6.0...HEAD
[0.6.0]: https://github.com/Budtender3000/budsUI/compare/v0.5.0...v0.6.0
[0.5.0]: https://github.com/Budtender3000/budsUI/compare/v0.4.0...v0.5.0
[0.4.0]: https://github.com/Budtender3000/budsUI/compare/v0.3.0...v0.4.0
[0.3.0]: https://github.com/Budtender3000/budsUI/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/Budtender3000/budsUI/releases/tag/v0.2.0
