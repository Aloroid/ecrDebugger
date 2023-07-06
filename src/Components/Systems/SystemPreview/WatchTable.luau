local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Plugin = script.Parent.Parent.Parent.Parent
local Services = Plugin.Services
local Packages = Plugin.Parent

local CubeCat = require(Packages.CubeCat)
local Fusion = require(Packages.Fusion)
local ecr = require(ReplicatedStorage.Packages.ecr)

local SystemWatchService = require(Services.SystemWatchService)

local Value = Fusion.Value
local Computed = Fusion.Computed
local Children = Fusion.Children

local unwrap = CubeCat.Util.unwrap
local stripProps = CubeCat.Util.stripProps

type CanBeState<T> = Fusion.CanBeState<T>
export type entityPane = {
	Position: CanBeState<UDim2>?,
	Size: CanBeState<UDim2>?,
	AnchorPoint: CanBeState<Vector2>?,

	SystemName: string,
	Frame: CanBeState<number>?,

	[any]: any,
}

local COMPONENT_ONLY_PROPERTIES = {
	"SystemName",
	"Frame",
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
	local systemName = props.SystemName
	local watch = SystemWatchService:GetWatch(systemName)
	local frame = props.Frame
	local currentFrame = Computed(function()
		return unwrap(watch.frames)[unwrap(frame)]
	end)

	local sizes = { Value(0.3), Value(0.1), Value(0.3), Value(0.3) }
	local minSizes = { 0.1, 0.1, 0.1, 0.1 }

	-- component inside the component
	local function field(id: Fusion.Value<number>, index: number)
		return CubeCat.Components.Background({

			Size = Computed(function()
				return UDim2.fromScale(unwrap(sizes[index]), 1)
			end),
			Position = Computed(function()
				local total = 0

				for i = 1, index - 1 do
					total += unwrap(sizes[i])
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

					Text = Computed(function()
						local id = unwrap(id) + 1
						local frame = unwrap(currentFrame)

						if frame == nil then
							return "err bad frame"
						end

						local log = frame.logs[id]

						if log == nil then
							return `err {id} no log`
						end

						if index == 1 then
							return log.tag
						elseif index == 2 then
							local up, low = ecr.extract(log.id)
							return `{up}:{low}`
						elseif index == 3 then
							return log.component
						elseif index == 4 then
							return fancyfy(log.value)
						end

						return "-"
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

		[Children] = {

			CubeCat.Components.SplitPane({

				Size = UDim2.new(1, 0, 0, 24),

				Sizes = sizes,
				MinSizes = minSizes,

				ClipsDescendants = true,

				[Children] = {
					resizeable("Action"),
					resizeable("Id"),
					resizeable("Component"),
					resizeable("Value"),
				},
			}),

			CubeCat.Components.List({

				Size = UDim2.new(1, 0, 1, -24),

				BackgroundColor = Enum.StudioStyleGuideColor.TableItem,

				StreamIn = function(index)
					return CubeCat.Components.Background({
						Size = UDim2.new(1, 0, 0, 24),
						Position = Computed(function()
							return UDim2.fromOffset(0, unwrap(index) * 24)
						end),

						BackgroundTransparency = 1,
						NoList = true,
						NoPadding = true,

						Visible = Computed(function()
							return unwrap(index) ~= ecr.null
						end),

						[Children] = {
							field(index, 1),
							field(index, 2),
							field(index, 3),
							field(index, 4),
						},
					})
				end,
				ItemSize = 24,

				MaxItems = Computed(function()
					if unwrap(currentFrame) == nil then
						return 0
					end

					return #unwrap(currentFrame).logs
				end),

				[Children] = CubeCat.Components.Border({}),
			}),
		},
	})

	return Fusion.Hydrate(entityPane)(stripProps(props, COMPONENT_ONLY_PROPERTIES))
end

return entityPane
