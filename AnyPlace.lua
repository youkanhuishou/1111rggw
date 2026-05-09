local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local ok, BridgeNet2 = pcall(function()
    return require(ReplicatedStorage:WaitForChild("BridgeNet2", 10))
end)
if not ok or not BridgeNet2 then
    warn("[AnyPlace] BridgeNet2 not found")
    return
end

local buildlist = require(ReplicatedStorage:WaitForChild("buildlist"))
local buildingBridge = BridgeNet2.ClientBridge("building")

local BLOCKS = {
    "plank", "smallplank", "crate", "smallcrate", "tungstencube",
    "balloon", "conveyor", "cannonball", "ball", "springboard",
    "floater", "arrow", "spark", "moon",
}

local ANCHORS = { "ghost", "red", "yellow", "blue", "bluemotorleft", "bluemotorright" }

local state = {
    block = "crate",
    anchor = "ghost",
    skin = "default",
    clickPlace = false,
}

local function placeBlock(cframe)
    if not cframe then return end
    local skinInst = buildlist.builds[state.block] and buildlist.builds[state.block].model:FindFirstChild(state.skin)
    local skin = skinInst and skinInst.Name or "default"
    buildingBridge:Fire({
        name = state.block,
        skin = skin,
        cframe = cframe,
        ghosting = state.anchor == "ghost",
        anchor = { state.anchor },
    })
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AnyPlaceGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = game:GetService("CoreGui")

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 240, 0, 290)
Main.Position = UDim2.new(0, 20, 0.5, 130)
Main.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
Main.BorderSizePixel = 0
Main.Active = true
Main.Parent = ScreenGui
local c = Instance.new("UICorner")
c.CornerRadius = UDim.new(0, 10)
c.Parent = Main
local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(80, 80, 80)
stroke.Thickness = 1.5
stroke.Parent = Main

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 26)
Title.Position = UDim2.new(0, 0, 0, 4)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(220, 220, 220)
Title.Text = "Any Place"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.Parent = Main

local function mkLabel(text, y)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -20, 0, 14)
    l.Position = UDim2.new(0, 10, 0, y)
    l.BackgroundTransparency = 1
    l.TextColor3 = Color3.fromRGB(200, 200, 200)
    l.Font = Enum.Font.Gotham
    l.TextSize = 12
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Text = text
    l.Parent = Main
    return l
end

