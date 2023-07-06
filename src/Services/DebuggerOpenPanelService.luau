local RunService = game:GetService("RunService")
local Plugin = script.Parent.Parent
local Packages = Plugin.Parent
local Components = Plugin.Components

local CubeCat = require(Packages.CubeCat)
local OpenedService = require(script.Parent.OpenedService)

local DebuggerOpenPanelService = CubeCat.CreateService({
	Name = "DebuggerOpenPanelService",
})

function DebuggerOpenPanelService:Init()
	if RunService:IsServer() then
		return
	end

	require(Components.mainView)({
		Enabled = OpenedService.Enabled,
	})
end

return DebuggerOpenPanelService
