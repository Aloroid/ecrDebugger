--[[
	SystemWatch is a component used to watch changes made by a system.
	
]]

local Plugin = script.Parent.Parent.Parent.Parent
local Packages = Plugin.Parent
local Services = Plugin.Services
local Components = Plugin.Components

local CubeCat = require(Packages.CubeCat)
local Fusion = require(Packages.Fusion)
local SystemsService = require(Services.SystemsService)

local Graph = require(Components.Graph)

local Value = Fusion.Value
local Computed = Fusion.Computed
local Children = Fusion.Children

local unwrap = CubeCat.Util.unwrap

type CanBeState<T> = Fusion.CanBeState<T>
export type PerformanceGraph = {
	Position: CanBeState<UDim2>?,
	Size: CanBeState<UDim2>?,
	AnchorPoint: CanBeState<Vector2>?,

	SystemName: string,

	[any]: any,
}

local function PerformanceGraph(props: PerformanceGraph)
	local systemName = props.SystemName
	local systemData = Computed(function()
		return unwrap(SystemsService.Value)[systemName]
	end)

	local selected = Value("Seconds")

	local PerformanceGraph = CubeCat.Components.Pane({

		PaneText = "Performance Over Time",

		[Children] = CubeCat.Components.Background({

			NoPadding = true,

			[Children] = {
				CubeCat.Components.Dropdown({

					DropdownItems = {
						"Frames",
						"Seconds",
						"Minutes",
					},

					Selected = selected,
				}),

				Graph({

					GraphValues = Computed(function()
						if unwrap(selected) == "Seconds" then
							return unwrap(unwrap(systemData).timeTakenGraphSeconds)
						elseif unwrap(selected) == "Frames" then
							return unwrap(unwrap(systemData).timeTaken)
						else
							return unwrap(unwrap(systemData).timeTakenGraphMinutes)
						end
					end),
				}),
			},
		}),
	})

	return PerformanceGraph
end

return PerformanceGraph
