-- Streaming-aware cosmetic water. Static foam and native spray belong to the map.
-- Reuses 72 small, non-collidable parts; all flow bounds follow the named water parts.
local RunService = game:GetService("RunService")
local map = workspace:WaitForChild("Phase1Map")
local settings = map:WaitForChild("WaterEffects")
local effects = Instance.new("Folder")
effects.Name = "LocalWaterMotion"
effects.Parent = settings

local surfaces, textures, details = {}, {}, {}
local falling, drifting, allParts = {}, {}, {}
local trackedNames = {
	UpperWaterfall = true, LowerWaterfall = true,
	ShallowStream_1 = true, ShallowStream_2 = true,
	ShallowStream_3 = true, ShallowStream_4 = true,
}
local detailCount = 0

local function numberAttribute(item, name, fallback)
	local value = item:GetAttribute(name)
	if typeof(value) == "number" and value == value and math.abs(value) < math.huge then
		return value
	end
	return fallback
end

local function register(item)
	if item:IsA("Texture") and item.Name == "AnimatedStudFlow" then
		if not textures[item] then
			textures[item] = {u = item.OffsetStudsU, v = item.OffsetStudsV}
		end
	elseif item:IsA("BasePart") then
		local parent = item.Parent
		local waterParent = parent and (parent.Name == "East_StreamAndWaterfall" or parent.Name == "WaterfallScenery")
		if waterParent and trackedNames[item.Name] then
			surfaces[item.Name] = item
		end
		local motion = item:GetAttribute("WaterMotion")
		if motion == "Foam" or motion == "Rill" or (waterParent and item.Name == "PoolFoam") then
			if not details[item] then
				detailCount += 1
				details[item] = {
					cf = item.CFrame,
					transparency = item.Transparency,
					baseTransparency = math.clamp(numberAttribute(item, "BaseTransparency", item.Transparency), 0, 1),
					motion = motion or "Foam",
					phase = detailCount * 2.399963,
					amplitude = math.clamp(numberAttribute(item, "MotionAmplitude", 0.12), 0, 0.4),
					speed = math.clamp(numberAttribute(item, "MotionSpeed", 1.1), 0, 4),
				}
			end
		end
	end
end

local added = map.DescendantAdded:Connect(function(item)
	-- A streamed part's attributes may arrive in the same batch as its parenting.
	task.defer(function()
		if item:IsDescendantOf(map) then register(item) end
	end)
end)
local removed = map.DescendantRemoving:Connect(function(item)
	textures[item] = nil
	details[item] = nil
	if surfaces[item.Name] == item then surfaces[item.Name] = nil end
end)
for _, item in ipairs(map:GetDescendants()) do register(item) end

local function makePart(name, size, color)
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.Color = color
	part.Material = Enum.Material.Plastic
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.CastShadow = false
	part.TopSurface = Enum.SurfaceType.Studs
	part.FrontSurface = Enum.SurfaceType.Studs
	part.LeftSurface = Enum.SurfaceType.Studs
	part.RightSurface = Enum.SurfaceType.Studs
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Transparency = 1
	part.Parent = effects
	table.insert(allParts, part)
	return part
end

for tier, name in ipairs({"UpperWaterfall", "LowerWaterfall"}) do
	local count = tier == 1 and 18 or 22
	for i = 1, count do
		local length = 1.3 + (i % 4) * 0.45
		local width = 0.28 + (i % 3) * 0.16
		table.insert(falling, {
			part = makePart("FallingWaterBrick", Vector3.new(0.16, length, width), Color3.fromRGB(197, 243, 249)),
			name = name, length = length, width = width,
			phase = i / count, lane = (i * 0.61803398875) % 1 - 0.5,
			speed = (tier == 1 and 11 or 14) + (i % 3) * 0.65,
		})
	end
end

for i = 1, 4 do
	for j = 1, 8 do
		table.insert(drifting, {
			part = makePart("DriftingStudFoam", Vector3.new(0.5 + (j % 4) * 0.16, 0.09, 0.35 + (j % 3) * 0.15), Color3.fromRGB(208, 247, 242)),
			name = "ShallowStream_" .. i, phase = j / 8, lane = (j - 4.5) / 8,
		})
	end
