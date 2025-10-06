-- ZonePlus Modern API Test Script
-- Place this in StarterPlayer > StarterPlayerScripts or StarterGui

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- Wait for Zone module (adjust path as needed)
local Zone = require(ReplicatedStorage:WaitForChild("Zone"))

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- Wait for test environment
local testFolder = workspace:WaitForChild("ZonePlusTests")
local boxZoneContainer = testFolder:WaitForChild("BoxZone")
local sphereZoneContainer = testFolder:WaitForChild("SphereZone")
local complexZoneContainer = testFolder:WaitForChild("ComplexZone")
local cylinderGroupedContainer = testFolder:WaitForChild("CylinderGroupedZone")
local cylinderUngroupedContainer = testFolder:WaitForChild("CylinderUngroupedZone")

print("🚀 ZonePlus v4.0.0 - Modern Spatial Query Edition Test")
print("=" .. string.rep("=", 60))

-- Test 1: Traditional Zone from Container (Modern APIs under the hood)
print("📦 Creating Box Zone from container...")
local boxZone = Zone.new(boxZoneContainer)
boxZone:setAccuracy("High")
boxZone:setDetection("Centre")
print("✅ Box Zone created with traditional method (Uses modern GetPartBoundsInBox internally)")

-- Test 2: New Optimized Box Zone
print("\n📦 Creating optimized Box Zone...")
local optimizedBoxZone = Zone.fromBox(CFrame.new(0, 10, 0), Vector3.new(30, 20, 30))
optimizedBoxZone:setAccuracy("High")
print("✅ Optimized Box Zone created with Zone.fromBox()")

-- Test 3: Sphere Zone from existing container
print("\n🔵 Creating Sphere Zone from container...")
local sphereZone = Zone.new(sphereZoneContainer)
sphereZone:setAccuracy("High")
sphereZone:setDetection("Centre")
print("✅ Sphere Zone created (Ball shape auto-detected)")

-- Test 4: Complex Zone (will use GetPartsInPart for precision)
print("\n🔧 Creating Complex Zone...")
local complexZone = Zone.new(complexZoneContainer)
complexZone:setAccuracy("High")
complexZone:setDetection("Centre")
print("✅ Complex Zone created (Uses GetPartsInPart for precision)")

-- Test 5: Cylinder Grouped Zone
print("\n🛢️ Creating Cylinder Grouped Zone...")
local cylinderGroupedZone = Zone.new(cylinderGroupedContainer)
cylinderGroupedZone:setAccuracy("High")
cylinderGroupedZone:setDetection("Centre")
print("✅ Cylinder Grouped Zone created (Full cylinder with top/bottom)")

-- Test 6: Cylinder Ungrouped Zones (Each part gets its own zone with different color)
print("\n🛢️ Creating Cylinder Ungrouped Zones...")
local ungroupedZones = {}
local ungroupedColors = {
	Color3.fromRGB(170, 0, 255), -- Purple
	Color3.fromRGB(255, 0, 170), -- Magenta
	Color3.fromRGB(0, 255, 170), -- Cyan
	Color3.fromRGB(255, 170, 0), -- Orange-Yellow
	Color3.fromRGB(170, 255, 0), -- Lime
}

