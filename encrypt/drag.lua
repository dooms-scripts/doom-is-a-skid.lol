return(function(Frame)
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
  	
  	if ValidInput(InputType) and Frame.GuiState == Enum.GuiState.Press then
  		DragStartPos = Input.Position
  		FrameStartPos = Frame.Position
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
  
  			Frame.Position = UDim2.new(
  				FrameStartPos.X.Scale, FrameStartPos.X.Offset + DeltaPosition.X,
  				FrameStartPos.Y.Scale, FrameStartPos.Y.Offset + DeltaPosition.Y
  			)
  		end
  	end
  end)
end)