end
settings:SetAttribute("LocalPooledPartCount", #allParts)

local function restoreDetails()
	for part, item in pairs(details) do
		if part.Parent then
			part.CFrame = item.cf
			part.Transparency = item.transparency
		end
	end
end

local function hide()
	for _, part in ipairs(allParts) do part.Transparency = 1 end
	restoreDetails()
end

local function nearWater(cameraPosition, viewDistance)
	local distanceSquared = viewDistance * viewDistance
	for _, part in pairs(surfaces) do
		local localPosition = part.CFrame:PointToObjectSpace(cameraPosition)
		local half = part.Size * 0.5
		local dx = math.max(math.abs(localPosition.X) - half.X, 0)
		local dy = math.max(math.abs(localPosition.Y) - half.Y, 0)
		local dz = math.max(math.abs(localPosition.Z) - half.Z, 0)
		if dx * dx + dy * dy + dz * dz <= distanceSquared then return true end
	end
	return false
end

local elapsed, accumulated, tickCount = 0, 0, 0
local active, cleaned = false, false
local connection

local function cleanup()
	if cleaned then return end
	cleaned = true
	if connection then connection:Disconnect() end
	added:Disconnect()
	removed:Disconnect()
	restoreDetails()
	for texture, original in pairs(textures) do
		if texture.Parent then
			texture.OffsetStudsU = original.u
			texture.OffsetStudsV = original.v
		end
	end
	effects:Destroy()
end

connection = RunService.Heartbeat:Connect(function(dt)
	if not map.Parent or not settings.Parent then cleanup(); return end
	elapsed += dt
	accumulated += dt
	local interval = 1 / math.clamp(numberAttribute(settings, "UpdateRate", 30), 5, 60)
	if accumulated < interval then return end
	accumulated %= interval
	local camera = workspace.CurrentCamera
	local enabled = settings:GetAttribute("Enabled") ~= false and camera ~= nil
		and nearWater(camera.CFrame.Position, math.clamp(numberAttribute(settings, "ViewDistance", 240), 20, 1000))
	if enabled ~= active then settings:SetAttribute("LocalEffectsActive", enabled) end
	if not enabled then
		if active then hide() end
		active = false
		return
	end
	active = true

	for texture in pairs(textures) do
		texture.OffsetStudsU = (elapsed * numberAttribute(texture, "SpeedU", 0)) % math.max(texture.StudsPerTileU, 0.01)
		texture.OffsetStudsV = (elapsed * numberAttribute(texture, "SpeedV", 0)) % math.max(texture.StudsPerTileV, 0.01)
	end

	for _, item in ipairs(falling) do
		local face, part = surfaces[item.name], item.part
		if face and face.Size.Y > 0.2 and face.Size.Z > 0.2 then
			local length = math.min(item.length, face.Size.Y * 0.35)
			local width = math.min(item.width, face.Size.Z * 0.2)
			local size = Vector3.new(0.16, length, width)
			if part.Size ~= size then part.Size = size end
			local usable = math.max(face.Size.Y - length - 0.06, 0.05)
			local u = (elapsed * item.speed / usable + item.phase) % 1
			local progress = 0.35 * u + 0.65 * u * u
			local laneWidth = math.max(face.Size.Z - width - 0.24, 0)
			local sway = math.sin(elapsed * 1.6 + item.phase * 12) * math.min(0.07, laneWidth * 0.03)
			part.CFrame = face.CFrame * CFrame.new(-face.Size.X / 2 - 0.11, usable / 2 - progress * usable, item.lane * laneWidth + sway)
			local edgeFade = 1 - math.clamp(math.min(u, 1 - u) * 9, 0, 1)
			part.Transparency = 0.4 + 0.6 * edgeFade
		else
			part.Transparency = 1
		end
	end

	for _, item in ipairs(drifting) do
		local surface, part = surfaces[item.name], item.part
		if surface and surface.Size.Z > part.Size.Z + 0.1 and surface.Size.X > part.Size.X + 0.1 then
			local length = math.max(surface.Size.Z - math.max(4, part.Size.Z + 0.1), 0.05)
			local u = (elapsed * 2.8 / length + item.phase) % 1
			local laneWidth = math.max(surface.Size.X - part.Size.X - 0.3, 0)
			part.CFrame = surface.CFrame * CFrame.new(item.lane * laneWidth, surface.Size.Y / 2 + 0.06, length / 2 - u * length)
			part.Transparency = 0.4 + 0.6 * (1 - math.clamp(math.min(u, 1 - u) * 8, 0, 1))
		else
			part.Transparency = 1
		end
	end

	for part, item in pairs(details) do
		local wave = elapsed * item.speed + item.phase
		if item.motion == "Rill" then
			-- Rills retain their fitted shape while gently varying their highlight.
			part.Transparency = math.clamp(item.baseTransparency + math.sin(wave) * 0.06, 0, 1)
		else
			part.CFrame = item.cf + Vector3.new(math.sin(wave) * item.amplitude, math.sin(wave * 1.3) * 0.012, math.cos(wave * 0.8) * item.amplitude * 0.35)
			part.Transparency = math.clamp(item.baseTransparency + (math.sin(wave * 1.2) + 1) * 0.055, 0, 1)
		end
	end

	tickCount += 1
	if tickCount % 30 == 0 then
		local textureCount, boundDetails = 0, 0
		for _ in pairs(textures) do textureCount += 1 end
		for _ in pairs(details) do boundDetails += 1 end
		settings:SetAttribute("LocalBoundTextures", textureCount)
		settings:SetAttribute("LocalBoundDetails", boundDetails)
		settings:SetAttribute("LocalAnimationTicks", tickCount)
	end
end)
script.Destroying:Connect(cleanup)
