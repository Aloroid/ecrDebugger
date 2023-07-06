--[[
	Contains all th
	
]]

local Packages = script.Parent.Parent

local ecr = require(Packages.ecr)

return {

	components = {} :: { [string]: number },
	registry = ecr.registry() :: ecr.Registry,

	pauseWhitelist = {} :: { number | string },

	hookBeforeSystemRun = nil :: ((systemName: string, callback: () -> ()) -> () -> ())?,
	hookAfterSystemRun = nil :: ((systemName: string, callback: (timeTaken: number?) -> ()) -> () -> ())?,
}
