--[[ gui safe loader ]]--
--[[    doom.lol     ]]--
safe_load = function(instance : Instance, encrypt_names : boolean)
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

return safe_load
