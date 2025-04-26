# Wally UI Library: Complete Documentation

This comprehensive documentation covers all features, customization options, and implementation details of the Wally UI Library for Roblox.

## Table of Contents
1. [Getting Started](#getting-started)
2. [Window Creation and Configuration](#window-creation-and-configuration)
3. [UI Elements](#ui-elements)
4. [Flags and Data Management](#flags-and-data-management)
5. [Styling and Customization](#styling-and-customization)
6. [Keyboard Controls and Keybinds](#keyboard-controls-and-keybinds)
7. [Working with Rainbow Elements](#working-with-rainbow-elements)
8. [Destroying and Cleaning Up](#destroying-and-cleaning-up)
9. [Tips and Best Practices](#tips-and-best-practices)
10. [Complete Example](#complete-example)

## Getting Started

Load the library with:

```lua
local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/DEVIX7/RBLX_Scripts/refs/heads/master/WallyUi_Fork", true))();
```

## Window Creation and Configuration

### Creating Basic Windows

```lua
local window = library:CreateWindow("Window Title")
```

### Window Position

Windows are automatically positioned horizontally next to each other with a gap of 200 pixels. The first window starts at position 15,0.

```lua
-- These windows will be positioned automatically in sequence
local window1 = library:CreateWindow("First Window")
local window2 = library:CreateWindow("Second Window") -- Will be placed to the right of window1
local window3 = library:CreateWindow("Third Window")  -- Will be placed to the right of window2
```

### Window Objects and Properties

Each window created has these key properties:

```lua
-- Window properties
window.object       -- The actual Frame instance
window.container    -- Container for all elements
window.toggled      -- Boolean state (expanded/collapsed)
window.flags        -- Table storing all flag values
window.count        -- Internal counter
```

### Minimizing Windows

Each window has a "-" button in the top right that collapses/expands the window's content.

## UI Elements

### Label

Creates a simple text label.

```lua
local label = window:Label("This is a label", false) -- Second parameter enables rainbow effect
```

**Advanced usage:**
```lua
-- Rainbow text
local rainbowLabel = window:Label("Rainbow Text", true)

-- Get the TextLabel instance to modify properties
local labelInstance = window:Label("My Label")
labelInstance.TextSize = 20
labelInstance.Font = Enum.Font.GothamBold
```

### Button

Creates a clickable button.

```lua
local button, buttonFunctions = window:Button("Click Me", function()
    print("Button clicked!")
end)
```

**Return values:**
- `button`: The button instance (TextButton)
- `buttonFunctions`: Table with a `Fire()` method to trigger the callback programmatically

**Advanced usage:**
```lua
-- Get the button's TextButton instance to modify properties
local buttonInstance, buttonUtils = window:Button("Special Button", function() end)
buttonInstance.BackgroundColor3 = Color3.fromRGB(255, 0, 0)

-- Programmatically trigger the button
buttonUtils.Fire()
```

### Toggle

Creates a toggle switch.

```lua
local toggle = window:Toggle("Enable Feature", {
    flag = "featureEnabled",  -- Identifier
    default = true,           -- Initial state
    location = _G             -- Where to store value (optional)
}, function(value)
    print("Feature is now:", value)
end)
```

**Return value:** Table with a `Set(boolean)` method to change the toggle state programmatically

**Advanced usage:**
```lua
-- Create a toggle and store reference
local autoFarmToggle = window:Toggle("Auto Farm", {flag = "autoFarm"}, function() end)

-- Later, programmatically update the toggle
autoFarmToggle.Set(true)  -- This will update the UI and run the callback
```

**Toggle Display Styles:**
The library supports two toggle display styles:
- `'Check'`: Shows a checkmark (✓) when enabled (default)
- `'Fill'`: Changes background color when enabled

Set using the window or library options:
```lua
-- For specific window
local window = library:CreateWindow("Window", {toggledisplay = 'Fill'})

-- Or for all windows
library.options.toggledisplay = 'Fill'
```

### TypeBox

Creates a text input box.

```lua
local typebox = window:TypeBox("Enter Name", {
    flag = "playerName",
    default = "Player",
    cleartext = true,         -- Clear when focused
    location = window.flags   -- Where to store value (optional)
}, function(value, oldValue, enterPressed)
    print("Name changed to:", value)
    print("Enter key pressed:", enterPressed)
end)
```

**Return value:** The TextBox instance

**Advanced usage:**
```lua
-- TextBox with specific properties
local emailBox = window:TypeBox("Email", {flag = "email"}, function() end)
emailBox.PlaceholderText = "example@email.com"
emailBox.TextColor3 = Color3.fromRGB(200, 200, 200)
```

### Box

Creates a specialized input box (with label).

```lua
local box = window:Box("Age", {
    type = "number",          -- Use "number" or leave empty for text
    default = 18,
    min = 13,                 -- Only for number type
    max = 99,                 -- Only for number type
    flag = "playerAge",
    location = window.flags
}, function(value, oldValue, enterPressed)
    print("Age set to:", value)
end)
```

**Return value:** Table with:
- `Box`: The TextBox instance
- `SetNew(value)`: Function to update the value

**Advanced usage:**
```lua
-- Create box with min/max validation
local healthBox = window:Box("Health Points", {
    type = "number",
    min = 0,
    max = 100,
    default = 100,
    flag = "health"
}, function(value) end)

-- Later, set a new value
healthBox.SetNew(75) -- This will respect min/max bounds
```

### Slider

Creates a numeric slider.

```lua
local slider = window:Slider("Volume", {
    min = 0,
    max = 100,
    default = 50,
    flag = "volumeLevel",
    precise = false,          -- true for decimals, false for integers
    location = window.flags
}, function(value)
    print("Volume set to:", value)
end)
```

**Return value:** Table with a `Set(number)` method to change the slider value programmatically

**Advanced features:**
- Input box allows direct value entry
- Draggable slider indicator
- Min/max validation

**Advanced usage:**
```lua
-- Create a precise (decimal) slider
local speedSlider = window:Slider("Speed", {
    min = 0,
    max = 10,
    default = 1.5,
    precise = true,  -- Enable decimals
    flag = "speed"
}, function(value) end)

-- Later, programmatically set a value
speedSlider.Set(3.75)
```

### Dropdown

Creates a dropdown selection menu.

```lua
local dropdown = window:Dropdown("Select Weapon", {
    flag = "selectedWeapon",
    list = {"Sword", "Bow", "Axe", "Wand"},
    default = "Sword",
    location = window.flags,
    colors = {               -- Optional custom colors for specific items
        ["Sword"] = Color3.fromRGB(255, 0, 0),
        ["Wand"] = Color3.fromRGB(0, 0, 255)
    }
}, function(selected)
    print("Selected weapon:", selected)
end)
```

**Return value:** Table with a `Refresh(newList, newDefault)` method to update dropdown options

**Advanced usage:**
```lua
-- Create dropdown with custom colors
local classDropdown = window:Dropdown("Class", {
    list = {"Warrior", "Mage", "Archer"},
    flag = "playerClass",
    colors = {
        ["Warrior"] = Color3.fromRGB(255, 0, 0),
        ["Mage"] = Color3.fromRGB(0, 0, 255),
        ["Archer"] = Color3.fromRGB(0, 255, 0)
    }
}, function(selected) end)

-- Later, update the options
local newClasses = {"Knight", "Wizard", "Hunter", "Priest"}
classDropdown.Refresh(newClasses, "Wizard")
```

### SearchBox

Creates a searchable dropdown menu.

```lua
local searchbox = window:SearchBox("Search Items", {
    flag = "selectedItem",
    list = {"Apple", "Banana", "Cherry", "Dragon Fruit", "Elderberry"},
    location = window.flags
}, function(selected)
    print("Selected item:", selected)
end)
```

**Return value:** Table with:
- `Reload(newList)`: Completely replaces the list and rebuilds dropdown
- `Refresh(newList)`: Updates the list without rebuilding dropdown
- `Box`: Reference to the TextBox instance

**Advanced usage:**
```lua
-- Create a searchbox with many items
local itemSearch = window:SearchBox("Find Item", {
    flag = "item",
    list = {"Item1", "Item2", "Item3", "OtherItem1", "OtherItem2"}
}, function(selected) end)

-- Later, update with new items
itemSearch.Refresh({"NewItem1", "NewItem2", "UpdatedItem"})

-- Or get the textbox to modify its properties
itemSearch.Box.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
```

### Bind

Creates a key binding option.

```lua
window:Bind("Sprint Key", {
    flag = "sprintKey",
    default = Enum.KeyCode.LeftShift,
    kbonly = true,           -- Keyboard only (no mouse buttons)
    location = window.flags
}, function()
    print("Sprint key pressed!")
end)
```

**Features:**
- Displays key name in UI
- Handles keyboard and mouse inputs
- Can restrict to keyboard-only inputs
- Shows "..." when waiting for input

**Advanced usage:**
```lua
-- Allow both keyboard and mouse buttons
window:Bind("Attack", {
    flag = "attackKey",
    default = Enum.KeyCode.E,
    kbonly = false  -- Allow mouse buttons
}, function() end)

-- The bind's value can be accessed from location[flag]
-- It stores the actual UserInputType or KeyCode object
```

### Section

Creates a section header to organize UI elements.

```lua
local section = window:Section("Settings", false) -- Second parameter enables rainbow effect
```

**Return value:** The TextLabel instance

**Advanced usage:**
```lua
-- Create a rainbow section header
local header = window:Section("Rainbow Header", true)

-- Modify the section's appearance
header.TextSize = 22
header.Font = Enum.Font.GothamBold
```

### DropSection

Creates a collapsible section for organizing related elements.

```lua
local dropSection = window:DropSection("Advanced Settings")

-- Add elements to the drop section
dropSection:Toggle("Enable Debug", {flag = "debug"}, function() end)
dropSection:Slider("Detail Level", {min = 1, max = 5, flag = "detailLevel"}, function() end)
```

**Return value:** A section object that has all the same UI creation methods as a window

**Methods:**
- `SetText(text)`: Updates the section title
- All UI element methods (`Toggle`, `Button`, `Slider`, etc.)

**Advanced usage:**
```lua
-- Create a dropdown section with custom elements
local combatSection = window:DropSection("Combat Settings")

-- Add elements specifically for combat
combatSection:Toggle("Auto Attack", {flag = "autoAttack"}, function(value) end)
combatSection:Dropdown("Attack Style", {
    flag = "attackStyle",
    list = {"Aggressive", "Defensive", "Controlled"}
}, function(style) end)

-- Later, update the section title
combatSection:SetText("Advanced Combat")
```

## Flags and Data Management

The library uses a flag system to store and access UI element values.

### Basic Flag Usage

```lua
-- Create toggle with flag
window:Toggle("Auto Farm", {flag = "autoFarm"}, function() end)

-- Access the value later
if window.flags.autoFarm then
    -- Do auto farming
end
```

### Custom Storage Locations

By default, flags are stored in `window.flags`, but you can specify a custom location:

```lua
-- Store in a local table
local settings = {}
window:Toggle("Auto Farm", {
    flag = "autoFarm",
    location = settings
}, function() end)

-- Access from your custom table
if settings.autoFarm then
    -- Do auto farming
end

-- Store in global environment
window:Toggle("God Mode", {
    flag = "godMode",
    location = _G
}, function() end)

-- Access from global environment
if _G.godMode then
    -- Enable god mode
end
```

### Shared Storage Across Windows

You can share settings across multiple windows:

```lua
-- Create a shared settings table
local settings = {}

-- Create multiple windows using the same storage
local window1 = library:CreateWindow("Window 1")
local window2 = library:CreateWindow("Window 2")

-- Add toggles that share the same storage
window1:Toggle("Setting 1", {flag = "setting1", location = settings}, function() end)
window2:Toggle("Setting 1 (copy)", {flag = "setting1", location = settings}, function() end)

-- Now toggling either will affect both since they share the same flag and location
```

## Styling and Customization

### Global Style Options

You can set default styles for all windows:

```lua
-- Set global options before creating any windows
library.options.toggledisplay = 'Fill'
library.options.underlinecolor = Color3.fromRGB(0, 255, 0)
library.options.font = Enum.Font.GothamBold

-- Now all windows will use these settings
local window1 = library:CreateWindow("Window 1")
local window2 = library:CreateWindow("Window 2")
```

### Window-Specific Styling

Each window can have its own styling:

```lua
local window1 = library:CreateWindow("Red Window", {
    topcolor = Color3.fromRGB(255, 0, 0),
    underlinecolor = Color3.fromRGB(255, 100, 100)
})

local window2 = library:CreateWindow("Blue Window", {
    topcolor = Color3.fromRGB(0, 0, 255),
    underlinecolor = Color3.fromRGB(100, 100, 255)
})
```

### All Customization Options

```lua
local window = library:CreateWindow("Custom Window", {
    -- Window appearance
    topcolor = Color3.fromRGB(30, 30, 30),         -- Top bar color
    titlecolor = Color3.fromRGB(255, 255, 255),    -- Title text color
    underlinecolor = Color3.fromRGB(0, 255, 0),    -- Underline color (or "rainbow")
    bgcolor = Color3.fromRGB(30, 30, 30),          -- Background color
    boxcolor = Color3.fromRGB(30, 30, 30),         -- Box inner color
    btncolor = Color3.fromRGB(50, 50, 50),         -- Button color
    dropcolor = Color3.fromRGB(30, 30, 30),        -- Dropdown color
    sectncolor = Color3.fromRGB(35, 35, 35),       -- Section/Label colors
    bordercolor = Color3.fromRGB(60, 60, 60),      -- Border color
    
    -- Fonts and sizes
    font = Enum.Font.SourceSans,                   -- Main font
    titlefont = Enum.Font.Code,                    -- Title font
    fontsize = 17,                                 -- Main font size
    titlesize = 18,                                -- Title font size
    
    -- Text appearance
    textstroke = 1,                                -- Text stroke transparency (0-1)
    titlestroke = 1,                               -- Title stroke transparency (0-1)
    strokecolor = Color3.fromRGB(0, 0, 0),         -- Stroke color
    textcolor = Color3.fromRGB(255, 255, 255),     -- Text color
    titletextcolor = Color3.fromRGB(255, 255, 255),-- Title text color
    placeholdercolor = Color3.fromRGB(255, 255, 255), -- Placeholder text color
    titlestrokecolor = Color3.fromRGB(0, 0, 0),       -- Title stroke color
    
    -- Toggle appearance
    toggledisplay = 'Check'                        -- Toggle display style ('Check' or 'Fill')
})
```

## Keyboard Controls and Keybinds

### Default GUI Toggle

By default, pressing `RightControl` toggles the entire UI (hides/shows all windows).

```lua
-- This is built-in and automatically bound
-- When RightControl is pressed, all windows will hide/show
```

### Custom Keybinds

Create custom keybinds with the Bind element:

```lua
window:Bind("Toggle Autorun", {
    flag = "autorunBind",
    default = Enum.KeyCode.R
}, function()
    -- This runs when the bound key is pressed
    _G.autorun = not _G.autorun
    print("Autorun:", _G.autorun)
end)
```

### Handling Keyboard and Mouse Inputs

```lua
-- Keyboard only binds
window:Bind("Action Key", {
    flag = "actionKey",
    kbonly = true,  -- Only allow keyboard keys, no mouse buttons
    default = Enum.KeyCode.F
}, function() end)

-- Keyboard and mouse binds
window:Bind("Attack Key", {
    flag = "attackKey",
    kbonly = false,  -- Allow both keyboard and mouse buttons
    default = Enum.UserInputType.MouseButton2  -- Right mouse button
}, function() end)
```

## Working with Rainbow Elements

The library has built-in rainbow effect support for certain elements.

### Rainbow Title Underline

```lua
-- Create a window with rainbow underline
local window = library:CreateWindow("Rainbow Window", {
    underlinecolor = "rainbow"  -- Special value "rainbow" instead of a Color3
})
```

### Rainbow Text Elements

```lua
-- Create label with rainbow text
window:Label("Rainbow Label", true)  -- Second parameter enables rainbow

-- Create section with rainbow text
window:Section("Rainbow Section", true)  -- Second parameter enables rainbow
```

### How Rainbow Effect Works

The library maintains a `rainbowtable` that cycles through colors for all rainbow elements:

```lua
-- Internal rainbow effect implementation (simplified)
while true do
    for i=0, 1, 1 / 300 do              
        for _, obj in next, library.rainbowtable do
            obj[props[obj.ClassName]] = Color3.fromHSV(i, 1, 1);
        end
        wait()
    end
end
```

## Destroying and Cleaning Up

The library doesn't have a built-in destroy function, but you can implement one:

```lua
function library:DestroyUI()
    -- Remove the ScreenGui
    if self.container and self.container.Parent then
        local screenGui = self.container.Parent
        screenGui:Destroy()
    end
    
    -- Clear all data tables
    self.queue = {}
    self.callbacks = {}
    self.binds = {}
    self.rainbowtable = {}
    self.count = 0
    
    -- Set toggled to false
    self.toggled = false
end

-- Usage
local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/DEVIX7/RBLX_Scripts/refs/heads/master/WallyUi_Fork", true))()
-- Create your UI...
-- When done:
library:DestroyUI()
library = nil  -- Clear the reference
```

## Tips and Best Practices

### Organizing Complex UIs

For complex scripts, organize related settings into separate windows or drop sections:

```lua
-- Create windows for different categories
local mainWindow = library:CreateWindow("Main")
local combatWindow = library:CreateWindow("Combat")
local farmingWindow = library:CreateWindow("Farming")
local settingsWindow = library:CreateWindow("Settings")

-- Use drop sections for subcategories
local mobSettings = farmingWindow:DropSection("Mob Settings")
local lootSettings = farmingWindow:DropSection("Loot Settings")
```

### Managing State Outside Callbacks

Use the flags system to access values outside of callbacks:

```lua
-- Create a shared settings table
local settings = {}

-- Add UI elements that update the settings
window:Toggle("Auto Farm", {flag = "autoFarm", location = settings}, function() end)
window:Dropdown("Target Mob", {flag = "targetMob", location = settings, list = {"Zombie", "Skeleton"}}, function() end)
window:Slider("Farm Speed", {flag = "farmSpeed", location = settings, min = 1, max = 10}, function() end)

-- Use settings in a separate game loop
spawn(function()
    while wait(1) do
        if settings.autoFarm then
            print("Farming " .. settings.targetMob .. " at speed " .. settings.farmSpeed)
            -- Do farming logic here
        end
    end
end)
```

### Updating UI Elements Programmatically

```lua
-- Store references to UI elements
local autoFarmToggle = window:Toggle("Auto Farm", {flag = "autoFarm"}, function() end)
local mobDropdown = window:Dropdown("Mob", {flag = "mob", list = {"Zombie", "Skeleton"}}, function() end)
local speedSlider = window:Slider("Speed", {flag = "speed", min = 1, max = 10}, function() end)

-- Later, update them programmatically
function resetSettings()
    autoFarmToggle.Set(false)
    speedSlider.Set(5)
    mobDropdown.Refresh({"Zombie", "Skeleton", "Dragon"}, "Zombie")
end

-- Add a reset button
window:Button("Reset Settings", resetSettings)
```

### Creating Dynamic UIs

```lua
-- Create a dynamic mob list UI based on available mobs
local mobsInGame = {"Zombie", "Skeleton"}  -- This could be fetched from the game

-- Add mobs dynamically
function refreshMobList()
    -- Get current mobs in game (example)
    local newMobs = {}
    for _, mob in pairs(workspace.Mobs:GetChildren()) do
        table.insert(newMobs, mob.Name)
    end
    
    -- Update the dropdown
    mobDropdown.Refresh(newMobs, newMobs[1])
end

-- Create UI with initial state
local mobDropdown = window:Dropdown("Select Mob", {
    flag = "selectedMob",
    list = mobsInGame
}, function(mob) end)

-- Add refresh button
window:Button("Refresh Mob List", refreshMobList)
```

## Complete Example

Here's a complete example showcasing most features:

```lua
-- Load the library
local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/DEVIX7/RBLX_Scripts/refs/heads/master/WallyUi_Fork", true))()

-- Set global styling
library.options.font = Enum.Font.GothamSemibold
library.options.toggledisplay = 'Fill'

-- Create windows for different categories
local mainWindow = library:CreateWindow("Farm Bot", {
    underlinecolor = "rainbow",
    topcolor = Color3.fromRGB(40, 40, 40)
})

local settingsWindow = library:CreateWindow("Settings", {
    underlinecolor = Color3.fromRGB(0, 255, 0),
    topcolor = Color3.fromRGB(40, 40, 40)
})

-- Create shared settings table
local settings = {
    autoFarm = false,
    mobType = "Zombie",
    farmSpeed = 2,
    farmRadius = 100,
    collectItems = true,
    attackPlayers = false
}

-- Main Window Elements
mainWindow:Section("Auto Farming")

local autoFarmToggle = mainWindow:Toggle("Auto Farm", {
    flag = "autoFarm",
    default = settings.autoFarm,
    location = settings
}, function(value)
    print("Auto Farm:", value)
    -- Implement auto farm logic...
end)

local mobDropdown = mainWindow:Dropdown("Target Mob", {
    flag = "mobType",
    list = {"Zombie", "Skeleton", "Spider", "Dragon"},
    default = settings.mobType,
    location = settings,
    colors = {
        ["Dragon"] = Color3.fromRGB(255, 0, 0)  -- Make Dragon red
    }
}, function(selected)
    print("Selected mob:", selected)
end)

mainWindow:Slider("Farm Speed", {
    flag = "farmSpeed",
    min = 1,
    max = 5,
    default = settings.farmSpeed,
    precise = true,
    location = settings
}, function(value)
    print("Farm speed:", value)
end)

mainWindow:Slider("Farm Radius", {
    flag = "farmRadius",
    min = 10,
    max = 200,
    default = settings.farmRadius,
    location = settings
}, function(value)
    print("Farm radius:", value)
end)

-- Collapsible Combat Section
local combatSection = mainWindow:DropSection("Combat Settings")

combatSection:Toggle("Attack Players", {
    flag = "attackPlayers",
    default = settings.attackPlayers,
    location = settings
}, function(value)
    print("Attack players:", value)
end)

combatSection:Dropdown("Attack Mode", {
    flag = "attackMode",
    list = {"Closest", "Highest Level", "Lowest Health"},
    default = "Closest",
    location = settings
}, function(mode)
    print("Attack mode:", mode)
end)

-- Settings Window Elements
settingsWindow:Section("Game Settings")

settingsWindow:Toggle("Collect Items", {
    flag = "collectItems",
    default = settings.collectItems,
    location = settings
}, function(value)
    print("Collect items:", value)
end)

settingsWindow:Box("Character Name", {
    flag = "characterName",
    default = "Player"
}, function(value)
    print("Character name:", value)
    -- Update character name...
end)

-- Key Binds
settingsWindow:Section("Key Binds")

settingsWindow:Bind("Toggle Farm", {
    flag = "farmKey",
    default = Enum.KeyCode.F,
    location = settings
}, function()
    -- Toggle auto farm when key pressed
    settings.autoFarm = not settings.autoFarm
    autoFarmToggle.Set(settings.autoFarm)
    print("Farm toggled with key:", settings.autoFarm)
end)

-- Reset Button
settingsWindow:Button("Reset All Settings", function()
    -- Reset all settings to default
    settings.autoFarm = false
    settings.mobType = "Zombie"
    settings.farmSpeed = 2
    settings.farmRadius = 100
    settings.collectItems = true
    settings.attackPlayers = false
    
    -- Update UI to match
    autoFarmToggle.Set(false)
    mobDropdown.Refresh({"Zombie", "Skeleton", "Spider", "Dragon"}, "Zombie")
    
    print("All settings reset to default")
end)

-- Main game loop using settings
spawn(function()
    while wait(1) do
        if settings.autoFarm then
            print("Farming " .. settings.mobType .. 
                  " at speed " .. settings.farmSpeed .. 
                  " in radius " .. settings.farmRadius)
            
            -- Farm implementation...
        end
    end
end)
```

This example showcases:
- Multiple windows with different styles
- A shared settings table
- Various UI elements (toggles, dropdowns, sliders)
- Collapsible sections
- Key binds
- UI updating from code
- A game loop that uses the settings

The library offers flexible options for creating intuitive and functional user interfaces for Roblox scripts.
