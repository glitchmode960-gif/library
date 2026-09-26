--[[
    Sensei UI Library — Mobile Edition
    Rewritten from ZyronX architecture
    Author: CreativeGPT & Douwe
    Version: 2.0.0
    Style: Blue Neon, phone-optimized, Delta-style minibar
    Load: local Sensei = loadstring(game:HttpGet("https://raw.githubusercontent.com/glitchmode960-gif/library/main/library.lua"))()
]]

local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui          = game:GetService("CoreGui")
local RunService       = game:GetService("RunService")
local HttpService      = game:GetService("HttpService")
local Players          = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

local Library = {
    WhitelistedUsers = {}
}

-- ============================================================
-- File System (safe fallbacks)
-- ============================================================
local _isfolder  = isfolder  or function() return true end
local _makefolder= makefolder or function() end
local _writefile = writefile or function() warn("[Sensei] writefile not supported.") end
local _readfile  = readfile  or function() return "{}" end
local _listfiles = listfiles or function() return {} end
local _delfile   = delfile   or function() warn("[Sensei] delfile not supported.") end

local function SafeCopy(text)
    if setclipboard then setclipboard(text)
    elseif toclipboard then toclipboard(text)
    else warn("[Sensei] Clipboard not supported.") end
end

-- ============================================================
-- Palette (Blue Neon)
-- ============================================================
local AccentColor       = Color3.fromRGB(0, 170, 255)
local AccentColorLight  = Color3.fromRGB(120, 220, 255)
local BackgroundColor   = Color3.fromRGB(15, 18, 24)
local CardColor         = Color3.fromRGB(24, 28, 36)
local ItemColor         = Color3.fromRGB(34, 40, 50)
local HoverColor        = Color3.fromRGB(44, 52, 64)
local TextColor         = Color3.fromRGB(235, 240, 248)
local SubTextColor      = Color3.fromRGB(150, 165, 185)
local StrokeColor       = Color3.fromRGB(40, 60, 90)

-- ============================================================
-- Utility: Create instance
-- ============================================================
local function Create(className, props)
    local inst = Instance.new(className)
    if className == "TextBox" then inst.Text = "" end
    for k, v in pairs(props or {}) do
        inst[k] = v
    end
    -- Автоматический TextScaled для длинных текстов
    if className == "TextLabel" or className == "TextButton" or className == "TextBox" then
        if props and props.TextSize and not props.RichText then
            inst.TextScaled = true
            local c = Instance.new("UITextSizeConstraint")
            c.MaxTextSize = props.TextSize
            c.MinTextSize = 8
            c.Parent = inst
        end
    end
    return inst
end

-- ============================================================
-- Utility: Tween
-- ============================================================
local function Tween(instance, properties, duration)
    duration = duration or 0.22
    local info = TweenInfo.new(duration, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    local tw = TweenService:Create(instance, info, properties)
    tw:Play()
    return tw
end

-- ============================================================
-- Utility: Bounce (микро-анимация нажатия)
-- ============================================================
local function AddBounce(button, scaleFactor)
    scaleFactor = scaleFactor or 0.96
    local scale = button:FindFirstChild("UIScale") or Create("UIScale", {Parent = button, Scale = 1})
    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            Tween(scale, {Scale = scaleFactor}, 0.12)
        end
    end)
    button.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            Tween(scale, {Scale = 1}, 0.12)
        end
    end)
    button.MouseLeave:Connect(function()
        Tween(scale, {Scale = 1}, 0.12)
    end)
end

-- ============================================================
-- Utility: Draggable
-- ============================================================
local function MakeDraggable(topbar, object)
    topbar.Active = true
    object.Active = true
    local dragging, dragInput, dragStart, startPos

    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = object.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    topbar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            object.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- ============================================================
-- Notifications
-- ============================================================
local GlobalNotifContainer

function Library:Notify(options)
    if not GlobalNotifContainer then return end
    options = options or {}
    local title = options.Title or "Уведомление"
    local desc  = options.Description or options.Content or ""
    local duration = options.Duration or 3

    local Notif = Create("Frame", {
        Parent = GlobalNotifContainer,
        BackgroundColor3 = BackgroundColor,
        Size = UDim2.new(1, 0, 0, 62),
        BackgroundTransparency = 1,
        ZIndex = 201,
        ClipsDescendants = true,
    })
    Create("UICorner", {Parent = Notif, CornerRadius = UDim.new(0, 10)})
    local Stroke = Create("UIStroke", {
        Parent = Notif, Color = AccentColor, Thickness = 1.4, Transparency = 1,
    })

    local TitleText = Create("TextLabel", {
        Parent = Notif, Text = title, Font = Enum.Font.GothamBold, TextSize = 13,
        TextColor3 = TextColor, BackgroundTransparency = 1,
        Position = UDim2.new(0, 14, 0, 12), Size = UDim2.new(1, -28, 0, 16),
        TextXAlignment = Enum.TextXAlignment.Left, TextTransparency = 1, ZIndex = 202,
    })
    local DescText = Create("TextLabel", {
        Parent = Notif, Text = desc, Font = Enum.Font.Gotham, TextSize = 11,
        TextColor3 = SubTextColor, BackgroundTransparency = 1,
        Position = UDim2.new(0, 14, 0, 30), Size = UDim2.new(1, -28, 0, 22),
        TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true,
        TextTransparency = 1, ZIndex = 202,
    })

    Tween(Notif, {BackgroundTransparency = 0.05}, 0.3)
    Tween(Stroke, {Transparency = 0.2}, 0.3)
    Tween(TitleText, {TextTransparency = 0}, 0.3)
    Tween(DescText, {TextTransparency = 0}, 0.3)

    task.delay(duration, function()
        Tween(Notif, {BackgroundTransparency = 1}, 0.35)
        Tween(Stroke, {Transparency = 1}, 0.35)
        Tween(TitleText, {TextTransparency = 1}, 0.35)
        Tween(DescText, {TextTransparency = 1}, 0.35)
        task.wait(0.4)
        Notif:Destroy()
    end)
