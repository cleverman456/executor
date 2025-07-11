-- Loadstring-ready All-in-One Doors + Rooms Script
-- Includes OrionLib UI, full automation, anti-cheat detection
-- Made by Zach (PRIVATE_EXECUTOR)

local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Orion/main/source"))()

local Window = OrionLib:MakeWindow({
    Name = "🏃 Doors & Rooms AutoRun",
    HidePremium = false,
    SaveConfig = false,
    ConfigFolder = "DoorsAutoSpeedrun"
})

local Tab = Window:MakeTab({
    Name = "Auto Mode",
    Icon = "rbxassetid://7734053494",
    PremiumOnly = false
})

Tab:AddButton({
    Name = "Start Auto Run",
    Callback = function()
        if game.PlaceId == 6839171747 then
            OrionLib:MakeNotification({Name="The Rooms",Content="Starting A-1000 Run",Time=4})
            startRoomsRun()
        else
            OrionLib:MakeNotification({Name="Doors",Content="Starting Speedrun Mode",Time=4})
            startDoorsRun()
        end
        startAntiCheat()
    end
})

function firePrompt(obj)
    if obj and obj:IsA("ProximityPrompt") then
        fireproximityprompt(obj)
    end
end

function startDoorsRun()
    local player = game.Players.LocalPlayer
    local LatestRoom = game:GetService("ReplicatedStorage").GameData.LatestRoom

    task.spawn(function()
        repeat task.wait(0.2)
            local room = workspace.CurrentRooms:FindFirstChild(tostring(LatestRoom.Value))
            if room then
                local key = room:FindFirstChild("Assets") and room.Assets:FindFirstChild("KeyObtain")
                if key then firePrompt(key:FindFirstChildOfClass("ProximityPrompt")) end

                local lever = room:FindFirstChild("Assets") and room.Assets:FindFirstChild("LeverForGate")
                if lever then firePrompt(lever.Main:FindFirstChildOfClass("ProximityPrompt")) end

                local door = room:FindFirstChild("Door")
                if door then
                    player.Character:PivotTo(door.CFrame * CFrame.new(0,0,2))
                    local prompt = door:FindFirstChild("Lock") and door.Lock:FindFirstChildOfClass("ProximityPrompt")
                    if prompt then firePrompt(prompt) end
                end
            end
        until LatestRoom.Value == 50

        solveLibrary()
        repeat task.wait() until LatestRoom.Value == 100
        solveBreaker()

        OrionLib:MakeNotification({Name="Finished",Content="Auto Doors Run Complete!",Time=6})
    end)
end

function solveLibrary()
    local player = game.Players.LocalPlayer
    local room = workspace.CurrentRooms:FindFirstChild("50")
    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
    if not room or not hrp then return end

    for _, v in ipairs(room.Assets:GetDescendants()) do
        if v.Name == "LiveHintBook" and v:FindFirstChild("ModulePrompt") then
            hrp.CFrame = v.CFrame + Vector3.new(0,2,0)
            firePrompt(v.ModulePrompt)
            task.wait(0.2)
        end
    end

    local codeMod = require(player.PlayerGui.MainUI.Initiator.Main_Game.RemoteListener.Modules["BreakerPuzzle"])
    if codeMod and codeMod.generatedCode then
        for digit in codeMod.generatedCode:gmatch(".") do
            game:GetService("ReplicatedStorage").GameStats[player.Name].CodeInput:FireServer(tonumber(digit))
            task.wait(0.15)
        end
    end
end

function solveBreaker()
    local player = game.Players.LocalPlayer
    local room = workspace.CurrentRooms:FindFirstChild("100")
    if not room then return end

    for _, obj in ipairs(room.Assets:GetDescendants()) do
        if obj.Name == "BreakerPolePickup" and obj:FindFirstChild("Prompt") then
            player.Character.HumanoidRootPart.CFrame = obj:GetPivot() + Vector3.new(0,1,0)
            firePrompt(obj.Prompt)
            task.wait(0.3)
        end
    end

    local breaker = require(game.ReplicatedStorage.ClientModules.EntityModules.BreakerModule)
    if breaker then
        breaker.InputBreaker({true,true,true,true,true,true,true,true,true,true})
    end
end

function startRoomsRun()
    local RS = game:GetService("ReplicatedStorage")
    local LatestRoom = RS.GameData.LatestRoom
    local player = game.Players.LocalPlayer
    local hrp = player.Character:WaitForChild("HumanoidRootPart")

    while LatestRoom.Value < 1000 do
        local room = workspace.CurrentRooms:FindFirstChild(tostring(LatestRoom.Value))
        if room then
            local door = room:FindFirstChild("Door")
            if door then
                hrp.CFrame = door.CFrame + Vector3.new(0,0,2)
                local prompt = door:FindFirstChildOfClass("ProximityPrompt")
                if prompt then firePrompt(prompt) end
            end
        end

        local ent = workspace:FindFirstChild("A60") or workspace:FindFirstChild("A120")
        if ent and ent.Main.Position.Y > -4 then
            local locker = findLocker()
            if locker then
                hrp.CFrame = locker.CFrame + Vector3.new(0,0,2)
                firePrompt(locker.Parent.HidePrompt)
                task.wait(3.5)
            end
        end

        if player.PlayerGui:FindFirstChild("MainUI") then
            local a90 = player.PlayerGui.MainUI.Initiator.Main_Game.RemoteListener.Modules:FindFirstChild("A90")
            if a90 then a90.Name = "A90_bypass" end
        end

        task.wait(0.25)
    end

    OrionLib:MakeNotification({Name="Rooms", Content="Reached Room A-1000!", Time=6})
end

function findLocker()
    local lockers = {}
    for _,v in ipairs(workspace.CurrentRooms:GetDescendants()) do
        if v.Name == "Rooms_Locker" and v:FindFirstChild("Door") and v.HiddenPlayer.Value == nil then
            table.insert(lockers, v.Door)
        end
    end
    table.sort(lockers, function(a,b)
        return (a.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude <
               (b.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
    end)
    return lockers[1]
end

function startAntiCheat()
    local player = game.Players.LocalPlayer
    local function notify(text)
        OrionLib:MakeNotification({Name="Anti-Cheat Alert",Content=text,Time=5})
    end

    task.spawn(function()
        while true do
            local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.WalkSpeed > 30 then notify("Suspicious WalkSpeed Detected") end
            if not player:FindFirstChild("PlayerScripts") then notify("Missing PlayerScripts!") end
            if game:GetService("StarterGui").ResetPlayerGuiOnSpawn == false then notify("ResetButton Blocked") end
            task.wait(3)
        end
    end)
end
