----------------------------------------------------------------------------------------
-- F3X / Fork3X Model Importer — COMPACT + CLICK TO PLACE
----------------------------------------------------------------------------------------
local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local CoreGui          = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Mouse       = LocalPlayer:GetMouse()

local PRESET_BUILDS = {
	{ Name = "Villager house",       ID = "7021878884"      },
	{ Name = "Classic house",        ID = "8959904556"      },
	{ Name = "Head",                 ID = "6701243463"      },
	{ Name = "Noob Model",           ID = "4446576906"      },
	{ Name = "Posed rigs",           ID = "127964771902906" },
	{ Name = "Tung Tung model",      ID = "138151705692565" },
	{ Name = "Baseplate",            ID = "12333757276"     },
	{ Name = "giant Maxwell cat",    ID = "11390853367"     },
	{ Name = "Mcdonalds",            ID = "9281768993"      },
	{ Name = "Small Verity",         ID = "119402344637044" },
	{ Name = "Crossroads",           ID = "18631504779"     },
	{ Name = "Slap Tower obby HUGE", ID = "127892190707313" },
	{ Name = "Parts to use",         ID = "71401680377675"  },
	{ Name = "Small Obby",           ID = "9345150660"      },
	{ Name = "Rainbow stairs",       ID = "72358687892729"  },
	{ Name = "Normal House",         ID = "6803387316"      },
	{ Name = "City map",             ID = "92781618724300"  },
	{ Name = "Backrooms",            ID = "10581711055"     },
	{ Name = "Steal a brainrot map", ID = "101491434169003" },
	{ Name = "long obby",            ID = "121219424139703" },
	{ Name = "road",                 ID = "14102233829"     },
}

local oldGui = CoreGui:FindFirstChild("Fork3X_Importer")
	or LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("Fork3X_Importer")
if oldGui then oldGui:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Fork3X_Importer"
ScreenGui.ResetOnSpawn = false
pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

-- ─── compact window 340×240 ───────────────────────────────────────────────────
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 340, 0, 240)
MainFrame.Position = UDim2.new(0.5, -170, 0.5, -120)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui
local ms = Instance.new("UIStroke", MainFrame)
ms.Color = Color3.fromRGB(45, 45, 45); ms.Thickness = 1.5

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 32)
TopBar.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -80, 1, 0)
TitleLabel.Position = UDim2.new(0, 10, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "F3X Model Importer"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 12
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TopBar

local function makeTopBtn(xOff, label)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(0, 32, 0, 32)
	b.Position = UDim2.new(1, xOff, 0, 0)
	b.BackgroundTransparency = 1
	b.Text = label
	b.TextColor3 = Color3.fromRGB(200, 200, 200)
	b.Font = Enum.Font.GothamBold
	b.TextSize = 13
	b.Parent = TopBar
	return b
end
local CloseBtn = makeTopBtn(-32, "✕")
local MinBtn   = makeTopBtn(-64, "—")
CloseBtn.MouseEnter:Connect(function() CloseBtn.TextColor3 = Color3.fromRGB(255,80,80) end)
CloseBtn.MouseLeave:Connect(function() CloseBtn.TextColor3 = Color3.fromRGB(200,200,200) end)

-- viewport 120×120
local VPContainer = Instance.new("Frame")
VPContainer.Size = UDim2.new(0, 120, 0, 120)
VPContainer.Position = UDim2.new(0, 10, 0, 42)
VPContainer.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
VPContainer.BorderSizePixel = 0
VPContainer.Active = true
VPContainer.Parent = MainFrame
Instance.new("UIStroke", VPContainer).Color = Color3.fromRGB(55, 55, 55)

local ViewportFrame = Instance.new("ViewportFrame")
ViewportFrame.Size = UDim2.new(1, 0, 1, 0)
ViewportFrame.BackgroundTransparency = 1
ViewportFrame.Parent = VPContainer

local VPCamera = Instance.new("Camera")
ViewportFrame.CurrentCamera = VPCamera

local PreviewLabel = Instance.new("TextLabel")
PreviewLabel.Size = UDim2.new(1, 0, 1, 0)
PreviewLabel.BackgroundTransparency = 1
PreviewLabel.Text = "No Preview\n(drag to spin)"
PreviewLabel.TextColor3 = Color3.fromRGB(90, 90, 90)
PreviewLabel.Font = Enum.Font.Gotham
PreviewLabel.TextSize = 10
PreviewLabel.Parent = VPContainer

-- right-side controls
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -145, 0, 190)
Content.Position = UDim2.new(0, 138, 0, 38)
Content.BackgroundTransparency = 1
Content.Parent = MainFrame

