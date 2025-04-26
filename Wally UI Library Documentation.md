# Wally UI Library Documentation

This documentation covers all functions available in the Wally UI Library for creating user interfaces in Roblox.

## Getting Started

Load the library with:

```lua
local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/DEVIX7/RBLX_Scripts/refs/heads/master/WallyUi_Fork", true))();
```

## Creating a Window

```lua
local window = library:CreateWindow("Window Title", {
    -- Optional customization options
    topcolor = Color3.fromRGB(30, 30, 30),       -- Top bar color
    titlecolor = Color3.fromRGB(255, 255, 255),  -- Title text color
    underlinecolor = Color3.fromRGB(0, 255, 0),  -- Underline color (or "rainbow")
    -- More customization options available - see Customization section
})
```

## UI Elements

### Label

Creates a simple text label.

```lua
window:Label("This is a label" -- required
    -- , true -- optional: rainbow effect
)
```

### Button

Creates a clickable button.

```lua
local button, buttonObj = window:Button("Button Text", -- required
    function() -- required: callback
        print("Button clicked!")
    end
)
```

The function returns the button object and a table with a `Fire()` method to trigger the button programmatically.

### Toggle

Creates a toggle switch.

```lua
local toggle = window:Toggle("Toggle Option", { 
    flag = "toggleFlag",      -- required: identifier for this toggle
    -- default = false,       -- optional: initial state
    -- location = window.flags -- optional: where to store the value (defaults to window.flags)
}, function(value) -- required: callback
    print("Toggle value changed to:", value)
end)
```

Return value has a `Set(bool)` method to change the toggle state programmatically.

### TypeBox

Creates a text input box.

```lua
local textBox = window:TypeBox("Enter Text", {
    flag = "textBoxFlag",     -- required: identifier
    -- default = "",          -- optional: default text
    -- cleartext = true,      -- optional: clear on focus (defaults to true)
    -- location = window.flags -- optional: where to store the value
}, function(value, oldValue, enterPressed) -- required: callback
    print("Text box value changed to:", value)
end)
```

### Box

Creates a specialized input box (for numbers or text).

```lua
local box = window:Box("Box Name", {
    type = "number",          -- required: "number" or leave empty for text
    flag = "boxFlag",         -- required: identifier
    -- default = "",          -- optional: default value
    -- min = 0,               -- optional: minimum value (for number type)
    -- max = 100,             -- optional: maximum value (for number type)
    -- location = window.flags -- optional: where to store the value
}, function(value, oldValue, enterPressed) -- required: callback
    print("Box value changed to:", value)
end)
```

Returns a table with the box object and `SetNew(value)` method.

### Slider

Creates a numeric slider.

```lua
local slider = window:Slider("Slider Name", {
    min = 0,                  -- required: minimum value
    max = 100,                -- required: maximum value
    flag = "sliderFlag",      -- required: identifier
    -- default = 50,          -- optional: default value
    -- precise = false,       -- optional: use integers (false) or decimals (true)
    -- location = window.flags -- optional: where to store the value
}, function(value) -- required: callback
    print("Slider value changed to:", value)
end)
```

Returns an object with a `Set(value)` method.

### Dropdown

Creates a dropdown selection menu.

```lua
local dropdown = window:Dropdown("Dropdown Name", {
    flag = "dropdownFlag",    -- required: identifier
    list = {"Option 1", "Option 2", "Option 3"}, -- required: list of options
    -- default = "Option 1",  -- optional: default selection
    -- colors = {},           -- optional: color table for specific options
    -- location = window.flags -- optional: where to store the value
}, function(selected) -- required: callback
    print("Selected:", selected)
end)
```

Returns an object with a `Refresh(newList, newDefault)` method to update options.

### SearchBox

Creates a searchable dropdown.

```lua
local searchbox = window:SearchBox("Search Placeholder", {
    flag = "searchFlag",      -- required: identifier
    list = {"Item 1", "Item 2", "Item 3"}, -- required: searchable items
    -- location = window.flags -- optional: where to store the value
}, function(selected) -- required: callback
    print("Selected from search:", selected)
end)
```

Returns an object with `Reload(newList)`, `Refresh(newList)`, and `Box` properties.

### Bind

Creates a key binding option.

```lua
window:Bind("Bind Name", {
    flag = "bindFlag",        -- required: identifier
    -- default = Enum.KeyCode.F, -- optional: default key
    -- kbonly = false,        -- optional: keyboard only (no mouse buttons)
    -- location = window.flags -- optional: where to store the value
}, function() -- required: callback when key is pressed
    print("Key bind activated!")
end)
```

### Section

Creates a section header to organize UI elements.

```lua
local section = window:Section("Section Name" -- required
    -- , true -- optional: rainbow effect
)
```

### DropSection

Creates a collapsible section.

```lua
local dropSection = window:DropSection("Collapsible Section") -- required
```

The returned object can be used to add UI elements within the collapsible section. It supports all the same UI elements as a window:

