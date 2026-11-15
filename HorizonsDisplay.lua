local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local remote = ReplicatedStorage:WaitForChild("FetchHorizons")
local gui = script.Parent
local spacecraft = workspace:WaitForChild("SpaceCraft")

local markerDistance = 600

-- Time slider configuration
local MINUTES_PER_STEP = 10
local currentMinutes = 720
local dragging = false
local fetching = false

-- Create interface

local panel = Instance.new("Frame")
panel.Name = "HorizonsPanel"
panel.Size = UDim2.fromOffset(340, 345)
panel.Position = UDim2.new(1, -360, 0, 20)
panel.BackgroundColor3 = Color3.fromRGB(20, 25, 35)
panel.Parent = gui

Instance.new("UICorner", panel).CornerRadius =
	UDim.new(0, 10)

local function makeLabel(name, text, position, size)

	local label = Instance.new("TextLabel")

	label.Name = name
	label.Position = position
	label.Size = size

	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextSize = 14
	label.Font = Enum.Font.Gotham
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = panel

	return label
end

local function makeInput(name, placeholder, position, size, default)

	local box = Instance.new("TextBox")

	box.Name = name
	box.Position = position
	box.Size = size

	box.BackgroundColor3 = Color3.fromRGB(45, 52, 65)
	box.TextColor3 = Color3.new(1, 1, 1)

	box.PlaceholderText = placeholder
	box.Text = default

	box.TextSize = 14
	box.Font = Enum.Font.Gotham
	box.ClearTextOnFocus = false
	box.Parent = panel

	Instance.new("UICorner", box).CornerRadius =
		UDim.new(0, 5)

	return box
end

-- Title

makeLabel(
	"Title",
	"LUNAR ENVIRONMENT",
	UDim2.fromOffset(12, 8),
	UDim2.fromOffset(310, 30)
).Font = Enum.Font.GothamBold

-- Date input

makeLabel(
	"DateLabel",
	"DATE",
	UDim2.fromOffset(12, 43),
	UDim2.fromOffset(310, 20)
).Font = Enum.Font.GothamBold

local dateBox = makeInput(
	"Date",
	"YYYY-MM-DD",
	UDim2.fromOffset(12, 65),
	UDim2.new(1, -24, 0, 32),
	"2026-11-15"
)

-- Time slider

makeLabel(
	"TimeLabel",
	"TIME (UTC)",
	UDim2.fromOffset(12, 106),
	UDim2.fromOffset(150, 20)
).Font = Enum.Font.GothamBold

local timeDisplay = makeLabel(
	"TimeDisplay",
	"12:00",
	UDim2.new(1, -85, 0, 103),
	UDim2.fromOffset(73, 25)
)

timeDisplay.TextXAlignment = Enum.TextXAlignment.Right
timeDisplay.TextSize = 19
timeDisplay.Font = Enum.Font.GothamBold

-- Slider track

local sliderTrack = Instance.new("Frame")
sliderTrack.Name = "TimeSlider"
sliderTrack.Position = UDim2.fromOffset(16, 143)
sliderTrack.Size = UDim2.new(1, -32, 0, 8)
sliderTrack.BackgroundColor3 = Color3.fromRGB(65, 75, 90)
sliderTrack.BorderSizePixel = 0
sliderTrack.Parent = panel

Instance.new("UICorner", sliderTrack).CornerRadius =
	UDim.new(1, 0)

-- Filled portion

local sliderFill = Instance.new("Frame")
sliderFill.Size = UDim2.new(0.5, 0, 1, 0)
sliderFill.BackgroundColor3 = Color3.fromRGB(55, 160, 230)
sliderFill.BorderSizePixel = 0
sliderFill.Parent = sliderTrack

Instance.new("UICorner", sliderFill).CornerRadius =
	UDim.new(1, 0)

-- Slider knob

local knob = Instance.new("Frame")
knob.Name = "Knob"
knob.Size = UDim2.fromOffset(18, 18)
knob.AnchorPoint = Vector2.new(0.5, 0.5)
knob.Position = UDim2.new(0.5, 0, 0.5, 0)
knob.BackgroundColor3 = Color3.new(1, 1, 1)
knob.BorderSizePixel = 0
knob.ZIndex = 3
knob.Parent = sliderTrack