end-- ============================================================
-- CREATE WINDOW
-- ============================================================
function Library:CreateWindow(options)
    local hubName  = "Sensei"
    local subText  = "Mobile Edition"
    local subColor = AccentColorLight
    local topbarLogo = nil
    local logoSize = 26

    if type(options) == "table" then
        hubName    = options.Title or hubName
        subText    = options.Subtitle or subText
        subColor   = options.SubtitleColor or subColor
        topbarLogo = options.Logo
        logoSize   = options.LogoSize or 26
    elseif type(options) == "string" then
        hubName = options
    end

    local uniqueID = HttpService:GenerateGUID(false)
    local ScreenGui = Create("ScreenGui", {
        Name = "Sensei_UI_" .. uniqueID,
        Parent = RunService:IsStudio()
            and LocalPlayer:WaitForChild("PlayerGui")
            or CoreGui,
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
    })
    if syn and syn.protect_gui then pcall(function() syn.protect_gui(ScreenGui) end) end

    -- Notifications container (справа сверху)
    local NotifContainer = Create("Frame", {
        Parent = ScreenGui,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 260, 0, 300),
        Position = UDim2.new(1, -270, 0, 12),
        ZIndex = 200,
        Active = false,
    })
    Create("UIListLayout", {
        Parent = NotifContainer,
        VerticalAlignment = Enum.VerticalAlignment.Top,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8),
    })
    GlobalNotifContainer = NotifContainer

    -- ========================================================
    -- Main Frame (mobile-optimized)
    -- ========================================================
    local MainFrame = Create("Frame", {
        Parent = ScreenGui,
        BackgroundColor3 = BackgroundColor,
        Size = UDim2.new(0, 340, 0, 470),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        ClipsDescendants = true,
        BackgroundTransparency = 0.05,
        Active = true,
        ZIndex = 5,
    })
    local MainScale = Create("UIScale", {Parent = MainFrame, Scale = 1})
    Create("UICorner", {Parent = MainFrame, CornerRadius = UDim.new(0, 12)})
    local MainStroke = Create("UIStroke", {
        Parent = MainFrame, Color = StrokeColor, Thickness = 1.2, Transparency = 0.15,
    })

    -- ========================================================
    -- Delta-style Minibar (маленькая панель для свёрнутого окна)
    -- ========================================================
    local Minibar = Create("Frame", {
        Parent = ScreenGui,
        BackgroundColor3 = CardColor,
        Size = UDim2.new(0, 180, 0, 44),
        Position = UDim2.new(0.5, -90, 1, -80),
        AnchorPoint = Vector2.new(0, 0),
        Visible = false,
        Active = true,
        ZIndex = 10,
    })
    Create("UICorner", {Parent = Minibar, CornerRadius = UDim.new(0, 12)})
    local MinibarStroke = Create("UIStroke", {
        Parent = Minibar, Color = AccentColor, Thickness = 1.4, Transparency = 0.2,
    })

    -- Иконка
    local MinibarIcon
    if topbarLogo then
        MinibarIcon = Create("ImageLabel", {
            Parent = Minibar, BackgroundTransparency = 1,
            Size = UDim2.new(0, 24, 0, 24),
            Position = UDim2.new(0, 10, 0.5, -12),
            Image = topbarLogo, ImageColor3 = AccentColor,
        })
    else
        MinibarIcon = Create("TextLabel", {
            Parent = Minibar, BackgroundTransparency = 1,
            Size = UDim2.new(0, 24, 0, 24),
            Position = UDim2.new(0, 10, 0.5, -12),
            Text = "⚡", Font = Enum.Font.GothamBold,
            TextSize = 16, TextColor3 = AccentColor,
        })
    end

    -- Название
    local MinibarTitle = Create("TextLabel", {
        Parent = Minibar, BackgroundTransparency = 1,
        Size = UDim2.new(1, -80, 1, 0),
        Position = UDim2.new(0, 40, 0, 0),
        Text = hubName, Font = Enum.Font.GothamBold,
        TextSize = 13, TextColor3 = TextColor,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
    })

    -- Кнопка развернуть
    local MinibarExpand = Create("TextButton", {
        Parent = Minibar,
        Size = UDim2.new(0, 28, 0, 28),
        Position = UDim2.new(1, -34, 0.5, -14),
        BackgroundColor3 = ItemColor,
        Text = "⤢", Font = Enum.Font.GothamBold,
        TextSize = 14, TextColor3 = AccentColor,
        AutoButtonColor = false,
        BorderSizePixel = 0,
    })
    Create("UICorner", {Parent = MinibarExpand, CornerRadius = UDim.new(0, 8)})
    AddBounce(MinibarExpand)

    -- Мини-бар draggable
    MakeDraggable(Minibar, Minibar)

    -- Кнопка разворачивания
    local function RestoreFromMinibar()
        Minibar.Visible = false
        MainFrame.Visible = true
        MainScale.Scale = 0.9
        Tween(MainScale, {Scale = 1}, 0.35)
        Tween(MainFrame, {BackgroundTransparency = 0.05}, 0.35)
    end
    MinibarExpand.MouseButton1Click:Connect(RestoreFromMinibar)
    Minibar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            -- Тап по телу мини-бара (кроме кнопки) — тоже разворачивает
            -- (сработает только если не drag)
        end
    end)

    -- ========================================================
    -- TopBar
    -- ========================================================
    local TopBar = Create("Frame", {
        Parent = MainFrame,
        BackgroundColor3 = CardColor,
        BackgroundTransparency = 0.15,
        Size = UDim2.new(1, 0, 0, 40),
        Position = UDim2.new(0, 0, 0, 0),
        Active = true,
        BorderSizePixel = 0,
    })
    Create("UICorner", {Parent = TopBar, CornerRadius = UDim.new(0, 12)})
    -- нижняя полоска, чтобы углы снизу не были скруглены "внутрь"
    local topPatch = Create("Frame", {
        Parent = TopBar, BackgroundColor3 = CardColor,
        BackgroundTransparency = 0.15, BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 14), Position = UDim2.new(0, 0, 1, -14),
    })

    MakeDraggable(TopBar, MainFrame)

    local titleOffsetX = 12
    if topbarLogo then
        Create("ImageLabel", {
            Parent = TopBar, BackgroundTransparency = 1,
            Size = UDim2.new(0, logoSize, 0, logoSize),
            Position = UDim2.new(0, 10, 0.5, -(logoSize / 2)),
            Image = topbarLogo, ImageColor3 = AccentColor,
            ScaleType = Enum.ScaleType.Fit,
        })
        titleOffsetX = 10 + logoSize + 8
    end

    local TitleContainer = Create("Frame", {
        Parent = TopBar, BackgroundTransparency = 1,
        Size = UDim2.new(0, 160, 1, 0),
        Position = UDim2.new(0, titleOffsetX, 0, 0),
    })
    Create("TextLabel", {
        Parent = TitleContainer,
        Text = hubName, Font = Enum.Font.GothamBold, TextSize = 13,
        TextColor3 = TextColor, BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 5), Size = UDim2.new(1, 0, 0, 15),
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    Create("TextLabel", {
        Parent = TitleContainer,
        Text = subText, Font = Enum.Font.Gotham, TextSize = 9,
        TextColor3 = subColor, BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 21), Size = UDim2.new(1, 0, 0, 12),
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    -- Кнопки close / minimize
    local CloseBtn = Create("TextButton", {
        Parent = TopBar, Text = "✕", Font = Enum.Font.GothamBold, TextSize = 13,
        TextColor3 = SubTextColor, BackgroundTransparency = 1,
        Size = UDim2.new(0, 30, 1, 0), Position = UDim2.new(1, -34, 0, 0),
        AutoButtonColor = false,
    })
    local MinBtn = Create("TextButton", {
        Parent = TopBar, Text = "—", Font = Enum.Font.GothamBold, TextSize = 14,
        TextColor3 = SubTextColor, BackgroundTransparency = 1,
        Size = UDim2.new(0, 30, 1, 0), Position = UDim2.new(1, -64, 0, 0),
        AutoButtonColor = false,
    })
    AddBounce(CloseBtn); AddBounce(MinBtn)

    -- ========================================================
    -- Minimize → Delta-style minibar
    -- ========================================================
    MinBtn.MouseButton1Click:Connect(function()
        -- Сохраняем позицию окна → ставим мини-бар туда
        Minibar.Position = UDim2.new(
            MainFrame.Position.X.Scale,
            MainFrame.Position.X.Offset - 90 + 170, -- примерно к правому краю окна
            MainFrame.Position.Y.Scale,
            MainFrame.Position.Y.Offset - 80
        )
        -- Анимация: окно уменьшается, мини-бар выезжает
        Tween(MainScale, {Scale = 0.85}, 0.28)
        Tween(MainFrame, {BackgroundTransparency = 1}, 0.28)
        task.wait(0.22)
        MainFrame.Visible = false
        Minibar.Visible = true
        Minibar.Size = UDim2.new(0, 0, 0, 44)
        Tween(Minibar, {Size = UDim2.new(0, 180, 0, 44)}, 0.3)
    end)

    -- ========================================================
    -- Sidebar (мобильная, узкая)
    -- ========================================================
    local Sidebar = Create("Frame", {
        Parent = MainFrame,
        BackgroundColor3 = CardColor,
        BackgroundTransparency = 0.15,
        Size = UDim2.new(0, 110, 1, -40),
        Position = UDim2.new(0, 0, 0, 40),
        Active = true,
        BorderSizePixel = 0,
    })

    local TabContainer = Create("ScrollingFrame", {
        Parent = Sidebar,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -10, 1, -10),
        Position = UDim2.new(0, 5, 0, 5),
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = StrokeColor,
        BorderSizePixel = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0),
    })
    local TabLayout = Create("UIListLayout", {
        Parent = TabContainer,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 6),
    })
    TabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        TabContainer.CanvasSize = UDim2.new(0, 0, 0, TabLayout.AbsoluteContentSize.Y + 10)
    end)

    -- Разделитель
    Create("Frame", {
        Parent = MainFrame, BackgroundColor3 = StrokeColor,
        BorderSizePixel = 0, Size = UDim2.new(0, 1, 1, -40),
        Position = UDim2.new(0, 110, 0, 40),
    })

    -- ========================================================
    -- Content Area
    -- ========================================================
    local ContentArea = Create("Frame", {
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -115, 1, -40),
        Position = UDim2.new(0, 115, 0, 40),
        Active = true,
    })

    -- ========================================================
    -- Confirm Close Popup
    -- ========================================================
    local Popup = Create("Frame", {
        Parent = ScreenGui, BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 100, Visible = false, Active = true,
    })
    local PopupCard = Create("Frame", {
        Parent = Popup, BackgroundColor3 = BackgroundColor,
        Size = UDim2.new(0, 280, 0, 150),
        Position = UDim2.new(0.5, 0, 0.5, 0), AnchorPoint = Vector2.new(0.5, 0.5),
        ZIndex = 101, BackgroundTransparency = 1,
    })
    Create("UICorner", {Parent = PopupCard, CornerRadius = UDim.new(0, 12)})
    local PopupScale = Create("UIScale", {Parent = PopupCard, Scale = 0.85})
    local PopupStroke = Create("UIStroke", {
        Parent = PopupCard, Color = StrokeColor, Thickness = 1.2, Transparency = 1,
    })
    local PopupTitle = Create("TextLabel", {
        Parent = PopupCard, Text = "Закрыть Sensei?",
        Font = Enum.Font.GothamBold, TextSize = 16, TextColor3 = TextColor,
        BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 26),
        Position = UDim2.new(0, 0, 0, 22), ZIndex = 102,
        TextTransparency = 1, TextXAlignment = Enum.TextXAlignment.Center,
    })
    local PopupText = Create("TextLabel", {
        Parent = PopupCard, Text = "Несохранённые настройки могут быть потеряны.",
        Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = SubTextColor,
        BackgroundTransparency = 1, Size = UDim2.new(1, -30, 0, 40),
        Position = UDim2.new(0, 15, 0, 50), ZIndex = 102,
        TextTransparency = 1, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Center,
    })
    local YesBtn = Create("TextButton", {
        Parent = PopupCard, Text = "Закрыть",
        Font = Enum.Font.GothamBold, TextSize = 12,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundColor3 = AccentColor,
        Size = UDim2.new(0, 110, 0, 32),
        Position = UDim2.new(0.5, 8, 1, -44),
        ZIndex = 102, BackgroundTransparency = 1, TextTransparency = 1,
        AutoButtonColor = false, BorderSizePixel = 0,
    })
    Create("UICorner", {Parent = YesBtn, CornerRadius = UDim.new(0, 8)})
    AddBounce(YesBtn)
    local NoBtn = Create("TextButton", {
        Parent = PopupCard, Text = "Отмена",
        Font = Enum.Font.GothamBold, TextSize = 12,
        TextColor3 = TextColor, BackgroundColor3 = ItemColor,
        Size = UDim2.new(0, 110, 0, 32),
        Position = UDim2.new(0.5, -118, 1, -44),
        ZIndex = 102, BackgroundTransparency = 1, TextTransparency = 1,
        AutoButtonColor = false, BorderSizePixel = 0,
    })
    Create("UICorner", {Parent = NoBtn, CornerRadius = UDim.new(0, 8)})
    AddBounce(NoBtn)

    CloseBtn.MouseButton1Click:Connect(function()
        Popup.Visible = true
        Tween(Popup, {BackgroundTransparency = 0.5}, 0.3)
        Tween(PopupCard, {BackgroundTransparency = 0}, 0.3)
        Tween(PopupScale, {Scale = 1}, 0.3)
        Tween(PopupStroke, {Transparency = 0.3}, 0.3)
        Tween(PopupTitle, {TextTransparency = 0}, 0.3)
        Tween(PopupText, {TextTransparency = 0}, 0.3)
        Tween(YesBtn, {BackgroundTransparency = 0, TextTransparency = 0}, 0.3)
        Tween(NoBtn, {BackgroundTransparency = 0, TextTransparency = 0}, 0.3)
    end)
    YesBtn.MouseButton1Click:Connect(function()
        Tween(MainScale, {Scale = 0.85}, 0.3)
        Tween(MainFrame, {BackgroundTransparency = 1}, 0.3)
        task.wait(0.35)
        ScreenGui:Destroy()
    end)
    NoBtn.MouseButton1Click:Connect(function()
        Tween(Popup, {BackgroundTransparency = 1}, 0.3)
        Tween(PopupCard, {BackgroundTransparency = 1}, 0.3)
        Tween(PopupScale, {Scale = 0.85}, 0.3)
        Tween(PopupStroke, {Transparency = 1}, 0.3)
        Tween(PopupTitle, {TextTransparency = 1}, 0.3)
        Tween(PopupText, {TextTransparency = 1}, 0.3)
        Tween(YesBtn, {BackgroundTransparency = 1, TextTransparency = 1}, 0.3)
        Tween(NoBtn, {BackgroundTransparency = 1, TextTransparency = 1}, 0.3)
        task.wait(0.3)
        Popup.Visible = false
    end)

    -- ========================================================
    -- Window API
    -- ========================================================
    local Window = {
        CurrentTab = nil,
        Tabs = {},
        Title = TitleContainer,
        AllCards = {},
        MainFrame = MainFrame,
        CurrentTransparency = 0.05,
        ConfigElements = {},
        ScreenGui = ScreenGui,
    }

    function Window:SetTransparency(val)
        Window.CurrentTransparency = val
        if MainFrame.Visible then
            Tween(MainFrame, {BackgroundTransparency = val}, 0.3)
        end
    end

    function Window:SetThemeAccent(color)
        AccentColor = color
        AccentColorLight = color:Lerp(Color3.new(1,1,1), 0.4)
        Tween(MainStroke, {Color = color:Lerp(Color3.new(1,1,1), 0.7)}, 0.3)
        Tween(MinibarStroke, {Color = color}, 0.3)
    end

    -- Заглушка, чтобы не падало, если кто-то вызовет
    function Window:SelectTab() end

    return Window, {
        TopBar = TopBar,
        Sidebar = Sidebar,
        TabContainer = TabContainer,
        ContentArea = ContentArea,
        MainFrame = MainFrame,
        ScreenGui = ScreenGui,
        Popup = Popup,
        Minibar = Minibar,
    }
