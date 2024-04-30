--[[

	encrypt esp library
	~~~~~~~~~~~~~~~~~~~
	> ESP LIBRARY
	> MADE BY doom#1000
	
]]--

-- [ ATTRIBUTES ] ----------------------------------------------------------------------------------
local library = { 
	version = 'e1.0.8', 
	drawings = { 
		highlights = {}, 
		skeletons = {}, 
		tracers = {}, 
		labels = {}, 
		boxes = {}, 
	}
}

Drawing = Drawing or error('Your executor is not supported.', 99)
cloneref = cloneref or function(...) return(...) end

-- [ SERVICES ] ------------------------------------------------------------------------------------
local run = game:GetService('RunService')
local core = cloneref(game:GetService('CoreGui'))
local players = game:GetService('Players')

-- [ FUNCTIONS ] -----------------------------------------------------------------------------------
local function clearAllDrawings()
	for _, __table in pairs(library.drawings) do
		for _, drawing in pairs(__table) do
			drawing:Destroy()
			--> print('removed 1 drawing')
		end
	end
end

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

library.new = function(esp_type : string, player : Player, ... : {})
	--// HIGHLIGHTS \\--------------------------------------------------
	if esp_type == 'Highlight' then
		local highlight, defaults, connections = { i = #library.drawings.highlights+1 }, {
			Enabled = true, -- <bool>
			FillColor = Color3.fromRGB(255, 255, 255), -- <color3>
			OutlineColor = Color3.fromRGB(0, 0, 0), -- <color3>
			FillTransparency = 0.65, -- <number>
			OutlineTransparency = 0, -- <number>
		}, {}
		
		local data = overwrite(defaults, ... or {})
		local instance = Instance.new('Highlight', core)

		local function create_highlight()
			local character = player.Character or player.CharacterAdded:Wait()
			instance.DepthMode = 'AlwaysOnTop'
			instance.FillColor = data.FillColor
			instance.OutlineColor = data.OutlineColor
			instance.FillTransparency = data.FillTransparency
			instance.OutlineTransparency = data.OutlineTransparency
			instance.Adornee = character
			instance.Enabled = data.Enabled
		end

		function highlight:Hide()
			instance.Enabled = false
		end

		function highlight:Show()
			instance.Enabled = true
		end
		
		function highlight:Update(...)
			data = overwrite(data, ... or {})
			instance.FillColor = data.FillColor
			instance.OutlineColor = data.OutlineColor
			instance.FillTransparency = data.FillTransparency
			instance.OutlineTransparency = data.OutlineTransparency
			instance.Adornee = player.Character
			instance.Enabled = data.Enabled
		end

		function highlight:Destroy()
			connections['CharacterAdded']:Disconnect()
			instance:Destroy()
			table.remove(library.drawings.highlights[highlight.i])
			warn(`! Destroyed Highlight#{highlight.i}`)	
		end
		
		connections['CharacterAdded'] = player.CharacterAdded:Connect(create_highlight)
		
		library.drawings.highlights[highlight.i] = highlight
		return highlight, create_highlight()
	end
	
	--// TEXT LABELS \\-------------------------------------------------
	if esp_type == 'Text' then
		local text, defaults, connections = { i = #library.drawings.labels+1 }, { -- <table>
			Text = 'Text', -- <string>
			Enabled = true, -- <bool>
			TextStroke = true, -- <bool>
			TextColor3 = Color3.fromRGB(255, 255, 255), -- <color3>
			TextStrokeColor3 = Color3.fromRGB(0, 0, 0), -- <color3>
			UpdateSpeed = 0, -- <number>
		}, {}

		local data = overwrite(defaults, ... or {})
		
		local instance = Drawing.new('Text')
		instance.Text = data.Text
		instance.Visible = data.Enabled
		instance.Color = data.TextColor3
		instance.Outline = data.TextStroke
		instance.OutlineColor = data.TextStrokeColor3
		
		function text:Hide()
			instance.Visible = false
		end
		
		function text:Show()
			instance.Visible = true
		end
		
		function text:Update(...)			
			data = overwrite(data, ... or {})
			instance.Text = data.Text
			instance.Visible = data.Enabled
			instance.Color = data.TextColor3
			instance.Outline = data.TextStroke
			instance.OutlineColor = data.TextStrokeColor3
		end
		
		function text:Destroy()
			connections['RenderStepped']:Disconnect()
			instance:Remove()
			table.remove(library.drawings.labels[text.i])
			warn(`! Destroyed Text#{text.i}`)
		end

		connections['RenderStepped'] = run.RenderStepped:Connect(function()
			if player.Character and data.Enabled then
				local root = player.Character:WaitForChild('HumanoidRootPart')
				
				local vector, on_screen = workspace.CurrentCamera:WorldToViewportPoint(root.Position)
				
				if on_screen then text:Show() else text:Hide() end

				instance.Position = Vector2.new(vector.X + 10, vector.Y - 10)
				--- print('Text Running')
			elseif player.Character == nil then
				text:Destroy() 
			end

			task.wait(data.UpdateSpeed)
		end)
		
		library.drawings.labels[text.i] = text
		return text
	end
	
	--// TRACERS \\-----------------------------------------------------
	if esp_type == 'Tracer' then
		local tracer, defaults, connections = { i = #library.drawings.tracers+1, From = Vector2.new(workspace.CurrentCamera.ViewportSize.X / 2, workspace.CurrentCamera.ViewportSize.Y) }, { -- <table>
			Enabled = true, -- <bool>
			Outline = false, -- <bool>
			Color = Color3.fromRGB(255, 255, 255), -- <color3>
			OutlineColor = Color3.fromRGB(0, 0, 0), -- <color3>
			Thickness = 1, -- <number>
			UpdateSpeed = 0, -- <number>
		}, {}

		local data = overwrite(defaults, ... or {})
		local tracerOutline
	
		if data.Outline then
			tracerOutline = Drawing.new('Line')
			tracerOutline.Color = data.OutlineColor
			tracerOutline.Thickness = data.Thickness + 2
		end
		
		local instance = Drawing.new('Line')
		instance.Visible = data.Enabled
		instance.Color = data.Color
		instance.Thickness = data.Thickness
		
		function tracer:Hide()
			instance.Visible = false
			
			if tracerOutline then 
				tracerOutline.Visible = false 
			end
		end

		function tracer:Show()
			instance.Visible = true

			if tracerOutline then 
				tracerOutline.Visible = true 
			end
		end
		
		function tracer:Update(...)
			data = overwrite(data, ... or {})
			
			if data.Outline then
				tracerOutline = Drawing.new('Line')
				tracerOutline.Color = data.OutlineColor
				tracerOutline.Thickness = data.Thickness + 2
				tracerOutline.Visible = data.Outline
				
				if data.Outline then
					tracerOutline.Visible = data.Enabled
				end
			end
			
			instance.Visible = data.Enabled
			instance.Color = data.Color
			instance.Thickness = data.Thickness
		end
		
		function tracer:Destroy()
			connections['RenderStepped']:Disconnect()
			instance:Remove()
			if tracerOutline then tracerOutline:Remove() end
			table.remove(library.drawings.tracers[tracer.i])
			warn(`! Destroyed Tracer#{tracer.i}`)
		end
		
		connections['RenderStepped'] = run.RenderStepped:Connect(function()
			if player.Character and data.Enabled then
				local root = player.Character:WaitForChild('HumanoidRootPart')

				local vector, on_screen = workspace.CurrentCamera:WorldToViewportPoint(root.Position)

				if tracerOutline then
					tracerOutline.Visible = data.Outline
					tracerOutline.From = tracer.From
					tracerOutline.To = Vector2.new(vector.X, vector.Y)
				end
				
				if on_screen then tracer:Show() else tracer:Hide() end
				
				instance.From = tracer.From
				instance.To = Vector2.new(vector.X, vector.Y)
				
				-- print('Tracer Running')
			elseif player.Character == nil then
				tracer:Destroy() 
			end
			
			task.wait(data.UpdateSpeed)
		end)
		
		library.drawings.tracers[tracer.i] = tracer
		return tracer
	end
	
	--// BOXES \\-------------------------------------------------------
	if esp_type == 'Box' then
		local box, defaults, connections = { i = #library.drawings.boxes+1 }, { -- <table>
			Enabled = true, -- <bool>
			Outline = false, -- <bool>
			Color = Color3.fromRGB(255, 255, 255), -- <color3>
			OutlineColor = Color3.fromRGB(0, 0, 0), -- <color3>
			UpdateSpeed = 0,
		}, {}

		local data = overwrite(defaults, ... or {})
		
		local lines = {
			[1] = Drawing.new('Line'),
			[2] = Drawing.new('Line'),
			[3] = Drawing.new('Line'),
			[4] = Drawing.new('Line'),
		}
		
		local outlines = {
			[1] = Drawing.new('Line'),
			[2] = Drawing.new('Line'),
			[3] = Drawing.new('Line'),
			[4] = Drawing.new('Line'),
		}
		
		for _, line in pairs(lines) do
			line.Visible = data.Enabled
			line.Color = data.Color
		end
		
		for _, line in pairs(outlines) do
			line.Visible = data.Outline
			line.Visible = data.Enabled
			line.Color = data.OutlineColor
		end
		
		function box:Hide()
			for _, line in pairs(lines) do 
				line.Visible = false 
			end

			for _, line in pairs(outlines) do 
				line.Visible = false 
			end
		end
		
		function box:Show()
			for _, line in pairs(lines) do 
				line.Visible = true 
			end
			
			for _, line in pairs(outlines) do 
				line.Visible = true 
			end
		end
		
		function box:Update(...)
			data = overwrite(data, ... or {})
			data.UpdateSpeed = data.UpdateSpeed

			for _, line in pairs(lines) do
				line.Visible = data.Enabled
				line.Color = data.Color
			end

			for _, line in pairs(outlines) do
				line.Visible = data.Outline
				line.Visible = data.Enabled
				line.Color = data.OutlineColor
			end
		end
		
		function box:Destroy()
			for _, line in pairs(lines) do
				line:Remove()
			end
			
			for _, line in pairs(outlines) do
				line:Remove()
			end
			
			connections['RenderStepped']:Disconnect()
			table.remove(library.drawings.boxes[box.i])
			warn(`! Destroyed Box#{box.i}`)
		end
		
		connections['RenderStepped'] = run.Stepped:Connect(function()
			local char = player.character

			if char then
				local root = char.HumanoidRootPart or char:WaitForChild('HumanoidRootPart')
				local _, on_screen = workspace.CurrentCamera:WorldToViewportPoint(root.Position)

				for _, line in pairs(outlines) do
					line.Visible = data.Outline
				end
				
				if on_screen then box:Show() else box:Hide() end

				local vectors = {
					look_vector = root.CFrame.LookVector,
					right_vector = root.CFrame.RightVector,
					up_vector = root.CFrame.UpVector,
				}

				local bound_positions = {}
				bound_positions[1], _ = workspace.CurrentCamera:WorldToViewportPoint(root.Position + vectors.look_vector * 0.25 + vectors.right_vector * -2 + vectors.up_vector * -2)
				bound_positions[2], _ = workspace.CurrentCamera:WorldToViewportPoint(root.Position + vectors.look_vector * 0.25 + vectors.right_vector * -2 + vectors.up_vector * 2)
				bound_positions[3], _ = workspace.CurrentCamera:WorldToViewportPoint(root.Position + vectors.look_vector * 0.25 + vectors.right_vector * 2 + vectors.up_vector * 2)
				bound_positions[4], _ = workspace.CurrentCamera:WorldToViewportPoint(root.Position + vectors.look_vector * 0.25 + vectors.right_vector * 2 + vectors.up_vector * -2)

				outlines[1].From = Vector2.new(bound_positions[1].X, bound_positions[1].Y)
				outlines[2].From = Vector2.new(bound_positions[2].X, bound_positions[2].Y)
				outlines[3].From = Vector2.new(bound_positions[3].X, bound_positions[3].Y)
				outlines[4].From = Vector2.new(bound_positions[4].X, bound_positions[4].Y)
				outlines[1].To = Vector2.new(bound_positions[2].X, bound_positions[2].Y)
				outlines[2].To = Vector2.new(bound_positions[3].X, bound_positions[3].Y)
				outlines[3].To = Vector2.new(bound_positions[4].X, bound_positions[4].Y)
				outlines[4].To = Vector2.new(bound_positions[1].X, bound_positions[1].Y)

				lines[1].From = Vector2.new(bound_positions[1].X, bound_positions[1].Y)
				lines[2].From = Vector2.new(bound_positions[2].X, bound_positions[2].Y)
				lines[3].From = Vector2.new(bound_positions[3].X, bound_positions[3].Y)
				lines[4].From = Vector2.new(bound_positions[4].X, bound_positions[4].Y)
				lines[1].To = Vector2.new(bound_positions[2].X, bound_positions[2].Y)
				lines[2].To = Vector2.new(bound_positions[3].X, bound_positions[3].Y)
				lines[3].To = Vector2.new(bound_positions[4].X, bound_positions[4].Y)
				lines[4].To = Vector2.new(bound_positions[1].X, bound_positions[1].Y)
			elseif char == nil then
				box:Destroy()
			end

			task.wait(data.UpdateSpeed)
		end)
		
		library.drawings.boxes[box.i] = box
		return box
	end
	
	--// SKELETONS \\---------------------------------------------------
	if esp_type == 'Skeleton' then
		local skeleton, defaults, connections = { i = #drawings.skeletons+1 }, { -- <table>
			Enabled = true,
			Color = Color3.fromRGB(255, 255, 255), -- <color3>
			Thickness = 1, -- <number>
			UpdateSpeed = 0, -- <number>
		}, {}

		local data = overwrite(defaults, ... or {})
		
		local function getWorldVector2(attachment)
			local camera = workspace.CurrentCamera
			local vector, _ = camera:WorldToViewportPoint(attachment.WorldPosition)
			return Vector2.new(vector.X, vector.Y)
		end

		local function newLine()
			local drawing = Drawing.new('Line')
			drawing.Visible = true
			drawing.Color = data.Color
			drawing.Thickness = data.Thickness

			return drawing
		end
		
		--> Draw Adornment
		local line_adornment = Instance.new('LineHandleAdornment')
		line_adornment.Length = 2
		line_adornment.Thickness = 2
		line_adornment.ZIndex = 999
		line_adornment.Color3 = data.Color
		line_adornment.AlwaysOnTop = true
		
		--> Create lines
		local lines = {
			--> Body
			['Head'] = newLine(),
			['Waist'] = newLine(),
			
			--> Left arm
			['LeftHand'] = newLine(),
			['LeftShoulder'] = newLine(),
			['LeftArmJoint'] = newLine(),
			
			--> Right arm
			['RightHand'] = newLine(),
			['RightShoulder'] = newLine(),
			['RightArmJoint'] = newLine(),
			
			--> Left leg
			['LeftFoot'] = newLine(),
			['LeftHip'] = newLine(),
			['LeftWaistJoint'] = newLine(),
			
			--> Right leg
			['RightFoot'] = newLine(),
			['RightHip'] = newLine(),
			['RightWaistJoint'] = newLine(),
		}  
		
		--> Functions
		function skeleton:Hide()
			for _, line in pairs(lines) do
				line.Visible = false
			end
		end
		
		function skeleton:Show()
			for _, line in pairs(lines) do
				line.Visible = true
			end
		end
		
		function skeleton:Update(...)
			local new_data = ...
			data = overwrite(data, new_data or {})
			data.UpdateSpeed = new_data.UpdateSpeed
			
			for _, line in pairs(lines) do
				line.Color = data.Color
				line.Thickness = data.Thickness
			end
		end
		
		function skeleton:Destroy()
			line_adornment:Destroy()
			
			for _, line in pairs(lines) do
				line:Remove()
			end
			
			connections['RenderStepped']:Disconnect()
			table.remove(library.drawings.skeletons[skeleton.i])
			warn(`! Destroyed Skeleton#{skeleton.i}`)
		end

		connections['RenderStepped'] = run.Stepped:Connect(function()
			local char = player.Character

			if char then
				pcall(function()
					line_adornment.Parent = char.UpperTorso
					line_adornment.Adornee = char.UpperTorso

					local root = char.HumanoidRootPart or char:WaitForChild('HumanoidRootPart')
					local _, on_screen = workspace.CurrentCamera:WorldToViewportPoint(root.Position)

					--> Get Attachments
					local attachments = {
						--> Head <-------------------------------------------------------------
						Head = char["Head"]["HatAttachment"],
						Neck = char["Head"]["NeckRigAttachment"],

						--> Hip <--------------------------------------------------------------
						Waist = char["LowerTorso"]["WaistRigAttachment"],

						--> Left Arm <---------------------------------------------------------
						LeftHand = char["LeftHand"]["LeftGripAttachment"],
						LeftElbow = char["LeftUpperArm"]["LeftElbowRigAttachment"],
						LeftShoulder = char["LeftUpperArm"]["LeftShoulderAttachment"],

						-- Right Arm
						RightHand = char["RightHand"]["RightGripAttachment"],
						RightElbow = char["RightUpperArm"]["RightElbowRigAttachment"],
						RightShoulder = char["RightUpperArm"]["RightShoulderAttachment"],

						--> Left Leg <---------------------------------------------------------
						LeftFoot = char["LeftFoot"]["LeftFootAttachment"],
						LeftKnee = char["LeftLowerLeg"]["LeftKneeRigAttachment"],
						LeftHip = char["LowerTorso"]["LeftHipRigAttachment"],

						--> Right Leg <--------------------------------------------------------
						RightFoot = char["RightFoot"]["RightFootAttachment"],
						RightKnee = char["RightLowerLeg"]["RightKneeRigAttachment"],
						RightHip = char["RightUpperLeg"]["RightHipRigAttachment"],
					}
					
					if on_screen and data.Enabled then
						--> Head <-------------------------------------------------------------
						lines.Head.From = getWorldVector2(attachments.Neck)
						lines.Head.To = getWorldVector2(attachments.Head)

						lines.Waist.From = getWorldVector2(attachments.Neck)
						lines.Waist.To = getWorldVector2(attachments.Waist)
						
						--> Left Arm <---------------------------------------------------------
						lines.LeftHand.From = getWorldVector2(attachments.LeftHand)
						lines.LeftHand.To = getWorldVector2(attachments.LeftElbow)
						lines.LeftShoulder.From = getWorldVector2(attachments.LeftElbow)
						lines.LeftShoulder.To = getWorldVector2(attachments.LeftShoulder)
						lines.LeftArmJoint.From = getWorldVector2(attachments.LeftShoulder)
						lines.LeftArmJoint.To = getWorldVector2(attachments.Neck)
						
						--> Right Arm <--------------------------------------------------------
						lines.RightHand.From = getWorldVector2(attachments.RightHand)
						lines.RightHand.To = getWorldVector2(attachments.RightElbow)
						lines.RightShoulder.From = getWorldVector2(attachments.RightElbow)
						lines.RightShoulder.To = getWorldVector2(attachments.RightShoulder)
						lines.RightArmJoint.From = getWorldVector2(attachments.RightShoulder)
						lines.RightArmJoint.To = getWorldVector2(attachments.Neck)

						--> Left Leg <---------------------------------------------------------
						lines.LeftFoot.From = getWorldVector2(attachments.LeftFoot)
						lines.LeftFoot.To = getWorldVector2(attachments.LeftKnee)
						lines.LeftHip.From = getWorldVector2(attachments.LeftKnee)
						lines.LeftHip.To = getWorldVector2(attachments.LeftHip)
						lines.LeftWaistJoint.From = getWorldVector2(attachments.LeftHip)
						lines.LeftWaistJoint.To = getWorldVector2(attachments.Waist)
						
						--> Right Leg <--------------------------------------------------------
						lines.RightFoot.From = getWorldVector2(attachments.RightFoot)
						lines.RightFoot.To = getWorldVector2(attachments.RightKnee)
						lines.RightHip.From = getWorldVector2(attachments.RightKnee)
						lines.RightHip.To = getWorldVector2(attachments.RightHip)
						lines.RightWaistJoint.From = getWorldVector2(attachments.RightHip)
						lines.RightWaistJoint.To = getWorldVector2(attachments.Waist)
						
						skeleton:Show()
					else 
						skeleton:Hide() 
					end
				end)
			elseif char == nil then
				skeleton:Destroy()
			end
			
			task.wait(data.UpdateSpeed)
		end)
		
		library.drawings.skeletons[skeleton.i] = skeleton
		return skeleton
	end
end

-- [ CONNECTIONS ]----------------------------------------------------------------------------------
game.Close:Connect(clearAllDrawings)

return library