local Layout = Instance.new("UIListLayout")
Layout.SortOrder = Enum.SortOrder.LayoutOrder
Layout.Padding = UDim.new(0, 6)
Layout.Parent = Content

local IdInput = Instance.new("TextBox")
IdInput.Size = UDim2.new(1, 0, 0, 32)
IdInput.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
IdInput.TextColor3 = Color3.fromRGB(255, 255, 255)
IdInput.PlaceholderText = "Asset / Model ID..."
IdInput.Text = ""
IdInput.Font = Enum.Font.Gotham
IdInput.TextSize = 12
IdInput.ClearTextOnFocus = false
IdInput.LayoutOrder = 1
IdInput.BorderSizePixel = 0
IdInput.Parent = Content
Instance.new("UIStroke", IdInput).Color = Color3.fromRGB(55, 55, 55)

local DropdownBtn = Instance.new("TextButton")
DropdownBtn.Size = UDim2.new(1, 0, 0, 28)
DropdownBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
DropdownBtn.TextColor3 = Color3.fromRGB(190, 190, 190)
DropdownBtn.Text = "Preset Builds ▼"
DropdownBtn.Font = Enum.Font.GothamSemibold
DropdownBtn.TextSize = 11
DropdownBtn.LayoutOrder = 2
DropdownBtn.BorderSizePixel = 0
DropdownBtn.Parent = Content

local DropdownList = Instance.new("ScrollingFrame")
DropdownList.Size = UDim2.new(1, 0, 0, 0)
DropdownList.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
DropdownList.BorderSizePixel = 0
DropdownList.ScrollBarThickness = 3
DropdownList.ClipsDescendants = true
DropdownList.LayoutOrder = 3
DropdownList.Parent = Content
local ListLayout = Instance.new("UIListLayout")
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ListLayout.Parent = DropdownList

local ActionsFrame = Instance.new("Frame")
ActionsFrame.Size = UDim2.new(1, 0, 0, 34)
ActionsFrame.BackgroundTransparency = 1
ActionsFrame.LayoutOrder = 4
ActionsFrame.Parent = Content

local ImportBtn = Instance.new("TextButton")
ImportBtn.Size = UDim2.new(0.65, -3, 1, 0)
ImportBtn.Position = UDim2.new(0, 0, 0, 0)
ImportBtn.BackgroundColor3 = Color3.fromRGB(0, 110, 200)
ImportBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ImportBtn.Text = "Spawn Model"
ImportBtn.Font = Enum.Font.GothamBold
ImportBtn.TextSize = 12
ImportBtn.BorderSizePixel = 0
ImportBtn.Parent = ActionsFrame

local StopBtn = Instance.new("TextButton")
StopBtn.Size = UDim2.new(0.35, -3, 1, 0)
StopBtn.Position = UDim2.new(0.65, 3, 0, 0)
StopBtn.BackgroundColor3 = Color3.fromRGB(175, 40, 40)
StopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
StopBtn.Text = "Stop"
StopBtn.Font = Enum.Font.GothamBold
StopBtn.TextSize = 12
StopBtn.BorderSizePixel = 0
StopBtn.Parent = ActionsFrame

local function hover(b, on, off)
	b.MouseEnter:Connect(function() TweenService:Create(b,TweenInfo.new(0.12),{BackgroundColor3=on}):Play() end)
	b.MouseLeave:Connect(function() TweenService:Create(b,TweenInfo.new(0.12),{BackgroundColor3=off}):Play() end)
end
hover(ImportBtn,   Color3.fromRGB(20,140,230),  Color3.fromRGB(0,110,200))
hover(StopBtn,     Color3.fromRGB(210,55,55),   Color3.fromRGB(175,40,40))
hover(DropdownBtn, Color3.fromRGB(38,38,38),    Color3.fromRGB(28,28,28))

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -10, 0, 28)
StatusLabel.Position = UDim2.new(0, 8, 1, -30)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Ready — enter an ID or pick a preset."
StatusLabel.TextColor3 = Color3.fromRGB(140, 140, 140)
StatusLabel.TextSize = 11
StatusLabel.TextWrapped = true
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = MainFrame

