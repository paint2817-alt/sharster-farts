local Players=game:GetService("Players")
local Storage=game:GetService("ReplicatedStorage")
local Input=game:GetService("UserInputService")
local Tween=game:GetService("TweenService")
local RunService=game:GetService("RunService")
local Debris=game:GetService("Debris")
local player=Players.LocalPlayer
local event=Storage:WaitForChild("ArenaAction")
local rules=game:GetService("HttpService"):JSONDecode(Storage:WaitForChild("ArenaRules").Value)
local gui=Instance.new("ScreenGui")
gui.Name="ShatterbergArena";gui.ResetOnSpawn=false;gui.Parent=player:WaitForChild("PlayerGui")
local ink=Color3.fromRGB(29,51,39)
local cream=Color3.fromRGB(255,237,193)
local lime=Color3.fromRGB(209,241,103)
local panel=Instance.new("Frame")
panel.Position=UDim2.fromOffset(10,6);panel.Size=UDim2.new(.94,0,0,108);panel.BackgroundColor3=ink;panel.Parent=gui
local limit=Instance.new("UISizeConstraint");limit.MaxSize=Vector2.new(430,180);limit.Parent=panel
local function element(kind,name,x,y,w,height)
    local el=Instance.new(kind);el.Name=name;el.Position=UDim2.new(x,4,y,0)
    el.Size=UDim2.new(w,-8,0,height);el.Font=Enum.Font.GothamBold;el.TextSize=14
    el.BackgroundColor3=cream;el.TextColor3=ink;el.TextWrapped=true;el.Parent=panel
    return el
end
local stats=element("TextLabel","Stats",0,0,1,24)
stats.BackgroundTransparency=1;stats.TextColor3=lime
local note=element("TextLabel","Hint",0,0,1,34)
note.Position=UDim2.fromOffset(4,25);note.BackgroundTransparency=1;note.TextColor3=cream
note.Text="Eat chili, enter the gate, face a target and fire."
local function button(name,x,y,w,text,action)
    local b=element("TextButton",name,x,0,w,33);b.Position=UDim2.new(x,4,0,y);b.Text=text
    b.Activated:Connect(action);return b
end
local eat=button("Eat",0,66,.36,"Eat chili [E]",function() event:FireServer("Eat") end)
local shoot=button("Fart",.36,66,.31,"Fart [F]",function() event:FireServer("Blast") end)
shoot.BackgroundColor3=lime
local foodButton,colonButton
button("Shop",.67,66,.33,"Upgrades",function()
    local open=not foodButton.Visible
    foodButton.Visible=open;colonButton.Visible=open
    panel.Size=UDim2.new(.94,0,0,if open then 149 else 108)
end)
foodButton=button("Food",0,106,.5,"Food",function() event:FireServer("Food") end)
colonButton=button("Colon",.5,106,.5,"Colon",function() event:FireServer("Colon") end)
foodButton.Visible=false;colonButton.Visible=false
local function refresh()
    local food=player:GetAttribute("FoodLevel") or 1
    local colon=player:GetAttribute("ColonLevel") or 1
    local fuel=player:GetAttribute("Meals") or 0
    stats.Text="SHATTERBERG    •    GAS "..fuel.."/3    •    ◆ "..(player:GetAttribute("Shatters") or 0)
    eat.Text="Eat "..({"chili","eggs","curry"})[food].." [E]"
    local function price(nextTier) return if nextTier then nextTier.name.." ◆"..nextTier.cost else "Fully upgraded" end
    foodButton.Text=price(rules.foods[food+1]);colonButton.Text=price(rules.colons[colon+1])
end
for _,key in {"FoodLevel","ColonLevel","Meals","Shatters"} do player:GetAttributeChangedSignal(key):Connect(refresh) end
refresh()
Input.InputBegan:Connect(function(key,handled)
    if handled then return end
    if key.KeyCode==Enum.KeyCode.E then event:FireServer("Eat") end
    if key.KeyCode==Enum.KeyCode.F then event:FireServer("Blast") end
end)
local poses={}
RunService.PreSimulation:Connect(function()
    for joint,untilTime in poses do
        if not joint.Parent or os.clock()>=untilTime then
            if joint.Parent then joint.Transform=CFrame.identity end
            poses[joint]=nil
        else
            joint.Transform=CFrame.Angles(math.rad(-50),0,0)
        end
    end
end)
local function effect(name,shape,size,color,position)
    local p=Instance.new("Part")
    p.Name=name;p.Shape=shape;p.Size=size;p.Color=color;p.Position=position
    p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=false
    p.Parent=workspace
    return p
end
local function showMeal(actor,tier)
    local root=actor:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local filling=({Color3.fromRGB(167,64,32),Color3.fromRGB(248,193,62),Color3.fromRGB(218,71,38)})[tier]
    for i,color in {cream,filling} do
        local size=if i==1 then Vector3.new(1.6,.75,1.6) else Vector3.new(1.38,.37,1.38)
        local bowl=effect("Chili bowl",Enum.PartType.Ball,size,color,root.Position)
        bowl.CFrame=root.CFrame*CFrame.new(.35,.6+(i-1)*.27,-1.15)
        bowl.Massless=true;bowl.Anchored=false
        local weld=Instance.new("WeldConstraint")
        weld.Part0=root;weld.Part1=bowl;weld.Parent=bowl
        Debris:AddItem(bowl,.65)
    end
end
event.OnClientEvent:Connect(function(kind,actor,dir,duration,tint,range)
    if kind=="Note" then note.Text=actor;return end
    if kind=="Meal" and actor then showMeal(actor,dir);return end
    if kind=="Crack" and actor then
        for i=1,7 do
            local chip=effect("Shatter fragment",Enum.PartType.Block,Vector3.new(.35,.6,.3),actor.Color,actor.Position)
            local scatter=Vector3.new(math.random(-4,4),math.random(1,4),math.random(-4,4))
            Tween:Create(chip,TweenInfo.new(.38),{Position=chip.Position+scatter,Transparency=1}):Play()
            Debris:AddItem(chip,.42)
        end
        return
    end
    if kind~="Blast" or not actor then return end
    local root=actor:FindFirstChild("HumanoidRootPart") or actor.PrimaryPart
    if not root then return end
    local joint=actor:FindFirstChild("Waist",true) or actor:FindFirstChild("RootJoint",true)
    if joint and joint:IsA("Motor6D") then poses[joint]=os.clock()+duration end
    local color=Color3.fromHex(tint)
    local rumble=Instance.new("Sound")
    rumble.SoundId="rbxasset://sounds/action_swim.mp3";rumble.Looped=true;rumble.Volume=.5
    rumble.PlaybackSpeed=.48;rumble.RollOffMaxDistance=72;rumble.Parent=root;rumble:Play()
    Debris:AddItem(rumble,duration)
    local finish=os.clock()+duration
    while root.Parent and os.clock()<finish do
        local gas=effect("Chili cloud",Enum.PartType.Ball,Vector3.new(1.4,1.4,1.4),color,root.Position+dir*1.2-Vector3.new(0,.7,0))
        gas.Material=Enum.Material.Neon;gas.Transparency=.23
        local side=Vector3.new(-dir.Z,0,dir.X)*math.random(-18,18)/10
        Tween:Create(gas,TweenInfo.new(.45,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{
            Position=gas.Position+dir*range+side,Size=Vector3.new(6,4.5,6),Transparency=1}):Play()
        Debris:AddItem(gas,.5)
        task.wait(.075)
    end
end)
