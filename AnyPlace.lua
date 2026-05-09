local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

LocalPlayer:SetAttribute("buildrange2x", true)

local function waitAndRequire(path)
    local node = ReplicatedStorage
    for _, name in ipairs(path) do
        node = node:WaitForChild(name, 10)
        if not node then return nil end
    end
    local ok, mod = pcall(require, node)
    if ok then return mod end
    return nil
end

local BuildUtils = waitAndRequire({"SharedModules", "BuildUtils"})
if BuildUtils then
    BuildUtils.GetBuildRange = function()
        return 99999, 99999, true
    end
end

local buildlist = waitAndRequire({"buildlist"})
if buildlist and buildlist.builds then
    for _, data in pairs(buildlist.builds) do
        data.norange = true
    end
end

local filterParams = RaycastParams.new()
filterParams.FilterType = Enum.RaycastFilterType.Exclude
filterParams.IgnoreWater = false

local function getIgnoreList()
    local list = {}
    if LocalPlayer.Character then
        table.insert(list, LocalPlayer.Character)
    end
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj:IsA("Model") or obj:IsA("BasePart") then
            if obj:GetAttribute("ghostype") ~= nil then
                table.insert(list, obj)
            end
        end
    end
    return list
end

local function getMouseWorldHit()
    filterParams.FilterDescendantsInstances = getIgnoreList()
    local cam = workspace.CurrentCamera
    if not cam then return nil end
    local unitRay = cam:ViewportPointToRay(Mouse.X, Mouse.Y)
    local result = workspace:Raycast(unitRay.Origin, unitRay.Direction * 10000, filterParams)
    if result then
        return result.Position, result.Normal
    end
    return unitRay.Origin + unitRay.Direction * 200, Vector3.new(0, 1, 0)
end

local function findGhosts()
    local ghosts = {}
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj:GetAttribute("ghostype") ~= nil then
            table.insert(ghosts, obj)
        end
    end
    return ghosts
end

local buildRotation = 0
UserInputService.InputChanged:Connect(function(input, processed)
    if processed then return end
    if input.UserInputType == Enum.UserInputType.MouseWheel then
        if UserInputService:IsKeyDown(Enum.KeyCode.R) or UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            buildRotation = buildRotation + input.Position.Z * 15
        end
    end
end)

RunService.RenderStepped:Connect(function()
    local ghosts = findGhosts()
    if #ghosts == 0 then return end
    local hitPos, hitNormal = getMouseWorldHit()
    if not hitPos then return end
    for _, ghost in ipairs(ghosts) do
        ghost:SetAttribute("ghostype", 0)
        if ghost:IsA("Model") then
            local pivot = ghost:GetPivot()
            local _, currentY, _ = pivot:ToOrientation()
            local newCF = CFrame.new(hitPos) * CFrame.Angles(0, math.rad(buildRotation), 0)
            pcall(function() ghost:PivotTo(newCF) end)
            for _, desc in ipairs(ghost:GetDescendants()) do
                if desc:IsA("BasePart") then
                    local origColor = desc:GetAttribute("color")
                    if origColor then
                        desc.Color = origColor
                    end
                    desc.LocalTransparencyModifier = 0.35
                end
            end
        elseif ghost:IsA("BasePart") then
            ghost.CFrame = CFrame.new(hitPos) * CFrame.Angles(0, math.rad(buildRotation), 0)
            local origColor = ghost:GetAttribute("color")
            if origColor then
                ghost.Color = origColor
            end
            ghost.LocalTransparencyModifier = 0.35
        end
    end
end)

for _, obj in ipairs(workspace:GetChildren()) do
    if obj.Name == "shamancircle" or obj.Name:lower():find("shamancircle") then
        obj:Destroy()
    end
end
workspace.ChildAdded:Connect(function(obj)
    if obj.Name == "shamancircle" or obj.Name:lower():find("shamancircle") then
        task.wait()
        pcall(function() obj:Destroy() end)
    end
end)

