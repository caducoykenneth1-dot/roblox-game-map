-- Edit-mode repair of the existing studded waterfall. No external assets.
local map = workspace:WaitForChild("Phase1Map")
local scenery = map.ArtPass.WaterfallScenery
local stream = map.Landmarks.East_StreamAndWaterfall
local accents = map.ArtPass.MapPolishDetails.FeatureAccents
local history = game:GetService("ChangeHistoryService")
assert(not scenery:GetAttribute("WaterfallRepairV2"), "Waterfall repair already applied")
local recording = history:TryBeginRecording("WaterfallRepairV2", "Reshape and enlarge waterfall and pool")
local backup = Instance.new("Folder")
backup.Name = "WaterfallRepairBackup_20261010"
backup:SetAttribute("Purpose", "Original waterfall, waterway, effects and accents before repair")
for _, root in {scenery, stream, map.WaterEffects, accents} do root:Clone().Parent = backup end
game.StarterPlayer.StarterPlayerScripts.StuddedWaterVisuals:Clone().Parent = backup
backup.Parent = game:GetService("ServerStorage")

local stoneTemplate = scenery:FindFirstChild("PoolShoreStone"):Clone()
local cliffTemplate = scenery:FindFirstChild("FacetedCliffColumn"):Clone()
local plantTemplate = scenery:FindFirstChild("TrailingCliffPlant"):Clone()
local grassTemplate = scenery:FindFirstChild("ClifftopGrass"):Clone()
local reedTemplate = scenery:FindFirstChild("Reed"):Clone()
local waterTemplate = scenery.CascadePool:Clone()
local flowTemplate = scenery.WaterfallFlowDetails:FindFirstChild("WaterfallWaterRill"):Clone()
local foamTemplate = scenery:FindFirstChild("PoolFoam"):Clone()

-- Remove obsolete overlays only after preserving the complete source models.
scenery.WaterfallFlowDetails:Destroy()
for _, part in scenery:GetChildren() do
 if part.Name == "PoolFoam" or part.Name == "PoolShoreStone" or part.Name == "TrailingCliffPlant" then part:Destroy() end
end
for _, part in accents:GetChildren() do
 if part.Name:match("^Cascade") or part.Name:match("^[UL][po][pw]erWaterSheen") or part.Name:find("WaterSheen") then part:Destroy() end
end
map.WaterEffects.WaterfallLipDetails:ClearAllChildren()
local detail = Instance.new("Model")
detail.Name = "WaterfallDetailV2"
detail.Parent = scenery

local function fit(part, size, position)
 part.Size = size
 part.CFrame = CFrame.new(position)
 part.Anchored = true
 return part
end
local function reuse(template, name, size, position, color, solid)
 local part = template:Clone()
 part:ClearAllChildren()
 part.Name = name
 fit(part, size, position)
 if color then part.Color = color end
 part.CanCollide = solid == true
 part.CanTouch = false
 part.CanQuery = solid == true
 part.CastShadow = solid == true
 part.Parent = detail
 return part
end
local function water(part, size, position, transparency)
 fit(part, size, position)
 part.Color = Color3.fromRGB(45, 185, 215)
 part.Transparency = transparency or 0.12
 part.Material = Enum.Material.SmoothPlastic
 part.CanCollide = false
 part.CanTouch = false
 part.CanQuery = false
 part.CastShadow = false
 for _, child in part:GetChildren() do
  if child:IsA("Texture") then child.Transparency = 0.85 end
 end
 return part
end

-- Broaden existing cliff masses and align the rock backing to both drops.
local columns = {}
for _, part in scenery:GetChildren() do
 if part.Name == "FacetedCliffColumn" then table.insert(columns,part) end
end
for _, column in columns do
 local old = column.Position
 local target, size
 if old.X == 165 then
  target, size = Vector3.new(165,23.5,-7), Vector3.new(24,47,27.4)
 elseif old.X == 154 then
  target, size = Vector3.new(150,13.1,-7), Vector3.new(31.2,26.2,32)
 elseif old.X == 158 then
  target, size = Vector3.new(158.5,17.2,-28), Vector3.new(20,34.4,16)
 elseif old.X == 160 then
  target, size = Vector3.new(162,18.8,17), Vector3.new(22,37.6,18)
 else
  target, size = old, column.Size
 end
 for _, part in scenery:GetChildren() do
  if part:IsA("BasePart") and math.abs(part.Position.X-old.X)<0.01 and math.abs(part.Position.Z-old.Z)<0.01 then
   if part.Name == "ClifftopGrass" then
    fit(part,Vector3.new(size.X+0.7,1.3,size.Z+0.7),Vector3.new(target.X,size.Y+0.05,target.Z))
   elseif part.Name == "WeatheredCliffBand" then
    fit(part,Vector3.new(size.X+0.18,0.8,size.Z+0.18),Vector3.new(target.X,size.Y*0.42,target.Z))
    part.Color=Color3.fromRGB(170,192,181)
   end
  end
 end
 fit(column,size,target)
