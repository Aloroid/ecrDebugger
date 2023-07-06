local Plugin = script.Parent.Parent.Parent
local Services = Plugin.Services
local Packages = Plugin.Parent

local CubeCat = require(Packages.CubeCat)
local Fusion = require(Packages.Fusion)
local SystemsService = require(Services.SystemsService)

local SystemPreview = require(script.Parent.SystemPreview)

local getAverage = require(Plugin.Utility.getAverage)
local getColor = require(Plugin.Utility.getColor)
local getSuffixSeconds = require(Plugin.Utility.getSuffixSeconds)

local New = Fusion.New
local Computed = Fusion.Computed
local ForValues = Fusion.ForValues
local Children = Fusion.Children
local OnEvent = Fusion.OnEvent

local unwrap = CubeCat.Util.unwrap

type CanBeState<T> = Fusion.CanBeState<T>
export type entityView = {
	Position: CanBeState<UDim2>?,
	Size: CanBeState<UDim2>?,
	AnchorPoint: CanBeState<Vector2>?,

	Enabled: CanBeState<boolean>?,

	[any]: any,
}

local function entityView(props: entityView)
	local entityView = CubeCat.Components.ScrollingFrame({

		Size = UDim2.new(1, 0, 1, -188),

		ListPadding = 4,

		[Children] = {

			ForValues(SystemsService.Value, function(value)
				return CubeCat.Components.Button({

					Name = value.name,
					Size = UDim2.new(1, 0, 0, 30),

					BackgroundColor = Enum.StudioStyleGuideColor.Button,
					BorderColor = Enum.StudioStyleGuideColor.Button,

					Text = Computed(function()
						return `{unwrap(value.name)}{if unwrap(value.disabled) then " (disabled)" else ""}`
					end),
					TextXAlignment = Enum.TextXAlignment.Left,

					LayoutOrder = value.order,

					[OnEvent("Activated")] = function()
						SystemPreview({
							SystemName = unwrap(value.name),
						})
					end,

					[Children] = {

						New("Frame")({

							Size = UDim2.fromOffset(12, 12),

							BackgroundColor3 = Computed(function()
								return getColor(unwrap(value.order))
							end),

							[Children] = New("UICorner")({
								CornerRadius = UDim.new(1, 0),
							}),
						}),

						CubeCat.Components.Text({

							LayoutOrder = 200,

							Text = Computed(function()
								return getSuffixSeconds(getAverage(unwrap(value.timeTaken)))
							end),
							TextColor = Enum.StudioStyleGuideColor.DimmedText,
						}),
					},
				})
			end, Fusion.cleanup),
		},
	})

	return entityView
end

return entityView
