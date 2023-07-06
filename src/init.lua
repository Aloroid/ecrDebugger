--[[
	Starts all the modules and such
	
]]

local Packages = script.Parent
local Services = script.Services

local CubeCat = require(Packages.CubeCat)
local State = require(script.State)

return function(state: typeof(State))
	assert(state.components, "no components table, components is required")
	assert(state.registry, "no registry, registry is required")

	for key, value in state do
		State[key] = value
	end

	CubeCat.AddServices(Services:GetChildren())
	CubeCat.Start()

	local SystemsService = require(Services.SystemsService)
	local SystemWatchService = require(Services.SystemWatchService)
	local ServerMessagingService = require(Services.ServerMessagingService)
	local OpenedService = require(Services.OpenedService)

	return {

		-- Display

		toggle = function() OpenedService:Toggle() end,

		-- Systems

		--appends the given data into the system's record
		addSystemData = function(systemName: string, order: number, timeTaken: number)
			SystemsService:AddSystem(systemName, order, timeTaken)
		end,

		--resets the time for the given system
		resetTime = function(systemName: string) SystemsService:ResetTime(systemName) end,

		--removes a system from the debugger and any of it's data
		remove = function(systemName: string) SystemsService:Remove(systemName) end,

		--displays all the current received system data into the debugger
		push = function() SystemsService:Push() end,

		--clears all the logged data of systems (not watches)
		clear = function() SystemsService:Clear() end,

		getPaused = function() return ServerMessagingService.Paused end,

		-- Watches

		--creates a new watch for a system
		createWatch = function(systemName: string) return SystemWatchService:CreateWatch(systemName) end,

		--gets a existing watch or creates a new one
		getWatch = function(systemName: string) return SystemWatchService:GetWatch(systemName) end,
	}
end
