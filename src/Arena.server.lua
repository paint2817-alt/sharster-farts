local Players = game:GetService("Players")
local Storage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local event = Storage:WaitForChild("ArenaAction")
local rules = HttpService:JSONDecode(Storage:WaitForChild("ArenaRules").Value)
local rocks, bots, states = {}, {}, {}
local function flat(v) return Vector3.new(v.X, 0, v.Z) end
local function inside(p) return math.abs(p.X) <= 50 and math.abs(p.Z) <= 29 and p.Y > -2 and p.Y < 12 end
local function rootOf(player)
    local c = player.Character
    local h = c and c:FindFirstChildOfClass("Humanoid")
    if h and h.Health > 0 then return c:FindFirstChild("HumanoidRootPart"), h end
end
local function sync(p,s)
    p:SetAttribute("Shatters",s.money)
    p:SetAttribute("Meals",s.fuel)
    p:SetAttribute("FoodLevel",s.food)
    p:SetAttribute("ColonLevel",s.colon)
end
local function tell(p,text) event:FireClient(p,"Note",text) end
local function award(p,s,value)
    s.money += value
    sync(p,s)
    tell(p,"+"..value.." Shatters")
end
local function add(p)
    if states[p] then return end
    local s={money=0,food=1,colon=1,fuel=0,nextUse=0}
    states[p]=s
    sync(p,s)
    p.CharacterAdded:Connect(function()
        s.blast=nil
        s.fuel=0
        sync(p,s)
    end)
end
Players.PlayerAdded:Connect(add)
Players.PlayerRemoving:Connect(function(p) states[p]=nil end)
for _,p in Players:GetPlayers() do add(p) end
for _,part in workspace:WaitForChild("Shatters"):GetChildren() do
    local hard=part.Name:sub(1,4)=="Hard"
    table.insert(rocks,{part=part,hp=if hard then 3 else 1,max=if hard then 3 else 1,ready=0})
end
for i,model in workspace:WaitForChild("Rivals"):GetChildren() do
    local head=model:WaitForChild("Head")
    local plate=Instance.new("BillboardGui")
    plate.Size=UDim2.fromOffset(125,25)
    plate.StudsOffset=Vector3.new(0,2,0)
    plate.MaxDistance=80
    plate.Parent=head
    local title=Instance.new("TextLabel")
    title.Size=UDim2.fromScale(1,1)
    title.BackgroundColor3=Color3.fromRGB(41,57,45)
    title.TextColor3=Color3.fromRGB(252,232,185)
    title.Text=model.Name
    title.Parent=plate
    table.insert(bots,{model=model,label=title,home=model:GetPivot().Position,hp=3,ready=0,nextShot=os.clock()+5+i,seed=i,stun=0})
end
local function inCone(pos,origin,dir,range)
    local delta=pos-origin
    if math.abs(delta.Y)>8 then return false end
    local offset=flat(delta)
    return offset.Magnitude<=range and (offset.Magnitude<1 or offset.Unit:Dot(dir)>.77)
end
local function hitCharacter(p,root,h,dir,power)
    h:TakeDamage(12*power)
    root:ApplyImpulse((dir*(18+3*power)+Vector3.new(0,7,0))*root.AssemblyMass)
end
local function pulse(p,s,b,root,now)
    for _,r in rocks do
        if r.ready==0 and inCone(r.part.Position,root.Position,b.dir,b.range) then
            r.hp-=b.power
            if r.hp<=0 then
                r.ready=now+4
                r.part.Transparency=1
                event:FireAllClients("Crack",r.part)
                award(p,s,if r.max==3 then 4 else 2)
            end
        end
    end
    for _,bot in bots do
        local pos=bot.model:GetPivot().Position
        if bot.ready==0 and inCone(pos,root.Position,b.dir,b.range) then
            bot.hp-=b.power
            bot.stun=now+.5
            bot.windup=nil
            bot.label.Text=bot.model.Name
            if bot.hp<=0 then
                bot.ready=now+5
                bot.model:PivotTo(CFrame.new(bot.home-Vector3.new(0,40,0)))
                award(p,s,5)
            else
                local dest=pos+b.dir*2
                bot.model:PivotTo(CFrame.new(math.clamp(dest.X,-46,46),pos.Y,math.clamp(dest.Z,-25,25)))
            end
        end
    end
    for other in states do
        if other~=p then
            local target,h=rootOf(other)
            if target and inside(target.Position) and inCone(target.Position,root.Position,b.dir,b.range) then
                hitCharacter(other,target,h,b.dir,b.power)
                if h.Health<=0 then award(p,s,5) end
            end
        end
    end
