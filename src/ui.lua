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

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 560, 0, 360)
    MainFrame.Position = UDim2.new(0.5, -280, 0.4, -180)
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Parent = ScreenGui

    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, 0, 0, 40)
    Header.BackgroundColor3 = Color3.fromRGB(28, 28, 40)
    Header.BorderSizePixel = 0
    Header.Parent = MainFrame
    Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 10)

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -15, 1, 0)
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "Blox Fruits Hub v2.2 | [Right Shift - Скрыть]"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 16
    Title.Font = Enum.Font.SourceSansBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Header

    -- Драг-энд-дроп
    local dragging = false
    local dragInput, dragStart, startPos

    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
        end
    end)

    Header.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == Enum.KeyCode.RightShift then
            MainFrame.Visible = not MainFrame.Visible
        end
    end)

    -- Sidebar
    local Sidebar = Instance.new("Frame")
    Sidebar.Size = UDim2.new(0, 130, 1, -50)
    Sidebar.Position = UDim2.new(0, 8, 0, 45)
    Sidebar.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = MainFrame
    Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 8)

    local SidebarList = Instance.new("UIListLayout", Sidebar)
    SidebarList.Padding = UDim.new(0, 6)

    local PageContainer = Instance.new("Frame")
    PageContainer.Size = UDim2.new(1, -154, 1, -50)
    PageContainer.Position = UDim2.new(0, 146, 0, 45)
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
        layout.Padding = UDim.new(0, 8)
        
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
        btn.Size = UDim2.new(1, 0, 0, 38)
        btn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
        btn.BorderSizePixel = 0
        btn.Text = text
        btn.TextColor3 = Color3.fromRGB(230, 230, 230)
        btn.TextSize = 15
        btn.Font = Enum.Font.SourceSansBold
        btn.Parent = Sidebar
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

        btn.MouseButton1Click:Connect(function()
            showPage(pageName)
        end)
    end

    createTabBtn("Фарм", "Farm")
    createTabBtn("Статы", "Stats")
    createTabBtn("ESP / Фрукты", "ESP")

    local function createToggle(parent, text, configKey, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 38)
        btn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
        btn.BorderSizePixel = 0
        btn.Text = text .. ": OFF"
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextSize = 15
        btn.Font = Enum.Font.SourceSansSemibold
        btn.Parent = parent
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

        btn.MouseButton1Click:Connect(function()
            getgenv().Config[configKey] = not getgenv().Config[configKey]
            local state = getgenv().Config[configKey]
            btn.Text = text .. (state and ": ON" or ": OFF")
            btn.BackgroundColor3 = state and Color3.fromRGB(45, 125, 210) or Color3.fromRGB(35, 35, 50)
            if callback then callback(state) end
        end)
    end

    -- Переключатели
    createToggle(farmPage, "Автофарм мобов", "AutoFarm")
    createToggle(statsPage, "Авто-прокачка статов", "AutoStats")
    
    local statBtns = {"Melee", "Defense", "Sword", "Gun", "Fruit"}
    for _, sName in ipairs(statBtns) do
        local sBtn = Instance.new("TextButton")
        sBtn.Size = UDim2.new(1, 0, 0, 30)
        sBtn.BackgroundColor3 = Color3.fromRGB(32, 32, 45)
        sBtn.Text = "Прокачивать: " .. sName
        sBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
        sBtn.TextSize = 14
        sBtn.Font = Enum.Font.SourceSans
        sBtn.Parent = statsPage
        Instance.new("UICorner", sBtn).CornerRadius = UDim.new(0, 4)

        sBtn.MouseButton1Click:Connect(function()
            getgenv().Config.SelectedStat = sName
            print("[BloxFruitsHub]: Выбрана стата - " .. sName)
        end)
    end

    createToggle(espPage, "ESP Подсветка сундуков", "ChestESP", function(st) espModule.UpdateChestESP(st) end)
    createToggle(espPage, "Авто-сбор сундуков", "AutoCollectChests")

    local fruitBtn = Instance.new("TextButton")
    fruitBtn.Size = UDim2.new(1, 0, 0, 38)
    fruitBtn.BackgroundColor3 = Color3.fromRGB(190, 55, 55)
    fruitBtn.Text = "Найти и забрать фрукт"
    fruitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    fruitBtn.TextSize = 15
    fruitBtn.Font = Enum.Font.SourceSansBold
    fruitBtn.Parent = espPage
    Instance.new("UICorner", fruitBtn).CornerRadius = UDim.new(0, 6)

    fruitBtn.MouseButton1Click:Connect(function()
        local found = espModule.SearchAndCollectFruit()
        if not found then
            print("[BloxFruitsHub]: На карте нет заспавненных фруктов!")
        end
    end)

    showPage("Farm")
end

return UIModule