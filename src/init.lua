local BASE_URL = "https://raw.githubusercontent.com/K0lbasa60/BloxFruitsHub/main/src/"

local function safeLoad(path)
    local url = BASE_URL .. path .. "?v=" .. tostring(tick()) -- обход кэша GitHub
    local success, content = pcall(function() return game:HttpGet(url) end)
    
    if not success or not content or content:find("404: Not Found") then
        warn("[BloxFruitsHub]: Ошибка 404! Проверь путь к файлу на GitHub: " .. path)
        return nil
    end

    local func, err = loadstring(content)
    if not func then
        warn("[BloxFruitsHub]: Ошибка синтаксиса в файле " .. path .. ": " .. tostring(err))
        return nil
    end

    return func()
end

-- Загрузка конфига
safeLoad("config.lua")

-- Загрузка модулей
local ESPModule = safeLoad("modules/esp.lua")
local AutoFarmModule = safeLoad("modules/autofarm.lua")
local StatsModule = safeLoad("modules/stats.lua")
local UIModule = safeLoad("ui.lua")

-- Запуск систем
if UIModule and ESPModule then
    UIModule.Create(ESPModule)
end

if AutoFarmModule then AutoFarmModule.StartLoop() end
if StatsModule then StatsModule.StartLoop() end
if ESPModule and ESPModule.StartChestCollectLoop then ESPModule.StartChestCollectLoop() end