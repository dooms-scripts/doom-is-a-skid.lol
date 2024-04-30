--[[

	    ###########  #####       #####  ##########  ##############  #####  #####  ##############  ################
	   #####        ########    #####  #####       #####    #####  #####  #####  #####    #####        #####      
	  ###########  #####  ###  #####  #####       ############    ############  ##############        #####       
	 #####        #####    ########  #####       #####    #####         #####  #####                 #####        
	###########  #####       #####  ##########  #####    #####  ############  #####                 #####         

	::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
	:                                           UI LIBRARY MADE BY @doomxx                                       :
	:                              HOW TO USE: dooms-scripts.gitbook.io/encrypt-docs                             :
	::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
	
]]--

local initialize = loadstring(game:HttpGet('https://raw.githubusercontent.com/dooms-scripts/ui-libraries/main/safe-load.lua'))()
getgenv = getgenv or getfenv --error('Encrypt could not load.', 999)
setreadonly = setreadonly or function() end

--> LIBRARY DATA <------------------------------------------
local encrypt = {
	version = 'e1.6.2',
	instance = nil,
	drop_shadow = false,
	encrypt_names = false,
	on_loaded = function() 
		game.StarterGui:SetCore('SendNotification', {
			Title = string.format('ENCRYPT UI LIBRARY'),
			Text = 'Finished loading!',
			Duration = 2,
			Icon = 'rbxassetid://16947733084',
		})	
	end,

	threads = { 
		dropdowns = {},
		keybinds = {},
		textbox = {},
		toggles = {},
		buttons = {},
		sliders = {},
	},

	custom_cursor = {
		use_custom_cursor = false,
		enabled = false,
		icon = 'http://www.roblox.com/asset/?id=16710247795',
	},

	fonts = {
		main = 'Gotham',
		secondary = 'GothamMedium',
	},

	colors = {
		main_color = Color3.fromRGB(255, 255, 255),
		foreground = Color3.fromRGB(23, 23, 23),
		background = Color3.fromRGB(10, 10, 10),
		categories = Color3.fromRGB(10, 10, 10),
		topbar = Color3.fromRGB(10, 10, 10),
	},

	connections = {}
}

--> START CLOCK <-------------------------------------------
local start_time = tick()
warn(string.format('[+] ENCRYPT > LOADING (%s)', encrypt.version))

--> SERVICES & ATTRIBUTES <---------------------------------
local tween_service = game:GetService('TweenService')
local input_service = game:GetService('UserInputService')
local run_service = game:GetService('RunService')
local players = game:GetService('Players')
local tween_info = TweenInfo
local easing_style = Enum.EasingStyle
local easing_direction = Enum.EasingDirection

local player = players.LocalPlayer
local mouse = player:GetMouse()

--> FUNCTIONS <---------------------------------------------
function encrypt.create(instance, properties)
	local i = Instance.new(instance)
	for p,v in pairs(properties) do
		local s, err = pcall(function()
			i[p] = v
		end)

		if err then warn('[!] ENCRYPT > PROBLEM CREATING INSTANCE "'..tostring(instance)..'": '..err) end
	end

	return i
end

function encrypt.tween(instance, info, property, value)
	tween_service:Create(instance, info, {[property] = value}):Play()
end

function encrypt.randomize(length)
	local str = ''

	for i=1, length do
		str = str .. string.char(math.random(65, 122))
	end

	return str
end

function encrypt.overwrite(to_overwrite : {}, overwrite_with : {})
	for i, v in pairs(overwrite_with) do
		if type(v) == 'table' then
			to_overwrite[i] = encrypt.overwrite(to_overwrite[i] or {}, v)
		else
			to_overwrite[i] = v
		end
	end

	return to_overwrite or nil
end

--> INITIALIZE <--------------------------------------------
encrypt.instance = encrypt.create("ScreenGui", {
	Name = 'ENCRYPT_'.. encrypt.randomize(20),
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	Parent = nil,
	IgnoreGuiInset = true,
})

local custom_cursor = encrypt.create('ImageLabel', {
	Parent = encrypt.instance,
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	BackgroundTransparency = 1.000,
	BorderColor3 = Color3.fromRGB(0, 0, 0),
	BorderSizePixel = 0,
	Position = UDim2.new(0.5, 0, 0.5, 0),
	Size = UDim2.new(0, 25, 0, 25),
	Image = encrypt.custom_cursor.icon,
	Visible = false,
	ZIndex = 99999,
})

encrypt.threads['MouseThread'] = coroutine.wrap(function()
	run_service.Stepped:Connect(function()
		if encrypt.use_custom_cursor then
			input_service.MouseIconEnabled = not encrypt.custom_cursor.enabled
			custom_cursor.Visible = encrypt.custom_cursor.enabled

			custom_cursor.Position = UDim2.new(0, mouse.X, 0, mouse.Y)
		else
			input_service.MouseIconEnabled = true
			custom_cursor.Visible = false
		end
	end)
end)()

--> CREATE UI <---------------------------------------------
function encrypt.watermark(...)
	local watermark, default = {}, {
		text = string.format('encrypt // %s', encrypt.version),
		size = UDim2.new(0, 250, 0, 25),
	}

	local data = encrypt.overwrite(default, ... or {})

	local container = encrypt.create('Frame', {
		Name = "Watermark",
		Parent = encrypt.instance,
		AnchorPoint = Vector2.new(1, 0),
		BackgroundColor3 = Color3.fromRGB(10, 10, 10),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		Position = UDim2.new(0.99, 0, 0.01, 0),
		Size = data.size,
		Active = true,
		Selectable = true,
		Draggable = true,
	})

	local label = encrypt.create('TextLabel', {
		Name = "TitleText",
		Parent = container,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1.000,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		Size = UDim2.new(0, 1, 1, 0),
		Font = Enum.Font.Gotham,
		Text = "  ".. data.text,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextSize = 12.000,
		TextXAlignment = Enum.TextXAlignment.Left,
	})

	local color = encrypt.create('Frame', {
		Name = "Color",
		Parent = container,
		AnchorPoint = Vector2.new(0.5, 1),
		BackgroundColor3 = encrypt.colors.main_color,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		Position = UDim2.new(0.5, 0, 0, 0),
		Size = UDim2.new(1, 0, 0, 1),
	})

	encrypt.create("UIPadding", { 
		Parent = label, PaddingLeft = UDim.new(0, 2) 
	})

	function watermark:update(...)
		local new_data = encrypt.overwrite(data, ... or {})

		label.Text = '  ' ..new_data.text
		container.Size = new_data.size
		color.BackgroundColor3 = encrypt.colors.main_color
	end

	function watermark:toggle()
		container.Visible = not container.Visible
	end

	function watermark:Destroy()
		container:Destroy()
	end

	return watermark
end

