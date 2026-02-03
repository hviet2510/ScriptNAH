-- Bee Swarm Simulator - FINAL FULL FIXED VERSION
-- Smooth Speed | Stable Slider | VIP Rejoin | JSON Save | Webhook | Optimized

---------------- SERVICES ----------------
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local UIS = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local GuiService = game:GetService("GuiService")

local player = Players.LocalPlayer
local pg = player:WaitForChild("PlayerGui")

---------------- CLEAN OLD ----------------
if pg:FindFirstChild("BeeSpeedGui") then
    pg.BeeSpeedGui:Destroy()
end

---------------- SAVE ----------------
local FOLDER = "BeeSwarmConfig"
local FILE = FOLDER .. "/config.json"

if isfolder and makefolder and not isfolder(FOLDER) then
    makefolder(FOLDER)
end

---------------- LOAD CONFIG ----------------
local config = {
    speed = 60,
    enabled = true,
    vipLink = "https://www.roblox.com/share?code=20126a0e28925e4393f7a7b9e69e4f4f&type=Server",
    webhook = "https://discord.com/api/webhooks/1221364248785981571/ZNqaNh7eMz-OKalevl5kU5rki1p4qQbWYlGWbV77LM5SFJkMPi7N1CeWJAQpfyPCNPc1"
}

if readfile and isfile and isfile(FILE) then
    local ok, data = pcall(function()
        return HttpService:JSONDecode(readfile(FILE))
    end)

    if ok and type(data) == "table" then
        for k,v in pairs(config) do
            if data[k] ~= nil then
                config[k] = data[k]
            end
        end
    end
end

local currentSpeed = config.speed
local desiredSpeed = currentSpeed
local enabled = config.enabled
local VIP_LINK = config.vipLink
local WEBHOOK_URL = config.webhook

---------------- SPEED SETTINGS ----------------
local BASE_SPEED = 16
local MAX_SAFE_SPEED = 70

---------------- GUI ROOT ----------------
local gui = Instance.new("ScreenGui")
gui.Name = "BeeSpeedGui"
gui.ResetOnSpawn = false
gui.Parent = pg

---------------- TOGGLE BUTTON ----------------
local toggleGuiBtn = Instance.new("TextButton", gui)
toggleGuiBtn.Size = UDim2.fromOffset(90,42)
toggleGuiBtn.Position = UDim2.fromScale(0.05,0.5)
toggleGuiBtn.Text = "⚡ SPEED"
toggleGuiBtn.Font = Enum.Font.GothamBold
toggleGuiBtn.TextSize = 13
toggleGuiBtn.BackgroundColor3 = Color3.fromRGB(255,200,80)
Instance.new("UICorner", toggleGuiBtn)

---------------- FRAME ----------------
local frame = Instance.new("Frame", gui)
frame.AnchorPoint = Vector2.new(0.5,0.5)
frame.Position = UDim2.fromScale(0.5,0.5)
frame.Size = UDim2.fromScale(0.55,0.52)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,16)

---------------- TITLE ----------------
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,44)
title.Text = "⚡ Bee Speed Hub"
title.Font = Enum.Font.GothamBold
title.TextSize = 19
title.TextColor3 = Color3.fromRGB(255,210,90)
title.BackgroundTransparency = 1

---------------- TOGGLE SPEED ----------------
local toggle = Instance.new("TextButton", frame)
toggle.Size = UDim2.new(0.5,0,0,38)
toggle.Position = UDim2.new(0.25,0,0.28,0)
toggle.Font = Enum.Font.GothamBold
toggle.TextSize = 16
Instance.new("UICorner", toggle)

---------------- SPEED LABEL ----------------
local speedLabel = Instance.new("TextLabel", frame)
speedLabel.Size = UDim2.new(1,0,0,30)
speedLabel.Position = UDim2.new(0,0,0.44,0)
speedLabel.Font = Enum.Font.Gotham
speedLabel.TextSize = 15
speedLabel.TextColor3 = Color3.fromRGB(230,230,230)
speedLabel.BackgroundTransparency = 1

---------------- SLIDER ----------------
local bar = Instance.new("Frame", frame)
bar.Size = UDim2.new(0.85,0,0,12)
bar.Position = UDim2.new(0.075,0,0.6,0)
bar.BackgroundColor3 = Color3.fromRGB(70,70,70)
Instance.new("UICorner", bar)

local fill = Instance.new("Frame", bar)
fill.BackgroundColor3 = Color3.fromRGB(255,200,80)
Instance.new("UICorner", fill)

---------------- VIP BOX ----------------
local vipBox = Instance.new("TextBox", frame)
vipBox.Size = UDim2.new(0.9,0,0,34)
vipBox.Position = UDim2.new(0.05,0,0.74,0)
vipBox.PlaceholderText = "Paste VIP server link..."
vipBox.Text = VIP_LINK
vipBox.Font = Enum.Font.Gotham
vipBox.TextSize = 14
vipBox.BackgroundColor3 = Color3.fromRGB(45,45,45)
vipBox.TextColor3 = Color3.fromRGB(240,240,240)
Instance.new("UICorner", vipBox)

