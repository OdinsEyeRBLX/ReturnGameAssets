-- [!] PLACE THIS SCRIPT IN ServerScriptService

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemoteEvent = ReplicatedStorage:WaitForChild("AssetScannerUpdate") -- [!] CREATE WITHIN REPLICATED STORAGE IF NOT ALREADY!

local SCAN_INTERVAL = 10
local seenAssets = {
	Meshes = {},
	Sounds = {},
	Animations = {},
	Scripts = {}
}

-- Helpers
local function extractId(value)
	if typeof(value) ~= "string" then return nil end
	local id = value:match("rbxassetid://(%d+)")
	return id or nil
end

local function tryGet(obj, prop)
	local success, result = pcall(function() return obj[prop] end)
	return success and result or nil
end

local function getFullNameSafe(obj)
	local success, result = pcall(function() return obj:GetFullName() end)
	return success and result or obj.Name
end

-- Scan
local function scanAssets()
	local found = {
		Meshes = {},
		Sounds = {},
		Animations = {},
		Scripts = {}
	}

	for _, obj in ipairs(game:GetDescendants()) do
		-- Mesh
		local meshId = tryGet(obj, "MeshId")
		if meshId and meshId ~= "" then
			local id = extractId(meshId)
			if id then
				local key = id .. "|" .. getFullNameSafe(obj)
				if not seenAssets.Meshes[key] then
					seenAssets.Meshes[key] = true
					table.insert(found.Meshes, string.format("%s - <%s> - %s", obj.Name, id, getFullNameSafe(obj)))
				end
			end
		end

		-- Sound
		if obj:IsA("Sound") then
			local soundId = extractId(obj.SoundId)
			if soundId then
				local key = soundId .. "|" .. getFullNameSafe(obj)
				if not seenAssets.Sounds[key] then
					seenAssets.Sounds[key] = true
					table.insert(found.Sounds, string.format("%s - <%s> - %s", obj.Name, soundId, getFullNameSafe(obj)))
				end
			end
		end

		-- Animation
		if obj:IsA("Animation") then
			local animId = extractId(obj.AnimationId)
			if animId then
				local key = animId .. "|" .. getFullNameSafe(obj)
				if not seenAssets.Animations[key] then
					seenAssets.Animations[key] = true
					table.insert(found.Animations, string.format("%s - <%s> - %s", obj.Name, animId, getFullNameSafe(obj)))
				end
			end
		end

		-- Script asset ID check (safe)
		if obj:IsA("LuaSourceContainer") then
			local ok, source = pcall(function() return obj.Source end)
			if ok and source then
				for match in source:gmatch("rbxassetid://(%d+)") do
					local key = match .. "|" .. getFullNameSafe(obj)
					if not seenAssets.Scripts[key] then
						seenAssets.Scripts[key] = true
						table.insert(found.Scripts, string.format("%s - <%s> - %s", obj.Name, match, getFullNameSafe(obj)))
					end
				end
			else
				-- Cannot read .Source (probably running in play mode), skip
			end
		end
	end

	-- Send to all clients if anything new found
	if #found.Meshes > 0 or #found.Sounds > 0 or #found.Animations > 0 or #found.Scripts > 0 then
		RemoteEvent:FireAllClients(found)
	end
end

while true do
	task.wait(SCAN_INTERVAL)
	scanAssets()
end
