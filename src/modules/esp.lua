local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local ESPModule = {}
local activeHighlights = {}

local function clearHighlights()
    for _, hl in pairs(activeHighlights) do
        if hl and hl.Parent then
            hl:Destroy()
        end
    end
    activeHighlights = {}
end

-- Валидация: проверка, является ли объект НАСТОЯЩИМ собираемым сундуком
local function isRealChest(obj)
    if not obj then return false, nil end
    
    local name = obj.Name:lower()
    if not name:find("chest") then return false, nil end

    -- Проверка детали на наличие TouchInterest
    if obj:IsA("BasePart") then
        local touch = obj:FindFirstChildOfClass("TouchTransmitter") or obj:FindFirstChild("TouchInterest")
        if touch and obj.Transparency < 1 then
            return true, obj
        end
    end

    -- Проверка модели (Chest1, Chest2, Chest3)
    if obj:IsA("Model") then
        for _, child in pairs(obj:GetChildren()) do
            if child:IsA("BasePart") then
                local touch = child:FindFirstChildOfClass("TouchTransmitter") or child:FindFirstChild("TouchInterest")
                if touch then
                    return true, child
                end
            end
        end
        local mainPart = obj.PrimaryPart or obj:FindFirstChildOfClass("BasePart")
        if mainPart and obj.Name:match("^Chest%d?$") then
            return true, mainPart
        end
    end

    return false, nil
end

-- Получение списка только активных сундуков
local function getActiveChests()
    local chests = {}
    for _, obj in pairs(Workspace:GetDescendants()) do
        local isValid, part = isRealChest(obj)
        if isValid and part and part.Parent then
            table.insert(chests, {model = obj, part = part})
        end
    end
    return chests
end

-- ESP Подсветка сундуков
function ESPModule.UpdateChestESP(enabled)
    clearHighlights()
    if not enabled then return end

    task.spawn(function()
        local chests = getActiveChests()
        for _, chestData in ipairs(chests) do
            local part = chestData.part
            if part and part.Parent then
                local hl = Instance.new("Highlight")
                hl.Name = "Chest_ESP_Highlight"
                hl.FillColor = Color3.fromRGB(255, 215, 0)
                hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                hl.FillTransparency = 0.3
                hl.OutlineTransparency = 0
                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                hl.Adornee = part
                hl.Parent = part
                table.insert(activeHighlights, hl)
            end
        end
    end)
end

-- Поиск и сбор фрукта
function ESPModule.SearchAndCollectFruit()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return false end

    for _, obj in pairs(Workspace:GetDescendants()) do
        if (obj:IsA("Tool") or obj.Name:lower():find("fruit")) and not obj:FindFirstChild("Humanoid") then
            local handle = obj:FindFirstChild("Handle") or obj:FindFirstChildOfClass("BasePart") or (obj:IsA("BasePart") and obj)
            if handle and handle.Parent then
                local hrp = char.HumanoidRootPart
                local startTime = tick()
                
                repeat
                    if char and hrp and handle and handle.Parent then
                        hrp.CFrame = handle.CFrame + Vector3.new(0, 1, 0)
                        hrp.AssemblyLinearVelocity = Vector3.zero
                        
                        if firetouchinterest then
                            firetouchinterest(hrp, handle, 0)
                            task.wait(0.05)
                            firetouchinterest(hrp, handle, 1)
                        end
                    end
                    task.wait(0.05)
                until not handle.Parent or (tick() - startTime) > 3

                print("[BloxFruitsHub]: Успешно забран фрукт: " .. obj.Name)
                return true
            end
        end
    end
    return false
end

-- Цикл авто-сбора сундуков
function ESPModule.StartChestCollectLoop()
    task.spawn(function()
        while task.wait(0.3) do
            if getgenv().Config and getgenv().Config.AutoCollectChests then
                pcall(function()
                    local char = LocalPlayer.Character
                    if not char or not char:FindFirstChild("HumanoidRootPart") then return end

                    local chests = getActiveChests()
                    for _, chestData in ipairs(chests) do
                        if not getgenv().Config or not getgenv().Config.AutoCollectChests then break end
                        
                        local part = chestData.part
                        if part and part.Parent then
                            local startTime = tick()
                            repeat
                                if not getgenv().Config.AutoCollectChests then break end
                                local hrp = char:FindFirstChild("HumanoidRootPart")
                                if hrp and part and part.Parent then
                                    hrp.CFrame = part.CFrame + Vector3.new(0, 1.5, 0)
                                    hrp.AssemblyLinearVelocity = Vector3.zero
                                    
                                    if firetouchinterest then
                                        firetouchinterest(hrp, part, 0)
                                        task.wait(0.05)
                                        firetouchinterest(hrp, part, 1)
                                    end
                                end
                                task.wait(0.05)
                            until not part.Parent or (tick() - startTime) > 1.2
                        end
                    end
                end)
            end
        end
    end)
end

print("[BloxFruitsHub]: ESP & Chest Collector загружен!")
return ESPModule