-- cursor stud label
local StudsLabel = Instance.new("TextLabel")
StudsLabel.Size = UDim2.new(0, 160, 0, 22)
StudsLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
StudsLabel.BackgroundTransparency = 0.45
StudsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
StudsLabel.Text = ""
StudsLabel.Font = Enum.Font.GothamBold
StudsLabel.TextSize = 11
StudsLabel.Visible = false
StudsLabel.BorderSizePixel = 0
StudsLabel.Parent = ScreenGui

-- ─── viewport drag-to-spin ────────────────────────────────────────────────────
local isDragging = false
local lastMP = Vector2.new()
local vpAX, vpAY = -45, -30
local vpDist, vpCenter = 10, Vector3.new()

local function updateVPCam()
	local r = CFrame.Angles(0,math.rad(vpAX),0)*CFrame.Angles(math.rad(vpAY),0,0)
	VPCamera.CFrame = CFrame.new(vpCenter + r.LookVector*vpDist, vpCenter)
end

VPContainer.InputBegan:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 then isDragging=true; lastMP=i.Position end
end)
UserInputService.InputEnded:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 then isDragging=false end
end)
UserInputService.InputChanged:Connect(function(i)
	if isDragging and i.UserInputType == Enum.UserInputType.MouseMovement then
		local d = i.Position - lastMP; lastMP=i.Position
		vpAX -= d.X
		vpAY = math.clamp(vpAY - d.Y, -85, 85)
		updateVPCam()
	end
end)

-- ─── helpers ──────────────────────────────────────────────────────────────────
local function SafeGetObjects(id)
	local result, loaded = nil, false
	task.spawn(function()
		local ok, raw = pcall(function() return game:GetObjects("rbxassetid://"..tostring(id)) end)
		if ok and raw and #raw > 0 then result = raw[1] end
		loaded = true
	end)
	local t = 0
	while not loaded and t < 8 do task.wait(0.1); t+=0.1 end
	return result
end

local function GetBBox(obj)
	local parts = {}
	if obj:IsA("BasePart") then table.insert(parts, obj) end
	for _, d in ipairs(obj:GetDescendants()) do
		if d:IsA("BasePart") then table.insert(parts, d) end
	end
	if #parts == 0 then return CFrame.new(), Vector3.new(4,1,2) end
	local mnX,mnY,mnZ = math.huge,math.huge,math.huge
	local mxX,mxY,mxZ = -math.huge,-math.huge,-math.huge
	for _, p in ipairs(parts) do
		local cf, s = p.CFrame, p.Size/2
		for _,c in ipairs({
			cf*Vector3.new(-s.X,-s.Y,-s.Z), cf*Vector3.new(s.X,-s.Y,-s.Z),
			cf*Vector3.new(-s.X,s.Y,-s.Z),  cf*Vector3.new(s.X,s.Y,-s.Z),
			cf*Vector3.new(-s.X,-s.Y,s.Z),  cf*Vector3.new(s.X,-s.Y,s.Z),
			cf*Vector3.new(-s.X,s.Y,s.Z),   cf*Vector3.new(s.X,s.Y,s.Z),
		}) do
			mnX=math.min(mnX,c.X); mnY=math.min(mnY,c.Y); mnZ=math.min(mnZ,c.Z)
			mxX=math.max(mxX,c.X); mxY=math.max(mxY,c.Y); mxZ=math.max(mxZ,c.Z)
		end
	end
	local center = Vector3.new((mnX+mxX)/2,(mnY+mxY)/2,(mnZ+mxZ)/2)
	local size   = Vector3.new(mxX-mnX,mxY-mnY,mxZ-mnZ)
	return CFrame.new(center), size
end

local function GetF3X()
	local char = LocalPlayer.Character
	local bp   = LocalPlayer:FindFirstChild("Backpack")
	local tool = (char and char:FindFirstChild("Building Tools"))
	          or (bp   and bp:FindFirstChild("Building Tools"))
	if tool and tool:FindFirstChild("SyncAPI") and tool.SyncAPI:FindFirstChild("ServerEndpoint") then
		return tool.SyncAPI.ServerEndpoint
	end
end

