local Plugin = script.Parent.Parent.Parent
local Services = Plugin.Services
local Packages = Plugin.Parent

local CubeCat = require(Packages.CubeCat)
local Fusion = require(Packages.Fusion)

local ServerMessagingService = require(Services.ServerMessagingService)

local Computed = Fusion.Computed
local Children = Fusion.Children
local OnEvent = Fusion.OnEvent

local unwrap = CubeCat.Util.unwrap
local stripProps = CubeCat.Util.stripProps

type CanBeState<T> = Fusion.CanBeState<T>
export type entityPane = {
	Position: CanBeState<UDim2>?,
	Size: CanBeState<UDim2>?,
	AnchorPoint: CanBeState<Vector2>?,

	[any]: any,
}

local COMPONENT_ONLY_PROPERTIES = {}

local function LoopControl(props: entityPane)
	local LoopControl = CubeCat.Components.Background({

		Size = UDim2.new(1, 0, 0, 64),

		NoPadding = true,

		[Children] = {

			CubeCat.Components.Button({

				Size = UDim2.fromScale(1, 0),

				Text = Computed(function()
					if unwrap(ServerMessagingService.IsPausedServer) == true then
						return "Resume Server"
					else
						return "Pause Server"
					end
				end),

				[OnEvent("Activated")] = function()
					ServerMessagingService:ToggleDebuggerPaused(not unwrap(ServerMessagingService.IsPausedServer))
				end,

				[Children] = CubeCat.Components.Image({

					Size = UDim2.fromOffset(26, 26),

					Image = Computed(function()
						if unwrap(ServerMessagingService.IsPausedServer) == true then
							return "rbxasset://textures/DeveloperFramework/MediaPlayerControls/play_button.png"
						else
							return "rbxasset://textures/DeveloperFramework/MediaPlayerControls/pause_button.png"
						end
					end),
				}),
			}),

			CubeCat.Components.Button({

				Size = UDim2.fromScale(1, 0),

				Text = Computed(function()
					if unwrap(ServerMessagingService.IsPaused) == true then
						return "Resume Locally"
					else
						return "Pause Locally"
					end
				end),

				[OnEvent("Activated")] = function()
					ServerMessagingService:ToggleLocalDebuggerPaused(not unwrap(ServerMessagingService.IsPaused))
				end,

				[Children] = CubeCat.Components.Image({

					Size = UDim2.fromOffset(26, 26),

					Image = Computed(function()
						if unwrap(ServerMessagingService.IsPaused) == true then
							return "rbxasset://textures/DeveloperFramework/MediaPlayerControls/play_button.png"
						else
							return "rbxasset://textures/DeveloperFramework/MediaPlayerControls/pause_button.png"
						end
					end),
				}),
			}),
		},
	})

	return Fusion.Hydrate(LoopControl)(stripProps(props, COMPONENT_ONLY_PROPERTIES))
end

return LoopControl