end

fit(scenery.UpperSpringShelf,Vector3.new(23,0.8,30.4),Vector3.new(163.5,47.35,-7))
water(scenery.UpperSpringWater,Vector3.new(22.9,0.5,28.8),Vector3.new(163.4,47.85,-7),0.10)
water(scenery.UpperWaterfall,Vector3.new(1.05,20.65,28.8),Vector3.new(152.5,37.775,-7),0.24)
fit(scenery.CascadeTerrace,Vector3.new(30.5,1.1,34.2),Vector3.new(149,26.68,-7))
water(scenery.CascadePool,Vector3.new(30.5,0.44,32.4),Vector3.new(148.3,27.23,-7),0.10)
water(scenery.LowerWaterfall,Vector3.new(1.15,27.03,31.2),Vector3.new(133.8,13.935,-7),0.24)
scenery.CascadeFootPool.Transparency=1
scenery.CascadeFootPool:SetAttribute("AnimationGuide",true)
scenery.CascadeFootPool.CanQuery=false
fit(scenery.CascadeFootPool,Vector3.new(50.4,0.2,52.8),Vector3.new(131.5,0.25,-3))

-- A single joined water surface removes the old overlapping rectangular pool.
fit(stream.ShallowPool,Vector3.new(50.4,0.2,44),Vector3.new(131.5,0.25,-3))
local sides={}
for _, part in stream:GetChildren() do if part.Name == "SteppedPoolSide" then table.insert(sides,part) end end
for i,part in sides do
 fit(part,Vector3.new(42.4,0.2,4.5),Vector3.new(131.5,0.25,-3+(i==1 and -24.15 or 24.15)))
end
for i=1,4 do
 local guide=stream["ShallowStream_"..i]
 guide.Size=Vector3.new(18.4,0.2,guide.Size.Z+0.6)
 guide.Position=Vector3.new(guide.Position.X,0.25,guide.Position.Z)
 local bank=stream["StreamSandyBank_"..i]
 bank.Size=Vector3.new(23,bank.Size.Y,bank.Size.Z+0.6)
end
stream.StreamEndPool.Size=Vector3.new(18.4,0.2,17)
stream.StreamEndPool.Position=Vector3.new(58,0.25,33)
fit(stream.PoolSandbed,Vector3.new(42.8,0.12,54.2),Vector3.new(131.5,0.10,-3))
local shelfIndex=0
for _,part in stream:GetChildren() do
 if part.Name=="AngularShoreShelf" then
  shelfIndex+=1
  fit(part,Vector3.new(4.7,0.12,45.4),Vector3.new(shelfIndex==1 and 108.6 or 154.4,0.10,-3))
 end
end
local sources={}
for _, part in stream:GetChildren() do
 if part:IsA("BasePart") and part:GetAttribute("AnimationGuide") then
  local copy=part:Clone()
  copy:ClearAllChildren()
  copy.Transparency=0
  copy.Material=Enum.Material.Plastic
  copy.TopSurface=Enum.SurfaceType.Studs
  copy.Color=Color3.fromRGB(43,183,216)
  copy.Anchored=true
  copy.CanCollide=false
  copy.Parent=workspace
  table.insert(sources,copy)
 end
end
local first=table.remove(sources,1)
local ok,joined=pcall(function() return first:UnionAsync(sources,Enum.CollisionFidelity.Box,Enum.RenderFidelity.Precise) end)
if ok then
 joined.Name="ContinuousStuddedWater"
 joined.UsePartColor=true
 joined.Color=Color3.fromRGB(43,183,216)
 joined.Anchored=true
 joined.CanCollide=false
 joined.CanTouch=false
 joined.CanQuery=false
 joined.CastShadow=false
 joined.TopSurface=Enum.SurfaceType.Studs
 local texture=stream.ContinuousStuddedWater:FindFirstChild("AnimatedStudFlow")
 if texture then local copy=texture:Clone() copy.Transparency=0.83 copy.Parent=joined end
 stream.ContinuousStuddedWater:Destroy()
 joined.Parent=stream
else
 error("Pool union failed; original union retained: "..tostring(joined))
end
first:Destroy()
for _,part in sources do part:Destroy() end
task.wait()

