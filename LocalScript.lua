local button = script.Parent
local frame = button.Parent

local latitudeBox = frame:WaitForChild("LatitudeBox")
local longitudeBox = frame:WaitForChild("LongitudeBox")
local statusLabel = frame:WaitForChild("StatusLabel")

-- Lunar map configuration
local MOON_RADIUS = 1737400
local METRES_PER_STUD = 175.78125

local MIN_LATITUDE = -90
local MAX_LATITUDE = -45

local MIN_LONGITUDE = -180
local MAX_LONGITUDE = 180

local function convertCoordinates(latitude, longitude)

	local lat = math.rad(latitude)
	local lon = math.rad(longitude)

	-- South polar stereographic projection
	local rho = 2 * MOON_RADIUS *
		math.tan(math.pi / 4 + lat / 2)

	local projectedX = rho * math.sin(lon)
	local projectedY = rho * math.cos(lon)

	-- Convert projected metres to Roblox studs
	local worldX = projectedX / METRES_PER_STUD
	local worldZ = -projectedY / METRES_PER_STUD

	return worldX, worldZ
end

button.MouseButton1Click:Connect(function()

	local latitude = tonumber(latitudeBox.Text)
	local longitude = tonumber(longitudeBox.Text)

	if not latitude or not longitude then
		statusLabel.Text = "Enter valid numbers."
		return
	end

	if latitude < MIN_LATITUDE or latitude > MAX_LATITUDE then
		statusLabel.Text = "Latitude must be between -90 and -45."
		return
	end

	if longitude < MIN_LONGITUDE or longitude > MAX_LONGITUDE then
		statusLabel.Text = "Longitude must be between -180 and 180."
		return
	end

	local x, z = convertCoordinates(latitude, longitude)

	-- Check map boundaries
	if math.abs(x) > 8192 or math.abs(z) > 8192 then
		statusLabel.Text = "Location outside terrain."
		return
	end

	-- Find actual terrain elevation
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Include
	params.FilterDescendantsInstances = {workspace.Terrain}

	local origin = Vector3.new(x, 1000, z)
	local direction = Vector3.new(0, -2000, 0)

	local result = workspace:Raycast(
		origin,
		direction,
		params
	)

	if not result then
		statusLabel.Text = "No terrain detected at this location."
		warn("Raycast missed terrain at:", x, z)
		return
	end

	-- Move camera while preserving its current rotation
	local camera = workspace.CurrentCamera

	local destination = result.Position + Vector3.new(0, 40, 0)

	local rotation = camera.CFrame.Rotation

	camera.CFrame = CFrame.new(destination) * rotation

	statusLabel.Text = string.format(
		"Selected: %.3f°, %.3f°",
		latitude,
		longitude
	)

	print("Roblox position:", x, result.Position.Y, z)

end)
