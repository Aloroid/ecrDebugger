local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Plugin = script.Parent.Parent
local Packages = Plugin.Parent

local CubeCat = require(Packages.CubeCat)
local Fusion = require(Packages.Fusion)

local Entity = require(Plugin.Components.Entity)
local Systems = require(Plugin.Components.Systems)

local New = Fusion.New
local Value = Fusion.Value
local Computed = Fusion.Computed
local Children = Fusion.Children
local OnEvent = Fusion.OnEvent
local Cleanup = Fusion.Cleanup

local unwrap = CubeCat.Util.unwrap

type CanBeState<T> = Fusion.CanBeState<T>
export type entityView = {
	Position: CanBeState<UDim2>?,
	Size: CanBeState<UDim2>?,
	AnchorPoint: CanBeState<Vector2>?,

	Enabled: CanBeState<boolean>?,

	[any]: any,
}

local function debugView(props: entityView)
	local currentSize = Value(400)
	local dragging = false

	local debugView = New("ScreenGui")({

		Parent = Players.LocalPlayer:WaitForChild("PlayerGui"),

		Name = "EntityDebuggerPanel",

		IgnoreGuiInset = true,
		Enabled = props.Enabled,

		DisplayOrder = 999,

		[Children] = CubeCat.Components.Background({

			Size = Computed(function()
				return UDim2.new(0, unwrap(currentSize), 1, 0)
			end),
			Active = true,
			NoPadding = true,
			ListPadding = 16,

			[Children] = {

				CubeCat.Components.Border({}),

				CubeCat.Components.Padding({

					Padding = 16,
					PaddingTop = UDim.new(0, 48),
				}),

				CubeCat.Components.Tabs({

					Tabs = {

						{ Name = "Entities", Children = Entity({}) },
						{ Name = "Systems", Children = Systems({}) },
					},
				}),
			},

			[OnEvent("InputBegan")] = function(input)
				if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
					return
				end

				if input.Position.X > unwrap(currentSize) - 16 then
					dragging = true
				end
			end,

			[Cleanup] = RunService.Heartbeat:Connect(function()
				dragging = dragging and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)

				if dragging == false then
					return
				end
				local mouseLocation = UserInputService:GetMouseLocation()
				currentSize:set(mouseLocation.X)
			end),
		}),
	})

	return debugView
end

return debugView
