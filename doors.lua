--[[

📜 Doors Speedrun Script with OrionLib UI
By: Zach | Sleek custom GUI with full automation

Features:
✅ One toggle: Start Auto Doors Run
🎯 Auto grab keys, levers, books, breaker parts
🚪 Teleport to next door
🧐 Solve code in Room 50 & breaker puzzle
🎨 OrionLib UI (modular, polished)
🔊 Sound + animation polish
📆 Future support for Rooms integration

Load this using your executor:
loadstring(game:HttpGet("https://your-raw-url.com/doors_autorun.lua"))()

]]

-- Load OrionLib
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/jensonhirst/Orion/main/source"))()

-- Window
local Window = OrionLib:MakeWindow({
    Name = "🚪 Doors Speedrun Utility",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "DoorsSpeedrun"
})

-- Main Tab
local Tab = Window:MakeTab({
	Name = "Auto Run",
	Icon = "rbxassetid://7734068321",
	PremiumOnly = false
})

-- Toggle
Tab:AddToggle({
	Name = "Start Auto Doors Run",
	Default = false,
	Save = false,
	Callback = function(Value)
		if Value then
			startDoorsSpeedrun()
		end
	end    
})

-- Notification
OrionLib:MakeNotification({
	Name = "Loaded",
	Content = "Doors Speedrun Utility Ready",
	Image = "rbxassetid://7733658504",
	Time = 4
})

-- Sound effect
local function playSound()
	local sound = Instance.new("Sound")
	sound.SoundId = "rbxassetid://4590662766"
	sound.Volume = 3
	sound.Parent = workspace
	sound:Play()
	game.Debris:AddItem(sound, 5)
end

-- Main logic
function startDoorsSpeedrun()
	task.spawn(function()
		playSound()
		local RS = game:GetService("ReplicatedStorage")
		local LatestRoom = RS:WaitForChild("GameData"):WaitForChild("LatestRoom")
		local player = game.Players.LocalPlayer
		local char = player.Character or player.CharacterAdded:Wait()

		repeat
			task.wait(0.25)
			local room = workspace.CurrentRooms:FindFirstChild(tostring(LatestRoom.Value))
			if not room then continue end

			-- Auto grab key
			local key = room:FindFirstChild("Assets") and room.Assets:FindFirstChild("KeyObtain")
			if key then
				fireproximityprompt(key.ModulePrompt)
				task.wait(0.3)
			end

			-- Auto lever
			local lever = room:FindFirstChild("Assets") and room.Assets:FindFirstChild("LeverForGate")
			if lever then
				fireproximityprompt(lever.Main.ProximityPrompt)
				task.wait(0.5)
			end

			-- Auto teleport to door
			local door = room:FindFirstChild("Door")
			if door then
				char:PivotTo(door.CFrame + Vector3.new(0,0,3))
				task.wait(0.2)
				local prompt = door:FindFirstChild("Lock") and door.Lock:FindFirstChildOfClass("ProximityPrompt")
				if prompt then fireproximityprompt(prompt) end
			end

		until LatestRoom.Value >= 50

		-- Room 50: Auto solve books/code
		autoSolveRoom50()

		repeat
			task.wait()
		until LatestRoom.Value >= 100

		autoSolveBreaker()
		OrionLib:MakeNotification({
			Name = "Finished",
			Content = "Run complete!",
			Time = 5
		})
	end)
end

-- Room 50 Auto Logic
function autoSolveRoom50()
	local room = workspace.CurrentRooms:FindFirstChild("50")
	if not room then return end
	local player = game.Players.LocalPlayer
	local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")

	-- Grab books
	for _, v in ipairs(room.Assets:GetDescendants()) do
		if v.Name == "LiveHintBook" then
			hrp.CFrame = v.CFrame + Vector3.new(0,2,0)
			fireproximityprompt(v.ModulePrompt)
			task.wait(0.3)
		end
	end

	-- Solve code
	local codeModule = require(player.PlayerGui.MainUI.Initiator.Main_Game.RemoteListener.Modules["BreakerPuzzle"])
	local code = codeModule and codeModule.generatedCode
	if code then
		for i = 1, #code do
			local digit = code:sub(i,i)
			game:GetService("ReplicatedStorage").GameStats[player.Name].CodeInput:FireServer(tonumber(digit))
			task.wait(0.2)
		end
	end
end

-- Room 100 Auto Logic
function autoSolveBreaker()
	local player = game.Players.LocalPlayer
	local char = player.Character or player.CharacterAdded:Wait()
	local hrp = char:WaitForChild("HumanoidRootPart")
	local breakerRoom = workspace.CurrentRooms:FindFirstChild("100")

	if not breakerRoom then return end

	-- Collect parts
	for _, v in pairs(breakerRoom.Assets:GetDescendants()) do
		if v.Name == "BreakerPolePickup" and v:IsA("Model") then
			hrp.CFrame = v:GetPivot() + Vector3.new(0,1,0)
			fireproximityprompt(v.Prompt)
			task.wait(0.3)
		end
	end

	-- Solve puzzle
	local puzzle = require(game.ReplicatedStorage.ClientModules.EntityModules.BreakerModule)
	if puzzle then
		puzzle.InputBreaker({true, true, true, true, true, true, true, true, true, true})
	end
end
