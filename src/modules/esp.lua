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

-- Глубокий поиск сундуков по всей карте
local function getChests()
    local chests = {}
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name:lower():find("chest") then
            table.insert(chests, obj)
        elseif obj:IsA("Model") and obj.Name:lower():find("chest") then
            local part = obj:FindFirstChildOfClass("BasePart") or obj.PrimaryPart
            if part then
                table.insert(chests, part)
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
                local target = part.Parent:IsA("Model") and part.Parent or part
                if not target:FindFirstChildOfClass("Highlight") then
                    local hl = Instance.new("Highlight")
                    hl.FillColor = Color3.fromRGB(255, 215, 0)
                    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                    hl.Parent = target
                    table.insert(activeHighlights, hl)
                end
            end
        end
    end)
end

-- Сбор фрукта с удержанием позиции
function ESPModule.SearchAndCollectFruit()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return false end

    for _, obj in pairs(Workspace:GetDescendants()) do
        if (obj:IsA("Tool") or obj.Name:lower():find("fruit")) and not obj:FindFirstChild("Humanoid") then
            local handle = obj:FindFirstChild("Handle") or obj:FindFirstChildOfClass("BasePart") or obj.PrimaryPart
            if handle then
                local startTime = tick()
                repeat
                    if char and char:FindFirstChild("HumanoidRootPart") and handle and handle.Parent then
                        char.HumanoidRootPart.CFrame = handle.CFrame
                        char.HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
                        
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

-- Авто-сбор сундуков по всей карте
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
                                    char.HumanoidRootPart.CFrame = part.CFrame * CFrame.new(0, 1, 0)
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