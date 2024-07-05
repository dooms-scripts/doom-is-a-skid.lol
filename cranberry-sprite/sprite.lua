--[[
                                                                                                                                                                                             
--	              .:-==--:                       =+++:     :-                  
--	            :=++=--=++.                     :++++=    -+-                  
--	           .+++-    -: ::::::.     .::. :-:  .:-:  .-+++::  .::--:.        
--	           .++++:     :+++==+++=   +++-=++-:+==:.==++++==::=++-.=++:       
--	            :++++-   .+++=  -+++- =+++:  :.+++=   -+++:  =+++. .++=.       
--	             .=+++=  =++=   =+++:-+++:    =+++.  :+++-  =+++:.-+=:         
--	        :-    .++++ -+++:  -+++-.+++-    -+++:  .+++=  :+++=               
--	        =+=:..-+++::+++-  -++=. =++=    .+++=   =+++.  .++++:  .:.         
--	       .=++++++=- .=++=.:=-:.  -===.    ==+=   -+++:    :=+++=-:           
--	                  =+++.                                                    
--	                 -+++:                                                     
--	                 ....                                                                                                              

		CRANBERRY SPRITE UI LIB
		-----------------------
		: FULLY UNDETECTABLE UI LIB (Safe to use in games with CoreGui checks like Peroxide etc.)
		: MADE BY DOOM.LOL
		: MADE WITH DOOMS GUI TO LUA CONVERTER

]]--

--[[ LIBRARY DATA ]]-------------------------------------------------
local library = {
	version = '1.2.5',
	use_custom_cursor = true,
	threads = {}, connections = {},
	custom_cursor = {
		enabled = false
	},
	colors = {
		accent = Color3.fromRGB(255, 0, 0),
		foreground = Color3.fromRGB(),
		background = Color3.fromRGB(),
	}
}

--[[ + ]]------------------------------------------------------------
cloneref = cloneref or nil
local clone_service = cloneref or function(...) return ... end

local services = setmetatable({}, {__index = function(self, name)
	local new_service = clone_service(game:GetService(name))
	self[name] = new_service
	return new_service
end})

--[[ DEPENDENCIES ]]-------------------------------------------------
local run_service = services.RunService
local input_service = services.UserInputService
local tween_service = services.TweenService
local players = services.Players

--// METHODS
local tween_info = TweenInfo
local easing_style = Enum.EasingStyle
local easing_direction = Enum.EasingDirection
local ease_style = Enum.EasingStyle.Linear
local ease_direction = Enum.EasingDirection.InOut

local plr = players.LocalPlayer
local mouse = plr:GetMouse()

--[[ FUNCTIONS ]]----------------------------------------------------
function library:exit_threads()
	if pcall(function() 
			for _, thread in pairs(library.threads) do
				pcall(function() task.cancel(thread) end)
				pcall(function() coroutine.close(thread) end)
			end
		end) then 
		warn('Successfully exited threads.')
	end
end

--// CLOSE ALL RBX_SCRIPT_CONNECTIONS WITHIN THE LIBRARY
function library:exit_connections()
	if pcall(function() 
			for _, connection in pairs(library.connections) do
				if typeof(connection) == 'RBXScriptConnection' then
					connection:Disconnect()
				end
			end
		end) then
		warn('Successfully exited connections.')
	end
end

--// CLOSE ALL COROUTINES, TASKS WITHIN THE LIBRARY
function library:exit()
	if library.GUI then library.GUI:Destroy() end

	if not pcall(function() library:exit_threads() end) then warn('Failed to exit lib threads') end
	if not pcall(function() library:exit_connections() end) then warn('Failed to exit lib connections') end

	input_service.MouseIconEnabled = true

	warn('> sprite closed')
end

