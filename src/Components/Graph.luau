--[[
	SystemWatch is a component used to watch changes made by a system.
	
]]

local Plugin = script.Parent.Parent
local Packages = Plugin.Parent

local CubeCat = require(Packages.CubeCat)
local Fusion = require(Packages.Fusion)

local getAverage = require(Plugin.Utility.getAverage)

local New = Fusion.New
local Computed = Fusion.Computed
local Children = Fusion.Children

local unwrap = CubeCat.Util.unwrap
local Theme = CubeCat.Util.Theme

type CanBeState<T> = Fusion.CanBeState<T>
export type Graph = {
	Position: CanBeState<UDim2>?,
	Size: CanBeState<UDim2>?,
	AnchorPoint: CanBeState<Vector2>?,

	GraphValues: CanBeState<{ CanBeState<number> }>,

	[any]: any,
}

local function Graph(props: Graph)
	--TODO: Optimize Graphs, Graphs currently shit on performance.
	local graphSize = Computed(function()
		return #unwrap(props.GraphValues)
	end)
	local bounds = Computed(function()
		local highest, lowest = -math.huge, math.huge
		for _, value in unwrap(props.GraphValues) do
			if value > highest then
				highest = value
			elseif value < lowest then
				lowest = value
			end
		end

		return { highest = highest, lowest = lowest }
	end)

	local highestBounds = Computed(function()
		return unwrap(bounds).highest
	end)

	local average = Computed(function()
		return getAverage(unwrap(props.GraphValues))
	end)

	local lowest = Computed(function()
		local lowestBound = unwrap(bounds).lowest
		local highestBound = unwrap(bounds).highest
		local average = unwrap(average)
		local delta = highestBound - average

		return math.min(lowestBound, average - delta * 0.5)
	end)

	local graphValues = Computed(function()
		local t = {}
		for index = 1, unwrap(graphSize) do
			table.insert(
				t,
				Computed(function()
					local value = Computed(function()
						return unwrap(unwrap(props.GraphValues)[index])
					end)

					return New("Frame")({

						Position = Computed(function()
							return UDim2.fromScale((unwrap(graphSize) - index) / unwrap(graphSize), 1)
						end),
						Size = Computed(function()
							return UDim2.fromScale(
								1 / unwrap(graphSize),
								((unwrap(value) or 0) - unwrap(lowest)) / (unwrap(highestBounds) - unwrap(lowest))
							)
						end),
						AnchorPoint = Vector2.new(0, 1),

						BackgroundColor3 = Theme(Enum.StudioStyleGuideColor.LinkText),

						[Children] = New("UIGradient")({
							Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.new(0.5, 0.5, 0.5)),
							Rotation = 90,
						}),
					})
				end, Fusion.cleanup)
			)
		end
		print("pain")
		return t
	end, Fusion.cleanup)

	local Graph = CubeCat.Components.Background({

		Size = UDim2.fromScale(1, 0.5),

		NoList = true,
		ClipsDescendants = true,

		--FIXME
		[Children] = graphValues,
	})

	return Graph
end

return Graph