local partIndex = 1
local children = cylinderUngroupedContainer:GetChildren()
print("🔍 Found " .. #children .. " children in CylinderUngroupedContainer")

for _, part in children do
	print("  Checking child: " .. part.Name .. " (Type: " .. part.ClassName .. ")")
	if part:IsA("BasePart") then
		print("    Part details - Position: " .. tostring(part.Position) .. ", Size: " .. tostring(part.Size))
		print(
			"    Part properties - CanCollide: "
				.. tostring(part.CanCollide)
				.. ", Anchored: "
				.. tostring(part.Anchored)
		)

		local zone = Zone.new(part)
		zone:setAccuracy("High")
		zone:setDetection("Centre")

		-- Verify zone was created properly
		print("    Zone created - ZoneID: " .. zone.zoneId)
		print("    Zone parts count: " .. #zone.zoneParts)
		if #zone.zoneParts > 0 then
			print("    Zone part[1]: " .. zone.zoneParts[1].Name)
		end

		local color = ungroupedColors[((partIndex - 1) % #ungroupedColors) + 1]
		table.insert(ungroupedZones, {
			zone = zone,
			part = part, -- Store reference to the part for debugging
			name = "Ungrouped Part " .. partIndex .. " (" .. part.Name .. ")",
			inZone = false,
			color = color,
		})
		print(
			"✅ Created zone #"
				.. partIndex
				.. " for part: "
				.. part.Name
				.. " with color RGB("
				.. math.floor(color.R * 255)
				.. ", "
				.. math.floor(color.G * 255)
				.. ", "
				.. math.floor(color.B * 255)
				.. ")"
		)
		partIndex = partIndex + 1
	end
end

print("📊 Total ungrouped zones created: " .. #ungroupedZones)

-- Track zone status
local zoneStatus = {
	boxZone = { name = "Box Zone (Container)", inZone = false, color = Color3.fromRGB(0, 170, 255) },
	sphereZone = { name = "Sphere Zone", inZone = false, color = Color3.fromRGB(255, 85, 127) },
	complexZone = { name = "Complex Zone", inZone = false, color = Color3.fromRGB(127, 255, 85) },
	cylinderGroupedZone = { name = "Cylinder Grouped Zone", inZone = false, color = Color3.fromRGB(255, 170, 0) },
}

-- Connect to zone events
boxZone.localPlayerEntered:Connect(function()
	zoneStatus.boxZone.inZone = true
	print("\n🟢 ENTERED:", zoneStatus.boxZone.name)
end)

boxZone.localPlayerExited:Connect(function()
	zoneStatus.boxZone.inZone = false
	print("\n🔴 EXITED:", zoneStatus.boxZone.name)
end)

sphereZone.localPlayerEntered:Connect(function()
	zoneStatus.sphereZone.inZone = true
	print("\n🟢 ENTERED:", zoneStatus.sphereZone.name)
end)

sphereZone.localPlayerExited:Connect(function()
	zoneStatus.sphereZone.inZone = false
	print("\n🔴 EXITED:", zoneStatus.sphereZone.name)
end)

complexZone.localPlayerEntered:Connect(function()
	zoneStatus.complexZone.inZone = true
	print("\n🟢 ENTERED:", zoneStatus.complexZone.name)
end)

complexZone.localPlayerExited:Connect(function()
	zoneStatus.complexZone.inZone = false
	print("\n🔴 EXITED:", zoneStatus.complexZone.name)
end)

cylinderGroupedZone.localPlayerEntered:Connect(function()
	zoneStatus.cylinderGroupedZone.inZone = true
	print("\n🟢 ENTERED:", zoneStatus.cylinderGroupedZone.name)
end)

cylinderGroupedZone.localPlayerExited:Connect(function()
	zoneStatus.cylinderGroupedZone.inZone = false
	print("\n🔴 EXITED:", zoneStatus.cylinderGroupedZone.name)
end)

-- Connect events for each ungrouped zone
print("\n🔗 Connecting events for " .. #ungroupedZones .. " ungrouped zones...")
for index, zoneData in ungroupedZones do
	print(
		"  Connecting events for zone #"
			.. index
			.. ": "
			.. zoneData.name
			.. " (ZoneID: "
			.. zoneData.zone.zoneId
			.. ")"
	)

	zoneData.zone.localPlayerEntered:Connect(function()
		zoneData.inZone = true
		print("\n🟢 ENTERED:", zoneData.name, "| Part:", zoneData.part.Name, "| Zone:", zoneData.zone.zoneId)
	end)

	zoneData.zone.localPlayerExited:Connect(function()
		zoneData.inZone = false
		print("\n🔴 EXITED:", zoneData.name, "| Part:", zoneData.part.Name, "| Zone:", zoneData.zone.zoneId)
	end)
end
print("✅ All ungrouped zone events connected!")

boxZone.itemEntered:Connect(function(item)
	print("📦 Item entered Box Zone:", item.Name)
end)

boxZone.itemExited:Connect(function(item)
	print("📦 Item exited Box Zone:", item.Name)
end)

-- Visual feedback - highlight character when in zones
local highlight = Instance.new("Highlight")
highlight.FillTransparency = 0.5
highlight.OutlineTransparency = 0
highlight.Parent = character

RunService.Heartbeat:Connect(function()
	-- Update highlight color based on which zone player is in
	local inAnyZone = false
	local currentColor = Color3.new(1, 1, 1)

	-- Check main zones
	for _, status in zoneStatus do
		if status.inZone then
			inAnyZone = true
			currentColor = status.color
			break
		end
	end

	-- Check ungrouped zones
	if not inAnyZone then
		for _, zoneData in ungroupedZones do
			if zoneData.inZone then
				inAnyZone = true
				currentColor = zoneData.color
				break
			end
		end
	end

	highlight.Enabled = inAnyZone
	if inAnyZone then
		highlight.FillColor = currentColor
		highlight.OutlineColor = currentColor
	end
end)

-- Print test summary
task.wait(1)
print("\n" .. string.rep("-", 50))
print("\n🎯 Test Summary:")
print("• Box Zone: Using modern GetPartBoundsInBox")
print("• Sphere Zone: Auto-detected Ball shape")
print("• Complex Zone: Using GetPartsInPart for precision")
print("• Cylinder Grouped Zone: Full cylinder with top/bottom")
print("• Cylinder Ungrouped Zones: " .. #ungroupedZones .. " separate zones with unique colors")
print("\n💡 Walk into zones to test detection!")
print("💡 Your character will highlight in zone colors:")
print("   🔵 Blue = Box Zone")
print("   💗 Pink = Sphere Zone")
print("   💚 Green = Complex Zone")
print("   🟠 Orange = Cylinder Grouped Zone")
print("   🌈 Various Colors = Ungrouped Zones (Purple, Magenta, Cyan, Orange-Yellow, Lime)")
print("💡 Watch the Output for enter/exit events")

-- Performance monitoring and zone status debugging
local lastUpdate = tick()
local lastStatusCheck = tick()
local frameCount = 0
RunService.Heartbeat:Connect(function()
	frameCount = frameCount + 1
	if tick() - lastUpdate >= 5 then
		local fps = math.floor(frameCount / (tick() - lastUpdate))
		print(string.format("📊 Performance: %d FPS", fps))
		lastUpdate = tick()
		frameCount = 0
	end

	-- Debug: Check zone status every 3 seconds
	if tick() - lastStatusCheck >= 3 then
		local playerPos = humanoidRootPart.Position
		print("\n🔍 DEBUG: Player position: " .. tostring(playerPos))
		print("  Ungrouped zones status:")
		for index, zoneData in ungroupedZones do
			local distance = (zoneData.part.Position - playerPos).Magnitude
			print(
				string.format(
					"    Zone #%d (%s): inZone=%s, distance=%.2f",
					index,
					zoneData.part.Name,
					tostring(zoneData.inZone),
					distance
				)
			)
		end
		lastStatusCheck = tick()
	end
end)

print("\n✅ ZonePlus test script initialized successfully!")
print("📝 Watch the Output window for zone status updates")
