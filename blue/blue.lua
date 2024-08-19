--* Dependancies
local Blue = { i = nil }
local load_to_core = loadstring(game:HttpGet('https://www.doom-is-a-skid.lol/coreload.lua'))()

--* Module funcs
function Blue.make(class : string, properties : {})
	local i

	local madeInstance, errorMessage = pcall(function()
		i = Instance.new(class)	
	end)

	if not madeInstance then
		return error(errorMessage, 99)
	end

	for property, value in properties do
		local _, err = pcall(function()
			i[property] = value
		end)

		if err then 
			return warn(`Problem adding instance: {err}`) 
		end
	end

	return i or nil
end

function Blue.ini()
	Blue.i = Instance.new('ScreenGui')
	--Blue.i.Parent = game.Players.LocalPlayer.PlayerGui
	load_to_core(Blue.i, true)
end

function Blue.exit()
	Blue.i:Destroy()
end

function Blue.win(a1)
	local Win = {}
	
	--* Instances
	local Window = Blue.make("Frame", { Parent = Blue.i, Name = [[Window]], BorderSizePixel = 0, Size = UDim2.new(0, 250, 0, 40), BorderColor3 = Color3.fromRGB(0, 0, 0), Position = UDim2.new(0.0177409817, 0, 0.0259965342, 0), BackgroundTransparency = 0.3499999940395355, BackgroundColor3 = Color3.fromRGB(35, 35, 35),})
	local Topbar = Blue.make("Frame", { Parent = Window, Name = [[Topbar]], LayoutOrder = -999, BorderSizePixel = 0, Size = UDim2.new(0, 250, 0, 30), BorderColor3 = Color3.fromRGB(0, 0, 0), BackgroundColor3 = Color3.fromRGB(105, 132, 255),})
	local TextLabel = Blue.make("TextLabel", { Parent = Topbar, BorderSizePixel = 0, BackgroundColor3 = Color3.fromRGB(255, 255, 255), TextSize = 14, Size = UDim2.new(0, 250, 0, 30), TextXAlignment = Enum.TextXAlignment.Left, BorderColor3 = Color3.fromRGB(0, 0, 0), Text = a1, FontFace = Font.new('rbxassetid://11702779409', Enum.FontWeight.Regular, Enum.FontStyle.Normal), TextColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 1,})
	local CloseButton = Blue.make("TextButton", { Parent = Topbar, BorderSizePixel = 0, BackgroundColor3 = Color3.fromRGB(255, 255, 255), TextSize = 14, Size = UDim2.new(0, 30, 0, 30), BorderColor3 = Color3.fromRGB(0, 0, 0), Text = [[x]], FontFace = Font.new('rbxassetid://11702779409', Enum.FontWeight.Regular, Enum.FontStyle.Normal), Position = UDim2.new(0.875999987, 0, 0, 0), TextColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 1,})
	local Filler = Blue.make("Frame", { Parent = Window, Name = [[Filler]], BorderSizePixel = 0, Size = UDim2.new(0, 0, 0, 5), BorderColor3 = Color3.fromRGB(0, 0, 0), BackgroundColor3 = Color3.fromRGB(255, 255, 255),})
	local UIListLayout = Blue.make("UIListLayout", { Parent = Window, SortOrder = Enum.SortOrder.LayoutOrder,})
	local UIPadding = Blue.make("UIPadding", { Parent = TextLabel, PaddingLeft = UDim.new(0, 10),})
	
	--* Drag
	task.spawn(function()
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
		local function ValidInput(InputType)
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

			if ValidInput(InputType) and Window.GuiState == Enum.GuiState.Press then
				DragStartPos = Input.Position
				FrameStartPos = Window.Position
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

					Window.Position = UDim2.new(
						FrameStartPos.X.Scale, FrameStartPos.X.Offset + DeltaPosition.X,
						FrameStartPos.Y.Scale, FrameStartPos.Y.Offset + DeltaPosition.Y
					)
				end
			end
		end)
	end)
	
	CloseButton.MouseButton1Click:Connect(function()
		Window:Destroy()
	end)
	
	--* Library
	function Win.res(num)
		Window.Size += UDim2.fromOffset(0, num)
	end
	
	function Win.add(a1, t1)
		local data = t1
		if a1 == 'toggle' then
			local Toggle = { v = false }
			
			local ToggleFrame = Blue.make("Frame", { Parent = Window, Name = [[ToggleFrame]], BorderSizePixel = 0, Size = UDim2.new(0, 250, 0, 25), BorderColor3 = Color3.fromRGB(0, 0, 0), Position = UDim2.new(0, 0, 0.0799999982, 0), BackgroundTransparency = 1, BackgroundColor3 = Color3.fromRGB(255, 255, 255),})
			local ToggleButton = Blue.make("TextButton", { Parent = ToggleFrame, Name = [[ToggleButton]], AutoButtonColor = false, BorderSizePixel = 0, BackgroundColor3 = Color3.fromRGB(150, 150, 150), AnchorPoint = Vector2.new(0, 0.5), TextSize = 14, Size = UDim2.new(0, 10, 0, 10), BorderColor3 = Color3.fromRGB(0, 0, 0), Text = [[]], Font = Enum.Font.SourceSans, Position = UDim2.new(0.916000009, 0, 0.5, 0), TextColor3 = Color3.fromRGB(0, 0, 0), BackgroundTransparency = 0.550000011920929,})
			local UICorner = Blue.make("UICorner", { Parent = ToggleButton, CornerRadius = UDim.new(1, 0),})
			local UIStroke = Blue.make("UIStroke", { Parent = ToggleButton, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Transparency = 0.5, Thickness = 3, Color = Color3.fromRGB(255, 255, 255),})
			local TextLabel = Blue.make("TextLabel", { Parent = ToggleFrame, BorderSizePixel = 0, BackgroundColor3 = Color3.fromRGB(255, 255, 255), TextSize = 14, Size = UDim2.new(0, 200, 1, 0), TextXAlignment = Enum.TextXAlignment.Left, BorderColor3 = Color3.fromRGB(0, 0, 0), Text = [[Skeleton]], FontFace = Font.new('rbxassetid://11702779409', Enum.FontWeight.Regular, Enum.FontStyle.Normal), TextColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 1,})
			local UIPadding = Blue.make("UIPadding", { Parent = TextLabel, PaddingLeft = UDim.new(0, 10),})
			
			ToggleButton.MouseButton1Click:Connect(function()
				Toggle.v = not Toggle.v
				ToggleButton.BackgroundTransparency = Toggle.v and 0 or 0.55
				
				if data.callback then
					data.callback()
				end
			end)
			
			Win.res(25)
			
			return Toggle
		end
	end
	
	return Win
end

return Blue
