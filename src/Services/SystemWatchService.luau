--[[
	This service allows for watching a specific system.
	
]]

local Plugin = script.Parent.Parent
local Packages = Plugin.Parent

local CubeCat = require(Packages.CubeCat)
local Fusion = require(Packages.Fusion)
local State = require(Plugin.State)

local registry = State.registry
local components = State.components

local SystemWatchService = CubeCat.CreateService({
	Name = "SystemWatchService",
})

local Value = Fusion.Value

local watches = {}

SystemWatchService.WatchEnabled = not not (State.hookAfterSystemRun and State.hookBeforeSystemRun)

function SystemWatchService:GetLogs(systemName: string)
	local logs = {}
	local connections = {}

	local function log(tag: string, component: string)
		return function(id: number, value: unknown)
			table.insert(logs, { tag = tag, id = id, component = component, value = value })
		end
	end

	for key: string, componentId: number in components do
		table.insert(connections, registry:added(componentId):connect(log("added", key)))
		table.insert(connections, registry:changed(componentId):connect(log("changed", key)))
		table.insert(connections, registry:removing(componentId):connect(log("removed", key)))
	end

	return logs, function()
		for _, connection in connections do
			connection:disconnect()
		end
	end
end

function SystemWatchService:CreateWatch(systemName: string)
	local watch = {

		name = systemName,
		active = false,

		frames = Value({}),

		totalFrames = Value(0),
	}

	local frame, stop
	local cleanupBeforeHook
	local cleanupAfterHook

	local function startLogging()
		watch.totalFrames:set(watch.totalFrames:get(false) + 1)
		frame, stop = SystemWatchService:GetLogs(systemName)
	end

	local function finishLogging(timeTaken: number)
		stop()

		if #frame == 0 then return end

		local frames = watch.frames
		table.insert(frames:get(false), {
			frame = watch.totalFrames:get(false),
			timeTaken = timeTaken,
			logs = frame,
		})
		frames:set(frames:get(false))
	end

	function watch:disable()
		if watch.active == false then return end
		watch.active = false

		cleanupBeforeHook()
		cleanupAfterHook()
	end

	function watch:enable()
		if watch.active == true then return end
		watch.active = true

		assert(State.hookBeforeSystemRun ~= nil, "No before hook for before a system started running")
		assert(State.hookAfterSystemRun ~= nil, "No after hook for after a system finished running")

		cleanupBeforeHook = State.hookBeforeSystemRun(systemName, startLogging)
		cleanupAfterHook = State.hookAfterSystemRun(systemName, finishLogging)
	end

	function watch:clear()
		watch.totalFrames:set(0)
		watch.frames:set({})
	end

	return watch
end

function SystemWatchService:GetWatch(systemName: string): typeof(SystemWatchService:CreateWatch(""))
	local watch = watches[systemName]

	if watch then return watch end

	watch = SystemWatchService:CreateWatch(systemName)
	watches[systemName] = watch
	return watch
end

function SystemWatchService:Init()
	if State.hookAfterSystemRun == nil or State.hookBeforeSystemRun == nil then
		warn("Unable to implement System Watch, No hooks for before and after a system runs.")
	end
end

return SystemWatchService