```lua
dropSection:Toggle("Option in section", {flag = "sectionToggle"}, function(value) end)
dropSection:Button("Section Button", function() end)
dropSection:Slider("Section Slider", {min = 0, max = 10, flag = "sectionSlider"}, function(value) end)
-- etc...
```

The drop section object also has a `SetText(newText)` method to change the section title.

## Working with Flags

All UI elements with a `flag` parameter store their values in a table. By default, they are stored in `window.flags`, but you can specify a custom location:

```lua
-- Using the default window.flags
window:Toggle("Auto Farm", {flag = "autoFarm"}, function() end)
print("Auto farm is:", window.flags.autoFarm)

-- Using a custom table
local settings = {}
window:Toggle("Auto Farm", {
    flag = "autoFarm",
    location = settings
}, function() end)
print("Auto farm is:", settings.autoFarm)

-- Using the global table
window:Toggle("Auto Farm", {
    flag = "autoFarm",
    location = _G
}, function() end)
print("Auto farm is:", _G.autoFarm)
```

## Customization Options

When creating a window, you can customize its appearance with these options:

```lua
local window = library:CreateWindow("Customized Window", {
    topcolor = Color3.fromRGB(30, 30, 30),         -- Top bar color
    titlecolor = Color3.fromRGB(255, 255, 255),    -- Title text color
    underlinecolor = Color3.fromRGB(0, 255, 0),    -- Underline color (or "rainbow")
    bgcolor = Color3.fromRGB(30, 30, 30),          -- Background color
    boxcolor = Color3.fromRGB(30, 30, 30),         -- Box inner color
    btncolor = Color3.fromRGB(50, 50, 50),         -- Button color
    dropcolor = Color3.fromRGB(30, 30, 30),        -- Dropdown color
    sectncolor = Color3.fromRGB(35, 35, 35),       -- Section/Label colors
    bordercolor = Color3.fromRGB(60, 60, 60),      -- Border color
    
    font = Enum.Font.SourceSans,                   -- Main font
    titlefont = Enum.Font.Code,                    -- Title font
    
    fontsize = 17,                                 -- Main font size
    titlesize = 18,                                -- Title font size
    
    textstroke = 1,                                -- Text stroke transparency
    titlestroke = 1,                               -- Title stroke transparency
    
    strokecolor = Color3.fromRGB(0, 0, 0),         -- Stroke color
    
    textcolor = Color3.fromRGB(255, 255, 255),     -- Text color
    titletextcolor = Color3.fromRGB(255, 255, 255),-- Title text color
    
    placeholdercolor = Color3.fromRGB(255, 255, 255), -- Placeholder text color
    titlestrokecolor = Color3.fromRGB(0, 0, 0),       -- Title stroke color
    
    toggledisplay = 'Check'                        -- Toggle display style ('Check' or 'Fill')
})
```

## Key Controls

By default, the UI can be toggled with the `RightControl` key. All windows of the UI will hide/show together when this key is pressed.

## Complete Example

```lua
local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/DEVIX7/RBLX_Scripts/refs/heads/master/WallyUi_Fork", true))();

-- Create a window with custom colors
local window = library:CreateWindow("My Script", {
    topcolor = Color3.fromRGB(40, 40, 40),
    underlinecolor = "rainbow"
})

-- Create a section
window:Section("Main Settings")

-- Add a toggle
local autoFarmToggle = window:Toggle("Auto Farm", {
    flag = "autoFarm",
    default = false
}, function(value)
    print("Auto Farm:", value)
end)

-- Add a slider
local speedSlider = window:Slider("Speed", {
    min = 1,
    max = 10,
    default = 5,
    flag = "speed",
    precise = true
}, function(value)
    print("Speed set to:", value)
end)

-- Add a dropdown
local mobDropdown = window:Dropdown("Select Mob", {
    flag = "selectedMob",
    list = {"Zombie", "Skeleton", "Dragon"},
    default = "Zombie"
}, function(selected)
    print("Selected mob:", selected)
end)

-- Create a collapsible section
local advancedSettings = window:DropSection("Advanced Settings")

-- Add elements to the collapsible section
advancedSettings:Toggle("Show Hitboxes", {flag = "hitboxes", default = true}, function(value)
    print("Show hitboxes:", value)
end)

advancedSettings:Slider("Render Distance", {
    min = 10,
    max = 500,
    default = 100,
    flag = "renderDistance"
}, function(value)
    print("Render distance:", value)
end)

-- Add a button to reset settings
window:Button("Reset Settings", function()
    autoFarmToggle.Set(false)
    speedSlider.Set(5)
    mobDropdown.Refresh({"Zombie", "Skeleton", "Dragon"}, "Zombie")
    print("Settings reset")
end)

-- Create a bind
window:Bind("Farm Key", {
    flag = "farmKey",
    default = Enum.KeyCode.F
}, function()
    print("Farm key pressed")
end)

-- Game loop using the settings
while true do
    wait(1)
    
    if window.flags.autoFarm then
        print("Farming " .. window.flags.selectedMob .. " at speed " .. window.flags.speed)
    end
end
```