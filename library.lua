--[[
    Sensei UI Library (Powered by Wand UI / Redz V5)
    Version: 1.3.0 — Custom Gray Minimizer
    Load: local Sensei = loadstring(game:HttpGet("https://raw.githubusercontent.com/glitchmode960-gif/library/main/library.lua"))()
]]

local Sensei = {}

-- ============================================================
-- Загружаем Wand UI
-- ============================================================
local WandUI
do
    local ok, result = pcall(function()
        return loadstring(game:HttpGet(
            "https://raw.githubusercontent.com/newredzv3/WandUI/refs/heads/main/redz-V5-remake/main.luau"
        ))()
    end)
    if ok and result then
        WandUI = result
    else
        warn("[Sensei] Failed to load Wand UI:", result)
        return {}
    end
end

print("[Sensei] Wand UI loaded")

-- ============================================================
-- Прокси методов
-- ============================================================
Sensei.Creator = WandUI
Sensei.Version = "1.3.0"

Sensei.GetThemes     = function(self) return WandUI:GetThemes() end
Sensei.GetTheme      = function(self, name) return WandUI:GetTheme(name) end
Sensei.SetTheme      = function(self, name) return WandUI:SetTheme(name) end
Sensei.SetUIScale    = function(self, v) return WandUI:SetUIScale(v) end
Sensei.GetMinScale   = function(self) return WandUI:GetMinScale() end
Sensei.GetMaxScale   = function(self) return WandUI:GetMaxScale() end
Sensei.GetIconByName = function(self, name) return WandUI:GetIconByName(name) end
Sensei.Destroy       = function(self) return WandUI:Destroy() end

-- ============================================================
-- Создание СВОЕЙ серой кнопки-минимизатора
-- ============================================================
local function CreateGrayMinimizer(window)
    local hui = gethui and gethui() or game:GetService("CoreGui")

    -- Кнопка
    local btn = Instance.new("TextButton")
    btn.Name = "SenseiMinimizer"
    btn.Size = UDim2.fromOffset(44, 44)
    btn.Position = UDim2.new(0, 20, 0, 20)   -- слева сверху
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)  -- серый
    btn.BackgroundTransparency = 0.1
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.BorderSizePixel = 0
    btn.Active = true
    btn.Draggable = true   -- перетаскивание
    btn.Parent = hui

    -- Скругление
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = btn

    -- Обводка
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(100, 100, 110)
    stroke.Thickness = 1.5
    stroke.Transparency = 0.4
    stroke.Parent = btn

    -- Внутренний квадрат (серый, чуть темнее)
    local inner = Instance.new("Frame")
    inner.Name = "Inner"
    inner.Size = UDim2.fromOffset(20, 20)
    inner.Position = UDim2.new(0.5, 0, 0.5, 0)
    inner.AnchorPoint = Vector2.new(0.5, 0.5)
    inner.BackgroundColor3 = Color3.fromRGB(120, 120, 130)
    inner.BorderSizePixel = 0
    inner.Parent = btn

    local innerCorner = Instance.new("UICorner")
    innerCorner.CornerRadius = UDim.new(0, 4)
    innerCorner.Parent = inner

    -- Анимация нажатия
    local pressed = false
    btn.MouseButton1Down:Connect(function()
        pressed = true
        inner.Size = UDim2.fromOffset(16, 16)
    end)
    btn.MouseButton1Up:Connect(function()
        pressed = false
        inner.Size = UDim2.fromOffset(20, 20)
    end)

    -- Клик → Minimize
    btn.MouseButton1Click:Connect(function()
        if window.Minimize then
            pcall(function() window:Minimize() end)
        elseif window.MinimizeButton then
            pcall(function() window:MinimizeButton() end)
        end
    end)

    return btn
end

-- ============================================================
-- CreateWindow
-- ============================================================
function Sensei:CreateWindow(options)
    options = options or {}

    if not options.Title then options.Title = "Sensei Hub" end
    if not options.SubTitle then options.SubTitle = "Powered by Sensei" end
    if not options.ScriptFolder then options.ScriptFolder = "sensei" end

    local window = WandUI:MakeWindow(options)

    pcall(function() WandUI:SetUIScale(0.85) end)

    -- Создаём штатный минимизатор Wand UI (скрытый)
    pcall(function()
        local minimizer = window:NewMinimizer({
            KeyCode = Enum.KeyCode.LeftControl,
        })
        -- Наша собственная серая кнопка
        CreateGrayMinimizer(window)
    end)

    return window
end

-- ============================================================
-- Notify
-- ============================================================
local _origNotify = WandUI.Notify
function Sensei:Notify(options)
    return _origNotify(WandUI, options)
end

-- ============================================================
-- Экспорт
-- ============================================================
if getgenv then
    pcall(function()
        getgenv().Sensei = Sensei
        getgenv().SenseiVersion = Sensei.Version
    end)
end

print("[Sensei] loaded, version:", Sensei.Version)

return Sensei