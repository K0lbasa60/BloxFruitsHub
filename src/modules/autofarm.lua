local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer

local AutoFarmModule = {}

-- Автоматическое взятие оружия в руки
local function equipTool()
    local char = LocalPlayer.Character
    if not char then return end
    if not char:FindFirstChildOfClass("Tool") then
        local backpack = LocalPlayer:FindFirstChild("Backpack")
        if backpack then
            local tool = backpack:FindFirstChildOfClass("Tool")
            if tool then
                char.Humanoid:EquipTool(tool)
            end
        end
    end
end

function AutoFarmModule.StartLoop()
    task.spawn(function()
        while task.wait(0.05) do
            if getgenv().Config.AutoFarm then
                pcall(function()
                    local char = LocalPlayer.Character
                    if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
                        
                        -- Сброс падения
                        char.HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
                        equipTool()

                        local enemies = Workspace:FindFirstChild("Enemies")
                        if enemies then
                            for _, enemy in pairs(enemies:GetChildren()) do
                                local hrp = enemy:FindFirstChild("HumanoidRootPart")
                                local hum = enemy:FindFirstChild("Humanoid")
                                
                                if hrp and hum and hum.Health > 0 then
                                    local dist = getgenv().Config.FarmDistance or 8
                                    
                                    -- Безопасное зависание ПРЯМО НАД мобом (без поломки углов)
                                    char.HumanoidRootPart.CFrame = hrp.CFrame * CFrame.new(0, dist, 0)
                                    
                                    -- Отключение коллизий (NoClip)
                                    for _, part in pairs(char:GetChildren()) do
                                        if part:IsA("BasePart") then part.CanCollide = false end
                                    end
                                    
                                    -- Атака
                                    VirtualUser:CaptureController()
                                    VirtualUser:Button1Down(Vector2.zero)
                                    task.wait(0.01)
                                    VirtualUser:Button1Up(Vector2.zero)
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

print("[BloxFruitsHub]: AutoFarm Модуль исправлен!")
return AutoFarmModule
