-- ==========================================
-- MODULES/AUTOFARM.LUA (Универсальный автофарм)
-- ==========================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer
local AutoFarmModule = {}

-- Поиск ближайшего живого моба
local function getNearestEnemy()
    local nearest = nil
    local shortestDistance = math.huge
    local enemies = Workspace:FindFirstChild("Enemies")

    if enemies then
        for _, enemy in pairs(enemies:GetChildren()) do
            local hrp = enemy:FindFirstChild("HumanoidRootPart")
            local humanoid = enemy:FindFirstChild("Humanoid")
            
            if hrp and humanoid and humanoid.Health > 0 then
                local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if myHrp then
                    local dist = (myHrp.Position - hrp.Position).Magnitude
                    if dist < shortestDistance then
                        shortestDistance = dist
                        nearest = enemy
                    end
                end
            end
        end
    end
    return nearest
end

-- Главный цикл фарминга
function AutoFarmModule.StartLoop()
    task.spawn(function()
        while task.wait(0.05) do
            if getgenv().Config.AutoFarm then
                pcall(function()
                    local char = LocalPlayer.Character
                    if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
                        local target = getNearestEnemy()
                        if target and target:FindFirstChild("HumanoidRootPart") and target.Humanoid.Health > 0 then
                            
                            -- Фиксация позиции над головой моба
                            local distanceOffset = getgenv().Config.TargetHoverDistance or 6
                            local targetPos = target.HumanoidRootPart.CFrame * CFrame.new(0, distanceOffset, 0)
                            char.HumanoidRootPart.CFrame = targetPos
                            
                            -- Отключение коллизий
                            for _, part in pairs(char:GetChildren()) do
                                if part:IsA("BasePart") then
                                    part.CanCollide = false
                                end
                            end
                            
                            -- Симуляция удара
                            VirtualUser:CaptureController()
                            VirtualUser:ClickButton1(Vector2.new(850, 520))
                        end
                    end
                end)
            end
        end
    end)
end

print("[BloxFruitsHub]: AutoFarm Модуль загружен!")
return AutoFarmModule