local function MapPartType(part)
	if part:IsA("WedgePart")       then return "Wedge"    end
	if part:IsA("CornerWedgePart") then return "Corner"   end
	if part:IsA("TrussPart")       then return "Truss"    end
	if part:IsA("Part") then
		if part.Shape == Enum.PartType.Ball     then return "Sphere"   end
		if part.Shape == Enum.PartType.Cylinder then return "Cylinder" end
	end
	return "Normal"
end

local function ProcessMesh(part, created)
	if part:IsA("MeshPart") then
		local ms = part.MeshSize
		local sc = (ms.X>0.001 and ms.Y>0.001 and ms.Z>0.001) and part.Size/ms or part.Size
		return {Part=created}, {Part=created, MeshType=Enum.MeshType.FileMesh,
			MeshId=part.MeshId, TextureId=part.TextureID or "",
			Scale=sc, Offset=Vector3.new(0,0,0), VertexColor=Vector3.new(1,1,1)}
	end
	local sm = part:FindFirstChildWhichIsA("SpecialMesh")
	if sm then
		return {Part=created}, {Part=created, MeshType=sm.MeshType,
			MeshId=sm.MeshId, TextureId=sm.TextureId,
			Scale=sm.Scale, Offset=sm.Offset, VertexColor=sm.VertexColor}
	end
	return nil, nil
end

local function GetRaycastHit()
	local ray = Mouse.UnitRay
	local params = RaycastParams.new()
	if LocalPlayer.Character then
		params.FilterDescendantsInstances = {LocalPlayer.Character}
		params.FilterType = Enum.RaycastFilterType.Exclude
	end
	local result = workspace:Raycast(ray.Origin, ray.Direction * 2000, params)
	return result and result.Position or Mouse.Hit.Position
end

-- ─── preview ─────────────────────────────────────────────────────────────────
local previewBusy = false
local function UpdatePreview(id)
	if previewBusy then return end
	previewBusy = true
	PreviewLabel.Text = "Loading..."
	ViewportFrame:ClearAllChildren()
	task.spawn(function()
		local model = SafeGetObjects(id)
		if not model then PreviewLabel.Text = "Failed"; previewBusy=false; return end
		model.Parent = ViewportFrame
		local cf, sz = GetBBox(model)
		vpDist   = math.max(sz.X,sz.Y,sz.Z) * 1.5
		vpCenter = cf.Position
		vpAX, vpAY = -45, -30
		updateVPCam()
		PreviewLabel.Text = ""
		previewBusy = false
	end)
end

IdInput.FocusLost:Connect(function()
	local id = IdInput.Text:match("%d+")
	if id then UpdatePreview(id) end
end)

-- ─── preset dropdown ──────────────────────────────────────────────────────────
for i, d in ipairs(PRESET_BUILDS) do
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1,0,0,26)
	b.BackgroundColor3 = Color3.fromRGB(28,28,28)
	b.BackgroundTransparency = 1
	b.TextColor3 = Color3.fromRGB(190,190,190)
	b.Text = "  "..d.Name
	b.Font = Enum.Font.Gotham
	b.TextSize = 11
	b.TextXAlignment = Enum.TextXAlignment.Left
	b.LayoutOrder = i
	b.BorderSizePixel = 0
	b.Parent = DropdownList
	b.MouseEnter:Connect(function() b.BackgroundTransparency=0 end)
	b.MouseLeave:Connect(function() b.BackgroundTransparency=1 end)
	b.MouseButton1Click:Connect(function()
		IdInput.Text = d.ID
		DropdownBtn.Text = d.Name.." ▲"
		TweenService:Create(DropdownList,TweenInfo.new(0.25),{Size=UDim2.new(1,0,0,0)}):Play()
		TweenService:Create(MainFrame,TweenInfo.new(0.25),{Size=UDim2.new(0,340,0,240)}):Play()
		UpdatePreview(d.ID)
	end)
end

local dropOpen = false
DropdownBtn.MouseButton1Click:Connect(function()
	dropOpen = not dropOpen
	local h = dropOpen and 90 or 0
	TweenService:Create(DropdownList,TweenInfo.new(0.25,Enum.EasingStyle.Quint),{Size=UDim2.new(1,0,0,h)}):Play()
	TweenService:Create(MainFrame,TweenInfo.new(0.25,Enum.EasingStyle.Quint),{Size=UDim2.new(0,340,0,dropOpen and 330 or 240)}):Play()
	DropdownBtn.Text = dropOpen and "Preset Builds ▲" or "Preset Builds ▼"
end)

