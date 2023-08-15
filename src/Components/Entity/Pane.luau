local RunService = game:GetService("RunService")

local Plugin = script.Parent.Parent.Parent
local Services = Plugin.Services
local Packages = Plugin.Parent

local CubeCat = require(Packages.CubeCat)
local Fusion = require(Packages.Fusion)
local State = require(Plugin.State)
local ecr = require(Packages.ecr)

local registry = State.registry

local EntityQueryService = require(Services.EntityQueryService)

local Out = Fusion.Out
local Value = Fusion.Value
local Computed = Fusion.Computed
local Children = Fusion.Children
local ForPairs = Fusion.ForPairs
local Runtime = CubeCat.Runtime
local Cleanup = Fusion.Cleanup

local unwrap = CubeCat.Util.unwrap
local stripProps = CubeCat.Util.stripProps

type CanBeState<T> = Fusion.CanBeState<T>
export type entityPane = {
	Position: CanBeState<UDim2>?,
	Size: CanBeState<UDim2>?,
	AnchorPoint: CanBeState<Vector2>?,

	Query: Fusion.StateObject<string>,

	[any]: any,
}

local COMPONENT_ONLY_PROPERTIES = {
	"Query",
}

local function resizeable(key: string)
	return CubeCat.Components.Background({
		BackgroundColor = Enum.StudioStyleGuideColor.Button,

		VerticalAlignment = Enum.VerticalAlignment.Center,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,

		NoPadding = true,

		[Children] = {

			CubeCat.Components.Text({
				AutomaticSize = Enum.AutomaticSize.None,
				Size = UDim2.fromScale(1, 1),

				Text = key,
				TextTruncate = Enum.TextTruncate.AtEnd,
			}),

			CubeCat.Components.Border({}),
		},
	})
end

local function fancyfy(value: unknown)
	if typeof(value) == "CFrame" then
		return `[{fancyfy(value.Position)}] [{fancyfy(value.XVector)}] [{fancyfy(value.YVector)}] [{fancyfy(value.ZVector)}]`
	elseif typeof(value) == "Vector3" then
		local new = value * 100
		local x, y, z = math.round(new.X) / 100, math.round(new.Y) / 100, math.round(new.Z) / 100
		return string.format("%s, %s, %s", x, y, z)
	else
		return tostring(value)
	end
end

