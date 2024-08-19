--* doom.lol
-- >> drawing library for solara and other 0% unc executors
local Drawing = {}
setmetatable(Drawing, {})
Drawing.__index = Drawing
Drawing.cache = {}
Drawing.service = nil

-- >> services
local RunService = game:GetService('RunService')
local CoreGui = game:GetService('CoreGui')
local Players = game:GetService('Players')

-- >> variables
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild('PlayerGui')

-- >> check permissions
local CoreGuiAvailable, Message = pcall(function()
	local Test = Instance.new('ScreenGui', CoreGui)

	task.delay(0.01, function()
		Test:Destroy()
	end)
end)

if CoreGuiAvailable then 
	Drawing.service = CoreGui
	print('Environment has access to CoreGui!') 
elseif not CoreGuiAvailable then 
	Drawing.service = PlayerGui
	warn('Environment does not have access to CoreGui.')
end

-- >> initialize cache
Drawing.cache = Instance.new('ScreenGui', Drawing.service)
Drawing.cache.IgnoreGuiInset = true
Drawing.cache.ResetOnSpawn = false

local function MakeInstance(class : string, properties : {})
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

function Drawing.clearcache()
	for _, Drawing in Drawing.cache:GetChildren() do
		pcall(function() Drawing:Destroy() end)
	end
end

