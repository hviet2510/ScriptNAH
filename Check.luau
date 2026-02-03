-- Bee Swarm Simulator - Speed GUI (Simple)
-- JSON Save | Drag | Toggle GUI | PC + Mobile

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

if isfolder and makefolder then
    if not isfolder(FOLDER) then
        makefolder(FOLDER)
    end
end

--------------------------------------------------
-- LOAD CONFIG
--------------------------------------------------
local config = { speed = 40, enabled = true }

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

--------------------------------------------------
-- TOGGLE GUI BUTTON
--------------------------------------------------
local toggleGuiBtn = Instance.new("TextButton", gui)
toggleGuiBtn.Size = UDim2.fromOffset(70,40)
toggleGuiBtn.Position = UDim2.fromScale(0.05,0.5)
toggleGuiBtn.Text = "⚡ SPEED"
toggleGuiBtn.Font = Enum.Font.GothamBold
toggleGuiBtn.TextSize = 13
toggleGuiBtn.BackgroundColor3 = Color3.fromRGB(255,200,80)

Instance.new("UICorner", toggleGuiBtn)

--------------------------------------------------
-- MAIN FRAME
--------------------------------------------------
local frame = Instance.new("Frame", gui)
frame.AnchorPoint = Vector2.new(0.5,0.5)
frame.Position = UDim2.fromScale(0.5,0.5)
frame.Size = UDim2.fromScale(0.5,0.4)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
frame.Active = true

Instance.new("UICorner", frame).CornerRadius = UDim.new(0,16)

--------------------------------------------------
-- DRAG GUI
--------------------------------------------------
do
    local dragging = false
    local dragStart, startPos

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if dragging and
        (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then

            local delta = input.Position - dragStart
            frame.Position = startPos + UDim2.fromOffset(delta.X, delta.Y)
        end
    end)

    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

--------------------------------------------------
-- TITLE
--------------------------------------------------
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,42)
title.Text = "⚡ Speed Controller"
title.Font = Enum.Font.GothamBold
title.TextSize = 19
title.TextColor3 = Color3.fromRGB(255,210,90)
title.BackgroundTransparency = 1

--------------------------------------------------
-- TOGGLE SPEED
--------------------------------------------------
local toggle = Instance.new("TextButton", frame)
toggle.Size = UDim2.new(0.5,0,0,38)
toggle.Position = UDim2.new(0.25,0,0.32,0)
toggle.Font = Enum.Font.GothamBold
toggle.TextSize = 16

Instance.new("UICorner", toggle)

--------------------------------------------------
-- SPEED LABEL
--------------------------------------------------
local speedLabel = Instance.new("TextLabel", frame)
speedLabel.Size = UDim2.new(1,0,0,30)
speedLabel.Position = UDim2.new(0,0,0.5,0)
speedLabel.Font = Enum.Font.Gotham
speedLabel.TextSize = 15
speedLabel.TextColor3 = Color3.fromRGB(230,230,230)
speedLabel.BackgroundTransparency = 1

--------------------------------------------------
-- SLIDER BAR
--------------------------------------------------
local bar = Instance.new("Frame", frame)
bar.Size = UDim2.new(0.85,0,0,12)
bar.Position = UDim2.new(0.075,0,0.7,0)
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

    local percent = math.clamp((currentSpeed - 16) / (120 - 16), 0, 1)
    fill.Size = UDim2.new(percent,0,1,0)
end

--------------------------------------------------
-- SAVE CONFIG
--------------------------------------------------
local function saveConfig()
    if writefile then
        writefile(FILE, HttpService:JSONEncode({
            speed = currentSpeed,
            enabled = enabled
        }))
    end
end

--------------------------------------------------
-- APPLY SPEED
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
-- TOGGLE SPEED
--------------------------------------------------
toggle.MouseButton1Click:Connect(function()
    enabled = not enabled
    updateUI()
    applySpeed()
    saveConfig()
end)

--------------------------------------------------
-- SLIDER CONTROL
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
-- TOGGLE GUI VISIBILITY
--------------------------------------------------
toggleGuiBtn.MouseButton1Click:Connect(function()
    frame.Visible = not frame.Visible
end)

--------------------------------------------------
updateUI()
applySpeed()

print("⚡ Bee Speed GUI loaded (simple version)")
