local desiredPlaceId = 137885680
local version = "1.0"
local applicationName = "TB_ZR".. version

local player = game.Players.LocalPlayer

local firstRun = true

local opGun = true
local isWalkSpeed = false
local isZTP = true
local isZDestroy = false
local isRTrees = false
local wsValue = 18

local groupId = 2589590
local groupRolesAvoid = {
    "Group Moderator",
    "Developers",
    "Vertex",
    "Beacon"
}

local character = player.Character or player.CharacterAdded:Wait()

local platform = Instance.new("Part")
platform.Size = Vector3.new(10, 1, 10)
platform.Position = character.HumanoidRootPart.Position + Vector3.new(0, 1000, 1000)
platform.Anchored = true
platform.BrickColor = BrickColor.new("Bright blue")
platform.Parent = game.Workspace
platform.Transparency = 1

local function teleportToPlatform()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    humanoidRootPart.CFrame = CFrame.new(platform.Position + Vector3.new(0, 5, 0))
end

game.Players.PlayerAdded:Connect(function(newPlayer)
    local isStaff = false
    local role = newPlayer:GetRoleInGroup(groupId)
    for i,v in pairs(groupRolesAvoid) do
        if v == role then
            isStaff = true
        end
    end
    
    if isStaff then
        player:Kick("Staff has joined the game, disconnecting you safely to avoid detection.")
    end
end)

function playAsZombie()
    local Target = game:GetService("ReplicatedStorage").Remotes.PlayerZombie
    Target:FireServer(player.Character)
end

function opWeapon(tool)
    if isGun(tool) then
        local con = tool.Configuration
        if con.Range.Value ~= 9999 then
            con.Range.Value = 9999
            con.FullAuto.Value = true
            con.Spread.Value = 0
            con.Firerate.Value = 100
            con.Damage.Value = 99999
            tool.GunController.Disabled = true
            tool.GunController.Disabled = false
        end
    end
end

function isGun(tool)
    local returnValue = false
    if tool then
        if tool.ClassName == "Tool" and tool:FindFirstChild("Configuration") and tool:FindFirstChild("GunController") then
            returnValue = true
        end
    end
    return returnValue
end

function tpZombiesToPlayer()
    local ztable = game.Workspace["Zombie Storage"]:GetChildren()
    local character = player.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        local hrp = character.HumanoidRootPart
        local lookDirection = hrp.CFrame.LookVector
        
        for i, v in pairs(ztable) do
            if v:FindFirstChild("Head") then
                local targetPosition = hrp.Position + lookDirection * 5
                v.Head.CFrame = CFrame.new(targetPosition)
                v.Head.Anchored = true
            end
            if v:IsA("Part") then
                if v.CanCollide then
                    v.CanCollide = false
                end
            end
        end
    end    
end

local function findNearestZombie()
    local nearestZombie = nil
    local shortestDistance = math.huge
    local ztable = game.Workspace["Zombie Storage"]:GetChildren()
    
    local character = player.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        local hrp = character.HumanoidRootPart
        for _, zombie in pairs(ztable) do
            if zombie:FindFirstChild("HumanoidRootPart") then
                local distance = (hrp.Position - zombie.HumanoidRootPart.Position).Magnitude
                if distance < shortestDistance then
                    shortestDistance = distance
                    nearestZombie = zombie
                end
            end
        end
    end
    return nearestZombie
end

local function lockCameraToZombie()
    local nearestZombie = findNearestZombie()
    if nearestZombie then
        local camera = game.Workspace.CurrentCamera
        local zombiePosition = nearestZombie.Head.Position
        camera.CFrame = CFrame.new(camera.CFrame.Position, zombiePosition)
    end
end

local function mainLoop()
    print("Zombie Rushmore Main Loop Running")
    print("Written by The Band")
    while true do
        local humanoid = player.Character:WaitForChild("Humanoid")
        
        if opGun then
            local tool = player.Character:FindFirstChildWhichIsA("Tool")
            if tool then
                if isGun(tool) then
                    opWeapon(tool)
                end
            end
        end
        
        if isZTP then
            tpZombiesToPlayer()
        end

        teleportToPlatform()

        lockCameraToZombie()

        wait(0)
    end
end

firstRun = false
spawn(mainLoop)