end
event.OnServerEvent:Connect(function(p,action)
    local s=states[p]
    local root,h=rootOf(p)
    local now=os.clock()
    if not s or not root or now<s.nextUse then return end
    s.nextUse=now+.18
    if action=="Eat" then
        if s.fuel==rules.capacity then tell(p,"Tank full.") return end
        s.fuel+=1
        sync(p,s)
        event:FireAllClients("Meal",p.Character,s.food)
        tell(p,rules.foods[s.food].name.." down.")
    elseif action=="Food" or action=="Colon" then
        local key=if action=="Food" then "food" else "colon"
        local list=if action=="Food" then rules.foods else rules.colons
        local nextTier=list[s[key]+1]
        if not nextTier then return end
        if s.money<nextTier.cost then tell(p,"Need "..nextTier.cost.." Shatters.") return end
        s.money-=nextTier.cost
        s[key]+=1
        sync(p,s)
        tell(p,nextTier.name.." unlocked.")
    elseif action=="Blast" then
        if s.blast then return end
        if not inside(root.Position) then tell(p,"Walk through the gate into the arena.") return end
        if s.fuel<=0 then tell(p,"Eat a free bowl first.") return end
        local dir=flat(root.CFrame.LookVector)
        if dir.Magnitude<.01 then return end
        dir=dir.Unit
        local dinner=rules.foods[s.food]
        local duration=rules.colons[s.colon].duration
        s.fuel-=1
        sync(p,s)
        s.blast={dir=dir,range=dinner.reach*3,power=dinner.power,finish=now+duration,nextPulse=now+.28,root=root,
            speed=h.WalkSpeed,rotate=h.AutoRotate}
        h.AutoRotate=false
        h.WalkSpeed=0
        root.CFrame=CFrame.lookAt(root.Position,root.Position-dir)
        event:FireAllClients("Blast",p.Character,dir,duration,dinner.color,dinner.reach*3)
        pulse(p,s,s.blast,root,now)
    end
end)
local function stepBot(bot,now,dt)
    if bot.ready>0 then
        if now>=bot.ready then
            bot.ready=0;bot.hp=3;bot.model:PivotTo(CFrame.new(bot.home));bot.nextShot=now+3
        end
        return
    end
    if bot.stun>now then return end
    local pos=bot.model:GetPivot().Position
    if bot.windup then
        if now>=bot.windup then
            event:FireAllClients("Blast",bot.model,bot.dir,.65,"#f6af78",12)
            for p in states do
                local root,h=rootOf(p)
                if root and inside(root.Position) and inCone(root.Position,pos,bot.dir,12) then hitCharacter(p,root,h,bot.dir,1) end
            end
            bot.windup=nil;bot.label.Text=bot.model.Name;bot.nextShot=now+6
        end
        return
    end
    if now>=bot.nextShot then
        for p in states do
            local root=rootOf(p)
            if root and inside(root.Position) then
                local delta=flat(root.Position-pos)
                if delta.Magnitude<13 and delta.Magnitude>.01 then
                    bot.dir=delta.Unit;bot.windup=now+.9
                    bot.label.Text="INCOMING!"
                    bot.model:PivotTo(CFrame.lookAt(pos,pos-bot.dir))
                    return
                end
            end
        end
    end
    local goal=bot.home+Vector3.new(math.sin(now*.5+bot.seed)*5,0,math.cos(now*.37+bot.seed)*4)
    local offset=flat(goal-pos)
    if offset.Magnitude>.15 then
        local dest=pos+offset.Unit*math.min(offset.Magnitude,dt*4)
        bot.model:PivotTo(CFrame.lookAt(dest,dest+offset.Unit))
    end
end
local elapsed=0
RunService.Heartbeat:Connect(function(dt)
    elapsed+=dt
    if elapsed<.06 then return end
    local step=math.min(.15,elapsed)
    elapsed=0
    local now=os.clock()
    for _,r in rocks do
        if r.ready>0 and now>=r.ready then r.ready=0;r.hp=r.max;r.part.Transparency=0 end
    end
    for _,bot in bots do stepBot(bot,now,step) end
    for p,s in states do
        local b=s.blast
        if b then
            local root,h=rootOf(p)
            if now>=b.finish or root~=b.root or not inside(b.root.Position) then
                s.blast=nil
                if h and root==b.root then h.AutoRotate=b.rotate;h.WalkSpeed=b.speed end
            elseif now>=b.nextPulse then
                b.nextPulse=now+.32
                pulse(p,s,b,root,now)
            end
        end
    end
end)
