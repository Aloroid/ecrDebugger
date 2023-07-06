local Plugin = script.Parent.Parent
local Packages = Plugin.Parent

local CubeCat = require(Packages.CubeCat)
local Fusion = require(Packages.Fusion)

local OpenPanelService = CubeCat.CreateService({
	Name = "OpenPanelService",
})

local enabled = Fusion.Value(false)

OpenPanelService.Enabled = enabled

function OpenPanelService:Toggle() enabled:set(not enabled:get()) end

return OpenPanelService