function encrypt.new_window(...)
	local window, default = { tab_count = 0 }, {
		title_text = 'encrypt // '..encrypt.version,
		title_alignment = 'Center',
		size = UDim2.new(0, 380, 0, 425),
		position = UDim2.new(1, -380 - 20, 1, -425 - 20),
		anchor = Vector2.new(0, 0)
	}

	local data = encrypt.overwrite(default, ... or {})

	-- Creating UI
	local WindowFrame = encrypt.create('Frame', {
		Name = "WindowFrame",
		Parent = encrypt.instance,
		BackgroundColor3 = encrypt.colors.background,
		BorderColor3 = Color3.fromRGB(35, 35, 35),
		Position = data.position,
		Size = data.size,
		AnchorPoint = data.anchor,
		Active = true,
		Selectable = true,
		Draggable = true,
	})

	local Topbar = encrypt.create('Frame', {
		Name = "[1] Topbar",
		Parent = WindowFrame,
		AnchorPoint = Vector2.new(0.5, 0),
		BackgroundColor3 = encrypt.colors.topbar,
		BackgroundTransparency = 0,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		Position = UDim2.new(0.5, 0, 0, 0),
		Size = UDim2.new(1, 0, 0, 25),
	})

	local Tabs = encrypt.create("Frame", {
		Name = "[2] Tabs",
		Parent = WindowFrame,
		AnchorPoint = Vector2.new(0.5, 1),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1.000,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		Position = UDim2.new(0.5, 0, 1, 0),
		Size = UDim2.new(1, 0, 1, -25),
	})

	local ButtonHolder = encrypt.create('Frame', {
		Name = "[1] ButtonHolder",
		Parent = Topbar,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1.000,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0, 
		Size = UDim2.new(1, 0, 1, 0)
	})

	local Divider = encrypt.create('Frame', {
		Name = "[2] Divider",
		Parent = Topbar,
		AnchorPoint = Vector2.new(0.5, 0),
		BackgroundColor3 = Color3.fromRGB(35, 35, 35),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		Position = UDim2.new(0.5, 0, 1, 0),
		Size = UDim2.new(1, 0, 0, -1),
	})

	local TitleText = encrypt.create('TextLabel', {
		Name = "[1] TitleText",
		Parent = ButtonHolder,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1.000,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		Size = UDim2.new(0, 111, 0, 25),
		Font = Enum.Font[encrypt.fonts.main],
		Text = "  "..tostring(data.title_text),
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextSize = 12.000,
		TextXAlignment = Enum.TextXAlignment[data.title_alignment],
		RichText = true,
	})

	local TopbarDivider = encrypt.create('Frame', {
		Name = '[2] Divider',
		Parent = ButtonHolder,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1.000,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		Size = UDim2.new(0, 12, 1, 0),
	})

	local DividerPart = encrypt.create('Frame', {
		Parent = TopbarDivider,
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.fromRGB(25, 25, 25),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		Position = UDim2.new(0.65, 0, 0.5, 0),
		Size = UDim2.new(0, 1, 0.600000024, 0),
	})

	local drop_shadow = encrypt.create('ImageLabel', {
		Name = "DropShadow",
		Parent = WindowFrame,
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1.000,
		BorderSizePixel = 0,
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(1, 47, 1, 47),
		ZIndex = -475645654,
		Image = "rbxassetid://6015897843",
		ImageColor3 = Color3.fromRGB(10, 10, 10),
		ImageTransparency = 0.500,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(49, 49, 450, 450),
		Visible = encrypt.drop_shadow
	})

	encrypt.create('ImageLabel', {
		Parent = WindowFrame,
		AnchorPoint = Vector2.new(0, 1),
		BackgroundColor3 = encrypt.colors.background,
		BackgroundTransparency = 1.000,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0.99, 0),
		Size = UDim2.new(1, 0, 0, 25),
		Image = "rbxassetid://277037193",
		ImageColor3 = Color3.fromRGB(10, 10, 10),
		ZIndex = 99,
	})

	encrypt.create('UIListLayout', {
		Parent = ButtonHolder,
		FillDirection = Enum.FillDirection.Horizontal,
		SortOrder = Enum.SortOrder.LayoutOrder,
	})

	encrypt.create('UIPadding', {
		Parent = Tabs,
		PaddingBottom = UDim.new(0, 7),
		PaddingRight = UDim.new(0, 7),
		PaddingLeft = UDim.new(0, 7),
		PaddingTop = UDim.new(0, 7),
	})

	WindowFrame.MouseEnter:Connect(function()
		encrypt.custom_cursor.enabled = encrypt.custom_cursor.enabled
	end)

	WindowFrame.MouseLeave:Connect(function()
		encrypt.custom_cursor.enabled = encrypt.custom_cursor.enabled
	end)

	TitleText.Size = UDim2.new(0, TitleText.TextBounds.X, 1, 0)

	-- Functions
	function window:toggle()
		WindowFrame.Visible = not WindowFrame.Visible
	end

	function window.new_tab(tab_name)
		window.tab_count += 1
		local tab = { group_count = 0 }
		local tab_name = tab_name or `Tab {tostring(window.tab_count)}`

		local TabFrame = encrypt.create('Frame', {
			Name = encrypt.randomize(999),
			Parent = Tabs,
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1.000,
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0,
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Visible = false,
			Size = UDim2.new(1, 0, 1, 0),
			LayoutOrder = window.tab_count,
		})

		local TabButton = encrypt.create('TextButton', {
			Name = 'TabButton',
			Parent = ButtonHolder,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1.000,
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0,
			Position = UDim2.new(0.293650806, 0, 0, 0),
			Size = UDim2.new(0.213506043, 0, 1, 0),
			Font = Enum.Font[encrypt.fonts.main],
			Text = tab_name,
			TextColor3 = Color3.fromRGB(100, 100, 100),
			TextSize = 12.000,
			TextWrapped = true,
			RichText = true,
			LayoutOrder = window.tab_count,
		})

		local UIListLayout = encrypt.create('UIListLayout', {
			Parent = TabFrame,
			FillDirection = Enum.FillDirection.Horizontal,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 8),
		})

		-->> automatically resize tab buttons based on text
		encrypt.threads['TabButtonResize'] = coroutine.wrap(function() 
			task.wait(0.1)
			local bounds = TabButton.TextBounds
			local bound_x = bounds.X

			TabButton.Size = UDim2.new(0, bound_x + 10, 1, 0)
		end)()

		TabButton.MouseButton1Click:Connect(function()
			for _,t in ipairs(Tabs:GetChildren()) do
				if t:IsA('Frame') then t.Visible = false end
			end
			for _,b in ipairs(ButtonHolder:GetChildren()) do
				if b:IsA('TextButton') then b.TextColor3 = Color3.fromRGB(100, 100, 100) end
				TabButton.TextColor3 = encrypt.colors.main_color
			end

			TabFrame.Visible = true
		end)

		function tab.new_group(group_name)
			local group = {}
			local group_name = group_name or 'group'
			tab.group_count += 1

			-- Creating UI
			local ContentHolder = encrypt.create('ScrollingFrame', {
				Parent = TabFrame,
				Name = group_name,
				Size = UDim2.new(0.5, -4, 1, 0),
				Position = UDim2.new(0, 0, 0, 0),
				CanvasSize = UDim2.new(0, 0, 0, 0),
				Active = true,
				ScrollBarThickness = 4,
				BorderSizePixel = 0,
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BackgroundColor3 = Color3.fromRGB(15, 15, 15),
				ScrollBarImageColor3 = encrypt.colors.main_color,
				BackgroundTransparency = 1.000,
				TopImage = "http://www.roblox.com/asset/?id=16747999837",
				BottomImage = "http://www.roblox.com/asset/?id=16748002234",
				MidImage = "rbxassetid://1510273450",
			})

			encrypt.create('UIListLayout', {
				Parent = ContentHolder, 
				SortOrder = Enum.SortOrder.LayoutOrder, 
				Padding = UDim.new(0, 4)
			})

			encrypt.create('UIPadding', {
				Parent = ContentHolder,
				PaddingRight = UDim.new(0, 8)
			})

			encrypt.threads['GroupResize'] = coroutine.wrap(function()
				task.wait(0.1)
				ContentHolder.Size = UDim2.new(1 / tab.group_count, -4, 1, 0)
			end)()

			-- Functions
			group.categoryCount = 0

			function group.new_category(title_text, title_alignment)
				group.categoryCount += 1

				local category = {
					label_count = 0,
					button_count = 0,
					toggle_count = 0,
					slider_count = 0,
					keybind_count = 0,
					textbox_count = 0,
					dropdown_count = 0,
					colorpicker_count = 0,
				}
				
				local title_text = title_text or 'Category'
				local title_alignment = title_alignment or 'Center'

				-- Creating UI
				local CategoryFrame = encrypt.create('Frame', {
					Parent = ContentHolder,
					Name = "CategoryFrame",
					BackgroundColor3 = encrypt.colors.categories,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BackgroundTransparency = 0,
					BorderSizePixel = 0,
					Size = UDim2.new(1, 0, 0, 24),
					LayoutOrder = group.categoryCount
				})

				local TitleText = encrypt.create('TextLabel', {
					Name = "TitleText",
					Parent = CategoryFrame,
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 1.000,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Position = UDim2.new(0.0411764719, 0, 0, 0),
					Size = UDim2.new(1, 0, 0, 20),
					Font = Enum.Font[encrypt.fonts.secondary],
					Text = tostring(title_text),
					TextColor3 = Color3.fromRGB(255, 255, 255),
					TextSize = 14.000,
					TextXAlignment = Enum.TextXAlignment[title_alignment]
				})

				encrypt.create('UICorner', {
					CornerRadius = UDim.new(0, 4),
					Parent = CategoryFrame,
				})

				encrypt.create('UIListLayout', {
					Parent = CategoryFrame,
					SortOrder = Enum.SortOrder.LayoutOrder,
				})

				encrypt.create('UIPadding', {
					Parent = CategoryFrame,
					PaddingLeft = UDim.new(0, 6),
					PaddingRight = UDim.new(0, 6),
				})

				ContentHolder.CanvasSize += UDim2.new(0, 0, 0, 28)

				-- Functions
				function category.append(y)
					CategoryFrame.Size += UDim2.new(0, 0, 0, y)
					ContentHolder.CanvasSize += UDim2.new(0, 0, 0, y)
				end

				function category.cut(y)
					CategoryFrame.Size -= UDim2.new(0, 0, 0, y)
					ContentHolder.CanvasSize -= UDim2.new(0, 0, 0, y)
				end

				function category.new_label(...)
					category.label_count += 1

					local text_label, default = {}, {
						text = 'label',
						alignment = 'Center',
					}

					local data = encrypt.overwrite(default, ... or {})

					--> Creating UI
					local container = encrypt.create('Frame', {
						Name = "Label",
						Parent = CategoryFrame,
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BackgroundTransparency = 1.000,
						BorderColor3 = Color3.fromRGB(0, 0, 0),
						BorderSizePixel = 0,
						Position = UDim2.new(0, 0, 0.13333334, 0),
						Size = UDim2.new(1, 0, 0, 20),
						LayoutOrder = #ContentHolder:GetChildren()+1,
					})

					local label = encrypt.create('TextLabel', {
						Name = "TextLabel",
						Parent = container,
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BackgroundTransparency = 1.000,
						BorderColor3 = Color3.fromRGB(0, 0, 0),
						BorderSizePixel = 0,
						AnchorPoint = Vector2.new(0, 0.5),
						Position = UDim2.new(0, 0, 0.5, 0),
						Size = UDim2.new(1, 0, 0, 20),
						Font = Enum.Font[encrypt.fonts.main],
						Text = data.text,
						TextColor3 = encrypt.colors.main_color,
						TextSize = 12.000,
						TextXAlignment = Enum.TextXAlignment[data.alignment],
						RichText = true,
					})

					--> Functions
					function text_label:Hide()
						category.cut(20)
						container.Visible = false
					end

					function text_label:Show()
						category.append(20)
						container.Visible = true
					end

					function text_label:Update(...)
						local new_data = encrypt.overwrite(data, ... or {})
						label.Text = new_data.text
						label.TextXAlignment = Enum.TextXAlignment[new_data.alignment]
					end

					function text_label:Align(option)
						local first_character = string.upper(option:sub(1,1))
						local rest = string.lower(option:sub(2,99))
						label.TextXAlignment = Enum.TextXAlignment[first_character .. rest]
					end

					function text_label:GetValue()
						return label.Text
					end

					function text_label:Destroy() 
						container:Destroy()
						category.cut(20)
					end

					category.append(20)
					return text_label
				end

				function category.new_toggle(...)
					category.toggle_count += 1

					local toggle, default = { 
						Methods = {  },
						OnValueChanged = { Connections = {} },
						value = false,
					}, {
						text = 'toggle',
						yield = false,
						callback = function()
							warn(string.format('[â—] Toggle #%d > no callback set.', category.toggle_count))
						end,
					}

					toggle.__index = toggle

					-- Connections
					function toggle.Methods:FireAll()
						for _, Connection in pairs(toggle.OnValueChanged.Connections) do
							if type(Connection) == 'function' then
								Connection(toggle.value)
							end
						end
					end

					function toggle.Methods:FilterConnections()
						for index, Connection in pairs(toggle.OnValueChanged.Connections) do
							if type(Connection) == 'table' and Connection.Callback == nil then
								table.remove(toggle.OnValueChanged.Connections, index)
							end
						end
					end
					
					function toggle.OnValueChanged:Connect(...)
						toggle.Methods:FilterConnections()
						
						local Connection = {}
						local Connected = true
						local Callback = ...
						local Index = #toggle.OnValueChanged.Connections+1

						if type(...) == 'function' then
							toggle.OnValueChanged.Connections[Index] = Callback
							--> print('Added Connection: '.. Index)
						end

						function Connection:Disconnect()
							toggle.OnValueChanged.Connections[Index] = nil
							toggle.Methods:FilterConnections()
							--> print('Removed Connection: '.. Index)
						end

						return Connection
					end

					local data = encrypt.overwrite(default, ... or {})

					-- Creating UI
					local container = encrypt.create('Frame', {
						Name = "Toggle",
						Parent = CategoryFrame,
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BackgroundTransparency = 1.000,
						BorderColor3 = Color3.fromRGB(0, 0, 0),
						BorderSizePixel = 0,
						Position = UDim2.new(0, 0, 0.13333334, 0),
						Size = UDim2.new(1, 0, 0, 20),
						LayoutOrder = #ContentHolder:GetChildren()+1,
					})

					local label = encrypt.create('TextLabel', {
						Name = "text",
						Parent = container,
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BackgroundTransparency = 1.000,
						BorderColor3 = Color3.fromRGB(0, 0, 0),
						BorderSizePixel = 0,
						AnchorPoint = Vector2.new(0, 0.5),
						Position = UDim2.new(0, 0, 0.5, 0),
						Size = UDim2.new(1, 0, 0, 20),
						Font = Enum.Font[encrypt.fonts.main],
						Text = data.text,
						TextColor3 = Color3.fromRGB(255, 255, 255),
						TextSize = 12.000,
						TextXAlignment = Enum.TextXAlignment.Left,
						RichText = true,
					})

					local button = encrypt.create('TextButton', {
						Name = "button",
						Parent = container,
						AnchorPoint = Vector2.new(1, 0.5),
						BackgroundColor3 = encrypt.colors.foreground,
						BorderColor3 = Color3.fromRGB(0, 0, 0),
						BorderSizePixel = 0,
						Position = UDim2.new(1, 0, 0.5, 0),
						Size = UDim2.new(0, 16, 0, 16),
						AutoButtonColor = false,
						Font = Enum.Font.SourceSans,
						Text = "",
						TextColor3 = Color3.fromRGB(0, 0, 0),
						TextSize = 14.000,
					})

					encrypt.create('UICorner', {
						CornerRadius = UDim.new(0, 2),
						Parent = button,
					})

					-- Functions
					local call = nil

					encrypt.threads.toggles[category.toggle_count] = button.MouseButton1Click:Connect(function()
						if data.yield then
							toggle.value = true
							toggle.Methods:FireAll()
							encrypt.tween(button, tween_info.new(.15), 'BackgroundColor3', encrypt.colors.main_color)
							call = coroutine.create(function()
								data.callback(toggle.value)
							end)

							coroutine.resume(call)

							encrypt.tween(button, tween_info.new(.15), 'BackgroundColor3', encrypt.colors.foreground)
							toggle.value = false
							toggle.Methods:FireAll()
							coroutine.close(call)
						elseif not data.yield then
							--encrypt.threads.toggles[category.toggle_count] = task.spawn(function()
							toggle.value = not toggle.value
							toggle.Methods:FireAll()
							if toggle.value then encrypt.tween(button, tween_info.new(.15), 'BackgroundColor3', encrypt.colors.main_color)
								data.callback(toggle.value)
							elseif not toggle.value then 
								encrypt.tween(button, tween_info.new(.15), 'BackgroundColor3', encrypt.colors.foreground)
								data.callback(toggle.value)
							end
						end
					end)

					function toggle:GetValue()
						return toggle.value
					end

					function toggle:UpdateValue(bool)
						warn('updated toggle to ' .. tostring(bool))
						toggle.value = bool

						if bool then
							encrypt.tween(button, tween_info.new(.15), 'BackgroundColor3', encrypt.colors.main_color)
						elseif not bool then 
							encrypt.tween(button, tween_info.new(.15), 'BackgroundColor3', encrypt.colors.foreground)
						end
					end

					function toggle:Hide()
						container.Visible = false
						category.cut(20)
					end

					function toggle:Show()
						container.Visible = true
						category.append(20)
					end

					function toggle:Destroy()
						container:Destroy()
						category.cut(20)
					end

					category.append(20)
					setreadonly(toggle.Methods, true)
					return toggle
				end

				function category.new_button(...)
					category.button_count += 1

					local text_button, default = {}, {
						text = 'button',
						callback = function()
							warn(string.format('[â—] Button #%d > no callback set.', category.button_count))
						end,
					}

					local data = encrypt.overwrite(default, ... or {})

					-- Creating UI
					local container = encrypt.create('Frame', {
						Name = "TextButton",
						Parent = CategoryFrame,
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BackgroundTransparency = 1.000,
						BorderColor3 = Color3.fromRGB(0, 0, 0),
						BorderSizePixel = 0,
						Position = UDim2.new(0, 0, 0.13333334, 0),
						Size = UDim2.new(1, 0, 0, 20),
						LayoutOrder = #ContentHolder:GetChildren()+1,
					})

					local button = encrypt.create('TextButton', {
						Name = "button",
						Parent = container,
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundColor3 = encrypt.colors.foreground,
						BorderColor3 = Color3.fromRGB(0, 0, 0),
						BorderSizePixel = 0,
						Position = UDim2.new(0.5, 0, 0.5, 0),
						Size = UDim2.new(1, 0, 0, 16),
						AutoButtonColor = true,
						Font = Enum.Font[encrypt.fonts.main],
						Text = data.text,
						TextColor3 = Color3.fromRGB(255, 255, 255),
						TextSize = 12.000,
						RichText = true,
					})

					encrypt.create('UICorner', {
						CornerRadius = UDim.new(0, 2),
						Parent = button,
					})

					CategoryFrame.Size += UDim2.new(0, 0, 0, 20)
					ContentHolder.CanvasSize += UDim2.new(0, 0, 0, 20)

					-- Functions
					button.MouseButton1Click:Connect(data.callback)

					function text_button:Hide()
						container.Visible = false
						category.cut(20)
					end

					function text_button:Show()
						container.Visible = true
						category.append(20)
					end

					function text_button:Update(...)
						local new_data = encrypt.overwrite(data, ... or {})
						button.Text = new_data.text
						data.callback = new_data.callback
					end

					function text_button:Destroy()
						container:Destroy()
						CategoryFrame.Size -= UDim2.new(0, 0, 0, 20)
						ContentHolder.CanvasSize -= UDim2.new(0, 0, 0, 20)
					end

					return text_button
				end

				function category.new_textbox(...)
					category.textbox_count += 1

					local text_box, default = {}, {
						text = 'button',
						placeholder_text = '...',
						callback = function()
							warn(string.format('[â—] Textbox #%d > no callback set.', category.textbox_count))
						end,
					}

					local data = encrypt.overwrite(default, ... or {})

					local text_box = { text = data.text }

					local container = encrypt.create('Frame', {
						Name = "TextBox",
						Parent = CategoryFrame,
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BackgroundTransparency = 1.000,
						BorderColor3 = Color3.fromRGB(0, 0, 0),
						BorderSizePixel = 0,
						Position = UDim2.new(0, 0, 0.13333334, 0),
						Size = UDim2.new(1, 0, 0, 20),
						LayoutOrder = #ContentHolder:GetChildren()+1,
					})

					local label = encrypt.create('TextLabel', {
						Name = "text",
						Parent = container,
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BackgroundTransparency = 1.000,
						BorderColor3 = Color3.fromRGB(0, 0, 0),
						BorderSizePixel = 0,
						Position = UDim2.new(0, 0, 0, 0),
						Size = UDim2.new(0, 93, 0, 20),
						Font = Enum.Font[encrypt.fonts.main],
						Text = data.text,
						TextColor3 = Color3.fromRGB(255, 255, 255),
						TextSize = 12.000,
						TextXAlignment = Enum.TextXAlignment.Left,
						RichText = true,
					})

					local textbox = encrypt.create('TextBox', {
						Name = "input",
						Parent = container,
						AnchorPoint = Vector2.new(1, 0.5),
						BackgroundColor3 = encrypt.colors.foreground,
						BorderColor3 = Color3.fromRGB(0, 0, 0),
						BorderSizePixel = 0,
						Position = UDim2.new(1, 0, 0.5, 0),
						Size = UDim2.new(0, 60, 0, 16),
						Font = Enum.Font[encrypt.fonts.main],
						PlaceholderText = data.placeholder_text,
						Text = '',
						TextColor3 = Color3.fromRGB(255, 255, 255),
						TextSize = 12.000,
						TextTruncate = 'AtEnd',
						TextWrapped = true,
					})

					encrypt.create('UICorner', {
						CornerRadius = UDim.new(0, 2),
						Parent = textbox,
					})

					CategoryFrame.Size += UDim2.new(0, 0, 0, 20)
					ContentHolder.CanvasSize += UDim2.new(0, 0, 0, 20)

					-- Functions
					textbox.FocusLost:Connect(function()
						text_box.text = textbox.Text
						data.callback(textbox.Text)
					end)

					function text_box:Hide()
						container.Visible = false
						category.cut(20)
					end

					function text_box:Show()
						container.Visible = true
						category.append(20)
					end

					function text_box:Disable()
						textbox.TextEditable = false
						textbox.TextColor3 = Color3.fromRGB(75,75,75)
					end

					function text_box:Enable()
						textbox.TextEditable = true
						textbox.TextColor3 = Color3.fromRGB(255,255,255)
					end

					function text_box:Update(new_text)
						text_box.text = new_text
						textbox.Text = new_text
					end

					function text_box:Destroy()
						container:Destroy()
						CategoryFrame.Size -= UDim2.new(0, 0, 0, 20)
						ContentHolder.CanvasSize -= UDim2.new(0, 0, 0, 20)
					end

					return text_box
				end

				function category.new_keybind(...)
					category.keybind_count += 1

					local keybind, default = {}, {
						text = 'keybind',
						keybind = '...',
						callback = function()
							warn(string.format('[â—] Keybind #%d > no callback set.', category.keybind_count))
						end,
					}

					local data = encrypt.overwrite(default, ... or {})

					keybind = { text = data.text, key = data.keybind, editing = false }

					local container = encrypt.create('Frame', {
						Name = "keybind",
						Parent = CategoryFrame,
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BackgroundTransparency = 1.000,
						BorderColor3 = Color3.fromRGB(0, 0, 0),
						BorderSizePixel = 0,
						Position = UDim2.new(0, 0, 0.13333334, 0),
						Size = UDim2.new(1, 0, 0, 20),
						LayoutOrder = #ContentHolder:GetChildren()+1,
					})

					local label = encrypt.create('TextLabel', {
						Name = "text",
						Parent = container,
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BackgroundTransparency = 1.000,
						BorderColor3 = Color3.fromRGB(0, 0, 0),
						BorderSizePixel = 0,
						Position = UDim2.new(0, 0, 0, 0),
						Size = UDim2.new(0, 140, 0, 20),
						Font = Enum.Font[encrypt.fonts.main],
						Text = data.text,
						TextColor3 = Color3.fromRGB(255, 255, 255),
						TextSize = 12.000,
						TextXAlignment = Enum.TextXAlignment.Left,
						RichText = true,
					})

					local button = encrypt.create('TextButton', {
						Name = "button",
						Parent = container,
						AnchorPoint = Vector2.new(1, 0.5),
						BackgroundColor3 = encrypt.colors.foreground,
						BorderColor3 = Color3.fromRGB(0, 0, 0),
						BorderSizePixel = 0,
						Position = UDim2.new(1, 0, 0.5, 0),
						Size = UDim2.new(0, 16, 0,16),
						ZIndex = 2,
						AutoButtonColor = false,
						Font = Enum.Font.SourceSans,
						Text = data.keybind,
						TextColor3 = Color3.fromRGB(150, 150, 150),
						TextSize = 15.000,
						TextWrapped = true,
						RichText = true,
					})

					encrypt.create('UICorner', {
						CornerRadius = UDim.new(0, 2),
						Parent = button,
					})

					CategoryFrame.Size += UDim2.new(0, 0, 0, 20)
					ContentHolder.CanvasSize += UDim2.new(0, 0, 0, 20)

					--> Functions
					button.MouseButton1Click:Connect(function()
						keybind.editing = true
						button.Text = '...'
						print('editing...')
					end)

					local thread = nil
					coroutine.wrap(function()
						thread = input_service.InputBegan:Connect(function(input)
							local focused = input_service:GetFocusedTextBox()
							if focused then return end

							if keybind.editing then
								keybind.key = tostring(input.KeyCode):gsub('Enum.KeyCode.', '')
								button.Text = keybind.key

								keybind.editing = false
							elseif keybind.key ~= '...' and input.KeyCode == Enum.KeyCode[keybind.key] then
								data.callback()
							end
						end)

						encrypt.threads.keybinds[category.keybind_count] = thread
					end)()

					function keybind:Hide()
						container.Visible = false
						category.cut(20)
					end

					function keybind:Show()
						container.Visible = true
						category.append(20)
					end

					function keybind:GetValue()
						return keybind.key
					end

					function keybind:Disconnect()
						thread:Disconnect()
					end

					function keybind:Destroy()
						container:Destroy()
						CategoryFrame.Size -= UDim2.new(0, 0, 0, 20)
						ContentHolder.CanvasSize -= UDim2.new(0, 0, 0, 20)
					end

					return keybind
				end

				function category.new_slider(...)
					category.slider_count += 1
					local slider, default = {}, {
						text = 'slider',
						value = 0,
						min = 1,
						max = 100,
						allow_decimals = false,
						callback = function()
							warn(string.format('[â—] Slider #%d > no callback set.', category.slider_count))
						end,
					}

					local data = encrypt.overwrite(default, ... or {})

					slider = { value = data.default_value }

					local container = encrypt.create('Frame', {
						Name = "slider",
						Parent = CategoryFrame,
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BackgroundTransparency = 1.000,
						BorderColor3 = Color3.fromRGB(0, 0, 0),
						BorderSizePixel = 0,
						Position = UDim2.new(0, 0, 0.13333334, 0),
						Size = UDim2.new(1, 0, 0, 20),
						LayoutOrder = #ContentHolder:GetChildren()+1,
					})

					local button = encrypt.create('TextButton', {
						Name = "button",
						Parent = container,
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundColor3 = encrypt.colors.foreground,
						BorderColor3 = Color3.fromRGB(0, 0, 0),
						BorderSizePixel = 0,
						Position = UDim2.new(0.5, 0, 0.5, 0),
						Size = UDim2.new(1, 0, 0, 16),
						AutoButtonColor = false,
						Font = Enum.Font[encrypt.fonts.main],
						Text = "",
						TextColor3 = Color3.fromRGB(255, 255, 255),
						TextSize = 12.000,
						RichText = true,
					})

					local fill = encrypt.create('Frame', {
						Name = "fill",
						Parent = button,
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BackgroundTransparency = 0.750,
						BorderColor3 = Color3.fromRGB(0, 0, 0),
						BorderSizePixel = 0,
						Size = UDim2.new(0, 0, 1, 0),
						ZIndex = 2,
					})

					local label = encrypt.create('TextLabel', {
						Name = "label",
						Parent = button,
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BackgroundTransparency = 1.000,
						BorderColor3 = Color3.fromRGB(0, 0, 0),
						BorderSizePixel = 0,
						Position = UDim2.new(0.5, 0, 0.5, 0),
						Size = UDim2.new(1, 0, 1, 0),
						ZIndex = 3,
						Font = Enum.Font[encrypt.fonts.main],
						Text = data.text,
						TextColor3 = Color3.fromRGB(255, 255, 255),
						TextSize = 11.000,
						TextStrokeTransparency = 0.500,
						TextWrapped = true,
						RichText = true,
					})

					encrypt.create('UICorner', {
						CornerRadius = UDim.new(0, 2),
						Parent = button,
					})

					encrypt.create('UICorner', {
						CornerRadius = UDim.new(0, 2),
						Parent = fill,
					})

					--encrypt.create('UIPadding', {
					--	PaddingLeft = UDim.new(0, 5),
					--	PaddingRight = UDim.new(0, 5),
					--	Parent = container
					--})

					CategoryFrame.Size += UDim2.new(0, 0, 0, 20)
					ContentHolder.CanvasSize += UDim2.new(0, 0, 0, 20)

					--> Values
					local min = data.min
					local max = data.max
					slider.value = data.value

					--> Variables
					local plr = game.Players.LocalPlayer
					local mouse = plr:GetMouse()

					local fill = button.fill
					fill.Size = UDim2.new((slider.value - min) / (max - min), 0, 1, 0)

					-- local text = 'slider'
					local label = button.label

					local mouse_down = false
					local mouse_on = false

					--> Connections
					button.MouseButton1Up:Connect(function() mouse_down = false label.Text = data.text end)
					button.MouseEnter:Connect(function() mouse_on = true end)
					button.MouseLeave:Connect(function() mouse_on = false end)

					button.MouseButton1Down:Connect(function()
						mouse_down = true
						encrypt.tween(fill, tween_info.new(.25, easing_style.Linear, easing_direction.InOut), 'BackgroundTransparency', 0)
						local mouse_x = math.clamp(mouse.X - button.AbsolutePosition.X, min, button.AbsoluteSize.X)
						if data.allow_decimals then
							slider.value = (math.clamp((mouse_x / button.AbsoluteSize.X) * (max - min) + min, min, max))
						elseif not data.allow_decimals then
							slider.value = math.floor(math.clamp((mouse_x / button.AbsoluteSize.X) * (max - min) + min, min, max))
						end

						-- tween(fill, ti.new(.25, es.Quad, easing_direction.InOut), 'Size', UDim2.new((slider.value - min) / (max - min), 0, 1, 0))
						fill.Size = UDim2.new((slider.value - min) / (max - min), 0, 1, 0)
						label.Text = tostring(slider.value):sub(1,4)
						local s, err = pcall(function()
							data.callback(slider.value)
						end)

						if err then warn('err') end
					end)

					mouse.Move:Connect(function()
						if mouse_down then	
							local mouse_x = math.clamp(mouse.X - button.AbsolutePosition.X, min, button.AbsoluteSize.X)
							if data.allow_decimals then
								slider.value = (math.clamp((mouse_x / button.AbsoluteSize.X) * (max - min) + min, min, max))
							elseif not data.allow_decimals then
								slider.value = math.floor(math.clamp((mouse_x / button.AbsoluteSize.X) * (max - min) + min, min, max))
							end

							-- tween(fill, ti.new(.25, es.Quad, easing_direction.InOut), 'Size', UDim2.new((slider.value - min) / (max - min), 0, 1, 0))
							fill.Size = UDim2.new((slider.value - min) / (max - min), 0, 1, 0)
							label.Text = tostring(slider.value):sub(1,4)
							local s, err = pcall(function()
								data.callback(slider.value)
							end)

							if err then warn('err') end
						end
					end)

					input_service.InputEnded:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.MouseButton1 then
							mouse_down = false
							label.Text = data.text
							encrypt.tween(fill, tween_info.new(.25, easing_style.Linear, easing_direction.InOut), 'BackgroundTransparency', .75)
						end
					end)

					function slider:Hide()
						container.Visible = false
						category.cut(20)
					end

					function slider:Show()
						container.Visible = true
						category.append(20)
					end

					function slider:GetValue()
						return(slider.value)
					end

					function slider:Destroy()
						container:destroy()
						CategoryFrame.Size -= UDim2.new(0, 0, 0, 20)
						ContentHolder.CanvasSize -= UDim2.new(0, 0, 0, 20)
					end

					return slider
				end

				function category.new_dropdown(...)
					category.dropdown_count += 1
					local dropdown, default = {}, {
						text = 'dropdown',
						options = {},
						default_selection = nil,
						callback = function()
							warn(string.format('[â—] Dropdown #%d > no callback set.', category.dropdown_count))
						end,
					}

					local data = encrypt.overwrite(default, ... or {})

					dropdown = { selection = data.default_selection, options = {} }

					local container = encrypt.create('Frame', {
						Name = "dropdown",
						Parent = CategoryFrame,
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BackgroundTransparency = 1.000,
						BorderColor3 = Color3.fromRGB(0, 0, 0),
						BorderSizePixel = 0,
						Position = UDim2.new(0, 0, 0.13333334, 0),
						Size = UDim2.new(1, 0, 0, 20),
						LayoutOrder = #ContentHolder:GetChildren()+1,
					})

					local button = encrypt.create('TextButton', {
						Name = "1button",
						Parent = container,
						AnchorPoint = Vector2.new(0.5, 0),
						BackgroundColor3 = Color3.fromRGB(23, 23, 23),
						BorderColor3 = Color3.fromRGB(0, 0, 0),
						BorderSizePixel = 0,
						Position = UDim2.new(0.5, 0, 0, 0),
						Size = UDim2.new(1, 0, 0, 16),
						Font = Enum.Font[encrypt.fonts.main],
						Text = data.text,
						RichText = true,
						TextColor3 = Color3.fromRGB(255, 255, 255),
						TextSize = 12.000,
					})

					local arrow = encrypt.create('ImageLabel', {
						Parent = button,
						AnchorPoint = Vector2.new(1, 0),
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BackgroundTransparency = 1.000,
						BorderColor3 = Color3.fromRGB(0, 0, 0),
						BorderSizePixel = 0,
						Position = UDim2.new(1, 0, 0.125, 0),
						Size = UDim2.new(0, 20, 0, 12),
						Image = "rbxassetid://13273265041",
						ScaleType = Enum.ScaleType.Fit,
					})

					local options_frame = encrypt.create('Frame', {
						Parent = container,
						BackgroundColor3 = Color3.fromRGB(23, 23, 23),
						BorderColor3 = Color3.fromRGB(0, 0, 0),
						BorderSizePixel = 0,
						Size = UDim2.new(1, 0, 0, 0),
						Visible = false,
					})

					encrypt.create('UIListLayout', {
						Parent = container,
						SortOrder = Enum.SortOrder.Name,
					})

					encrypt.create('UIPadding', {
						PaddingTop = UDim.new(0, 2),
						PaddingBottom = UDim.new(0, 2),
						Parent = container,
					})


					encrypt.create('UICorner', {
						CornerRadius = UDim.new(0, 2),
						Parent = button,
					})

					encrypt.create('UICorner', {
						CornerRadius = UDim.new(0, 2),
						Parent = options_frame,
					})

					encrypt.create('UIListLayout', {
						Parent = options_frame,
						SortOrder = Enum.SortOrder.LayoutOrder,
					})

					CategoryFrame.Size += UDim2.new(0, 0, 0, 20)
					ContentHolder.CanvasSize += UDim2.new(0, 0, 0, 20)

					button.MouseButton1Click:Connect(function()
						data.showing_options = not data.showing_options
						options_frame.Visible = data.showing_options

						if data.showing_options then
							container.Size += UDim2.new(0, 0, 0, options_frame.Size.Y.Offset)
							CategoryFrame.Size += UDim2.new(0, 0, 0, options_frame.Size.Y.Offset)
							ContentHolder.CanvasSize += UDim2.new(0, 0, 0, options_frame.Size.Y.Offset)

							arrow.Rotation = 180
						elseif not data.showing_options then
							container.Size -= UDim2.new(0, 0, 0, options_frame.Size.Y.Offset)
							CategoryFrame.Size -= UDim2.new(0, 0, 0, options_frame.Size.Y.Offset)
							ContentHolder.CanvasSize -= UDim2.new(0, 0, 0, options_frame.Size.Y.Offset)

							arrow.Rotation = 0	
						end
					end)

					function dropdown:AddOption(option)
						table.insert(dropdown.options, option)

						local option_button = encrypt.create('TextButton', {
							Parent = options_frame,
							BackgroundColor3 = Color3.fromRGB(255, 255, 255),
							BackgroundTransparency = 1.000,
							BorderColor3 = Color3.fromRGB(0, 0, 0),
							BorderSizePixel = 0,
							Size = UDim2.new(1, 0, 0, 20),
							Font = Enum.Font[encrypt.fonts.main],
							Name = option,
							Text = option,
							RichText = true,
							TextColor3 = Color3.fromRGB(125, 125, 125),
							TextSize = 12.000,
						})

						if option == dropdown.selection then
							option_button.BackgroundTransparency = .95
							option_button.TextColor3 = Color3.fromRGB(125, 125, 125)
						end

						option_button.MouseButton1Click:Connect(function()
							for _, b in ipairs(options_frame:GetChildren()) do
								if b:IsA('TextButton') then
									b.TextColor3 = Color3.fromRGB(125, 125, 125)
									b.BackgroundTransparency = 1
								end
							end

							option_button.TextColor3 = Color3.fromRGB(255, 255, 255)
							option_button.BackgroundTransparency = .95
							dropdown.selection = option

							data.callback(dropdown.selection)
						end)

						options_frame.Size += UDim2.new(0, 0, 0, 20)
					end

					function dropdown:RemoveOption(option)
						if not table.find(option) then return warn("[!] ENCRYPT > Could not remove option because it doesn't exist") end

						table.remove(dropdown.options, option)
						options_frame[option]:Destroy()

						options_frame.Size -= UDim2.new(0, 0, 0, 20)
					end

					function dropdown:Hide()
						container.Visible = false
						category.cut(20)
					end

					function dropdown:Show()
						container.Visible = true
						category.append(20)
					end

					function dropdown:GetValue()
						return dropdown.selection
					end

					function dropdown:Destroy()
						container:Destroy()
						CategoryFrame.Size -= UDim2.new(0, 0, 0, 20)
						ContentHolder.CanvasSize -= UDim2.new(0, 0, 0, 20)
					end

					return dropdown
				end

				function category.new_colorpicker(...)
					category.colorpicker_count += 1
					local color_picker, default = {}, {
						text = 'color picker',
						default_color = Color3.fromRGB(255, 255, 255),
						callback = function() 
							warn(string.format('[â—] Color Picker #%d > no callback set.', category.colorpicker_count))
						end,
					}

					local data = encrypt.overwrite(default, ... or {})

					color_picker = { color = data.default_color }

					local container = encrypt.create("Frame", {
						Name = "container",
						Parent = CategoryFrame,
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BackgroundTransparency = 1.000,
						BorderColor3 = Color3.fromRGB(0, 0, 0),
						BorderSizePixel = 0,
						Position = UDim2.new(0, 0, 0.13333334, 0),
						Size = UDim2.new(1, 0, 0, 20),
						ZIndex = 99999,
						LayoutOrder = #ContentHolder:GetChildren()+1,
					})

					local label = encrypt.create("TextLabel", {
						Name = "text",
						Parent = container,
						AnchorPoint = Vector2.new(0, 0.5),
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BackgroundTransparency = 1.000,
						BorderColor3 = Color3.fromRGB(0, 0, 0),
						BorderSizePixel = 0,
						Position = UDim2.new(0, 0, 0.5, 0),
						Size = UDim2.new(1, 0, 0, 20),
						Font = Enum.Font[encrypt.fonts.main],
						Text = data.text,
						TextColor3 = Color3.fromRGB(255, 255, 255),
						TextSize = 12.000,
						TextXAlignment = Enum.TextXAlignment.Left,
						RichText = true,
					})

					local button = encrypt.create("TextButton", {
						Name = "button",
						Parent = container,
						AnchorPoint = Vector2.new(1, 0.5),
						BackgroundColor3 = data.default_color,
						BorderColor3 = Color3.fromRGB(0, 0, 0),
						BorderSizePixel = 0,
						Position = UDim2.new(1, 0, 0.5, 0),
						Size = UDim2.new(0, 16, 0, 16),
						AutoButtonColor = false,
						Text = "",
						TextColor3 = Color3.fromRGB(0, 0, 0),
						TextSize = 14.000,
					})

					local color_pick = encrypt.create('Frame', {
						Name = "color_pick",
						Parent = button,
						BackgroundColor3 = Color3.fromRGB(10, 10, 10),
						BorderColor3 = Color3.fromRGB(76, 76, 76),
						BorderSizePixel = 0,
						Position = UDim2.new(0, -88, 0, 21),
						Size = UDim2.new(0, 105, 0, 83),
						SizeConstraint = Enum.SizeConstraint.RelativeXX,
						ZIndex = 99,
						Visible = false,
					})

					local rgb_map = encrypt.create('ImageLabel', {
						Name = "rgb_map",
						Parent = color_pick,
						AnchorPoint = Vector2.new(0, 0.5),
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BorderColor3 = Color3.fromRGB(40, 40, 40),
						Position = UDim2.new(-0.0207375139, 6, 0.49404788, 0),
						Size = UDim2.new(0, 82, 0, 76),
						ZIndex = 4,
						Image = "rbxassetid://1433361550",
						SliceCenter = Rect.new(10, 10, 90, 90),
					})

					local hitbox = encrypt.create('TextButton', {
						Name = "Hitbox",
						Parent = rgb_map,
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BackgroundTransparency = 1.000,
						Size = UDim2.new(0, 200, 0, 50),
						TextColor3 = Color3.fromRGB(0, 0, 0),
						TextSize = 14.000,
						TextTransparency = 1.000,
					})

					local value_map = encrypt.create('ImageLabel', {
						Name = "value_map",
						Parent = color_pick,
						AnchorPoint = Vector2.new(0, 0.5),
						BackgroundColor3 = Color3.fromRGB(0, 0, 0),
						BorderColor3 = Color3.fromRGB(40, 40, 40),
						Position = UDim2.new(0, 91, 0.493999988, 0),
						Size = UDim2.new(0, 10, 0, 76),
						ImageColor3 = data.default_color,
						ZIndex = 4,
						Image = "rbxassetid://359311684",
						SliceCenter = Rect.new(10, 10, 90, 90),
					})

					local marker = encrypt.create('Frame', {
						Name = "Marker",
						Parent = rgb_map,
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BorderColor3 = Color3.fromRGB(0, 0, 0),
						BorderSizePixel = 0,
						Position = UDim2.new(0.5, 0, 0.5, 0),
						Size = UDim2.new(0, 5, 0, 5),
						ZIndex = 5,
					})

					local marker_2 = encrypt.create('Frame', {
						Name = "Marker",
						Parent = value_map,
						AnchorPoint = Vector2.new(0.5, 1),
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BorderColor3 = Color3.fromRGB(0, 0, 0),
						Position = UDim2.new(0.5, 0, 0, 1),
						Size = UDim2.new(1, 2, 0, 1),
						ZIndex = 5,
					})

					encrypt.create("UICorner", { CornerRadius = UDim.new(0, 2), Parent = button })
					encrypt.create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = marker })
					encrypt.create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = rgb_map })
					encrypt.create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = value_map })
					encrypt.create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = color_pick })

					encrypt.create('UIStroke', { Color = Color3.fromRGB(0, 0, 0), Transparency = 0.65, Parent = marker })
					encrypt.create('UIStroke', { Color = Color3.fromRGB(35, 35, 35), Transparency = 0, Parent = color_pick })

					encrypt.create('UIGradient', {
						Color = ColorSequence.new{
							ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 255, 255)), 
							ColorSequenceKeypoint.new(1.00, Color3.fromRGB(155, 155, 155)),
						},
						Rotation = 90,
						Parent = button,
					})

					button.MouseButton1Click:Connect(function()
						color_pick.Visible = not color_pick.Visible
					end)

					local mouse_down = false
					local current_color_h, current_color_s, current_color_v = data.default_color:ToHSV()
					local current_color = Color3.fromHSV(current_color_h, current_color_s, current_color_v)

					local color_data = {
						current_color_h,
						current_color_s,
						current_color_v,
					}

					local function set_color(hue,sat,val)
						color_data = {hue or color_data[1],sat or color_data[2],val or color_data[3]}

						color_picker.color = Color3.fromHSV(color_data[1], color_data[2], color_data[3])
						current_color = Color3.fromHSV(color_data[1],color_data[2],color_data[3])
						value_map.ImageColor3 = Color3.fromHSV(color_data[1],color_data[2],1)

						button.BackgroundColor3 = current_color

						data.callback(color_picker.color)
					end

					local function in_bounds(i)
						local x, y = mouse.X - i.AbsolutePosition.X, mouse.Y - i.AbsolutePosition.Y
						local max_x, max_y = i.AbsoluteSize.X, i.AbsoluteSize.Y

						if x >= 0 and y >= 0 and x <= max_x and y <= max_y then
							return x/max_x,y/max_y
						end
					end

					local function update_rgb()
						if mouse_down then
							local x,y = in_bounds(rgb_map)
							if x and y then
								rgb_map:WaitForChild("Marker").Position = UDim2.new(x,0,y,0)
								set_color(1 - x,1 - y)
							end

							local x,y = in_bounds(value_map)
							if x and y then
								value_map:WaitForChild("Marker").Position = UDim2.new(0.5,0,y,0)
								set_color(nil,nil,1 - y)
							end
						end
					end

					update_rgb()

					color_pick.MouseEnter:Connect(function()	
						input_service.MouseIconEnabled = false
						custom_cursor.Visible = true
						-- encrypt.custom_cursor.enabled = true
					end)

					color_pick.MouseLeave:Connect(function()	
						input_service.MouseIconEnabled = true
						custom_cursor.Visible = false
						-- encrypt.custom_cursor.enabled = false
					end)

					rgb_map.MouseLeave:Connect(function() mouse_down = false end)
					value_map.MouseLeave:Connect(function() mouse_down = false end)
					hitbox.MouseButton1Up:Connect(function() mouse_down = false end)
					hitbox.MouseButton1Down:Connect(function() mouse_down = true end)

					mouse.Move:connect(update_rgb)

					CategoryFrame.Size += UDim2.new(0, 0, 0, 20)
					ContentHolder.CanvasSize += UDim2.new(0, 0, 0, 20)

					function color_picker:Hide()
						container.Visible = false
						category.cut(20)
					end

					function color_picker:Show()
						container.Visible = true
						category.append(20)
					end

					function color_picker:GetValue()
						return color_picker.color
					end

					function color_picker:Destroy()
						CategoryFrame.Size -= UDim2.new(0, 0, 0, 20)
						ContentHolder.CanvasSize -= UDim2.new(0, 0, 0, 20)

						container:Destroy()
					end

					return color_picker
				end

				function category.import_custom(instance)
					pcall(function()
						instance.Parent = CategoryFrame
						CategoryFrame.Size += UDim2.new(0, 0, instance.Size.Y.Scale, instance.Size.Y.Offset)
					end)
				end

				return category
			end

			return group
		end

		if window.tab_count <= 1 then
			TabFrame.Visible = true
			TabButton.TextColor3 = encrypt.colors.main_color
		end

		return tab
	end

	return window
end

function encrypt:exit()
	encrypt.instance:Destroy()

	for _, t in pairs(encrypt.threads) do
		if pcall(function() coroutine.close(t) end) then print("Closed thread: " .. t) end

		for i, thread in pairs(t) do
			pcall(function()
				task.cancel(t[i])
				print('Closed thread: '.. thread)
			end)

			pcall(function()
				thread:Disconnect()
				print('Closed thread: '.. thread)
			end)
		end
	end

	warn('[-] ENCRYPT > CLOSED')
end

function encrypt:toggle() 
	encrypt.instance.Enabled = not encrypt.instance.Enabled 
end

getgenv().ENCRYPT_LIB_LOADED = true
getgenv().ENCRYPT_INSTANCE = encrypt.instance

if not pcall(function() initialize(getgenv().ENCRYPT_INSTANCE, false) end) then
	warn('[!] ENCRYPT > Could not initialize encrypt')
else
	warn('[+] ENCRYPT > LOADED IN '..tostring(tick() - start_time):sub(1,4) .. ' SECONDS')
end

spawn(function()
	task.wait(0.1)
	encrypt.on_loaded()
end)

return encrypt