Instance.new("UICorner", knob).CornerRadius =
	UDim.new(1, 0)

-- Invisible interaction surface

local sliderButton = Instance.new("TextButton")
sliderButton.Name = "SliderInput"
sliderButton.Size = UDim2.new(1, 0, 0, 32)
sliderButton.Position = UDim2.fromOffset(0, -12)
sliderButton.BackgroundTransparency = 1
sliderButton.Text = ""
sliderButton.ZIndex = 4
sliderButton.Parent = sliderTrack

makeLabel(
	"StartTime",
	"00:00",
	UDim2.fromOffset(12, 162),
	UDim2.fromOffset(60, 18)
)

local endTime = makeLabel(
	"EndTime",
	"23:50",
	UDim2.new(1, -72, 0, 162),
	UDim2.fromOffset(60, 18)
)

endTime.TextXAlignment = Enum.TextXAlignment.Right

-- Time conversion

local function formatTime(minutes)

	local hours = math.floor(minutes / 60)
	local mins = minutes % 60

	return string.format("%02d:%02d", hours, mins)
end

local function updateSlider(minutes)

	currentMinutes = math.clamp(
		math.floor(minutes / MINUTES_PER_STEP + 0.5)
			* MINUTES_PER_STEP,
		0,
		1430
	)

	local fraction = currentMinutes / 1430

	knob.Position = UDim2.new(
		fraction, 0, 0.5, 0
	)

	sliderFill.Size = UDim2.new(
		fraction, 0, 1, 0
	)

	timeDisplay.Text = formatTime(currentMinutes)
end

local function setSliderFromMouse(mouseX)

	local trackStart = sliderTrack.AbsolutePosition.X
	local trackWidth = sliderTrack.AbsoluteSize.X

	local fraction = math.clamp(
		(mouseX - trackStart) / trackWidth,
		0,
		1
	)

	updateSlider(fraction * 1430)
end

updateSlider(720)

-- Results panel

local results = makeLabel(
	"Results",
	"Select a location and fetch Horizons data.",
	UDim2.fromOffset(12, 195),
	UDim2.new(1, -24, 0, 135)
)

results.TextYAlignment = Enum.TextYAlignment.Top
results.TextWrapped = true
results.TextSize = 13

-- Fetch button

local button = Instance.new("TextButton")

button.Name = "FetchButton"
button.Position = UDim2.fromOffset(12, 225)
button.Size = UDim2.new(1, -24, 0, 36)

button.BackgroundColor3 = Color3.fromRGB(40, 105, 170)
button.TextColor3 = Color3.new(1, 1, 1)

button.Text = "UPDATE CELESTIAL POSITIONS"
button.TextSize = 13
button.Font = Enum.Font.GothamBold

button.Parent = panel

Instance.new("UICorner", button).CornerRadius =
	UDim.new(0, 5)

-- Slider interaction

local function finishDragging()

	if not dragging then
		return
	end

	dragging = false

	-- Automatically fetch when the user releases the slider
	if not fetching then
		task.spawn(function()
			-- fetchHorizons is defined below
		end)
	end
end

-- Create or update celestial spheres

local function createMarker(name, color)

	local part = workspace:FindFirstChild(name)

	if not part then

		part = Instance.new("Part")

		part.Name = name
		part.Shape = Enum.PartType.Ball
		part.Size = Vector3.new(24, 24, 24)

		part.Anchored = true
		part.CanCollide = false
		part.Material = Enum.Material.Neon
		part.Color = color

		part.Parent = workspace

	end

	local billboard = part:FindFirstChildOfClass("BillboardGui")

	if not billboard then

		billboard = Instance.new("BillboardGui")
		billboard.Size = UDim2.fromOffset(150, 40)
		billboard.StudsOffset = Vector3.new(0, 2, 0)
		billboard.AlwaysOnTop = true
		billboard.Parent = part

	end

	local label = billboard:FindFirstChildOfClass("TextLabel")

	if not label then

		label = Instance.new("TextLabel")
		label.Size = UDim2.fromScale(1, 1)
		label.BackgroundTransparency = 1
		label.TextColor3 = color
		label.TextStrokeTransparency = 0
		label.TextScaled = true
		label.Font = Enum.Font.GothamBold
		label.Parent = billboard

	end

	part.Transparency = 0
	billboard.Enabled = true

	return part
