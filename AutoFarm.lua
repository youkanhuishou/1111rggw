local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local enabled = false
local teleportDelay = 0.11
local offsetX = 1
local offsetY = 0.6
local offsetZ = -9.6

local cachedCoins = {}
local cachedDoor = nil
local hoverConnection = nil
local savedCollide = {}

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AutoFarmGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = game:GetService("CoreGui")

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 220, 0, 220)
Main.Position = UDim2.new(0, 20, 0.5, -110)
Main.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
Main.BorderSizePixel = 0
Main.Active = true
Main.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = Main

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(80, 80, 80)
MainStroke.Thickness = 1.5
MainStroke.Parent = Main

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 26)
Title.Position = UDim2.new(0, 0, 0, 4)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(220, 220, 220)
Title.Text = "Auto Farm"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.Parent = Main

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(1, -20, 0, 36)
ToggleButton.Position = UDim2.new(0, 10, 0, 34)
ToggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Text = "OFF"
ToggleButton.TextSize = 14
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.BorderSizePixel = 0
ToggleButton.AutoButtonColor = false
ToggleButton.Parent = Main

local TBCorner = Instance.new("UICorner")
TBCorner.CornerRadius = UDim.new(0, 6)
TBCorner.Parent = ToggleButton

local function makeSlider(yPos, labelText, minVal, maxVal, defaultVal, decimals, onChanged)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -20, 0, 32)
    container.Position = UDim2.new(0, 10, 0, yPos)
    container.BackgroundTransparency = 1
    container.Parent = Main

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 14)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.Font = Enum.Font.Gotham
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Text = labelText .. ": " .. string.format("%." .. decimals .. "f", defaultVal)
    label.Parent = container

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, 0, 0, 8)
    bar.Position = UDim2.new(0, 0, 0, 18)
    bar.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
    bar.BorderSizePixel = 0
    bar.Parent = container
    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(1, 0)
    barCorner.Parent = bar

    local fill = Instance.new("Frame")
    fill.BackgroundColor3 = Color3.fromRGB(90, 170, 255)
    fill.BorderSizePixel = 0
    fill.Size = UDim2.new((defaultVal - minVal) / (maxVal - minVal), 0, 1, 0)
    fill.Parent = bar
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill

    local sliding = false
    local function setFromX(px)
        local rel = math.clamp((px - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        local val = minVal + rel * (maxVal - minVal)
        fill.Size = UDim2.new(rel, 0, 1, 0)
        label.Text = labelText .. ": " .. string.format("%." .. decimals .. "f", val)
        onChanged(val)
    end

    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            sliding = true
            setFromX(input.Position.X)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            sliding = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            setFromX(input.Position.X)
        end
    end)
end

makeSlider(80, "Speed", 0.02, 0.5, teleportDelay, 2, function(v)
    teleportDelay = v
end)
makeSlider(115, "Offset X", -10, 10, offsetX, 1, function(v)
    offsetX = v
end)
makeSlider(150, "Offset Y", -10, 10, offsetY, 1, function(v)
    offsetY = v
end)
makeSlider(185, "Offset Z", -20, 20, offsetZ, 1, function(v)
    offsetZ = v
end)

local dragging = false
local dragInput, dragStart, startPos
local DRAG_THRESHOLD = 5
local didDrag = false

local function onInputBegan(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        didDrag = false
        dragStart = input.Position
        startPos = Main.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end

local function onInputChanged(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end

Main.InputBegan:Connect(onInputBegan)
Main.InputChanged:Connect(onInputChanged)
Title.InputBegan:Connect(onInputBegan)
Title.InputChanged:Connect(onInputChanged)
ToggleButton.InputBegan:Connect(onInputBegan)
ToggleButton.InputChanged:Connect(onInputChanged)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        if delta.Magnitude >= DRAG_THRESHOLD then
            didDrag = true
        end
        if didDrag then
            Main.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end
end)

local function getCharacter()
    return LocalPlayer.Character
end

local function getHRP()
    local char = getCharacter()
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function getCollisionPart()
    local char = getCharacter()
    return char and char:FindFirstChild("CollisionPart")
end

local function teleportTo(position)
    local char = getCharacter()
    if not char then return end
    local target = position + Vector3.new(offsetX, offsetY, offsetZ)
    local cf = CFrame.new(target)
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local cp = char:FindFirstChild("CollisionPart")
    if cp then
        cp.CFrame = cf
        cp.AssemblyLinearVelocity = Vector3.zero
    end
    if hrp then
        hrp.CFrame = cf
        hrp.AssemblyLinearVelocity = Vector3.zero
    end
end

local function applyHover(char)
    if not char then return end
    table.clear(savedCollide)
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            savedCollide[part] = part.CanCollide
            part.CanCollide = false
        end
    end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.PlatformStand = true
    end
end

local function removeHover(char)
    if char then
        for part, val in pairs(savedCollide) do
            if part and part.Parent then
                part.CanCollide = val
            end
        end
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.PlatformStand = false
        end
    end
    table.clear(savedCollide)
end

local function startHover()
    if hoverConnection then hoverConnection:Disconnect() end
    local char = getCharacter()
    applyHover(char)
    hoverConnection = RunService.Heartbeat:Connect(function()
        if not enabled then return end
        local c = getCharacter()
        if not c then return end
        local humanoid = c:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.PlatformStand = true
        end
        local hrp = c:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.AssemblyLinearVelocity = Vector3.zero
        end
        local cp = c:FindFirstChild("CollisionPart")
        if cp then
            cp.AssemblyLinearVelocity = Vector3.zero
        end
    end)
end

local function stopHover()
    if hoverConnection then
        hoverConnection:Disconnect()
        hoverConnection = nil
    end
    removeHover(getCharacter())
end

local function refreshCoins()
    table.clear(cachedCoins)
    for _, obj in ipairs(CollectionService:GetTagged("spinnyrobux")) do
        if obj:IsDescendantOf(workspace) and obj:IsA("BasePart") then
            table.insert(cachedCoins, obj)
        end
    end
end

local function refreshDoor()
    cachedDoor = nil
    for _, door in ipairs(CollectionService:GetTagged("animdoor")) do
        if door:IsDescendantOf(workspace) then
            cachedDoor = door
            break
        end
    end
end

CollectionService:GetInstanceAddedSignal("spinnyrobux"):Connect(function(obj)
    if obj:IsA("BasePart") and obj:IsDescendantOf(workspace) then
        table.insert(cachedCoins, obj)
    end
end)
CollectionService:GetInstanceRemovedSignal("spinnyrobux"):Connect(function(obj)
    for i = #cachedCoins, 1, -1 do
        if cachedCoins[i] == obj then
            table.remove(cachedCoins, i)
        end
    end
end)
CollectionService:GetInstanceAddedSignal("animdoor"):Connect(function()
    refreshDoor()
end)
CollectionService:GetInstanceRemovedSignal("animdoor"):Connect(function()
    refreshDoor()
end)
refreshCoins()
refreshDoor()

local function farmLoop()
    while enabled do
        local hrp = getHRP()
        if not hrp then
            task.wait(0.2)
            continue
        end

        for i = 1, #cachedCoins do
            if not enabled then break end
            local coin = cachedCoins[i]
            if coin and coin.Parent and coin:IsDescendantOf(workspace) then
                teleportTo(coin.Position)
                task.wait(teleportDelay)
            end
        end

        if enabled and cachedDoor then
            local doorPos
            if cachedDoor:IsA("Model") then
                doorPos = cachedDoor:GetPivot().Position
            elseif cachedDoor:IsA("BasePart") then
                doorPos = cachedDoor.Position
            end
            if doorPos then
                teleportTo(doorPos)
                task.wait(teleportDelay * 2)
            end
        end

        task.wait(teleportDelay)
    end
end

LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.3)
    if enabled then
        applyHover(char)
    end
end)

ToggleButton.MouseButton1Click:Connect(function()
    if didDrag then return end
    enabled = not enabled
    if enabled then
        ToggleButton.Text = "ON"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        MainStroke.Color = Color3.fromRGB(50, 200, 50)
        startHover()
        task.spawn(farmLoop)
    else
        ToggleButton.Text = "OFF"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        MainStroke.Color = Color3.fromRGB(80, 80, 80)
        stopHover()
    end
end)
