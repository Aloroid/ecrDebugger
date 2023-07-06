local RunService = game:GetService("RunService")

local Plugin = script.Parent.Parent
local Packages = Plugin.Parent

local CubeCat = require(Packages.CubeCat)
local Fusion = require(Packages.Fusion)
local State = require(Plugin.State)

local ServerMessagingService = CubeCat.CreateService({
	Name = "ServerMessagingService",
})

local debugger_stop
local paused = Fusion.Value(false)

ServerMessagingService.IsPaused = paused
ServerMessagingService.Paused = false

function ServerMessagingService:ToggleDebuggerPaused(result: boolean)
	debugger_stop:FireServer(result)
	print("setting server state to", result)
end

function ServerMessagingService:Init()
	local function updatePaused(bool)
		paused:set(bool)
		ServerMessagingService.Paused = bool
	end

	if RunService:IsServer() then
		debugger_stop = Instance.new("RemoteEvent", script)
		debugger_stop.OnServerEvent:Connect(function(player, bool)
			if
				table.find(State.pauseWhitelist, player.UserId)
				or table.find(State.pauseWhitelist, player.Name)
				or RunService:IsStudio()
			then
				updatePaused(bool)
				debugger_stop:FireAllClients(bool)
			end
		end)
	else
		debugger_stop = script:WaitForChild("RemoteEvent")
		debugger_stop.OnClientEvent:Connect(updatePaused)
	end
end

return ServerMessagingService
