local Plugin = script.Parent.Parent
local Services = Plugin.Services
local Packages = Plugin.Parent

local CubeCat = require(Packages.CubeCat)
local Fusion = require(Packages.Fusion)

local EntityQueryService = require(Services.EntityQueryService)

local entityPane = require(script.Pane)

local New = Fusion.New
local Value = Fusion.Value
local Children = Fusion.Children

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
	local currentQuery = Value("")
	local queryString = Value("")

	local entityView = New("Frame")({

		Size = UDim2.fromScale(1, 1),

		BackgroundTransparency = 1,

		[Children] = {

			New("UIListLayout")({
				Padding = UDim.new(0, 16),
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),

			CubeCat.Components.Padding({
				Padding = 4,
			}),

			CubeCat.Components.TextInput({

				Size = UDim2.new(1, 0, 0, 24),

				Text = queryString,
				PlaceholderText = "Entity Component Query",
				ErrorLocation = "Bottom",

				FocusLost = function(enterPressed)
					currentQuery:set(unwrap(queryString))
				end,

				Validator = function(text: string)
					local ok, result = EntityQueryService:parseQuery(text)
					return ok, if not ok then result else nil
				end,
			}),

			CubeCat.Components.Pane({

				PaneText = "Entities",

				Size = UDim2.new(1, 0, 1, -40),
				AutomaticSize = Enum.AutomaticSize.None,

				[Children] = entityPane({
					Size = UDim2.new(1, 0, 1),

					Query = currentQuery,
				}),
			}),
		},
	})

	return entityView
end

return entityView