end

local sunPart = createMarker(
	"SunIndicator",
	Color3.fromRGB(255, 190, 40)
)

local earthPart = createMarker(
	"EarthIndicator",
	Color3.fromRGB(60, 150, 255)
)

-- Convert azimuth/elevation into a Roblox direction

local function getDirection(azimuth, elevation, longitude)

	local az = math.rad(azimuth)
	local el = math.rad(elevation)
	local lon = math.rad(longitude)

	local north = Vector3.new(
		math.sin(lon),
		0,
		-math.cos(lon)
	)

	local east = Vector3.new(
		math.cos(lon),
		0,
		math.sin(lon)
	)

	local horizontal =
		north * math.cos(az)
		+ east * math.sin(az)

	local direction =
		horizontal * math.cos(el)
		+ Vector3.new(0, 1, 0) * math.sin(el)

	return direction.Unit
end

-- Update celestial marker and visibility

local function updateMarker(part, name, data, longitude)

	local aboveHorizon = data.elevation > 0

	local billboard = part:FindFirstChildOfClass("BillboardGui")

	-- Hide the sphere if the body is below the horizon
	part.Transparency = aboveHorizon and 0 or 1

	if billboard then
		billboard.Enabled = aboveHorizon
	end

	local direction = getDirection(
		data.azimuth,
		data.elevation,
		longitude
	)

	part.Position =
		spacecraft.Position + direction * markerDistance

	if billboard then

		local label = billboard:FindFirstChildOfClass("TextLabel")

		if label then
			label.Text = string.format(
				"%s | %.2f°",
				name,
				data.elevation
			)
		end

	end

	return aboveHorizon
end

-- Fetch Horizons data

local function fetchHorizons()

	if fetching then
		return
	end

	fetching = true
	button.Text = "FETCHING..."
	button.Active = false

	spacecraft = workspace:FindFirstChild("SpaceCraft")

	if not spacecraft or not spacecraft:IsA("BasePart") then

		results.Text = "SpaceCraft part not found!"

		button.Text = "UPDATE CELESTIAL POSITIONS"
		button.Active = true
		fetching = false
		return

	end

	local time = formatTime(currentMinutes)

	local success, response = pcall(function()

		return remote:InvokeServer(
			spacecraft.Position.X,
			spacecraft.Position.Z,
			dateBox.Text,
			time
		)

	end)

	button.Text = "UPDATE CELESTIAL POSITIONS"
	button.Active = true
	fetching = false

	if not success then
		results.Text = "Connection error: " .. tostring(response)
		return
	end

	if not response.ok then
		results.Text = "Error: " .. response.error
		return
	end

	local sun = response.data.Sun
	local earth = response.data.Earth

	local sunVisible = updateMarker(
		sunPart,
		"SUN",
		sun,
		response.longitude
	)

	local earthVisible = updateMarker(
		earthPart,
		"EARTH",
		earth,
		response.longitude
	)

	local sunStatus = sunVisible
		and "ABOVE HORIZON"
		or "BELOW HORIZON"

	local earthStatus = earthVisible
		and "ABOVE HORIZON"
		or "BELOW HORIZON"

	results.Text = string.format(
		"UTC: %s\n" ..
			"Lunar location: %.3f° S, %.3f° E\n\n" ..
			"SUN: %s\nAz %.2f° | El %.2f°\n\n" ..
			"EARTH: %s\nAz %.2f° | El %.2f°",
		time,
		math.abs(response.latitude),
		response.longitude,
		sunStatus,
		sun.azimuth,
		sun.elevation,
		earthStatus,
		earth.azimuth,
		earth.elevation
	)

end

-- Slider events

sliderButton.InputBegan:Connect(function(input)

	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then

		dragging = true
		setSliderFromMouse(input.Position.X)

	end

end)

UserInputService.InputChanged:Connect(function(input)

	if not dragging then
		return
	end

	if input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch then

		setSliderFromMouse(input.Position.X)

	end

end)

UserInputService.InputEnded:Connect(function(input)

	if dragging and (
		input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		) then

		dragging = false

		task.spawn(fetchHorizons)

	end

end)

-- Manual update button

button.MouseButton1Click:Connect(function()
	fetchHorizons()
end)

-- Initial display
results.Text = "Choose a date and time, then update celestial positions."
