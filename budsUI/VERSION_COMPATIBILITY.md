# WoW Version Compatibility Reference

This document lists all World of Warcraft API elements used by budsUI that require version-specific checks for compatibility with WoW 3.3.5 (Wrath of the Lich King).

## Overview

budsUI was originally developed for newer WoW versions and contains references to UI elements that don't exist in 3.3.5. To ensure compatibility, the addon implements defensive programming through nil checks before accessing these elements.

## Version-Specific API Elements

### GameMenuFrame and Related Buttons

**Introduced:** Post-3.3.5 (exact version unknown)  
**Purpose:** Main game menu that appears when pressing ESC

#### GameMenuFrame
- **Type:** Frame
- **Description:** The main container for the game menu
- **Fallback:** Skip menu integration entirely; features remain accessible via slash commands
- **Implementation:** `budsUI_Config/budsUI_Config.lua`, `budsUI/Modules/Misc/AddonList.lua`

#### GameMenuButtonUIOptions
- **Type:** Button
- **Description:** "Interface" button in the game menu
- **Fallback:** Config GUI not added to menu; accessible via `/kkthnxui` command
- **Implementation:** `budsUI_Config/budsUI_Config.lua` (line ~928)
- **Usage:** Used as reference for sizing and positioning custom menu buttons

```lua
-- Implementation pattern
local Interface = GameMenuButtonUIOptions
if not Interface then
    return  -- Skip menu integration
end
```

#### GameMenuButtonKeybindings
- **Type:** Button
- **Description:** "Key Bindings" button in the game menu
- **Fallback:** Custom buttons use default positioning
- **Implementation:** `budsUI_Config/budsUI_Config.lua` (line ~960)
- **Usage:** Used as anchor point for repositioning other buttons

```lua
-- Implementation pattern
if KeyBinds then
    KeyBinds:SetPoint("TOP", Config, "BOTTOM", 0, -1)
end
```

#### GameMenuButtonMacros
- **Type:** Button
- **Description:** "Macros" button in the game menu
- **Fallback:** Addon list button uses alternative positioning
- **Implementation:** `budsUI/Modules/Misc/AddonList.lua` (line ~145)
- **Usage:** Used as anchor point for addon list button

```lua
-- Implementation pattern
if GameMenuButtonMacros then
    AddonListButton:SetPoint("TOP", GameMenuButtonMacros, "BOTTOM", 0, -1)
end
```

#### GameMenuButtonLogout
- **Type:** Button
- **Description:** "Logout" button in the game menu
- **Fallback:** Button remains in original position
- **Implementation:** `budsUI_Config/budsUI_Config.lua` (line ~965), `budsUI/Modules/Misc/AddonList.lua` (line ~150)
- **Usage:** Repositioned to accommodate custom buttons

```lua
-- Implementation pattern
if GameMenuButtonLogout then
    GameMenuButtonLogout:SetPoint("TOP", AddonListButton, "BOTTOM", 0, -16)
end
```

### InterfaceOptions Elements

**Introduced:** Post-3.3.5 (exact version unknown)  
**Purpose:** Built-in interface configuration panels

#### InterfaceOptionsDisplayPanelShowFreeBagSpace
- **Type:** CheckButton
- **Description:** Checkbox in Interface Options to show free bag space
- **Fallback:** Blizzard's default bag space display may remain visible (cosmetic only)
- **Implementation:** `budsUI/Modules/Blizzard/Bags.lua` (line 38)
- **Usage:** Hidden to prevent conflicts with budsUI's custom bag implementation

```lua
-- Implementation pattern
if InterfaceOptionsDisplayPanelShowFreeBagSpace then
    InterfaceOptionsDisplayPanelShowFreeBagSpace:Hide()
end
```

## Compatibility Pattern

All version-specific API elements follow this defensive programming pattern:

```lua
-- Single operation
if ElementName then
    ElementName:SomeMethod()
end

-- Multiple dependent operations
if ParentElement then
    -- All operations that depend on ParentElement
    local child = ParentElement.ChildElement
    if child then
        child:DoSomething()
    end
end
```

## Impact on Functionality

### On WoW 3.3.5 (Missing Elements)
- **Config GUI:** Not integrated into game menu; accessible via `/kkthnxui` slash command
- **Addon List:** Not integrated into game menu; accessible via `/addons` slash command
- **Bags:** Blizzard's bag space display may show alongside custom bags (minor cosmetic issue)
- **Core Features:** All core functionality remains fully operational

### On Newer WoW Versions (Elements Present)
- **Full Integration:** All menu buttons appear in game menu
- **Proper Positioning:** All UI elements positioned correctly
- **No Regression:** All original functionality preserved

## Testing Results

### WoW 3.3.5 Testing
- ✅ Addon loads without errors
- ✅ Config GUI accessible via `/kkthnxui`
- ✅ Bags module functional
- ✅ Addon list accessible via `/addons`
- ✅ No nil errors during gameplay

### Newer Versions
- ⏳ Pending regression testing
- Expected: All features work as originally designed

## Maintenance Guidelines

When adding new UI element access:

1. **Always check existence first:** Use `if ElementName then` before accessing
2. **Provide fallback behavior:** Ensure addon remains functional when element is missing
3. **Add explanatory comments:** Document why the check is needed
4. **Update this document:** Add new version-specific elements to this list
5. **Test on 3.3.5:** Verify no nil errors occur

## Future Considerations

### Version Detection
For more complex compatibility needs, explicit version detection can be used:

```lua
local tocVersion = select(4, GetBuildInfo())
if tocVersion >= 30400 then
    -- Use newer API
else
    -- Use 3.3.5 compatible code
end
```

However, the nil check approach is simpler and more maintainable for most cases.

### Additional Compatibility Issues
This pattern can be extended to handle:
- Different function signatures between versions
- Renamed API elements
- Changed behavior of existing functions
- New API features in later expansions

## References

- **Specification:** `.kiro/specs/wow-335-api-compatibility/`
- **Requirements:** `.kiro/specs/wow-335-api-compatibility/requirements.md`
- **Design:** `.kiro/specs/wow-335-api-compatibility/design.md`
- **Tasks:** `.kiro/specs/wow-335-api-compatibility/tasks.md`

## Version History

- **Initial Version:** Created as part of WoW 3.3.5 compatibility implementation
- **Elements Documented:** GameMenuFrame, GameMenuButton elements, InterfaceOptions elements
- **Status:** All documented elements have been fixed and tested on 3.3.5