---------------- WEBHOOK BOX ----------------
local webhookBox = Instance.new("TextBox", frame)
webhookBox.Size = UDim2.new(0.9,0,0,34)
webhookBox.Position = UDim2.new(0.05,0,0.84,0)
webhookBox.PlaceholderText = "Discord webhook (optional)"
webhookBox.Text = WEBHOOK_URL
webhookBox.Font = Enum.Font.Gotham
webhookBox.TextSize = 14
webhookBox.BackgroundColor3 = Color3.fromRGB(45,45,45)
webhookBox.TextColor3 = Color3.fromRGB(240,240,240)
Instance.new("UICorner", webhookBox)

---------------- UI UPDATE ----------------
local function updateUI()
    toggle.Text = enabled and "ON" or "OFF"
    toggle.BackgroundColor3 =
        enabled and Color3.fromRGB(90,200,90)
        or Color3.fromRGB(200,90,90)

    speedLabel.Text = "Speed: "..currentSpeed

    fill.Size = UDim2.new(
        math.clamp(
            (currentSpeed - BASE_SPEED) /
            (MAX_SAFE_SPEED - BASE_SPEED),
            0,1
        ),
        0,1,0
    )
end

---------------- SAVE ----------------
local function saveConfig()
    if writefile then
        writefile(FILE, HttpService:JSONEncode(config))
    end
end

---------------- SPEED LOOP (STABLE) ----------------
local SPEED_EPSILON = 0.15

task.spawn(function()
    while true do
        task.wait(enabled and 0.09 or 0.28)

        local char = player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")

        if hum and hum.Health > 0 then
            local target = enabled and desiredSpeed or BASE_SPEED
            target = math.clamp(target, BASE_SPEED, MAX_SAFE_SPEED)

            local diff = target - hum.WalkSpeed

            if math.abs(diff) > SPEED_EPSILON then
                hum.WalkSpeed += diff * 0.11
            end
        end
    end
end)

local function setDesiredSpeed(v)
    desiredSpeed = math.clamp(v, BASE_SPEED, MAX_SAFE_SPEED)
end

player.CharacterAdded:Connect(function()
    task.wait(0.6)
    setDesiredSpeed(currentSpeed)
end)

---------------- BUTTONS ----------------
toggle.MouseButton1Click:Connect(function()
    enabled = not enabled
    config.enabled = enabled
    updateUI()
    saveConfig()
end)

local dragging = false

bar.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1
    or i.UserInputType == Enum.UserInputType.Touch then
        dragging = true
    end
end)

bar.InputEnded:Connect(function()
    dragging = false
end)

UIS.InputChanged:Connect(function(i)
    if not dragging then return end

    if i.UserInputType == Enum.UserInputType.MouseMovement
    or i.UserInputType == Enum.UserInputType.Touch then

        local pos = math.clamp(
            (i.Position.X - bar.AbsolutePosition.X)
            / bar.AbsoluteSize.X,
            0,1
        )

        local newSpeed = math.floor(
            BASE_SPEED +
            (MAX_SAFE_SPEED - BASE_SPEED) * pos
        )

        if newSpeed ~= currentSpeed then
            currentSpeed = newSpeed
            config.speed = newSpeed
            setDesiredSpeed(newSpeed)
            updateUI()
            saveConfig()
        end
    end
end)

vipBox.FocusLost:Connect(function()
    VIP_LINK = vipBox.Text
    config.vipLink = VIP_LINK
    saveConfig()
end)

webhookBox.FocusLost:Connect(function()
    WEBHOOK_URL = webhookBox.Text
    config.webhook = WEBHOOK_URL
    saveConfig()
end)

toggleGuiBtn.MouseButton1Click:Connect(function()
    frame.Visible = not frame.Visible
end)

---------------- VIP AUTO REJOIN ----------------
local teleporting = false
local LAST_REJOIN = 0
local REJOIN_DELAY = 6
local REJOIN_COOLDOWN = 60

local function extractPrivateId(link)
    if type(link) ~= "string" then return nil end
    return
        link:match("privateServerLinkCode=([%w%-_]+)") or
        link:match("code=([%w%-_]+)")
end

local function sendWebhook(msg)
    local req =
        (syn and syn.request)
        or request
        or http_request

    if not req or WEBHOOK_URL == "" then return end

    task.spawn(function()
        pcall(function()
            req({
                Url = WEBHOOK_URL,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = HttpService:JSONEncode({
                    content = "🐝 **Bee Swarm Auto Rejoin**\n"..msg
                })
            })
        end)
    end)
end

local function rejoinVIP(reason)
    if teleporting then return end
    if os.clock() - LAST_REJOIN < REJOIN_COOLDOWN then return end
    if VIP_LINK == "" then return end

    local privateId = extractPrivateId(VIP_LINK)
    if not privateId then return end

    teleporting = true
    LAST_REJOIN = os.clock()

    local msg =
        "⚠ Kicked\n"..
        "Player: "..player.Name.."\n"..
        "Reason: "..tostring(reason)

    warn(msg)
    sendWebhook(msg)

    task.delay(REJOIN_DELAY, function()
        local ok = pcall(function()
            TeleportService:TeleportToPrivateServer(
                game.PlaceId,
                privateId,
                {player}
            )
        end)

        if not ok then
            teleporting = false
        end
    end)
end

GuiService.ErrorMessageChanged:Connect(function(msg)
    if msg and msg ~= "" then
        rejoinVIP(msg)
    end
end)

---------------- INIT ----------------
setDesiredSpeed(currentSpeed)
updateUI()

print("⚡ Bee Swarm FINAL FULL FIX loaded!")
