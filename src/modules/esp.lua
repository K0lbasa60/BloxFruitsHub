-- ==========================================
-- MODULES/ESP.LUA (Функции поиска и подсветки)
-- ==========================================

local Workspace = game:GetService("Workspace")
local ESPModule = {}

-- Переменные хранилища подсветок
local activeChestHighlights = {}
local activeFruitHighlights = {}

-- 1. Подсветка сундуков
function ESPModule.UpdateChestESP(enabled)
    if enabled then
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj.Name:find("Chest") and obj:IsA("BasePart") then
                if not obj:FindFirstChild("ChestHighlight") then
                    local hl = Instance.new("Highlight")
                    hl.Name = "ChestHighlight"
                    hl.FillColor = Color3.fromRGB(255, 215, 0)
                    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                    hl.Parent = obj
                    table.insert(activeChestHighlights, hl)
                end
            end
        end
    else
        for _, hl in pairs(activeChestHighlights) do
            if hl and hl.Parent then
                hl:Destroy()
            end
        end
        activeChestHighlights = {}
    end
end

-- 2. Подсветка фруктов
function ESPModule.UpdateFruitESP(enabled)
    if enabled then
        for _, obj in pairs(Workspace:GetChildren()) do
            if obj:IsA("Tool") or obj.Name:find("Fruit") then
                if not obj:FindFirstChild("FruitHighlight") then
                    local hl = Instance.new("Highlight")
                    hl.Name = "FruitHighlight"
                    hl.FillColor = Color3.fromRGB(255, 50, 50)
                    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                    hl.Parent = obj
                    table.insert(activeFruitHighlights, hl)
                end
            end
        end
    else
        for _, hl in pairs(activeFruitHighlights) do
            if hl and hl.Parent then
                hl:Destroy()
            end
        end
        activeFruitHighlights = {}
    end
end

print("[BloxFruitsHub]: ESP Модуль загружен!")
return ESPModule