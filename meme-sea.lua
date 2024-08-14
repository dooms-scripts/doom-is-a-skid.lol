----------------------
-- /\/ doom.lol \/\ --
----------------------

--> Variables
local Player = game:GetService('Players').LocalPlayer
local NPCFolder = workspace:WaitForChild('NPCs')
local QuestFloppa = NPCFolder:WaitForChild('Quests_Npc'):WaitForChild("Cool Floppa Quest")
local QuestPrompt = QuestFloppa.Block.QuestPrompt
local LavaFloppa = workspace.Island.FloppaIsland["Lava Floppa"]
local LavaPrompt = LavaFloppa:WaitForChild("ClickPart"):WaitForChild("ProximityPrompt")
local FirePrompt = fireproximityprompt

--> Functions
local function Teleport(pos)
    local Character = Player.Character
    local Root = Character:WaitForChild('HumanoidRootPart') or Character.PrimaryPart
    Root.CFrame = CFrame.new(pos)
end

local function StartFarm()
    --> Start quest
    Teleport(Vector3.new(757, -28, -425)) task.wait(1)
    FirePrompt(QuestPrompt, math.huge) task.wait(1)

    --> Goto Lava Floppa
    Teleport(Vector3.new(792, -31, -443))

    --> Start loop
    _G.running = true
    while _G.running do task.wait()
        if _G.running then FirePrompt(LavaPrompt) end
    end
end

local function StopFarm()
    _G.running = false
end

--> Resume farm on death
Player.CharacterAdded:Connect(function()
    StopFarm()
    task.wait(3)
    StartFarm()
end)

--> Start farm
StartFarm()
