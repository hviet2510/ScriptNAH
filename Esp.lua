--// UNIVERSAL 3D BOX + LASER TRACER ESP (DELTA)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LP = Players.LocalPlayer

local ESP = {}

-- get root part
local function GetRoot(char)
    return char:FindFirstChild("HumanoidRootPart")
        or char:FindFirstChild("UpperTorso")
        or char:FindFirstChild("Torso")
        or char:FindFirstChildWhichIsA("BasePart")
end

-- create neon line
local function NewLine(parent,color)
    local p = Instance.new("Part")
    p.Anchored = true
    p.CanCollide = false
    p.Material = Enum.Material.Neon
    p.Color = color
    p.Transparency = 0.05
    p.CastShadow = false
    p.Size = Vector3.new(0.1,0.1,1)
    p.Parent = parent
    return p
end

-- create esp set
local function CreateESP(char)
    local root = GetRoot(char)
    if not root then return end

    local folder = Instance.new("Folder")
    folder.Name = "ESP_VISUAL"
    folder.Parent = char

    -- 3D box edges
    local lines = {}
    for i=1,12 do
        lines[i] = NewLine(folder, Color3.fromRGB(255,220,0))
    end

    -- tracer laser
    local tracer = NewLine(folder, Color3.fromRGB(255,0,0))

    ESP[char] = {
        Root = root,
        BoxLines = lines,
        Tracer = tracer
    }
end

-- update visuals
RunService.RenderStepped:Connect(function()
    if not LP.Character then return end
    local myRoot = GetRoot(LP.Character)
    if not myRoot then return end

    for char,data in pairs(ESP) do
        if char and char.Parent and data.Root then
            local cf = data.Root.CFrame
            local size = Vector3.new(4,6,3)

            local x,y,z = size.X/2, size.Y/2, size.Z/2

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

                local line = data.BoxLines[i]
                local dist = (a-b).Magnitude
                line.Size = Vector3.new(0.08,0.08,dist)
                line.CFrame = CFrame.lookAt((a+b)/2, b)
            end

            -- tracer line
            local startPos = myRoot.Position
            local endPos = data.Root.Position

            local tdist = (startPos-endPos).Magnitude
            data.Tracer.Size = Vector3.new(0.1,0.1,tdist)
            data.Tracer.CFrame = CFrame.lookAt((startPos+endPos)/2, endPos)
            data.Tracer.Transparency = 0
        end
    end
end)

-- add player
local function AddPlayer(plr)
    if plr == LP then return end

    local function Char(char)
        task.wait(1)
        CreateESP(char)
    end

    if plr.Character then
        Char(plr.Character)
    end

    plr.CharacterAdded:Connect(Char)
end

for _,p in pairs(Players:GetPlayers()) do
    AddPlayer(p)
end
Players.PlayerAdded:Connect(AddPlayer)
