-- Bee Swarm Simulator - Server Info GUI
-- Single Instance + Minimize + Toggle + Custom Icon

local Players = game:GetService("Players")
local Stats = game:GetService("Stats")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer

--------------------------------------------------
-- REMOVE OLD GUI
--------------------------------------------------

local pg = player:WaitForChild("PlayerGui")
local old = pg:FindFirstChild("BeeServerInfoGui")
if old then
    old:Destroy()
end

--------------------------------------------------
-- SETTINGS (CHANGE ICON HERE)
--------------------------------------------------

local TOGGLE_ICON_ID = "rbxassetid://7072724538" -- <-- đổi ảnh tại đây
local MINIMIZE_ICON_ID = "rbxassetid://7072719338"

--------------------------------------------------
-- GUI ROOT
--------------------------------------------------

local gui = Instance.new("ScreenGui")
gui.Name = "BeeServerInfoGui"
gui.ResetOnSpawn = false
gui.Parent = pg

--------------------------------------------------
-- TOGGLE BUTTON
--------------------------------------------------

local toggleBtn = Instance.new("ImageButton")
toggleBtn.Parent = gui
toggleBtn.Size = UDim2.fromOffset(52,52)
toggleBtn.Position = UDim2.fromScale(0.05,0.6)
toggleBtn.Image = TOGGLE_ICON_ID
toggleBtn.BackgroundColor3 = Color3.fromRGB(255,200,80)
toggleBtn.AutoButtonColor = true

Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(1,0)

--------------------------------------------------
-- MAIN FRAME
--------------------------------------------------

local frame = Instance.new("Frame")
frame.Parent = gui
frame.AnchorPoint = Vector2.new(0.5,0.5)
frame.Position = UDim2.fromScale(0.5,0.5)
frame.Size = UDim2.fromScale(0.7,0.55)
frame.BackgroundColor3 = Color3.fromRGB(28,28,28)
frame.Active = true
frame.Visible = true

Instance.new("UICorner", frame).CornerRadius = UDim.new(0,18)

--------------------------------------------------
-- RESPONSIVE SCALE
--------------------------------------------------

local scale = Instance.new("UIScale", frame)
scale.Scale = math.clamp(workspace.CurrentCamera.ViewportSize.X / 900, 0.75, 1.1)

workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
    scale.Scale = math.clamp(workspace.CurrentCamera.ViewportSize.X / 900, 0.75, 1.1)
end)

--------------------------------------------------
-- TITLE BAR
--------------------------------------------------

local titleBar = Instance.new("Frame", frame)
titleBar.Size = UDim2.new(1,0,0,46)
titleBar.BackgroundTransparency = 1

local title = Instance.new("TextLabel", titleBar)
title.Size = UDim2.new(1,-100,1,0)
title.Position = UDim2.new(0,12,0,0)
title.Text = "🐝 Bee Swarm - Server Info"
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.TextColor3 = Color3.fromRGB(255,215,90)
title.BackgroundTransparency = 1
title.TextXAlignment = Left

--------------------------------------------------
-- MINIMIZE BUTTON
--------------------------------------------------

local minimizeBtn = Instance.new("ImageButton", titleBar)
minimizeBtn.Size = UDim2.fromOffset(34,34)
minimizeBtn.Position = UDim2.new(1,-40,0.5,-17)
minimizeBtn.Image = MINIMIZE_ICON_ID
minimizeBtn.BackgroundColor3 = Color3.fromRGB(255,200,80)

Instance.new("UICorner", minimizeBtn).CornerRadius = UDim.new(1,0)

--------------------------------------------------
-- INFO LABEL
--------------------------------------------------

local info = Instance.new("TextLabel", frame)
info.Position = UDim2.new(0,14,0,56)
info.Size = UDim2.new(1,-28,1,-120)
info.TextWrapped = true
info.TextXAlignment = Left
info.TextYAlignment = Top
info.Font = Enum.Font.Gotham
info.TextSize = 15
info.TextColor3 = Color3.fromRGB(220,220,220)
info.BackgroundTransparency = 1

--------------------------------------------------
-- DRAG SUPPORT
--------------------------------------------------

do
    local dragging, dragStart, startPos

    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = startPos + UDim2.fromOffset(delta.X, delta.Y)
        end
    end)

    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch) then
            dragging = false
        end
    end)
end

--------------------------------------------------
-- DATA
--------------------------------------------------

local function safePing()
    local ok, result = pcall(function()
        local net = Stats:FindFirstChild("Network")
        local stats = net and net:FindFirstChild("ServerStatsItem")
        local ping = stats and stats:FindFirstChild("Data Ping")
        return ping and ping:GetValueString() or "N/A"
    end)
    return ok and result or "N/A"
end

local function updateInfo()
    local t = {}

    t[#t+1] = "🆔 JobId: ".. game.JobId
    t[#t+1] = "📍 PlaceId: ".. game.PlaceId
    t[#t+1] = "👥 Players: ".. #Players:GetPlayers() .. "/" .. Players.MaxPlayers
    t[#t+1] = "📶 Ping: ".. safePing()
    t[#t+1] = "⏱ Server Time: ".. math.floor(workspace:GetServerTimeNow()) .. "s"

    t[#t+1] = "\n--- Player List ---"
    for i, p in ipairs(Players:GetPlayers()) do
        t[#t+1] = i..". ".. p.Name
    end

    info.Text = table.concat(t,"\n")
end

--------------------------------------------------
-- BUTTON LOGIC
--------------------------------------------------

local minimized = false

minimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized

    info.Visible = not minimized

    if minimized then
        frame.Size = UDim2.fromScale(0.7,0.18)
    else
        frame.Size = UDim2.fromScale(0.7,0.55)
    end
end)

toggleBtn.MouseButton1Click:Connect(function()
    frame.Visible = not frame.Visible
end)

--------------------------------------------------
-- AUTO UPDATE
--------------------------------------------------

task.spawn(function()
    while true do
        task.wait(12)
        updateInfo()
    end
end)

updateInfo()
