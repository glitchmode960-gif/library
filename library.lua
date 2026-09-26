--[[
    Sensei UI Library (Powered by Wand UI / Redz V5)
    Version: 1.1.0 — Themes & GUI Settings
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
-- ДОБАВЛЯЕМ СВОИ ТЕМЫ
-- ============================================================
local function MakeTheme(name, colors)
    return {
        Name = name,
        Colors = {
            Background = ColorSequence.new{
                ColorSequenceKeypoint.new(0.00, colors.bg1),
                ColorSequenceKeypoint.new(0.50, colors.bg2),
                ColorSequenceKeypoint.new(1.00, colors.bg1),
            },
            Primary = colors.accent,
            OnPrimary = colors.accentDark,
            ScrollBar = colors.scroll,
            Stroke = colors.stroke,
            Error = Color3.fromRGB(255, 102, 102),
            Icons = Color3.fromRGB(232, 233, 235),
            JoinButton = Color3.fromRGB(37, 128, 69),
            Link = Color3.fromRGB(40, 150, 255),
            Dialog = { Background = colors.dialogBg },
            Buttons = {
                Holding = colors.btnHover,
                Default = colors.btn,
            },
            Border = {
                Holding = colors.borderHover,
                Default = colors.border,
            },
            Text = {
                Default = colors.text,
                Dark = colors.textDark,
                Darker = colors.textDarker,
            },
            Slider = {
                SliderBar = colors.scroll,
                SliderNumber = Color3.fromRGB(232, 233, 235),
            },
            Dropdown = {
                Holder = colors.dropdownBg,
            },
        },
        Icons = {},
        Font = {
            Normal = Enum.Font.BuilderSans,
            Medium = Enum.Font.BuilderSansMedium,
            Bold = Enum.Font.BuilderSansBold,
            ExtraBold = Enum.Font.BuilderSansExtraBold,
            SliderValue = Enum.Font.FredokaOne,
        },
        BackgroundTransparency = 0.03,
    }
end

-- Blue (голубая — как Sensei ZX)
WandUI.Themes.Blue = MakeTheme("Blue", {
    bg1 = Color3.fromRGB(12, 15, 22),
    bg2 = Color3.fromRGB(18, 22, 32),
    accent = Color3.fromRGB(0, 170, 255),
    accentDark = Color3.fromRGB(0, 100, 180),
    scroll = Color3.fromRGB(0, 80, 140),
    stroke = Color3.fromRGB(40, 60, 90),
    dialogBg = Color3.fromRGB(20, 25, 35),
    btn = Color3.fromRGB(22, 28, 38),
    btnHover = Color3.fromRGB(30, 40, 55),
    border = Color3.fromRGB(38, 50, 70),
    borderHover = Color3.fromRGB(60, 80, 110),
    text = Color3.fromRGB(240, 245, 252),
    textDark = Color3.fromRGB(200, 210, 225),
    textDarker = Color3.fromRGB(150, 165, 185),
    dropdownBg = Color3.fromRGB(20, 28, 40),
})

-- Purple
WandUI.Themes.Purple = MakeTheme("Purple", {
    bg1 = Color3.fromRGB(15, 12, 22),
    bg2 = Color3.fromRGB(22, 18, 32),
    accent = Color3.fromRGB(138, 43, 226),
    accentDark = Color3.fromRGB(90, 30, 150),
    scroll = Color3.fromRGB(80, 30, 140),
    stroke = Color3.fromRGB(60, 40, 90),
    dialogBg = Color3.fromRGB(25, 20, 35),
    btn = Color3.fromRGB(28, 22, 38),
    btnHover = Color3.fromRGB(40, 30, 55),
    border = Color3.fromRGB(50, 38, 70),
    borderHover = Color3.fromRGB(80, 60, 110),
    text = Color3.fromRGB(245, 240, 252),
    textDark = Color3.fromRGB(210, 200, 225),
    textDarker = Color3.fromRGB(165, 150, 185),
    dropdownBg = Color3.fromRGB(28, 20, 40),
})

-- Red
WandUI.Themes.Red = MakeTheme("Red", {
    bg1 = Color3.fromRGB(22, 12, 12),
    bg2 = Color3.fromRGB(32, 18, 18),
    accent = Color3.fromRGB(235, 70, 85),
    accentDark = Color3.fromRGB(150, 40, 50),
    scroll = Color3.fromRGB(140, 40, 50),
    stroke = Color3.fromRGB(90, 40, 40),
    dialogBg = Color3.fromRGB(35, 20, 20),
    btn = Color3.fromRGB(38, 22, 22),
    btnHover = Color3.fromRGB(55, 30, 30),
    border = Color3.fromRGB(70, 38, 38),
    borderHover = Color3.fromRGB(110, 60, 60),
    text = Color3.fromRGB(252, 240, 240),
    textDark = Color3.fromRGB(225, 200, 200),
    textDarker = Color3.fromRGB(185, 150, 150),
    dropdownBg = Color3.fromRGB(40, 20, 20),
})

-- Green
WandUI.Themes.Green = MakeTheme("Green", {
    bg1 = Color3.fromRGB(12, 20, 15),
    bg2 = Color3.fromRGB(18, 30, 22),
    accent = Color3.fromRGB(50, 200, 120),
    accentDark = Color3.fromRGB(30, 120, 70),
    scroll = Color3.fromRGB(30, 120, 70),
    stroke = Color3.fromRGB(40, 80, 55),
    dialogBg = Color3.fromRGB(20, 32, 25),
    btn = Color3.fromRGB(22, 35, 27),
    btnHover = Color3.fromRGB(30, 48, 38),
    border = Color3.fromRGB(38, 60, 45),
    borderHover = Color3.fromRGB(60, 95, 75),
    text = Color3.fromRGB(240, 252, 245),
    textDark = Color3.fromRGB(200, 225, 210),
    textDarker = Color3.fromRGB(150, 185, 165),
    dropdownBg = Color3.fromRGB(20, 38, 28),
})

-- Light
WandUI.Themes.Light = MakeTheme("Light", {
    bg1 = Color3.fromRGB(240, 240, 245),
    bg2 = Color3.fromRGB(250, 250, 255),
    accent = Color3.fromRGB(80, 100, 220),
    accentDark = Color3.fromRGB(50, 60, 150),
    scroll = Color3.fromRGB(100, 120, 200),
    stroke = Color3.fromRGB(180, 185, 200),
    dialogBg = Color3.fromRGB(235, 235, 240),
    btn = Color3.fromRGB(225, 225, 235),
    btnHover = Color3.fromRGB(210, 210, 225),
    border = Color3.fromRGB(190, 195, 210),
    borderHover = Color3.fromRGB(160, 170, 190),
    text = Color3.fromRGB(30, 35, 50),
    textDark = Color3.fromRGB(70, 80, 100),
    textDarker = Color3.fromRGB(120, 130, 150),
    dropdownBg = Color3.fromRGB(230, 230, 240),
})

-- Dark (просто тёмная)
WandUI.Themes.Dark = MakeTheme("Dark", {
    bg1 = Color3.fromRGB(15, 15, 18),
    bg2 = Color3.fromRGB(22, 22, 26),
    accent = Color3.fromRGB(150, 150, 170),
    accentDark = Color3.fromRGB(80, 80, 100),
    scroll = Color3.fromRGB(80, 80, 100),
    stroke = Color3.fromRGB(45, 45, 55),
    dialogBg = Color3.fromRGB(25, 25, 30),
    btn = Color3.fromRGB(30, 30, 36),
    btnHover = Color3.fromRGB(45, 45, 52),
    border = Color3.fromRGB(50, 50, 60),
    borderHover = Color3.fromRGB(80, 80, 95),
    text = Color3.fromRGB(240, 240, 245),
    textDark = Color3.fromRGB(200, 200, 210),
    textDarker = Color3.fromRGB(150, 150, 165),
    dropdownBg = Color3.fromRGB(28, 28, 34),
})

print("[Sensei] Themes registered:", table.concat(WandUI:GetThemes(), ", "))

-- ============================================================
-- Прокси публичных методов
-- ============================================================
Sensei.Creator = WandUI
Sensei.Version = "1.1.0"

Sensei.GetThemes     = function(self) return WandUI:GetThemes() end
Sensei.GetTheme      = function(self, name) return WandUI:GetTheme(name) end
Sensei.SetTheme      = function(self, name) return WandUI:SetTheme(name) end
Sensei.IsValidTheme  = function(self, name) return WandUI:IsValidTheme(name) end
Sensei.SetUIScale    = function(self, v) return WandUI:SetUIScale(v) end
Sensei.GetMinScale   = function(self) return WandUI:GetMinScale() end
Sensei.GetMaxScale   = function(self) return WandUI:GetMaxScale() end
Sensei.GetIconByName = function(self, name) return WandUI:GetIconByName(name) end
Sensei.Destroy       = function(self) return WandUI:Destroy() end

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

    pcall(function()
        local minimizer = window:NewMinimizer({
            KeyCode = Enum.KeyCode.LeftControl,
        })
        if minimizer and minimizer.CreateMobileMinimizer then
            minimizer:CreateMobileMinimizer({
                Image = "rbxassetid://15298567397",
                Size = UDim2.new(0, 35, 0, 35),
                Corner = { CornerRadius = UDim.new(0, 6) },
            })
        end
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