# Bug Fix: Settings Not Getting Saved

## Issue
GitHub Issue #1: Settings were not being saved when users changed options in the config GUI. Even after reloading the UI with `/rl`, all settings would revert to defaults.

## Root Cause
The profile system was initializing with an empty `Profiles` table, but no default profile was being created for new users. This caused:

1. `GetActiveProfile()` to return "Unknown" for new characters
2. The Config GUI's `SetValue()` function to silently fail when trying to save to a non-existent profile
3. All settings changes to be lost on reload

## Solution
Added automatic default profile creation in two places:

### 1. Profile Core Initialization (`budsUI/Modules/Profiles/Core.lua`)
Added `EnsureValidProfile()` function that:
- Checks if the current character has a valid active profile assigned
- Creates a "Default" profile if none exists
- Assigns the profile to the current character
- Runs during `ADDON_LOADED` event to ensure SavedVariables are loaded

### 2. Config GUI Safeguard (`budsUI_Config/budsUI_Config.lua`)
Enhanced `SetValue()` function to:
- Detect when no valid profile exists
- Automatically create a "Default" profile on-the-fly
- Notify the user that a default profile was created
- Continue with saving the setting

## Testing
To verify the fix works:

1. Delete your WTF folder (or just the budsUI SavedVariables)
2. Start the game with a fresh character
3. Open config with `/buds` or `/config`
4. Change any setting (e.g., disable AutoScale)
5. Type `/rl` to reload
6. Open config again - settings should be preserved

## Files Modified
- `budsUI/Modules/Profiles/Core.lua` - Added automatic profile creation
- `budsUI_Config/budsUI_Config.lua` - Added safeguard in SetValue function

## Impact
- Fixes settings persistence for all new users
- Fixes settings persistence for existing users who had no profile assigned
- No breaking changes to existing functionality
- Backward compatible with existing profiles
