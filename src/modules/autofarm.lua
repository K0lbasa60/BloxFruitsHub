local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer

local AutoFarmModule = {}

-- Авто-экипировка и гарантированная активация атаки
local function equipAndAttack()
    local char = LocalPlayer.Character
    if not char then return end
    
    local tool = char:FindFirstChildOfClass("Tool")
    if not tool then
        local backpack = LocalPlayer:FindFirstChild("Backpack")
        if backpack then
            tool = backpack:FindFirstChildOfClass("Tool")
            if tool and char:FindFirstChild("Humanoid") then
                char.Humanoid:EquipTool(tool)
            end
        end
    end

    if tool then
        tool:Activate()
    end
    
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
end

-- Поиск ближайшего моба
local function getClosestEnemy()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
    
    local myPos = char.HumanoidRootPart.Position
    local closestEnemy = nil
    local shortestDist = math.huge

    local folder = Workspace:FindFirstChild("Enemies") or Workspace
    
    for _, enemy in pairs(folder:GetChildren()) do
        local hum = enemy:FindFirstChildOfClass("Humanoid")
        local hrp = enemy:FindFirstChild("HumanoidRootPart") or enemy.PrimaryPart
        
        if hum and hrp and hum.Health > 0 and enemy.Name ~= LocalPlayer.Name then
            local dist = (hrp.Position - myPos).Magnitude
            if dist < shortestDist then
                shortestDist = dist
                closestEnemy = enemy
            end
        end
    end
    
    return closestEnemy
end

function AutoFarmModule.StartLoop()
    task.spawn(function()
        while task.wait() do
            if getgenv().Config and getgenv().Config.AutoFarm then
                pcall(function()
                    local char = LocalPlayer.Character
                    if not char or not char:FindFirstChild("HumanoidRootPart") then return end

                    local target = getClosestEnemy()
                    if target and target:FindFirstChild("HumanoidRootPart") and target:FindFirstChildOfClass("Humanoid") then
                        local hum = target:FindFirstChildOfClass("Humanoid")
                        local hrp = target.HumanoidRootPart

                        -- Зависаем ровно над мобом без наклонов персонажа
                        while getgenv().Config.AutoFarm and hum and hum.Health > 0 and hrp and hrp.Parent do
                            local farmDist = getgenv().Config.FarmDistance or 6
                            char.HumanoidRootPart.CFrame = CFrame.new(hrp.Position + Vector3.new(0, farmDist, 0), hrp.Position)
                            char.HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
                            
                            equipAndAttack()
                            task.wait(0.05)
                        end
                    end
                end)
            end
        end
    end)
end

print("[BloxFruitsHub]: AutoFarm Модуль обновлен!")
return AutoFarmModule