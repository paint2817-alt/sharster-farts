local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local sites = workspace:WaitForChild("Encounters")
local remote = ReplicatedStorage:WaitForChild("ShiftAction")
local gui = Instance.new("ScreenGui")
gui.Name = "FartBinder"
gui.ResetOnSpawn = false
gui.DisplayOrder = 3
gui.Parent = player:WaitForChild("PlayerGui")
local paper = Color3.fromRGB(248,228,185)
local ink = Color3.fromRGB(27,51,51)
local function label(parent, name, pos, size, textSize, color)
    local t = Instance.new("TextLabel")
    t.Name = name
    t.BackgroundTransparency = 1
    t.Position = pos
    t.Size = size
    t.TextColor3 = color
    t.Font = Enum.Font.GothamBold
    t.TextSize = textSize
    t.TextXAlignment = Enum.TextXAlignment.Left
    t.TextWrapped = true
    t.Text = ""
    t.Parent = parent
    return t
end
local hud = Instance.new("Frame")
hud.Size = UDim2.new(0.9,0,0,95)
hud.Position = UDim2.fromOffset(12,8)
hud.BackgroundColor3 = ink
hud.BackgroundTransparency = 0.08
hud.Parent = gui
local limit = Instance.new("UISizeConstraint")
limit.MaxSize = Vector2.new(440,95)
limit.Parent = hud
local heading = label(hud,"Binder",UDim2.fromOffset(12,6),UDim2.new(1,-24,0,22),15,Color3.fromRGB(255,211,118))
local objective = label(hud,"Objective",UDim2.fromOffset(12,30),UDim2.new(1,-24,0,54),16,paper)
local toggle = Instance.new("TextButton")
toggle.Size = UDim2.fromOffset(68,23)
toggle.Position = UDim2.new(1,-76,0,5)
toggle.Text = "Binder"
toggle.BackgroundColor3 = paper
toggle.TextColor3 = ink
toggle.Parent = hud
local pages = label(hud,"Entries",UDim2.fromOffset(0,99),UDim2.new(1,0,0,155),16,ink)
pages.BackgroundTransparency = 0
pages.BackgroundColor3 = paper
pages.TextXAlignment = Enum.TextXAlignment.Center
pages.Visible = false
toggle.Activated:Connect(function() pages.Visible = not pages.Visible end)
local notes = {
    "Find the jingling green cloud near the pumps. Hold the catch prompt.",
    "Take Loose Change to the red vending machine. It accepts anything that jingles.",
    "Catch Baja Mistake. It just came out of the machine.",
    "Visit the employee shoe rack. The traffic cone can hear your shoes.",
    "Near the cone, walk a step away from it and stand still. Let it park.",
    "The cone parked. Net the little commuter at the RESERVED sign.",
    "Use the Commuter’s staff key and Baja Mistake at Stall 6.",
    "Stand still beside Drain Wayne in the pool. He'll walk into your net.",
    "Use Drain Wayne on the red pool valve.",
    "The lifeguard was a reflection. Net the little guy on the ledge between whistles.",
    "Shift complete. Adult Swim is in the binder. The ladder takes you back.",
}
local entries = {{1,"Loose Change"},{3,"Baja Mistake"},{6,"The Commuter"},{8,"Drain Wayne"},{10,"Adult Swim"}}
local zones = {"Change","Vending","Baja","ShoeRack","Cone","Commuter","Stall","Wayne","Valve","Lifeguard","PoolEntry"}
local verbs = {"I'm brave","Spend Loose Change","Net Baja Mistake","Leave shoes","", "Catch the Commuter","Open staff entrance","","Pull the plug","Net Adult Swim","Back to the lot"}
local names = {"Loose Change","Exact change only","Baja Mistake","Employee shoe rack","The cone is due","The Commuter","Stall 6","Drain Wayne","Emergency drain","Adult Swim","Pool ladder"}
local visuals = Instance.new("Folder")
visuals.Name = "ShiftVisuals"
visuals.Parent = workspace
local prompt, beacon, moving, start
local function piece(parent, name, position, size, color, shape)
    local p = Instance.new("Part")
    p.Name = name
    p.Anchored = true
    p.CanCollide = false
    p.CanTouch = false
    p.CanQuery = false
    p.Size = size
    p.Position = position
    p.Color = color
    p.Shape = shape or Enum.PartType.Block
    p.Material = Enum.Material.SmoothPlastic
    p.Parent = parent
    return p
end
local function netFor(character)
    local hand = character:WaitForChild("RightHand",2) or character:FindFirstChild("Right Arm")
    if not hand or character ~= player.Character then return end
    local model = Instance.new("Model")
    model.Name = "Butterfly net"
    model.Parent = character
    local function rod(a,b,width,color)
        local midpoint=(a+b)/2
        local p=piece(model,"Net",midpoint,Vector3.new(width,width,(b-a).Magnitude),color)
        p.Anchored=false
        p.Massless=true
        p.CFrame=hand.CFrame*CFrame.lookAt(midpoint,b)
        local w=Instance.new("WeldConstraint")
        w.Part0=hand; w.Part1=p; w.Parent=p
    end
    local center=Vector3.new(0,-0.3,-3.1)
    rod(Vector3.new(0,-0.3,0),center+Vector3.new(0,0,0.8),0.12,Color3.fromRGB(161,103,54))
    for i=0,11 do
        local a,b=2*math.pi*i/12,2*math.pi*(i+1)/12
        local edge=center+Vector3.new(math.cos(a),0,math.sin(a))*0.8
        rod(edge,center+Vector3.new(math.cos(b),0,math.sin(b))*0.8,0.075,paper)
        if i%2==0 then rod(edge,center+Vector3.new(0,-0.8,0),0.035,paper) end
    end
