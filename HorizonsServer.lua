local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local remote = ReplicatedStorage:FindFirstChild("FetchHorizons")

if not remote then
	remote = Instance.new("RemoteFunction")
	remote.Name = "FetchHorizons"
	remote.Parent = ReplicatedStorage
end

local MOON_RADIUS = 1737400
local METRES_PER_STUD = 175.78125

local API = "https://ssd.jpl.nasa.gov/api/horizons.api"

-- Convert Roblox terrain coordinates into lunar coordinates.
local function worldToLunar(x, z)

	local projectedX = x * METRES_PER_STUD
	local projectedY = -z * METRES_PER_STUD

	local rho = math.sqrt(
		projectedX^2 + projectedY^2
	)

	local latitudeRad =
		2 * math.atan(rho / (2 * MOON_RADIUS))
	- math.pi / 2

	local longitudeRad = 0

	if rho > 0.001 then
		longitudeRad = math.atan2(projectedX, projectedY)
	end

	local latitude = math.deg(latitudeRad)
	local longitude = math.deg(longitudeRad) % 360

	return latitude, longitude
end

local function getPosition(bodyId, latitude, longitude, date, time)

	local params = {
		format = "json",
		COMMAND = "'" .. bodyId .. "'",
		OBJ_DATA = "'NO'",
		MAKE_EPHEM = "'YES'",
		EPHEM_TYPE = "'OBSERVER'",
		CENTER = "'coord@301'",
		COORD_TYPE = "'GEODETIC'",
		SITE_COORD = string.format(
			"'%.6f,%.6f,0'",
			longitude, latitude
		),
		TLIST = "'" .. date .. " " .. time .. "'",
		TLIST_TYPE = "'CAL'",
		TIME_TYPE = "'UT'",
		QUANTITIES = "'4'",
		CSV_FORMAT = "'YES'"
	}

	local query = {}

	for key, value in pairs(params) do
		table.insert(
			query,
			key .. "=" .. HttpService:UrlEncode(value)
		)
	end

	local url = API .. "?" .. table.concat(query, "&")

	local response = HttpService:GetAsync(url)
	local data = HttpService:JSONDecode(response)

	if data.error then
		error(data.error)
	end

	local tableData = string.match(
		data.result,
		"%$%$SOE%s*(.-)%$%$EOE"
	)

	if not tableData then
		error("No ephemeris data returned")
	end

	local line = string.match(tableData, "[^\r\n]+")

	if not line then
		error("Empty ephemeris result")
	end

	line = string.gsub(line, ",%s*$", "")

	local azimuth, elevation = string.match(
		line,
		",%s*([%-]?[%d%.]+)%s*,%s*([%-]?[%d%.]+)%s*$"
	)

	if not azimuth or not elevation then
		error("Could not parse Horizons coordinates")
	end

	return {
		azimuth = tonumber(azimuth),
		elevation = tonumber(elevation)
	}
end

remote.OnServerInvoke = function(
	player, worldX, worldZ, date, time
)

	worldX = tonumber(worldX)
	worldZ = tonumber(worldZ)

	if not worldX or not worldZ then
		return {ok = false, error = "Invalid spacecraft position"}
	end

	if math.abs(worldX) > 8192 or math.abs(worldZ) > 8192 then
		return {ok = false, error = "Position outside terrain"}
	end

	local latitude, longitude = worldToLunar(worldX, worldZ)

	if latitude < -90 or latitude > -45 then
		return {ok = false, error = "Invalid lunar location"}
	end

	if type(date) ~= "string"
		or not string.match(date, "^%d%d%d%d%-%d%d%-%d%d$") then
		return {ok = false, error = "Invalid date"}
	end

	if type(time) ~= "string"
		or not string.match(time, "^%d%d:%d%d$") then
		return {ok = false, error = "Invalid UTC time"}
	end

	local success, result = pcall(function()

		return {
			Sun = getPosition(
				"10", latitude, longitude, date, time
			),

			Earth = getPosition(
				"399", latitude, longitude, date, time
			)
		}

	end)

	if not success then
		warn("Horizons error:", result)

		return {
			ok = false,
			error = tostring(result)
		}
	end

	return {
		ok = true,
		data = result,
		latitude = latitude,
		longitude = longitude
	}
end