--// ENCRYPT NAMES FUNCTION
local function encrypt_name()
	local characters = [[救效须介首助职例热毕节害击乱态嗯宝倒注]]
	local characters = "azxcvnmiopqyu1234567890"
	local str = ''
	for i=1, 99 do
		str = str .. characters:sub(
			math.random(1, #characters), 
			math.random(1, #characters)
		)
	end

	return str
end

--// SAFELOAD FUNCTION
local function safe_load(instance : Instance, encrypt_names : boolean)
	local cloneref = cloneref or function(...) return ... end
	local elevated_state = pcall(function() local a = cloneref(game:GetService("CoreGui")):GetFullName() end)

	if encrypt_names then
		for _,__ in ipairs(instance:GetDescendants()) do
			__.Name = encrypt_name()
		end
	end

	local service = setmetatable({},{__index = function(self,name)
		local serv = cloneref(game:GetService(name))
		self[name] = serv
		return serv
	end})

	instance.Parent = elevated_state and service.CoreGui
end

--// INSTANCE CREATE FUNCTION
local function create(instance : string, properties : {})
	local i = Instance.new(instance)
	for p,v in pairs(properties) do
		local s, err = pcall(function()
			i[p] = v
		end)

		if err then 
			warn('[...] PROBLEM CREATING INSTANCE "'..instance..'": '..err) 
		end
	end

	return i
end

--// TABLE OVERWRITE FUNCTION
local function overwrite(to_overwrite : {}, overwrite_with : {})
	for i, v in pairs(overwrite_with) do
		if type(v) == 'table' then
			to_overwrite[i] = overwrite(to_overwrite[i] or {}, v)
		else
			to_overwrite[i] = v
		end
	end

	return to_overwrite or nil
end

--// GET CHILDREN OF CLASS
local function GetChildrenOfClass(instance : Instance, class : string)
	local children = {}

	for _,__ in ipairs(instance:GetChildren()) do
		if __:IsA(class) then
			table.insert(children, __)
		end
	end

	return children or nil
end

--// GET DESCENDANTS OF CLASS
local function GetDescendantsOfClass(instance : Instance, class : string)
	local descendants = {}

	for _,__ in ipairs(instance:GetDescendants()) do
		if __:IsA(class) then
			table.insert(descendants, __)
		end
	end

	return descendants or nil
end

--// UPDATE CUSTOM CURSOR POSITION
local function update_cursor(...)
	local position = ...

	if library.use_custom_cursor then
		input_service.MouseIconEnabled = not library.custom_cursor.enabled
		library.custom_cursor.image.Visible = library.custom_cursor.enabled

		library.custom_cursor.image.Position = UDim2.new(0, position.x, 0, position.y)
	else
		input_service.MouseIconEnabled = true
		library.custom_cursor.image.Visible = false
	end
end

--// LOOP UPDATE CURSOR POSITION AND VISIBILITY
local function reposition_cursor()
	repeat task.wait() update_cursor({ x = mouse.X, y = mouse.Y }) until nil
end

--[[ CREATE UI ]]----------------------------------------------------
library.GUI = create("ScreenGui", {Name = [[cranberry sprite | doom.lol | ]] .. encrypt_name();Parent = nil;ZIndexBehavior = Enum.ZIndexBehavior.Sibling;})
library.custom_cursor.image = create('ImageLabel', { Parent = library.GUI, AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 1.000, BorderColor3 = Color3.fromRGB(0, 0, 0), BorderSizePixel = 0, Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.new(0, 25, 0, 25), Image = 'http://www.roblox.com/asset/?id=16710247795', Visible = false, ZIndex = 99999, })

--// ATTEMPT TO SAFELY LOAD THE LIBRARY TO THE CORE, EXIT LIBRARY IF FAILED
if not pcall(function() safe_load(library.GUI, true) end) then
	warn('Cranberry Sprite failed to load: cannot load sprite to an elevated state; For your safety, sprite is closing.')
	library:exit()
	return
end

--// WINDOW CREATION FUNCTION
function library:new_window(...)
	local window, data = {}, {
		title = 'cranberry sprite // ui library<font color="rgb(185,185,185)"> | doom#1000</font>',
		size = UDim2.new(0, 450, 0, 550),
		position = UDim2.new(0, 500, 0, 200),
		anchor = Vector2.new(0, 0),
		draggable = true,
		bg_img = 'rbxassetid://15688752899',
		bg_img_transparency = 0.95,
	}

	local window_data = overwrite(data, ... or {})

	local window_frame = create("Frame", {Name = encrypt_name();Parent = library.GUI;Draggable = false;AnchorPoint = window_data.anchor; BorderSizePixel = 0;Size = window_data.size;BorderColor3 = Color3.fromRGB(45, 45, 45);BorderMode = Enum.BorderMode.Inset;Position = window_data.position;BackgroundColor3 = Color3.fromRGB(40, 40, 40);Active=true;Selectable=true;})
	local tab_holder = create("Frame", {Name = encrypt_name();Parent = window_frame;AnchorPoint = Vector2.new(0.5, 1);ZIndex = 2;BorderSizePixel = 0;Size = UDim2.new(1, 0, 1, -45);BorderColor3 = Color3.fromRGB(0, 0, 0);LayoutOrder = 2;Position = UDim2.new(0.5, 0, 1, 0);BackgroundTransparency = 1;BackgroundColor3 = Color3.fromRGB(255, 255, 255);})
	local top_bar = create("Frame", {Name = encrypt_name();Parent = window_frame;Size = UDim2.new(1, 0, 0, 25);BorderColor3 = Color3.fromRGB(58, 58, 58);BorderMode = Enum.BorderMode.Inset;BackgroundColor3 = Color3.fromRGB(40, 40, 40);})
	local label = create("TextLabel", {Name = encrypt_name(); Parent = top_bar; TextStrokeTransparency = 0.5;BorderSizePixel = 0;RichText = true;BackgroundColor3 = Color3.fromRGB(255, 255, 255);AnchorPoint = Vector2.new(0.5, 0);TextSize = 14;Size = UDim2.new(1, 0, 1, 0);TextXAlignment = Enum.TextXAlignment.Left;BorderColor3 = Color3.fromRGB(0, 0, 0);Text = string.format(window_data.title);TextStrokeColor3 = Color3.fromRGB(18, 18, 18);Font = Enum.Font.Code;Position = UDim2.new(0.5, 0, 0, 0);TextColor3 = library.colors.accent;BackgroundTransparency = 1;})
	local line = create("Frame", {Name = encrypt_name();Parent = top_bar;BorderSizePixel = 0;Size = UDim2.new(1, 0, 0, 1);BorderColor3 = Color3.fromRGB(0, 0, 0);BackgroundColor3 = library.colors.accent;})
	local tab_buttons = create("Frame", {Name = encrypt_name();Parent = window_frame;BorderSizePixel = 0;Size = UDim2.new(1, 0, 0, 20);BorderColor3 = Color3.fromRGB(0, 0, 0);LayoutOrder = 1;BackgroundTransparency = 1;BackgroundColor3 = Color3.fromRGB(255, 255, 255);})
	local background_image = create("ImageLabel", {Name = encrypt_name();Parent = window_frame;LayoutOrder = 99;AnchorPoint = Vector2.new(0.5, 0.5);Image = window_data.bg_img;BorderSizePixel = 0;Size = UDim2.new(1, 0, -1, 45);ScaleType = Enum.ScaleType.Stretch;BorderColor3 = Color3.fromRGB(0, 0, 0);ImageTransparency = window_data.bg_img_transparency;BackgroundTransparency = 1;BackgroundColor3 = Color3.fromRGB(255, 255, 255);})
	create("UIPadding", {Name = encrypt_name();Parent = label;PaddingLeft = UDim.new(0, 6);})
	create("UIStroke", {Name = encrypt_name();Parent = window_frame;Color = Color3.fromRGB(29, 29, 29);})
	create("UIGradient", {Name = encrypt_name();Parent = top_bar;Rotation = 90;Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255));ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 200, 200));});})
	create("UIGradient", {Name = encrypt_name();Parent = window_frame;Rotation = 90;Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255));ColorSequenceKeypoint.new(1, Color3.fromRGB(176, 176, 176));});})
	create("UIPadding", {Name = encrypt_name();PaddingTop = UDim.new(0, 6);Parent = tab_holder;PaddingRight = UDim.new(0, 6);PaddingLeft = UDim.new(0, 6);PaddingBottom = UDim.new(0, 6);})
	create("UIPadding", {Name = encrypt_name();Parent = tab_buttons;PaddingRight = UDim.new(0, 6);PaddingLeft = UDim.new(0, 6);})
	create("UIListLayout", {Name = encrypt_name(); FillDirection = Enum.FillDirection.Horizontal;Parent = tab_buttons;Padding = UDim.new(0, 10);SortOrder = Enum.SortOrder.LayoutOrder;})
	create("UIListLayout", {Name = encrypt_name();Parent = window_frame;SortOrder = Enum.SortOrder.LayoutOrder;})

	--[[
			Dependancies
	]]--
	
	-- >> Services
	local Players = game:GetService('Players')
	local InputService = game:GetService('UserInputService')
	
	-- >> Variables
	local Player = Players.LocalPlayer
	local Mouse = Player:GetMouse()
	
	local Dragging = false;
	local DragStartPos = nil;
	local FrameStartPos = nil;
	local DeltaPosition = nil;
	
	-- >> Functions
	function ValidInput(InputType)
		if InputType == Enum.UserInputType.MouseButton1 then return true end
		if InputType == Enum.UserInputType.MouseMovement then return true end
		if InputType == Enum.UserInputType.Touch then return true end
	end
	
	--[[
			Connections
	]]--
	
	-- >> Input Began
	InputService.InputBegan:Connect(function(Input)
		local InputType = Input.UserInputType
		
		if ValidInput(InputType) and window_frame.GuiState == Enum.GuiState.Press then
			DragStartPos = Input.Position
			FrameStartPos = window_frame.Position
			Dragging = true
		end
		
		-- >> Input Ended
		Input.Changed:Connect(function(InputType)
			local InputState = Input.UserInputState
			
			if InputState == Enum.UserInputState.End then
				Dragging = false
			end
		end)
	end)
	
	-- >> Input Changed
	InputService.InputChanged:Connect(function(Input)
		local InputType = Input.UserInputType
	
		if ValidInput(InputType) then
			if Dragging then
				DeltaPosition = Input.Position - DragStartPos
	
				window_frame.Position = UDim2.new(
					FrameStartPos.X.Scale, FrameStartPos.X.Offset + DeltaPosition.X,
					FrameStartPos.Y.Scale, FrameStartPos.Y.Offset + DeltaPosition.Y
				)
			end
		end
	end)

	function window:toggle()
		window_frame.Visible = not window_frame.Visible
	end

	function window:close() 
		window_frame:Destroy()
	end

	function window:update(...)
		local data = overwrite(data, ... or {})

		label.Text = data.title
		window_frame.Size = data.size
		window_frame.Position = data.position
		window_frame.Draggable = data.draggable
		background_image.Image = data.bg_img
		background_image.ImageTransparency = data.ImageTransparency
	end

	window_frame.MouseEnter:Connect(function()
		library.custom_cursor.enabled = true
	end)

	window_frame.MouseLeave:Connect(function()
		library.custom_cursor.enabled = false
	end)

	function window:add_tab(...)
		local tab, data = {}, {
			name = 'tab',
		}

		local tab_data = overwrite(data, ... or {})

		local tab_frame = create("Frame", {Parent = tab_holder;Size = UDim2.new(1, 0, 1, 0);Visible=false;ClipsDescendants = false;BorderColor3 = Color3.fromRGB(255, 255, 255);BorderMode = Enum.BorderMode.Inset;Name = [[tab_frame]];BackgroundTransparency = 1;BackgroundColor3 = Color3.fromRGB(35, 35, 35);})
		local tab_button = create("TextButton", {TextStrokeTransparency = 0;BorderSizePixel = 0;BackgroundColor3 = Color3.fromRGB(255, 255, 255);Parent = tab_buttons;TextSize = 13;Size = UDim2.new(0, 75, 1, 0);BorderColor3 = Color3.fromRGB(0, 0, 0);Text = tab_data.name;TextStrokeColor3 = Color3.fromRGB(18, 18, 18);Font = Enum.Font.Code;Name = [[tab_button]];TextColor3 = Color3.fromRGB(255, 255, 255);BackgroundTransparency = 1;})
		local line = create("Frame", {Visible = false;Parent = tab_button;AnchorPoint = Vector2.new(0, 1);Size = UDim2.new(1, 0, 0, 1);BorderColor3 = Color3.fromRGB(28, 28, 28);Name = [[line]];Position = UDim2.new(0, 0, 1, 0);BackgroundColor3 = library.colors.accent;})
		create("UIStroke", {Name = [[outline]];Parent = tab_frame;Enabled = false;Color = Color3.fromRGB(20, 20, 20);})
		create("UIGradient", {Name = [[gradient]];Parent = tab_frame;Rotation = 90;Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255));ColorSequenceKeypoint.new(0.8287197351455688, Color3.fromRGB(253, 253, 253));ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 200, 200));});})
		create("UIPadding", {Name = [[padding]];Parent = tab_frame;PaddingTop = UDim.new(0, 2)})

		-->> automatically resize tab buttons based on text
		coroutine.wrap(function() 
			task.wait(0.1)
			local bounds = tab_button.TextBounds
			local bound_x = bounds.X

			tab_button.Size = UDim2.new(0, bound_x, 1, 0)
		end)()

		local function GetCategoryFrames()
			local frames = {}
			for _, child in ipairs(tab_frame:GetChildren()) do
				if child:IsA("Frame") and child.Name == "category_frame" then
					table.insert(frames, child)
				end
			end
			return frames
		end
		
		local function PositionCategoryFrames(frames)
			local count = 0
			local sizeY = 0
			local anchor = 0
			local padding = 10
			local switched = false
	
			for index, category in ipairs(frames) do
				count = count + 1
	
				if count > 1 then
					local lastFrame = frames[index - 1]
	
					if sizeY + category.Size.Y.Offset + padding > tab_frame.AbsoluteSize.Y then
						--> warn("Switched")
						switched = not switched
						sizeY = 0
						anchor = 1
	
						category.Position = UDim2.new(
							anchor, 
							0, 
							0, 
							0
						)
					else
						sizeY = sizeY + category.Size.Y.Offset + padding
	
						category.Position = UDim2.new(
							anchor, 
							0, 0, 
							lastFrame.Position.Y.Offset + lastFrame.Size.Y.Offset + padding
						)
					end
	
					if sizeY > tab_frame.AbsoluteSize.Y then
						--> warn("Switched")
						switched = not switched
						sizeY = 0
						anchor = 1
					end
	
					category.AnchorPoint = Vector2.new(anchor, 0)
				else
					sizeY = sizeY + category.Size.Y.Offset
				end
			end
		end
	
		local function Reposition()
			local frames = GetCategoryFrames()
			PositionCategoryFrames(frames)
			PositionCategoryFrames(frames)
		end

		tab_button.MouseButton1Click:Connect(function()
			for _, button in ipairs(tab_buttons:GetChildren()) do 
				if button:IsA('TextButton') then
					button.TextColor3 = Color3.fromRGB(255, 255, 255)

					for _, line in ipairs(GetChildrenOfClass(button, 'Frame')) do
						line.Visible = false
					end
				end
			end

			for _, tab in ipairs(tab_holder:GetChildren()) do
				if tab:IsA('Frame') then tab.Visible = false end
			end

			tab_button.TextColor3 = library.colors.accent
			line.Visible = true
			tab_frame.Visible = true
		end)

		function tab:add_category(...)
			local category, data = { elements = 0 }, {
				name = 'category'
			}

			local category_data = overwrite(data, ... or {})

			local category_frame = create("Frame", {Parent = tab_frame;Size = UDim2.new(0.5, -5, 0, 18);BorderColor3 = Color3.fromRGB(50, 50, 50);BorderMode = Enum.BorderMode.Inset;Name = [[category_frame]];BackgroundTransparency = 0.15000000596046448;BackgroundColor3 = Color3.fromRGB(30, 30, 30);})
			local top_bar = create("Frame", {Parent = category_frame;BorderSizePixel = 0;Size = UDim2.new(1, 0, 0, 10);BorderColor3 = Color3.fromRGB(0, 0, 0);Name = [[top_bar]];BackgroundTransparency = 1;BackgroundColor3 = Color3.fromRGB(255, 255, 255);})
			local line = create("Frame", {Parent = top_bar;BorderSizePixel = 0;Size = UDim2.new(1, 0, 0, 1);BorderColor3 = Color3.fromRGB(0, 0, 0);Name = [[line]];BackgroundColor3 = library.colors.accent;})
			local label = create("TextLabel", {TextStrokeTransparency = 0;BorderSizePixel = 0;RichText = true;BackgroundColor3 = Color3.fromRGB(30, 30, 30);Parent = top_bar;TextSize = 13;Size = UDim2.new(0, 66, 0, 10);BorderColor3 = Color3.fromRGB(0, 0, 0);Text = category_data.name;TextStrokeColor3 = Color3.fromRGB(18, 18, 18);Font = Enum.Font.Code;Name = [[label]];Position = UDim2.new(0.05, 0, 0, -2);TextColor3 = Color3.fromRGB(255, 255, 255);})
			create("UIStroke", {Name = [[outline]];Parent = category_frame;Color = Color3.fromRGB(20, 20, 20);})
			create("UIListLayout", {Name = [[list_layout]];Parent = category_frame;SortOrder = Enum.SortOrder.LayoutOrder;})
			create("UIPadding", {Name = [[text_padding]];Parent = label;PaddingBottom = UDim.new(0, 7);})

			coroutine.wrap(function() 
				task.wait(0.1)
				local bounds = label.TextBounds
				local bound_x = bounds.X

				label.Size = UDim2.new(0, bound_x + 10, 0, 10)
			end)()

			function category:new_label(...)
				category.elements += 1
				category_frame.Size += UDim2.new(0, 0, 0, 20)

				local label, data = {}, {
					text = 'text label',
					alignment = 'Left',
				}

				local data = overwrite(data, ... or {})

				local label_frame = create("Frame", {Parent = category_frame;BorderSizePixel = 0;Size = UDim2.new(1, 0, 0, 20);BorderColor3 = Color3.fromRGB(0, 0, 0);Name = [[label_frame]];BackgroundTransparency = 1;BackgroundColor3 = Color3.fromRGB(255, 255, 255);})
				local label_text = create("TextLabel", {TextStrokeTransparency = 0.5;RichText=true;BorderSizePixel = 0;BackgroundColor3 = Color3.fromRGB(255, 255, 255);Parent = label_frame;AnchorPoint = Vector2.new(0, 0.5);TextSize = 13;Size = UDim2.new(1, 0, 1, 0);TextXAlignment = Enum.TextXAlignment[data.alignment];BorderColor3 = Color3.fromRGB(0, 0, 0);Text = data.text;TextStrokeColor3 = Color3.fromRGB(18, 18, 18);Font = Enum.Font.Code;Name = [[label_text]];Position = UDim2.new(0, 0, 0.5, 0);TextColor3 = Color3.fromRGB(150, 150, 150);BackgroundTransparency = 1;})
				local padding = create("UIPadding", {Name = [[padding]];Parent = label_frame;PaddingRight = UDim.new(0, 6);PaddingLeft = UDim.new(0, 6);})

				task.spawn(function() task.wait() Reposition() end)
				return label
			end

			function category:new_button(...)
				category.elements += 1
				category_frame.Size += UDim2.new(0, 0, 0, 22)

				local button, data = {}, {
					text = 'button',
					callback = function ()
						warn('No callback has been set to button')
					end
				}

				local data = overwrite(data, ... or {})

				local button_frame = create("Frame", {Parent = category_frame;BorderSizePixel = 0;Size = UDim2.new(1, 0, 0, 22);BorderColor3 = Color3.fromRGB(0, 0, 0);Name = [[button_frame]];BackgroundTransparency = 1;BackgroundColor3 = Color3.fromRGB(255, 255, 255);})
				local text_button = create("TextButton", {TextStrokeTransparency = 0.5;AutoButtonColor = false;BackgroundColor3 = Color3.fromRGB(29, 29, 29);BorderMode = Enum.BorderMode.Inset;Parent = button_frame;AnchorPoint = Vector2.new(0, 0.5);TextSize = 13;Size = UDim2.new(1, 0, 0, 18);BorderColor3 = Color3.fromRGB(50, 50, 50);Text = data.text;TextStrokeColor3 = Color3.fromRGB(18, 18, 18);Font = Enum.Font.Code;Position = UDim2.new(0, 0, 0.5, 0);TextColor3 = Color3.fromRGB(150, 150, 150);})
				local button_highlight = create("Frame", {Visible = false;Parent = text_button;AnchorPoint = Vector2.new(0.5, 0.5);BorderSizePixel = 0;Size = UDim2.new(1, 0, 1, 0);BorderColor3 = Color3.fromRGB(0, 0, 0);Position = UDim2.new(0.5, 0, 0.5, 0);BackgroundTransparency = 0.85;BackgroundColor3 = library.colors.accent;})
				create("UIStroke", {ApplyStrokeMode = Enum.ApplyStrokeMode.Border;Parent = text_button;Color = Color3.fromRGB(21, 21, 21);})
				create("UIGradient", {Parent = text_button;Rotation = 90;Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255));ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 200, 200));});})
				create("UIPadding", {Parent = button_frame;PaddingRight = UDim.new(0, 6);PaddingLeft = UDim.new(0, 6);})

				text_button.MouseEnter:Connect(function() button_highlight.Visible = true end)
				text_button.MouseLeave:Connect(function() button_highlight.Visible = false end)
				text_button.MouseButton1Up:Connect(function() button_highlight.BackgroundTransparency = 0.85 end)
				text_button.MouseButton1Down:Connect(function() button_highlight.BackgroundTransparency = 0.875 end)
				text_button.MouseButton1Click:Connect(function() data.callback() button_highlight.BackgroundTransparency = 0.85 end)

				task.spawn(function() task.wait() Reposition() end)
				return button
			end

			function category:new_toggle(...)
				category.elements += 1
				category_frame.Size += UDim2.new(0, 0, 0, 20)

				local toggle, data = {}, {
					text = 'toggle',
					callback = function()
						warn('No callback has been set to toggle')
					end,
				}

				local data = overwrite(data, ... or {})
				toggle.value = false

				local toggle_frame = create("Frame", {Parent = category_frame;BorderSizePixel = 0;Size = UDim2.new(1, 0, 0, 20);BorderColor3 = Color3.fromRGB(0, 0, 0);Name = [[toggle_frame]];Position = UDim2.new(-1.41860461, 0, 0.309090912, 0);BackgroundTransparency = 1;BackgroundColor3 = Color3.fromRGB(255, 255, 255);})
				local toggle_text = create("TextLabel", {TextStrokeTransparency = 0.5;BorderSizePixel = 0;BackgroundColor3 = Color3.fromRGB(255, 255, 255);Parent = toggle_frame;AnchorPoint = Vector2.new(1, 0.5);TextSize = 13;Size = UDim2.new(1, -20, 1, 0);TextXAlignment = Enum.TextXAlignment.Left;BorderColor3 = Color3.fromRGB(0, 0, 0);Text = data.text;TextStrokeColor3 = Color3.fromRGB(18, 18, 18);Font = Enum.Font.Code;Name = [[toggle_text]];Position = UDim2.new(1, 0, 0.5, 0);TextColor3 = Color3.fromRGB(150, 150, 150);BackgroundTransparency = 1;})
				local toggle_button = create("TextButton", {AutoButtonColor = false;BackgroundColor3 = Color3.fromRGB(29, 29, 29);BorderMode = Enum.BorderMode.Inset;Parent = toggle_frame;AnchorPoint = Vector2.new(0, 0.5);TextSize = 14;Size = UDim2.new(0, 15, 0, 15);BorderColor3 = Color3.fromRGB(50, 50, 50);Text = [[]];Font = Enum.Font.SourceSans;Name = [[toggle_button]];Position = UDim2.new(0, 0, 0.5, 0);TextColor3 = Color3.fromRGB(0, 0, 0);})
				local outline = create("UIStroke", {ApplyStrokeMode = Enum.ApplyStrokeMode.Border;Parent = toggle_button;Color = Color3.fromRGB(21, 21, 21);})
				local UIGradient = create("UIGradient", {Enabled = false;Parent = toggle_button;Rotation = 90;Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255));ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 200, 200));});})
				local UIPadding = create("UIPadding", {Parent = toggle_frame;PaddingRight = UDim.new(0, 6);PaddingLeft = UDim.new(0, 6);})

				toggle_button.MouseEnter:Connect(function()
					outline.Color = library.colors.accent
				end)

				toggle_button.MouseLeave:Connect(function()
					outline.Color = Color3.fromRGB(21, 21, 21)
				end)

				toggle_button.MouseButton1Click:Connect(function()
					toggle.value = not toggle.value
					warn(toggle.value)

					if toggle.value then
						toggle_button.BackgroundColor3 = library.colors.accent
						data.callback(toggle.value)
						--> toggle_button.BorderColor3 = library.colors.accent
					elseif not toggle.value then 
						toggle_button.BackgroundColor3 = Color3.fromRGB(29, 29, 29)
						data.callback(toggle.value)
						--> toggle_button.BorderColor3 = Color3.fromRGB(50, 50, 50)
					end
				end)

				function toggle:add_keybind(...)
					local keybind, defaults = { key = nil, editing = false, clicked = false }, {
						text = 'keybind',
						input_mode = 'click',
						key = nil,
						callback = function()
							warn("No callback set to keybind")
						end,
					}

					local data = overwrite(data, ... or {})

					local keybind_button = create("TextButton", {TextStrokeTransparency = 0.5;BorderSizePixel = 0;AutoButtonColor = false;BackgroundColor3 = Color3.fromRGB(255, 255, 255);Parent = toggle_frame;AnchorPoint = Vector2.new(1, 0.5);TextSize = 13;Size = UDim2.new(0, 30, 0, 15);TextXAlignment = Enum.TextXAlignment.Right;BorderColor3 = Color3.fromRGB(0, 0, 0);Text = '[...]';TextStrokeColor3 = Color3.fromRGB(18, 18, 18);Font = Enum.Font.Code;Name = [[keybind_button]];Position = UDim2.new(1, 0, 0.5, 0);TextColor3 = Color3.fromRGB(150, 150, 150);BackgroundTransparency = 1;})

					if data.key then
						keybind_button.Text = string.format('[%s]', keybind.key)
						keybind.key = data.key
					end

					local blacklisted_keys = {
						'RightSuper',
						'LeftSuper',
						'BackSlash',
						'Backspace',
						'Unknown',
						'Return',
						'Escape',
					}

					keybind_button.MouseEnter:Connect(function()
						keybind_button.TextColor3 = library.colors.accent
					end)

					keybind_button.MouseLeave:Connect(function()
						keybind_button.TextColor3 = Color3.fromRGB(150, 150, 150)
					end)

					library.connections['click_connection_' .. tostring(category.elements)] = keybind_button.MouseButton1Click:Connect(function()
						keybind_button.TextColor3 = library.colors.accent
						keybind_button.Text = '[...]'
						keybind.editing = true
					end)

					library.connections['input_connection_' .. tostring(category.elements)] = input_service.InputBegan:Connect(function(key)
						if keybind.editing then
							keybind_button.TextColor3 = Color3.new(150, 150, 150)

							if table.find(blacklisted_keys, tostring(key.KeyCode):gsub('Enum.KeyCode.', '')) then
								keybind.key = nil
								keybind_button.Text = '[...]'
								keybind_button.Size = UDim2.new(0, 30, 1, 0)	
								keybind.editing = false
								return
							end

							keybind.key = tostring(key.KeyCode):gsub('Enum.KeyCode.', '')
							keybind_button.Text = string.format('[%s]', keybind.key)

							if keybind_button.TextBounds.X > 30 then
								keybind_button.Size = UDim2.new(0, keybind_button.TextBounds.X + 6, 1, 0)	
							end

							if keybind_button.TextBounds.X < 30 then
								keybind_button.Size = UDim2.new(0, 30, 1, 0)	
							end

							keybind.editing = false 
							return
						end

						if keybind.key == nil then return end

						if key.KeyCode == Enum.KeyCode[keybind.key] then
							if data.input_mode == 'hold' then
								keybind.clicked = true
								while keybind.clicked do task.wait()
									data.callback(keybind.key, toggle.value)
								end
							elseif data.input_mode == 'toggle' then
								keybind.clicked = not keybind.clicked
								while keybind.clicked do task.wait()
									data.callback(keybind.key, toggle.value)
								end
							elseif data.input_mode == 'click' then
								data.callback(keybind.key, toggle.value)
							end
						end
					end)

					library.connections['hold_connection_' .. tostring(category.element_count)] = input_service.InputEnded:Connect(function(key)
						if keybind.key == nil then return end

						if key.KeyCode == Enum.KeyCode[keybind.key] and data.input_mode == 'hold' then
							keybind.clicked = false
						end
					end)

					return keybind
				end

				function toggle:get_value()
					return toggle.value
				end

				task.spawn(function() task.wait() Reposition() end)
				return toggle
			end

			function category:new_textbox(...)
				category.elements += 1
				category_frame.Size += UDim2.new(0, 0, 0, 36)

				local textbox, data = { value = '' }, {
					text = 'textbox',
					text_prefix = '',
					placeholder_text = '...',
					callback = function()
						warn('No callback set to textbox.')
					end,
				}

				local data = overwrite(data, ... or {})

				local textbox_frame = create("Frame", {Parent = category_frame;BorderSizePixel = 0;Size = UDim2.new(1, 0, 0, 36);BorderColor3 = Color3.fromRGB(0, 0, 0);Name = [[textbox_frame]];BackgroundTransparency = 1;BackgroundColor3 = Color3.fromRGB(255, 255, 255);})
				local textbox_label = create("TextLabel", {TextStrokeTransparency = 0.5;Position = UDim2.new(0,0,0,0);BorderSizePixel = 0;BackgroundColor3 = Color3.fromRGB(255, 255, 255);Parent = textbox_frame;TextSize = 14;Size = UDim2.new(1, 0, 0.5, 0);TextXAlignment = Enum.TextXAlignment.Left;BorderColor3 = Color3.fromRGB(0, 0, 0);Text = data.text;TextStrokeColor3 = Color3.fromRGB(18, 18, 18);Font = Enum.Font.Code;Name = [[textbox_label]];TextColor3 = Color3.fromRGB(150, 150, 150);BackgroundTransparency = 1;})
				local textbox_text = create("TextBox", {CursorPosition = -1;TextStrokeTransparency = 0.5;PlaceholderColor3 = Color3.fromRGB(178, 178, 178);BackgroundColor3 = Color3.fromRGB(25, 25, 25);BorderMode = Enum.BorderMode.Inset;Parent = textbox_frame;AnchorPoint = Vector2.new(0, 1);TextXAlignment = Enum.TextXAlignment.Left;TextSize = 13;Size = UDim2.new(1, 0, 0, 18);TextStrokeColor3 = Color3.fromRGB(18, 18, 18);TextColor3 = Color3.fromRGB(150, 150, 150);BorderColor3 = Color3.fromRGB(50, 50, 50);Text = data.text_prefix .. data.placeholder_text;Font = Enum.Font.Code;Name = [[textbox_text]];Position = UDim2.new(0, 0, 1, 0);})
				local outline = create("UIStroke", {ApplyStrokeMode = Enum.ApplyStrokeMode.Border;Parent = textbox_text;Color = Color3.fromRGB(21, 21, 21);})
				create("UIGradient", {Parent = textbox_text;Rotation = 90;Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255));ColorSequenceKeypoint.new(1, Color3.fromRGB(191, 191, 191));});})
				create("UIPadding", {Parent = textbox_frame;PaddingRight = UDim.new(0, 6);PaddingLeft = UDim.new(0, 6);PaddingBottom = UDim.new(0, 1);})
				create("UIPadding", {Parent = textbox_text;PaddingLeft = UDim.new(0, 4);})

				textbox_text.MouseEnter:Connect(function()
					outline.Color = library.colors.accent
				end)

				textbox_text.MouseLeave:Connect(function()
					outline.Color = Color3.fromRGB(21, 21, 21)
				end)

				textbox_text.FocusLost:Connect(function()
					if textbox_text.Text == '' then textbox_text.Text = '...' else
						textbox.value = textbox_text.Text
						textbox_text.Text = data.text_prefix .. textbox_text.Text 
					end 
					if not pcall(function() data.callback(textbox.value) end) then
						warn('Callback failed. Check your code bud')
					end
				end)

				function textbox:get_value()
					return textbox.value
				end

				function textbox:update(...)
					local new_data = overwrite(data, ... or {})
					textbox_text.Text = new_data.text_prefix .. new_data.text
				end

				task.spawn(function() task.wait() Reposition() end)
				return textbox
			end

			function category:new_slider(...)
				category.elements += 1
				category_frame.Size += UDim2.new(0, 0, 0, 36)

				local slider, data = { value = 0 }, {
					text = 'slider',
					allow_decimals = false,
					min = 0,
					max = 100,
					value = 0,
					callback = function()
						warn('No callback set to slider.')
					end,
				}

				local data = overwrite(data, ... or {})
				slider.value = data.value

				local slider_frame = create("Frame", {Parent = category_frame;BorderSizePixel = 0;Size = UDim2.new(1, 0, 0, 36);BorderColor3 = Color3.fromRGB(0, 0, 0);Name = [[slider_frame]];BackgroundTransparency = 1;BackgroundColor3 = Color3.fromRGB(255, 255, 255);})
				local slider_button = create("TextButton", {AutoButtonColor = false;BackgroundColor3 = Color3.fromRGB(29, 29, 29);BorderMode = Enum.BorderMode.Inset;Parent = slider_frame;AnchorPoint = Vector2.new(0, 1);TextSize = 14;Size = UDim2.new(1, 0, 0, 18);BorderColor3 = Color3.fromRGB(50, 50, 50);Text = [[]];Font = Enum.Font.SourceSans;Name = [[slider_button]];Position = UDim2.new(0, 0, 1, 0);TextColor3 = Color3.fromRGB(0, 0, 0);})
				local slider_label = create("TextLabel", {TextStrokeTransparency = 0.5;BorderSizePixel = 0;BackgroundColor3 = Color3.fromRGB(255, 255, 255);Parent = slider_frame;TextSize = 14;Size = UDim2.new(1, 0, 0.5, 0);TextXAlignment = Enum.TextXAlignment.Left;BorderColor3 = Color3.fromRGB(0, 0, 0);Text = data.text;TextStrokeColor3 = Color3.fromRGB(18, 18, 18);Font = Enum.Font.Code;Name = [[slider_label]];TextColor3 = Color3.fromRGB(150, 150, 150);BackgroundTransparency = 1;})
				local value_label = create("TextLabel", {TextStrokeTransparency = 0.5;BorderSizePixel = 0;BackgroundColor3 = Color3.fromRGB(255, 255, 255);Parent = slider_frame;AnchorPoint = Vector2.new(1, 0);TextSize = 14;Size = UDim2.new(0.25, 0, 0.5, 0);TextXAlignment = Enum.TextXAlignment.Right;BorderColor3 = Color3.fromRGB(0, 0, 0);	Text = slider.value;TextStrokeColor3 = Color3.fromRGB(18, 18, 18);Font = Enum.Font.Code;Name = [[value_label]];	Position = UDim2.new(1, 0, 0, 0);TextColor3 = Color3.fromRGB(150, 150, 150);BackgroundTransparency = 1;})
				local outline = create("UIStroke", {ApplyStrokeMode = Enum.ApplyStrokeMode.Border;Parent = slider_button;Color = Color3.fromRGB(21, 21, 21);})
				local fill = create("Frame", {Parent = slider_button;BorderSizePixel = 0;Size = UDim2.new(0.25, 0, 1, 0);BorderColor3 = Color3.fromRGB(0, 0, 0);Name = [[fill]];BackgroundColor3 = library.colors.accent;})
				local UIPadding = create("UIPadding", {Parent = slider_frame;PaddingRight = UDim.new(0, 6);PaddingLeft = UDim.new(0, 6);PaddingBottom = UDim.new(0, 2);})
				local UIGradient = create("UIGradient", {Parent = slider_button;Rotation = 90;Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255));ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 200, 200));});})

				slider_button.MouseEnter:Connect(function()
					outline.Color = library.colors.accent
				end)

				slider_button.MouseLeave:Connect(function()
					outline.Color = Color3.fromRGB(21, 21, 21)
				end)

				local min = data.min
				local max = data.max
				local mouse_down = false
				local mouse_on = false

				slider.value = data.value
				fill.Size = UDim2.new((slider.value - min) / (max - min), 0, 1, 0)
				value_label.Text = tostring(slider.value):sub(1,4)

				local function update_value()
					local mouse_x = math.clamp(mouse.X - slider_button.AbsolutePosition.X, min, slider_button.AbsoluteSize.X)

					if data.allow_decimals then
						slider.value = (math.clamp((mouse_x / slider_button.AbsoluteSize.X) * (max - min) + min, min, max))
						value_label.Text = tostring(slider.value):sub(1,4)
					elseif not data.allow_decimals then
						slider.value = math.floor(math.clamp((mouse_x / slider_button.AbsoluteSize.X) * (max - min) + min, min, max))
						value_label.Text = tostring(slider.value)
					end

					fill.Size = UDim2.new((slider.value - min) / (max - min), 0, 1, 0)

					data.callback(slider.value)
				end

				mouse.Move:Connect(function() if mouse_down then update_value() end end)
				slider_button.MouseButton1Down:Connect(function() mouse_down = true update_value() end)
				slider_button.MouseButton1Up:Connect(function() mouse_down = false end)
				slider_button.MouseEnter:Connect(function() mouse_on = true end)
				slider_button.MouseLeave:Connect(function() mouse_on = false end)

				input_service.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						mouse_down = false
					end
				end)

				function slider:get_value() 
					return slider.value
				end

				task.spawn(function() task.wait() Reposition() end)
				return slider	
			end

			function category:new_keybind(...)
				category.elements += 1
				category_frame.Size += UDim2.new(0, 0, 0, 20)

				local keybind, data = { key = nil, editing = false, clicked = false }, {
					text = 'keybind',
					input_mode = 'click',
					key = nil,
					callback = function()
						warn("No callback set to keybind")
					end,
				}

				local data = overwrite(data, ... or {})

				local keybind_frame = create("Frame", {Parent = category_frame;BorderSizePixel = 0;Size = UDim2.new(1, 0, 0, 20);BorderColor3 = Color3.fromRGB(0, 0, 0);Name = [[keybind_frame]];BackgroundTransparency = 1;BackgroundColor3 = Color3.fromRGB(255, 255, 255);})
				local keybind_label = create("TextLabel", {TextStrokeTransparency = 0.5;BorderSizePixel = 0;BackgroundColor3 = Color3.fromRGB(255, 255, 255);Parent = keybind_frame;AnchorPoint = Vector2.new(0, 0.5);TextSize = 13;Size = UDim2.new(0.75, 0, 1, 0);TextXAlignment = Enum.TextXAlignment.Left;BorderColor3 = Color3.fromRGB(0, 0, 0);Text = data.text;TextStrokeColor3 = Color3.fromRGB(18, 18, 18);Font = Enum.Font.Code;Name = [[keybind_label]];Position = UDim2.new(0, 0, 0.5, 0);TextColor3 = Color3.fromRGB(150, 150, 150);BackgroundTransparency = 1;})
				local keybind_button = create("TextButton", {TextStrokeTransparency = 0.5;BorderSizePixel = 0;AutoButtonColor = false;BackgroundColor3 = Color3.fromRGB(255, 255, 255);Parent = keybind_frame;AnchorPoint = Vector2.new(1, 0.5);TextSize = 13;Size = UDim2.new(0, 30, 0, 15);TextXAlignment = Enum.TextXAlignment.Right;BorderColor3 = Color3.fromRGB(0, 0, 0);Text = '[...]';TextStrokeColor3 = Color3.fromRGB(18, 18, 18);Font = Enum.Font.Code;Name = [[keybind_button]];Position = UDim2.new(1, 0, 0.5, 0);TextColor3 = Color3.fromRGB(150, 150, 150);BackgroundTransparency = 1;})
				create("UIPadding", {Parent = keybind_frame;PaddingRight = UDim.new(0, 6);PaddingLeft = UDim.new(0, 6);})

				if data.key then
					keybind_button.Text = string.format('[%s]', keybind.key)
					keybind.key = data.key
				end

				local blacklisted_keys = {
					'RightSuper',
					'LeftSuper',
					'BackSlash',
					'Backspace',
					'Unknown',
					'Return',
					'Escape',
				}

				keybind_button.MouseEnter:Connect(function()
					keybind_button.TextColor3 = library.colors.accent
				end)

				keybind_button.MouseLeave:Connect(function()
					keybind_button.TextColor3 = Color3.fromRGB(150, 150, 150)
				end)

				library.connections['click_connection_' .. tostring(category.elements)] = keybind_button.MouseButton1Click:Connect(function()
					keybind_button.TextColor3 = library.colors.accent
					keybind_button.Text = '[...]'
					keybind.editing = true
				end)

				library.connections['input_connection_' .. tostring(category.elements)] = input_service.InputBegan:Connect(function(key)
					if keybind.editing then
						keybind_button.TextColor3 = Color3.new(150, 150, 150)

						if table.find(blacklisted_keys, tostring(key.KeyCode):gsub('Enum.KeyCode.', '')) then
							keybind.key = nil
							keybind_button.Text = '[...]'
							keybind_button.Size = UDim2.new(0, 30, 1, 0)	
							keybind.editing = false
							return
						end

						keybind.key = tostring(key.KeyCode):gsub('Enum.KeyCode.', '')
						keybind_button.Text = string.format('[%s]', keybind.key)

						if keybind_button.TextBounds.X > 30 then
							keybind_button.Size = UDim2.new(0, keybind_button.TextBounds.X + 6, 1, 0)	
						end

						if keybind_button.TextBounds.X < 30 then
							keybind_button.Size = UDim2.new(0, 30, 1, 0)	
						end

						keybind.editing = false 
						return
					end

					if keybind.key == nil then return end

					if key.KeyCode == Enum.KeyCode[keybind.key] then
						if data.input_mode == 'hold' then
							keybind.clicked = true
							while keybind.clicked do task.wait()
								data.callback(keybind.key)
							end
						elseif data.input_mode == 'toggle' then
							keybind.clicked = not keybind.clicked
							while keybind.clicked do task.wait()
								data.callback(keybind.key)
							end
						elseif data.input_mode == 'click' then
							data.callback(keybind.key)
						end
					end
				end)

				library.connections['hold_connection_' .. tostring(category.element_count)] = input_service.InputEnded:Connect(function(key)
					if keybind.key == nil then return end

					if key.KeyCode == Enum.KeyCode[keybind.key] and data.input_mode == 'hold' then
						keybind.clicked = false
					end
				end)

				task.spawn(function() task.wait() Reposition() end)
				return keybind
			end

			function category:new_colorpicker(...)
				category.elements += 1
				category_frame.Size += UDim2.new(0, 0, 0, 20)

				local color_picker, data = { value = Color3.fromRGB(255, 255, 255) }, {
					text = 'color picker',
					callback = function()
						warn('')
					end,
				}

				local data = overwrite(data, ... or {})

				local color_picker_frame = create("Frame", {Parent = category_frame;BorderSizePixel = 0;Size = UDim2.new(1, 0, 0, 20);BorderColor3 = Color3.fromRGB(0, 0, 0);Name = [[keybind_frame]];BackgroundTransparency = 1;BackgroundColor3 = Color3.fromRGB(255, 255, 255);})
				local color_picker_label = create("TextLabel", {TextStrokeTransparency = 0.5;BorderSizePixel = 0;BackgroundColor3 = Color3.fromRGB(255, 255, 255);Parent = color_picker_frame;AnchorPoint = Vector2.new(0, 0.5);TextSize = 13;Size = UDim2.new(0.75, 0, 1, 0);TextXAlignment = Enum.TextXAlignment.Left;BorderColor3 = Color3.fromRGB(0, 0, 0);Text = [[keybind]];TextStrokeColor3 = Color3.fromRGB(18, 18, 18);Font = Enum.Font.Code;Name = [[keybind_label]];Position = UDim2.new(0, 0, 0.5, 0);TextColor3 = Color3.fromRGB(150, 150, 150);BackgroundTransparency = 1;})
				local color_picker_button = create("TextButton", {AutoButtonColor = false;BackgroundColor3 = Color3.fromRGB(255, 0, 0);BorderMode = Enum.BorderMode.Inset;Parent = color_picker_frame;AnchorPoint = Vector2.new(1, 0.5);TextSize = 14;Size = UDim2.new(0, 30, 0, 15);BorderColor3 = Color3.fromRGB(50, 50, 50);Text = [[]];Font = Enum.Font.SourceSans;Position = UDim2.new(1, 0, 0.5, 0);TextColor3 = Color3.fromRGB(0, 0, 0);})
				local outline = create("UIStroke", {ApplyStrokeMode = Enum.ApplyStrokeMode.Border;Parent = color_picker_button;Color = Color3.fromRGB(44, 44, 44);})
				create("UIPadding", {Parent = color_picker_frame;PaddingRight = UDim.new(0, 6);PaddingLeft = UDim.new(0, 6);})
				create("UIGradient", {Parent = color_picker_button;Rotation = 90;Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255));ColorSequenceKeypoint.new(0.6712803244590759, Color3.fromRGB(140, 140, 140));ColorSequenceKeypoint.new(1, Color3.fromRGB(86, 86, 86));});})

				task.spawn(function() task.wait() Reposition() end)
				return color_picker
			end

			function category.element_count()
				return category.elements
			end

			task.spawn(function() task.wait() Reposition() end)
			return category
		end

		--// auto sort categories
		task.spawn(function() task.wait() Reposition() end)

		return tab
	end

	return window
end

coroutine.wrap(function()
	task.wait()

	--// encrypt names
	for _,__ in ipairs(library.GUI:GetDescendants()) do
		__.Name = encrypt_name()
	end

	--// start threads
	library.threads['update_cursor_pos'] = coroutine.create(reposition_cursor)
	coroutine.resume(library.threads['update_cursor_pos'])

	warn('. encrypted')
	warn('. started threads')
end)() warn('loaded sprite: ' .. library.version)

return library