local function entityPane(props: entityPane)
	local queryString = props.Query
	local queryResults = Computed(function()
		-- This Computed will get the queried entities and convert them in a
		-- easy to-use format.

		local ok, included, excluded = EntityQueryService:parseQuery(unwrap(queryString))
		local result = {
			included = {} :: { [string]: true },
			excluded = {} :: { [string]: true },
		}

		if ok then
			result.included = included
			result.excluded = excluded
		end

		return result
	end)
	local ids = Value({})
	local parent = Value()
	local isVisible = CubeCat.Runtime(function()
		local object: Instance? = unwrap(parent)

		if object == nil then return false end
		local screenGui = object:FindFirstAncestorWhichIsA("LayerCollector")
		if screenGui == nil then return false end

		return screenGui.Enabled
	end)

	local idSize = Value(0.1)
	local sizes = Computed(function()
		local sizes = { idSize }
		local total = 0

		for _ in unwrap(queryResults).included do
			total += 1
		end

		for i = 1, total do
			-- we tell it to not capture dependencies as this is a one-time
			-- thing for the initial sizes.
			table.insert(sizes, Value((1 - unwrap(idSize, false)) / total))
		end

		if total == 0 then table.insert(sizes, Value(1)) end

		return sizes
	end)
	local minSizes = Computed(function()
		local sizes = {}
		local total = 1

		for _ in unwrap(queryResults).included do
			total += 1
		end

		for i = 1, total do
			table.insert(sizes, 0.01)
		end

		if total == 1 then table.insert(sizes, 1) end

		return sizes
	end)
	local orderedComponents = Computed(function()
		local ordered = {}

		for name in unwrap(queryResults).included do
			table.insert(ordered, name)
		end

		return ordered
	end)

	-- component inside the component
	local function field(id: Fusion.Value<number>, index: number)
		return CubeCat.Components.Background({

			Size = Computed(function() return UDim2.fromScale(unwrap(unwrap(sizes)[index]), 1) end),
			Position = Computed(function()
				local total = 0

				for i = 1, index - 1 do
					total += unwrap(unwrap(sizes)[i])
				end

				return UDim2.fromScale(total, 0)
			end),

			BackgroundColor = Enum.StudioStyleGuideColor.TableItem,

			VerticalAlignment = Enum.VerticalAlignment.Center,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			NoPadding = true,

			[Children] = {

				CubeCat.Components.Border({}),
				CubeCat.Components.Text({
					AutomaticSize = Enum.AutomaticSize.None,
					Size = UDim2.fromScale(1, 1),

					Text = if index == 1
						then Computed(function()
							local id, version = ecr.extract(unwrap(id))
							return `{id}:{version}`
						end)
						else Runtime(function()
							if unwrap(isVisible) == false then return "" end

							local orderedName = unwrap(orderedComponents)[index - 1]
							local included = unwrap(queryResults).included
							local component = included[orderedName]

							if component == nil then return "-" end

							return fancyfy(registry:try_get(unwrap(id), component))
						end),
					TextTruncate = Enum.TextTruncate.AtEnd,
				}),
			},
		})
	end

	local entityPane = CubeCat.Components.Background({

		BackgroundColor = Enum.StudioStyleGuideColor.TableItem,

		ListPadding = 0,
		NoPadding = true,

		Visible = isVisible,

		[Out("Parent")] = parent,

		[Children] = {

			CubeCat.Components.SplitPane({

				Size = UDim2.new(1, 0, 0, 24),

				Sizes = sizes,
				MinSizes = minSizes,

				ClipsDescendants = true,

				[Children] = Computed(function()
					local children = {
						resizeable("Id"),
					}

					for _, name in unwrap(orderedComponents) do
						table.insert(children, resizeable(unwrap(name)))
					end

					if #unwrap(orderedComponents) == 0 then table.insert(children, resizeable("")) end
					table.insert(children, CubeCat.Components.Border({}))

					return children
				end),
			}),

			CubeCat.Components.List({

				Size = UDim2.new(1, 0, 1, -24),

				BackgroundColor = Enum.StudioStyleGuideColor.TableItem,

				StreamIn = function(index)
					local id = Computed(function()
						local ids = unwrap(ids)
						--print(ids[unwrap(index)], unwrap(index))
						return ids[#ids - unwrap(index)] or ecr.null
					end)

					return CubeCat.Components.Background({
						Size = UDim2.new(1, 0, 0, 24),
						Position = Computed(function() return UDim2.fromOffset(0, unwrap(index) * 24) end),

						BackgroundTransparency = 1,
						NoList = true,
						NoPadding = true,

						Visible = Computed(function() return unwrap(id) ~= ecr.null end),

						[Children] = {
							field(id, 1),
							ForPairs(
								orderedComponents,
								function(index) return index, field(id, index + 1) end,
								Fusion.cleanup
							),
							if #unwrap(orderedComponents) == 0 then field(id, 2) else nil,
						},
					})
				end,
				ItemSize = 24,

				MaxItems = Computed(function()
					--print(#unwrap(ids))
					return #unwrap(ids)
				end),

				[Children] = CubeCat.Components.Border({}),
			}),
		},

		[Cleanup] = RunService.Heartbeat:Connect(function()
			local queryResults = unwrap(queryResults)
			local collectedIds = {}

			if unwrap(isVisible) == false then return end

			for id in EntityQueryService:getQuery(queryResults.included, queryResults.excluded) do
				print(type(id), id)
				table.insert(collectedIds, id)
			end

			ids:set(collectedIds)
		end),
	})

	return Fusion.Hydrate(entityPane)(stripProps(props, COMPONENT_ONLY_PROPERTIES))
end

return entityPane