end
player.CharacterAdded:Connect(netFor)
if player.Character then task.spawn(netFor,player.Character) end
local function render()
    if prompt then prompt:Destroy(); prompt=nil end
    if beacon then beacon:Destroy(); beacon=nil end
    visuals:ClearAllChildren()
    moving=nil
    local phase=player:GetAttribute("Shift") or 0
    local spaces=player:GetAttribute("Spaces") or 0
    local lines, count={},0
    for i, entry in ipairs(entries) do
        local found=phase>=entry[1]
        if found then count+=1 end
        table.insert(lines, string.format("%02d   %s",i,if found then entry[2] else "???"))
    end
    pages.Text=table.concat(lines,"\n")
    heading.Text="SHARSTER FARTS     •     "..count.."/5"
    objective.Text=notes[phase+1]..(if phase==4 then "  "..spaces.."/3 skrrts." else "")
    local anchor=sites:WaitForChild(zones[phase+1])
    local base=anchor.Position
    local ball=Enum.PartType.Ball
    if phase==0 or phase==2 or phase==9 then
        moving=Instance.new("Model"); moving.Parent=visuals
        local color=if phase==2 then Color3.fromRGB(88,210,245) else Color3.fromRGB(170,219,92)
        for i=-1,1 do
            piece(moving,"Wisp",base+Vector3.new(i*0.75,0.3*(1-math.abs(i)),0),Vector3.new(1.65,1.55,1.45),color,ball)
        end
        for _,x in {-0.35,0.35} do piece(moving,"Eye",base+Vector3.new(x,0.22,0.74),Vector3.new(.18,.22,.12),ink,ball) end
        if phase==0 then
            for i=1,3 do piece(moving,"Penny",base+Vector3.new(i*.38-.8,-.4,.66),Vector3.new(.31,.32,.08),Color3.fromRGB(238,169,65),ball) end
        end
        start=moving:GetPivot()
    elseif phase==3 or phase==4 or phase==5 then
        local conePos=sites.Cone.Position+Vector3.new(math.min(spaces,3)*4,0,0)
        piece(visuals,"Base",conePos,Vector3.new(3,.25,3),ink)
        for i=0,5 do
            local size=2.4-i*.34
            piece(visuals,"Cone",conePos+Vector3.new(0,.32+i*.42,0),Vector3.new(size,.45,size),if i==3 then paper else Color3.fromRGB(244,100,43))
        end
        if phase==5 then
            piece(visuals,"The Commuter",base,Vector3.new(1.45,1.55,1.1),Color3.fromRGB(239,165,42))
            piece(visuals,"Tie",base+Vector3.new(0,-.1,.6),Vector3.new(.2,.7,.1),ink)
            piece(visuals,"Lunch pail",base+Vector3.new(.9,-.5,0),Vector3.new(.65,.55,.45),ink)
        end
    elseif phase==7 then
        piece(visuals,"Wayne",base,Vector3.new(2,1.5,1.8),Color3.fromRGB(127,137,133))
        for i=-1,1 do piece(visuals,"Slots",base+Vector3.new(i*.5,.76,0),Vector3.new(.18,.05,1.3),ink) end
    end
    local water=workspace:WaitForChild("PoolWater")
    local drained=phase>=9
    water.LocalTransparencyModifier=if drained then 1 else 0
    for _,p in workspace:WaitForChild("Reflection"):GetChildren() do
        if p:IsA("BasePart") then p.LocalTransparencyModifier=if drained then 1 else 0 end
    end
    beacon=Instance.new("BillboardGui")
    beacon.Adornee=anchor;beacon.Size=UDim2.fromOffset(177,28);beacon.StudsOffset=Vector3.new(0,4,0)
    beacon.AlwaysOnTop=true;beacon.MaxDistance=160;beacon.Parent=gui
    local tag=label(beacon,"Marker",UDim2.new(),UDim2.fromScale(1,1),15,paper)
    tag.Text="◆  "..names[phase+1];tag.TextXAlignment=Enum.TextXAlignment.Center
    tag.TextStrokeTransparency=.1
    if verbs[phase+1]~="" then
        prompt=Instance.new("ProximityPrompt")
        prompt.ActionText=verbs[phase+1];prompt.ObjectText=names[phase+1]
        prompt.HoldDuration=if phase==0 or phase==2 or phase==9 then .45 else .18
        prompt.RequiresLineOfSight=false;prompt.MaxActivationDistance=10
        prompt.Parent=anchor
        prompt.Triggered:Connect(function()
            remote:FireServer(if phase==10 then "BackToLot" else zones[phase+1])
        end)
    end
end
RunService.RenderStepped:Connect(function()
    if prompt and player:GetAttribute("Shift")==9 then
        local resting=workspace:GetServerTimeNow()%4>=1.8
        prompt.Enabled=resting
        if beacon then beacon.Marker.Text=if resting then "◆  Inhaling! Swing now" else "♪  WHISTLING" end
    end
    if moving then
        local t=os.clock()
        moving:PivotTo(start+Vector3.new(math.sin(t*1.7)*1.45,math.cos(t*2)*.35,0))
    end
end)
player:GetAttributeChangedSignal("Shift"):Connect(render)
player:GetAttributeChangedSignal("Spaces"):Connect(render)
render()