local slate=Color3.fromRGB(105,145,145)
local lightSlate=Color3.fromRGB(142,174,167)
local moss=Color3.fromRGB(81,166,109)
-- Reused faceted stone and grass silhouettes frame the cascade with irregular ledges.
local shelves={
 {135.6,7.2,-24.4,5,14.4,5.2},{137.1,15.5,-25.2,5.5,8.0,6.1},
 {137.5,5.5,10.5,6.2,11,5.0},{139.2,19.8,11.2,5.5,8.6,5.0},
 {153.9,34.6,-23.5,5.0,12.8,4.9},{154.7,39.1,9.7,4.6,10.0,5.2},
 {146.1,3.2,-31.7,9.4,6.4,8},{150.7,3.8,23.3,9.4,7.6,7.2},
}
for i,s in shelves do
 local rock=reuse(cliffTemplate,"CascadeRockLedge_"..i,Vector3.new(s[4],s[5],s[6]),Vector3.new(s[1],s[2],s[3]),i%2==0 and slate or lightSlate,true)
 rock.CFrame*=CFrame.Angles(0,math.rad(i%2==0 and 7 or -5),0)
 local cap=reuse(grassTemplate,"MossLedge_"..i,Vector3.new(s[4]+0.15,0.38,s[6]+0.15),Vector3.new(s[1],s[2]+s[5]*0.5,s[3]),moss,false)
 cap.CFrame=rock.CFrame*CFrame.new(0,s[5]*0.5,0)
end

-- Fine flow bands use the same existing rill asset, fitted exactly to each curtain.
local shades={Color3.fromRGB(96,210,228),Color3.fromRGB(169,236,242),Color3.fromRGB(42,169,199)}
for _,fall in {scenery.UpperWaterfall,scenery.LowerWaterfall} do
 for i=1,15 do
  local width=0.20+(i%4)*0.16
  local height=fall.Size.Y*(0.66+(i%3)*0.13)
  local z=fall.Position.Z-fall.Size.Z/2+0.9+(i-1)*(fall.Size.Z-1.8)/14
  local rill=reuse(flowTemplate,fall.Name.."_Rill_"..i,Vector3.new(0.08,height,width),Vector3.new(fall.Position.X-fall.Size.X/2-0.035,fall.Position.Y+(i%3-1)*0.48,z),shades[i%3+1],false)
  rill.Transparency=0.27+(i%3)*0.11
  rill.Material=Enum.Material.SmoothPlastic
  rill.TopSurface=Enum.SurfaceType.Smooth
  rill:SetAttribute("WaterMotion","Rill")
  rill:SetAttribute("BaseTransparency",rill.Transparency)
  rill:SetAttribute("MotionSpeed",1.2+i*0.07)
 end
 -- Foam rests in front of the impact, never behind its cliff face.
 local landingY=fall.Position.Y-fall.Size.Y/2+0.12
 for row=1,2 do
  for i=1,10 do
   local z=fall.Position.Z-fall.Size.Z*0.43+(i-1)*fall.Size.Z*0.086
   local foam=reuse(foamTemplate,fall.Name.."_ImpactFoam_"..row.."_"..i,Vector3.new(1.0+(i%3)*0.40,0.12,1.15+(i%2)*0.6),Vector3.new(fall.Position.X-fall.Size.X/2-0.5-row*0.85,landingY+(row-1)*0.025,z),Color3.fromRGB(216,247,242),false)
   foam.Shape=Enum.PartType.Block
   foam.Material=Enum.Material.SmoothPlastic
   foam.TopSurface=Enum.SurfaceType.Smooth
   foam.Transparency=row==1 and 0.18 or 0.39
   foam.CFrame*=CFrame.Angles(0,math.rad((i%3-1)*11),0)
   foam:SetAttribute("WaterMotion","Foam")
   foam:SetAttribute("MotionAmplitude",0.09)
   foam:SetAttribute("MotionSpeed",1+i*0.08)
  end
 end
 -- Repair and reuse native mist; attachments follow the new landing height.
 for _,child in fall:GetChildren() do
  if child:IsA("Attachment") then child:Destroy() end
 end
 for i=1,3 do
  local attachment=Instance.new("Attachment")
  attachment.Name="LandingMist_"..i
  attachment.Position=Vector3.new(-fall.Size.X/2-0.6,-fall.Size.Y/2+0.4,(i-2)*fall.Size.Z*0.29)
  attachment.Parent=fall
  local emitter=Instance.new("ParticleEmitter")
  emitter.Name="WaterMist"
  emitter.Texture="rbxasset://textures/particles/smoke_main.dds"
  emitter.Color=ColorSequence.new(Color3.fromRGB(207,242,241))
  emitter.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(0.15,0.73),NumberSequenceKeypoint.new(1,1)})
  emitter.Size=NumberSequence.new({NumberSequenceKeypoint.new(0,1.3),NumberSequenceKeypoint.new(1,4.0)})
  emitter.Rate=fall==scenery.LowerWaterfall and 8 or 5
  emitter.Lifetime=NumberRange.new(0.8,1.5)
  emitter.Speed=NumberRange.new(1.2,3.0)
  emitter.Acceleration=Vector3.new(-1.2,0.8,0)
  emitter.SpreadAngle=Vector2.new(30,45)
  emitter.Rotation=NumberRange.new(0,360)
  emitter.RotSpeed=NumberRange.new(-18,18)
  emitter.LightEmission=0.05
  emitter.LightInfluence=0.75
  emitter.Parent=attachment
 end
