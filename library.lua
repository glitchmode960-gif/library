--[[
    Sensei UI Library (Powered by Wand UI / Redz V5)
    Version: 1.0.0
    Load: local Sensei = loadstring(game:HttpGet("https://raw.githubusercontent.com/glitchmode960-gif/library/main/library.lua"))()
]]

local Sensei = {}

-- ============================================================
-- Загружаем Wand UI (движок)
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
-- Прокси публичных методов
-- ============================================================
Sensei.Creator = WandUI
Sensei.Version = "1.0.0"

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
-- CreateWindow — обёртка с мобильными дефолтами
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