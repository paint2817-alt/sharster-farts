-- Progress lives on the server, separately for each visitor to the lot.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local event = ReplicatedStorage:WaitForChild("ShiftAction")
local sites = workspace:WaitForChild("Encounters")
local targets = {"Change", "Vending", "Baja", "ShoeRack", "Cone", "Commuter", "Stall", "Wayne", "Valve", "Lifeguard"}
local states = {}

local function moveTo(player, anchor)
    local character = player.Character
    if character then
        character:PivotTo(anchor.CFrame + Vector3.new(0, 3, 0))
    end
end

local function addPlayer(player)
    if states[player] then return end
    states[player] = {phase = 0, nextUse = 0, spaces = 0, still = 0}
    player:SetAttribute("Shift", 0)
    player:SetAttribute("Spaces", 0)
    local function spawned(character)
        local root = character:WaitForChild("HumanoidRootPart", 10)
        local state = states[player]
        if root and state and state.phase >= 7 and character == player.Character then
            moveTo(player, sites.PoolEntry)
        end
    end
    player.CharacterAdded:Connect(spawned)
    if player.Character then task.spawn(spawned, player.Character) end
end

local function advance(player, state)
    state.phase += 1
    state.still = 0
    state.lastPosition = nil
    player:SetAttribute("Shift", state.phase)
    if state.phase == 7 then moveTo(player, sites.PoolEntry) end
end

local function rootFor(player)
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if humanoid and humanoid.Health > 0 then return character:FindFirstChild("HumanoidRootPart") end
    return nil
end

event.OnServerEvent:Connect(function(player, action)
    local state = states[player]
    local root = rootFor(player)
    if not state or not root or typeof(action) ~= "string" or os.clock() < state.nextUse then return end
    state.nextUse = os.clock() + 0.2
    if action == "BackToLot" and state.phase == 10 and (root.Position-sites.PoolEntry.Position).Magnitude <= 13 then
        moveTo(player, workspace.LotSpawn)
        return
    end
    if action ~= targets[state.phase + 1] or action == "Cone" or action == "Wayne" then return end
    if (root.Position - sites[action].Position).Magnitude > 13 then return end
    if action == "Lifeguard" and workspace:GetServerTimeNow() % 4 < 1.8 then return end
    advance(player, state)
end)

Players.PlayerAdded:Connect(addPlayer)
Players.PlayerRemoving:Connect(function(player) states[player] = nil end)
for _, player in Players:GetPlayers() do addPlayer(player) end

-- Use avatar facing so the stakeout works with keyboard, touch, or a gamepad.
while true do
    local dt = math.min(task.wait(0.12), 0.3)
    for player, state in pairs(states) do
        if state.phase ~= 4 and state.phase ~= 7 then continue end
        local root = rootFor(player)
        if not root then state.still = 0; state.lastPosition = nil; continue end
        local watchingCone = state.phase == 4
        local target = if watchingCone then sites.Cone.Position + Vector3.new(state.spaces * 4,0,0) else sites.Wayne.Position
        local delta = target - root.Position
        local horizontal = Vector3.new(delta.X, 0, delta.Z)
        local stationary = state.lastPosition and (root.Position - state.lastPosition).Magnitude < 0.14
        state.lastPosition = root.Position
        local lookingAway = horizontal.Magnitude > 0.3 and root.CFrame.LookVector:Dot(horizontal.Unit) < 0.1
        local radius = if watchingCone then 26 else 10
        if stationary and delta.Magnitude <= radius and (not watchingCone or lookingAway) then
            state.still += dt
        else
            state.still = 0
        end
        if watchingCone and state.still >= 1 then
            state.still = 0
            state.spaces += 1
            player:SetAttribute("Spaces", state.spaces)
            if state.spaces == 3 then advance(player, state) end
        elseif not watchingCone and state.still >= 2 then
            advance(player, state)
        end
    end
end
