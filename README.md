# ECR Debugger
ECR Debugger is a project to provide a general debugger for [ECR](https://github.com/centau/ecr) allowing you to view systems and entities.

Originally designed for GameCat, ECR Debugger is now standalone and can be implemented in any Roblox project that uses [ECR](https://github.com/centau/ecr).

# Setting up

## Installing

### Wally
Add ```debugger = "aloroid/ecr-debugger@0.1.0"``` to your wally.toml

### Roblox
Get the release from Releases.

## Starting Up
ECR Debugger returns a function which is used to start the debugger.
This function needs to be called in order to start the debugger. You'll need to provide the list of components and registry in order for it to succesfully start. Otherwise, it will error.

Optionally, you can also provide hook functions which when both are provided enable the Watch functionality of the debugger. This allows you to watch Systems and what changes they are making to the given entities. You need to provide a before hook, which will run before the system runs and is used to start connections for recording changes, and a after hook which will be used to cleanup said connections.
```lua
local registry = ecr.registry()
local debugger = require(path.to.debugger)
local api = debugger({
	registry = registry,
	components = {
		Transform = ecr.component()
	},
	
	hookBeforeSystemRun = function(systemName: string, callback: () -> ())
		-- sets up the hook
		return function()
			-- cleans the hook up
		end
	end,
	hookAfterSystemRun = function(systemName: string, callback: () -> ())
		-- sets up the hook
		return function()
			-- cleans the hook up
		end
	end,
	
	
})
```

After the debugger has succesfully been setup, it returns a API which you must use to setup the rest of the debugger. The debugger provides the ability to add system data, remove systems, create and get watches and toggle the UI.

In order for the systems screen to work properly, you'll need to call `debugger.addSystemData(systemName, order, timeTaken)`. This will add the system data to the debugger allowing it to display the time it took and also the ability to create a watch for said system. When all systems have ran, call `debugger.push()` which will allow the UI to display the new frame.

When you remove a system, call `debugger.remove(systemName)`. If you don't know what system has been removed, or you cannot track something but know something changed about your systems, run `debugger.clear()` which will clear all system data. Watches are not included.

## Displaying the debugger
After the debugger has been setup, you'll need to add a way to toggle it. The easiest method is by listening to UserInputService for a specific key and calling `debugger.toggle()` like so:
```lua
UserInputService.InputBegan:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.F4 then
		debugger.toggle()
	end
end)
```

# Finish

You're done, Congratulations!