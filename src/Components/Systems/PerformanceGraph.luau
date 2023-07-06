local Plugin = script.Parent.Parent.Parent
local Services = Plugin.Services
local Packages = Plugin.Parent

local CubeCat = require(Packages.CubeCat)
local Fusion = require(Packages.Fusion)
local SystemsService = require(Services.SystemsService)

local getAverage = require(Plugin.Utility.getAverage)
local getColor = require(Plugin.Utility.getColor)
local getSuffixSeconds = require(Plugin.Utility.getSuffixSeconds)

local New = Fusion.New
local Computed = Fusion.Computed
local Value = Fusion.Value
local ForValues = Fusion.ForValues
local Children = Fusion.Children
local OnEvent = Fusion.OnEvent

local unwrap = CubeCat.Util.unwrap

type CanBeState<T> = Fusion.CanBeState<T>
export type Graph = {
	Position: CanBeState<UDim2>?,
	Size: CanBeState<UDim2>?,
	AnchorPoint: CanBeState<Vector2>?,

	[any]: any,
}

local function PerformanceGraph(props: Graph)
	local runTime = Computed(function()
		local timeUsed = 0

		for name, system in unwrap(SystemsService.Value) do
			if unwrap(system.disabled) then
				continue
			end
			timeUsed += getAverage(unwrap(system.timeTaken, false))
		end

		return timeUsed
	end)

	local selected = Value({ name = "", order = 1, timeTaken = { 0 } })
	local isHoverSelected = true

	local PerformanceGraph = CubeCat.Components.Pane({

		PaneText = "Performance Graph",

		Size = UDim2.new(1, 0, 0, 140),

		[Children] = {

			CubeCat.Components.Text({

				Text = Computed(function()
					return `Run time: {getSuffixSeconds(unwrap(runTime))}`
				end),
			}),

			CubeCat.Components.Background({

				Size = UDim2.new(1, 0, 0, 48),

				ListPadding = 0,
				FillDirection = Enum.FillDirection.Horizontal,

				[Children] = ForValues(SystemsService.Value, function(value)
					return New("TextButton")({

						Size = Computed(function()
							return UDim2.fromScale(getAverage(unwrap(value.timeTaken)) / unwrap(runTime), 1)
						end),

						Visible = Computed(function()
							return not unwrap(value.disabled)
						end),

						BackgroundColor3 = Computed(function()
							return getColor(unwrap(value.order))
						end),

						[OnEvent("MouseEnter")] = function()
							if isHoverSelected == false then
								return
							end
							selected:set(value)
						end,

						[OnEvent("Activated")] = function()
							selected:set(value)
							isHoverSelected = false
						end,

						LayoutOrder = value.order,
					})
				end, Fusion.cleanup),
			}),

			CubeCat.Components.Text({

				Font = Enum.Font.SourceSansBold,

				Text = Computed(function()
					return `system: {unwrap(unwrap(selected).name)}`
				end),
				TextColor3 = Computed(function()
					return getColor(unwrap(unwrap(selected).order))
				end),
			}),

			CubeCat.Components.Text({

				Text = Computed(function()
					return `Run time: {getSuffixSeconds(getAverage(unwrap(unwrap(selected).timeTaken)))}`
				end),
			}),
		},
	})

	return PerformanceGraph
end

return PerformanceGraph
