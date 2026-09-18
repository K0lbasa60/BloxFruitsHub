local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local AutoFarmModule = {}
local noclipConnection = nil

-- Управление NoClip
local function setNoclip(enabled)
    if enabled then
        if not noclipConnection then
            noclipConnection = RunService.Stepped:Connect(function()
                local char = LocalPlayer.Character
                if char then
                    for _, part in pairs(char:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end)
        end
    else
        if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
        end
    end
end

-- Экипировка оружия и проведение атаки
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
    
    VirtualUser:CaptureController()
    VirtualUser:ClickButton1(Vector2.new(500, 500))
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
        while task.wait(0.1) do
            local isFarming = getgenv().Config and getgenv().Config.AutoFarm
            setNoclip(isFarming)

            if isFarming then
                pcall(function()
                    local char = LocalPlayer.Character
                    if not char or not char:FindFirstChild("HumanoidRootPart") or not char:FindFirstChild("Humanoid") then return end

                    local target = getClosestEnemy()
                    if target and target:FindFirstChild("HumanoidRootPart") and target:FindFirstChildOfClass("Humanoid") then
                        local hum = target:FindFirstChildOfClass("Humanoid")
                        local hrp = target.HumanoidRootPart
                        local myHRP = char.HumanoidRootPart

                        -- Отключаем авто-поворот для устранения тряски
                        char.Humanoid.AutoRotate = false

                        while getgenv().Config and getgenv().Config.AutoFarm and hum and hum.Health > 0 and hrp and hrp.Parent do
                            local farmDist = getgenv().Config.FarmDistance or 5
                            
                            -- Стабильное позиционирование над мобом
                            myHRP.CFrame = CFrame.new(hrp.Position + Vector3.new(0, farmDist, 0), hrp.Position)
                            myHRP.AssemblyLinearVelocity = Vector3.zero
                            myHRP.AssemblyAngularVelocity = Vector3.zero

                            equipAndAttack()
                            task.wait(0.05)
                        end

                        -- Восстанавливаем поворот
                        if char and char:FindFirstChild("Humanoid") then
                            char.Humanoid.AutoRotate = true
                        end
                    end
                end)
            else
                -- Если фарм выключен, гарантируем включение AutoRotate
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("Humanoid") then
                    char.Humanoid.AutoRotate = true
                end
            end
        end
    end)
end

print("[BloxFruitsHub]: AutoFarm Модуль загружен!")
return AutoFarmModule