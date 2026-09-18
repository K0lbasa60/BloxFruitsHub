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

-- Поиск ТОЛЬКО моделей и деталей сундуков (без подсветки всей карты)
local function getChests()
    local chests = {}
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local name = obj.Name:lower()
            if (name:find("chest") or name == "chest1" or name == "chest2" or name == "chest3") and obj.Size.Magnitude < 15 then
                table.insert(chests, obj)
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
        local chests = getChests()
        for _, part in ipairs(chests) do
            if part and part.Parent then
                local hl = Instance.new("Highlight")
                hl.FillColor = Color3.fromRGB(255, 215, 0)
                hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                hl.FillTransparency = 0.4
                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                hl.Adornee = part
                hl.Parent = part
                table.insert(activeHighlights, hl)
            end
        end
    end)
end

-- Сбор фрукта с фиксом античита
function ESPModule.SearchAndCollectFruit()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return false end

    for _, obj in pairs(Workspace:GetDescendants()) do
        if (obj:IsA("Tool") or obj.Name:lower():find("fruit")) and not obj:FindFirstChild("Humanoid") then
            local handle = obj:FindFirstChild("Handle") or obj:FindFirstChildOfClass("BasePart") or (obj:IsA("BasePart") and obj)
            if handle then
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

-- Авто-сбор сундуков
function ESPModule.StartChestCollectLoop()
    task.spawn(function()
        while task.wait(0.5) do
            if getgenv().Config and getgenv().Config.AutoCollectChests then
                pcall(function()
                    local char = LocalPlayer.Character
                    if not char or not char:FindFirstChild("HumanoidRootPart") then return end

                    local chests = getChests()
                    for _, part in ipairs(chests) do
                        if not getgenv().Config.AutoCollectChests then break end
                        
                        if part and part.Parent then
                            local startTime = tick()
                            repeat
                                if char and char:FindFirstChild("HumanoidRootPart") and part and part.Parent then
                                    char.HumanoidRootPart.CFrame = part.CFrame + Vector3.new(0, 2, 0)
                                    char.HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
                                    
                                    if firetouchinterest then
                                        firetouchinterest(char.HumanoidRootPart, part, 0)
                                        task.wait(0.05)
                                        firetouchinterest(char.HumanoidRootPart, part, 1)
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