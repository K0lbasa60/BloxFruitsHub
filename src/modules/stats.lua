local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StatsModule = {}

function StatsModule.StartLoop()
    task.spawn(function()
        while task.wait(0.5) do
            if getgenv().Config.AutoStats then
                pcall(function()
                    local statMap = {
                        ["Melee"] = "Melee",
                        ["Defense"] = "Defense",
                        ["Sword"] = "Sword",
                        ["Gun"] = "Gun",
                        ["Fruit"] = "Demon Fruit"
                    }
                    local targetStat = statMap[getgenv().Config.SelectedStat] or "Melee"
                    local comm = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")
                    if comm then
                        comm:InvokeServer("AddPoint", targetStat, 1)
                    end
                end)
            end
        end
    end)
end

print("[BloxFruitsHub]: Stats Модуль загружен!")
return StatsModule