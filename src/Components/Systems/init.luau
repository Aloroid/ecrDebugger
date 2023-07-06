local Plugin = script.Parent.Parent
local Packages = Plugin.Parent

local CubeCat = require(Packages.CubeCat)
local Fusion = require(Packages.Fusion)

local LoopControl = require(script.LoopControl)
local PerformanceGraph = require(script.PerformanceGraph)
local SystemList = require(script.SystemList)

local Children = Fusion.Children

type CanBeState<T> = Fusion.CanBeState<T>
export type entityView = {
	Position: CanBeState<UDim2>?,
	Size: CanBeState<UDim2>?,
	AnchorPoint: CanBeState<Vector2>?,

	Enabled: CanBeState<boolean>?,

	[any]: any,
}

local function entityView(props: entityView)
	local entityView = CubeCat.Components.Background({

		Padding = 0,
		ListPadding = 8,

		[Children] = {

			PerformanceGraph({}),

			LoopControl({}),

			SystemList({}),
		},
	})

	return entityView
end

return entityView
