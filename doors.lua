-- Kardin-Style Minimal UI Auto Script (Rayfield)
-- Made for Zach (PRIVATE_EXECUTOR)

-- Load Rayfield Library
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

-- UI Window
local Window = Rayfield:CreateWindow({
    Name = "Doors | Rooms Auto",
    LoadingTitle = "PRIVATE_EXECUTOR",
    LoadingSubtitle = "Kardin Mode",
    ConfigurationSaving = { Enabled = false },
    Discord = { Enabled = false },
    KeySystem = false
})

-- Tabs & Toggles
local AutoTab = Window:CreateTab("Automation", 7734053494)

local toggles = {
    autoDoors = false,
    autoRooms = false,
    speedBoost = false
}

AutoTab:CreateToggle({
    Name = "Auto Complete Doors",
    Default = false,
    Callback = function(state)
        toggles.autoDoors = state
        if state then startDoorsRun() end
    end
})

AutoTab:CreateToggle({
    Name = "Auto Complete Rooms (A-1000)",
    Default = false,
    Callback = function(state)
        toggles.autoRooms = state
        if state then startRoomsRun() end
    end
})

AutoTab:CreateToggle({
    Name = "Speed Boost",
    Default = false,
    Callback = function(state)
        toggles.speedBoost = state
        local hum = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = state and 30 or 16 end
    end
})

-- Keybind Support
game:GetService("UserInputService").InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.F1 then toggles.autoDoors = not toggles.autoDoors if toggles.autoDoors then startDoorsRun() end end
    if input.KeyCode == Enum.KeyCode.F2 then toggles.autoRooms = not toggles.autoRooms if toggles.autoRooms then startRoomsRun() end end
    if input.KeyCode == Enum.KeyCode.F3 then toggles.speedBoost = not toggles.speedBoost
        local hum = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = toggles.speedBoost and 30 or 16 end
    end
end)

function firePrompt(p)
    if p and p:IsA("ProximityPrompt") then fireproximityprompt(p) end
end

function startDoorsRun()
    local player = game.Players.LocalPlayer
    local LatestRoom = game:GetService("ReplicatedStorage").GameData.LatestRoom

    task.spawn(function()
        repeat task.wait(0.2)
            local room = workspace.CurrentRooms:FindFirstChild(tostring(LatestRoom.Value))
            if not toggles.autoDoors then break end

            if room then
                local key = room:FindFirstChild("Assets") and room.Assets:FindFirstChild("KeyObtain")
                if key then firePrompt(key:FindFirstChildOfClass("ProximityPrompt")) end

                local lever = room:FindFirstChild("Assets") and room.Assets:FindFirstChild("LeverForGate")
                if lever then firePrompt(lever.Main:FindFirstChildOfClass("ProximityPrompt")) end

                local door = room:FindFirstChild("Door")
                if door then
                    player.Character:PivotTo(door.CFrame * CFrame.new(0,0,2))
                    firePrompt(door:FindFirstChildOfClass("ProximityPrompt"))
                end
            end
        until LatestRoom.Value == 50 or not toggles.autoDoors

        solveLibrary()
        repeat task.wait() until LatestRoom.Value == 100 or not toggles.autoDoors
        solveBreaker()
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
    local player = game.Players.LocalPlayer
    local RS = game:GetService("ReplicatedStorage")
    local LatestRoom = RS.GameData.LatestRoom
    local hrp = player.Character:WaitForChild("HumanoidRootPart")

    task.spawn(function()
        while toggles.autoRooms and LatestRoom.Value < 1000 do
            local room = workspace.CurrentRooms:FindFirstChild(tostring(LatestRoom.Value))
            if room and room:FindFirstChild("Door") then
                hrp.CFrame = room.Door.CFrame + Vector3.new(0,0,2)
                firePrompt(room.Door:FindFirstChildOfClass("ProximityPrompt"))
            end

            local a60 = workspace:FindFirstChild("A60") or workspace:FindFirstChild("A120")
            if a60 and a60.Main.Position.Y > -4 then
                local locker = findLocker()
                if locker then
                    hrp.CFrame = locker.CFrame + Vector3.new(0,0,2)
                    firePrompt(locker.Parent:FindFirstChild("HidePrompt"))
                    task.wait(3.5)
                end
            end

            task.wait(0.3)
        end
    end)
end

function findLocker()
    local player = game.Players.LocalPlayer
    local lockers = {}
    for _,v in ipairs(workspace.CurrentRooms:GetDescendants()) do
        if v.Name == "Rooms_Locker" and v:FindFirstChild("Door") and v.HiddenPlayer.Value == nil then
            table.insert(lockers, v.Door)
        end
    end
    table.sort(lockers, function(a,b)
        return (a.Position - player.Character.HumanoidRootPart.Position).Magnitude <
               (b.Position - player.Character.HumanoidRootPart.Position).Magnitude
    end)
    return lockers[1]
end