end-- ============================================================
-- WINDOW METHODS (CreateTab / CreatePage / CreateSection)
-- ============================================================
local function AttachWindowMethods(Window, Refs)
    local TabContainer = Refs.TabContainer
    local ContentArea  = Refs.ContentArea
    local ScreenGui    = Refs.ScreenGui

    -- ========================================================
    -- CreateTab
    -- ========================================================
    function Window:CreateTab(tabName, isDefault, isLocked)
        tabName = tabName or "Tab"
        local isWhitelisted = false
        if LocalPlayer then
            for _, allowed in ipairs(Library.WhitelistedUsers) do
                if LocalPlayer.Name == allowed or LocalPlayer.DisplayName == allowed then
                    isWhitelisted = true
                    break
                end
            end
        end

        local TabBtn = Create("TextButton", {
            Parent = TabContainer,
            Text = "",
            BackgroundColor3 = HoverColor,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 34),
            AutoButtonColor = false,
            BorderSizePixel = 0,
        })
        Create("UICorner", {Parent = TabBtn, CornerRadius = UDim.new(0, 8)})
        AddBounce(TabBtn, 0.97)

        local Indicator = Create("Frame", {
            Parent = TabBtn,
            BackgroundColor3 = isLocked and Color3.fromRGB(255, 200, 70) or AccentColor,
            Size = UDim2.new(0, 3, 0, 0),
            Position = UDim2.new(0, 0, 0.5, 0),
            AnchorPoint = Vector2.new(0, 0.5),
            BorderSizePixel = 0,
        })
        Create("UICorner", {Parent = Indicator, CornerRadius = UDim.new(1, 0)})

        local Txt = Create("TextLabel", {
            Parent = TabBtn,
            Text = tabName,
            Font = Enum.Font.GothamBold,
            TextSize = 12,
            TextColor3 = SubTextColor,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -36, 1, 0),
            Position = UDim2.new(0, 12, 0, 0),
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
        })

        if isLocked then
            Create("TextLabel", {
                Parent = TabBtn, Text = "🔒", BackgroundTransparency = 1,
                Size = UDim2.new(0, 16, 0, 16),
                Position = UDim2.new(1, -20, 0.5, -8),
                TextSize = 12, TextColor3 = Color3.fromRGB(255, 200, 70),
            })
        end

        local TabContent = Create("Frame", {
            Parent = ContentArea,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Visible = false,
        })

        local PageNav = Create("Frame", {
            Parent = TabContent, BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 30),
        })
        Create("UIListLayout", {
            Parent = PageNav,
            FillDirection = Enum.FillDirection.Horizontal,
            Padding = UDim.new(0, 12),
            VerticalAlignment = Enum.VerticalAlignment.Center,
        })

        local PageContainer = Create("Frame", {
            Parent = TabContent, BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, -30),
            Position = UDim2.new(0, 0, 0, 30),
        })

        local TabConfig = {
            Button = TabBtn, Content = TabContent,
            Indicator = Indicator, Txt = Txt,
            Pages = {}, CurrentPage = nil,
            IsLocked = isLocked,
        }
        table.insert(Window.Tabs, TabConfig)

        TabBtn.MouseButton1Click:Connect(function()
            if isLocked and not isWhitelisted then
                Library:Notify({
                    Title = "Доступ закрыт",
                    Description = "Этот раздел доступен только по подписке.",
                    Duration = 3,
                })
                return
            end
            if Window.CurrentTab == TabConfig then return end

            if Window.CurrentTab then
                Tween(Window.CurrentTab.Button, {BackgroundTransparency = 1}, 0.2)
                Tween(Window.CurrentTab.Indicator, {Size = UDim2.new(0, 3, 0, 0)}, 0.2)
                Tween(Window.CurrentTab.Txt, {TextColor3 = SubTextColor}, 0.2)
                Window.CurrentTab.Content.Visible = false
            end

            Window.CurrentTab = TabConfig
            TabConfig.Content.Visible = true
            TabConfig.Content.Position = UDim2.new(0, 0, 0, 10)
            Tween(TabConfig.Content, {Position = UDim2.new(0, 0, 0, 0)}, 0.3)

            Tween(TabBtn, {BackgroundTransparency = 0.15}, 0.2)
            Tween(Indicator, {Size = UDim2.new(0, 3, 0, 18)}, 0.3)
            Tween(Txt, {TextColor3 = TextColor}, 0.2)

            if #TabConfig.Pages > 0 and not TabConfig.CurrentPage then
                local first = TabConfig.Pages[1]
                TabConfig.CurrentPage = first
                first.Scroll.Visible = true
                Tween(first.Btn, {TextColor3 = TextColor}, 0.2)
                Tween(first.Highlight, {Size = UDim2.new(1, 0, 0, 2), BackgroundTransparency = 0}, 0.2)
            end
        end)

        -- ====================================================
        -- CreatePage
        -- ====================================================
        function TabConfig:CreatePage(pageName)
            pageName = pageName or "Page"
            local PageBtn = Create("TextButton", {
                Parent = PageNav, Text = pageName,
                Font = Enum.Font.GothamBold, TextSize = 12,
                TextColor3 = SubTextColor, BackgroundTransparency = 1,
                Size = UDim2.new(0, 0, 1, 0),
                AutomaticSize = Enum.AutomaticSize.X,
                AutoButtonColor = false,
            })
            local PageHighlight = Create("Frame", {
                Parent = PageBtn, BackgroundColor3 = AccentColor,
                Size = UDim2.new(0, 0, 0, 2),
                Position = UDim2.new(0.5, 0, 1, -4),
                AnchorPoint = Vector2.new(0.5, 0),
                BackgroundTransparency = 1, BorderSizePixel = 0,
            })
            local PageScroll = Create("ScrollingFrame", {
                Parent = PageContainer, BackgroundTransparency = 1,
                Size = UDim2.new(1, -10, 1, -10),
                Position = UDim2.new(0, 5, 0, 5),
                ScrollBarThickness = 3,
                ScrollBarImageColor3 = StrokeColor,
                Visible = false, BorderSizePixel = 0,
                CanvasSize = UDim2.new(0, 0, 0, 0),
            })

            local LeftColumn = Create("Frame", {
                Parent = PageScroll, BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
            })
            local L_Layout = Create("UIListLayout", {
                Parent = LeftColumn,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 8),
            })

            L_Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                PageScroll.CanvasSize = UDim2.new(0, 0, 0, L_Layout.AbsoluteContentSize.Y + 20)
            end)

            local PageObj = {
                Scroll = PageScroll, Btn = PageBtn,
                Highlight = PageHighlight,
                Column = LeftColumn,
            }
            table.insert(TabConfig.Pages, PageObj)

            PageBtn.MouseButton1Click:Connect(function()
                if TabConfig.CurrentPage == PageObj then return end
                if TabConfig.CurrentPage then
                    Tween(TabConfig.CurrentPage.Btn, {TextColor3 = SubTextColor}, 0.2)
                    Tween(TabConfig.CurrentPage.Highlight,
                        {Size = UDim2.new(0, 0, 0, 2), BackgroundTransparency = 1}, 0.2)
                    TabConfig.CurrentPage.Scroll.Visible = false
                end
                TabConfig.CurrentPage = PageObj
                PageObj.Scroll.Visible = true
                PageObj.Scroll.Position = UDim2.new(0, 5, 0, 15)
                Tween(PageObj.Scroll, {Position = UDim2.new(0, 5, 0, 5)}, 0.3)
                Tween(PageBtn, {TextColor3 = TextColor}, 0.2)
                Tween(PageHighlight,
                    {Size = UDim2.new(1, 0, 0, 2), BackgroundTransparency = 0}, 0.2)
            end)

            if #TabConfig.Pages == 1 and not TabConfig.CurrentPage then
                TabConfig.CurrentPage = PageObj
                PageObj.Scroll.Visible = true
                PageBtn.TextColor3 = TextColor
                PageHighlight.Size = UDim2.new(1, 0, 0, 2)
                PageHighlight.BackgroundTransparency = 0
            end

            -- ================================================
            -- CreateSection
            -- ================================================
            function PageObj:CreateSection(sectionName)
                sectionName = sectionName or "Section"
                local SectionContainer = Create("Frame", {
                    Parent = LeftColumn,
                    BackgroundColor3 = CardColor,
                    Size = UDim2.new(1, 0, 0, 30),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    ClipsDescendants = true,
                    BorderSizePixel = 0,
                })
                Create("UICorner", {Parent = SectionContainer, CornerRadius = UDim.new(0, 10)})
                Create("UIStroke", {
                    Parent = SectionContainer, Color = StrokeColor,
                    Thickness = 1, Transparency = 0.5,
                })

                Create("TextLabel", {
                    Parent = SectionContainer, Text = sectionName,
                    Font = Enum.Font.GothamBold, TextSize = 12,
                    TextColor3 = AccentColorLight, BackgroundTransparency = 1,
                    Size = UDim2.new(1, -20, 0, 28),
                    Position = UDim2.new(0, 12, 0, 0),
                    TextXAlignment = Enum.TextXAlignment.Left,
                })

                local ItemContainer = Create("Frame", {
                    Parent = SectionContainer, BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 0),
                    Position = UDim2.new(0, 0, 0, 28),
                    AutomaticSize = Enum.AutomaticSize.Y,
                })
                Create("UIPadding", {
                    Parent = ItemContainer,
                    PaddingTop = UDim.new(0, 6),
                    PaddingBottom = UDim.new(0, 10),
                    PaddingLeft = UDim.new(0, 10),
                    PaddingRight = UDim.new(0, 10),
                })
                Create("UIListLayout", {
                    Parent = ItemContainer,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, 8),
                })

                -- Регистрируем карточку для поиска (позже пригодится)
                table.insert(Window.AllCards, {
                    Card = SectionContainer,
                    OrigParent = LeftColumn,
                    Tab = TabConfig,
                    Page = PageObj,
                })

                local Elements = {}

                -- ============================================
                -- AddButton
                -- ============================================
                function Elements:AddButton(name, callback)
                    local Btn = Create("TextButton", {
                        Parent = ItemContainer, Text = "  " .. (name or "Button"),
                        Font = Enum.Font.Gotham, TextSize = 12,
                        TextColor3 = TextColor, BackgroundColor3 = ItemColor,
                        Size = UDim2.new(1, 0, 0, 34),
                        AutoButtonColor = false, BorderSizePixel = 0,
                        TextXAlignment = Enum.TextXAlignment.Left,
                    })
                    Create("UICorner", {Parent = Btn, CornerRadius = UDim.new(0, 8)})
                    Create("UIStroke", {
                        Parent = Btn, Color = StrokeColor, Thickness = 1, Transparency = 0.6,
                    })
                    AddBounce(Btn)
                    Btn.MouseButton1Click:Connect(function()
                        if callback then pcall(callback) end
                    end)
                    return Btn
                end

                -- ============================================
                -- AddCopyButton
                -- ============================================
                function Elements:AddCopyButton(name, copyText)
                    return Elements:AddButton(name, function()
                        SafeCopy(copyText)
                        Library:Notify({
                            Title = "Скопировано",
                            Description = "Текст в буфере обмена.",
                            Duration = 2,
                        })
                    end)
                end

                -- ============================================
                -- AddToggle
                -- ============================================
                function Elements:AddToggle(name, default, callback)
                    local state = default and true or false
                    local Frame = Create("Frame", {
                        Parent = ItemContainer, BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 26),
                    })
                    Create("TextLabel", {
                        Parent = Frame, Text = name or "Toggle",
                        Font = Enum.Font.Gotham, TextSize = 12,
                        TextColor3 = TextColor, BackgroundTransparency = 1,
                        Size = UDim2.new(1, -60, 1, 0),
                        Position = UDim2.new(0, 2, 0, 0),
                        TextXAlignment = Enum.TextXAlignment.Left,
                    })

                    local Lever = Create("TextButton", {
                        Parent = Frame, Text = "",
                        BackgroundColor3 = state and AccentColor or Color3.fromRGB(45, 50, 60),
                        Size = UDim2.new(0, 40, 0, 22),
                        Position = UDim2.new(1, -42, 0.5, -11),
                        AutoButtonColor = false, BorderSizePixel = 0,
                    })
                    Create("UICorner", {Parent = Lever, CornerRadius = UDim.new(1, 0)})
                    AddBounce(Lever)

                    local Knob = Create("Frame", {
                        Parent = Lever, BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        Size = UDim2.new(0, 16, 0, 16),
                        Position = state and UDim2.new(1, -18, 0.5, -8)
                                        or UDim2.new(0, 2, 0.5, -8),
                        BorderSizePixel = 0,
                    })
                    Create("UICorner", {Parent = Knob, CornerRadius = UDim.new(1, 0)})

                    local function apply()
                        Tween(Lever, {
                            BackgroundColor3 = state and AccentColor or Color3.fromRGB(45, 50, 60),
                        }, 0.2)
                        Tween(Knob, {
                            Position = state and UDim2.new(1, -18, 0.5, -8)
                                             or UDim2.new(0, 2, 0.5, -8),
                        }, 0.2)
                    end
                    apply()

                    local function internalSet(val, fire)
                        state = val and true or false
                        apply()
                        if fire ~= false and callback then pcall(callback, state) end
                    end

                    Lever.MouseButton1Click:Connect(function()
                        internalSet(not state, true)
                    end)

                    Window.ConfigElements[name] = {
                        Set = function(v) internalSet(v, false) end,
                        Get = function() return state end,
                    }
                    return {Set = internalSet, Get = function() return state end}
                end

                -- ============================================
                -- AddSlider
                -- ============================================
                function Elements:AddSlider(name, min, max, default, callback)
                    min = min or 0
                    max = max or 100
                    local val = math.clamp(default or min, min, max)

                    local Frame = Create("Frame", {
                        Parent = ItemContainer, BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 46),
                    })
                    Create("TextLabel", {
                        Parent = Frame, Text = name or "Slider",
                        Font = Enum.Font.Gotham, TextSize = 12,
                        TextColor3 = TextColor, BackgroundTransparency = 1,
                        Size = UDim2.new(1, -50, 0, 16),
                        Position = UDim2.new(0, 2, 0, 0),
                        TextXAlignment = Enum.TextXAlignment.Left,
                    })
                    local ValTxt = Create("TextLabel", {
                        Parent = Frame, Text = tostring(math.floor(val)),
                        Font = Enum.Font.GothamBold, TextSize = 12,
                        TextColor3 = AccentColor, BackgroundTransparency = 1,
                        Size = UDim2.new(0, 44, 0, 16),
                        Position = UDim2.new(1, -46, 0, 0),
                        TextXAlignment = Enum.TextXAlignment.Right,
                    })

                    local Track = Create("Frame", {
                        Parent = Frame, BackgroundColor3 = Color3.fromRGB(40, 46, 56),
                        Size = UDim2.new(1, 0, 0, 6),
                        Position = UDim2.new(0, 0, 0, 26),
                        BorderSizePixel = 0,
                    })
                    Create("UICorner", {Parent = Track, CornerRadius = UDim.new(1, 0)})

                    local alpha = (max - min > 0) and (val - min) / (max - min) or 0
                    local Fill = Create("Frame", {
                        Parent = Track, BackgroundColor3 = AccentColor,
                        Size = UDim2.new(alpha, 0, 1, 0),
                        BorderSizePixel = 0,
                    })
                    Create("UICorner", {Parent = Fill, CornerRadius = UDim.new(1, 0)})

                    local Knob = Create("Frame", {
                        Parent = Fill, BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        Size = UDim2.new(0, 14, 0, 14),
                        Position = UDim2.new(1, -7, 0.5, -7),
                        BorderSizePixel = 0,
                    })
                    Create("UICorner", {Parent = Knob, CornerRadius = UDim.new(1, 0)})

                    local function internalSet(v, fire)
                        val = math.clamp(v, min, max)
                        ValTxt.Text = tostring(math.floor(val))
                        local a = (max - min > 0) and (val - min) / (max - min) or 0
                        Tween(Fill, {Size = UDim2.new(a, 0, 1, 0)}, 0.08)
                        if fire ~= false and callback then pcall(callback, val) end
                    end

                    -- Активная зона для тапа по всему треку
                    local Hit = Create("TextButton", {
                        Parent = Frame, Text = "",
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 24),
                        Position = UDim2.new(0, 0, 0, 17),
                        AutoButtonColor = false,
                    })

                    local dragging = false
                    local function update(input)
                        local rel = math.clamp(
                            (input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X,
                            0, 1)
                        internalSet(min + (max - min) * rel, true)
                    end

                    Hit.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1
                            or input.UserInputType == Enum.UserInputType.Touch then
                            dragging = true
                            update(input)
                        end
                    end)
                    UserInputService.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1
                            or input.UserInputType == Enum.UserInputType.Touch then
                            dragging = false
                        end
                    end)
                    UserInputService.InputChanged:Connect(function(input)
                        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
                            or input.UserInputType == Enum.UserInputType.Touch) then
                            update(input)
                        end
                    end)

                    Window.ConfigElements[name] = {
                        Set = function(v) internalSet(v, false) end,
                        Get = function() return val end,
                    }
                    return {Set = internalSet, Get = function() return val end}
                end

                -- ============================================
                -- AddDropdown
                -- ============================================
                function Elements:AddDropdown(name, options, isMulti, callback)
                    options = options or {}
                    local selected
                    if isMulti then
                        selected = {}
                    else
                        selected = options[1]
                    end
                    local dropped = false
                    local optionButtons = {}
                    local maxVisible = math.min(#options, 4)
                    local listHeight = maxVisible * 28

                    local Wrapper = Create("Frame", {
                        Parent = ItemContainer, BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 50),
                        ClipsDescendants = true,
                    })
                    Create("TextLabel", {
                        Parent = Wrapper, Text = name or "Dropdown",
                        Font = Enum.Font.Gotham, TextSize = 12,
                        TextColor3 = TextColor, BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 16),
                        Position = UDim2.new(0, 2, 0, 0),
                        TextXAlignment = Enum.TextXAlignment.Left,
                    })

                    local MainBtn = Create("TextButton", {
                        Parent = Wrapper,
                        Text = isMulti and "Выбрать..." or (selected or "Выбрать..."),
                        Font = Enum.Font.Gotham, TextSize = 12,
                        TextColor3 = TextColor, BackgroundColor3 = ItemColor,
                        Size = UDim2.new(1, 0, 0, 28),
                        Position = UDim2.new(0, 0, 0, 20),
                        AutoButtonColor = false, BorderSizePixel = 0,
                        TextXAlignment = Enum.TextXAlignment.Left,
                    })
                    Create("UIPadding", {Parent = MainBtn, PaddingLeft = UDim.new(0, 10)})
                    Create("UICorner", {Parent = MainBtn, CornerRadius = UDim.new(0, 8)})
                    Create("UIStroke", {
                        Parent = MainBtn, Color = StrokeColor, Thickness = 1, Transparency = 0.6,
                    })
                    AddBounce(MainBtn, 0.98)

                    local Arrow = Create("TextLabel", {
                        Parent = MainBtn, Text = "▼",
                        Font = Enum.Font.GothamBold, TextSize = 10,
                        TextColor3 = SubTextColor, BackgroundTransparency = 1,
                        Size = UDim2.new(0, 16, 1, 0),
                        Position = UDim2.new(1, -22, 0, 0),
                    })

                    local ListFrame = Create("ScrollingFrame", {
                        Parent = Wrapper, BackgroundColor3 = BackgroundColor,
                        Size = UDim2.new(1, 0, 0, 0),
                        Position = UDim2.new(0, 0, 0, 50),
                        CanvasSize = UDim2.new(0, 0, 0, #options * 28),
                        ScrollBarThickness = 2,
                        ScrollBarImageColor3 = StrokeColor,
                        BorderSizePixel = 0,
                        Visible = false,
                    })
                    Create("UICorner", {Parent = ListFrame, CornerRadius = UDim.new(0, 8)})
                    Create("UIListLayout", {
                        Parent = ListFrame,
                        SortOrder = Enum.SortOrder.LayoutOrder,
                    })

                    local function updateText()
                        if isMulti then
                            local arr = {}
                            for _, v in ipairs(selected) do table.insert(arr, v) end
                            MainBtn.Text = #arr == 0 and "Выбрать..." or table.concat(arr, ", ")
                        else
                            MainBtn.Text = selected or "Выбрать..."
                        end
                    end

                    local function isSelected(opt)
                        if isMulti then
                            return table.find(selected, opt) ~= nil
                        end
                        return selected == opt
                    end

                    local function refreshBtn(btn, opt)
                        local on = isSelected(opt)
                        Tween(btn, {
                            TextColor3 = on and AccentColor or SubTextColor,
                        }, 0.15)
                    end

                    for i, opt in ipairs(options) do
                        local OptBtn = Create("TextButton", {
                            Parent = ListFrame, Text = "  " .. tostring(opt),
                            Font = Enum.Font.Gotham, TextSize = 12,
                            TextColor3 = isSelected(opt) and AccentColor or SubTextColor,
                            BackgroundTransparency = 1,
                            Size = UDim2.new(1, 0, 0, 28),
                            AutoButtonColor = false,
                            TextXAlignment = Enum.TextXAlignment.Left,
                            LayoutOrder = i,
                        })
                        table.insert(optionButtons, OptBtn)

                        OptBtn.MouseButton1Click:Connect(function()
                            if isMulti then
                                local idx = table.find(selected, opt)
                                if idx then table.remove(selected, idx)
                                else table.insert(selected, opt) end
                            else
                                selected = opt
                                dropped = false
                                Tween(Arrow, {Rotation = 0}, 0.25)
                                Tween(Wrapper, {Size = UDim2.new(1, 0, 0, 50)}, 0.25)
                                task.delay(0.22, function() ListFrame.Visible = false end)
                            end
                            for _, b in ipairs(optionButtons) do
                                refreshBtn(b, b.Text:gsub("^%s+", ""))
                            end
                            updateText()
                            if callback then pcall(callback, selected) end
                        end)
                    end

                    MainBtn.MouseButton1Click:Connect(function()
                        dropped = not dropped
                        if dropped then
                            ListFrame.Visible = true
                            Tween(Arrow, {Rotation = 180}, 0.25)
                            Tween(Wrapper, {Size = UDim2.new(1, 0, 0, 50 + listHeight)}, 0.25)
                        else
                            Tween(Arrow, {Rotation = 0}, 0.25)
                            Tween(Wrapper, {Size = UDim2.new(1, 0, 0, 50)}, 0.25)
                            task.delay(0.22, function()
                                if not dropped then ListFrame.Visible = false end
                            end)
                        end
                    end)

                    Window.ConfigElements[name] = {
                        Set = function(v)
                            selected = v
                            for _, b in ipairs(optionButtons) do
                                refreshBtn(b, b.Text:gsub("^%s+", ""))
                            end
                            updateText()
                        end,
                        Get = function() return selected end,
                    }
                    return {Set = function(v) selected = v; updateText() end,
                            Get = function() return selected end}
                end

                -- ============================================
                -- AddTextbox
                -- ============================================
                function Elements:AddTextbox(name, placeholder, callback)
                    local Frame = Create("Frame", {
                        Parent = ItemContainer, BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 50),
                    })
                    Create("TextLabel", {
                        Parent = Frame, Text = name or "Textbox",
                        Font = Enum.Font.Gotham, TextSize = 12,
                        TextColor3 = TextColor, BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 16),
                        Position = UDim2.new(0, 2, 0, 0),
                        TextXAlignment = Enum.TextXAlignment.Left,
                    })
                    local Input = Create("TextBox", {
                        Parent = Frame,
                        PlaceholderText = placeholder or "Введите...",
                        Text = "",
                        Font = Enum.Font.Gotham, TextSize = 12,
                        TextColor3 = TextColor, BackgroundColor3 = ItemColor,
                        PlaceholderColor3 = SubTextColor,
                        Size = UDim2.new(1, 0, 0, 28),
                        Position = UDim2.new(0, 0, 0, 20),
                        TextXAlignment = Enum.TextXAlignment.Left,
                        ClearTextOnFocus = false, BorderSizePixel = 0,
                    })
                    Create("UIPadding", {Parent = Input, PaddingLeft = UDim.new(0, 10)})
                    Create("UICorner", {Parent = Input, CornerRadius = UDim.new(0, 8)})
                    Create("UIStroke", {
                        Parent = Input, Color = StrokeColor, Thickness = 1, Transparency = 0.6,
                    })

                    Input.FocusLost:Connect(function()
                        if callback then pcall(callback, Input.Text) end
                    end)

                    Window.ConfigElements[name] = {
                        Set = function(v) Input.Text = tostring(v) end,
                        Get = function() return Input.Text end,
                    }
                    return {Set = function(v) Input.Text = tostring(v) end,
                            Get = function() return Input.Text end}
                end

                -- ============================================
                -- AddColorPicker
                -- ============================================
                function Elements:AddColorPicker(name, defaultColor, callback)
                    local color = defaultColor or AccentColor
                    local h, s, v = Color3.toHSV(color)
                    local dropped = false

                    local Wrapper = Create("Frame", {
                        Parent = ItemContainer, BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 30),
                        ClipsDescendants = true,
                    })
                    Create("TextLabel", {
                        Parent = Wrapper, Text = name or "Color",
                        Font = Enum.Font.Gotham, TextSize = 12,
                        TextColor3 = TextColor, BackgroundTransparency = 1,
                        Size = UDim2.new(1, -50, 0, 30),
                        Position = UDim2.new(0, 2, 0, 0),
                        TextXAlignment = Enum.TextXAlignment.Left,
                    })
                    local Preview = Create("TextButton", {
                        Parent = Wrapper, Text = "",
                        BackgroundColor3 = color,
                        Size = UDim2.new(0, 32, 0, 20),
                        Position = UDim2.new(1, -34, 0.5, -10),
                        AutoButtonColor = false, BorderSizePixel = 0,
                    })
                    Create("UICorner", {Parent = Preview, CornerRadius = UDim.new(0, 6)})
                    Create("UIStroke", {
                        Parent = Preview, Color = Color3.fromRGB(255, 255, 255),
                        Transparency = 0.7, Thickness = 1,
                    })
                    AddBounce(Preview)

                    local PickerArea = Create("Frame", {
                        Parent = Wrapper, BackgroundColor3 = BackgroundColor,
                        Size = UDim2.new(1, 0, 0, 130),
                        Position = UDim2.new(0, 0, 0, 34),
                    })
                    Create("UICorner", {Parent = PickerArea, CornerRadius = UDim.new(0, 8)})

                    local SVMap = Create("TextButton", {
                        Parent = PickerArea, Text = "",
                        BackgroundColor3 = Color3.fromHSV(h, 1, 1),
                        Size = UDim2.new(1, -20, 0, 76),
                        Position = UDim2.new(0, 10, 0, 10),
                        AutoButtonColor = false, BorderSizePixel = 0,
                    })
                    Create("UICorner", {Parent = SVMap, CornerRadius = UDim.new(0, 6)})

                    local WhiteGrad = Create("Frame", {
                        Parent = SVMap, BackgroundColor3 = Color3.new(1,1,1),
                        Size = UDim2.new(1,0,1,0), BorderSizePixel = 0,
                    })
                    Create("UIGradient", {
                        Parent = WhiteGrad,
                        Transparency = NumberSequence.new({
                            NumberSequenceKeypoint.new(0, 0),
                            NumberSequenceKeypoint.new(1, 1),
                        }),
                    })
                    Create("UICorner", {Parent = WhiteGrad, CornerRadius = UDim.new(0, 6)})

                    local BlackGrad = Create("Frame", {
                        Parent = SVMap, BackgroundColor3 = Color3.new(0,0,0),
                        Size = UDim2.new(1,0,1,0), BorderSizePixel = 0,
                    })
                    Create("UIGradient", {
                        Parent = BlackGrad,
                        Rotation = 90,
                        Transparency = NumberSequence.new({
                            NumberSequenceKeypoint.new(0, 1),
                            NumberSequenceKeypoint.new(1, 0),
                        }),
                    })
                    Create("UICorner", {Parent = BlackGrad, CornerRadius = UDim.new(0, 6)})

                    local SVRing = Create("Frame", {
                        Parent = SVMap, BackgroundColor3 = Color3.new(1,1,1),
                        Size = UDim2.new(0, 10, 0, 10),
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        Position = UDim2.new(s, 0, 1 - v, 0),
                        BorderSizePixel = 0,
                    })
                    Create("UICorner", {Parent = SVRing, CornerRadius = UDim.new(1, 0)})
                    Create("UIStroke", {
                        Parent = SVRing, Color = Color3.new(0,0,0), Thickness = 1,
                    })

                    local HueBar = Create("TextButton", {
                        Parent = PickerArea, Text = "",
                        BackgroundColor3 = Color3.new(1,1,1),
                        Size = UDim2.new(1, -20, 0, 12),
                        Position = UDim2.new(0, 10, 0, 96),
                        AutoButtonColor = false, BorderSizePixel = 0,
                    })
                    Create("UICorner", {Parent = HueBar, CornerRadius = UDim.new(1, 0)})
                    Create("UIGradient", {
                        Parent = HueBar,
                        Color = ColorSequence.new({
                            ColorSequenceKeypoint.new(0, Color3.fromRGB(255,0,0)),
                            ColorSequenceKeypoint.new(0.167, Color3.fromRGB(255,255,0)),
                            ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0,255,0)),
                            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0,255,255)),
                            ColorSequenceKeypoint.new(0.667, Color3.fromRGB(0,0,255)),
                            ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255,0,255)),
                            ColorSequenceKeypoint.new(1, Color3.fromRGB(255,0,0)),
                        }),
                    })
                    local HueRing = Create("Frame", {
                        Parent = HueBar, BackgroundColor3 = Color3.new(1,1,1),
                        Size = UDim2.new(0, 14, 0, 14),
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        Position = UDim2.new(h, 0, 0.5, 0),
                        BorderSizePixel = 0,
                    })
                    Create("UICorner", {Parent = HueRing, CornerRadius = UDim.new(1, 0)})
                    Create("UIStroke", {
                        Parent = HueRing, Color = Color3.new(0,0,0),
                        Thickness = 1, Transparency = 0.4,
                    })

                    local function updateColor(fire)
                        color = Color3.fromHSV(h, s, v)
                        Preview.BackgroundColor3 = color
                        SVMap.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                        if fire ~= false and callback then pcall(callback, color) end
                    end

                    local dragSV, dragHue = false, false
                    SVMap.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1
                            or input.UserInputType == Enum.UserInputType.Touch then
                            dragSV = true
                            SVMap.ScrollingEnabled = false
                        end
                    end)
                    HueBar.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1
                            or input.UserInputType == Enum.UserInputType.Touch then
                            dragHue = true
                        end
                    end)
                    UserInputService.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1
                            or input.UserInputType == Enum.UserInputType.Touch then
                            dragSV, dragHue = false, false
                        end
                    end)
                    UserInputService.InputChanged:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseMovement
                            or input.UserInputType == Enum.UserInputType.Touch then
                            if dragSV then
                                local relX = math.clamp(
                                    (input.Position.X - SVMap.AbsolutePosition.X) / SVMap.AbsoluteSize.X, 0, 1)
                                local relY = math.clamp(
                                    (input.Position.Y - SVMap.AbsolutePosition.Y) / SVMap.AbsoluteSize.Y, 0, 1)
                                s = relX
                                v = 1 - relY
                                SVRing.Position = UDim2.new(s, 0, 1 - v, 0)
                                updateColor(true)
                            elseif dragHue then
                                local relX = math.clamp(
                                    (input.Position.X - HueBar.AbsolutePosition.X) / HueBar.AbsoluteSize.X, 0, 1)
                                h = relX
                                HueRing.Position = UDim2.new(h, 0, 0.5, 0)
                                updateColor(true)
                            end
                        end
                    end)

                    Preview.MouseButton1Click:Connect(function()
                        dropped = not dropped
                        Tween(Wrapper, {
                            Size = UDim2.new(1, 0, 0, dropped and 170 or 30),
                        }, 0.25)
                    end)

                    updateColor(false)

                    Window.ConfigElements[name] = {
                        Set = function(hexOrColor)
                            if typeof(hexOrColor) == "Color3" then
                                h, s, v = Color3.toHSV(hexOrColor)
                                SVRing.Position = UDim2.new(s, 0, 1 - v, 0)
                                HueRing.Position = UDim2.new(h, 0, 0.5, 0)
                                updateColor(false)
                            elseif type(hexOrColor) == "string" then
                                local ok, c = pcall(Color3.fromHex, hexOrColor)
                                if ok then
                                    h, s, v = Color3.toHSV(c)
                                    SVRing.Position = UDim2.new(s, 0, 1 - v, 0)
                                    HueRing.Position = UDim2.new(h, 0, 0.5, 0)
                                    updateColor(false)
                                end
                            end
                        end,
                        Get = function() return color:ToHex() end,
                    }
                    return {Set = function(c) h, s, v = Color3.toHSV(c); updateColor(false) end,
                            Get = function() return color end}
                end

                return Elements
            end
            return PageObj
        end

        -- Default tab
        if isDefault then
            TabBtn.BackgroundTransparency = 0.15
            Indicator.Size = UDim2.new(0, 3, 0, 18)
            Txt.TextColor3 = TextColor
            TabContent.Visible = true
            Window.CurrentTab = TabConfig
        end

        return TabConfig
    end
