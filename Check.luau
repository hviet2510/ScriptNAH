-- Bee Swarm Simulator - Speed GUI + JSON Save Config
-- Folder + File Save | Toggle | Slider | PC + Mobile

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer
local pg = player:WaitForChild("PlayerGui")

--------------------------------------------------
-- REMOVE OLD GUI
--------------------------------------------------
if pg:FindFirstChild("BeeSpeedGui") then
    pg.BeeSpeedGui:Destroy()
end

--------------------------------------------------
-- SAVE PATH
--------------------------------------------------
local FOLDER = "BeeSwarmConfig"
local FILE = FOLDER .. "/speed.json"

-- create folder if not exist
if isfolder and makefolder then
    if not isfolder(FOLDER) then
        makefolder(FOLDER)
    end
end

--------------------------------------------------
-- LOAD CONFIG
--------------------------------------------------
local config = {
    speed = 40,
    enabled = true
}

if readfile and isfile and isfile(FILE) then
    local ok, data = pcall(function()
        return HttpService:JSONDecode(readfile(FILE))
    end)

    if ok and type(data) == "table" then
        config.speed = data.speed or config.speed
        config.enabled = data.enabled ~= false
    end
end

local currentSpeed = config.speed
local enabled = config.enabled

--------------------------------------------------
-- GUI ROOT
--------------------------------------------------
local gui = Instance.new("ScreenGui")
gui.Name = "BeeSpeedGui"
gui.ResetOnSpawn = false
gui.Parent = pg

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.fromScale(0.45, 0.28)
frame.Position = UDim2.fromScale(0.5, 0.75)
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)

Instance.new("UICorner", frame).CornerRadius = UDim.new(0,14)

--------------------------------------------------
-- TITLE
--------------------------------------------------
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,36)
title.Text = "⚡ Speed Control"
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextColor3 = Color3.fromRGB(255,210,90)
title.BackgroundTransparency = 1

--------------------------------------------------
-- TOGGLE
--------------------------------------------------
local toggle = Instance.new("TextButton", frame)
toggle.Size = UDim2.new(0.45,0,0,36)
toggle.Position = UDim2.new(0.05,0,0.45,0)
toggle.Font = Enum.Font.GothamBold
toggle.TextSize = 15

Instance.new("UICorner", toggle)

--------------------------------------------------
-- SPEED LABEL
--------------------------------------------------
local speedLabel = Instance.new("TextLabel", frame)
speedLabel.Size = UDim2.new(0.45,0,0,36)
speedLabel.Position = UDim2.new(0.5,0,0.45,0)
speedLabel.Font = Enum.Font.Gotham
speedLabel.TextSize = 14
speedLabel.TextColor3 = Color3.fromRGB(230,230,230)
speedLabel.BackgroundTransparency = 1

--------------------------------------------------
-- SLIDER BAR
--------------------------------------------------
local bar = Instance.new("Frame", frame)
bar.Size = UDim2.new(0.9,0,0,10)
bar.Position = UDim2.new(0.05,0,0.8,0)
bar.BackgroundColor3 = Color3.fromRGB(70,70,70)

Instance.new("UICorner", bar)

local fill = Instance.new("Frame", bar)
fill.BackgroundColor3 = Color3.fromRGB(255,200,80)

Instance.new("UICorner", fill)

--------------------------------------------------
-- UI UPDATE
--------------------------------------------------
local function updateUI()
    toggle.Text = enabled and "ON" or "OFF"
    toggle.BackgroundColor3 = enabled
        and Color3.fromRGB(90,200,90)
        or Color3.fromRGB(200,90,90)

    speedLabel.Text = "Speed: " .. currentSpeed

    local percent = math.clamp(
        (currentSpeed - 16) / (120 - 16),
        0, 1
    )

    fill.Size = UDim2.new(percent,0,1,0)
end

--------------------------------------------------
-- SAVE CONFIG
--------------------------------------------------
local function saveConfig()
    if writefile then
        local data = {
            speed = currentSpeed,
            enabled = enabled
        }

        writefile(FILE, HttpService:JSONEncode(data))
    end
end

--------------------------------------------------
-- SPEED APPLY
--------------------------------------------------
local function applySpeed()
    local char = player.Character
    if not char then return end

    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = enabled and currentSpeed or 16
    end
end

player.CharacterAdded:Connect(function()
    task.wait(0.4)
    applySpeed()
end)

--------------------------------------------------
-- TOGGLE LOGIC
--------------------------------------------------
toggle.MouseButton1Click:Connect(function()
    enabled = not enabled
    updateUI()
    applySpeed()
    saveConfig()
end)

--------------------------------------------------
-- SLIDER CONTROL (PC + MOBILE)
--------------------------------------------------
local dragging = false

bar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
    end
end)

bar.InputEnded:Connect(function()
    dragging = false
end)

UIS.InputChanged:Connect(function(input)
    if not dragging then return end

    if input.UserInputType == Enum.UserInputType.MouseMovement
    or input.UserInputType == Enum.UserInputType.Touch then

        local pos = math.clamp(
            (input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X,
            0, 1
        )

        currentSpeed = math.floor(16 + (120 - 16) * pos)

        updateUI()
        applySpeed()
        saveConfig()
    end
end)

--------------------------------------------------
updateUI()
applySpeed()

print("⚡ Bee Speed GUI loaded + JSON save config!")
