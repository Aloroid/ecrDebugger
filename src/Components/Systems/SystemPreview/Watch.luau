--[[
	SystemWatch is a component used to watch changes made by a system.
	
]]

local Plugin = script.Parent.Parent.Parent.Parent
local Packages = Plugin.Parent
local Services = Plugin.Services

local CubeCat = require(Packages.CubeCat)
local Fusion = require(Packages.Fusion)
local SystemWatchService = require(Services.SystemWatchService)

local WatchTable = require(script.Parent.WatchTable)

local getSuffixSeconds = require(Plugin.Utility.getSuffixSeconds)

local Value = Fusion.Value
local Computed = Fusion.Computed
local Children = Fusion.Children
local OnEvent = Fusion.OnEvent

local unwrap = CubeCat.Util.unwrap

type CanBeState<T> = Fusion.CanBeState<T>
export type Watch = {
	Position: CanBeState<UDim2>?,
	Size: CanBeState<UDim2>?,
	AnchorPoint: CanBeState<Vector2>?,

	SystemName: string,

	[any]: any,
}

local function Watch(props: Watch)
	local systemName = props.SystemName

	local watch = SystemWatchService:GetWatch(systemName)
	local watching = Value(watch.active)
	local frame = Value(0)

	local Watch = CubeCat.Components.Background({

		NoPadding = true,
		ListPadding = 8,

		[Children] = {

			CubeCat.Components.Background({

				Size = UDim2.new(1, 0, 0, 32),

				Padding = 1,
				FillDirection = Enum.FillDirection.Horizontal,
				VerticalAlignment = Enum.VerticalAlignment.Center,

				[Children] = {

					CubeCat.Components.Button({
						Size = UDim2.fromOffset(59, 30),

						Text = Computed(function()
							if unwrap(watching) then
								return "Finish"
							else
								return "Record"
							end
						end),
						HorizontalAlignment = Enum.HorizontalAlignment.Center,

						[OnEvent("Activated")] = function()
							if watch.active == false then
								frame:set(0)
								watching:set(true)
								watch:clear()
								watch:enable()
							else
								watching:set(false)
								watch:disable()
							end
						end,

						Disabled = not SystemWatchService.WatchEnabled,
					}),

					CubeCat.Components.TextInput({

						Size = UDim2.new(0, 50, 0, 30),

						PlaceholderText = "0",

						Filter = function(text)
							if text == "" then return text end
							if tonumber(text) == nil then return tostring(unwrap(frame)) end

							frame:set(tonumber(text))
							return text
						end,

						Validator = function(text)
							local num = tonumber(text) or 0
							local max = #unwrap(watch.frames)

							--if max == 0 then return true end

							if num > max or num < 0 then
								return false
							else
								return true
							end
						end,

						Disabled = Computed(function() return #unwrap(watch.frames) == 0 end),
					}),

					CubeCat.Components.Text({
						Size = UDim2.new(1, -59 - 50 - 16, 0),
						AutomaticSize = Enum.AutomaticSize.Y,

						TextXAlignment = Enum.TextXAlignment.Right,
						Text = Computed(
							function() return `Recorded {#unwrap(watch.frames)}/{unwrap(watch.totalFrames)} frames` end
						),
					}),
				},
			}),

			CubeCat.Components.Text({
				Size = UDim2.new(1, 0, 0, 18),

				Text = Computed(function()
					if SystemWatchService.WatchEnabled == false then return "Watch Hooks not implemented" end

					local frame = unwrap(watch.frames)[unwrap(frame)]
					if frame == nil then return "Out of bounds" end
					if frame.timeTaken == nil then return "" end
					return `Took {getSuffixSeconds(frame.timeTaken)}`
				end),
				TextXAlignment = Enum.TextXAlignment.Left,
			}),

			CubeCat.Components.Background({

				Size = UDim2.new(1, 0, 1, -32 - 18 - 8 - 8),

				BackgroundColor = Enum.StudioStyleGuideColor.ViewPortBackground,

				NoPadding = true,

				[Children] = WatchTable({
					SystemName = systemName,
					Frame = frame,
				}),
			}),
		},
	})

	return Watch
end

return Watch