local minimized = false
MinBtn.MouseButton1Click:Connect(function()
	minimized = not minimized
	dropOpen = false
	DropdownList.Size = UDim2.new(1,0,0,0)
	DropdownBtn.Text = "Preset Builds ▼"
	TweenService:Create(MainFrame,TweenInfo.new(0.35,Enum.EasingStyle.Quint),{
		Size = minimized and UDim2.new(0,340,0,32) or UDim2.new(0,340,0,240)
	}):Play()
end)

CloseBtn.MouseButton1Click:Connect(function()
	currentBuildToken = -1
	TweenService:Create(MainFrame,TweenInfo.new(0.25),{Size=UDim2.new(0,340,0,0)}):Play()
	task.wait(0.25); ScreenGui:Destroy()
end)

MainFrame.Size = UDim2.new(0,0,0,0)
TweenService:Create(MainFrame,TweenInfo.new(0.45,Enum.EasingStyle.Back,Enum.EasingDirection.Out),
	{Size=UDim2.new(0,340,0,240)}):Play()

-- ─── BUILD ENGINE ─────────────────────────────────────────────────────────────
local currentBuildToken = 0

local function BuildModel(assetId, spawnHitPosition)
	local endpoint = GetF3X()
	if not endpoint then
		StatusLabel.Text = "⚠️ Equip F3X tool first!"
		StatusLabel.TextColor3 = Color3.fromRGB(255,80,80)
		return
	end

	StatusLabel.Text = "Downloading..."
	StatusLabel.TextColor3 = Color3.fromRGB(255,200,80)

	local root = SafeGetObjects(assetId)
	if not root then
		StatusLabel.Text = "⚠️ Failed to load asset."
		StatusLabel.TextColor3 = Color3.fromRGB(255,80,80)
		return
	end

	local bboxCF, bboxSize = GetBBox(root)
	local spawnCF = CFrame.new(spawnHitPosition) * CFrame.new(0, bboxSize.Y/2, 0)

	local parts = {}
	if root:IsA("BasePart") then table.insert(parts, root) end
	for _, d in ipairs(root:GetDescendants()) do
		if d:IsA("BasePart") then table.insert(parts, d) end
	end

	if #parts == 0 then
		StatusLabel.Text = "No BaseParts in model."
		StatusLabel.TextColor3 = Color3.fromRGB(255,80,80)
		root:Destroy(); return
	end

	local myToken = tick()
	currentBuildToken = myToken
	local t0 = os.clock()

	StatusLabel.Text = string.format("⚡ Spawning %d parts...", #parts)
	StatusLabel.TextColor3 = Color3.fromRGB(100,255,130)

	task.spawn(function()
		local mapping = {}
		local resizeB,colorB,matB,anchorB,finalB = {},{},{},{},{}
		local cMeshB,sMeshB,texB = {},{},{}

		local MAX = 150
		local active = 0
		local sig = Instance.new("BindableEvent")
		local base = bboxCF

		for idx, part in ipairs(parts) do
			if currentBuildToken ~= myToken then
				StatusLabel.Text = "Cancelled."
				StatusLabel.TextColor3 = Color3.fromRGB(255,100,100)
				root:Destroy(); return
			end

			while active >= MAX do sig.Event:Wait() end
			active += 1

			task.spawn(function()
				local cf = spawnCF * base:ToObjectSpace(part.CFrame)
				local ok, created = pcall(function()
					return endpoint:InvokeServer("CreatePart", MapPartType(part), cf, workspace)
				end)
				if ok and created then
					mapping[part] = created
					table.insert(resizeB, {Part=created, CFrame=cf, Size=part.Size})
					table.insert(colorB,  {Part=created, Color=part.Color})
					table.insert(matB,    {Part=created, Material=part.Material, Transparency=part.Transparency})
					table.insert(anchorB, {Part=created, Anchored=true})
					table.insert(finalB,  {Part=created, Anchored=part.Anchored})
					local cM,sM = ProcessMesh(part,created)
					if cM then table.insert(cMeshB,cM); table.insert(sMeshB,sM) end
					local hasT = false
					for _,c in ipairs(part:GetChildren()) do
						if c:IsA("Texture") or c:IsA("Decal") or c:IsA("SurfaceAppearance") then hasT=true; break end
					end
					if hasT then table.insert(texB,{src=part,dst=created}) end
				end
				active -= 1; sig:Fire()
			end)

			if idx % 50 == 0 then
				StatusLabel.Text = string.format("Spawning %d / %d", idx, #parts)
				task.wait()
			end
		end

		while active > 0 do sig.Event:Wait() end
		sig:Destroy()
		if currentBuildToken ~= myToken then return end

		StatusLabel.Text = "Applying properties..."
		pcall(function()
			if #resizeB > 0 then endpoint:InvokeServer("SyncResize",   resizeB) end
			if #colorB  > 0 then endpoint:InvokeServer("SyncColor",    colorB)  end
			if #matB    > 0 then endpoint:InvokeServer("SyncMaterial", matB)    end
			if #anchorB > 0 then endpoint:InvokeServer("SyncAnchor",   anchorB) end
			if #cMeshB  > 0 then endpoint:InvokeServer("CreateMeshes", cMeshB)  end
			if #sMeshB  > 0 then endpoint:InvokeServer("SyncMesh",     sMeshB)  end
		end)

		if #texB > 0 then
			StatusLabel.Text = "Textures..."
			for _, e in ipairs(texB) do
				for _, c in ipairs(e.src:GetChildren()) do
					if c:IsA("Texture") or c:IsA("Decal") or c:IsA("SurfaceAppearance") then
						pcall(function() c:Clone().Parent = e.dst end)
					end
				end
			end
		end

		StatusLabel.Text = "Joints..."
		for _, d in ipairs(root:GetDescendants()) do
			if d:IsA("Weld") or d:IsA("WeldConstraint") or d:IsA("Motor6D") then
				local p0,p1 = mapping[d.Part0], mapping[d.Part1]
				if p0 and p1 then
					pcall(function()
						local w = Instance.new(d.ClassName)
						w.Part0=p0; w.Part1=p1
						if w:IsA("Weld") or w:IsA("Motor6D") then w.C0=d.C0; w.C1=d.C1 end
						w.Parent = p0
					end)
				end
			end
		end

		pcall(function()
			if #finalB > 0 then endpoint:InvokeServer("SyncAnchor", finalB) end
		end)

		StatusLabel.Text = string.format("✅ %d parts — %.1fs", #parts, os.clock()-t0)
		StatusLabel.TextColor3 = Color3.fromRGB(100,255,130)
		root:Destroy()
	end)
end

StopBtn.MouseButton1Click:Connect(function()
	currentBuildToken = tick()
	StatusLabel.Text = "Stopped."
	StatusLabel.TextColor3 = Color3.fromRGB(255,100,100)
end)

-- ─── CLICK TO PLACE (original F3X behaviour) ──────────────────────────────────
local isPlacing = false

ImportBtn.MouseButton1Click:Connect(function()
	local id = IdInput.Text:match("%d+")
	if not id then
		StatusLabel.Text = "⚠️ Enter a valid ID!"
		StatusLabel.TextColor3 = Color3.fromRGB(255,80,80)
		return
	end
	if isPlacing then return end
	isPlacing = true

	StatusLabel.Text = "🖱️ Click to place..."
	StatusLabel.TextColor3 = Color3.fromRGB(0,180,255)

	local oldIcon = Mouse.Icon
	Mouse.Icon = "rbxasset://textures/GunCursor.png"
	StudsLabel.Visible = true

	local renderConn = RunService.RenderStepped:Connect(function()
		local hitPos  = GetRaycastHit()
		local mousePos = UserInputService:GetMouseLocation()
		StudsLabel.Position = UDim2.new(0, mousePos.X+15, 0, mousePos.Y-15)
		local dist = 0
		if LocalPlayer.Character and LocalPlayer.Character.PrimaryPart then
			dist = math.floor((hitPos - LocalPlayer.Character.PrimaryPart.Position).Magnitude)
		end
		StudsLabel.Text = string.format("Y: %.1f | Dist: %d", hitPos.Y, dist)
	end)

	local clickConn
	clickConn = Mouse.Button1Down:Connect(function()
		local spawnPos = GetRaycastHit()
		clickConn:Disconnect()
		renderConn:Disconnect()
		Mouse.Icon = oldIcon
		isPlacing = false
		StudsLabel.Visible = false
		BuildModel(id, spawnPos)
	end)
end)
