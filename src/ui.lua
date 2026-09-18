local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local UIModule = {}

function UIModule.Create(espModule)
    if PlayerGui:FindFirstChild("BloxFruitsHubGUI") then
        PlayerGui.BloxFruitsHubGUI:Destroy()
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "BloxFruitsHubGUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = PlayerGui

    -- Окно программы
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 440, 0, 280)
    MainFrame.Position = UDim2.new(0.5, -220, 0.4, -140)
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Parent = ScreenGui

    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

    -- Шапка (Header)
    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, 0, 0, 35)
    Header.BackgroundColor3 = Color3.fromRGB(28, 28, 40)
    Header.BorderSizePixel = 0
    Header.Parent = MainFrame
    Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 8)

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -10, 1, 0)
    Title.Position = UDim2.new(0, 10, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "Blox Fruits Hub v2.0 | [Right Shift - Скрыть]"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 13
    Title.Font = Enum.Font.SourceSansBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Header

    -- Драг-энд-дроп
    local dragging, dragInput, dragStart, startPos
    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; dragStart = input.Position; startPos = MainFrame.Position
        end
    end)
    Header.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- Toggle Right Shift
    UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == Enum.KeyCode.RightShift then
            MainFrame.Visible = not MainFrame.Visible
        end
    end)

    -- Боковая панель (Sidebar)
    local Sidebar = Instance.new("Frame")
    Sidebar.Size = UDim2.new(0, 110, 1, -45)
    Sidebar.Position = UDim2.new(0, 5, 0, 40)
    Sidebar.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = MainFrame
    Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 6)

    local SidebarList = Instance.new("UIListLayout", Sidebar)
    SidebarList.Padding = UDim.new(0, 5)

    -- Контейнер страниц
    local PageContainer = Instance.new("Frame")
    PageContainer.Size = UDim2.new(1, -130, 1, -45)
    PageContainer.Position = UDim2.new(0, 122, 0, 40)
    PageContainer.BackgroundTransparency = 1
    PageContainer.Parent = MainFrame

    local pages = {}

    local function createPage(name)
        local page = Instance.new("Frame")
        page.Size = UDim2.new(1, 0, 1, 0)
        page.BackgroundTransparency = 1
        page.Visible = false
        page.Parent = PageContainer
        
        local layout = Instance.new("UIListLayout", page)
        layout.Padding = UDim.new(0, 6)
        
        pages[name] = page
        return page
    end

    local farmPage = createPage("Farm")
    local statsPage = createPage("Stats")
    local espPage = createPage("ESP")

    local function showPage(name)
        for pName, page in pairs(pages) do
            page.Visible = (pName == name)
        end
    end

    local function createTabBtn(text, pageName)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 32)
        btn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
        btn.BorderSizePixel = 0
        btn.Text = text
        btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        btn.Font = Enum.Font.SourceSansSemibold
        btn.Parent = Sidebar
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

        btn.MouseButton1Click:Connect(function()
            showPage(pageName)
        end)
    end

    createTabBtn("Фарм", "Farm")
    createTabBtn("Статы", "Stats")
    createTabBtn("ESP / Фрукты", "ESP")

    -- Вспомогательная функция для переключателей
    local function createToggle(parent, text, configKey, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 32)
        btn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
        btn.BorderSizePixel = 0
        btn.Text = text .. ": OFF"
        btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        btn.Font = Enum.Font.SourceSansSemibold
        btn.Parent = parent
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

        btn.MouseButton1Click:Connect(function()
            getgenv().Config[configKey] = not getgenv().Config[configKey]
            local state = getgenv().Config[configKey]
            btn.Text = text .. (state and ": ON" or ": OFF")
            btn.BackgroundColor3 = state and Color3.fromRGB(50, 120, 210) or Color3.fromRGB(35, 35, 50)
            if callback then callback(state) end
        end)
    end

    -- Наполнение Вкладки "Фарм"
    createToggle(farmPage, "Автофарм мобов", "AutoFarm")

    -- Наполнение Вкладки "Статы"
    createToggle(statsPage, "Авто-прокачка статов", "AutoStats")
    
    local statBtns = {"Melee", "Defense", "Sword", "Gun", "Fruit"}
    for _, sName in ipairs(statBtns) do
        local sBtn = Instance.new("TextButton")
        sBtn.Size = UDim2.new(1, 0, 0, 26)
        sBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
        sBtn.Text = "Прокачивать: " .. sName
        sBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
        sBtn.Font = Enum.Font.SourceSans
        sBtn.Parent = statsPage
        Instance.new("UICorner", sBtn).CornerRadius = UDim.new(0, 4)

        sBtn.MouseButton1Click:Connect(function()
            getgenv().Config.SelectedStat = sName
            print("[BloxFruitsHub]: Выбрана стата - " .. sName)
        end)
    end

    -- Наполнение Вкладки "ESP"
    createToggle(espPage, "ESP Сундуков", "ChestESP", function(st) espModule.UpdateChestESP(st) end)

    local fruitBtn = Instance.new("TextButton")
    fruitBtn.Size = UDim2.new(1, 0, 0, 32)
    fruitBtn.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
    fruitBtn.Text = "Найти и забрать фрукт"
    fruitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    fruitBtn.Font = Enum.Font.SourceSansBold
    fruitBtn.Parent = espPage
    Instance.new("UICorner", fruitBtn).CornerRadius = UDim.new(0, 4)

    fruitBtn.MouseButton1Click:Connect(function()
        local found = espModule.SearchAndCollectFruit()
        if not found then
            print("[BloxFruitsHub]: На карте нет заспавненных фруктов!")
        end
    end)

    showPage("Farm")
end

return UIModule