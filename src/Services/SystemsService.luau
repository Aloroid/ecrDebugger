--[[
	This service accepts data of the current state of the systems
	
]]

local Plugin = script.Parent.Parent
local Packages = Plugin.Parent

local CubeCat = require(Packages.CubeCat)
local Fusion = require(Packages.Fusion)

local getAverage = require(Plugin.Utility.getAverage)

local SystemsService = CubeCat.CreateService({
	Name = "SystemsService",
})

local systemData = Fusion.Value({})

type Value<T> = Fusion.Value<T>
SystemsService.Value = systemData :: {
	[string]: {
		name: Value<string>,
		order: Value<number>,
		timeTaken: Value<{ number }>,

		timeTakenGraphSeconds: Value<{ number }>,
		timeTakenGraphMinutes: Value<{ number }>,
	},
}

function SystemsService:AddSystem(systemName: string, order: number, timeTaken: number)
	local t = systemData:get(false)
	local existing = t[systemName]

	if existing == nil then
		t[systemName] = {
			name = Fusion.Value(systemName),
			order = Fusion.Value(order),
			timeTaken = Fusion.Value({ timeTaken }),
			anomalies = Fusion.Value({}),

			timeTakenGraphSeconds = Fusion.Value({ timeTaken }),
			timeTakenGraphMinutes = Fusion.Value({ timeTaken }),

			counter = math.floor(time()),
		}
	else
		existing.name:set(systemName)
		existing.order:set(order)
		local timeTakenList = existing.timeTaken:get()
		local timeTakenSeconds = existing.timeTakenGraphSeconds:get()
		local timeTakenMinutes = existing.timeTakenGraphMinutes:get()
		local average = getAverage(timeTakenList)

		-- stores a graph
		if math.floor(time()) % 2 == 0 and existing.counter ~= math.floor(time()) then
			table.remove(timeTakenSeconds, 60)
			table.insert(timeTakenSeconds, 1, average)
			existing.timeTakenGraphSeconds:set(timeTakenSeconds)
		end

		-- stores a graph for every 2 minutes
		if math.floor(time()) % 120 == 0 and existing.counter ~= math.floor(time()) then
			table.remove(timeTakenMinutes, 60)
			table.insert(timeTakenMinutes, 1, getAverage(timeTakenSeconds))
			existing.timeTakenGraphMinutes:set(timeTakenMinutes)
		end

		existing.counter = math.floor(time())

		table.remove(timeTakenList, 60)
		table.insert(timeTakenList, 1, timeTaken)

		existing.timeTaken:set(timeTakenList)
	end
end

function SystemsService:ResetTime(systemName: string)
	systemData:get(false)[systemName].timeTaken:set({ systemData:get(false)[systemName].timeTaken:get(false)[1] })
end

function SystemsService:Push()
	systemData:set(systemData:get(false))
end

function SystemsService:Remove(systemName: string)
	systemData:get(false)[systemName].disabled:set(true)
end

function SystemsService:Clear()
	systemData:set({})
end

return SystemsService