function Drawing.new(__type : string)
	--* Box
	if __type == 'BoundingBox' then
		--* Metadata
		local BoundingBox = {
			--* Vector
			Position = Vector2.new(0, 0),

			--* Color3
			FillColor = Color3.fromRGB(255, 255, 255),
			OutlineColor = Color3.fromRGB(0, 0, 0),

			--* Bool
			Visible = true,

			--* Number
			FillTransparency = 0,
			OutlineTransparency = 0,
			Size = { X = 10, Y = 10},
			OutlineThickness = 1,
		}
		
		--* Make instances
		local Drawing = MakeInstance("Frame", { Parent = Drawing.cache, Name = [[BoundingBox]], AnchorPoint = Vector2.new(.5,.5), BorderSizePixel = 0, Size = UDim2.new(0, 182, 0, 282), BorderColor3 = Color3.fromRGB(0, 0, 0), Position = UDim2.new(0.759148955, 0, 0.363679677, 0), BackgroundTransparency = 1, BackgroundColor3 = Color3.fromRGB(0, 0, 0),})
		local BorderLines = {
			[1] = MakeInstance("Frame", { Parent = Drawing, AnchorPoint = Vector2.new(0, 1), BorderSizePixel = 0, Size = UDim2.new(0, 2, 0.35, 0), BorderColor3 = Color3.fromRGB(0, 0, 0), Position = UDim2.new(0, 0, 1, 0), BackgroundColor3 = Color3.fromRGB(255, 255, 255),});
			[2] = MakeInstance("Frame", { Parent = Drawing, AnchorPoint = Vector2.new(1, 0), BorderSizePixel = 0, Size = UDim2.new(0, 2, 0.35, 0), BorderColor3 = Color3.fromRGB(0, 0, 0), Position = UDim2.new(1, 0, 0, 0), BackgroundColor3 = Color3.fromRGB(255, 255, 255),});
			[3] = MakeInstance("Frame", { Parent = Drawing, AnchorPoint = Vector2.new(1, 1), BorderSizePixel = 0, Size = UDim2.new(0, 2, 0.35, 0), BorderColor3 = Color3.fromRGB(0, 0, 0), Position = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.fromRGB(255, 255, 255),});
			[4] = MakeInstance("Frame", { Parent = Drawing, AnchorPoint = Vector2.new(0, 0), BorderSizePixel = 0, Size = UDim2.new(0.35, 0, 0, 2), BorderColor3 = Color3.fromRGB(0, 0, 0), Position = UDim2.new(0, 0, 0, 0), BackgroundColor3 = Color3.fromRGB(255, 255, 255),});
			[5] = MakeInstance("Frame", { Parent = Drawing, AnchorPoint = Vector2.new(1, 1), BorderSizePixel = 0, Size = UDim2.new(0.35, 0, 0, 2), BorderColor3 = Color3.fromRGB(0, 0, 0), Position = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.fromRGB(255, 255, 255),});
			[6] = MakeInstance("Frame", { Parent = Drawing, AnchorPoint = Vector2.new(1, 0), BorderSizePixel = 0, Size = UDim2.new(0.35, 0, 0, 2), BorderColor3 = Color3.fromRGB(0, 0, 0), Position = UDim2.new(1, 0, 0, 0), BackgroundColor3 = Color3.fromRGB(255, 255, 255),});
			[7] = MakeInstance("Frame", { Parent = Drawing, AnchorPoint = Vector2.new(0, 1), BorderSizePixel = 0, Size = UDim2.new(0.35, 0, 0, 2), BorderColor3 = Color3.fromRGB(0, 0, 0), Position = UDim2.new(0, 0, 1, 0), BackgroundColor3 = Color3.fromRGB(255, 255, 255),});
			[8] = MakeInstance("Frame", { Parent = Drawing, AnchorPoint = Vector2.new(0, 0), BorderSizePixel = 0, Size = UDim2.new(0, 2, 0.35, 0), BorderColor3 = Color3.fromRGB(0, 0, 0), Position = UDim2.new(0, 0, 0, 0), BackgroundColor3 = Color3.fromRGB(255, 255, 255),});
		}
		
		--* Threads
		local UpdateThread = RunService.Stepped:Connect(function()
			Drawing.Visible = BoundingBox.Visible
			Drawing.Size = UDim2.new(0, BoundingBox.Size.X, 0, BoundingBox.Size.Y)
			Drawing.Position = UDim2.new(0, BoundingBox.Position.X, 0, BoundingBox.Position.Y)
			Drawing.BackgroundColor3 = BoundingBox.FillColor
			Drawing.BackgroundTransparency = BoundingBox.FillTransparency
			
			for _, Line in BorderLines do
				Line.BackgroundColor3 = BoundingBox.OutlineColor
				Line.BackgroundTransparency = BoundingBox.OutlineTransparency
			end
		end)

		--* Functions
		function BoundingBox:Remove()
			Drawing:Destroy()
			UpdateThread:Disconnect()
			BoundingBox = nil
		end

		return BoundingBox
	end
	
	if __type == 'Box' then
		--* Metadata
		local Box = {
			--* Vector
			Position = Vector2.new(0, 0),

			--* Color3
			Color = Color3.fromRGB(255, 255, 255),
			OutlineColor = Color3.fromRGB(0, 0, 0),

			--* Bool
			Filled = true,
			Outline = false,
			Visible = false,

			--* Number
			FillTransparency = 0,
			OutlineTransparency = 0,
			Size = { X = 10, Y = 10},
			OutlineThickness = 1,
		}

		setmetatable(Box, {})
		Box.__index = Box

		--* Making drawing
		local Drawing = Instance.new('Frame', Drawing.cache)
		Drawing.AnchorPoint = Vector2.new(.5, .5)
		Drawing.Name = 'Box'
		
		local Outline = Instance.new('UIStroke', Drawing)
		Outline.Color = Box.Color
		Outline.Thickness = 1
		Outline.Enabled = false

		--* Threads
		local UpdateThread = RunService.Stepped:Connect(function()
			Drawing.Visible = Box.Visible
			Drawing.Size = UDim2.new(0, Box.Size.X, 0, Box.Size.Y)
			Drawing.Position = UDim2.new(0, Box.Position.X, 0, Box.Position.Y)
			Drawing.BackgroundColor3 = Box.Color
			
			Drawing.BorderColor3 = Box.OutlineColor
			Drawing.BorderSizePixel = Box.Outline and Box.OutlineThickness or 0
			Drawing.BackgroundTransparency = Box.Filled and Box.FillTransparency or not Box.Filled and 1
			Outline.Enabled = not Box.Filled
			Outline.Color = Box.Color
			Outline.Transparency = Box.OutlineTransparency
		end)
		
		--* Functions
		function Box:Remove()
			Drawing:Destroy()
			Outline:Destroy()
			UpdateThread:Disconnect()
			Box = nil
		end
		
		return Box
	end
	
	--* Circle
	if __type == 'Circle' then
		--* Metadata
		local Circle = {
			--* Vector
			Position = Vector2.new(0, 0),

			--* Color3
			Color = Color3.fromRGB(255, 255, 255),
			OutlineColor = Color3.fromRGB(0, 0, 0),

			--* Bool
			Visible = true,
			Filled = true,
			Outline = false,

			--* Number
			Radius = 5,
			Size = 10,
			Round = 1,
			OutlineThickness = 1,	
		}
		
		setmetatable(Circle, {})
		Circle.__index = Circle		
		
		--* Making drawing
		local Drawing = Instance.new('Frame', Drawing.cache)
		Drawing.AnchorPoint = Vector2.new(.5, .5)
		
		local Round = Instance.new('UICorner', Drawing)
		Round.CornerRadius = UDim.new(1, 0)

		local Outline = Instance.new('UIStroke', Drawing)
		Outline.Color = Circle.Color
		Outline.Thickness = 1
		Outline.Enabled = false

		--* Threads
		local UpdateThread = RunService.Stepped:Connect(function()
			Drawing.Visible = Circle.Visible
			Drawing.Size = UDim2.new(0, Circle.Radius * 2, 0, Circle.Radius * 2)
			Drawing.Position = UDim2.new(0, Circle.Position.X, 0, Circle.Position.Y)
			Drawing.BackgroundColor3 = Circle.Color
			Drawing.BorderColor3 = Circle.OutlineColor
			Drawing.BorderSizePixel = Circle.Outline and Circle.OutlineThickness or 0
			Drawing.BackgroundTransparency = Circle.Filled and 0 or not Circle.Filled and 1
			Outline.Enabled = not Circle.Filled
			Outline.Color = Circle.Color
			Round.CornerRadius = UDim.new(Circle.Round, 0)
		end)

		--* Functions
		function Circle:Remove()
			Drawing:Destroy()
			Outline:Destroy()
			UpdateThread:Disconnect()
			Circle = nil
		end

		return Circle
	end
	
	--* Line
	if __type == 'Line' then
		--* Metadata
		local Line = {
			Visible = true,
			Color = Color3.fromHSV(0, 0, 1),
			Outline = false,
			OutlineColor = Color3.fromHSV(0, 0, 0),
			Thickness = 1,
			OutlineThickness = 1,
			FillTransparency = 0,
			OutlineTransparency = 0,
			To = Vector2.new(0, 0),
			From = Vector2.new(0, 0),
		}
		
		setmetatable(Line, {})
		Line.__index = Line
		
		--* Make drawing
		local Drawing = Instance.new('Frame', Drawing.cache)
		Drawing.AnchorPoint = Vector2.new(.5, .5)
		
		--* Threads
		local UpdateThread = RunService.Stepped:Connect(function()
			local Central = (Line.From + Line.To) / 2
			local Offset = (Line.To - Line.From)
			
			Drawing.Position = UDim2.fromOffset(Central.X, Central.Y)
			Drawing.Rotation = math.atan2(Offset.Y, Offset.X) * 180 / math.pi
			Drawing.Size = UDim2.fromOffset(Offset.Magnitude, Line.Thickness)
			Drawing.Visible = Line.Visible
			
			Drawing.BorderSizePixel = Line.Outline and Line.OutlineThickness or 0
			Drawing.BackgroundColor3 = Line.Color
		end)

		--* Functions
		function Line:Remove()
			Drawing:Destroy()
			UpdateThread:Disconnect()
			Line = nil
		end
		
		return Line
	end
	
	if __type == 'Text' then
		--* Metadata
		local Text = {
			Visible = true,
			Text = 'Label',
			Color = Color3.fromHSV(0, 0, 1),
			OutlineColor = Color3.fromHSV(0, 0, 0),
			Size = { X = 100, Y = 25 },
			Position = { X = 0, Y = 0 },
			Outline = true,
			
			--* Custom
			FontFace = Font.new('rbxassetid://12187362578', Enum.FontWeight.Regular, Enum.FontStyle.Normal),
			OutlineTransparency = 0,
			Anchor = Vector2.new(.5, .5),
			TextSize = 18,
			Alignment = { X = 'Center', Y = 'Center' }
		}
		setmetatable(Text, {})
		Text.__index = Text
		
		--* Make drawing
		local Drawing = MakeInstance("TextLabel", { Parent = Drawing.cache, TextStrokeTransparency = 0, BorderSizePixel = 0, RichText = true, BackgroundColor3 = Color3.fromRGB(255, 255, 255), TextSize = 18, Size = UDim2.new(0, 100, 0, 25), BorderColor3 = Color3.fromRGB(0, 0, 0), FontFace = Font.new('rbxassetid://12187362578', Enum.FontWeight.Regular, Enum.FontStyle.Normal), TextColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 1,})
		
		--* Threads
		local UpdateThread = RunService.Stepped:Connect(function()
			Drawing.Text = Text.Text
			Drawing.FontFace = Text.FontFace
			Drawing.Visible = Text.Visible
			Drawing.TextColor3 = Text.Color
			Drawing.TextSize = Text.TextSize
			Drawing.AnchorPoint = Text.Anchor
			Drawing.TextStrokeColor3 = Text.OutlineColor
			Drawing.TextStrokeTransparency = Text.Outline and Text.OutlineTransparency or 1
			Drawing.TextXAlignment = Text.Alignment.X
			Drawing.TextYAlignment = Text.Alignment.Y
			
			Drawing.Size = UDim2.new(
				0, Text.Size.X, 
				0, Text.Size.Y
			)
			
			Drawing.Position = UDim2.new(
				0, Text.Position.X, 
				0, Text.Position.Y
			)
		end)
		
		--* Functions
		function Text:Remove()
			Drawing:Destroy()
			UpdateThread:Disconnect()
			Text = nil
		end
		
		return Text
	end
end

return Drawing
