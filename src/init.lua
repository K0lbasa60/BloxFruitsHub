local BASE_URL = "https://raw.githubusercontent.com/K0lbasa60/BloxFruitsHub/main/src/"

-- Загрузка конфига
loadstring(game:HttpGet(BASE_URL .. "config.lua"))()

-- Загрузка модулей
local ESPModule = loadstring(game:HttpGet(BASE_URL .. "modules/esp.lua"))()
local AutoFarmModule = loadstring(game:HttpGet(BASE_URL .. "modules/autofarm.lua"))()
local StatsModule = loadstring(game:HttpGet(BASE_URL .. "modules/stats.lua"))()
local UIModule = loadstring(game:HttpGet(BASE_URL .. "ui.lua"))()

-- Запуск
UIModule.Create(ESPModule)
AutoFarmModule.StartLoop()
StatsModule.StartLoop()

print("[BloxFruitsHub]: Система v2.0 готова!")