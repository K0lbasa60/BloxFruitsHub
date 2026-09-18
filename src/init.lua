local BASE_URL = "https://raw.githubusercontent.com/K0lbasa60/BloxFruitsHub/main/src/"

-- Загрузка конфига
loadstring(game:HttpGet(BASE_URL .. "config.lua"))()

-- Загрузка модулей
local ESPModule = loadstring(game:HttpGet(BASE_URL .. "modules/esp.lua"))()
local AutoFarmModule = loadstring(game:HttpGet(BASE_URL .. "modules/autofarm.lua"))()
local StatsModule = loadstring(game:HttpGet(BASE_URL .. "modules/stats.lua"))()
local UIModule = loadstring(game:HttpGet(BASE_URL .. "ui.lua"))()

-- Запуск интерфейса и фоновых циклов
UIModule.Create(ESPModule)
AutoFarmModule.StartLoop()
StatsModule.StartLoop()
ESPModule.StartChestCollectLoop()

print("[BloxFruitsHub]: Система v2.2 готова!")