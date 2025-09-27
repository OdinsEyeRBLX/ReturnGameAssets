local scannedScripts = {}

local function safeGetFullName(obj)
	local ok, result = pcall(function() return obj:GetFullName() end)
	return ok and result or obj.Name
end

local function scanScriptsForAssetIds()
	local foundAssets = {}

	for _, obj in ipairs(game:GetDescendants()) do
		if obj:IsA("LuaSourceContainer") then
			local source = obj.Source
			for id in source:gmatch("rbxassetid://(%d+)") do
				table.insert(foundAssets, string.format("%s - <%s> - %s", obj.Name, id, safeGetFullName(obj)))
			end
		end
	end

	return foundAssets
end

local results = scanScriptsForAssetIds()

print("------ SCRIPT ASSET ID SCAN RESULTS ------")
if #results == 0 then
	print("No asset IDs found in scripts.")
else
	for _, line in ipairs(results) do
		print(line)
	end
end
