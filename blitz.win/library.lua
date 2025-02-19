--@ doom.dtw | blitz.win | v1.1.0
--@ patch: 
--@ 	remade color picker
--@	added watermark
--@	fixed visual bugs

--@ dependancies
cloneref = cloneref or function(...) return ... end
local Services = setmetatable({}, {__index = function(self, name)
	local __service = cloneref(game:GetService(name))
	self[name] = __service
	return __service
end})

--@ library
blitz = {
	cache = Instance.new('Folder');
	pages = {};
	win = nil; 
	accent = Color3.fromRGB(255, 255, 255);

	--@ table overwrite function
	['overwrite'] = function(T1 : {}, T2 : {})
		for i, v in pairs(T2) do
			if type(v) == 'table' then
				T1[i] = blitz.overwrite(T1[i] or {}, v)
			else
				T1[i] = v
			end
		end

		return T1 or nil
	end;

	--@ random string function
	['randomize'] = function(MODE)
		local modes = {
			[1] = [[救效须介首助职例热毕节害击乱态嗯宝倒注宝]];
			[2] = [[чряхдилвмагзнчгойцно]];
			[3] = [[zxcvbnmasdfghjklqwer]];
			[4] = [[12345678901234567890]];
		}

		local characters = modes[MODE]
		local str = ''

		for i = 1, 99 do
			str = str .. characters:sub(
				math.random(1, #modes[MODE]), 
				math.random(1, #modes[MODE])
			)
		end

		return str
	end;

	--@ gui protection
	['safe_load'] = function(i : ScreenGui, ENCRYPT : boolean)
		if ENCRYPT then
			for _,__ in ipairs(i:GetDescendants()) do
				__.Name = blitz.randomize(math.random(1,4))
			end
		end

		local ElevationAllowed = pcall(function() local a = cloneref(game:GetService("CoreGui")):GetFullName() end)
		i.Parent = ElevationAllowed and Services.CoreGui or warn('blitz.win | COULD NOT LOAD - Elevation Failed')
	end;

	--@ instance creation
	['create'] = function(class : string, properties : {}, attributes : {} )
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
				return warn(`[{i}] Problem adding instance: {err}`) 
			end
		end

		if attributes then
			for attribute, value in attributes do
				i:SetAttribute(attribute, value)
			end
		end

		return i or nil
	end;

	--@ tweening
	['tween'] = function(instance : Instance, meta : {}, info : TweenInfo)
		Services.TweenService:Create(
			instance,
			info or TweenInfo.new(.25, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
			meta
		):Play()
	end;

	--@ input validation
	['check_input'] = function(InputType : EnumItem)
		if InputType == Enum.UserInputType.MouseMovement then return true end
		if InputType == Enum.UserInputType.MouseButton1 then return true end
		if InputType == Enum.UserInputType.Touch then return true end
	end
}

--@ init function
function blitz.init()
	if blitz.win then
		blitz.safe_load(blitz.win, true)
	end
end

function blitz.exit()
	if blitz.win then
		blitz.win:Destroy()
	end
end

function blitz.update(...)
	local NewData = ...
	
	if NewData.accent then
		for _, Page in blitz.pages do
			for _, Descendant in Page.Instance:GetDescendants() do
				if Descendant:GetAttribute('Accent') then
					pcall(function() blitz.tween(Descendant, { Color = NewData.accent }) end)
					pcall(function() blitz.tween(Descendant, { TextColor3 = NewData.accent }) end)
					pcall(function() blitz.tween(Descendant, { ImageColor3 = NewData.accent }) end)
					pcall(function() blitz.tween(Descendant, { BackgroundColor3 = NewData.accent }) end)
				end
			end
		end	
	end

	blitz.accent = NewData.accent
end

function blitz.watermark(text)
	--@ Metadata
	local Watermark = {
		Dragging = false;
		DragPos = nil;
		FramePos = nil;
		DeltaPos = nil;
		Hidden = false;
	}
	
	--@ Instances
	local WatermarkFrame = blitz.create("Frame", { Parent = blitz.win, Name = [[Watermark]], AutomaticSize = Enum.AutomaticSize.X, BorderSizePixel = 0, Size = UDim2.new(0, 0, 0, 30), BorderColor3 = Color3.fromRGB(0, 0, 0), Position = UDim2.new(0.0136208851, 0, 0.0207972266, 0), BackgroundColor3 = Color3.fromRGB(12, 12, 12),})
	local WatermarkLabel = blitz.create("TextLabel", { Parent = WatermarkFrame, RichText = true, BorderSizePixel = 0, BackgroundColor3 = Color3.fromRGB(255, 255, 255), AnchorPoint = Vector2.new(0.5, 0.5), TextSize = 18, Size = UDim2.new(0, 423, 0, 14), BorderColor3 = Color3.fromRGB(0, 0, 0), FontFace = Font.new('rbxassetid://12187607287', Enum.FontWeight.Regular, Enum.FontStyle.Normal), Position = UDim2.new(0.501184821, 0, 0.5, 0), TextColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 1,})
	blitz.create("UIListLayout", { Parent = WatermarkFrame, VerticalAlignment = Enum.VerticalAlignment.Center, FillDirection = Enum.FillDirection.Horizontal, SortOrder = Enum.SortOrder.LayoutOrder, HorizontalAlignment = Enum.HorizontalAlignment.Center,})
	blitz.create("UICorner", { Parent = WatermarkFrame, CornerRadius = UDim.new(0, 6),})

	WatermarkLabel.Text = text
	WatermarkLabel:GetPropertyChangedSignal('TextBounds'):Wait()
	
	WatermarkLabel.Size = UDim2.fromOffset(WatermarkLabel.TextBounds.X + 20, 30)	
	
	--@ Functions + Connections
	function Watermark:Edit(new_text)
		WatermarkLabel.Text = new_text
		WatermarkLabel:GetPropertyChangedSignal('TextBounds'):Wait()

		WatermarkLabel.Size = UDim2.fromOffset(WatermarkLabel.TextBounds.X + 20, 30)	
	end
	
	function Watermark:Toggle(v)
		WatermarkFrame.Visible = v
	end
	
	function Watermark:Destroy()
		WatermarkFrame:Destroy()
	end
	
	--@ Functions + Connections
	Services.UserInputService.InputBegan:Connect(function(Input)
		local InputType = Input.UserInputType

		if blitz.check_input(InputType) and WatermarkFrame.GuiState == Enum.GuiState.Press then
			Watermark.DragPos = Input.Position
			Watermark.FramePos = WatermarkFrame.Position
			Watermark.Dragging = true
		end

		-- >> Input Ended
		Input.Changed:Connect(function(InputType)
			local InputState = Input.UserInputState

			if InputState == Enum.UserInputState.End and Input.UserInputType ~= Enum.UserInputType.Keyboard then
				Watermark.Dragging = false
			end
		end)
	end)

	Services.UserInputService.InputChanged:Connect(function(Input)
		local InputType = Input.UserInputType

		if blitz.check_input(InputType) then
			if Watermark.Dragging then
				Watermark.DeltaPos = Input.Position - Watermark.DragPos

				WatermarkFrame.Position = UDim2.new(
					Watermark.FramePos.X.Scale, Watermark.FramePos.X.Offset + Watermark.DeltaPos.X,
					Watermark.FramePos.Y.Scale, Watermark.FramePos.Y.Offset + Watermark.DeltaPos.Y
				)
			end
		end
	end)
	
	return Watermark
end

--@ window function
function blitz.new(name, ...)
	--@ Metadata
	local Window = blitz.overwrite({
		--@ Window Meta
		Size = UDim2.new(0, 863, 0, 550);
		Pos = UDim2.new(0.0646853149, 0, 0.466204494, 0);
		ToggleKey = nil;

		--@ Don't tamper
		Instance = nil;
		Dragging = false;
		DragPos = nil;
		FramePos = nil;
		DeltaPos = nil;
		Hidden = false;
		Tabs = {}
	}, ... or {})

	--@ Instances
	local WindowFrame = blitz.create("Frame", { Parent = nil, Name = [[WindowFrame]], BorderSizePixel = 0, Size = Window.Size, BorderColor3 = Color3.fromRGB(0, 0, 0), Position = Window.Pos, BackgroundColor3 = Color3.fromRGB(12, 12, 12),})
	local SidebarFrame = blitz.create("Frame", { Parent = WindowFrame, Name = [[SidebarFrame]], BorderSizePixel = 0, Size = UDim2.new(0, 250, 0, 550), BorderColor3 = Color3.fromRGB(0, 0, 0), BackgroundTransparency = 1, BackgroundColor3 = Color3.fromRGB(12, 12, 12),})
	local TitleCardFrame = blitz.create("Frame", { Parent = SidebarFrame, Name = [[TitleCardFrame]], BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 80), ClipsDescendants = true, BorderColor3 = Color3.fromRGB(0, 0, 0), BackgroundTransparency = 1, BackgroundColor3 = Color3.fromRGB(255, 255, 255),})
	local LargeTextLabel = blitz.create("TextLabel", { Parent = TitleCardFrame, Name = [[LargeTextLabel]], Visible = false, BorderSizePixel = 0, BackgroundColor3 = Color3.fromRGB(255, 255, 255), AnchorPoint = Vector2.new(0.5, 0.5), TextSize = 26, Size = UDim2.new(0, 200, 0, 50), BorderColor3 = Color3.fromRGB(0, 0, 0), Text = [[blitz.win]], FontFace = Font.new('rbxassetid://12187607287', Enum.FontWeight.Regular, Enum.FontStyle.Normal), Position = UDim2.new(0.5, 0, 0.5, 0), TextColor3 = Color3.fromRGB(175, 175, 175), BackgroundTransparency = 1,})
	local LibraryNameLabel = blitz.create("TextLabel", { Parent = TitleCardFrame, Name = [[LibraryNameLabel]], BorderSizePixel = 0, BackgroundColor3 = Color3.fromRGB(255, 255, 255), AnchorPoint = Vector2.new(0.5, 0), TextSize = 26, Size = UDim2.new(0, 106, 0, 14), TextXAlignment = Enum.TextXAlignment.Left, BorderColor3 = Color3.fromRGB(0, 0, 0), Text = name, FontFace = Font.new('rbxassetid://12187607287', Enum.FontWeight.Medium, Enum.FontStyle.Normal), Position = UDim2.new(0.481999993, 0, 0.0250000004, 24), TextColor3 = blitz.accent, BackgroundTransparency = 1,}, { ["Accent"] = true })
	local UserNameLabel = blitz.create("TextLabel", { Parent = TitleCardFrame, Name = [[UserNameLabel]], BorderSizePixel = 0, BackgroundColor3 = Color3.fromRGB(255, 255, 255), AnchorPoint = Vector2.new(0.5, 0), TextSize = 20, Size = UDim2.new(0, 163, 0, 10), TextXAlignment = Enum.TextXAlignment.Left, BorderColor3 = Color3.fromRGB(0, 0, 0), Text = Services.Players.LocalPlayer.DisplayName, TextTransparency = 0.75, FontFace = Font.new('rbxassetid://12187607287', Enum.FontWeight.Regular, Enum.FontStyle.Normal), Position = UDim2.new(0.592999995, 0, -0.0250000004, 46), TextColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 1,})
	local ProfileIcon = blitz.create("ImageLabel", { Parent = TitleCardFrame, Name = [[ProfileIcon]], AnchorPoint = Vector2.new(0, 0.5), Image = `rbxthumb://type=AvatarHeadShot&id={Services.Players.LocalPlayer.UserId}&w=420&h=420`, BorderSizePixel = 0, Size = UDim2.new(0, 32, 0, 32), BorderColor3 = Color3.fromRGB(0, 0, 0), Position = UDim2.new(-0, 24, 0.5, 0), BackgroundColor3 = Color3.fromRGB(32, 32, 32),})
	local UICorner = blitz.create("UICorner", { Parent = ProfileIcon,})
	local UIStroke = blitz.create("UIStroke", { Parent = ProfileIcon, Color = blitz.accent,}, {["Accent"] = true })
	local UIGradient = blitz.create("UIGradient", { Parent = UIStroke, Enabled = false, Rotation = -125, Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.fromRGB(52.000000700354576, 52.000000700354576, 52.000000700354576)); ColorSequenceKeypoint.new(0.30103808641433716, Color3.fromRGB(55.00000052154064, 53.00000064074993, 56.000000461936)); ColorSequenceKeypoint.new(1, Color3.fromRGB(177.0000046491623, 144.00000661611557, 255));}),})
	local UIGradient2 = blitz.create("UIGradient", { Parent = UIStroke, Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1, 0); NumberSequenceKeypoint.new(0.35286784172058105, 0.856249988079071, 0); NumberSequenceKeypoint.new(0.6583541631698608, 0.606249988079071, 0); NumberSequenceKeypoint.new(1, 0, 0);}), Rotation = -125,})
	local SettingsButton = blitz.create("ImageButton", { Parent = TitleCardFrame, Name = [[SettingsButton]], Visible = false, BackgroundTransparency = 1, Image = [[http://www.roblox.com/asset/?id=6031280882]], BorderSizePixel = 0, Size = UDim2.new(0, 16, 0, 16), BorderColor3 = Color3.fromRGB(0, 0, 0), ImageColor3 = Color3.fromRGB(75, 75, 75), Position = UDim2.new(0.812777758, 0, 0.419375002, 0), BackgroundColor3 = Color3.fromRGB(255, 255, 255),})
	local Ambience = blitz.create("Frame", { Parent = TitleCardFrame, Name = [[Ambience]], BorderSizePixel = 0, Size = UDim2.new(0, 251, 0, 118), BorderColor3 = Color3.fromRGB(0, 0, 0), BackgroundTransparency = 0.8999999761581421, BackgroundColor3 = blitz.accent,}, { ["Accent"] = true })
	local BigProfileIcon = blitz.create("ImageLabel", { Parent = TitleCardFrame, Name = [[BigProfileIcon]], Image = `rbxthumb://type=AvatarHeadShot&id={Services.Players.LocalPlayer.UserId}&w=420&h=420`, ZIndex = 0, BorderSizePixel = 0, Size = UDim2.new(0, 190, 0, 190), BorderColor3 = Color3.fromRGB(0, 0, 0), ImageTransparency = 0.5, Position = UDim2.new(-0.108000003, 0, -1, 0), BackgroundTransparency = 1, BackgroundColor3 = Color3.fromRGB(255, 255, 255),})
	local SideButtonsFrame = blitz.create("Frame", { Parent = SidebarFrame, Name = [[SideButtonsFrame]], BorderSizePixel = 0, Size = UDim2.new(1, 0, 1, -100), BorderColor3 = Color3.fromRGB(0, 0, 0), LayoutOrder = 3, Position = UDim2.new(0, 0, 0.200000003, 0), BackgroundTransparency = 1, BackgroundColor3 = Color3.fromRGB(255, 255, 255),})
	local SideDividerFrame = blitz.create("Frame", { Parent = SidebarFrame, Name = [[SideDividerFrame]], BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 1), BorderColor3 = Color3.fromRGB(0, 0, 0), LayoutOrder = 2, BackgroundColor3 = Color3.fromRGB(32, 32, 32),})
	local GradientFrame = blitz.create("Frame", { Parent = WindowFrame, Name = [[GradientFrame]], ZIndex = 999; AnchorPoint = Vector2.new(1, 1), BorderSizePixel = 0, Size = UDim2.new(1, -251, -0.218181819, 200), BorderColor3 = Color3.fromRGB(0, 0, 0), Position = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.fromRGB(12, 12, 12),})
	local DividerFrame = blitz.create("Frame", { Parent = WindowFrame, Name = [[DividerFrame]], BorderSizePixel = 0, Size = UDim2.new(0, 1, 1, 0), BorderColor3 = Color3.fromRGB(0, 0, 0), Position = UDim2.new(0, 250, 0, 0), BackgroundTransparency = 0.5, BackgroundColor3 = Color3.fromRGB(32, 32, 32),})
	blitz.create("UIGradient", { Parent = BigProfileIcon, Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0, 0); NumberSequenceKeypoint.new(0.5922693610191345, 0.856249988079071, 0); NumberSequenceKeypoint.new(0.7768080234527588, 1, 0); NumberSequenceKeypoint.new(1, 1, 0);}), Rotation = 75, Offset = Vector2.new(0, 0.150000006),})
	blitz.create("UIListLayout", { Parent = SideButtonsFrame, Padding = UDim.new(0, 15), SortOrder = Enum.SortOrder.LayoutOrder, HorizontalAlignment = Enum.HorizontalAlignment.Center,})
	blitz.create("UIPadding", { Parent = SideButtonsFrame, PaddingTop = UDim.new(0, 20),})
	blitz.create("UIGradient", { Parent = LibraryNameLabel,})
	blitz.create("UIGradient", { Parent = Ambience, Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0, 0); NumberSequenceKeypoint.new(0.6533666253089905, 1, 0); NumberSequenceKeypoint.new(1, 1, 0);}), Rotation = 66,})
	blitz.create("UICorner", { Parent = Ambience, CornerRadius = UDim.new(0, 11),})
	blitz.create("UICorner", { Parent = ProfileIcon,})
	blitz.create("UIGradient", { Parent = SideDividerFrame, Enabled = false, Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1, 0); NumberSequenceKeypoint.new(0.5, 0, 0); NumberSequenceKeypoint.new(1, 1, 0);}),})
	blitz.create("UIListLayout", { Parent = SidebarFrame, SortOrder = Enum.SortOrder.LayoutOrder,})
	blitz.create("UICorner", { Parent = WindowFrame, CornerRadius = UDim.new(0, 12),})
	blitz.create("UICorner", { Parent = GradientFrame, CornerRadius = UDim.new(0, 12),})
	blitz.create("UIGradient", { Parent = GradientFrame, Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1, 0); NumberSequenceKeypoint.new(1, 0, 0);}), Rotation = 90,})
	blitz.create("UIGradient", { Parent = DividerFrame, Enabled = false, Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1, 0); NumberSequenceKeypoint.new(0.5, 0, 0); NumberSequenceKeypoint.new(1, 1, 0);}), Rotation = 90,})

	--@ if ui doesn't exist, create
	if not blitz.win then
		blitz.win = blitz.create("ScreenGui", {
			Parent = nil,
			Name = [[blitz.win]],
			ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		})

		--@ load window into ui
		WindowFrame.Parent = blitz.win
		Window.Instance = WindowFrame
		blitz.pages[name] = Window
	end

	--@ Functions + Connections
	Services.UserInputService.InputBegan:Connect(function(Input)
		local InputType = Input.UserInputType

		if Input.KeyCode == Window.ToggleKey then
			if not Services.UserInputService:GetFocusedTextBox() then
				Window.Hidden = not Window.Hidden
				WindowFrame.Visible = Window.Hidden
			end
		end

		if blitz.check_input(InputType) and WindowFrame.GuiState == Enum.GuiState.Press then
			Window.DragPos = Input.Position
			Window.FramePos = WindowFrame.Position
			Window.Dragging = true
		end

		-- >> Input Ended
		Input.Changed:Connect(function(InputType)
			local InputState = Input.UserInputState

			if InputState == Enum.UserInputState.End and Input.UserInputType ~= Enum.UserInputType.Keyboard then
				Window.Dragging = false
			end
		end)
	end)

	Services.UserInputService.InputChanged:Connect(function(Input)
		local InputType = Input.UserInputType

		if blitz.check_input(InputType) then
			if Window.Dragging then
				Window.DeltaPos = Input.Position - Window.DragPos

				WindowFrame.Position = UDim2.new(
					Window.FramePos.X.Scale, Window.FramePos.X.Offset + Window.DeltaPos.X,
					Window.FramePos.Y.Scale, Window.FramePos.Y.Offset + Window.DeltaPos.Y
				)
			end
		end
	end)

	--@ tab creation
	function Window:NewTab(Name, Icon)
		--@ metadata
		local Tab = {}

		--@ instances
		local TabFrame = blitz.create("ScrollingFrame", { Visible = false; Parent = WindowFrame, Name = [[ContentFrame]], Active = true, BorderSizePixel = 0, BackgroundColor3 = Color3.fromRGB(255, 255, 255), AnchorPoint = Vector2.new(1, 0), Size = UDim2.new(1, -251, 1, 0), ScrollBarImageColor3 = Color3.fromRGB(83, 83, 83), BorderColor3 = Color3.fromRGB(0, 0, 0), ScrollBarThickness = 0, Position = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1,})
		local SearchBar = blitz.create("Frame", { Parent = TabFrame, Name = [[SearchBar]], BorderSizePixel = 0, Size = UDim2.new(0, 568, 0, 20), BorderColor3 = Color3.fromRGB(0, 0, 0), BackgroundTransparency = 1, BackgroundColor3 = Color3.fromRGB(255, 255, 255),})
		local SearchIcon = blitz.create("ImageLabel", { Parent = SearchBar, Image = [[http://www.roblox.com/asset/?id=6031154871]], BorderSizePixel = 0, Size = UDim2.new(1, 0, 1, 0), BorderColor3 = Color3.fromRGB(0, 0, 0), ImageColor3 = Color3.fromRGB(175, 175, 175), BackgroundTransparency = 1, BackgroundColor3 = Color3.fromRGB(255, 255, 255),})
		local SearchInput = blitz.create("TextBox", { Parent = SearchBar, CursorPosition = -1, PlaceholderColor3 = Color3.fromRGB(125, 125, 125), BorderSizePixel = 0, BackgroundColor3 = Color3.fromRGB(255, 255, 255), TextXAlignment = Enum.TextXAlignment.Left, PlaceholderText = [[Search Prompt...]], TextSize = 20, Size = UDim2.new(1, -30, 1, 0), TextColor3 = Color3.fromRGB(175, 175, 175), BorderColor3 = Color3.fromRGB(0, 0, 0), Text = [[]], FontFace = Font.new('rbxassetid://12187607287', Enum.FontWeight.Regular, Enum.FontStyle.Normal), Position = UDim2.new(0.0510562845, 0, 0, 0), BackgroundTransparency = 1,})
		local G1 = blitz.create("ScrollingFrame", { Parent = TabFrame, Name = [[G1]], Active = true, BorderSizePixel = 0, CanvasSize = UDim2.new(0, 0, 0, 0), BackgroundColor3 = Color3.fromRGB(255, 255, 255), AnchorPoint = Vector2.new(0, 1), Size = UDim2.new(0.5, -10, 1, -30), ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0), LayoutOrder = 1, AutomaticCanvasSize = Enum.AutomaticSize.Y, BorderColor3 = Color3.fromRGB(0, 0, 0), ScrollBarThickness = 0, Position = UDim2.new(0, 0, 1, 0), BackgroundTransparency = 1,})
		local G2 = blitz.create("ScrollingFrame", { Parent = TabFrame, Name = [[G2]], Active = true, BorderSizePixel = 0, CanvasSize = UDim2.new(0, 0, 0, 0), BackgroundColor3 = Color3.fromRGB(255, 255, 255), AnchorPoint = Vector2.new(1, 1), Size = UDim2.new(0.5, -10, 1, -30), ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0), LayoutOrder = 2, AutomaticCanvasSize = Enum.AutomaticSize.Y, BorderColor3 = Color3.fromRGB(0, 0, 0), ScrollBarThickness = 0, Position = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,})
		blitz.create("UIPadding", { Parent = TabFrame, PaddingTop = UDim.new(0, 20), PaddingRight = UDim.new(0, 20), PaddingLeft = UDim.new(0, 20),})
		blitz.create("UIPadding", { Parent = G1, PaddingTop = UDim.new(0, 2), PaddingLeft = UDim.new(0, 2),})
		blitz.create("UIPadding", { Parent = G2, PaddingTop = UDim.new(0, 2), PaddingLeft = UDim.new(0, 2),})
		blitz.create("UIListLayout", { Parent = G1, Padding = UDim.new(0, 20), SortOrder = Enum.SortOrder.LayoutOrder,})
		blitz.create("UIListLayout", { Parent = G2, Padding = UDim.new(0, 20), SortOrder = Enum.SortOrder.LayoutOrder,})
		blitz.create("UIAspectRatioConstraint", { Parent = SearchIcon,})
		blitz.create("UIListLayout", { Parent = SearchBar, FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder,})

		local TabButton = blitz.create("TextButton", { Parent = SideButtonsFrame, Name = [[TabButton]], BorderSizePixel = 0, BackgroundColor3 = Color3.fromRGB(255, 255, 255), TextSize = 20, Size = UDim2.new(1, -40, 0, 36), BorderColor3 = Color3.fromRGB(0, 0, 0), Text = Name, TextTransparency = 1, FontFace = Font.new('rbxassetid://12187607287', Enum.FontWeight.Regular, Enum.FontStyle.Normal), TextColor3 = Color3.fromRGB(125, 125, 125), BackgroundTransparency = 1,})
		local ButtonIcon = blitz.create("ImageLabel", { Parent = TabButton, AnchorPoint = Vector2.new(0, 0.5), Image = Icon or nil, BorderSizePixel = 0, Size = UDim2.new(0, 18, 0, 18), BorderColor3 = Color3.fromRGB(0, 0, 0), ImageColor3 = Color3.fromRGB(125, 125, 125), Position = UDim2.new(0, 20, 0.5, 0), BackgroundTransparency = 1, BackgroundColor3 = Color3.fromRGB(255, 255, 255),})
		local ButtonText = blitz.create("TextLabel", { Parent = TabButton, TextWrapped = true, BorderSizePixel = 0, BackgroundColor3 = Color3.fromRGB(255, 255, 255), TextSize = 20, Size = UDim2.new(0, 100, 1, 0), TextXAlignment = Enum.TextXAlignment.Left, BorderColor3 = Color3.fromRGB(0, 0, 0), Text = Name, FontFace = Font.new('rbxassetid://12187607287', Enum.FontWeight.Regular, Enum.FontStyle.Normal), Position = UDim2.new(0, 50, 0, 0), TextColor3 = Color3.fromRGB(125, 125, 125), BackgroundTransparency = 1,}, { ["Accent"] = false })
		local ButtonStroke = blitz.create("UIStroke", { Parent = TabButton, Name = [[ButtonStroke]], ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Transparency = 1, Color = blitz.accent,}, { ["Accent"] = true })
		local ButtonAmbience = blitz.create("Frame", { Parent = TabButton, Name = [[ButtonAmbience]], ZIndex = 0, BorderSizePixel = 0, Size = UDim2.new(1, 0, 1, 0), BorderColor3 = Color3.fromRGB(0, 0, 0), BackgroundTransparency = 1, BackgroundColor3 = blitz.accent,}, { ["Accent"] = true })
		blitz.create("UICorner", { Parent = ButtonAmbience, CornerRadius = UDim.new(0, 4),})
		blitz.create("UIGradient", { Parent = ButtonAmbience, Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.824999988079071, 0); NumberSequenceKeypoint.new(0.5, 0.6437499523162842, 0); NumberSequenceKeypoint.new(1, 0.41874998807907104, 0);}), Rotation = 15,})
		blitz.create("UICorner", { Parent = TabButton, CornerRadius = UDim.new(0, 4),})

		if not Icon then
			ButtonText.Position = UDim2.new(0, 20, 0, 0)
		end

		--@ search function
		--@ search function
		SearchInput.Changed:Connect(function()
			--@ filter sections
			for _, Section in G1:GetChildren() do
				if Section:IsA('Frame') then
					--@ filter elements
					for _, Element in Section:FindFirstChildOfClass('Frame'):GetChildren() do
						if Element:IsA('Frame') then
							Element.Visible = false

							for _, Label in Element:GetChildren() do
								if Label:IsA('TextLabel') or Label:IsA('TextBox') then
									if Label.Text:match(SearchInput.Text) then
										Element.Visible = true
									end
								end
							end
						end
					end
				end
			end

			--@ filter sections
			for _, Section in G2:GetChildren() do
				if Section:IsA('Frame') then
					--@ filter elements
					for _, Element in Section:FindFirstChildOfClass('Frame'):GetChildren() do
						if Element:IsA('Frame') then
							Element.Visible = false

							for _, Label in Element:GetChildren() do
								if Label:IsA('TextLabel') or Label:IsA('TextBox') then
									if Label.Text:match(SearchInput.Text) then
										Element.Visible = true
									end
								end
							end
						end
					end
				end
			end
		end)

		TabButton.MouseButton1Click:Connect(function()
			for _, Page in Window.Tabs do
				Page.Frame.Visible = false
				Page.Frame.Size = UDim2.new(1,-251, 0, 0)

				--@ tweening
				blitz.tween(Page.Button:FindFirstChildOfClass('TextLabel'), { TextColor3 = Color3.fromRGB(125, 125, 125) })
				blitz.tween(Page.Button:FindFirstChildOfClass('ImageLabel'), { ImageColor3 = Color3.fromRGB(125, 125, 125) })
				blitz.tween(Page.Button:FindFirstChildOfClass('UIStroke'), { Transparency = 1 })
				blitz.tween(Page.Button:FindFirstChildOfClass('Frame'), { BackgroundTransparency = 1 })
				
				Page.Button:SetAttribute('Accent', false)
				Page.Button:FindFirstChildOfClass('TextLabel'):SetAttribute('Accent', false)
				Page.Button:FindFirstChildOfClass('ImageLabel'):SetAttribute('Accent', false)
			end

			TabFrame.Visible = true
			
			--@ attributes
			TabButton:SetAttribute('Accent', true)
			ButtonText:SetAttribute('Accent', true)
			ButtonIcon:SetAttribute('Accent', true)

			--@ tweening
			blitz.tween(TabFrame, { Size = UDim2.new(1, -251, 1, 0) })
			blitz.tween(ButtonText, { TextColor3 = blitz.accent })
			blitz.tween(TabButton:FindFirstChildOfClass('ImageLabel'), { ImageColor3 = blitz.accent })
			blitz.tween(ButtonStroke, { Transparency = 0  })
			blitz.tween(ButtonAmbience,{ BackgroundTransparency = .75 })
		end)

		--@ section creation
		function Tab:NewSection(Name, Side, Icon)
			--@ Metadata
			local Section = {}

			--@ Instance Creation
			local SectionFrame = blitz.create("Frame", { AutomaticSize = Enum.AutomaticSize.Y, Parent = nil, Name = [[SectionFrame]], BorderSizePixel = 0, Size = UDim2.new(1, -4, 0, 30), BorderColor3 = Color3.fromRGB(0, 0, 0), BackgroundTransparency = 1, BackgroundColor3 = Color3.fromRGB(255, 255, 255),})
			local TopbarFrame = blitz.create("ImageLabel", { LayoutOrder = 1, Parent = SectionFrame, Name = [[TopbarFrame]], BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 30), BorderColor3 = Color3.fromRGB(0, 0, 0), BackgroundColor3 = Color3.fromRGB(24, 24, 24),})
			local Filler = blitz.create("Frame", { Parent = TopbarFrame, Name = [[Filler]], AnchorPoint = Vector2.new(0, 1), BorderSizePixel = 0, Size = UDim2.new(1, 0, 0.5, 0), BorderColor3 = Color3.fromRGB(0, 0, 0), Position = UDim2.new(0, 0, 1, 0), BackgroundColor3 = Color3.fromRGB(24, 24, 24),})
			local SectionTitle = blitz.create("TextLabel", { Parent = TopbarFrame, Name = [[SectionTitle]], BorderSizePixel = 0, BackgroundColor3 = Color3.fromRGB(255, 255, 255), AnchorPoint = Vector2.new(0.5, 0.5), TextSize = 20, Size = UDim2.new(1, 0, 1, 0), TextXAlignment = Enum.TextXAlignment.Left, BorderColor3 = Color3.fromRGB(0, 0, 0), Text = Name, FontFace = Font.new('rbxassetid://12187607287', Enum.FontWeight.Regular, Enum.FontStyle.Normal), Position = UDim2.new(0.5, 0, 0.5, 0), TextColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 1,})
			local SectionIcon = blitz.create("ImageLabel", { Parent = TopbarFrame, Name = [[SectionIcon]], AnchorPoint = Vector2.new(1, 0.5), Image = Icon, BorderSizePixel = 0, Size = UDim2.new(0, 18, 0, 18), BorderColor3 = Color3.fromRGB(0, 0, 0), ImageTransparency = 0.5, Position = UDim2.new(1, -6, 0.5, 0), BackgroundTransparency = 1, BackgroundColor3 = Color3.fromRGB(255, 255, 255),})
			local SectionContent = blitz.create("Frame", { ZIndex = 999; LayoutOrder = 2, AutomaticSize = Enum.AutomaticSize.Y, Parent = SectionFrame, Name = [[SectionContent]], AnchorPoint = Vector2.new(0, 1), BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 0), BorderColor3 = Color3.fromRGB(0, 0, 0), Position = UDim2.new(0, 0, 1, 0), BackgroundTransparency = 1, BackgroundColor3 = Color3.fromRGB(255, 255, 255),})
			blitz.create("UIPadding", { Parent = SectionTitle, PaddingLeft = UDim.new(0, 10),})
			blitz.create("UICorner", { Parent = SectionFrame,})
			blitz.create("UIStroke", { Parent = SectionFrame, Thickness = 1.5, Color = Color3.fromRGB(24, 24, 24),})
			blitz.create("UICorner", { Parent = TopbarFrame,})
			blitz.create("UIListLayout", { Parent = SectionContent, SortOrder = Enum.SortOrder.LayoutOrder, HorizontalAlignment = Enum.HorizontalAlignment.Center,})
			blitz.create("UIPadding", { Parent = SectionContent, PaddingTop = UDim.new(0, 4), PaddingRight = UDim.new(0, 10), PaddingLeft = UDim.new(0, 14), PaddingBottom = UDim.new(0, 4),})
			blitz.create("UIListLayout", { Parent = SectionFrame, SortOrder = Enum.SortOrder.LayoutOrder,})

			if Side == 'Left' then SectionFrame.Parent = G1 end
			if Side == 'Right' then SectionFrame.Parent = G2 end

			if not Icon then SectionIcon.Visible = false end

			--@ label
			function Section:NewLabel(...)
				--@ Metadata
				local Meta = blitz.overwrite({
					Text = 'Text Field';
					SecondaryText = nil;
					Prefix = '';
					Suffix = '';
				}, ... or {})

				--@ Instance Creation
				local ElementFrame = blitz.create("Frame", { Parent = SectionContent, Name = [[ElementFrame]], BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 36), BorderColor3 = Color3.fromRGB(0, 0, 0), BackgroundTransparency = 1, BackgroundColor3 = Color3.fromRGB(255, 255, 255),})
				local ElementTitle = blitz.create("TextBox", { Parent = ElementFrame, PlaceholderColor3 = Color3.fromRGB(178, 178, 178), BorderSizePixel = 0, TextEditable = false, BackgroundColor3 = Color3.fromRGB(255, 255, 255), AnchorPoint = Vector2.new(0.5, 0.5), TextXAlignment = Enum.TextXAlignment.Left, TextSize = 20, Size = UDim2.new(1, 0, 1, 0), TextColor3 = Color3.fromRGB(175, 175, 175), BorderColor3 = Color3.fromRGB(0, 0, 0), Text = Meta.Text, FontFace = Font.new('rbxassetid://12187607287', Enum.FontWeight.Regular, Enum.FontStyle.Normal), Position = UDim2.new(0.5, 0, 0.5, 0), ClearTextOnFocus = false, BackgroundTransparency = 1,})

				--@ Functions + Connections
				ElementFrame.MouseEnter:Connect(function()
					if Meta.SecondaryText then
						ElementTitle.Text = Meta.SecondaryText 
					end
				end)

				ElementFrame.MouseLeave:Connect(function()
					if Meta.SecondaryText then
						ElementTitle.Text = Meta.Text 
					end
				end)

				function Meta:Update(NewValue)
					Meta.Text = string.format(`%s%s%s`, Meta.Prefix, NewValue, Meta.Suffix)
					ElementTitle.Text = Meta.Text
				end

				return Meta
			end

			--@ button
			function Section:NewButton(...)
				--@ Metadata
				local Meta = blitz.overwrite({
					Text = 'TextButton';
					SecondaryText = nil;
					ButtonText = 'Button';
					OnPress = function() end;
					OnRelease = function() end;
					OnClick = function() end;
				}, ... or {})

				--@ Instance Creation
				local ElementFrame = blitz.create("Frame", { Parent = SectionContent, Name = [[ElementFrame]], BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 36), BorderColor3 = Color3.fromRGB(0, 0, 0), BackgroundTransparency = 1, BackgroundColor3 = Color3.fromRGB(255, 255, 255),})
				local ElementTitle = blitz.create("TextLabel", { Parent = ElementFrame, Name = [[ElementTitle]], BorderSizePixel = 0, BackgroundColor3 = Color3.fromRGB(255, 255, 255), AnchorPoint = Vector2.new(0.5, 0), TextSize = 20, Size = UDim2.new(1, 0, 0, 14), TextXAlignment = Enum.TextXAlignment.Left, BorderColor3 = Color3.fromRGB(0, 0, 0), Text = Meta.Text, FontFace = Font.new('rbxassetid://12187607287', Enum.FontWeight.Regular, Enum.FontStyle.Normal), Position = UDim2.new(0.5, 0, 0.360000014, 0), TextColor3 = Color3.fromRGB(175, 175, 175), BackgroundTransparency = 1,})
				local ElementButton = blitz.create("TextButton", { Parent = ElementFrame, Name = [[ElementButton]], Text = Meta.ButtonText; BorderSizePixel = 0, AutoButtonColor = false, BackgroundColor3 = Color3.fromRGB(32, 32, 32), AnchorPoint = Vector2.new(1, 0.5), TextSize = 16, Size = UDim2.new(0, 100, 0, 24), BorderColor3 = Color3.fromRGB(0, 0, 0), FontFace = Font.new('rbxassetid://12187607287', Enum.FontWeight.Regular, Enum.FontStyle.Normal), Position = UDim2.new(1, 0, 0.5, 0), TextColor3 = Color3.fromRGB(175, 175, 175),})
				local ElementDescription = blitz.create("TextLabel", { Parent = ElementFrame, Name = [[ElementDescription]], Visible = false, BorderSizePixel = 0, BackgroundColor3 = Color3.fromRGB(255, 255, 255), AnchorPoint = Vector2.new(0.5, 1), TextSize = 16, Size = UDim2.new(1, 0, 0, 12), TextXAlignment = Enum.TextXAlignment.Left, BorderColor3 = Color3.fromRGB(0, 0, 0), Text = [[Toggle Description]], FontFace = Font.new('rbxassetid://12187607287', Enum.FontWeight.Regular, Enum.FontStyle.Normal), Position = UDim2.new(0.5, 0, 0.779999971, 0), TextColor3 = Color3.fromRGB(100, 100, 100), BackgroundTransparency = 1,})
				blitz.create("UICorner", { Parent = ElementButton, CornerRadius = UDim.new(0.150000006, 0),})
				blitz.create("UIPadding", { Parent = ElementButton, PaddingRight = UDim.new(0, 4), PaddingLeft = UDim.new(0, 4),})

				--@ Functions + Connections
				ElementFrame.MouseEnter:Connect(function()
					if Meta.SecondaryText then
						ElementTitle.Text = Meta.SecondaryText 
					end
				end)

				ElementFrame.MouseLeave:Connect(function()
					if Meta.SecondaryText then
						ElementTitle.Text = Meta.Text 
					end
				end)

				ElementButton.MouseEnter:Connect(function()
					blitz.tween(ElementButton, {BackgroundColor3 = Color3.fromRGB(42,42,42)})
				end)

				ElementButton.MouseLeave:Connect(function()
					blitz.tween(ElementButton, {BackgroundColor3 = Color3.fromRGB(32,32,32)})
				end)

				ElementButton.MouseButton1Down:Connect(function()
					blitz.tween(ElementButton, {BackgroundColor3 = Color3.fromRGB(52,52,52)})
					Meta.OnPress()
				end)

				ElementButton.MouseButton1Up:Connect(function()
					blitz.tween(ElementButton, {BackgroundColor3 = Color3.fromRGB(32,32,32)})
					Meta.OnRelease()
				end)

				ElementButton.MouseButton1Click:Connect(Meta.OnClick)

				return Meta
			end

			--@ toggle
			function Section:NewToggle(...)
				--@ Metadata
				local Meta = blitz.overwrite({
					Text = 'Toggle';
					Value = false;
					SecondaryText = nil;
					OnToggle = function(...) end;
				}, ... or {})

				--@ Instance Creation
				local ElementFrame = blitz.create("Frame", { Parent = SectionContent, Name = [[ElementFrame]], BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 36), BorderColor3 = Color3.fromRGB(0, 0, 0), BackgroundTransparency = 1, BackgroundColor3 = Color3.fromRGB(255, 255, 255),})
				local ElementTitle = blitz.create("TextLabel", { Parent = ElementFrame, Name = [[ElementText]], BorderSizePixel = 0, BackgroundColor3 = Color3.fromRGB(255, 255, 255), AnchorPoint = Vector2.new(0, 0.5), TextSize = 20, Size = UDim2.new(1, 0, 1, 0), TextXAlignment = Enum.TextXAlignment.Left, BorderColor3 = Color3.fromRGB(0, 0, 0), Text = Meta.Text, FontFace = Font.new('rbxassetid://12187607287', Enum.FontWeight.Regular, Enum.FontStyle.Normal), Position = UDim2.new(0, 0, 0.5, 0), TextColor3 = Color3.fromRGB(175, 175, 175), BackgroundTransparency = 1,})
				local ElementButton = blitz.create("TextButton", { Parent = ElementFrame, Name = [[ElementButton]], BorderSizePixel = 0, AutoButtonColor = false, BackgroundColor3 = blitz.accent, AnchorPoint = Vector2.new(1, 0.5), TextSize = 14, Size = UDim2.new(0, 44, 0, 20), BorderColor3 = Color3.fromRGB(0, 0, 0), Text = [[]], Font = Enum.Font.SourceSans, Position = UDim2.new(1, 0, 0.5, 0), TextColor3 = Color3.fromRGB(0, 0, 0),}, { ["Accent"] = true })
				local Circle = blitz.create("ImageLabel", { Parent = ElementButton, BorderSizePixel = 0, BackgroundColor3 = Color3.fromRGB(255, 255, 255), AnchorPoint = Vector2.new(1, 0.5), Size = UDim2.new(1, -6, 1, -6), BorderColor3 = Color3.fromRGB(0, 0, 0), Position = UDim2.new(1, 0, 0.5, 0),})
				blitz.create("UICorner", { Parent = ElementButton, CornerRadius = UDim.new(1, 0),})
				blitz.create("UICorner", { Parent = Circle, CornerRadius = UDim.new(1, 0),})
				blitz.create("UIAspectRatioConstraint", { Parent = Circle,})
				blitz.create("UIPadding", { Parent = ElementButton, PaddingRight = UDim.new(0, 4), PaddingLeft = UDim.new(0, 4),})
				
				ElementButton:SetAttribute('Accent', Meta.Value)
				ElementButton.BackgroundColor3 = Meta.Value and blitz.accent or Color3.fromRGB(32, 32, 32)
				Circle.Position = Meta.Value and UDim2.new(1, 0, 0.5, 0) or UDim2.new(0, 0, 0.5, 0)
				Circle.AnchorPoint = Meta.Value and Vector2.new(1, 0.5) or Vector2.new(0, 0.5)

				--@ Functions + Connections
				ElementFrame.MouseEnter:Connect(function()
					if Meta.SecondaryText then
						ElementTitle.Text = Meta.SecondaryText 
					end
				end)

				ElementFrame.MouseLeave:Connect(function()
					if Meta.SecondaryText then
						ElementTitle.Text = Meta.Text 
					end
				end)

				ElementButton.MouseButton1Click:Connect(function()
					Meta.Value = not Meta.Value
					ElementButton:SetAttribute('Accent', Meta.Value)

					blitz.tween(
						ElementButton, { BackgroundColor3 = Meta.Value and blitz.accent or Color3.fromRGB(32, 32, 32)}
					)

					blitz.tween(
						Circle, {
							BackgroundTransparency = Meta.Value and 0 or 0.75;
							Position = Meta.Value and UDim2.new(1, 0, 0.5, 0) or UDim2.new(0, 0, 0.5, 0);
							AnchorPoint = Meta.Value and Vector2.new(1, 0.5) or Vector2.new(0, 0.5)
						}
					)

					Meta.OnToggle(Meta.Value)
				end)

				return Meta
			end

			--@ textbox
			function Section:NewTextbox(...)
				--@ Metadata
				local Meta = blitz.overwrite({
					Text = 'Textbox';
					Value =  '';
					SecondaryText = nil;
					OnFocusLost = function(...) end;
				}, ... or {})

				--@ Instance Creation
				local ElementFrame = blitz.create("Frame", { Parent = SectionContent, Name = [[ElementFrame]], BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 36), BorderColor3 = Color3.fromRGB(0, 0, 0), BackgroundTransparency = 1, BackgroundColor3 = Color3.fromRGB(255, 255, 255),})
				local ElementTitle = blitz.create("TextLabel", { Parent = ElementFrame, Name = [[ElementTitle]], BorderSizePixel = 0, BackgroundColor3 = Color3.fromRGB(255, 255, 255), AnchorPoint = Vector2.new(0.5, 0), TextSize = 20, Size = UDim2.new(1, 0, 0, 14), TextXAlignment = Enum.TextXAlignment.Left, BorderColor3 = Color3.fromRGB(0, 0, 0), Text = Meta.Text, FontFace = Font.new('rbxassetid://12187607287', Enum.FontWeight.Regular, Enum.FontStyle.Normal), Position = UDim2.new(0.5, 0, 0.360000014, 0), TextColor3 = Color3.fromRGB(175, 175, 175), BackgroundTransparency = 1,})
				local ElementButton = blitz.create("TextButton", { Parent = ElementFrame, Name = [[ElementButton]], BorderSizePixel = 0, AutoButtonColor = false, BackgroundColor3 = Color3.fromRGB(32, 32, 32), AnchorPoint = Vector2.new(1, 0.5), TextSize = 14, Size = UDim2.new(0, 100, 0, 24), BorderColor3 = Color3.fromRGB(0, 0, 0), Text = [[]], Font = Enum.Font.SourceSans, Position = UDim2.new(1, 0, 0.5, 0), TextColor3 = Color3.fromRGB(0, 0, 0),})
				local ElementDescription = blitz.create("TextLabel", { Parent = ElementFrame, Name = [[ElementDescription]], Visible = false, BorderSizePixel = 0, BackgroundColor3 = Color3.fromRGB(255, 255, 255), AnchorPoint = Vector2.new(0.5, 1), TextSize = 16, Size = UDim2.new(1, 0, 0, 12), TextXAlignment = Enum.TextXAlignment.Left, BorderColor3 = Color3.fromRGB(0, 0, 0), Text = [[Toggle Description]], FontFace = Font.new('rbxassetid://12187607287', Enum.FontWeight.Regular, Enum.FontStyle.Normal), Position = UDim2.new(0.5, 0, 0.779999971, 0), TextColor3 = Color3.fromRGB(100, 100, 100), BackgroundTransparency = 1,})
				local TextField = blitz.create("TextBox", { TextTruncate = Enum.TextTruncate.AtEnd,  Parent = ElementButton, Name = [[TextField]], BorderSizePixel = 0, BackgroundColor3 = Color3.fromRGB(255, 255, 255), AnchorPoint = Vector2.new(0, 0.5), TextXAlignment = Enum.TextXAlignment.Right, PlaceholderText = [[...]], TextSize = 20, Size = UDim2.new(1, 0, 1, 0), TextColor3 = Color3.fromRGB(175, 175, 175), BorderColor3 = Color3.fromRGB(0, 0, 0), Text = Meta.Value, FontFace = Font.new('rbxassetid://12187607287', Enum.FontWeight.Regular, Enum.FontStyle.Normal), Position = UDim2.new(0, 0, 0.5, 0), BackgroundTransparency = 1,})
				blitz.create("UICorner", { Parent = ElementButton, CornerRadius = UDim.new(0.150000006, 0),})
				blitz.create("UIPadding", { Parent = ElementButton, PaddingRight = UDim.new(0, 6), PaddingLeft = UDim.new(0, 4), PaddingTop = UDim.new(0, 3),})

				--@ Functions + Connections
				ElementFrame.MouseEnter:Connect(function()
					if Meta.SecondaryText then
						ElementTitle.Text = Meta.SecondaryText 
					end
				end)

				ElementFrame.MouseLeave:Connect(function()
					if Meta.SecondaryText then
						ElementTitle.Text = Meta.Text 
					end
				end)

				TextField.FocusLost:Connect(function()
					Meta.Value = TextField.Text
					Meta.OnFocusLost(Meta.Value)
				end)

				return Meta
			end

			--@ keybind
			function Section:NewKeybind(...)
				--@ Metadata
				local Meta = blitz.overwrite({
					Text = 'Keybind';
					Key = nil;
					Mode = 'Click';
					SecondaryText = nil;
					OnKeyPress = function(...) end;
					OnKeyRelease = function(...) end;
					OnKeyClick = function(...) end;
					OnKeyUpdate = function(...) end;

					--@ Non-Tamper
					Editing = false;
					Pressed = false;
				}, ... or {})

				--@ Instance Creationn
				local ElementFrame = blitz.create("Frame", { Parent = SectionContent, Name = [[ElementFrame]], BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 36), BorderColor3 = Color3.fromRGB(0, 0, 0), BackgroundTransparency = 1, BackgroundColor3 = Color3.fromRGB(255, 255, 255),})
				local ElementTitle = blitz.create("TextLabel", { Parent = ElementFrame, Name = [[ElementTitle]], BorderSizePixel = 0, BackgroundColor3 = Color3.fromRGB(255, 255, 255), AnchorPoint = Vector2.new(0.5, 0), TextSize = 20, Size = UDim2.new(1, 0, 0, 14), TextXAlignment = Enum.TextXAlignment.Left, BorderColor3 = Color3.fromRGB(0, 0, 0), Text = Meta.Text, FontFace = Font.new('rbxassetid://12187607287', Enum.FontWeight.Regular, Enum.FontStyle.Normal), Position = UDim2.new(0.5, 0, 0.360000014, 0), TextColor3 = Color3.fromRGB(175, 175, 175), BackgroundTransparency = 1,})
				local ElementDescription = blitz.create("TextLabel", { Parent = ElementFrame, Name = [[ElementDescription]], Visible = false, BorderSizePixel = 0, BackgroundColor3 = Color3.fromRGB(255, 255, 255), AnchorPoint = Vector2.new(0.5, 1), TextSize = 16, Size = UDim2.new(1, 0, 0, 12), TextXAlignment = Enum.TextXAlignment.Left, BorderColor3 = Color3.fromRGB(0, 0, 0), Text = [[Toggle Description]], FontFace = Font.new('rbxassetid://12187607287', Enum.FontWeight.Regular, Enum.FontStyle.Normal), Position = UDim2.new(0.5, 0, 0.779999971, 0), TextColor3 = Color3.fromRGB(100, 100, 100), BackgroundTransparency = 1,})
				local ElementButton = blitz.create("TextButton", { Parent = ElementFrame, Name = [[ElementButton]], BorderSizePixel = 0, AutoButtonColor = false, BackgroundColor3 = Color3.fromRGB(32, 32, 32), AnchorPoint = Vector2.new(1, 0.5), TextSize = 14, Size = UDim2.new(0, 100, 0, 24), BorderColor3 = Color3.fromRGB(0, 0, 0), Text = [[]], Font = Enum.Font.SourceSans, Position = UDim2.new(1, 0, 0.5, 0), TextColor3 = Color3.fromRGB(0, 0, 0),})
				local KeyLabel = blitz.create("TextLabel", { Parent = ElementButton, Name = [[KeyLabel]], BorderSizePixel = 0, BackgroundColor3 = Color3.fromRGB(255, 255, 255), AnchorPoint = Vector2.new(0, 0.5), TextSize = 20, Size = UDim2.new(1, 0, 1, 0), TextXAlignment = Enum.TextXAlignment.Right, BorderColor3 = Color3.fromRGB(0, 0, 0), Text = [[...]], FontFace = Font.new('rbxassetid://12187607287', Enum.FontWeight.Regular, Enum.FontStyle.Normal), Position = UDim2.new(0, 0, 0.5, 0), TextColor3 = Color3.fromRGB(175, 175, 175), BackgroundTransparency = 1,})
				blitz.create("UICorner", { Parent = ElementButton, CornerRadius = UDim.new(0.150000006, 0),})
				blitz.create("UIPadding", { Parent = ElementButton, PaddingRight = UDim.new(0, 6), PaddingLeft = UDim.new(0, 4), PaddingTop = UDim.new(0, 3),})

				--@ Functions + Connections
				ElementFrame.MouseEnter:Connect(function()
					if Meta.SecondaryText then
						ElementTitle.Text = Meta.SecondaryText 
					end
				end)

				ElementFrame.MouseLeave:Connect(function()
					if Meta.SecondaryText then
						ElementTitle.Text = Meta.Text 
					end
				end)

				local Blacklist = {
					'RightSuper',
					'LeftSuper',
					'BackSlash',
					'Backspace',
					'Unknown',
					'Return',
					'Escape',
				}

				ElementButton.MouseButton1Click:Connect(function()
					Meta.Editing = true
					KeyLabel.Text = '...'
					KeyLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
				end)

				Services.UserInputService.InputBegan:Connect(function(Input)
					if Services.UserInputService:GetFocusedTextBox() then return end

					if Meta.Editing then
						KeyLabel.TextColor3 = Color3.new(0.784, 0.784, 0.784)

						if table.find(Blacklist, tostring(Input.KeyCode):gsub('Enum.KeyCode.', '')) then
							Meta.Key = nil
							KeyLabel.Text = '...'
							--KeybindButton.Size = UDim2.new(0, 30, 1, 0)	
							Meta.Editing = false
							return
						end

						Meta.Key = Input.KeyCode
						KeyLabel.Text = tostring(Input.KeyCode):gsub('Enum.KeyCode.', '')
						Meta.OnKeyUpdate(Meta.Key)

						Meta.Editing = false 
						return
					end

					if Meta.Key == nil then return end

					if Input.KeyCode == Meta.Key then
						if Meta.Mode == 'Hold' then
							Meta.Pressed = true
							Meta.OnKeyPress(Meta.Key)
						elseif Meta.Mode == 'Toggle' then
							Meta.Pressed = not Meta.Pressed
							while Meta.Pressed do task.wait()
								Meta.OnKeyPress(Meta.Key)
							end
						elseif Meta.Mode == 'Click' then
							Meta.OnKeyClick(Meta.Key)
						end
					end
				end)

				Services.UserInputService.InputEnded:Connect(function(Input)
					if Meta.Key == nil then return end

					if Input.KeyCode == Meta.Key and Meta.Mode == 'hold' then
						Meta.Pressed = false
						Meta.OnKeyRelease(Meta.Key)
					end
				end)

				return Meta
			end

			--@ dropdown
			function Section:NewDropdown(...)
				--@ Metadata
				local Meta = blitz.overwrite({ 
					Text = 'Dropdown';
					Mode = 'Single';
					Value = {};
					SecondaryText = nil;
					List = {};
					OnSelect = function(...) end;

					--@ Non-Tamper
					Dropped = false;
				}, ... or {})

				--@ Instance Creation
				local ElementFrame = blitz.create("Frame", { Parent = SectionContent, Name = [[ElementFrame]], ZIndex = 0, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 36), BorderColor3 = Color3.fromRGB(0, 0, 0), BackgroundTransparency = 1, BackgroundColor3 = Color3.fromRGB(255, 255, 255),})
				local ElementTitle = blitz.create("TextLabel", { Parent = ElementFrame, Name = [[ElementTitle]], BorderSizePixel = 0, BackgroundColor3 = Color3.fromRGB(255, 255, 255), AnchorPoint = Vector2.new(0.5, 0), TextSize = 20, Size = UDim2.new(1, 0, 0, 14), TextXAlignment = Enum.TextXAlignment.Left, BorderColor3 = Color3.fromRGB(0, 0, 0), Text = Meta.Text, FontFace = Font.new('rbxassetid://12187607287', Enum.FontWeight.Regular, Enum.FontStyle.Normal), Position = UDim2.new(0.5, 0, 0.360000014, 0), TextColor3 = Color3.fromRGB(175, 175, 175), BackgroundTransparency = 1,})
				local ElementDescription = blitz.create("TextLabel", { Parent = ElementFrame, Name = [[ElementDescription]], Visible = false, BorderSizePixel = 0, BackgroundColor3 = Color3.fromRGB(255, 255, 255), AnchorPoint = Vector2.new(0.5, 1), TextSize = 16, Size = UDim2.new(1, 0, 0, 12), TextXAlignment = Enum.TextXAlignment.Left, BorderColor3 = Color3.fromRGB(0, 0, 0), Text = [[Toggle Description]], FontFace = Font.new('rbxassetid://12187607287', Enum.FontWeight.Regular, Enum.FontStyle.Normal), Position = UDim2.new(0.5, 0, 0.779999971, 0), TextColor3 = Color3.fromRGB(100, 100, 100), BackgroundTransparency = 1,})
				local ElementButton = blitz.create("TextButton", { Parent = ElementFrame, Name = [[ElementButton]], ZIndex = 99, BorderSizePixel = 0, AutoButtonColor = false, BackgroundColor3 = Color3.fromRGB(32, 32, 32), AnchorPoint = Vector2.new(1, 0.5), TextSize = 14, Size = UDim2.new(0, 100, 0, 24), BorderColor3 = Color3.fromRGB(0, 0, 0), Text = [[]], Font = Enum.Font.SourceSans, Position = UDim2.new(1, 0, 0.5, 0), TextColor3 = Color3.fromRGB(0, 0, 0),})
				local OptionFrame = blitz.create("Frame", { AutomaticSize = Enum.AutomaticSize.Y; Visible = false;  Parent = ElementButton, Name = [[OptionFrame]], Active = true, AnchorPoint = Vector2.new(0.5, 0), ZIndex = 99, BorderSizePixel = 0, Size = UDim2.new(1, 8, 0, 0), BorderColor3 = Color3.fromRGB(0, 0, 0), Position = UDim2.new(0.5, 0, 1, 0), BackgroundColor3 = Color3.fromRGB(32, 32, 32),})
				local ButtonText = blitz.create("TextLabel", { Parent = ElementButton, Name = [[ElementTitle]], TextWrapped = true, BorderSizePixel = 0, BackgroundColor3 = Color3.fromRGB(255, 255, 255), AnchorPoint = Vector2.new(0, 0.5), TextSize = 16, Size = UDim2.new(0.826086938, 0, 1, 0), TextXAlignment = Enum.TextXAlignment.Left, BorderColor3 = Color3.fromRGB(0, 0, 0), Text = [[Dropdown]], FontFace = Font.new('rbxassetid://12187607287', Enum.FontWeight.Regular, Enum.FontStyle.Normal), Position = UDim2.new(0, 0, 0.5, 0), TextColor3 = Color3.fromRGB(175, 175, 175), BackgroundTransparency = 1,})
				local ChevronIcon = blitz.create("ImageLabel", { Parent = ElementButton, Name = [[ChevronIcon]], AnchorPoint = Vector2.new(1, 0.5), Image = [[rbxassetid://6798365555]], BorderSizePixel = 0, Size = UDim2.new(0, 6, 0, 6), BorderColor3 = Color3.fromRGB(0, 0, 0), ImageColor3 = Color3.fromRGB(175, 175, 175), Rotation = 180, Position = UDim2.new(0.977999985, 0, 0.5, 0), BackgroundTransparency = 1, BackgroundColor3 = Color3.fromRGB(255, 255, 255),})
				local Fade = blitz.create("Frame", { Parent = ElementButton, Name = [[Fade]], AnchorPoint = Vector2.new(1, 0.5), ZIndex = 100, BorderSizePixel = 0, Size = UDim2.new(0.152173907, 10, 1, 0), BorderColor3 = Color3.fromRGB(0, 0, 0), Position = UDim2.new(1, -16, 0.5, 0), BackgroundColor3 = Color3.fromRGB(32, 32, 32),})
				blitz.create("UIGradient", { Parent = Fade, Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1, 0); NumberSequenceKeypoint.new(1, 0, 0);}),})
				blitz.create("UICorner", { Parent = OptionFrame, CornerRadius = UDim.new(0, 2),})
				blitz.create("UIListLayout", { Parent = OptionFrame, SortOrder = Enum.SortOrder.LayoutOrder,})
				blitz.create("UIPadding", { Parent = ButtonText, PaddingLeft = UDim.new(0, 3),})
				blitz.create("Frame", { Parent = ElementButton, Name = [[lil line]], AnchorPoint = Vector2.new(1, 0), BorderSizePixel = 0, Size = UDim2.new(0, 1, 1, 0), BorderColor3 = Color3.fromRGB(0, 0, 0), Position = UDim2.new(1, -14, 0, 0), BackgroundColor3 = Color3.fromRGB(12, 12, 12),})
				blitz.create("UIAspectRatioConstraint", { Parent = ChevronIcon,})
				blitz.create("UICorner", { Parent = ElementButton, CornerRadius = UDim.new(0.150000006, 0),})
				blitz.create("UIPadding", { Parent = ElementButton, PaddingRight = UDim.new(0, 4), PaddingLeft = UDim.new(0, 4),})

				--@ Functions + Connections
				ElementFrame.MouseEnter:Connect(function()
					if Meta.SecondaryText then
						ElementTitle.Text = Meta.SecondaryText 
					end
				end)

				ElementFrame.MouseLeave:Connect(function()
					if Meta.SecondaryText then
						ElementTitle.Text = Meta.Text 
					end
				end)

				--@ populate dropdown
				for Index, Option in Meta.List do
					local OptionButton = blitz.create("TextButton", { Parent = OptionFrame, Name = [[OptionButton]], ZIndex = 99, BorderSizePixel = 0, AutoButtonColor = false, BackgroundColor3 = Color3.fromRGB(32, 32, 32), AnchorPoint = Vector2.new(0, 0.5), TextSize = 16, Size = UDim2.new(1, 0, 0, 24), BorderColor3 = Color3.fromRGB(0, 0, 0), Text = Option, FontFace = Font.new('rbxassetid://12187607287', Enum.FontWeight.Regular, Enum.FontStyle.Normal), Position = UDim2.new(1, 0, 0.5, 0), TextColor3 = Color3.fromRGB(175, 175, 175), BackgroundTransparency = 1,})
					OptionButton.MouseButton1Click:Connect(function()
						if Meta.Mode == 'Single' then
							for _, Button in OptionFrame:GetChildren() do
								if Button:IsA('TextButton') then
									Button.TextColor3 = Color3.fromRGB(164,164,164)
									Button.FontFace = Font.new(
										'rbxassetid://12187607287',
										Enum.FontWeight.Regular, 
										Enum.FontStyle.Normal
									)
								end
							end

							Meta.Value[1] = Option
							ButtonText.Text = Meta.Value[1]
							Meta.OnSelect(Meta.Value)
							OptionButton.TextColor3 = Color3.fromRGB(200, 200, 200)
							OptionButton.FontFace = Font.new(
								'rbxassetid://12187607287', 
								Enum.FontWeight.SemiBold, 
								Enum.FontStyle.Normal
							)
						elseif Meta.Mode == 'Multi' then
							if OptionButton:GetAttribute('Selected') == nil then 
								OptionButton:SetAttribute('Selected', false)
							end

							OptionButton:SetAttribute('Selected', not OptionButton:GetAttribute('Selected'))

							if OptionButton:GetAttribute('Selected') then
								table.insert(Meta.Value, Option)
								Meta.OnSelect(Meta.Value)
								OptionButton.TextColor3 = Color3.fromRGB(200, 200, 200)
								OptionButton.FontFace = Font.new(
									'rbxassetid://12187607287',
									Enum.FontWeight.SemiBold, 
									Enum.FontStyle.Normal
								)
							elseif not OptionButton:GetAttribute('Selected') then
								for i, __ in Meta.Value do
									if __ == Option then
										table.remove(Meta.Value, i)
									end
								end
								Meta.OnSelect(Meta.Value)
								OptionButton.TextColor3 = Color3.fromRGB(164, 164, 164)
								OptionButton.FontFace = Font.new(
									'rbxassetid://12187607287',
									Enum.FontWeight.Regular, 
									Enum.FontStyle.Normal
								)
							end

							ButtonText.Text = table.concat(Meta.Value, ', ')
						end
					end)
				end

				ElementButton.MouseButton1Click:Connect(function()
					OptionFrame.Visible = not OptionFrame.Visible
					ElementFrame.ZIndex = OptionFrame.Visible and 99 or 00
					SectionFrame.ZIndex = OptionFrame.Visible and 99 or 0
					blitz.tween(ChevronIcon, { Rotation = OptionFrame.Visible and 0 or 180 })
				end)

				return Meta	
			end

			--@ slider
			function Section:NewSlider(...)
				--@ Metadata
				local Meta = blitz.overwrite({
					Text = 'Slider';
					SecondaryText = nil;
					Dec = false;
					Min = 0;
					Max = 100;
					Value = 0;
					OnUpdate = function(...) end,
				}, ... or {})

				if Meta.Value < Meta.Min then Meta.Value = Meta.Min end

				--@ Instance Creation
				local ElementFrame = blitz.create("Frame", { Parent = SectionContent, Name = [[ElementFrame]], BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 36), BorderColor3 = Color3.fromRGB(0, 0, 0), BackgroundTransparency = 1, BackgroundColor3 = Color3.fromRGB(255, 255, 255),})
				local ElementTitle = blitz.create("TextLabel", { Parent = ElementFrame, Name = [[ElementTitle]], BorderSizePixel = 0, BackgroundColor3 = Color3.fromRGB(255, 255, 255), AnchorPoint = Vector2.new(0.5, 0), TextSize = 20, Size = UDim2.new(1, 0, 0, 14), TextXAlignment = Enum.TextXAlignment.Left, BorderColor3 = Color3.fromRGB(0, 0, 0), Text = Meta.Text, FontFace = Font.new('rbxassetid://12187607287', Enum.FontWeight.Regular, Enum.FontStyle.Normal), Position = UDim2.new(0.5, 0, 0.360000014, 0), TextColor3 = Color3.fromRGB(175, 175, 175), BackgroundTransparency = 1,})
				local ElementDescription = blitz.create("TextLabel", { Parent = ElementFrame, Name = [[ElementDescription]], Visible = false, BorderSizePixel = 0, BackgroundColor3 = Color3.fromRGB(255, 255, 255), AnchorPoint = Vector2.new(0.5, 1), TextSize = 16, Size = UDim2.new(1, 0, 0, 12), TextXAlignment = Enum.TextXAlignment.Left, BorderColor3 = Color3.fromRGB(0, 0, 0), Text = [[Toggle Description]], FontFace = Font.new('rbxassetid://12187607287', Enum.FontWeight.Regular, Enum.FontStyle.Normal), Position = UDim2.new(0.5, 0, 0.779999971, 0), TextColor3 = Color3.fromRGB(100, 100, 100), BackgroundTransparency = 1,})
				local ElementButton = blitz.create("TextButton", { AutoButtonColor = false; Parent = ElementFrame, Name = [[ElementButton]], BorderSizePixel = 0, BackgroundColor3 = Color3.fromRGB(52, 52, 52), AnchorPoint = Vector2.new(1, 0.5), TextSize = 14, Size = UDim2.new(0, 100, 0, 6), BorderColor3 = Color3.fromRGB(0, 0, 0), Text = [[]], Font = Enum.Font.SourceSans, Position = UDim2.new(1, 0, 0.5, 0), TextColor3 = Color3.fromRGB(0, 0, 0),})
				local SliderFill = blitz.create("Frame", { Parent = ElementButton, Name = [[SliderFill]], BorderSizePixel = 0, Size = UDim2.new(1, 0, 1, 0), BorderColor3 = Color3.fromRGB(0, 0, 0), BackgroundColor3 = blitz.accent,}, { ["Accent"] = true })
				local SliderButton = blitz.create("ImageButton", { Parent = SliderFill, Name = [[SliderButton]], AnchorPoint = Vector2.new(0.5, 0.5), BorderSizePixel = 0, Size = UDim2.new(0, 10, 0, 10), ImageTransparency = 1, BorderColor3 = Color3.fromRGB(0, 0, 0), Position = UDim2.new(1, 0, 0.5, 0), BackgroundColor3 = Color3.fromRGB(255, 255, 255),})
				local SliderValue = blitz.create("TextLabel", { Parent = SliderButton, Name = [[SliderValue]], Visible = true, TextTransparency =1; BorderSizePixel = 0, BackgroundColor3 = Color3.fromRGB(255, 255, 255), AnchorPoint = Vector2.new(0.5, 1), TextSize = 12, Size = UDim2.new(0, 10, 0, 10), BorderColor3 = Color3.fromRGB(0, 0, 0), Text = [[100]], Font = Enum.Font.Gotham, Position = UDim2.new(0.5, 0, 1, -12), TextColor3 = Color3.fromRGB(175, 175, 175), BackgroundTransparency = 1,})
				blitz.create("UIStroke", { Parent = SliderButton, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Thickness = 1.5, Color = Color3.fromRGB(12, 12, 12),})
				blitz.create("UICorner", { Parent = ElementButton, CornerRadius = UDim.new(1, 0),})
				blitz.create("UICorner", { Parent = SliderButton, CornerRadius = UDim.new(1, 0),})
				blitz.create("UICorner", { Parent = SliderFill, CornerRadius = UDim.new(1, 0),})

				--@ Functions + Connections
				ElementFrame.MouseEnter:Connect(function()
					if Meta.SecondaryText then
						ElementTitle.Text = Meta.SecondaryText 
					end
				end)

				ElementFrame.MouseLeave:Connect(function()
					if Meta.SecondaryText then
						ElementTitle.Text = Meta.Text 
					end
				end)

				local Player = Services.Players.LocalPlayer
				local Mouse = Player:GetMouse()

				local MouseDown = false
				local MouseEnter = false

				SliderFill.Size = UDim2.new((Meta.Value - Meta.Min) / (Meta.Max - Meta.Min), 0, 1, 0)
				SliderValue.Text = tostring(Meta.Value):sub(1,4)

				local function update_value()
					local mouse_x = math.clamp(Mouse.X - ElementButton.AbsolutePosition.X, Meta.Min, ElementButton.AbsoluteSize.X)

					if Meta.decimals then
						Meta.Value = (math.clamp((mouse_x / ElementButton.AbsoluteSize.X) * (Meta.Max - Meta.Min) + Meta.Min, Meta.Min, Meta.Max))
						SliderValue.Text = tostring(Meta.Value):sub(1,4)
					elseif not Meta.decimals then
						Meta.Value = math.floor(math.clamp((mouse_x / ElementButton.AbsoluteSize.X) * (Meta.Max - Meta.Min) + Meta.Min, Meta.Min, Meta.Max))
						SliderValue.Text = tostring(Meta.Value)
					end

					SliderFill.Size = UDim2.new((Meta.Value - Meta.Min) / (Meta.Max - Meta.Min), 0, 1, 0)
					Meta.OnUpdate(Meta.Value)
				end

				Mouse.Move:Connect(function() if MouseDown then update_value() end end)

				SliderButton.MouseButton1Down:Connect(function() 
					MouseDown = true update_value()
					blitz.tween(SliderValue, {TextTransparency = 0})
				end)

				SliderButton.MouseButton1Up:Connect(function() 
					MouseDown = false 
					blitz.tween(SliderValue, {TextTransparency = 1})
				end)

				ElementButton.MouseEnter:Connect(function() MouseEnter = true end)

				ElementButton.MouseLeave:Connect(function() MouseEnter = false 
				end)

				Services.UserInputService.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						MouseDown = false
						blitz.tween(SliderValue, {TextTransparency = 1})
					end
				end)

				return Meta
			end

			--@ color picker
			function Section:NewColorPicker(...)
				--@ Metadata
				local Meta = blitz.overwrite({
					Text = 'Color Picker';
					SecondaryText = nil;
					Value = Color3.fromRGB(255, 255, 255);
					OnUpdate = function(...) end;
				}, ... or {})

				--@ Instance Creation
				local ElementFrame = blitz.create("Frame", { Parent = SectionContent, Name = [[ElementFrame]], ZIndex = 0, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 36), BorderColor3 = Color3.fromRGB(0, 0, 0), BackgroundTransparency = 1, BackgroundColor3 = Color3.fromRGB(255, 255, 255),})
				local ElementTitle = blitz.create("TextLabel", { Parent = ElementFrame, Name = [[ElementTitle]], BorderSizePixel = 0, BackgroundColor3 = Color3.fromRGB(255, 255, 255), AnchorPoint = Vector2.new(0.5, 0), TextSize = 20, Size = UDim2.new(1, 0, 0, 14), TextXAlignment = Enum.TextXAlignment.Left, BorderColor3 = Color3.fromRGB(0, 0, 0), Text = Meta.Text, FontFace = Font.new('rbxassetid://12187607287', Enum.FontWeight.Regular, Enum.FontStyle.Normal), Position = UDim2.new(0.5, 0, 0.360000014, 0), TextColor3 = Color3.fromRGB(175, 175, 175), BackgroundTransparency = 1,})
				local ElementButton = blitz.create("TextButton", { Parent = ElementFrame, Name = [[ElementButton]], ZIndex = 99, BorderSizePixel = 0, AutoButtonColor = false, BackgroundColor3 = Color3.fromRGB(32, 32, 32), AnchorPoint = Vector2.new(1, 0.5), TextSize = 14, Size = UDim2.new(0, 44, 0, 24), BorderColor3 = Color3.fromRGB(0, 0, 0), Text = [[]], Font = Enum.Font.SourceSans, Position = UDim2.new(1, 0, 0.5, 0), TextColor3 = Color3.fromRGB(0, 0, 0), BackgroundTransparency = 1,})
				local ElementDescription = blitz.create("TextLabel", { Parent = ElementFrame, Name = [[ElementDescription]], Visible = false, BorderSizePixel = 0, BackgroundColor3 = Color3.fromRGB(255, 255, 255), AnchorPoint = Vector2.new(0.5, 1), TextSize = 16, Size = UDim2.new(1, 0, 0, 12), TextXAlignment = Enum.TextXAlignment.Left, BorderColor3 = Color3.fromRGB(0, 0, 0), Text = [[Toggle Description]], FontFace = Font.new('rbxassetid://12187607287', Enum.FontWeight.Regular, Enum.FontStyle.Normal), Position = UDim2.new(0.5, 0, 0.779999971, 0), TextColor3 = Color3.fromRGB(100, 100, 100), BackgroundTransparency = 1,})
				local ColorCircle = blitz.create("Frame", { Parent = ElementButton, Name = [[Color]], AnchorPoint = Vector2.new(0, 0.5), BorderSizePixel = 0, Size = UDim2.new(1, -4, 1, -4), BorderColor3 = Color3.fromRGB(0, 0, 0), Position = UDim2.new(0, 0, 0.5, 0), BackgroundColor3 = Meta.Value,})
				local BrushIcon = blitz.create("ImageLabel", { Parent = ElementButton, Name = [[Icon]], AnchorPoint = Vector2.new(1, 0.5), Image = [[http://www.roblox.com/asset/?id=6031572320]], BorderSizePixel = 0, Size = UDim2.new(1, -4, 1, -4), BorderColor3 = Color3.fromRGB(0, 0, 0), ImageColor3 = Color3.fromRGB(125, 125, 125), Position = UDim2.new(1, 0, 0.5, 0), BackgroundTransparency = 1, BackgroundColor3 = Color3.fromRGB(255, 255, 255),})
				local ColorPicker = blitz.create("Frame", { Parent = nil, Name = [[ColorPicker]], BorderSizePixel = 0, Size = UDim2.new(0, 360, 0, 255), BorderColor3 = Color3.fromRGB(0, 0, 0), Position = UDim2.new(1.00000012, 20, 0, 0), BackgroundColor3 = Color3.fromRGB(12, 12, 12),})
				local RGBMap = blitz.create("ImageLabel", { Parent = ColorPicker, Name = [[RGBMap]], AnchorPoint = Vector2.new(0.5, 0), Image = [[rbxassetid://1433361550]], Size = UDim2.new(0, 340, 0, 172), SliceCenter = Rect.new(10, 10, 90, 90), BorderColor3 = Color3.fromRGB(40, 40, 40), Position = UDim2.new(0.497000009, 0, 0, 25), BackgroundColor3 = Color3.fromRGB(255, 255, 255),})
				local Hitbox = blitz.create("TextButton", { Parent = RGBMap, Name = [[Hitbox]], ZIndex = 99, BackgroundColor3 = Color3.fromRGB(255, 255, 255), TextSize = 14, Size = UDim2.new(1, 0, 1, 0), TextTransparency = 1, TextColor3 = Color3.fromRGB(0, 0, 0), BackgroundTransparency = 1,})
				local Marker = blitz.create("Frame", { Parent = RGBMap, Name = [[Marker]], AnchorPoint = Vector2.new(0.5, 0.5), ZIndex = 5, BorderSizePixel = 0, Size = UDim2.new(0, 5, 0, 5), BorderColor3 = Color3.fromRGB(0, 0, 0), BackgroundColor3 = Color3.fromRGB(255, 16, 231),})
				local TitleLabel = blitz.create("TextLabel", { Parent = ColorPicker, Name = [[TitleLabel]], BorderSizePixel = 0, BackgroundColor3 = Color3.fromRGB(255, 255, 255), TextSize = 17, Size = UDim2.new(0, 351, 0, 12), TextXAlignment = Enum.TextXAlignment.Left, BorderColor3 = Color3.fromRGB(0, 0, 0), Text = `Color Picker ({Meta.Text})`, FontFace = Font.new('rbxassetid://12187607287', Enum.FontWeight.Regular, Enum.FontStyle.Normal), Position = UDim2.new(0.0250000004, 0, 0.0313725509, 0), TextColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 1,})
				local PreviewFrame = blitz.create("Frame", { Parent = ColorPicker, Name = [[PreviewFrame]], ZIndex = 999, BorderSizePixel = 0, Size = UDim2.new(0, 54, 0, 16), BorderColor3 = Color3.fromRGB(0, 0, 0), Position = UDim2.new(0, 9, 0, 203), BackgroundColor3 = Color3.fromRGB(255, 255, 255),})
				local CheckerPattern = blitz.create("ImageLabel", { Parent = PreviewFrame, Name = [[CheckerPattern]], AnchorPoint = Vector2.new(0.5, 0.5), Image = [[rbxassetid://14727168439]], TileSize = UDim2.new(0.340000004, 0, 0.699999988, 0), BorderSizePixel = 0, Size = UDim2.new(1.00000012, 0, 1, 0), ScaleType = Enum.ScaleType.Tile, BorderColor3 = Color3.fromRGB(0, 0, 0), ImageTransparency = 1, ImageColor3 = Color3.fromRGB(12, 12, 12), Position = UDim2.new(0.50000006, 0, 0.5, 0), BackgroundTransparency = 1, BackgroundColor3 = Color3.fromRGB(255, 255, 255),})
				local RedInput = blitz.create("TextBox", { Parent = ColorPicker, Name = [[RedInput]], CursorPosition = -1, BorderSizePixel = 0, BackgroundColor3 = Color3.fromRGB(22, 22, 22), TextXAlignment = Enum.TextXAlignment.Right, TextSize = 20, Size = UDim2.new(0.330000013, -8, 0, 22), TextColor3 = Color3.fromRGB(150, 150, 150), BorderColor3 = Color3.fromRGB(0, 0, 0), Text = [[999]], FontFace = Font.new('rbxassetid://12187607287', Enum.FontWeight.Regular, Enum.FontStyle.Normal), Position = UDim2.new(0, 8, 0, 225), ClearTextOnFocus = false,})
				local TextLabel = blitz.create("TextLabel", { Parent = RedInput, BorderSizePixel = 0, BackgroundColor3 = Color3.fromRGB(255, 255, 255), TextSize = 20, Size = UDim2.new(0, 41, 0, 22), TextXAlignment = Enum.TextXAlignment.Left, BorderColor3 = Color3.fromRGB(0, 0, 0), Text = [[R]], FontFace = Font.new('rbxassetid://12187607287', Enum.FontWeight.Regular, Enum.FontStyle.Normal), TextColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 1,})
				local Frame = blitz.create("Frame", { Parent = RedInput, BorderSizePixel = 0, Size = UDim2.new(0, 1, 0, 22), BorderColor3 = Color3.fromRGB(0, 0, 0), Position = UDim2.new(0, 16, 0, 0), BackgroundColor3 = Color3.fromRGB(12, 12, 12),})
				local GreenInput = blitz.create("TextBox", { Parent = ColorPicker, Name = [[GreenInput]], CursorPosition = -1, BorderSizePixel = 0, BackgroundColor3 = Color3.fromRGB(22, 22, 22), TextXAlignment = Enum.TextXAlignment.Right, TextSize = 20, Size = UDim2.new(0.330000013, -8, 0, 22), TextColor3 = Color3.fromRGB(150, 150, 150), BorderColor3 = Color3.fromRGB(0, 0, 0), Text = [[999]], FontFace = Font.new('rbxassetid://12187607287', Enum.FontWeight.Regular, Enum.FontStyle.Normal), Position = UDim2.new(0, 123, 0, 225), ClearTextOnFocus = false,})
				local TextLabel2 = blitz.create("TextLabel", { Parent = GreenInput, BorderSizePixel = 0, BackgroundColor3 = Color3.fromRGB(255, 255, 255), TextSize = 20, Size = UDim2.new(0, 41, 0, 22), TextXAlignment = Enum.TextXAlignment.Left, BorderColor3 = Color3.fromRGB(0, 0, 0), Text = [[G]], FontFace = Font.new('rbxassetid://12187607287', Enum.FontWeight.Regular, Enum.FontStyle.Normal), TextColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 1,})
				local Frame2 = blitz.create("Frame", { Parent = GreenInput, BorderSizePixel = 0, Size = UDim2.new(0, 1, 0, 22), BorderColor3 = Color3.fromRGB(0, 0, 0), Position = UDim2.new(0, 16, 0, 0), BackgroundColor3 = Color3.fromRGB(12, 12, 12),})
				local BlueInput = blitz.create("TextBox", { Parent = ColorPicker, Name = [[BlueInput]], CursorPosition = -1, BorderSizePixel = 0, BackgroundColor3 = Color3.fromRGB(22, 22, 22), TextXAlignment = Enum.TextXAlignment.Right, TextSize = 20, Size = UDim2.new(0.330000013, -8, 0, 22), TextColor3 = Color3.fromRGB(150, 150, 150), BorderColor3 = Color3.fromRGB(0, 0, 0), Text = [[999]], FontFace = Font.new('rbxassetid://12187607287', Enum.FontWeight.Regular, Enum.FontStyle.Normal), Position = UDim2.new(0, 238, 0, 225), ClearTextOnFocus = false,})
				local TextLabel3 = blitz.create("TextLabel", { Parent = BlueInput, BorderSizePixel = 0, BackgroundColor3 = Color3.fromRGB(255, 255, 255), TextSize = 20, Size = UDim2.new(0, 41, 0, 22), TextXAlignment = Enum.TextXAlignment.Left, BorderColor3 = Color3.fromRGB(0, 0, 0), Text = [[B]], FontFace = Font.new('rbxassetid://12187607287', Enum.FontWeight.Regular, Enum.FontStyle.Normal), TextColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 1,})
				local Frame3 = blitz.create("Frame", { Parent = BlueInput, BorderSizePixel = 0, Size = UDim2.new(0, 1, 0, 22), BorderColor3 = Color3.fromRGB(0, 0, 0), Position = UDim2.new(0, 16, 0, 0), BackgroundColor3 = Color3.fromRGB(12, 12, 12),})
				local ValueSlider = blitz.create("Frame", { Parent = ColorPicker, Name = [[ValueSlider]], BorderSizePixel = 0, Size = UDim2.new(0, 280, 0, 6), BorderColor3 = Color3.fromRGB(0, 0, 0), Position = UDim2.new(0, 69, 0, 203), BackgroundColor3 = Color3.fromRGB(255, 255, 255),})
				local Fill = blitz.create("Frame", { Parent = ValueSlider, Name = [[Fill]], BorderSizePixel = 0, Size = UDim2.new(1, 0, 1, 0), BorderColor3 = Color3.fromRGB(0, 0, 0), BackgroundTransparency = 1, BackgroundColor3 = Color3.fromRGB(255, 255, 255),})
				local Marker2 = blitz.create("ImageButton", { Parent = Fill, Name = [[Marker]], AnchorPoint = Vector2.new(0.5, 0.5), Image = [[rbxasset://textures/ui/GuiImagePlaceholder.png]], BorderSizePixel = 0, Size = UDim2.new(0, 6, 0, 6), ImageTransparency = 1, BorderColor3 = Color3.fromRGB(0, 0, 0), Position = UDim2.new(1, 0, 0.5, 0), BackgroundColor3 = Color3.fromRGB(255, 255, 255),})
				local AlphaSlider = blitz.create("Frame", { Parent = ColorPicker, Name = [[AlphaSlider]], BorderSizePixel = 0, Size = UDim2.new(0, 280, 0, 6), BorderColor3 = Color3.fromRGB(0, 0, 0), Position = UDim2.new(0, 69, 0, 213), BackgroundColor3 = Color3.fromRGB(255, 255, 255),})
				local Fill2 = blitz.create("Frame", { Parent = AlphaSlider, Name = [[Fill]], BorderSizePixel = 0, Size = UDim2.new(1, 0, 1, 0), BorderColor3 = Color3.fromRGB(0, 0, 0), BackgroundTransparency = 1, BackgroundColor3 = Color3.fromRGB(255, 255, 255),})
				local Marker3 = blitz.create("ImageButton", { Parent = Fill2, Name = [[Marker]], AnchorPoint = Vector2.new(0.5, 0.5), Image = [[rbxasset://textures/ui/GuiImagePlaceholder.png]], BorderSizePixel = 0, Size = UDim2.new(0, 6, 0, 6), ImageTransparency = 1, BorderColor3 = Color3.fromRGB(0, 0, 0), Position = UDim2.new(1, 0, 0.5, 0), BackgroundColor3 = Color3.fromRGB(255, 255, 255),})
				local CheckerPattern2 = blitz.create("ImageLabel", { Parent = AlphaSlider, Name = [[CheckerPattern]], AnchorPoint = Vector2.new(0.5, 0.5), Image = [[rbxassetid://14727168439]], ImageTransparency = 1, TileSize = UDim2.new(0.0250000004, 0, 1, 0), ZIndex = 0, BorderSizePixel = 0, Size = UDim2.new(1, 0, 1, 0), ScaleType = Enum.ScaleType.Tile, BorderColor3 = Color3.fromRGB(0, 0, 0), ImageColor3 = Color3.fromRGB(0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0), BackgroundTransparency = 1, BackgroundColor3 = Color3.fromRGB(255, 255, 255),})
				local CloseButton = blitz.create("TextButton", { Parent = ColorPicker, Name = [[CloseButton]], BorderSizePixel = 0, BackgroundColor3 = Color3.fromRGB(255, 255, 255), AnchorPoint = Vector2.new(1, 0), TextSize = 14, Size = UDim2.new(0, 28, 0, 24), BorderColor3 = Color3.fromRGB(0, 0, 0), Text = [[x]], Font = Enum.Font.Michroma, Position = UDim2.new(1, 0, 0, 0), TextColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 1,})
				
				blitz.create("UIStroke", { Parent = Marker, Color = Color3.fromRGB(255, 255, 255),})
				blitz.create("UIStroke", { Parent = Marker2,})
				blitz.create("UIStroke", { Parent = Marker3,})
				blitz.create("UICorner", { Parent = ColorPicker, CornerRadius = UDim.new(0, 12),})
				blitz.create("UICorner", { Parent = Marker, CornerRadius = UDim.new(1, 0),})
				blitz.create("UICorner", { Parent = RGBMap, CornerRadius = UDim.new(0, 4),})
				blitz.create("UICorner", { Parent = PreviewFrame, CornerRadius = UDim.new(0, 4),})
				blitz.create("UICorner", { Parent = CheckerPattern, CornerRadius = UDim.new(0, 4),})
				blitz.create("UICorner", { Parent = RedInput, CornerRadius = UDim.new(0, 4),})
				blitz.create("UICorner", { Parent = GreenInput, CornerRadius = UDim.new(0, 4),})
				blitz.create("UICorner", { Parent = BlueInput, CornerRadius = UDim.new(0, 4),})
				blitz.create("UICorner", { Parent = ValueSlider, CornerRadius = UDim.new(1, 0),})
				blitz.create("UICorner", { Parent = Marker2, CornerRadius = UDim.new(1, 0),})
				blitz.create("UICorner", { Parent = AlphaSlider, CornerRadius = UDim.new(1, 0),})
				blitz.create("UICorner", { Parent = Marker3, CornerRadius = UDim.new(1, 0),})
				blitz.create("UICorner", { Parent = CheckerPattern2, CornerRadius = UDim.new(1, 0),})
				blitz.create("UICorner", { Parent = BrushIcon, CornerRadius = UDim.new(1, 0),})
				blitz.create("UICorner", {Parent = ColorCircle, CornerRadius = UDim.new(1, 0),})
				blitz.create("UIPadding", { Parent = RedInput, PaddingRight = UDim.new(0, 10), PaddingLeft = UDim.new(0, 10),})
				blitz.create("UIPadding", { Parent = GreenInput, PaddingRight = UDim.new(0, 10), PaddingLeft = UDim.new(0, 10),})
				blitz.create("UIPadding", { Parent = BlueInput, PaddingRight = UDim.new(0, 10), PaddingLeft = UDim.new(0, 10),})
				blitz.create("UIGradient", { Parent = ValueSlider, Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)); ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255));}),})
				blitz.create("UIGradient", { Parent = CheckerPattern2, Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0, 0); NumberSequenceKeypoint.new(1, 1, 0);}),})
				blitz.create("UIAspectRatioConstraint", { Parent = BrushIcon, })
				blitz.create("UIAspectRatioConstraint", { Parent = ColorCircle,})
				
				--@ Functions + Connections
				ElementButton.MouseButton1Click:Connect(function()
					if WindowFrame:FindFirstChild('ColorPicker') then
						WindowFrame.ColorPicker.Parent = nil
					end

					Meta.Hidden = not Meta.Hidden
					ColorPicker.Parent = Meta.Hidden and WindowFrame or blitz.cache
				end)
				
				CloseButton.MouseButton1Click:Connect(function()
					Meta.Hidden = true
					ColorPicker.Parent = blitz.cache
				end)

				local rgb_map = RGBMap
				local value_map = ValueSlider
				local Color = PreviewFrame

				local Hitbox = rgb_map.Hitbox
				local Marker = rgb_map.Marker
				--local Marker2 = value_map.Marker

				local RedInput = RedInput
				local GreenInput = GreenInput
				local BlueInput = BlueInput

				local Player = Services.Players.LocalPlayer
				local Mouse = Player:GetMouse()

				local mouse_down = false

				local function tween(instance : Instance, meta : {}, info : TweenInfo)
					game.TweenService:Create(
						instance,
						info or TweenInfo.new(.25, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
						meta
					):Play()
				end;

				local function overwrite(T1 : {}, T2 : {})
					for i, v in pairs(T2) do
						if type(v) == 'table' then
							T1[i] = overwrite(T1[i] or {}, v)
						else
							T1[i] = v
						end
					end

					return T1 or nil
				end;

				local Color_H, Color_S, Color_V = Meta.Value:ToHSV()
				local Color_RGB = Color3.fromHSV(Color_H, Color_S, Color_V)
				local ColorData = {
					Hue = 0;
					Sat = 0;
					Val = 1;
					Alpha = 0;
					RGB = nil;
				}

				local function SetColor(...)
					ColorData = overwrite(ColorData, ... or {})
					
					Color_RGB = Color3.fromHSV(
						ColorData.Hue,
						ColorData.Sat,
						ColorData.Val
					)
					
					ColorData.RGB = Color3.fromRGB(
						Color_RGB.R * 255,
						Color_RGB.G * 255,
						Color_RGB.B * 255
					)

					Color.BackgroundColor3 = ColorData.RGB
					ColorCircle.BackgroundColor3 = ColorData.RGB
					Marker.BackgroundColor3 = ColorData.RGB
					ValueSlider.BackgroundColor3 = ColorData.RGB
					AlphaSlider.BackgroundColor3 = ColorData.RGB
					RedInput.Text = math.round(Color_RGB.R * 255)
					GreenInput.Text = math.round(Color_RGB.G * 255)
					BlueInput.Text = math.round(Color_RGB.B * 255)
					Color.CheckerPattern.ImageTransparency = 1 - ColorData.Alpha

					if ColorData.Sat < .25 then tween(Marker.UIStroke, {Color = Color3.fromHSV(0,0,0)}, TweenInfo.new(.15)) end
					if ColorData.Sat > .25 then tween(Marker.UIStroke, {Color = Color3.fromHSV(0,0,1)}, TweenInfo.new(.15)) end

					Meta.Value = ColorData
					Meta.OnUpdate(Meta.Value)
				end

				local function InBounds(i)
					local x, y = Mouse.X - i.AbsolutePosition.X, Mouse.Y - i.AbsolutePosition.Y
					local max_x, max_y = i.AbsoluteSize.X, i.AbsoluteSize.Y

					if x >= 0 and y >= 0 and x <= max_x and y <= max_y then
						return x/max_x,y/max_y
					end
				end

				local function update_rgb()
					if mouse_down then
						local x,y = InBounds(rgb_map)
						if x and y then
							Marker.Position = UDim2.new(x,0,y,0)
							SetColor({ Hue = 1 - x, Sat = 1 - y})
						end

						local x,y = InBounds(value_map)
						if x and y then
							ValueSlider.Fill.Marker.Position = UDim2.new(0.5,0,y,0)
							SetColor({ Val = 1 - y})
						end
					end
				end

				Color.BackgroundColor3 = Color_RGB
				Marker.BackgroundColor3 = Color_RGB
				ValueSlider.BackgroundColor3 = Color_RGB
				AlphaSlider.BackgroundColor3 = Color_RGB
				RedInput.Text = math.round(Color_RGB.R * 255)
				GreenInput.Text = math.round(Color_RGB.G * 255)
				BlueInput.Text = math.round(Color_RGB.B * 255)
				Color.CheckerPattern.ImageTransparency = ColorData.Alpha

				update_rgb()
				local x,y = InBounds(rgb_map)
				Marker.Position = UDim2.new(x,0,y,0)

				Mouse.Move:Connect(function() update_rgb() end)

				rgb_map.MouseLeave:Connect(function() mouse_down = false end)
				value_map.MouseLeave:Connect(function() mouse_down = false end)
				Hitbox.MouseButton1Up:Connect(function() mouse_down = false end)
				Hitbox.MouseButton1Down:Connect(function() mouse_down = true end)

				-- >> Value Slider Control
				local ValueSlider = ValueSlider
				local ValueFill = ValueSlider.Fill
				local ValueMarker = ValueFill.Marker

				local ValueMeta = {
					Text = 'Slider';
					SecondaryText = nil;
					Dec = true;
					Min = 0;
					Max = 1;
					Value = 1;
					OnUpdate = function(...) end,
				}

				local S1_MouseDown = false
				local S1_MouseEnter = false

				local Min, Max, Value = ValueMeta.Min, ValueMeta.Max, ValueMeta.Value

				ValueFill.Size = UDim2.new((Value - Min) / (Max - Min), 0, 1, 0)

				local function update_value()
					local mouse_x = math.clamp(Mouse.X - ValueSlider.AbsolutePosition.X, Min, ValueSlider.AbsoluteSize.X)

					if ValueMeta.Dec then
						ValueMeta.Value = (math.clamp((mouse_x / ValueSlider.AbsoluteSize.X) * (Max - Min) + Min, Min, Max))
						SetColor({ Val = ValueMeta.Value})
					elseif not ValueMeta.Dec then
						ValueMeta.Value = math.floor(math.clamp((mouse_x / ValueSlider.AbsoluteSize.X) * (Max - Min) + Min, Min, Max))
						SetColor({ Val = ValueMeta.Value})
					end

					ValueFill.Size = UDim2.new((ValueMeta.Value - Min) / (Max - Min), 0, 1, 0)
					ValueMeta.OnUpdate(ValueMeta.Value)
				end

				Mouse.Move:Connect(function() if S1_MouseDown then update_value() end end)

				ValueMarker.MouseButton1Down:Connect(function() S1_MouseDown = true update_value() end)
				ValueMarker.MouseButton1Up:Connect(function() S1_MouseDown = false end)
				ValueSlider.MouseEnter:Connect(function() S1_MouseEnter = true end)
				ValueSlider.MouseLeave:Connect(function() S1_MouseEnter = false  end)

				Services.UserInputService.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						S1_MouseDown = false
					end
				end)

				-- >> Alpha Slider Control
				local AlphaSlider = AlphaSlider
				local AlphaFill = AlphaSlider.Fill
				local AlphaMarker = AlphaFill.Marker

				local AlphaMeta = {
					Text = 'Slider';
					SecondaryText = nil;
					Dec = true;
					Min = 0;
					Max = 1;
					Value = 1;
					Inversed = 0;
					OnUpdate = function(...) end,
				}

				local S2_MouseDown = false
				local S2_MouseEnter = false

				local Min, Max, Value = AlphaMeta.Min, AlphaMeta.Max, AlphaMeta.Value

				AlphaFill.Size = UDim2.new((Value - Min) / (Max - Min), 0, 1, 0)

				local function UpdateAlpha()
					local mouse_x = math.clamp(Mouse.X - AlphaSlider.AbsolutePosition.X, Min, AlphaSlider.AbsoluteSize.X)

					if AlphaMeta.Dec then
						AlphaMeta.Value = (math.clamp((mouse_x / AlphaSlider.AbsoluteSize.X) * (Max - Min) + Min, Min, Max))
						SetColor({ Alpha = 1 - AlphaMeta.Value})
					elseif not AlphaMeta.Dec then
						AlphaMeta.Value = math.floor(math.clamp((mouse_x / AlphaSlider.AbsoluteSize.X) * (Max - Min) + Min, Min, Max))
						SetColor({ Alpha = 1 - AlphaMeta.Value})
					end

					AlphaFill.Size = UDim2.new((AlphaMeta.Value - Min) / (Max - Min), 0, 1, 0)
					AlphaMeta.OnUpdate(AlphaMeta.Value)
				end

				Mouse.Move:Connect(function() if S2_MouseDown then UpdateAlpha() end end)

				AlphaMarker.MouseButton1Down:Connect(function() S2_MouseDown = true UpdateAlpha() end)
				AlphaMarker.MouseButton1Up:Connect(function() S2_MouseDown = false end)
				AlphaSlider.MouseEnter:Connect(function() S2_MouseEnter = true end)
				AlphaSlider.MouseLeave:Connect(function() S2_MouseEnter = false end)

				Services.UserInputService.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						S2_MouseDown = false
					end
				end)

			end

			return Section
		end

		Window.Tabs[Name] = Tab
		Window.Tabs[Name].Frame = TabFrame
		Window.Tabs[Name].Button = TabButton
		return Tab
	end

	return Window
end

return blitz
