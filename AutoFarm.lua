local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AutoFarmGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = game:GetService("CoreGui")

local ToggleFrame = Instance.new("Frame")
ToggleFrame.Name = "ToggleFrame"
ToggleFrame.Size = UDim2.new(0, 150, 0, 40)
ToggleFrame.Position = UDim2.new(0, 20, 0.5, -20)
ToggleFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ToggleFrame.BorderSizePixel = 0
ToggleFrame.Active = true
ToggleFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = ToggleFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(80, 80, 80)
UIStroke.Thickness = 1.5
UIStroke.Parent = ToggleFrame

local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleButton"
ToggleButton.Size = UDim2.new(1, -10, 1, -10)
ToggleButton.Position = UDim2.new(0, 5, 0, 5)
ToggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Text = "Auto Farm: OFF"
ToggleButton.TextSize = 14
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.BorderSizePixel = 0
ToggleButton.Parent = ToggleFrame

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0, 6)
ButtonCorner.Parent = ToggleButton

local dragging = false
local dragInput, dragStart, startPos
local DRAG_THRESHOLD = 5
local didDrag = false

local function onInputBegan(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        didDrag = false
        dragStart = input.Position
        startPos = ToggleFrame.Position
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

ToggleFrame.InputBegan:Connect(onInputBegan)
ToggleFrame.InputChanged:Connect(onInputChanged)
ToggleButton.InputBegan:Connect(onInputBegan)
ToggleButton.InputChanged:Connect(onInputChanged)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        if delta.Magnitude >= DRAG_THRESHOLD then
            didDrag = true
        end
        if didDrag then
            ToggleFrame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end
end)

local enabled = false

local function getCharacter()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function getHRP()
    local char = getCharacter()
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function getCollisionPart()
    local char = getCharacter()
    return char and (char:FindFirstChild("CollisionPart") or char:FindFirstChild("HumanoidRootPart"))
end

local function teleportTo(position)
    local hrp = getHRP()
    if hrp then
        hrp.CFrame = CFrame.new(position)
    end
end

local function getCoins()
    local coins = {}
    for _, obj in ipairs(CollectionService:GetTagged("spinnyrobux")) do
        if obj:IsDescendantOf(workspace) then
            table.insert(coins, obj)
        end
    end
    return coins
end

local function getDoor()
    local doors = CollectionService:GetTagged("animdoor")
    for _, door in ipairs(doors) do
        if door:IsDescendantOf(workspace) then
            return door
        end
    end
    return nil
end

local function getShopNPC()
    local npc = workspace:FindFirstChild("the guy who shops")
    return npc
end

local function farmLoop()
    while enabled do
        local hrp = getHRP()
        if not hrp then
            task.wait(1)
            continue
        end

        local coins = getCoins()
        if #coins > 0 then
            for _, coin in ipairs(coins) do
                if not enabled then break end
                if not coin:IsDescendantOf(workspace) then continue end
                local pos = coin.Position or coin:GetPivot().Position
                teleportTo(pos + Vector3.new(0, 2, 0))
                task.wait(0.15)
            end
            task.wait(0.3)
        end

        if enabled then
            local door = getDoor()
            if door then
                local doorPos
                if door:IsA("Model") then
                    doorPos = door:GetPivot().Position
                elseif door:IsA("BasePart") then
                    doorPos = door.Position
                end
                if doorPos then
                    teleportTo(doorPos + Vector3.new(0, 3, 0))
                    task.wait(0.5)
                end
            end
        end

        task.wait(1)
    end
end

ToggleButton.MouseButton1Click:Connect(function()
    if didDrag then return end
    enabled = not enabled
    if enabled then
        ToggleButton.Text = "Auto Farm: ON"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        UIStroke.Color = Color3.fromRGB(50, 200, 50)
        task.spawn(farmLoop)
    else
        ToggleButton.Text = "Auto Farm: OFF"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        UIStroke.Color = Color3.fromRGB(80, 80, 80)
    end
end)

