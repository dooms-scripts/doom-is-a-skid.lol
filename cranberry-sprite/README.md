# CRANBERRY SPRITE UI LIBRARY

# SHOWCASE
![image](https://github.com/dooms-scripts/ui-libraries/assets/140380232/cc56a545-b07b-4aaf-8a54-e5017355d56c)

# HOW TO USE
> Initializing the library
```lua
local sprite = loadstring(game:HttpGet('https://raw.githubusercontent.com/dooms-scripts/ui-libraries/main/cranberry-sprite/sprite.lua')()
```  
> Library settings
```lua
-- ↓↓↓ these are optional settings, if you dont wish to edit a specific thing, simply take it out.
sprite.use_custom_cursor = true
sprite.colors = {
	accent = Color3.fromRGB(255, 0, 0) -- the main GUI color
	foreground = Color3.fromRGB(),
	background = Color3.fromRGB(),
}
```
> Creating a window
```lua
-- ↓↓↓ these are optional settings, if you dont wish to edit a specific thing, simply take it out.
local window = sprite:new_window({
	title = 'cranberry sprite // ui library<font color="rgb(185,185,185)"> | doom#1000</font>',
	bg_img = 'rbxassetid://15688752899',
	bg_img_transparency = 0.95,
	size = UDim2.new(0, 450, 0, 550),
	pos = UDim2.new(0, 500, 0, 200),
	draggable = true,
})
```  
> Creating a tab
```lua
local tab = window:add_tab({
	name = 'tab'
})
```  
> Creating a category
```lua
local category = tab:add_category({
	name = 'category'
})
```
> Creating Elements
```lua
--> creates a text label
local label = category:new_label({
	text = 'text label'
})

--> creates a button
local button = category:new_button({
	text = 'button',
	callback = function()
		warn('this is a button!')
	end)
})

--> creates a toggle
local toggle = category:new_toggle({
	text = 'toggle',
	callback = function(value) -- you can either use a predefined variable, or add an argument to the function like seen here.
		warn('toggle value changed: ' .. tostring(value))
	end),
})

--> creates a keybind
local keybind = category:new_keybind({
	text = 'keybind',
	input_mode = 'click' -- you can set a custom input mode from one of the three: click, hold, toggle
	key = 'E',
	callback = function()
		warn('keybind input')
	end

	--[[
		expanding on input modes
		click: will fire the callback every time the keybind is pressed.
		hold: will keep firing the callback until the keybind is unpressed.
		toggle: will keep firing the callback until the keybind is pressed again.
	]]--
})

--> creates a slider
local slider = category:new_slider({
	text = 'slider',
	allow_decimals = false, -- toggles value rounding
	min = 0, -- the minimum slider value
	max = 100, -- the maximum slider value
	value = 0, -- the default slider value
	callback = function(value)
		warn('slider value changed: ' .. tostring(value))
	end,
})
```
