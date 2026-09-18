local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer

local AutoFarmModule = {}

function AutoFarmModule.StartLoop()
    task.spawn(function()
        while task.wait(0.03) do
            if getgenv().Config.AutoFarm then
                pcall(function()
                    local char = LocalPlayer.Character
                    if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
                        
                        -- Фиксация скорости (чтобы персонаж не падал и не получал урон)
                        char.HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
                        
                        local enemies = Workspace:FindFirstChild("Enemies")
                        if enemies then
                            for _, enemy in pairs(enemies:GetChildren()) do
                                local hrp = enemy:FindFirstChild("HumanoidRootPart")
                                local hum = enemy:FindFirstChild("Humanoid")
                                
                                if hrp and hum and hum.Health > 0 then
                                    local dist = getgenv().Config.FarmDistance or 9
                                    -- Безопасная точка над мобом с углом атаки вниз
                                    char.HumanoidRootPart.CFrame = hrp.CFrame * CFrame.new(0, dist, 0) * CFrame.Angles(math.rad(-90), 0, 0)
                                    
                                    -- Отключение коллизий
                                    for _, part in pairs(char:GetChildren()) do
                                        if part:IsA("BasePart") then part.CanCollide = false end
                                    end
                                    
                                    -- Удар
                                    VirtualUser:CaptureController()
                                    VirtualUser:ClickButton1(Vector2.new(850, 520))
                                    break
                                end
                            end
                        end
                    end
                end)
            end
        end
    end)
end

print("[BloxFruitsHub]: AutoFarm Модуль обновлен!")
return AutoFarmModule