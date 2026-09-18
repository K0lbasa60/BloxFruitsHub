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

-- Фильтрация: поиск ТОЛЬКО не открытых настоящих сундуков
local function getActiveChests()
    local chests = {}
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name:lower():find("chest") then
            -- Сундук должен быть видимым (не открытым) и иметь TouchInterest
            if obj.Transparency < 0.9 then
                local touch = obj:FindFirstChildOfClass("TouchTransmitter") or obj:FindFirstChild("TouchInterest")
                if touch then
                    table.insert(chests, obj)
                end
            end
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
        for _, part in ipairs(chests) do
            if part and part.Parent and part.Transparency < 0.9 then
                local hl = Instance.new("Highlight")
                hl.Name = "Chest_ESP"
                hl.FillColor = Color3.fromRGB(255, 215, 0)
                hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                hl.FillTransparency = 0.4
                hl.OutlineTransparency = 0
                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                hl.Adornee = part
                hl.Parent = part
                table.insert(activeHighlights, hl)
            end
        end
    end)
end

-- Сбор фрукта с возвратом на исходную позицию (фикс океана)
function ESPModule.SearchAndCollectFruit()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return false end

    local hrp = char.HumanoidRootPart
    local originalCFrame = hrp.CFrame -- Запоминаем где стояли

    for _, obj in pairs(Workspace:GetDescendants()) do
        if (obj:IsA("Tool") or obj.Name:lower():find("fruit")) and not obj:FindFirstChild("Humanoid") then
            local handle = obj:FindFirstChild("Handle") or obj:FindFirstChildOfClass("BasePart") or (obj:IsA("BasePart") and obj)
            if handle and handle.Parent then
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
                until not handle.Parent or (tick() - startTime) > 2.5

                -- Возвращаемся обратно на сушу
                hrp.CFrame = originalCFrame
                print("[BloxFruitsHub]: Фрукт забран, возврат в исходную точку.")
                return true
            end
        end
    end
    return false
end

-- Цикл авто-сбора сундуков с начислением Beli и возвратом на сушу
function ESPModule.StartChestCollectLoop()
    task.spawn(function()
        while task.wait(0.5) do
            if getgenv().Config and getgenv().Config.AutoCollectChests then
                pcall(function()
                    local char = LocalPlayer.Character
                    if not char or not char:FindFirstChild("HumanoidRootPart") then return end

                    local hrp = char.HumanoidRootPart
                    local startCFrame = hrp.CFrame -- Запоминаем безопасную позицию

                    local chests = getActiveChests()
                    for _, part in ipairs(chests) do
                        if not getgenv().Config or not getgenv().Config.AutoCollectChests then break end
                        
                        if part and part.Parent and part.Transparency < 0.9 then
                            local startTime = tick()
                            repeat
                                if not getgenv().Config.AutoCollectChests then break end
                                if hrp and part and part.Parent then
                                    hrp.CFrame = part.CFrame
                                    hrp.AssemblyLinearVelocity = Vector3.zero
                                    
                                    if firetouchinterest then
                                        firetouchinterest(hrp, part, 0)
                                        task.wait(0.05)
                                        firetouchinterest(hrp, part, 1)
                                    end
                                end
                                task.wait(0.05)
                            -- Ждём 0.35 секунды у сундука, чтобы сервер успел начислить деньги
                            until not part.Parent or part.Transparency >= 0.9 or (tick() - startTime) > 0.35
                        end
                    end

                    -- Возвращаем игрока обратно на остров
                    if hrp and startCFrame then
                        hrp.CFrame = startCFrame
                    end
                end)
            end
        end
    end)
end

print("[BloxFruitsHub]: ESP & Chest Collector загружен!")
return ESPModule