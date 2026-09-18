local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer

local AutoFarmModule = {}

-- Достать оружие из инвентаря
local function equipWeapon()
    local char = LocalPlayer.Character
    if not char then return end
    
    if not char:FindFirstChildOfClass("Tool") then
        local backpack = LocalPlayer:FindFirstChild("Backpack")
        if backpack then
            local tool = backpack:FindFirstChildOfClass("Tool")
            if tool and char:FindFirstChild("Humanoid") then
                char.Humanoid:EquipTool(tool)
            end
        end
    end
end

-- Имитация удара / клика
local function attack()
    VirtualUser:CaptureController()
    VirtualUser:Button1Down(Vector2.new(50, 50))
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

-- Отключение коллизии (чтобы не застревать)
local function enableNoclip()
    local char = LocalPlayer.Character
    if char then
        for _, part in pairs(char:GetChildren()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
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

                        enableNoclip()
                        equipWeapon()

                        -- Дёржимся над мобом и бьём, пока он жив
                        while getgenv().Config.AutoFarm and hum and hum.Health > 0 and hrp and hrp.Parent do
                            char.HumanoidRootPart.CFrame = hrp.CFrame * CFrame.new(0, getgenv().Config.FarmDistance or 7, 0) * CFrame.Angles(math.rad(-90), 0, 0)
                            char.HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
                            
                            equipWeapon()
                            attack()
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