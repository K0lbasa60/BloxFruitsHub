local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local ESPModule = {}
local activeHighlights = {}

local function clearHighlights()
    for _, hl in pairs(activeHighlights) do
        if hl and hl.Parent then hl:Destroy() end
    end
    activeHighlights = {}
end

-- ESP Подсветка сундуков
function ESPModule.UpdateChestESP(enabled)
    clearHighlights()
    if not enabled then return end

    task.spawn(function()
        local items = Workspace:GetChildren()
        for i, obj in ipairs(items) do
            if obj.Name:find("Chest") or obj.Name:find("chest") then
                local hl = Instance.new("Highlight")
                hl.FillColor = Color3.fromRGB(255, 215, 0)
                hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                hl.Parent = obj
                table.insert(activeHighlights, hl)
            end
            if i % 50 == 0 then task.wait() end
        end
    end)
end

-- Фикс сбора фрукта: удерживает позицию и имитирует касание
function ESPModule.SearchAndCollectFruit()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return false end

    for _, obj in pairs(Workspace:GetChildren()) do
        if (obj:IsA("Tool") or obj.Name:find("Fruit")) and not obj:FindFirstChild("Humanoid") then
            local handle = obj:FindFirstChild("Handle") or obj:FindFirstChildOfClass("BasePart") or obj.PrimaryPart
            if handle then
                local startTime = tick()
                -- Удерживаем персонажа на фрукте до 2.5 секунд или пока фрукт не пропадет с земли
                repeat
                    if char and char:FindFirstChild("HumanoidRootPart") and handle and handle.Parent then
                        char.HumanoidRootPart.CFrame = handle.CFrame
                        char.HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
                        
                        -- Вызов функции касания (если поддерживается инжектором)
                        if firetouchinterest then
                            firetouchinterest(char.HumanoidRootPart, handle, 0)
                            task.wait(0.05)
                            firetouchinterest(char.HumanoidRootPart, handle, 1)
                        end
                    end
                    task.wait(0.05)
                until not handle.Parent or (tick() - startTime) > 2.5

                print("[BloxFruitsHub]: Успешно забран фрукт: " .. obj.Name)
                return true
            end
        end
    end
    return false
end

-- Новая функция: Авто-сбор сундуков по всей карте
function ESPModule.StartChestCollectLoop()
    task.spawn(function()
        while task.wait(0.2) do
            if getgenv().Config.AutoCollectChests then
                pcall(function()
                    local char = LocalPlayer.Character
                    if not char or not char:FindFirstChild("HumanoidRootPart") then return end

                    for _, obj in pairs(Workspace:GetChildren()) do
                        if not getgenv().Config.AutoCollectChests then break end
                        
                        if obj.Name:find("Chest") or obj.Name:find("chest") then
                            local part = obj:IsA("BasePart") and obj or obj:FindFirstChildOfClass("BasePart") or obj.PrimaryPart
                            
                            if part and part.Parent then
                                local start = tick()
                                -- Телепорт к сундуку и ожидание получения награды (до 1 секунды)
                                repeat
                                    if char and char:FindFirstChild("HumanoidRootPart") and part and part.Parent then
                                        char.HumanoidRootPart.CFrame = part.CFrame
                                        char.HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
                                        
                                        if firetouchinterest then
                                            firetouchinterest(char.HumanoidRootPart, part, 0)
                                            task.wait(0.05)
                                            firetouchinterest(char.HumanoidRootPart, part, 1)
                                        end
                                    end
                                    task.wait(0.05)
                                until not part.Parent or (tick() - start) > 1
                            end
                        end
                    end
                end)
            end
        end
    end)
end

print("[BloxFruitsHub]: ESP & Chest Collector загружен!")
return ESPModule