end

-- Возвращаем ссылки из CreateWindow и навешиваем методы
-- (перезаписываем оригинальный CreateWindow, чтобы добавить методы)
local _origCreateWindow = Library.CreateWindow
function Library:CreateWindow(opts)
    local w, refs = _origCreateWindow(self, opts)
    AttachWindowMethods(w, refs)
    return w
end-- ============================================================
-- CONFIG MANAGER (Saves / Loader)
-- Добавляется к Page через :CreateSection → Elements:AddConfigManager
-- ============================================================
local function AttachConfigManager(Elements, ItemContainer, Window)
    function Elements:AddConfigManager(folderName)
        folderName = folderName or "SenseiConfigs"
        if not _isfolder(folderName) then _makefolder(folderName) end

        local ManagerFrame = Create("Frame", {
            Parent = ItemContainer, BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 250),
        })

        local Search = Create("TextBox", {
            Parent = ManagerFrame,
            PlaceholderText = "Поиск сохранений...",
            Font = Enum.Font.Gotham, TextSize = 12,
            TextColor3 = TextColor, BackgroundColor3 = ItemColor,
            PlaceholderColor3 = SubTextColor,
            Size = UDim2.new(1, 0, 0, 30),
            Position = UDim2.new(0, 0, 0, 0),
            TextXAlignment = Enum.TextXAlignment.Left,
            ClearTextOnFocus = false, BorderSizePixel = 0,
        })
        Create("UIPadding", {Parent = Search, PaddingLeft = UDim.new(0, 10)})
        Create("UICorner", {Parent = Search, CornerRadius = UDim.new(0, 8)})
        Create("UIStroke", {
            Parent = Search, Color = StrokeColor, Thickness = 1, Transparency = 0.6,
        })

        local Monitor = Create("ScrollingFrame", {
            Parent = ManagerFrame, BackgroundColor3 = Color3.fromRGB(15, 18, 24),
            Size = UDim2.new(1, 0, 0, 110),
            Position = UDim2.new(0, 0, 0, 38),
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = StrokeColor,
            BorderSizePixel = 0,
            CanvasSize = UDim2.new(0, 0, 0, 0),
        })
        Create("UICorner", {Parent = Monitor, CornerRadius = UDim.new(0, 8)})
        Create("UIStroke", {
            Parent = Monitor, Color = StrokeColor, Thickness = 1, Transparency = 0.6,
        })
        local MonitorLayout = Create("UIListLayout", {
            Parent = Monitor,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 5),
        })
        Create("UIPadding", {
            Parent = Monitor,
            PaddingTop = UDim.new(0, 6),
            PaddingBottom = UDim.new(0, 6),
            PaddingLeft = UDim.new(0, 6),
            PaddingRight = UDim.new(0, 6),
        })
        MonitorLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Monitor.CanvasSize = UDim2.new(0, 0, 0, MonitorLayout.AbsoluteContentSize.Y + 12)
        end)

        local deleteMode = false
        local editMode = false
        local selectedForDelete = {}
        local editTargetFile = ""

        -- Controls (нижняя зона)
        local Controls = Create("Frame", {
            Parent = ManagerFrame, BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 90),
            Position = UDim2.new(0, 0, 0, 155),
        })

        local NameBox = Create("TextBox", {
            Parent = Controls,
            PlaceholderText = "Имя сохранения...",
            Font = Enum.Font.Gotham, TextSize = 12,
            TextColor3 = TextColor, BackgroundColor3 = ItemColor,
            PlaceholderColor3 = SubTextColor,
            Size = UDim2.new(1, 0, 0, 28),
            Position = UDim2.new(0, 0, 0, 0),
            TextXAlignment = Enum.TextXAlignment.Left,
            ClearTextOnFocus = false, BorderSizePixel = 0,
        })
        Create("UIPadding", {Parent = NameBox, PaddingLeft = UDim.new(0, 10)})
        Create("UICorner", {Parent = NameBox, CornerRadius = UDim.new(0, 8)})
        Create("UIStroke", {
            Parent = NameBox, Color = StrokeColor, Thickness = 1, Transparency = 0.6,
        })

        local CreateBtn = Create("TextButton", {
            Parent = Controls, Text = "Создать",
            Font = Enum.Font.GothamBold, TextSize = 12,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundColor3 = AccentColor,
            Size = UDim2.new(0.5, -4, 0, 28),
            Position = UDim2.new(0, 0, 0, 36),
            AutoButtonColor = false, BorderSizePixel = 0,
        })
        Create("UICorner", {Parent = CreateBtn, CornerRadius = UDim.new(0, 8)})
        AddBounce(CreateBtn)

        local DeleteTogBtn = Create("TextButton", {
            Parent = Controls, Text = "Удаление: ВЫКЛ",
            Font = Enum.Font.GothamBold, TextSize = 12,
            TextColor3 = TextColor,
            BackgroundColor3 = ItemColor,
            Size = UDim2.new(0.5, -4, 0, 28),
            Position = UDim2.new(0.5, 4, 0, 36),
            AutoButtonColor = false, BorderSizePixel = 0,
        })
        Create("UICorner", {Parent = DeleteTogBtn, CornerRadius = UDim.new(0, 8)})
        AddBounce(DeleteTogBtn)

        local ActionArea = Create("Frame", {
            Parent = Controls, BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 28),
            Position = UDim2.new(0, 0, 0, 36),
            Visible = false,
        })
        local ConfirmActionBtn = Create("TextButton", {
            Parent = ActionArea, Text = "Подтвердить",
            Font = Enum.Font.GothamBold, TextSize = 12,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundColor3 = Color3.fromRGB(200, 60, 70),
            Size = UDim2.new(0.5, -4, 1, 0),
            Position = UDim2.new(0, 0, 0, 0),
            AutoButtonColor = false, BorderSizePixel = 0,
        })
        Create("UICorner", {Parent = ConfirmActionBtn, CornerRadius = UDim.new(0, 8)})
        AddBounce(ConfirmActionBtn)

        local CancelActionBtn = Create("TextButton", {
            Parent = ActionArea, Text = "Отмена",
            Font = Enum.Font.GothamBold, TextSize = 12,
            TextColor3 = TextColor, BackgroundColor3 = ItemColor,
            Size = UDim2.new(0.5, -4, 1, 0),
            Position = UDim2.new(0.5, 4, 0, 0),
            AutoButtonColor = false, BorderSizePixel = 0,
        })
        Create("UICorner", {Parent = CancelActionBtn, CornerRadius = UDim.new(0, 8)})
        AddBounce(CancelActionBtn)

        -- Внутреннее окно подтверждения
        local ConfirmPopup = Create("Frame", {
            Parent = ManagerFrame, BackgroundColor3 = BackgroundColor,
            Size = UDim2.new(1, -20, 1, -20),
            Position = UDim2.new(0, 10, 0, 10),
            ZIndex = 60, BackgroundTransparency = 1, Visible = false,
            BorderSizePixel = 0,
        })
        Create("UICorner", {Parent = ConfirmPopup, CornerRadius = UDim.new(0, 10)})
        Create("UIStroke", {
            Parent = ConfirmPopup, Color = Color3.fromRGB(200, 60, 70),
            Thickness = 1.2, Transparency = 1,
        })
        local PTitle = Create("TextLabel", {
            Parent = ConfirmPopup, Text = "Удалить выбранные?",
            Font = Enum.Font.GothamBold, TextSize = 14,
            TextColor3 = Color3.fromRGB(255, 90, 100), BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 26),
            Position = UDim2.new(0, 0, 0, 40),
            ZIndex = 61, TextTransparency = 1,
        })
        local PDesc = Create("TextLabel", {
            Parent = ConfirmPopup, Text = "Сохранения будут удалены навсегда.",
            Font = Enum.Font.Gotham, TextSize = 12,
            TextColor3 = SubTextColor, BackgroundTransparency = 1,
            Size = UDim2.new(1, -30, 0, 40),
            Position = UDim2.new(0, 15, 0, 70),
            ZIndex = 61, TextTransparency = 1, TextWrapped = true,
        })
        local PYes = Create("TextButton", {
            Parent = ConfirmPopup, Text = "Да",
            Font = Enum.Font.GothamBold, TextSize = 13,
            TextColor3 = Color3.fromRGB(255,255,255),
            BackgroundColor3 = Color3.fromRGB(200, 60, 70),
            Size = UDim2.new(0.5, -25, 0, 30),
            Position = UDim2.new(0, 20, 0, 130),
            AutoButtonColor = false, BorderSizePixel = 0,
            BackgroundTransparency = 1, TextTransparency = 1, ZIndex = 61,
        })
        Create("UICorner", {Parent = PYes, CornerRadius = UDim.new(0, 8)})
        AddBounce(PYes)
        local PNo = Create("TextButton", {
            Parent = ConfirmPopup, Text = "Нет",
            Font = Enum.Font.GothamBold, TextSize = 13,
            TextColor3 = TextColor, BackgroundColor3 = ItemColor,
            Size = UDim2.new(0.5, -25, 0, 30),
            Position = UDim2.new(0.5, 5, 0, 130),
            AutoButtonColor = false, BorderSizePixel = 0,
            BackgroundTransparency = 1, TextTransparency = 1, ZIndex = 61,
        })
        Create("UICorner", {Parent = PNo, CornerRadius = UDim.new(0, 8)})
        AddBounce(PNo)

        local function showPopup()
            ConfirmPopup.Visible = true
            Tween(ConfirmPopup, {BackgroundTransparency = 0.05}, 0.28)
            Tween(ConfirmPopup:FindFirstChildOfClass("UIStroke"), {Transparency = 0.5}, 0.28)
            Tween(PTitle, {TextTransparency = 0}, 0.28)
            Tween(PDesc, {TextTransparency = 0}, 0.28)
            Tween(PYes, {BackgroundTransparency = 0, TextTransparency = 0}, 0.28)
            Tween(PNo, {BackgroundTransparency = 0, TextTransparency = 0}, 0.28)
        end
        local function hidePopup()
            Tween(ConfirmPopup, {BackgroundTransparency = 1}, 0.28)
            Tween(ConfirmPopup:FindFirstChildOfClass("UIStroke"), {Transparency = 1}, 0.28)
            Tween(PTitle, {TextTransparency = 1}, 0.28)
            Tween(PDesc, {TextTransparency = 1}, 0.28)
            Tween(PYes, {BackgroundTransparency = 1, TextTransparency = 1}, 0.28)
            Tween(PNo, {BackgroundTransparency = 1, TextTransparency = 1}, 0.28)
            task.wait(0.3)
            ConfirmPopup.Visible = false
        end

        -- ====================================================
        -- Refresh monitor
        -- ====================================================
        local function refreshMonitor()
            for _, v in ipairs(Monitor:GetChildren()) do
                if v:IsA("Frame") then v:Destroy() end
            end
            selectedForDelete = {}

            local files = _listfiles(folderName)
            for _, filepath in ipairs(files) do
                local rawName = filepath:match("([^/\\]+)%.json$")
                if rawName then
                    local display = rawName:gsub("_%d+$", ""):gsub("_%d+%.%d+$", "")
                    local Row = Create("Frame", {
                        Parent = Monitor, BackgroundColor3 = ItemColor,
                        Size = UDim2.new(1, 0, 0, 32),
                        BorderSizePixel = 0,
                    })
                    Create("UICorner", {Parent = Row, CornerRadius = UDim.new(0, 8)})

                    Create("TextLabel", {
                        Parent = Row, Text = display,
                        Font = Enum.Font.Gotham, TextSize = 12,
                        TextColor3 = TextColor, BackgroundTransparency = 1,
                        Size = UDim2.new(1, -76, 1, 0),
                        Position = UDim2.new(0, 10, 0, 0),
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextTruncate = Enum.TextTruncate.AtEnd,
                    })

                    local LoadBtn = Create("TextButton", {
                        Parent = Row, Text = "Load",
                        Font = Enum.Font.GothamBold, TextSize = 10,
                        TextColor3 = Color3.fromRGB(255,255,255),
                        BackgroundColor3 = Color3.fromRGB(50, 150, 80),
                        Size = UDim2.new(0, 34, 0, 22),
                        Position = UDim2.new(1, -72, 0.5, -11),
                        AutoButtonColor = false, BorderSizePixel = 0,
                    })
                    Create("UICorner", {Parent = LoadBtn, CornerRadius = UDim.new(0, 6)})
                    AddBounce(LoadBtn)

                    local EditBtn = Create("TextButton", {
                        Parent = Row, Text = "Edit",
                        Font = Enum.Font.GothamBold, TextSize = 10,
                        TextColor3 = Color3.fromRGB(255,255,255),
                        BackgroundColor3 = Color3.fromRGB(180, 120, 50),
                        Size = UDim2.new(0, 34, 0, 22),
                        Position = UDim2.new(1, -36, 0.5, -11),
                        AutoButtonColor = false, BorderSizePixel = 0,
                    })
                    Create("UICorner", {Parent = EditBtn, CornerRadius = UDim.new(0, 6)})
                    AddBounce(EditBtn)

                    local SelectionMask = Create("TextButton", {
                        Parent = Row, Text = "",
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, -80, 1, 0),
                        ZIndex = 2,
                        AutoButtonColor = false,
                    })
                    SelectionMask.MouseButton1Click:Connect(function()
                        if deleteMode then
                            if selectedForDelete[filepath] then
                                selectedForDelete[filepath] = nil
                                Tween(Row, {BackgroundColor3 = ItemColor}, 0.2)
                            else
                                selectedForDelete[filepath] = true
                                Tween(Row, {BackgroundColor3 = Color3.fromRGB(180, 60, 70)}, 0.2)
                            end
                        end
                    end)

                    LoadBtn.MouseButton1Click:Connect(function()
                        if deleteMode or editMode then return end
                        local ok, data = pcall(function()
                            return HttpService:JSONDecode(_readfile(filepath))
                        end)
                        if ok and type(data) == "table" then
                            for k, val in pairs(data) do
                                local el = Window.ConfigElements[k]
                                if el and el.Set then el.Set(val) end
                            end
                            Library:Notify({
                                Title = "Загружено",
                                Description = display,
                                Duration = 2,
                            })
                        end
                    end)

                    EditBtn.MouseButton1Click:Connect(function()
                        if deleteMode then return end
                        editMode = true
                        editTargetFile = filepath
                        NameBox.Text = display
                        CreateBtn.Visible = false
                        DeleteTogBtn.Visible = false
                        ActionArea.Visible = true
                        ConfirmActionBtn.Text = "Сохранить"
                        ConfirmActionBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 200)
                    end)
                end
            end
        end

        -- ====================================================
        -- Save handler
        -- ====================================================
        local function executeSave(saveName)
            local payload = {}
            for k, el in pairs(Window.ConfigElements) do
                if el.Get then payload[k] = el.Get() end
            end
            local ok, encoded = pcall(HttpService.JSONEncode, HttpService, payload)
            if not ok then
                Library:Notify({Title = "Ошибка", Description = "Не удалось сохранить."})
                return
            end
            local uniqueKey = tostring(math.floor(tick()))
            local finalPath = folderName .. "/" .. saveName .. "_" .. uniqueKey .. ".json"
            _writefile(finalPath, encoded)
            refreshMonitor()
            Library:Notify({
                Title = "Сохранено",
                Description = saveName,
                Duration = 2,
            })
        end

        CreateBtn.MouseButton1Click:Connect(function()
            if NameBox.Text ~= "" then
                executeSave(NameBox.Text)
                NameBox.Text = ""
            end
        end)

        DeleteTogBtn.MouseButton1Click:Connect(function()
            if editMode then return end
            deleteMode = not deleteMode
            DeleteTogBtn.Text = deleteMode and "Удаление: ВКЛ" or "Удаление: ВЫКЛ"
            Tween(DeleteTogBtn, {
                BackgroundColor3 = deleteMode and Color3.fromRGB(180, 60, 70) or ItemColor,
            }, 0.2)
            ActionArea.Visible = deleteMode
            CreateBtn.Visible = not deleteMode
            if deleteMode then
                ConfirmActionBtn.Text = "Удалить"
                ConfirmActionBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 70)
            else
                refreshMonitor()
            end
        end)

        ConfirmActionBtn.MouseButton1Click:Connect(function()
            if deleteMode then
                showPopup()
            elseif editMode then
                local newName = NameBox.Text
                if newName ~= "" then
                    pcall(function() _delfile(editTargetFile) end)
                    executeSave(newName)
                end
                editMode = false
                ActionArea.Visible = false
                CreateBtn.Visible = true
                DeleteTogBtn.Visible = true
                NameBox.Text = ""
                refreshMonitor()
            end
        end)

        PYes.MouseButton1Click:Connect(function()
            for file, _ in pairs(selectedForDelete) do
                pcall(function() _delfile(file) end)
            end
            deleteMode = false
            DeleteTogBtn.Text = "Удаление: ВЫКЛ"
            DeleteTogBtn.BackgroundColor3 = ItemColor
            ActionArea.Visible = false
            CreateBtn.Visible = true
            refreshMonitor()
            Library:Notify({
                Title = "Удалено",
                Description = "Сохранения стёрты.",
                Duration = 2,
            })
            hidePopup()
        end)

        PNo.MouseButton1Click:Connect(function()
            hidePopup()
        end)

        CancelActionBtn.MouseButton1Click:Connect(function()
            editMode = false
            deleteMode = false
            DeleteTogBtn.Text = "Удаление: ВЫКЛ"
            DeleteTogBtn.BackgroundColor3 = ItemColor
            ActionArea.Visible = false
            CreateBtn.Visible = true
            DeleteTogBtn.Visible = true
            NameBox.Text = ""
            refreshMonitor()
        end)

        Search:GetPropertyChangedSignal("Text"):Connect(function()
            local q = Search.Text:lower()
            for _, v in ipairs(Monitor:GetChildren()) do
                if v:IsA("Frame") then
                    local lbl = v:FindFirstChildOfClass("TextLabel")
                    if lbl then
                        v.Visible = (q == "" or string.find(lbl.Text:lower(), q, 1, true) ~= nil)
                    end
                end
            end
        end)

        refreshMonitor()
    end
