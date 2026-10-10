-- Final palette and finishing pass, applied after reshape-waterfall.luau in Edit mode.
local map = workspace.Phase1Map
local scenery = map.ArtPass.WaterfallScenery
local detail = scenery.WaterfallDetailV2
local stream = map.Landmarks.East_StreamAndWaterfall
local history = game:GetService("ChangeHistoryService")
assert(not scenery:GetAttribute("WaterfallFinishingRecorded"), "Finishing pass already applied")
local recording = history:TryBeginRecording("WaterfallFinishing", "Finish waterfall with cheerful aqua and mint")
local rng = Random.new(381)
for _, part in detail:GetChildren() do
 if part:IsA("BasePart") and part:GetAttribute("WaterMotion") == "Foam" then
  part.Size = Vector3.new(rng:NextNumber(0.65, 2.25), 0.10, rng:NextNumber(0.55, 1.6))
  part.CFrame = part.CFrame * CFrame.new(rng:NextNumber(-0.5, 0.45), 0, rng:NextNumber(-0.6, 0.6)) * CFrame.Angles(0, math.rad(rng:NextNumber(-22, 22)), 0)
 end
end
for _, part in scenery:GetChildren() do
 if part:IsA("BasePart") and part.Name == "Reed" and part.Position.X > 105 and part.Position.X < 125 then
  local p = part.Position
  if p.X > 116 then
   part.Position = Vector3.new(p.X - 15, p.Y, -10 + (p.Z + 4))
  elseif p.Z < 10 then
   part.Position = Vector3.new(p.X - 2, p.Y, -24 + (p.Z - 7))
  end
 end
end
for _, fall in {scenery.UpperWaterfall, scenery.LowerWaterfall} do
 for _, attachment in fall:GetChildren() do
  if attachment:IsA("Attachment") and not attachment:FindFirstChild("WaterDroplets") then
   local emitter = Instance.new("ParticleEmitter")
   emitter.Name = "WaterDroplets"
   emitter.Texture = "rbxasset://textures/particles/smoke_main.dds"
   emitter.Color = ColorSequence.new(Color3.fromRGB(218, 251, 251))
   emitter.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.2), NumberSequenceKeypoint.new(0.5, 0.3), NumberSequenceKeypoint.new(1, 1)})
   emitter.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.18), NumberSequenceKeypoint.new(0.5, 0.25), NumberSequenceKeypoint.new(1, 0.06)})
   emitter.Rate = 9
   emitter.Lifetime = NumberRange.new(0.45, 0.8)
   emitter.Speed = NumberRange.new(3, 6)
   emitter.Acceleration = Vector3.new(-3, -13, 0)
   emitter.SpreadAngle = Vector2.new(30, 60)
   emitter.LightEmission = 0.12
   emitter.LightInfluence = 0.6
   emitter.Parent = attachment
  end
 end
end
local rocks = {Color3.fromRGB(173, 204, 195), Color3.fromRGB(183, 211, 200), Color3.fromRGB(161, 195, 190)}
local count = 0
for _, part in scenery:GetDescendants() do
 if part:IsA("BasePart") then
  local name = part.Name
  if name == "FacetedCliffColumn" or name:find("CascadeRockLedge") then
   count += 1
   part.Color = rocks[count % 3 + 1]
  elseif name == "WeatheredCliffBand" or name == "UpperSpringShelf" or name == "CascadeTerrace" then
   part.Color = Color3.fromRGB(204, 224, 204)
  elseif name == "ClifftopGrass" or name:find("MossLedge") then
   part.Color = Color3.fromRGB(129, 224, 150)
  elseif name:find("TrailingCliffPlant") or name:find("Reed") then
   part.Color = Color3.fromRGB(96, 194, 135)
  elseif name:find("PoolShoreStone") or name:find("ShorePebble") then
   part.Color = Color3.fromRGB(189, 216, 207)
  elseif name == "UpperWaterfall" or name == "LowerWaterfall" then
   part.Color = Color3.fromRGB(103, 214, 231)
   part.Transparency = 0.20
  elseif name == "UpperSpringWater" or name == "CascadePool" then
   part.Color = Color3.fromRGB(104, 218, 232)
   part.Transparency = 0.08
  elseif name:find("_Rill_") then
   local index = tonumber(name:match("_(%d+)$")) or 1
   local shades = {Color3.fromRGB(143, 233, 240), Color3.fromRGB(214, 250, 247), Color3.fromRGB(94, 204, 222)}
   part.Color = shades[index % 3 + 1]
  elseif name:find("ImpactFoam") then
   part.Color = Color3.fromRGB(234, 255, 248)
  elseif name == "WaterBlossom" then
   part.Color = Color3.fromRGB(255, 189, 209)
  elseif name == "LilyLeaf" then
   part.Color = Color3.fromRGB(138, 216, 148)
  end
 end
end
stream.ContinuousStuddedWater.Color = Color3.fromRGB(84, 205, 226)
for _, part in stream:GetChildren() do
 if part:IsA("BasePart") then
  if part.Name:find("Sand") or part.Name == "AngularShoreShelf" then part.Color = Color3.fromRGB(237, 224, 177) end
  if part:GetAttribute("AnimationGuide") then
   part.CanCollide = false
   part.CanQuery = false
   part.CanTouch = false
  end
 end
end
scenery.LowerWaterfall.Size = Vector3.new(1.15, 27.15, 31.2)
scenery.LowerWaterfall.Position = Vector3.new(133.8, 13.875, -7)
for _, part in detail:GetChildren() do
 if part:IsA("BasePart") and part.Name:find("LowerWaterfall_ImpactFoam") then
  part.Position = Vector3.new(part.Position.X, 0.42, part.Position.Z)
 end
end
scenery:SetAttribute("Palette", "Cheerful pale aqua, mint, warm sage stone, pastel pink blossoms")
scenery:SetAttribute("WaterfallFinishingRecorded", true)
if recording then history:FinishRecording(recording, Enum.FinishRecordingOperation.Commit) end
return "Waterfall finishing applied"
