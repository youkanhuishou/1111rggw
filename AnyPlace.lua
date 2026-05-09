local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

LocalPlayer:SetAttribute("buildrange2x", true)

local function safeRequire(inst)
    if not inst then return nil end
    local ok, mod = pcall(require, inst)
    if ok then return mod end
    return nil
end

local BuildUtils = safeRequire(ReplicatedStorage:FindFirstChild("SharedModules") and ReplicatedStorage.SharedModules:FindFirstChild("BuildUtils"))
if BuildUtils then
    BuildUtils.GetBuildRange = function()
        return 99999, 99999, true
    end
end

local buildlist = safeRequire(ReplicatedStorage:FindFirstChild("buildlist"))
if buildlist and buildlist.builds then
    for _, data in pairs(buildlist.builds) do
        data.norange = true
    end
end

local BridgeNet2 = ReplicatedStorage:FindFirstChild("BridgeNet2")
local ClientProcess = BridgeNet2 and safeRequire(BridgeNet2:FindFirstChild("src") and BridgeNet2.src:FindFirstChild("Client") and BridgeNet2.src.Client:FindFirstChild("ClientProcess"))

local function projectMouseTo2DPlane(planeZ)
    planeZ = planeZ or 0
    local cam = workspace.CurrentCamera
    if not cam then return Vector3.new(0, 0, planeZ) end
    local unitRay = cam:ScreenPointToRay(Mouse.X, Mouse.Y, 0)
    local origin = unitRay.Origin
    local direction = unitRay.Direction
    if math.abs(direction.Z) < 1e-5 then
        return Vector3.new(origin.X, origin.Y, planeZ)
    end
    local t = (planeZ - origin.Z) / direction.Z
    return origin + direction * t
end

local OVERRIDE_GHOST = true
local FORCE_VALID_COLOR = true

RunService.PreRender:Connect(function()
    if not OVERRIDE_GHOST then return end
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj:GetAttribute("ghostype") ~= nil then
            local pos = projectMouseTo2DPlane(0)
            local target = pos + Vector3.new(0, 0, 0.1)
            local pivot = obj:GetPivot()
            local _, _, currentZRot = pivot:ToOrientation()
            local newCF = CFrame.new(target) * CFrame.Angles(0, 0, currentZRot)
            pcall(function()
                if obj:IsA("Model") then
                    obj:PivotTo(newCF)
                elseif obj:IsA("BasePart") then
                    obj.CFrame = newCF
                end
            end)
            if FORCE_VALID_COLOR then
                obj:SetAttribute("ghostype", 0)
                if obj:IsA("Model") then
                    for _, p in ipairs(obj:GetDescendants()) do
                        if p:IsA("BasePart") then
                            local origColor = p:GetAttribute("color")
                            if origColor then p.Color = origColor end
                            p.LocalTransparencyModifier = 0.35
                        end
                    end
                elseif obj:IsA("BasePart") then
                    local origColor = obj:GetAttribute("color")
                    if origColor then obj.Color = origColor end
                    obj.LocalTransparencyModifier = 0.35
                end
            end
        end
    end
end)

local function destroyShamanCircle()
    for _, obj in ipairs(workspace:GetChildren()) do
        if type(obj.Name) == "string" and obj.Name:lower():find("shamancircle") then
            pcall(function() obj:Destroy() end)
        end
    end
end
destroyShamanCircle()
workspace.ChildAdded:Connect(function(obj)
    task.wait()
    if type(obj.Name) == "string" and obj.Name:lower():find("shamancircle") then
        pcall(function() obj:Destroy() end)
    end
end)

if ClientProcess and ClientProcess.addToQueue then
    local origAdd = ClientProcess.addToQueue
    ClientProcess.addToQueue = function(id, data, ...)
        if type(data) == "table" and data.cframe and data.name then
            local x, y, z = data.cframe.X, data.cframe.Y, data.cframe.Z
            print(string.format("[BuildAnywhere] OUT name=%s skin=%s pos=(%.2f, %.2f, %.2f)",
                tostring(data.name), tostring(data.skin), x, y, z))
        end
        return origAdd(id, data, ...)
    end
    print("yes")
else
    warn("[BuildAnywhere] Could not hook ClientProcess.addToQueue")
end
