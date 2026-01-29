--// FULL FEATURE 3D BOX ESP + GUI ONLY + MOBILE UI TOGGLE

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LP = Players.LocalPlayer

--------------------------------------------------
-- SETTINGS
--------------------------------------------------
local Settings = {
    Enabled = true,
    TeamCheck = false,
    ShowNPC = false,
    OnlyNearest = false,

    BoxSize = Vector3.new(4,6,3),
    Thickness = 0.08,
    Color = Color3.fromRGB(255,220,0),
}

--------------------------------------------------
-- ESP CORE
--------------------------------------------------
local ESP = {}
ESP.Objects = {}

local function GetRoot(model)
    return model:FindFirstChild("HumanoidRootPart")
        or model:FindFirstChild("UpperTorso")
        or model:FindFirstChild("Torso")
        or model:FindFirstChildWhichIsA("BasePart")
end

local function NewLine(parent)
    local p = Instance.new("Part")
    p.Anchored = true
    p.CanCollide = false
    p.Material = Enum.Material.Neon
    p.Color = Settings.Color
    p.Transparency = 0.1
    p.CastShadow = false
    p.Size = Vector3.new(Settings.Thickness,Settings.Thickness,1)
    p.Parent = parent
    return p
end

function ESP:Add(model)
    if self.Objects[model] then return end
    local root = GetRoot(model)
    if not root then return end

    local folder = Instance.new("Folder")
    folder.Name = "ESP3DBox"
    folder.Parent = model

    local lines = {}
    for i=1,12 do
        lines[i] = NewLine(folder)
    end

    self.Objects[model] = {
        Root = root,
        Lines = lines,
        Folder = folder
    }
end

function ESP:Remove(model)
    if self.Objects[model] then
        self.Objects[model].Folder:Destroy()
        self.Objects[model] = nil
    end
end

function ESP:Clear()
    for m,_ in pairs(self.Objects) do
        self:Remove(m)
    end
end

--------------------------------------------------
-- UPDATE LOOP
--------------------------------------------------
RunService.RenderStepped:Connect(function()
    if not Settings.Enabled then return end
    if not LP.Character then return end

    local myRoot = GetRoot(LP.Character)
    if not myRoot then return end

    local nearest, ndist = nil, math.huge
    if Settings.OnlyNearest then
        for model,data in pairs(ESP.Objects) do
            local d = (myRoot.Position - data.Root.Position).Magnitude
            if d < ndist then
                ndist = d
                nearest = model
            end
        end
    end

    for model,data in pairs(ESP.Objects) do
        if model and model.Parent and data.Root then
            if Settings.OnlyNearest and model ~= nearest then
                data.Folder.Parent = nil
                continue
            else
                data.Folder.Parent = model
            end

            local cf = data.Root.CFrame
            local size = Settings.BoxSize
            local x,y,z = size.X/2,size.Y/2,size.Z/2

            local corners = {
                cf * CFrame.new( x, y, z),
                cf * CFrame.new(-x, y, z),
                cf * CFrame.new( x,-y, z),
                cf * CFrame.new(-x,-y, z),

                cf * CFrame.new( x, y,-z),
                cf * CFrame.new(-x, y,-z),
                cf * CFrame.new( x,-y,-z),
                cf * CFrame.new(-x,-y,-z),
            }

            local edges = {
                {1,2},{1,3},{2,4},{3,4},
                {5,6},{5,7},{6,8},{7,8},
                {1,5},{2,6},{3,7},{4,8},
            }

            for i,e in ipairs(edges) do
                local a = corners[e[1]].Position
                local b = corners[e[2]].Position

                local line = data.Lines[i]
                line.Color = Settings.Color

                local dist = (a-b).Magnitude
                line.Size = Vector3.new(Settings.Thickness,Settings.Thickness,dist)
                line.CFrame = CFrame.lookAt((a+b)/2,b)
            end
        end
    end
end)

--------------------------------------------------
-- PLAYER HANDLING
--------------------------------------------------
local function AddCharacter(model, plr)
    if plr and plr == LP then return end
    if Settings.TeamCheck and plr and plr.Team == LP.Team then return end
    ESP:Add(model)
