--[[
	SystemWatch is a component used to watch changes made by a system.
	
]]

local Plugin = script.Parent.Parent.Parent
local Packages = Plugin.Parent

local CubeCat = require(Packages.CubeCat)
local Fusion = require(Packages.Fusion)

--local PerformanceGraph = require(script.PerformanceGraph)
local Watch = require(script.Watch)

local Value = Fusion.Value
local Children = Fusion.Children
local Ref = Fusion.Ref

type CanBeState<T> = Fusion.CanBeState<T>
export type SystemPreview = {
	Position: CanBeState<UDim2>?,
	Size: CanBeState<UDim2>?,
	AnchorPoint: CanBeState<Vector2>?,

	SystemName: string,

	[any]: any,
}

local function SystemPreview(props: SystemPreview)
	local systemName = props.SystemName
	local reference = Value()

	local SystemPreview = CubeCat.Components.Widget({

		Title = systemName,

		WidgetId = `system:{systemName}`,

		InitialDockState = Enum.InitialDockState.Float,
		InitialEnabled = true,
		OverrideEnabled = true,
		FloatingSize = Vector2.new(400, 200),
		MinimumSize = Vector2.new(300, 200),

		DisplayOrder = 1100,

		OnClose = function()
			reference:get():Destroy()
		end,

		[Ref] = reference,

		[Children] = CubeCat.Components.Background({

			[Children] = {

				-- PerformanceGraph consumes too much performance as of now of what should be appropiate.
				--TODO: Make Graph consume less frame time (try reducing re-renders)
				--[[PerformanceGraph {
					SystemName = systemName,
				},]]

				Watch({
					SystemName = systemName,
				}),
			},
		}),
	})

	return SystemPreview
end

return SystemPreview
