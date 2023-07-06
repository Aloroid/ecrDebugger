local Plugin = script.Parent.Parent
local Packages = Plugin.Parent

local CubeCat = require(Packages.CubeCat)
local State = require(Plugin.State)

local components = State.components
local registry = State.registry

local EntityQueryService = CubeCat.CreateService({
	Name = "EntityQueryService",
})

--[[
	This parses a given search query for entities and returns a error or the
	included/excluded components

	A example queryString is "@Transform !PhysicsObject"
	This query will search for entities that have a Transform, but exclude any
	entities that have a PhysicsObject.
]]
function EntityQueryService:parseQuery(queryString: string): (boolean, { number } | string)
	local splitted = string.split(queryString, " ")
	local alreadyUsed = {}
	local includeHash = {}
	local excludeHash = {}
	local include = {}
	local exclude = {}

	for _, componentQuery in splitted do
		local controlCharacter = string.sub(componentQuery, 1, 1)
		local componentName = string.sub(componentQuery, 2)
		local componentId = components[componentName]

		if queryString == "" then
			continue
		end
		if controlCharacter == "" then
			return false, "Invalid query"
		end

		-- Perform some checks and return a error about a query.
		if componentId == nil then
			return false, `"{componentName}" is not a valid component`
		end

		if alreadyUsed[componentName] then
			return false, `{componentName} is already included earlier in the query.`
		end

		alreadyUsed[componentName] = true

		if controlCharacter == "@" then
			includeHash[componentName] = componentId
			table.insert(include, componentId)
		elseif controlCharacter == "!" then
			excludeHash[componentName] = componentId
			table.insert(exclude, componentId)
		else
			return false, `{controlCharacter} is not a valid query character.`
		end
	end

	if #include == 0 and #exclude > 0 then
		return false, `Invalid query`
	end

	return true, includeHash, excludeHash
end

--[[
	This will create a query based on the include and exclude's given to it.
	
]]
function EntityQueryService:getQuery(included, excluded)
	local arrayInclude = {}
	local arrayExclude = {}

	for name in included do
		table.insert(arrayInclude, components[name])
	end

	for name in excluded do
		table.insert(arrayExclude, components[name])
	end

	if #arrayInclude == 0 and #arrayExclude == 0 then
		local ids = {}
		for id in registry do
			ids[id] = true
		end
		return ids
	end

	return registry:view(unpack(arrayInclude)):exclude(unpack(arrayExclude))
end

function EntityQueryService:Init() end

return EntityQueryService