end

-- Broken shoreline groups around the larger basin, with a clear stream outlet.
local shoreline={
 {110,0.65,-22,4.2,1.8,3.3},{115.4,0.75,-28.5,5.3,2.2,3.7},
 {122.0,0.60,-29.6,3.4,1.7,3.0},{133.0,0.7,-30.1,5.8,2.0,3.6},
 {141.4,0.9,-28.9,4.1,2.7,3.9},{107,0.65,-12.4,3.3,1.9,4.1},
 {106.6,0.55,-3.1,3.5,1.7,3.6},{121.5,0.6,23.2,4.2,1.7,3.2},
 {131.0,0.85,24.0,5.5,2.2,3.7},{141.0,0.65,22.3,4.0,1.8,3.4},
 {148.4,0.9,17.7,4.6,2.8,4.2},
}
for i,s in shoreline do
 local stone=reuse(stoneTemplate,"PoolShoreStone_"..i,Vector3.new(s[4],s[5],s[6]),Vector3.new(s[1],s[2],s[3]),i%3==0 and slate or lightSlate,true)
 stone.CFrame*=CFrame.Angles(math.rad((i%3-1)*6),math.rad(i*31),math.rad((i%2==0 and 1 or -1)*6))
 if i%2==0 then
  local chip=reuse(stoneTemplate,"ShorePebble_"..i,Vector3.new(1.5,0.85,1.3),Vector3.new(s[1]-2,0.32,s[3]+1.3),lightSlate,false)
  chip.CFrame*=CFrame.Angles(0,math.rad(i*19),0)
 end
end
for i,s in {{133.8,24.5,-24.6},{135.0,22.7,-24.8},{136.1,21.2,-24.6},{153.1,45.8,10.0},{153.2,43.7,10.4},{154.1,41.8,10.3}} do
 local plant=reuse(plantTemplate,"TrailingCliffPlant_"..i,Vector3.new(1.2,2.5,1.0),Vector3.new(s[1],s[2],s[3]),moss,false)
 plant.CFrame*=CFrame.Angles(0,math.rad(i*13),math.rad(8))
end
for i,s in {{112,-26},{125,-31},{138,25},{106,-8}} do
 for j=1,3 do
  local height=1.8+j*0.48
  reuse(reedTemplate,"PoolReed_"..i.."_"..j,Vector3.new(0.23,height,0.23),Vector3.new(s[1]+(j-2)*0.43,height/2,s[2]+math.sin(j)*0.4),moss,false)
 end
end
for _,part in scenery:GetChildren() do
 if part:IsA("BasePart") and (part.Name=="LilyLeaf" or part.Name=="WaterBlossom") and part.Position.X>120 then
  local old=part.Position
  local new=old.Z<0 and Vector3.new(117,old.Y,-17) or Vector3.new(136,old.Y,17)
  part.Position=new
  part.CanQuery=false
 end
end
for _,template in {stoneTemplate,cliffTemplate,plantTemplate,grassTemplate,reedTemplate,waterTemplate,flowTemplate,foamTemplate} do template:Destroy() end
scenery:SetAttribute("WaterfallRepairV2",true)
scenery:SetAttribute("WaterfallWidthIncrease",0.2)
scenery:SetAttribute("WaterfallHeight",48.1)
map.WaterEffects:SetAttribute("Validation","Aligned source, cascade and pool; falls widened 20%; enlarged connected basin and stream; V2 details")
game:GetService("Selection"):Set({scenery})
if recording then history:FinishRecording(recording,Enum.FinishRecordingOperation.Commit) end
return {detailParts=#detail:GetDescendants(),upperSize=tostring(scenery.UpperWaterfall.Size),lowerSize=tostring(scenery.LowerWaterfall.Size),poolSize=tostring(scenery.CascadeFootPool.Size),backup=backup:GetFullName()}
