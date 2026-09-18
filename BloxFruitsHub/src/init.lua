-- ==========================================
-- INIT.LUA (Главный стартовый файл)
-- ==========================================

local BASE_URL = "https://raw.githubusercontent.com/ТВОЙ_НИК/ТВОЙ_РЕПОЗИТОРИЙ/main/src/"

-- Загрузка конфига
loadstring(game:HttpGet(BASE_URL .. "config.lua"))()

-- Загрузка модулей
local ESPModule = loadstring(game:HttpGet(BASE_URL .. "modules/esp.lua"))()
local AutoFarmModule = loadstring(game:HttpGet(BASE_URL .. "modules/autofarm.lua"))()
local UIModule = loadstring(game:HttpGet(BASE_URL .. "ui.lua"))()

-- Запуск интерфейса и автофарма
UIModule.Create(ESPModule)
AutoFarmModule.StartLoop()

print("[BloxFruitsHub]: Проект успешно инициализирован!")