local function mkDropdown(y, items, getValue, onChanged)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, -20, 0, 28)
    holder.Position = UDim2.new(0, 10, 0, y)
    holder.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    holder.BorderSizePixel = 0
    holder.Parent = Main
    local hc = Instance.new("UICorner")
    hc.CornerRadius = UDim.new(0, 6)
    hc.Parent = holder

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.TextColor3 = Color3.fromRGB(230, 230, 230)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 13
    btn.Text = getValue() .. "  v"
    btn.Parent = holder

    local list = Instance.new("ScrollingFrame")
    list.Size = UDim2.new(1, 0, 0, math.min(#items * 24, 120))
    list.Position = UDim2.new(0, 0, 1, 4)
    list.BackgroundColor3 = Color3.fromRGB(38, 38, 42)
    list.BorderSizePixel = 0
    list.CanvasSize = UDim2.new(0, 0, 0, #items * 24)
    list.ScrollBarThickness = 4
    list.Visible = false
    list.ZIndex = 5
    list.Parent = holder
    local lc = Instance.new("UICorner")
    lc.CornerRadius = UDim.new(0, 6)
    lc.Parent = list
    local layout = Instance.new("UIListLayout")
    layout.Parent = list

    for _, item in ipairs(items) do
        local opt = Instance.new("TextButton")
        opt.Size = UDim2.new(1, 0, 0, 24)
        opt.BackgroundTransparency = 1
        opt.TextColor3 = Color3.fromRGB(220, 220, 220)
        opt.Font = Enum.Font.Gotham
        opt.TextSize = 12
        opt.Text = item
        opt.ZIndex = 6
        opt.Parent = list
        opt.MouseButton1Click:Connect(function()
            onChanged(item)
            btn.Text = item .. "  v"
            list.Visible = false
        end)
    end

    btn.MouseButton1Click:Connect(function()
        list.Visible = not list.Visible
    end)
    return holder
end

mkLabel("Block:", 34)
mkDropdown(50, BLOCKS, function() return state.block end, function(v) state.block = v end)

mkLabel("Anchor:", 86)
mkDropdown(102, ANCHORS, function() return state.anchor end, function(v) state.anchor = v end)

local PlaceBtn = Instance.new("TextButton")
PlaceBtn.Size = UDim2.new(1, -20, 0, 32)
PlaceBtn.Position = UDim2.new(0, 10, 0, 140)
PlaceBtn.BackgroundColor3 = Color3.fromRGB(90, 170, 255)
PlaceBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
PlaceBtn.Text = "Place at Mouse"
PlaceBtn.Font = Enum.Font.GothamBold
PlaceBtn.TextSize = 14
PlaceBtn.BorderSizePixel = 0
PlaceBtn.AutoButtonColor = false
PlaceBtn.Parent = Main
local pc = Instance.new("UICorner")
pc.CornerRadius = UDim.new(0, 6)
pc.Parent = PlaceBtn

local PlayerBtn = Instance.new("TextButton")
PlayerBtn.Size = UDim2.new(1, -20, 0, 32)
PlayerBtn.Position = UDim2.new(0, 10, 0, 178)
PlayerBtn.BackgroundColor3 = Color3.fromRGB(140, 90, 255)
PlayerBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
PlayerBtn.Text = "Place at Me"
PlayerBtn.Font = Enum.Font.GothamBold
PlayerBtn.TextSize = 14
PlayerBtn.BorderSizePixel = 0
PlayerBtn.AutoButtonColor = false
PlayerBtn.Parent = Main
local pb = Instance.new("UICorner")
pb.CornerRadius = UDim.new(0, 6)
pb.Parent = PlayerBtn

local ClickToggle = Instance.new("TextButton")
ClickToggle.Size = UDim2.new(1, -20, 0, 32)
ClickToggle.Position = UDim2.new(0, 10, 0, 216)
ClickToggle.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
ClickToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
ClickToggle.Text = "Click-to-Place: OFF"
ClickToggle.Font = Enum.Font.GothamBold
ClickToggle.TextSize = 13
ClickToggle.BorderSizePixel = 0
ClickToggle.AutoButtonColor = false
ClickToggle.Parent = Main
local ct = Instance.new("UICorner")
ct.CornerRadius = UDim.new(0, 6)
ct.Parent = ClickToggle

local Hint = Instance.new("TextLabel")
Hint.Size = UDim2.new(1, -20, 0, 30)
Hint.Position = UDim2.new(0, 10, 0, 252)
Hint.BackgroundTransparency = 1
Hint.TextColor3 = Color3.fromRGB(160, 160, 160)
Hint.Text = "Hotkey: press G to place at mouse"
Hint.Font = Enum.Font.Gotham
Hint.TextSize = 11
Hint.TextWrapped = true
Hint.Parent = Main

local function getMouseWorldCFrame()
    local hit = Mouse.Hit
    if hit then
        return CFrame.new(hit.Position)
    end
    return nil
end

local function getPlayerCFrame()
    local char = LocalPlayer.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("CollisionPart")
        if hrp then
            return CFrame.new(hrp.Position + Vector3.new(0, 0, -4))
        end
    end
end

PlaceBtn.MouseButton1Click:Connect(function()
    placeBlock(getMouseWorldCFrame())
end)

PlayerBtn.MouseButton1Click:Connect(function()
    placeBlock(getPlayerCFrame())
end)

ClickToggle.MouseButton1Click:Connect(function()
    state.clickPlace = not state.clickPlace
    if state.clickPlace then
        ClickToggle.Text = "Click-to-Place: ON"
        ClickToggle.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
    else
        ClickToggle.Text = "Click-to-Place: OFF"
        ClickToggle.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    end
end)

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.G then
        placeBlock(getMouseWorldCFrame())
    elseif input.UserInputType == Enum.UserInputType.MouseButton1 and state.clickPlace then
        placeBlock(getMouseWorldCFrame())
    end
end)

local dragging = false
local dragInput, dragStart, startPos
local DRAG_THRESHOLD = 5

local function onBegan(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Main.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end

local function onChanged(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end

Main.InputBegan:Connect(onBegan)
Main.InputChanged:Connect(onChanged)
Title.InputBegan:Connect(onBegan)
Title.InputChanged:Connect(onChanged)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        if delta.Magnitude >= DRAG_THRESHOLD then
            Main.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end
end)
