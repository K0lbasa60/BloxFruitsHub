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

-- Оптимизированный поиск сундуков без фризов (асинхронный перебор)
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
            if i % 50 == 0 then task.wait() end -- Разгрузка потока каждые 50 объектов
        end
    end)
end

-- Поиск и подбор фруктов на карте (Fruit Search)
function ESPModule.SearchAndCollectFruit()
    for _, obj in pairs(Workspace:GetChildren()) do
        if obj:IsA("Tool") or obj.Name:find("Fruit") then
            local handle = obj:FindFirstChild("Handle") or obj:FindFirstChild("Base") or obj:FindFirstChildOfClass("TouchTransmitter")
            if handle and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = obj:GetPivot()
                print("[BloxFruitsHub]: Найден фрукт! Телепорт к " .. obj.Name)
                return true
            end
        end
    end
    return false
end

print("[BloxFruitsHub]: ESP & Fruit Search загружен!")
return ESPModule