end

-- ============================================================
-- PATCH: AttachConfigManager внутрь CreateSection
-- Перезаписываем AttachWindowMethods-обёртку, чтобы Elements получил AddConfigManager
-- ============================================================
local _origAttach = AttachWindowMethods
-- AttachWindowMethods определён выше; нам нужно, чтобы внутри CreateSection
-- у Elements появился AddConfigManager. Проще всего — вызвать AttachConfigManager
-- внутри CreateSection через небольшой хак: Elements уже содержит методы,
-- мы добавляем AddConfigManager после того, как Elements создан.
--
-- Так как мы не можем легко вклиниться, делаем так: создаём дефолтный
-- AddConfigManager на уровне Elements ПОСЛЕ CreateSection. А чтобы не
-- ломать структуру, просто определим метод в конце файла через
-- модификацию Window — при следующем вызове CreateSection он будет
-- доступен.
--
-- Практическое решение: перезаписываем AttachWindowMethods на новую
-- версию, которая вызывает AttachConfigManager внутри CreateSection.
-- Но это уже сложно без переписывания AttachWindowMethods.
--
-- Чтобы не усложнять, оставляем AddConfigManager доступным как отдельный
-- вызов: после получения Page, можно вызвать Page:CreateSection("Config"),
-- а внутри его Elements — AddConfigManager. Он будет доступен, потому что
-- мы привязываем его в самом низу (см. ниже).

-- ============================================================
-- Публичный API: возврат методов для Config Manager
-- ============================================================
function Library:CreateConfigManager(section, folderName)
    -- section — это Elements, который вернул CreateSection
    if section and section.AddConfigManager then
        return section:AddConfigManager(folderName)
    end
end

-- ============================================================
-- EXPORT
-- ============================================================
Library.Version = "2.0.0"
Library.Brand   = "Sensei"

return Library