end

local function WatchPlayer(plr)
    plr.CharacterAdded:Connect(function(char)
        task.wait(1)
        if Settings.Enabled then
            AddCharacter(char, plr)
        end
    end)

    if plr.Character then
        AddCharacter(plr.Character, plr)
    end
end

for _,p in pairs(Players:GetPlayers()) do
    WatchPlayer(p)
end
Players.PlayerAdded:Connect(WatchPlayer)

--------------------------------------------------
-- GUI MAIN
--------------------------------------------------
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "ESP_GUI"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.fromScale(0.22,0.45)
frame.Position = UDim2.fromScale(0.05,0.25)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
Instance.new("UICorner",frame).CornerRadius = UDim.new(0,14)

local layout = Instance.new("UIListLayout",frame)
layout.Padding = UDim.new(0,6)

--------------------------------------------------
-- MOBILE TOGGLE BUTTON
--------------------------------------------------
local uiVisible = true

local mini = Instance.new("Frame", gui)
mini.Size = UDim2.fromScale(0.12,0.07)
mini.Position = UDim2.fromScale(0.82,0.15)
mini.BackgroundColor3 = Color3.fromRGB(35,35,35)
mini.BorderSizePixel = 0
mini.Active = true
mini.Draggable = true
Instance.new("UICorner",mini).CornerRadius = UDim.new(0,16)

local miniBtn = Instance.new("TextButton", mini)
miniBtn.Size = UDim2.fromScale(1,1)
miniBtn.BackgroundTransparency = 1
miniBtn.Text = "MENU"
miniBtn.Font = Enum.Font.GothamBold
miniBtn.TextScaled = true
miniBtn.TextColor3 = Color3.fromRGB(0,255,120)

miniBtn.MouseButton1Click:Connect(function()
    uiVisible = not uiVisible
    frame.Visible = uiVisible
    miniBtn.Text = uiVisible and "MENU" or "SHOW"
end)

--------------------------------------------------
-- GUI BUTTON CREATOR
--------------------------------------------------
local function NewButton(txt,callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1,-10,0,36)
    b.Position = UDim2.new(0,5,0,0)
    b.Text = txt
    b.Font = Enum.Font.GothamBold
    b.TextScaled = true
    b.BackgroundColor3 = Color3.fromRGB(40,40,40)
    b.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner",b)
    b.Parent = frame
    b.MouseButton1Click:Connect(callback)
    return b
end

--------------------------------------------------
-- GUI CONTROLS
--------------------------------------------------
local espBtn = NewButton("ESP: ON",function()
    Settings.Enabled = not Settings.Enabled
    espBtn.Text = "ESP: "..(Settings.Enabled and "ON" or "OFF")
    if not Settings.Enabled then
        ESP:Clear()
    end
end)

local teamBtn = NewButton("TeamCheck: OFF",function()
    Settings.TeamCheck = not Settings.TeamCheck
    teamBtn.Text = "TeamCheck: "..(Settings.TeamCheck and "ON" or "OFF")
end)

local npcBtn = NewButton("NPC: OFF",function()
    Settings.ShowNPC = not Settings.ShowNPC
    npcBtn.Text = "NPC: "..(Settings.ShowNPC and "ON" or "OFF")
end)

local nearBtn = NewButton("OnlyNearest: OFF",function()
    Settings.OnlyNearest = not Settings.OnlyNearest
    nearBtn.Text = "OnlyNearest: "..(Settings.OnlyNearest and "ON" or "OFF")
end)

NewButton("Bigger Box",function()
    Settings.BoxSize += Vector3.new(1,1,1)
end)

NewButton("Smaller Box",function()
    Settings.BoxSize -= Vector3.new(1,1,1)
end)

NewButton("Random Color",function()
    Settings.Color = Color3.fromHSV(math.random(),1,1)
end)

--------------------------------------------------
-- API
--------------------------------------------------
_G.ESP_FULL = {
    Enable = function()
        Settings.Enabled = true
    end,
    Disable = function()
        Settings.Enabled = false
        ESP:Clear()
    end,
    Settings = Settings
}
