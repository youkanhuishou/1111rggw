local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

LocalPlayer:SetAttribute("buildrange2x", true)

local function safeRequire(inst)
    if not inst then return nil end
    local ok, mod = pcall(require, inst)
    if ok then return mod end
    return nil
end

local SharedModules = ReplicatedStorage:FindFirstChild("SharedModules")
local BuildUtils = SharedModules and safeRequire(SharedModules:FindFirstChild("BuildUtils"))
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

local function killCircle(obj)
    if type(obj.Name) == "string" and obj.Name:lower():find("shamancircle") then
        pcall(function() obj:Destroy() end)
    end
end
for _, obj in ipairs(workspace:GetChildren()) do
    killCircle(obj)
end
workspace.ChildAdded:Connect(function(obj)
    task.wait()
    killCircle(obj)
end)

