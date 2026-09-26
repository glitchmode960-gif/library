--[[
    Sensei UI Library — ZX v5.0
    Author: CreativeGPT & Douwe
    Version: 5.0.0
    Style: Blue Neon, mobile, Delta-minibar
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
    WhitelistedUsers = {},
    Version = "5.0.0",
    Brand   = "Sensei",
}

-- ============================================================
-- File System (safe)
-- ============================================================
local _isfolder   = isfolder   or function() return true end
local _makefolder = makefolder or function() end
local _writefile  = writefile  or function() end
local _readfile   = readfile   or function() return "{}" end
local _listfiles  = listfiles  or function() return {} end
local _delfile    = delfile    or function() end

local function SafeCopy(text)
    if setclipboard then setclipboard(text)
    elseif toclipboard then toclipboard(text)
    else warn("[Sensei] Clipboard not supported.") end
end

-- ============================================================
-- ICONS (Material Icons от Roblox)
-- ============================================================
local ICONS = {
    Minimize  = "rbxassetid://6031091004",   -- минус
    Close     = "rbxassetid://6031090990",   -- X
    Expand    = "rbxassetid://6031094667",   -- стрелка развернуть
    Settings  = "rbxassetid://6031280882",   -- шестерёнка
    User      = "rbxassetid://6031075937",   -- человечек
    Copy      = "rbxassetid://6031154871",   -- копировать
    Lock      = "rbxassetid://6031082533",   -- замок
    Check     = "rbxassetid://6031091004",   -- галочка
    Warning   = "rbxassetid://6031280882",   -- восклицание
    Info      = "rbxassetid://6031075937",   -- инфо
    Delete    = "rbxassetid://6031090990",   -- мусорка
    Save      = "rbxassetid://6031280882",   -- дискета
    Load      = "rbxassetid://6031094667",   -- стрелка
    Edit      = "rbxassetid://6031280882",   -- карандаш
}

-- ============================================================
-- Palette (Blue Neon)
-- ============================================================
local AccentColor      = Color3.fromRGB(0, 170, 255)
local AccentColorLight = Color3.fromRGB(120, 220, 255)
local BackgroundColor  = Color3.fromRGB(15, 18, 24)
local CardColor        = Color3.fromRGB(24, 28, 36)
local ItemColor        = Color3.fromRGB(34, 40, 50)
local HoverColor       = Color3.fromRGB(44, 52, 64)
local TextColor        = Color3.fromRGB(240, 245, 252)
local SubTextColor     = Color3.fromRGB(150, 165, 185)
local StrokeColor      = Color3.fromRGB(45, 65, 100)
local DangerColor      = Color3.fromRGB(200, 60, 70)
local SuccessColor     = Color3.fromRGB(50, 160, 90)
local WarningColor     = Color3.fromRGB(255, 190, 70)

-- ============================================================
-- Create Instance
-- ============================================================
local function Create(className, props)
    local inst = Instance.new(className)
    if className == "TextBox" then inst.Text = "" end
    for k, v in pairs(props or {}) do inst[k] = v end
    if className == "TextLabel" or className == "TextButton" or className == "TextBox" then
        if not (props and props.TextColor3) then inst.TextColor3 = TextColor end
        inst.TextTransparency = 0
    end
    return inst
end

-- ============================================================
-- Tween
-- ============================================================
local function Tween(instance, properties, duration)
    duration = duration or 0.25
    local info = TweenInfo.new(duration, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    local tw = TweenService:Create(instance, info, properties)
    tw:Play()
    return tw
end

-- ============================================================
-- Bounce
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
-- Draggable
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
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
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
                startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- ============================================================
-- Helper: сделать иконку
-- ============================================================
local function CreateIcon(parent, iconId, size, position, color, zIndex)
    return Create("ImageLabel", {
        Parent = parent,
        BackgroundTransparency = 1,
        Image = iconId,
        ImageColor3 = color or TextColor,
        Size = UDim2.new(0, size or 18, 0, size or 18),
        Position = position or UDim2.new(0, 0, 0.5, -(size or 18) / 2),
        ZIndex = zIndex or 10,
    })
end

-- ============================================================
-- Notifications (с иконками)
-- ============================================================
local GlobalNotifContainer

function Library:Notify(options)
    if not GlobalNotifContainer then return end
    options = options or {}
    local title = options.Title or "Уведомление"
    local desc  = options.Description or options.Content or ""
    local duration = options.Duration or 3
    local kind = options.Kind or "info"

    local accent = AccentColor
    local iconId = ICONS.Info
    if kind == "success" then accent = SuccessColor; iconId = ICONS.Check
    elseif kind == "error" then accent = DangerColor; iconId = ICONS.Delete
    elseif kind == "warning" then accent = WarningColor; iconId = ICONS.Warning end

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
        Parent = Notif, Color = accent, Thickness = 1.4, Transparency = 1,
    })
    -- Иконка слева
    local IconCircle = Create("Frame", {
        Parent = Notif, BackgroundColor3 = accent,
        Size = UDim2.new(0, 28, 0, 28),
        Position = UDim2.new(0, 12, 0, 17),
        BackgroundTransparency = 1, ZIndex = 202,
    })
    Create("UICorner", {Parent = IconCircle, CornerRadius = UDim.new(1, 0)})
    Create("ImageLabel", {
        Parent = IconCircle, BackgroundTransparency = 1,
        Image = iconId, ImageColor3 = accent,
        Size = UDim2.new(0, 18, 0, 18),
        Position = UDim2.new(0.5, -9, 0.5, -9),
        ImageTransparency = 1, ZIndex = 203,
    })
    -- Тексты
    Create("TextLabel", {
        Parent = Notif, Text = title, Font = Enum.Font.GothamBold, TextSize = 13,
        TextColor3 = TextColor, BackgroundTransparency = 1,
        Position = UDim2.new(0, 50, 0, 12), Size = UDim2.new(1, -60, 0, 16),
        TextXAlignment = Enum.TextXAlignment.Left, TextTransparency = 1, ZIndex = 202,
    })
    Create("TextLabel", {
        Parent = Notif, Text = desc, Font = Enum.Font.Gotham, TextSize = 11,
        TextColor3 = SubTextColor, BackgroundTransparency = 1,
        Position = UDim2.new(0, 50, 0, 30), Size = UDim2.new(1, -60, 0, 22),
        TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true,
        TextTransparency = 1, ZIndex = 202,
    })

    Tween(Notif, {BackgroundTransparency = 0}, 0.3)
    Tween(Stroke, {Transparency = 0.2}, 0.3)
    task.delay(0.05, function()
        for _, d in ipairs(Notif:GetDescendants()) do
            if d:IsA("TextLabel") or d:IsA("ImageLabel") then
                Tween(d, {TextTransparency = 0, ImageTransparency = 0}, 0.3)
            end
        end
    end)
    task.delay(duration, function()
        Tween(Notif, {BackgroundTransparency = 1}, 0.35)
        Tween(Stroke, {Transparency = 1}, 0.35)
        for _, d in ipairs(Notif:GetDescendants()) do
            if d:IsA("TextLabel") or d:IsA("ImageLabel") then
                Tween(d, {TextTransparency = 1, ImageTransparency = 1}, 0.35)
            end
        end
        task.wait(0.4)
        Notif:Destroy()
    end)
end

-- Экспорт для дальнейших частей
Library._Internal = {
    Create = Create,
    Tween = Tween,
    AddBounce = AddBounce,
    MakeDraggable = MakeDraggable,
    CreateIcon = CreateIcon,
    ICONS = ICONS,
    Colors = {
        Accent = AccentColor,
        AccentLight = AccentColorLight,
        Background = BackgroundColor,
        Card = CardColor,
        Item = ItemColor,
        Hover = HoverColor,
        Text = TextColor,
        SubText = SubTextColor,
        Stroke = StrokeColor,
        Danger = DangerColor,
        Success = SuccessColor,
        Warning = WarningColor,
    },
    FileSystem = {
        isfolder = _isfolder,
        makefolder = _makefolder,
        writefile = _writefile,
        readfile = _readfile,
        listfiles = _listfiles,
        delfile = _delfile,
    },
    SafeCopy = SafeCopy,
    GetNotifContainer = function() return GlobalNotifContainer end,
    SetNotifContainer = function(c) GlobalNotifContainer = c end,
}-- ============================================================
-- CREATE WINDOW (с иконками в топбаре)
-- ============================================================
local _I = Library._Internal
local Create = _I.Create
local Tween = _I.Tween
local AddBounce = _I.AddBounce
local MakeDraggable = _I.MakeDraggable
local CreateIcon = _I.CreateIcon
local ICONS = _I.ICONS
local C = _I.Colors

function Library:CreateWindow(options)
    local hubName  = "Sensei"
    local subText  = "ZX Edition"
    local subColor = C.AccentLight

    if type(options) == "table" then
        hubName  = options.Title or hubName
        subText  = options.Subtitle or subText
        subColor = options.SubtitleColor or subColor
    elseif type(options) == "string" then
        hubName = options
    end

    local uniqueID = game:GetService("HttpService"):GenerateGUID(false)
    local ScreenGui = Create("ScreenGui", {
        Name = "Sensei_UI_" .. uniqueID,
        Parent = game:GetService("RunService"):IsStudio()
            and LocalPlayer:WaitForChild("PlayerGui")
            or game:GetService("CoreGui"),
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    })
    if syn and syn.protect_gui then pcall(function() syn.protect_gui(ScreenGui) end) end

    -- ========================================================
    -- NOTIFICATIONS CONTAINER
    -- ========================================================
    local NotifContainer = Create("Frame", {
        Parent = ScreenGui,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 260, 0, 300),
        Position = UDim2.new(1, -270, 0, 12),
        ZIndex = 200, Active = false,
    })
    Create("UIListLayout", {
        Parent = NotifContainer,
        VerticalAlignment = Enum.VerticalAlignment.Top,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8),
    })
    _I.SetNotifContainer(NotifContainer)

    -- ========================================================
    -- MAIN FRAME
    -- ========================================================
    local MainFrame = Create("Frame", {
        Parent = ScreenGui,
        BackgroundColor3 = C.Background,
        Size = UDim2.new(0, 520, 0, 320),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        ClipsDescendants = true,
        BackgroundTransparency = 0,
        Active = true,
        ZIndex = 5,
    })
    local MainScale = Create("UIScale", {Parent = MainFrame, Scale = 0.85})
    Create("UICorner", {Parent = MainFrame, CornerRadius = UDim.new(0, 12)})
    local MainStroke = Create("UIStroke", {
        Parent = MainFrame, Color = C.Stroke, Thickness = 1.4, Transparency = 0.2,
    })
    Tween(MainScale, {Scale = 1}, 0.5)

    -- ========================================================
    -- MINIBAR (Delta-style)
    -- ========================================================
    local Minibar = Create("Frame", {
        Parent = ScreenGui,
        BackgroundColor3 = C.Card,
        Size = UDim2.new(0, 180, 0, 44),
        Position = UDim2.new(0.5, -90, 1, -80),
        Visible = false, Active = true, ZIndex = 10,
    })
    Create("UICorner", {Parent = Minibar, CornerRadius = UDim.new(0, 12)})
    local MinibarStroke = Create("UIStroke", {
        Parent = Minibar, Color = C.Accent, Thickness = 1.4, Transparency = 0.2,
    })

    -- Иконка-молния
    Create("ImageLabel", {
        Parent = Minibar, BackgroundTransparency = 1,
        Size = UDim2.new(0, 22, 0, 22),
        Position = UDim2.new(0, 12, 0.5, -11),
        Image = ICONS.Settings, ImageColor3 = C.Accent,
    })
    Create("TextLabel", {
        Parent = Minibar, BackgroundTransparency = 1,
        Size = UDim2.new(1, -80, 1, 0),
        Position = UDim2.new(0, 42, 0, 0),
        Text = hubName, Font = Enum.Font.GothamBold,
        TextSize = 13, TextColor3 = C.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
    })
    -- Кнопка развернуть (иконка)
    local MinibarExpand = Create("TextButton", {
        Parent = Minibar,
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -36, 0.5, -15),
        BackgroundColor3 = C.Item,
        Text = "", AutoButtonColor = false, BorderSizePixel = 0,
        ZIndex = 11,
    })
    Create("UICorner", {Parent = MinibarExpand, CornerRadius = UDim.new(0, 8)})
    CreateIcon(MinibarExpand, ICONS.Expand, 16, UDim2.new(0.5, -8, 0.5, -8), C.Accent, 12)
    AddBounce(MinibarExpand)
    MakeDraggable(Minibar, Minibar)

    MinibarExpand.MouseButton1Click:Connect(function()
        Minibar.Visible = false
        MainFrame.Visible = true
        MainScale.Scale = 0.85
        Tween(MainScale, {Scale = 1}, 0.35)
        Tween(MainFrame, {BackgroundTransparency = 0}, 0.35)
    end)

    -- ========================================================
    -- TOPBAR
    -- ========================================================
    local TopBar = Create("Frame", {
        Parent = MainFrame,
        BackgroundColor3 = C.Card,
        BackgroundTransparency = 0.15,
        Size = UDim2.new(1, 0, 0, 42),
        Position = UDim2.new(0, 0, 0, 0),
        Active = true, BorderSizePixel = 0, ZIndex = 6,
    })
    Create("UICorner", {Parent = TopBar, CornerRadius = UDim.new(0, 12)})
    -- нижняя полоска, чтобы углы снизу не скруглялись
    Create("Frame", {
        Parent = TopBar, BackgroundColor3 = C.Card,
        BackgroundTransparency = 0.15, BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 14),
        Position = UDim2.new(0, 0, 1, -14), ZIndex = 6,
    })
    MakeDraggable(TopBar, MainFrame)

    -- Иконка-логотип слева
    CreateIcon(TopBar, ICONS.Settings, 20, UDim2.new(0, 14, 0.5, -10), C.Accent, 8)

    -- Заголовок
    local TitleContainer = Create("Frame", {
        Parent = TopBar, BackgroundTransparency = 1,
        Size = UDim2.new(0, 250, 1, 0),
        Position = UDim2.new(0, 42, 0, 0), ZIndex = 7,
    })
    Create("TextLabel", {
        Parent = TitleContainer,
        Text = hubName, Font = Enum.Font.GothamBold, TextSize = 14,
        TextColor3 = C.Text, BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 5), Size = UDim2.new(1, 0, 0, 16),
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 7,
    })
    Create("TextLabel", {
        Parent = TitleContainer,
        Text = subText, Font = Enum.Font.Gotham, TextSize = 10,
        TextColor3 = subColor, BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 22), Size = UDim2.new(1, 0, 0, 12),
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 7,
    })

    -- Кнопка "Свернуть" с иконкой
    local MinBtn = Create("TextButton", {
        Parent = TopBar, Text = "",
        BackgroundColor3 = C.Item,
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -74, 0.5, -15),
        AutoButtonColor = false, BorderSizePixel = 0, ZIndex = 7,
    })
    Create("UICorner", {Parent = MinBtn, CornerRadius = UDim.new(0, 8)})
    CreateIcon(MinBtn, ICONS.Minimize, 16, UDim2.new(0.5, -8, 0.5, -8), C.Warning, 8)
    AddBounce(MinBtn)

    -- Кнопка "Закрыть" с иконкой
    local CloseBtn = Create("TextButton", {
        Parent = TopBar, Text = "",
        BackgroundColor3 = C.Item,
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -40, 0.5, -15),
        AutoButtonColor = false, BorderSizePixel = 0, ZIndex = 7,
    })
    Create("UICorner", {Parent = CloseBtn, CornerRadius = UDim.new(0, 8)})
    CreateIcon(CloseBtn, ICONS.Close, 16, UDim2.new(0.5, -8, 0.5, -8), C.Danger, 8)
    AddBounce(CloseBtn)

    -- Свернуть
    MinBtn.MouseButton1Click:Connect(function()
        Minibar.Position = UDim2.new(
            MainFrame.Position.X.Scale,
            MainFrame.Position.X.Offset + 170,
            MainFrame.Position.Y.Scale,
            MainFrame.Position.Y.Offset - 80)
        Tween(MainScale, {Scale = 0.85}, 0.28)
        Tween(MainFrame, {BackgroundTransparency = 1}, 0.28)
        task.wait(0.22)
        MainFrame.Visible = false
        Minibar.Visible = true
        Minibar.Size = UDim2.new(0, 0, 0, 44)
        Tween(Minibar, {Size = UDim2.new(0, 180, 0, 44)}, 0.3)
    end)

    -- Закрыть
    CloseBtn.MouseButton1Click:Connect(function()
        Tween(MainScale, {Scale = 0.85}, 0.3)
        Tween(MainFrame, {BackgroundTransparency = 1}, 0.3)
        task.wait(0.35)
        ScreenGui:Destroy()
    end)

    -- ========================================================
    -- SIDEBAR
    -- ========================================================
    local Sidebar = Create("Frame", {
        Parent = MainFrame,
        BackgroundColor3 = C.Card,
        BackgroundTransparency = 0.15,
        Size = UDim2.new(0, 130, 1, -42),
        Position = UDim2.new(0, 0, 0, 42),
        Active = true, BorderSizePixel = 0, ZIndex = 6,
    })

    local TabContainer = Create("ScrollingFrame", {
        Parent = Sidebar, BackgroundTransparency = 1,
        Size = UDim2.new(1, -10, 1, -10),
        Position = UDim2.new(0, 5, 0, 5),
        ScrollBarThickness = 2, ScrollBarImageColor3 = C.Stroke,
        BorderSizePixel = 0, CanvasSize = UDim2.new(0, 0, 0, 0),
        ZIndex = 7,
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
        Parent = MainFrame, BackgroundColor3 = C.Stroke,
        BorderSizePixel = 0, Size = UDim2.new(0, 1, 1, -42),
        Position = UDim2.new(0, 130, 0, 42), ZIndex = 6,
    })

    -- ========================================================
    -- CONTENT AREA
    -- ========================================================
    local ContentArea = Create("Frame", {
        Parent = MainFrame, BackgroundTransparency = 1,
        Size = UDim2.new(1, -135, 1, -42),
        Position = UDim2.new(0, 135, 0, 42),
        Active = true, ZIndex = 6,
    })
    Create("UIPadding", {
        Parent = ContentArea,
        PaddingTop = UDim.new(0, 12),
        PaddingBottom = UDim2.new(0, 12),
        PaddingLeft = UDim2.new(0, 12),
        PaddingRight = UDim2.new(0, 12),
    })

    -- ========================================================
    -- WINDOW API
    -- ========================================================
    local Window = {
        CurrentTab = nil,
        Tabs = {},
        MainFrame = MainFrame,
        ConfigElements = {},
        ScreenGui = ScreenGui,
        _refs = {
            TabContainer = TabContainer,
            ContentArea = ContentArea,
            ScreenGui = ScreenGui,
        },
    }

    function Window:SetTransparency(val)
        Tween(MainFrame, {BackgroundTransparency = val}, 0.3)
    end

    return Window
end-- ============================================================
-- TAB / PAGE / SECTION
-- ============================================================
local function AttachTabMethods(Window)
    local _I = Library._Internal
    local Create = _I.Create
    local Tween = _I.Tween
    local AddBounce = _I.AddBounce
    local CreateIcon = _I.CreateIcon
    local ICONS = _I.ICONS
    local C = _I.Colors

    local TabContainer = Window._refs.TabContainer
    local ContentArea  = Window._refs.ContentArea

    -- ========================================================
    -- CreateTab
    -- ========================================================
    function Window:CreateTab(tabName, isDefault, isLocked)
        tabName = tabName or "Tab"
        local isWhitelisted = false
        if LocalPlayer then
            for _, allowed in ipairs(Library.WhitelistedUsers) do
                if LocalPlayer.Name == allowed or LocalPlayer.DisplayName == allowed then
                    isWhitelisted = true; break
                end
            end
        end

        local TabBtn = Create("TextButton", {
            Parent = TabContainer, Text = "",
            BackgroundColor3 = C.Hover, BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 36),
            AutoButtonColor = false, BorderSizePixel = 0, ZIndex = 8,
        })
        Create("UICorner", {Parent = TabBtn, CornerRadius = UDim.new(0, 8)})
        AddBounce(TabBtn, 0.97)

        -- Индикатор слева
        local Indicator = Create("Frame", {
            Parent = TabBtn,
            BackgroundColor3 = isLocked and C.Warning or C.Accent,
            Size = UDim2.new(0, 3, 0, 0),
            Position = UDim2.new(0, 0, 0.5, 0),
            AnchorPoint = Vector2.new(0, 0.5),
            BorderSizePixel = 0, ZIndex = 9,
        })
        Create("UICorner", {Parent = Indicator, CornerRadius = UDim.new(1, 0)})

        local Txt = Create("TextLabel", {
            Parent = TabBtn, Text = tabName,
            Font = Enum.Font.GothamBold, TextSize = 13,
            TextColor3 = C.SubText, BackgroundTransparency = 1,
            Size = UDim2.new(1, -40, 1, 0),
            Position = UDim2.new(0, 14, 0, 0),
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 9,
        })

        -- Замок для премиум-таба
        if isLocked then
            CreateIcon(TabBtn, ICONS.Lock, 14, UDim2.new(1, -22, 0.5, -7), C.Warning, 9)
        end

        -- Контент таба
        local TabContent = Create("Frame", {
            Parent = ContentArea, BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0), Visible = false, ZIndex = 7,
        })

        -- Навигация страниц
        local PageNav = Create("Frame", {
            Parent = TabContent, BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 30), ZIndex = 8,
        })
        Create("UIListLayout", {
            Parent = PageNav, FillDirection = Enum.FillDirection.Horizontal,
            Padding = UDim.new(0, 16),
            VerticalAlignment = Enum.VerticalAlignment.Center,
        })

        local PageContainer = Create("Frame", {
            Parent = TabContent, BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, -30),
            Position = UDim2.new(0, 0, 0, 30), ZIndex = 8,
        })

        local TabConfig = {
            Button = TabBtn, Content = TabContent,
            Indicator = Indicator, Txt = Txt,
            Pages = {}, CurrentPage = nil, IsLocked = isLocked,
        }
        table.insert(Window.Tabs, TabConfig)

        TabBtn.MouseButton1Click:Connect(function()
            if isLocked and not isWhitelisted then
                Library:Notify({
                    Title = "Доступ закрыт",
                    Description = "Этот раздел доступен только по подписке.",
                    Kind = "error",
                })
                return
            end
            if Window.CurrentTab == TabConfig then return end

            if Window.CurrentTab then
                Tween(Window.CurrentTab.Button, {BackgroundTransparency = 1}, 0.2)
                Tween(Window.CurrentTab.Indicator, {Size = UDim2.new(0, 3, 0, 0)}, 0.2)
                Tween(Window.CurrentTab.Txt, {TextColor3 = C.SubText}, 0.2)
                Window.CurrentTab.Content.Visible = false
            end

            Window.CurrentTab = TabConfig
            TabConfig.Content.Visible = true
            -- Плавный выезд контента
            TabConfig.Content.Position = UDim2.new(0, 0, 0, 15)
            Tween(TabConfig.Content, {Position = UDim2.new(0, 0, 0, 0)}, 0.35)

            Tween(TabBtn, {BackgroundTransparency = 0.15}, 0.2)
            Tween(Indicator, {Size = UDim2.new(0, 3, 0, 20)}, 0.3)
            Tween(Txt, {TextColor3 = C.Text}, 0.2)

            if #TabConfig.Pages > 0 and not TabConfig.CurrentPage then
                local first = TabConfig.Pages[1]
                TabConfig.CurrentPage = first
                first.Scroll.Visible = true
                Tween(first.Btn, {TextColor3 = C.Text}, 0.2)
                Tween(first.Highlight,
                    {Size = UDim2.new(1, 0, 0, 2), BackgroundTransparency = 0}, 0.2)
            end
        end)

        -- ================================================
        -- CreatePage
        -- ================================================
        function TabConfig:CreatePage(pageName)
            pageName = pageName or "Page"
            local PageBtn = Create("TextButton", {
                Parent = PageNav, Text = pageName,
                Font = Enum.Font.GothamBold, TextSize = 13,
                TextColor3 = C.SubText, BackgroundTransparency = 1,
                Size = UDim2.new(0, 0, 1, 0),
                AutomaticSize = Enum.AutomaticSize.X,
                AutoButtonColor = false, ZIndex = 9,
            })
            local PageHighlight = Create("Frame", {
                Parent = PageBtn, BackgroundColor3 = C.Accent,
                Size = UDim2.new(0, 0, 0, 2),
                Position = UDim2.new(0.5, 0, 1, -4),
                AnchorPoint = Vector2.new(0.5, 0),
                BackgroundTransparency = 1, BorderSizePixel = 0,
                ZIndex = 9,
            })
            local PageScroll = Create("ScrollingFrame", {
                Parent = PageContainer, BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Position = UDim2.new(0, 0, 0, 0),
                ScrollBarThickness = 3,
                ScrollBarImageColor3 = C.Stroke,
                Visible = false, BorderSizePixel = 0,
                CanvasSize = UDim2.new(0, 0, 0, 0),
                ZIndex = 8,
            })

            -- ДВЕ КОЛОНКИ
            local LeftColumn = Create("Frame", {
                Parent = PageScroll, BackgroundTransparency = 1,
                Size = UDim2.new(0.5, -5, 1, 0), ZIndex = 9,
            })
            local RightColumn = Create("Frame", {
                Parent = PageScroll, BackgroundTransparency = 1,
                Size = UDim2.new(0.5, -5, 1, 0),
                Position = UDim2.new(0.5, 5, 0, 0), ZIndex = 9,
            })

            local LeftLayout = Create("UIListLayout", {
                Parent = LeftColumn, SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 10),
            })
            local RightLayout = Create("UIListLayout", {
                Parent = RightColumn, SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 10),
            })

            local function updateCanvas()
                PageScroll.CanvasSize = UDim2.new(0, 0, 0,
                    math.max(LeftLayout.AbsoluteContentSize.Y,
                             RightLayout.AbsoluteContentSize.Y) + 20)
            end
            LeftLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)
            RightLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)

            local PageObj = {
                Scroll = PageScroll, Btn = PageBtn,
                Highlight = PageHighlight,
                LeftCol = LeftColumn, RightCol = RightColumn,
                _side = "left",
            }
            table.insert(TabConfig.Pages, PageObj)

            PageBtn.MouseButton1Click:Connect(function()
                if TabConfig.CurrentPage == PageObj then return end
                if TabConfig.CurrentPage then
                    Tween(TabConfig.CurrentPage.Btn, {TextColor3 = C.SubText}, 0.2)
                    Tween(TabConfig.CurrentPage.Highlight,
                        {Size = UDim2.new(0, 0, 0, 2), BackgroundTransparency = 1}, 0.2)
                    TabConfig.CurrentPage.Scroll.Visible = false
                end
                TabConfig.CurrentPage = PageObj
                PageObj.Scroll.Visible = true
                PageObj.Scroll.Position = UDim2.new(0, 0, 0, 15)
                Tween(PageObj.Scroll, {Position = UDim2.new(0, 0, 0, 0)}, 0.3)
                Tween(PageBtn, {TextColor3 = C.Text}, 0.2)
                Tween(PageHighlight,
                    {Size = UDim2.new(1, 0, 0, 2), BackgroundTransparency = 0}, 0.2)
            end)

            if #TabConfig.Pages == 1 and not TabConfig.CurrentPage then
                TabConfig.CurrentPage = PageObj
                PageObj.Scroll.Visible = true
                PageBtn.TextColor3 = C.Text
                PageHighlight.Size = UDim2.new(1, 0, 0, 2)
                PageHighlight.BackgroundTransparency = 0
            end

            -- ============================================
            -- CreateSection (ZX-стиль)
            -- ============================================
            function PageObj:CreateSection(sectionName)
                sectionName = sectionName or "Section"
                local targetCol = (PageObj._side == "left") and LeftColumn or RightColumn
                PageObj._side = (PageObj._side == "left") and "right" or "left"

                local SectionContainer = Create("Frame", {
                    Parent = targetCol,
                    BackgroundColor3 = C.Card,
                    Size = UDim2.new(1, 0, 0, 32),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    ClipsDescendants = true,
                    BorderSizePixel = 0, ZIndex = 8,
                })
                Create("UICorner", {Parent = SectionContainer, CornerRadius = UDim.new(0, 10)})
                Create("UIStroke", {
                    Parent = SectionContainer, Color = C.Stroke,
                    Thickness = 1, Transparency = 0.5,
                })

                -- Заголовок секции с цветной полоской
                local TitleRow = Create("Frame", {
                    Parent = SectionContainer, BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 32), ZIndex = 9,
                })
                Create("Frame", {
                    Parent = TitleRow, BackgroundColor3 = C.Accent,
                    BorderSizePixel = 0,
                    Size = UDim2.new(0, 3, 0, 14),
                    Position = UDim2.new(0, 10, 0.5, -7), ZIndex = 10,
                })
                Create("TextLabel", {
                    Parent = TitleRow, Text = sectionName,
                    Font = Enum.Font.GothamBold, TextSize = 13,
                    TextColor3 = C.Text, BackgroundTransparency = 1,
                    Size = UDim2.new(1, -30, 1, 0),
                    Position = UDim2.new(0, 20, 0, 0),
                    TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 9,
                })

                local ItemContainer = Create("Frame", {
                    Parent = SectionContainer, BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 0),
                    Position = UDim2.new(0, 0, 0, 32),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    ZIndex = 9,
                })
                Create("UIPadding", {
                    Parent = ItemContainer,
                    PaddingTop = UDim.new(0, 8),
                    PaddingBottom = UDim.new(0, 12),
                    PaddingLeft = UDim.new(0, 12),
                    PaddingRight = UDim2.new(0, 12),
                })
                Create("UIListLayout", {
                    Parent = ItemContainer,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, 10),
                })

                local Elements = {}
                Elements._ItemContainer = ItemContainer
                Elements._PageObj = PageObj
                Elements._TabConfig = TabConfig

                return Elements
            end
            return PageObj
        end

        if isDefault then
            TabBtn.BackgroundTransparency = 0.15
            Indicator.Size = UDim2.new(0, 3, 0, 20)
            Txt.TextColor3 = C.Text
            TabContent.Visible = true
            Window.CurrentTab = TabConfig
        end

        return TabConfig
    end
end

-- Экспорт функции для Части 10
Library._Internal.AttachTabMethods = AttachTabMethods-- ============================================================
-- БАЗОВЫЕ КОМПОНЕНТЫ
-- ============================================================
local function AttachBasicComponents(Elements)
    local _I = Library._Internal
    local Create = _I.Create
    local Tween = _I.Tween
    local AddBounce = _I.AddBounce
    local CreateIcon = _I.CreateIcon
    local ICONS = _I.ICONS
    local C = _I.Colors
    local SafeCopy = _I.SafeCopy

    local ItemContainer = Elements._ItemContainer

    -- ========================================================
    -- AddButton
    -- ========================================================
    function Elements:AddButton(name, callback)
        local Btn = Create("TextButton", {
            Parent = ItemContainer, Text = "  " .. (name or "Button"),
            Font = Enum.Font.Gotham, TextSize = 12,
            TextColor3 = C.Text, BackgroundColor3 = C.Item,
            Size = UDim2.new(1, 0, 0, 34),
            AutoButtonColor = false, BorderSizePixel = 0,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 10,
        })
        Create("UICorner", {Parent = Btn, CornerRadius = UDim.new(0, 8)})
        Create("UIStroke", {
            Parent = Btn, Color = C.Stroke, Thickness = 1, Transparency = 0.6,
        })
        AddBounce(Btn)
        Btn.MouseButton1Click:Connect(function()
            if callback then pcall(callback) end
        end)
        return Btn
    end

    -- ========================================================
    -- AddCopyButton
    -- ========================================================
    function Elements:AddCopyButton(name, copyText)
        local Btn = Create("TextButton", {
            Parent = ItemContainer, Text = "  " .. (name or "Copy"),
            Font = Enum.Font.Gotham, TextSize = 12,
            TextColor3 = C.Text, BackgroundColor3 = C.Item,
            Size = UDim2.new(1, 0, 0, 34),
            AutoButtonColor = false, BorderSizePixel = 0,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 10,
        })
        Create("UICorner", {Parent = Btn, CornerRadius = UDim.new(0, 8)})
        Create("UIStroke", {
            Parent = Btn, Color = C.Stroke, Thickness = 1, Transparency = 0.6,
        })
        -- Иконка копирования справа
        CreateIcon(Btn, ICONS.Copy, 16, UDim2.new(1, -24, 0.5, -8), C.Accent, 11)
        AddBounce(Btn)
        Btn.MouseButton1Click:Connect(function()
            SafeCopy(copyText)
            Library:Notify({
                Title = "Скопировано",
                Description = "Текст в буфере обмена.",
                Kind = "success",
            })
        end)
        return Btn
    end

    -- ========================================================
    -- AddToggle
    -- ========================================================
    function Elements:AddToggle(name, default, callback)
        local state = default and true or false
        local Frame = Create("Frame", {
            Parent = ItemContainer, BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 26), ZIndex = 10,
        })
        Create("TextLabel", {
            Parent = Frame, Text = name or "Toggle",
            Font = Enum.Font.Gotham, TextSize = 12,
            TextColor3 = C.Text, BackgroundTransparency = 1,
            Size = UDim2.new(1, -60, 1, 0),
            Position = UDim2.new(0, 2, 0, 0),
            TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 10,
        })
        local Lever = Create("TextButton", {
            Parent = Frame, Text = "",
            BackgroundColor3 = state and C.Accent or Color3.fromRGB(45, 50, 60),
            Size = UDim2.new(0, 40, 0, 22),
            Position = UDim2.new(1, -42, 0.5, -11),
            AutoButtonColor = false, BorderSizePixel = 0, ZIndex = 10,
        })
        Create("UICorner", {Parent = Lever, CornerRadius = UDim.new(1, 0)})
        AddBounce(Lever)
        local Knob = Create("Frame", {
            Parent = Lever, BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            Size = UDim2.new(0, 16, 0, 16),
            Position = state and UDim2.new(1, -18, 0.5, -8)
                            or UDim2.new(0, 2, 0.5, -8),
            BorderSizePixel = 0, ZIndex = 11,
        })
        Create("UICorner", {Parent = Knob, CornerRadius = UDim.new(1, 0)})
        local function apply()
            Tween(Lever, {
                BackgroundColor3 = state and C.Accent or Color3.fromRGB(45, 50, 60),
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
        Lever.MouseButton1Click:Connect(function() internalSet(not state, true) end)
        Library.ConfigElements[name] = {
            Set = function(v) internalSet(v, false) end,
            Get = function() return state end,
        }
        return {Set = internalSet, Get = function() return state end}
    end

    -- ========================================================
    -- AddSlider
    -- ========================================================
    function Elements:AddSlider(name, min, max, default, callback)
        min = min or 0; max = max or 100
        local val = math.clamp(default or min, min, max)
        local Frame = Create("Frame", {
            Parent = ItemContainer, BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 46), ZIndex = 10,
        })
        Create("TextLabel", {
            Parent = Frame, Text = name or "Slider",
            Font = Enum.Font.Gotham, TextSize = 12,
            TextColor3 = C.Text, BackgroundTransparency = 1,
            Size = UDim2.new(1, -50, 0, 16),
            Position = UDim2.new(0, 2, 0, 0),
            TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 10,
        })
        local ValTxt = Create("TextLabel", {
            Parent = Frame, Text = tostring(math.floor(val)),
            Font = Enum.Font.GothamBold, TextSize = 12,
            TextColor3 = C.Accent, BackgroundTransparency = 1,
            Size = UDim2.new(0, 44, 0, 16),
            Position = UDim2.new(1, -46, 0, 0),
            TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 10,
        })
        local Track = Create("Frame", {
            Parent = Frame, BackgroundColor3 = Color3.fromRGB(40, 46, 56),
            Size = UDim2.new(1, 0, 0, 6),
            Position = UDim2.new(0, 0, 0, 26),
            BorderSizePixel = 0, ZIndex = 10,
        })
        Create("UICorner", {Parent = Track, CornerRadius = UDim.new(1, 0)})
        local alpha = (max - min > 0) and (val - min) / (max - min) or 0
        local Fill = Create("Frame", {
            Parent = Track, BackgroundColor3 = C.Accent,
            Size = UDim2.new(alpha, 0, 1, 0),
            BorderSizePixel = 0, ZIndex = 11,
        })
        Create("UICorner", {Parent = Fill, CornerRadius = UDim.new(1, 0)})
        local Knob = Create("Frame", {
            Parent = Fill, BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            Size = UDim2.new(0, 14, 0, 14),
            Position = UDim2.new(1, -7, 0.5, -7),
            BorderSizePixel = 0, ZIndex = 12,
        })
        Create("UICorner", {Parent = Knob, CornerRadius = UDim.new(1, 0)})
        local function internalSet(v, fire)
            val = math.clamp(v, min, max)
            ValTxt.Text = tostring(math.floor(val))
            local a = (max - min > 0) and (val - min) / (max - min) or 0
            Tween(Fill, {Size = UDim2.new(a, 0, 1, 0)}, 0.08)
            if fire ~= false and callback then pcall(callback, val) end
        end
        local Hit = Create("TextButton", {
            Parent = Frame, Text = "",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 24),
            Position = UDim2.new(0, 0, 0, 17),
            AutoButtonColor = false, ZIndex = 13,
        })
        local dragging = false
        local function update(input)
            local rel = math.clamp(
                (input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
            internalSet(min + (max - min) * rel, true)
        end
        Hit.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true; update(input)
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
        Library.ConfigElements[name] = {
            Set = function(v) internalSet(v, false) end,
            Get = function() return val end,
        }
        return {Set = internalSet, Get = function() return val end}
    end

    -- ========================================================
    -- AddDropdown
    -- ========================================================
    function Elements:AddDropdown(name, options, isMulti, callback)
        options = options or {}
        local selected = isMulti and {} or options[1]
        local dropped = false
        local optionButtons = {}
        local maxVisible = math.min(#options, 4)
        local listHeight = maxVisible * 28

        local Wrapper = Create("Frame", {
            Parent = ItemContainer, BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 50),
            ClipsDescendants = true, ZIndex = 10,
        })
        Create("TextLabel", {
            Parent = Wrapper, Text = name or "Dropdown",
            Font = Enum.Font.Gotham, TextSize = 12,
            TextColor3 = C.Text, BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 16),
            Position = UDim2.new(0, 2, 0, 0),
            TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 10,
        })
        local MainBtn = Create("TextButton", {
            Parent = Wrapper,
            Text = isMulti and "Выбрать..." or (selected or "Выбрать..."),
            Font = Enum.Font.Gotham, TextSize = 12,
            TextColor3 = C.Text, BackgroundColor3 = C.Item,
            Size = UDim2.new(1, 0, 0, 28),
            Position = UDim2.new(0, 0, 0, 20),
            AutoButtonColor = false, BorderSizePixel = 0,
            TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 10,
        })
        Create("UIPadding", {Parent = MainBtn, PaddingLeft = UDim.new(0, 10)})
        Create("UICorner", {Parent = MainBtn, CornerRadius = UDim.new(0, 8)})
        Create("UIStroke", {
            Parent = MainBtn, Color = C.Stroke, Thickness = 1, Transparency = 0.6,
        })
        AddBounce(MainBtn, 0.98)
        -- Стрелка справа
        local Arrow = Create("TextLabel", {
            Parent = MainBtn, Text = "▼",
            Font = Enum.Font.GothamBold, TextSize = 10,
            TextColor3 = C.SubText, BackgroundTransparency = 1,
            Size = UDim2.new(0, 16, 1, 0),
            Position = UDim2.new(1, -22, 0, 0), ZIndex = 11,
        })
        local ListFrame = Create("ScrollingFrame", {
            Parent = Wrapper, BackgroundColor3 = C.Background,
            Size = UDim2.new(1, 0, 0, 0),
            Position = UDim2.new(0, 0, 0, 50),
            CanvasSize = UDim2.new(0, 0, 0, #options * 28),
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = C.Stroke,
            BorderSizePixel = 0, Visible = false, ZIndex = 11,
        })
        Create("UICorner", {Parent = ListFrame, CornerRadius = UDim.new(0, 8)})
        Create("UIListLayout", {Parent = ListFrame, SortOrder = Enum.SortOrder.LayoutOrder})

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
            if isMulti then return table.find(selected, opt) ~= nil end
            return selected == opt
        end
        for i, opt in ipairs(options) do
            local OptBtn = Create("TextButton", {
                Parent = ListFrame, Text = "  " .. tostring(opt),
                Font = Enum.Font.Gotham, TextSize = 12,
                TextColor3 = isSelected(opt) and C.Accent or C.SubText,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 28),
                AutoButtonColor = false,
                TextXAlignment = Enum.TextXAlignment.Left,
                LayoutOrder = i, ZIndex = 12,
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
                    local txt = b.Text:gsub("^%s+", "")
                    Tween(b, {TextColor3 = isSelected(txt) and C.Accent or C.SubText}, 0.15)
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
        Library.ConfigElements[name] = {
            Set = function(v)
                selected = v
                for _, b in ipairs(optionButtons) do
                    local txt = b.Text:gsub("^%s+", "")
                    Tween(b, {TextColor3 = isSelected(txt) and C.Accent or C.SubText}, 0.15)
                end
                updateText()
            end,
            Get = function() return selected end,
        }
        return {Set = function(v) selected = v; updateText() end,
                Get = function() return selected end}
    end

    -- ========================================================
    -- AddTextbox
    -- ========================================================
    function Elements:AddTextbox(name, placeholder, callback)
        local Frame = Create("Frame", {
            Parent = ItemContainer, BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 50), ZIndex = 10,
        })
        Create("TextLabel", {
            Parent = Frame, Text = name or "Textbox",
            Font = Enum.Font.Gotham, TextSize = 12,
            TextColor3 = C.Text, BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 16),
            Position = UDim2.new(0, 2, 0, 0),
            TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 10,
        })
        local Input = Create("TextBox", {
            Parent = Frame,
            PlaceholderText = placeholder or "Введите...",
            Text = "",
            Font = Enum.Font.Gotham, TextSize = 12,
            TextColor3 = C.Text, BackgroundColor3 = C.Item,
            PlaceholderColor3 = C.SubText,
            Size = UDim2.new(1, 0, 0, 28),
            Position = UDim2.new(0, 0, 0, 20),
            TextXAlignment = Enum.TextXAlignment.Left,
            ClearTextOnFocus = false, BorderSizePixel = 0, ZIndex = 10,
        })
        Create("UIPadding", {Parent = Input, PaddingLeft = UDim.new(0, 10)})
        Create("UICorner", {Parent = Input, CornerRadius = UDim.new(0, 8)})
        Create("UIStroke", {
            Parent = Input, Color = C.Stroke, Thickness = 1, Transparency = 0.6,
        })
        Input.FocusLost:Connect(function()
            if callback then pcall(callback, Input.Text) end
        end)
        Library.ConfigElements[name] = {
            Set = function(v) Input.Text = tostring(v) end,
            Get = function() return Input.Text end,
        }
        return {Set = function(v) Input.Text = tostring(v) end,
                Get = function() return Input.Text end}
    end

    -- ========================================================
    -- AddMultilineTextbox
    -- ========================================================
    function Elements:AddMultilineTextbox(name, lines, callback)
        lines = lines or 4
        local Frame = Create("Frame", {
            Parent = ItemContainer, BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 30 + lines * 18), ZIndex = 10,
        })
        Create("TextLabel", {
            Parent = Frame, Text = name or "TextBox",
            Font = Enum.Font.Gotham, TextSize = 12,
            TextColor3 = C.Text, BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 16),
            Position = UDim2.new(0, 2, 0, 0),
            TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 10,
        })
        local Input = Create("TextBox", {
            Parent = Frame, Text = "",
            PlaceholderText = "Введите...",
            Font = Enum.Font.Gotham, TextSize = 12,
            TextColor3 = C.Text, BackgroundColor3 = C.Item,
            PlaceholderColor3 = C.SubText,
            Size = UDim2.new(1, 0, 0, lines * 18 + 10),
            Position = UDim2.new(0, 0, 0, 20),
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            TextWrapped = true, MultiLine = true,
            ClearTextOnFocus = false, BorderSizePixel = 0, ZIndex = 10,
        })
        Create("UIPadding", {
            Parent = Input,
            PaddingLeft = UDim.new(0, 8),
            PaddingTop = UDim.new(0, 4),
        })
        Create("UICorner", {Parent = Input, CornerRadius = UDim.new(0, 8)})
        Create("UIStroke", {
            Parent = Input, Color = C.Stroke, Thickness = 1, Transparency = 0.6,
        })
        Input.FocusLost:Connect(function()
            if callback then pcall(callback, Input.Text) end
        end)
        Library.ConfigElements[name] = {
            Set = function(v) Input.Text = tostring(v) end,
            Get = function() return Input.Text end,
        }
        return {Set = function(v) Input.Text = tostring(v) end,
                Get = function() return Input.Text end}
    end
end

Library._Internal.AttachBasicComponents = AttachBasicComponents-- ============================================================
-- ПРОДВИНУТЫЕ КОМПОНЕНТЫ (часть 1)
-- ============================================================
local function AttachAdvancedComponents1(Elements)
    local _I = Library._Internal
    local Create = _I.Create
    local Tween = _I.Tween
    local AddBounce = _I.AddBounce
    local CreateIcon = _I.CreateIcon
    local ICONS = _I.ICONS
    local C = _I.Colors

    local ItemContainer = Elements._ItemContainer

    -- ========================================================
    -- AddKeybind
    -- ========================================================
    function Elements:AddKeybind(name, defaultKey, callback)
        local currentKey = defaultKey or Enum.KeyCode.RightShift
        local listening = false
        local Frame = Create("Frame", {
            Parent = ItemContainer, BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 34), ZIndex = 10,
        })
        Create("TextLabel", {
            Parent = Frame, Text = name or "Keybind",
            Font = Enum.Font.Gotham, TextSize = 12,
            TextColor3 = C.Text, BackgroundTransparency = 1,
            Size = UDim2.new(1, -70, 1, 0),
            Position = UDim2.new(0, 2, 0, 0),
            TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 10,
        })
        local KeyBtn = Create("TextButton", {
            Parent = Frame,
            Text = currentKey and currentKey.Name or "None",
            Font = Enum.Font.GothamBold, TextSize = 11,
            TextColor3 = C.Accent, BackgroundColor3 = C.Item,
            Size = UDim2.new(0, 64, 0, 24),
            Position = UDim2.new(1, -66, 0.5, -12),
            AutoButtonColor = false, BorderSizePixel = 0, ZIndex = 10,
        })
        Create("UICorner", {Parent = KeyBtn, CornerRadius = UDim.new(0, 6)})
        Create("UIStroke", {
            Parent = KeyBtn, Color = C.Stroke, Thickness = 1, Transparency = 0.6,
        })
        AddBounce(KeyBtn)
        local listenConn
        local function stopListen()
            listening = false
            if listenConn then listenConn:Disconnect(); listenConn = nil end
            KeyBtn.Text = currentKey and currentKey.Name or "None"
            Tween(KeyBtn, {TextColor3 = C.Accent}, 0.2)
        end
        local function startListen()
            if listening then stopListen(); return end
            listening = true
            KeyBtn.Text = "..."
            Tween(KeyBtn, {TextColor3 = C.Warning}, 0.2)
            listenConn = UserInputService.InputBegan:Connect(function(input)
                if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
                if input.KeyCode == Enum.KeyCode.Escape then stopListen(); return end
                currentKey = input.KeyCode
                stopListen()
                if callback then pcall(callback, currentKey) end
            end)
        end
        KeyBtn.MouseButton1Click:Connect(startListen)
        Library.ConfigElements[name] = {
            Set = function(kc)
                if typeof(kc) == "EnumItem" then currentKey = kc
                elseif type(kc) == "string" then
                    local ok, k = pcall(function() return Enum.KeyCode[kc] end)
                    if ok then currentKey = k end
                end
                KeyBtn.Text = currentKey and currentKey.Name or "None"
            end,
            Get = function() return currentKey and currentKey.Name end,
        }
        return {Set = function(kc) currentKey = kc; KeyBtn.Text = kc.Name end,
                Get = function() return currentKey end}
    end

    -- ========================================================
    -- AddProgressBar
    -- ========================================================
    function Elements:AddProgressBar(name, min, max)
        min = min or 0; max = max or 100
        local val = min
        local Frame = Create("Frame", {
            Parent = ItemContainer, BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 46), ZIndex = 10,
        })
        Create("TextLabel", {
            Parent = Frame, Text = name or "Progress",
            Font = Enum.Font.Gotham, TextSize = 12,
            TextColor3 = C.Text, BackgroundTransparency = 1,
            Size = UDim2.new(1, -50, 0, 16),
            Position = UDim2.new(0, 2, 0, 0),
            TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 10,
        })
        local ValTxt = Create("TextLabel", {
            Parent = Frame, Text = "0%",
            Font = Enum.Font.GothamBold, TextSize = 12,
            TextColor3 = C.Accent, BackgroundTransparency = 1,
            Size = UDim2.new(0, 44, 0, 16),
            Position = UDim2.new(1, -46, 0, 0),
            TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 10,
        })
        local Track = Create("Frame", {
            Parent = Frame, BackgroundColor3 = Color3.fromRGB(40, 46, 56),
            Size = UDim2.new(1, 0, 0, 8),
            Position = UDim2.new(0, 0, 0, 26),
            BorderSizePixel = 0, ZIndex = 10,
        })
        Create("UICorner", {Parent = Track, CornerRadius = UDim.new(1, 0)})
        local Fill = Create("Frame", {
            Parent = Track, BackgroundColor3 = C.Accent,
            Size = UDim2.new(0, 0, 1, 0),
            BorderSizePixel = 0, ZIndex = 11,
        })
        Create("UICorner", {Parent = Fill, CornerRadius = UDim.new(1, 0)})
        local obj = {Instance = Frame}
        function obj:Set(v)
            val = math.clamp(v, min, max)
            local a = (max - min > 0) and (val - min) / (max - min) or 0
            Tween(Fill, {Size = UDim2.new(a, 0, 1, 0)}, 0.2)
            ValTxt.Text = string.format("%d%%", math.floor(a * 100))
        end
        function obj:Get() return val end
        Library.ConfigElements[name] = {
            Set = function(v) obj:Set(v) end,
            Get = function() return val end,
        }
        return obj
    end

    -- ========================================================
    -- AddStepper (с иконками +/−)
    -- ========================================================
    function Elements:AddStepper(name, min, max, default, callback)
        min = min or 0; max = max or 10
        local val = math.clamp(default or min, min, max)
        local Frame = Create("Frame", {
            Parent = ItemContainer, BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 34), ZIndex = 10,
        })
        Create("TextLabel", {
            Parent = Frame, Text = name or "Stepper",
            Font = Enum.Font.Gotham, TextSize = 12,
            TextColor3 = C.Text, BackgroundTransparency = 1,
            Size = UDim2.new(1, -110, 1, 0),
            Position = UDim2.new(0, 2, 0, 0),
            TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 10,
        })
        -- Минус
        local Minus = Create("TextButton", {
            Parent = Frame, Text = "−",
            Font = Enum.Font.GothamBold, TextSize = 16,
            TextColor3 = C.Text, BackgroundColor3 = C.Item,
            Size = UDim2.new(0, 28, 0, 26),
            Position = UDim2.new(1, -110, 0.5, -13),
            AutoButtonColor = false, BorderSizePixel = 0, ZIndex = 10,
        })
        Create("UICorner", {Parent = Minus, CornerRadius = UDim.new(0, 6)})
        Create("UIStroke", {
            Parent = Minus, Color = C.Stroke, Thickness = 1, Transparency = 0.6,
        })
        AddBounce(Minus)
        -- Значение
        local ValLbl = Create("TextLabel", {
            Parent = Frame, Text = tostring(val),
            Font = Enum.Font.GothamBold, TextSize = 13,
            TextColor3 = C.Accent, BackgroundTransparency = 1,
            Size = UDim2.new(0, 36, 1, 0),
            Position = UDim2.new(1, -80, 0, 0),
            TextXAlignment = Enum.TextXAlignment.Center, ZIndex = 10,
        })
        -- Плюс
        local Plus = Create("TextButton", {
            Parent = Frame, Text = "+",
            Font = Enum.Font.GothamBold, TextSize = 16,
            TextColor3 = C.Text, BackgroundColor3 = C.Item,
            Size = UDim2.new(0, 28, 0, 26),
            Position = UDim2.new(1, -44, 0.5, -13),
            AutoButtonColor = false, BorderSizePixel = 0, ZIndex = 10,
        })
        Create("UICorner", {Parent = Plus, CornerRadius = UDim.new(0, 6)})
        Create("UIStroke", {
            Parent = Plus, Color = C.Stroke, Thickness = 1, Transparency = 0.6,
        })
        AddBounce(Plus)
        local function internalSet(v, fire)
            val = math.clamp(v, min, max)
            ValLbl.Text = tostring(val)
            if fire ~= false and callback then pcall(callback, val) end
        end
        Minus.MouseButton1Click:Connect(function() internalSet(val - 1, true) end)
        Plus.MouseButton1Click:Connect(function() internalSet(val + 1, true) end)
        Library.ConfigElements[name] = {
            Set = function(v) internalSet(v, false) end,
            Get = function() return val end,
        }
        return {Set = internalSet, Get = function() return val end}
    end

    -- ========================================================
    -- AddRadioGroup
    -- ========================================================
    function Elements:AddRadioGroup(name, options, default, callback)
        options = options or {}
        local current = default or options[1]
        local Wrapper = Create("Frame", {
            Parent = ItemContainer, BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 62), ZIndex = 10,
        })
        Create("TextLabel", {
            Parent = Wrapper, Text = name or "RadioGroup",
            Font = Enum.Font.Gotham, TextSize = 12,
            TextColor3 = C.Text, BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 20),
            Position = UDim2.new(0, 2, 0, 0),
            TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 10,
        })
        local Row = Create("Frame", {
            Parent = Wrapper, BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0, 24),
            Size = UDim2.new(1, 0, 0, 32), ZIndex = 10,
        })
        Create("UIListLayout", {
            Parent = Row, FillDirection = Enum.FillDirection.Horizontal,
            Padding = UDim.new(0, 6),
        })
        local buttons = {}
        local function update()
            for _, data in ipairs(buttons) do
                local on = (data.Name == current)
                Tween(data.Btn, {
                    BackgroundColor3 = on and C.Accent or C.Item,
                    TextColor3 = on and Color3.fromRGB(255,255,255) or C.Text,
                }, 0.15)
            end
        end
        for _, opt in ipairs(options) do
            local Btn = Create("TextButton", {
                Parent = Row, Text = tostring(opt),
                Font = Enum.Font.GothamBold, TextSize = 11,
                TextColor3 = C.Text, BackgroundColor3 = C.Item,
                Size = UDim2.new(0, 70, 1, 0),
                AutoButtonColor = false, BorderSizePixel = 0, ZIndex = 10,
            })
            Create("UICorner", {Parent = Btn, CornerRadius = UDim.new(0, 6)})
            Create("UIStroke", {
                Parent = Btn, Color = C.Stroke, Thickness = 1, Transparency = 0.6,
            })
            AddBounce(Btn)
            Btn.MouseButton1Click:Connect(function()
                current = opt; update()
                if callback then pcall(callback, current) end
            end)
            table.insert(buttons, {Name = opt, Btn = Btn})
        end
        update()
        Library.ConfigElements[name] = {
            Set = function(v) current = v; update() end,
            Get = function() return current end,
        }
        return {Set = function(v) current = v; update() end,
                Get = function() return current end}
    end
end

Library._Internal.AttachAdvancedComponents1 = AttachAdvancedComponents1-- ============================================================
-- ПРОДВИНУТЫЕ КОМПОНЕНТЫ (часть 2)
-- ============================================================
local function AttachAdvancedComponents2(Elements)
    local _I = Library._Internal
    local Create = _I.Create
    local Tween = _I.Tween
    local AddBounce = _I.AddBounce
    local CreateIcon = _I.CreateIcon
    local ICONS = _I.ICONS
    local C = _I.Colors

    local ItemContainer = Elements._ItemContainer

    -- ========================================================
    -- AddColorPicker (HSV, ZX-стиль)
    -- ========================================================
    function Elements:AddColorPicker(name, defaultColor, callback)
        local color = defaultColor or C.Accent
        local h, s, v = Color3.toHSV(color)
        local dropped = false
        local Wrapper = Create("Frame", {
            Parent = ItemContainer, BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 30),
            ClipsDescendants = true, ZIndex = 10,
        })
        Create("TextLabel", {
            Parent = Wrapper, Text = name or "Color",
            Font = Enum.Font.Gotham, TextSize = 12,
            TextColor3 = C.Text, BackgroundTransparency = 1,
            Size = UDim2.new(1, -50, 0, 30),
            Position = UDim2.new(0, 2, 0, 0),
            TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 10,
        })
        local Preview = Create("TextButton", {
            Parent = Wrapper, Text = "",
            BackgroundColor3 = color,
            Size = UDim2.new(0, 32, 0, 20),
            Position = UDim2.new(1, -34, 0.5, -10),
            AutoButtonColor = false, BorderSizePixel = 0, ZIndex = 10,
        })
        Create("UICorner", {Parent = Preview, CornerRadius = UDim.new(0, 6)})
        Create("UIStroke", {
            Parent = Preview, Color = Color3.fromRGB(255, 255, 255),
            Transparency = 0.7, Thickness = 1,
        })
        AddBounce(Preview)
        local PickerArea = Create("Frame", {
            Parent = Wrapper, BackgroundColor3 = C.Background,
            Size = UDim2.new(1, 0, 0, 130),
            Position = UDim2.new(0, 0, 0, 34), ZIndex = 10,
        })
        Create("UICorner", {Parent = PickerArea, CornerRadius = UDim.new(0, 8)})
        Create("UIStroke", {
            Parent = PickerArea, Color = C.Stroke, Thickness = 1, Transparency = 0.6,
        })
        local SVMap = Create("TextButton", {
            Parent = PickerArea, Text = "",
            BackgroundColor3 = Color3.fromHSV(h, 1, 1),
            Size = UDim2.new(1, -20, 0, 76),
            Position = UDim2.new(0, 10, 0, 10),
            AutoButtonColor = false, BorderSizePixel = 0, ZIndex = 11,
        })
        Create("UICorner", {Parent = SVMap, CornerRadius = UDim.new(0, 6)})
        -- Белый градиент (S)
        local WhiteGrad = Create("Frame", {
            Parent = SVMap, BackgroundColor3 = Color3.new(1,1,1),
            Size = UDim2.new(1,0,1,0), BorderSizePixel = 0, ZIndex = 12,
        })
        Create("UIGradient", {
            Parent = WhiteGrad,
            Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0),
                NumberSequenceKeypoint.new(1, 1),
            }),
        })
        Create("UICorner", {Parent = WhiteGrad, CornerRadius = UDim.new(0, 6)})
        -- Чёрный градиент (V)
        local BlackGrad = Create("Frame", {
            Parent = SVMap, BackgroundColor3 = Color3.new(0,0,0),
            Size = UDim2.new(1,0,1,0), BorderSizePixel = 0, ZIndex = 13,
        })
        Create("UIGradient", {
            Parent = BlackGrad, Rotation = 90,
            Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 1),
                NumberSequenceKeypoint.new(1, 0),
            }),
        })
        Create("UICorner", {Parent = BlackGrad, CornerRadius = UDim.new(0, 6)})
        -- Маркер SV
        local SVRing = Create("Frame", {
            Parent = SVMap, BackgroundColor3 = Color3.new(1,1,1),
            Size = UDim2.new(0, 10, 0, 10),
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(s, 0, 1 - v, 0),
            BorderSizePixel = 0, ZIndex = 14,
        })
        Create("UICorner", {Parent = SVRing, CornerRadius = UDim.new(1, 0)})
        Create("UIStroke", {Parent = SVRing, Color = Color3.new(0,0,0), Thickness = 1})
        -- Hue bar
        local HueBar = Create("TextButton", {
            Parent = PickerArea, Text = "",
            BackgroundColor3 = Color3.new(1,1,1),
            Size = UDim2.new(1, -20, 0, 12),
            Position = UDim2.new(0, 10, 0, 96),
            AutoButtonColor = false, BorderSizePixel = 0, ZIndex = 11,
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
            BorderSizePixel = 0, ZIndex = 12,
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
            Tween(Wrapper, {Size = UDim2.new(1, 0, 0, dropped and 170 or 30)}, 0.25)
        end)
        updateColor(false)
        Library.ConfigElements[name] = {
            Set = function(hexOrColor)
                if typeof(hexOrColor) == "Color3" then
                    h, s, v = Color3.toHSV(hexOrColor)
                elseif type(hexOrColor) == "string" then
                    local ok, c = pcall(Color3.fromHex, hexOrColor)
                    if ok then h, s, v = Color3.toHSV(c) end
                end
                SVRing.Position = UDim2.new(s, 0, 1 - v, 0)
                HueRing.Position = UDim2.new(h, 0, 0.5, 0)
                updateColor(false)
            end,
            Get = function() return color:ToHex() end,
        }
        return {Set = function(c) h, s, v = Color3.toHSV(c); updateColor(false) end,
                Get = function() return color end}
    end

    -- ========================================================
    -- AddLoader (крутящийся спиннер)
    -- ========================================================
    function Elements:AddLoader(name)
        local Frame = Create("Frame", {
            Parent = ItemContainer, BackgroundColor3 = C.Item,
            Size = UDim2.new(1, 0, 0, 44),
            BorderSizePixel = 0, ZIndex = 10,
        })
        Create("UICorner", {Parent = Frame, CornerRadius = UDim.new(0, 8)})
        Create("TextLabel", {
            Parent = Frame, Text = name or "Загрузка...",
            Font = Enum.Font.Gotham, TextSize = 12,
            TextColor3 = C.Text, BackgroundTransparency = 1,
            Size = UDim2.new(1, -62, 1, 0),
            Position = UDim2.new(0, 50, 0, 0),
            TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 10,
        })
        local Ring = Create("Frame", {
            Parent = Frame, BackgroundTransparency = 1,
            Size = UDim2.new(0, 22, 0, 22),
            Position = UDim2.new(0, 14, 0.5, -11), ZIndex = 10,
        })
        local RingVisual = Create("Frame", {
            Parent = Ring, BackgroundColor3 = C.Accent,
            Size = UDim2.new(1, 0, 1, 0),
            BorderSizePixel = 0, ZIndex = 10,
        })
        Create("UICorner", {Parent = RingVisual, CornerRadius = UDim.new(1, 0)})
        Create("UIGradient", {
            Parent = RingVisual,
            Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0),
                NumberSequenceKeypoint.new(0.5, 0.85),
                NumberSequenceKeypoint.new(1, 1),
            }),
        })
        local RingHole = Create("Frame", {
            Parent = Ring, BackgroundColor3 = C.Item,
            Size = UDim2.new(1, -8, 1, -8),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            AnchorPoint = Vector2.new(0.5, 0.5),
            BorderSizePixel = 0, ZIndex = 11,
        })
        Create("UICorner", {Parent = RingHole, CornerRadius = UDim.new(1, 0)})
        task.spawn(function()
            while Ring.Parent do
                Ring.Rotation = (Ring.Rotation + 6) % 360
                game:GetService("RunService").Heartbeat:Wait()
            end
        end)
        return Frame
    end

    -- ========================================================
    -- AddDivider
    -- ========================================================
    function Elements:AddDivider()
        local Wrap = Create("Frame", {
            Parent = ItemContainer, BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 9), ZIndex = 9,
        })
        Create("Frame", {
            Parent = Wrap, BackgroundColor3 = C.Stroke,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 1),
            Position = UDim2.new(0, 0, 0.5, 0), ZIndex = 9,
        })
        return Wrap
    end

    -- ========================================================
    -- AddDividerText (линия + текст по центру)
    -- ========================================================
    function Elements:AddDividerText(text)
        local Wrap = Create("Frame", {
            Parent = ItemContainer, BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 20), ZIndex = 9,
        })
        Create("Frame", {
            Parent = Wrap, BackgroundColor3 = C.Stroke,
            BorderSizePixel = 0,
            Size = UDim2.new(0.4, 0, 0, 1),
            Position = UDim2.new(0, 0, 0.5, 0), ZIndex = 9,
        })
        Create("Frame", {
            Parent = Wrap, BackgroundColor3 = C.Stroke,
            BorderSizePixel = 0,
            Size = UDim2.new(0.4, 0, 0, 1),
            Position = UDim2.new(0.6, 0, 0.5, 0), ZIndex = 9,
        })
        Create("TextLabel", {
            Parent = Wrap, Text = text or "",
            Font = Enum.Font.GothamBold, TextSize = 11,
            TextColor3 = C.SubText, BackgroundTransparency = 1,
            Size = UDim2.new(0.2, 0, 1, 0),
            Position = UDim2.new(0.4, 0, 0, 0),
            TextXAlignment = Enum.TextXAlignment.Center, ZIndex = 10,
        })
        return Wrap
    end

    -- ========================================================
    -- AddLabel
    -- ========================================================
    function Elements:AddLabel(text, color)
        return Create("TextLabel", {
            Parent = ItemContainer, Text = text or "",
            Font = Enum.Font.Gotham, TextSize = 12,
            TextColor3 = color or C.SubText,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 22),
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true, ZIndex = 9,
        })
    end

    -- ========================================================
    -- AddParagraph (карточка с текстом)
    -- ========================================================
    function Elements:AddParagraph(title, content)
        local Card = Create("Frame", {
            Parent = ItemContainer, BackgroundColor3 = C.Background,
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BorderSizePixel = 0, ZIndex = 9,
        })
        Create("UICorner", {Parent = Card, CornerRadius = UDim.new(0, 8)})
        Create("UIStroke", {
            Parent = Card, Color = C.Stroke,
            Thickness = 1, Transparency = 0.6,
        })
        Create("UIPadding", {
            Parent = Card,
            PaddingTop = UDim.new(0, 10),
            PaddingBottom = UDim.new(0, 10),
            PaddingLeft = UDim.new(0, 12),
            PaddingRight = UDim.new(0, 12),
        })
        Create("UIListLayout", {
            Parent = Card, SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 4),
        })
        if title then
            Create("TextLabel", {
                Parent = Card, Text = title,
                Font = Enum.Font.GothamBold, TextSize = 12,
                TextColor3 = C.Text, BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 18),
                TextXAlignment = Enum.TextXAlignment.Left,
                LayoutOrder = 1, ZIndex = 10,
            })
        end
        Create("TextLabel", {
            Parent = Card, Text = content or "",
            Font = Enum.Font.Gotham, TextSize = 11,
            TextColor3 = C.SubText, BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            LayoutOrder = 2, ZIndex = 10,
        })
        return Card
    end
end

Library._Internal.AttachAdvancedComponents2 = AttachAdvancedComponents2-- ============================================================
-- CONFIG MANAGER
-- ============================================================
local function AttachConfigManager(Elements)
    local _I = Library._Internal
    local Create = _I.Create
    local Tween = _I.Tween
    local AddBounce = _I.AddBounce
    local CreateIcon = _I.CreateIcon
    local ICONS = _I.ICONS
    local C = _I.Colors
    local FS = _I.FileSystem

    local ItemContainer = Elements._ItemContainer

    function Elements:AddConfigManager(folderName)
        folderName = folderName or "SenseiConfigs"
        if not FS.isfolder(folderName) then FS.makefolder(folderName) end

        local ManagerFrame = Create("Frame", {
            Parent = ItemContainer, BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 260), ZIndex = 10,
        })

        -- Поиск
        local Search = Create("TextBox", {
            Parent = ManagerFrame,
            PlaceholderText = "Поиск сохранений...",
            Font = Enum.Font.Gotham, TextSize = 12,
            TextColor3 = C.Text, BackgroundColor3 = C.Item,
            PlaceholderColor3 = C.SubText,
            Size = UDim2.new(1, 0, 0, 30),
            Position = UDim2.new(0, 0, 0, 0),
            TextXAlignment = Enum.TextXAlignment.Left,
            ClearTextOnFocus = false, BorderSizePixel = 0, ZIndex = 10,
        })
        Create("UIPadding", {Parent = Search, PaddingLeft = UDim.new(0, 10)})
        Create("UICorner", {Parent = Search, CornerRadius = UDim.new(0, 8)})
        Create("UIStroke", {
            Parent = Search, Color = C.Stroke, Thickness = 1, Transparency = 0.6,
        })

        -- Список сохранений
        local Monitor = Create("ScrollingFrame", {
            Parent = ManagerFrame, BackgroundColor3 = C.Background,
            Size = UDim2.new(1, 0, 0, 115),
            Position = UDim2.new(0, 0, 0, 38),
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = C.Stroke,
            BorderSizePixel = 0,
            CanvasSize = UDim2.new(0, 0, 0, 0), ZIndex = 10,
        })
        Create("UICorner", {Parent = Monitor, CornerRadius = UDim.new(0, 8)})
        Create("UIStroke", {
            Parent = Monitor, Color = C.Stroke, Thickness = 1, Transparency = 0.6,
        })
        local MonitorLayout = Create("UIListLayout", {
            Parent = Monitor, SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 5),
        })
        Create("UIPadding", {
            Parent = Monitor,
            PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 6),
            PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6),
        })
        MonitorLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Monitor.CanvasSize = UDim2.new(0, 0, 0, MonitorLayout.AbsoluteContentSize.Y + 12)
        end)

        local deleteMode = false
        local editMode = false
        local selectedForDelete = {}
        local editTargetFile = ""

        -- Контролы
        local Controls = Create("Frame", {
            Parent = ManagerFrame, BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 100),
            Position = UDim2.new(0, 0, 0, 160), ZIndex = 10,
        })

        local NameBox = Create("TextBox", {
            Parent = Controls,
            PlaceholderText = "Имя сохранения...",
            Font = Enum.Font.Gotham, TextSize = 12,
            TextColor3 = C.Text, BackgroundColor3 = C.Item,
            PlaceholderColor3 = C.SubText,
            Size = UDim2.new(1, 0, 0, 30),
            Position = UDim2.new(0, 0, 0, 0),
            TextXAlignment = Enum.TextXAlignment.Left,
            ClearTextOnFocus = false, BorderSizePixel = 0, ZIndex = 10,
        })
        Create("UIPadding", {Parent = NameBox, PaddingLeft = UDim.new(0, 10)})
        Create("UICorner", {Parent = NameBox, CornerRadius = UDim.new(0, 8)})
        Create("UIStroke", {
            Parent = NameBox, Color = C.Stroke, Thickness = 1, Transparency = 0.6,
        })

        local CreateBtn = Create("TextButton", {
            Parent = Controls, Text = "Создать",
            Font = Enum.Font.GothamBold, TextSize = 12,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundColor3 = C.Accent,
            Size = UDim2.new(0.5, -4, 0, 30),
            Position = UDim2.new(0, 0, 0, 40),
            AutoButtonColor = false, BorderSizePixel = 0, ZIndex = 10,
        })
        Create("UICorner", {Parent = CreateBtn, CornerRadius = UDim.new(0, 8)})
        AddBounce(CreateBtn)

        local DeleteTogBtn = Create("TextButton", {
            Parent = Controls, Text = "Удаление: ВЫКЛ",
            Font = Enum.Font.GothamBold, TextSize = 12,
            TextColor3 = C.Text, BackgroundColor3 = C.Item,
            Size = UDim2.new(0.5, -4, 0, 30),
            Position = UDim2.new(0.5, 4, 0, 40),
            AutoButtonColor = false, BorderSizePixel = 0, ZIndex = 10,
        })
        Create("UICorner", {Parent = DeleteTogBtn, CornerRadius = UDim.new(0, 8)})
        AddBounce(DeleteTogBtn)

        local ActionArea = Create("Frame", {
            Parent = Controls, BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 30),
            Position = UDim2.new(0, 0, 0, 40),
            Visible = false, ZIndex = 10,
        })
        local ConfirmActionBtn = Create("TextButton", {
            Parent = ActionArea, Text = "Подтвердить",
            Font = Enum.Font.GothamBold, TextSize = 12,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundColor3 = C.Danger,
            Size = UDim2.new(0.5, -4, 1, 0),
            Position = UDim2.new(0, 0, 0, 0),
            AutoButtonColor = false, BorderSizePixel = 0, ZIndex = 10,
        })
        Create("UICorner", {Parent = ConfirmActionBtn, CornerRadius = UDim.new(0, 8)})
        AddBounce(ConfirmActionBtn)
        local CancelActionBtn = Create("TextButton", {
            Parent = ActionArea, Text = "Отмена",
            Font = Enum.Font.GothamBold, TextSize = 12,
            TextColor3 = C.Text, BackgroundColor3 = C.Item,
            Size = UDim2.new(0.5, -4, 1, 0),
            Position = UDim2.new(0.5, 4, 0, 0),
            AutoButtonColor = false, BorderSizePixel = 0, ZIndex = 10,
        })
        Create("UICorner", {Parent = CancelActionBtn, CornerRadius = UDim.new(0, 8)})
        AddBounce(CancelActionBtn)

        -- Всплывающее подтверждение удаления
        local ConfirmPopup = Create("Frame", {
            Parent = ManagerFrame, BackgroundColor3 = C.Background,
            Size = UDim2.new(1, -20, 1, -20),
            Position = UDim2.new(0, 10, 0, 10),
            ZIndex = 60, BackgroundTransparency = 1, Visible = false,
            BorderSizePixel = 0,
        })
        Create("UICorner", {Parent = ConfirmPopup, CornerRadius = UDim.new(0, 10)})
        Create("UIStroke", {
            Parent = ConfirmPopup, Color = C.Danger,
            Thickness = 1.2, Transparency = 1,
        })
        local PTitle = Create("TextLabel", {
            Parent = ConfirmPopup, Text = "Удалить выбранные?",
            Font = Enum.Font.GothamBold, TextSize = 14,
            TextColor3 = Color3.fromRGB(255, 90, 100), BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 26),
            Position = UDim2.new(0, 0, 0, 40),
            ZIndex = 61, TextTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Center,
        })
        local PDesc = Create("TextLabel", {
            Parent = ConfirmPopup, Text = "Сохранения будут удалены навсегда.",
            Font = Enum.Font.Gotham, TextSize = 12,
            TextColor3 = C.SubText, BackgroundTransparency = 1,
            Size = UDim2.new(1, -30, 0, 40),
            Position = UDim2.new(0, 15, 0, 70),
            ZIndex = 61, TextTransparency = 1, TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Center,
        })
        local PYes = Create("TextButton", {
            Parent = ConfirmPopup, Text = "Да",
            Font = Enum.Font.GothamBold, TextSize = 13,
            TextColor3 = Color3.fromRGB(255,255,255),
            BackgroundColor3 = C.Danger,
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
            TextColor3 = C.Text, BackgroundColor3 = C.Item,
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

        -- Обновление списка
        local function refreshMonitor()
            for _, v in ipairs(Monitor:GetChildren()) do
                if v:IsA("Frame") then v:Destroy() end
            end
            selectedForDelete = {}

            local files = FS.listfiles(folderName)
            for _, filepath in ipairs(files) do
                local rawName = filepath:match("([^/\\]+)%.json$")
                if rawName then
                    local display = rawName:gsub("_%d+$", ""):gsub("_%d+%.%d+$", "")
                    local Row = Create("Frame", {
                        Parent = Monitor, BackgroundColor3 = C.Item,
                        Size = UDim2.new(1, 0, 0, 34),
                        BorderSizePixel = 0, ZIndex = 11,
                    })
                    Create("UICorner", {Parent = Row, CornerRadius = UDim.new(0, 8)})
                    Create("TextLabel", {
                        Parent = Row, Text = display,
                        Font = Enum.Font.Gotham, TextSize = 12,
                        TextColor3 = C.Text, BackgroundTransparency = 1,
                        Size = UDim2.new(1, -80, 1, 0),
                        Position = UDim2.new(0, 10, 0, 0),
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 11,
                    })
                    -- Load
                    local LoadBtn = Create("TextButton", {
                        Parent = Row, Text = "Load",
                        Font = Enum.Font.GothamBold, TextSize = 10,
                        TextColor3 = Color3.fromRGB(255,255,255),
                        BackgroundColor3 = C.Success,
                        Size = UDim2.new(0, 34, 0, 24),
                        Position = UDim2.new(1, -74, 0.5, -12),
                        AutoButtonColor = false, BorderSizePixel = 0, ZIndex = 11,
                    })
                    Create("UICorner", {Parent = LoadBtn, CornerRadius = UDim.new(0, 6)})
                    AddBounce(LoadBtn)
                    -- Edit
                    local EditBtn = Create("TextButton", {
                        Parent = Row, Text = "Edit",
                        Font = Enum.Font.GothamBold, TextSize = 10,
                        TextColor3 = Color3.fromRGB(255,255,255),
                        BackgroundColor3 = Color3.fromRGB(180, 120, 50),
                        Size = UDim2.new(0, 34, 0, 24),
                        Position = UDim2.new(1, -38, 0.5, -12),
                        AutoButtonColor = false, BorderSizePixel = 0, ZIndex = 11,
                    })
                    Create("UICorner", {Parent = EditBtn, CornerRadius = UDim.new(0, 6)})
                    AddBounce(EditBtn)

                    local SelectionMask = Create("TextButton", {
                        Parent = Row, Text = "",
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, -84, 1, 0),
                        ZIndex = 12, AutoButtonColor = false,
                    })
                    SelectionMask.MouseButton1Click:Connect(function()
                        if deleteMode then
                            if selectedForDelete[filepath] then
                                selectedForDelete[filepath] = nil
                                Tween(Row, {BackgroundColor3 = C.Item}, 0.2)
                            else
                                selectedForDelete[filepath] = true
                                Tween(Row, {BackgroundColor3 = C.Danger}, 0.2)
                            end
                        end
                    end)

                    LoadBtn.MouseButton1Click:Connect(function()
                        if deleteMode or editMode then return end
                        local ok, data = pcall(function()
                            return game:GetService("HttpService"):JSONDecode(FS.readfile(filepath))
                        end)
                        if ok and type(data) == "table" then
                            for k, val in pairs(data) do
                                local el = Library.ConfigElements[k]
                                if el and el.Set then pcall(el.Set, val) end
                            end
                            Library:Notify({
                                Title = "Загружено",
                                Description = display, Kind = "success",
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

        -- Сохранение
        local function executeSave(saveName)
            local payload = {}
            for k, el in pairs(Library.ConfigElements) do
                if el.Get then
                    local ok, v = pcall(el.Get)
                    if ok then payload[k] = v end
                end
            end
            local ok, encoded = pcall(function()
                return game:GetService("HttpService"):JSONEncode(payload)
            end)
            if not ok then
                Library:Notify({Title = "Ошибка", Description = "Не удалось сохранить.", Kind = "error"})
                return
            end
            local uniqueKey = tostring(math.floor(tick()))
            local finalPath = folderName .. "/" .. saveName .. "_" .. uniqueKey .. ".json"
            pcall(FS.writefile, finalPath, encoded)
            refreshMonitor()
            Library:Notify({Title = "Сохранено", Description = saveName, Kind = "success"})
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
                BackgroundColor3 = deleteMode and C.Danger or C.Item,
            }, 0.2)
            ActionArea.Visible = deleteMode
            CreateBtn.Visible = not deleteMode
            if deleteMode then
                ConfirmActionBtn.Text = "Удалить"
                ConfirmActionBtn.BackgroundColor3 = C.Danger
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
                    pcall(function() FS.delfile(editTargetFile) end)
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
                pcall(function() FS.delfile(file) end)
            end
            deleteMode = false
            DeleteTogBtn.Text = "Удаление: ВЫКЛ"
            DeleteTogBtn.BackgroundColor3 = C.Item
            ActionArea.Visible = false
            CreateBtn.Visible = true
            refreshMonitor()
            Library:Notify({Title = "Удалено", Description = "Сохранения стёрты.", Kind = "success"})
            hidePopup()
        end)
        PNo.MouseButton1Click:Connect(hidePopup)

        CancelActionBtn.MouseButton1Click:Connect(function()
            editMode = false
            deleteMode = false
            DeleteTogBtn.Text = "Удаление: ВЫКЛ"
            DeleteTogBtn.BackgroundColor3 = C.Item
            ActionArea.Visible = false
            CreateBtn.Visible = true
            DeleteTogBtn.Visible = true
            NameBox.Text = ""
            refreshMonitor()
        end)

        -- Поиск
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

Library._Internal.AttachConfigManager = AttachConfigManager-- ============================================================
-- ДОПОЛНИТЕЛЬНЫЕ УТИЛИТЫ
-- (PlayerList, SetTheme, SetTransparency, Confirm-диалог)
-- ============================================================
local function AttachExtraMethods(Elements)
    local _I = Library._Internal
    local Create = _I.Create
    local Tween = _I.Tween
    local AddBounce = _I.AddBounce
    local CreateIcon = _I.CreateIcon
    local ICONS = _I.ICONS
    local C = _I.Colors

    local ItemContainer = Elements._ItemContainer

    -- ========================================================
    -- AddPlayerList
    -- ========================================================
    function Elements:AddPlayerList(config)
        config = config or {}
        local Players = game:GetService("Players")
        local LocalPlayer = Players.LocalPlayer

        local Holder = Create("Frame", {
            Parent = ItemContainer, BackgroundColor3 = C.Background,
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BorderSizePixel = 0, ZIndex = 10,
        })
        Create("UICorner", {Parent = Holder, CornerRadius = UDim.new(0, 8)})
        Create("UIStroke", {
            Parent = Holder, Color = C.Stroke,
            Thickness = 1, Transparency = 0.6,
        })
        Create("UIPadding", {
            Parent = Holder,
            PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8),
            PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8),
        })
        local ListLayout = Create("UIListLayout", {
            Parent = Holder, SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 4),
        })

        local function refresh()
            for _, c in ipairs(Holder:GetChildren()) do
                if c:IsA("TextButton") or c:IsA("Frame") then c:Destroy() end
            end
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer then
                    local Row = Create("TextButton", {
                        Parent = Holder, Text = "  " .. plr.Name,
                        Font = Enum.Font.Gotham, TextSize = 12,
                        TextColor3 = C.Text, BackgroundColor3 = C.Item,
                        Size = UDim2.new(1, 0, 0, 30),
                        AutoButtonColor = false, BorderSizePixel = 0,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        ZIndex = 11,
                    })
                    Create("UICorner", {Parent = Row, CornerRadius = UDim.new(0, 6)})
                    if config.OnPlayer then
                        Row.MouseButton1Click:Connect(function()
                            config.OnPlayer(plr)
                        end)
                    end
                end
            end
        end
        refresh()

        -- Кнопка обновить
        local RefreshBtn = Create("TextButton", {
            Parent = Holder, Text = "Обновить",
            Font = Enum.Font.GothamBold, TextSize = 11,
            TextColor3 = Color3.fromRGB(255,255,255),
            BackgroundColor3 = C.Accent,
            Size = UDim2.new(1, 0, 0, 28),
            AutoButtonColor = false, BorderSizePixel = 0, ZIndex = 11,
        })
        Create("UICorner", {Parent = RefreshBtn, CornerRadius = UDim.new(0, 6)})
        AddBounce(RefreshBtn)
        RefreshBtn.MouseButton1Click:Connect(refresh)

        Players.PlayerAdded:Connect(refresh)
        Players.PlayerRemoving:Connect(function() task.wait(0.1) refresh() end)

        return {Refresh = refresh}
    end
end

Library._Internal.AttachExtraMethods = AttachExtraMethods

-- ============================================================
-- ФИНАЛЬНЫЙ ПАТЧ (правильный порядок применения)
-- ============================================================
local _origCreateWindow = Library.CreateWindow
function Library:CreateWindow(opts)
    local w = _origCreateWindow(self, opts)

    -- 1. Навешиваем методы Tab/Page/Section
    _I.AttachTabMethods(w)

    -- 2. Оборачиваем CreateTab → CreatePage → CreateSection
    --    чтобы внутри CreateSection появились ВСЕ компоненты
    local _origCreateTab = w.CreateTab
    function w:CreateTab(...)
        local tab = _origCreateTab(self, ...)

        local _origCreatePage = tab.CreatePage
        function tab:CreatePage(...)
            local page = _origCreatePage(self, ...)

            local _origCreateSection = page.CreateSection
            function page:CreateSection(...)
                local elements = _origCreateSection(self, ...)

                -- Приклеиваем ВСЕ наборы компонентов
                _I.AttachBasicComponents(elements)
                _I.AttachAdvancedComponents1(elements)
                _I.AttachAdvancedComponents2(elements)
                _I.AttachConfigManager(elements)
                _I.AttachExtraMethods(elements)

                return elements
            end
            return page
        end
        return tab
    end

    return w
end-- ============================================================
-- ПУБЛИЧНЫЕ МЕТОДЫ WINDOW
-- (SetTheme, SetTransparency, Confirm, Destroy)
-- ============================================================
local function AttachWindowPublicMethods(Window)
    local _I = Library._Internal
    local Create = _I.Create
    local Tween = _I.Tween
    local AddBounce = _I.AddBounce
    local CreateIcon = _I.CreateIcon
    local ICONS = _I.ICONS
    local C = _I.Colors

    -- ========================================================
    -- SetTheme (смена акцента)
    -- ========================================================
    function Window:SetTheme(accentColor)
        if typeof(accentColor) ~= "Color3" then return end
        C.Accent = accentColor
        C.AccentLight = accentColor:Lerp(Color3.new(1,1,1), 0.4)

        -- Обновляем табы
        if self.CurrentTab then
            Tween(self.CurrentTab.Indicator, {BackgroundColor3 = accentColor}, 0.3)
        end
        -- Обновляем все компоненты через UpdateTheme
        for _, el in ipairs(self.Elements or {}) do
            if el.UpdateTheme then pcall(el.UpdateTheme, accentColor) end
        end
    end

    -- ========================================================
    -- SetTransparency (прозрачность фона окна)
    -- ========================================================
    function Window:SetTransparency(val)
        val = math.clamp(val or 0, 0, 0.8)
        Tween(self.MainFrame, {BackgroundTransparency = val}, 0.3)
    end

    -- ========================================================
    -- Confirm (модальный диалог подтверждения)
    -- ========================================================
    function Window:Confirm(config)
        config = config or {}
        local ScreenGui = self.ScreenGui

        local Backdrop = Create("TextButton", {
            Parent = ScreenGui, Text = "",
            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            AutoButtonColor = false, BorderSizePixel = 0,
            ZIndex = 4999,
        })
        Tween(Backdrop, {BackgroundTransparency = 0.5}, 0.25)

        local Popup = Create("Frame", {
            Parent = ScreenGui, BackgroundColor3 = C.Background,
            Size = UDim2.new(0, 300, 0, 150),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            AnchorPoint = Vector2.new(0.5, 0.5),
            ZIndex = 5000, BorderSizePixel = 0,
            BackgroundTransparency = 1,
        })
        Create("UICorner", {Parent = Popup, CornerRadius = UDim.new(0, 12)})
        Create("UIStroke", {
            Parent = Popup, Color = C.Accent,
            Thickness = 1.4, Transparency = 1,
        })

        local Title = Create("TextLabel", {
            Parent = Popup, Text = config.Title or "Подтверждение",
            Font = Enum.Font.GothamBold, TextSize = 15,
            TextColor3 = C.Text, BackgroundTransparency = 1,
            Size = UDim2.new(1, -30, 0, 24),
            Position = UDim2.new(0, 15, 0, 18),
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTransparency = 1, ZIndex = 5001,
        })
        local Body = Create("TextLabel", {
            Parent = Popup, Text = config.Content or "",
            Font = Enum.Font.Gotham, TextSize = 12,
            TextColor3 = C.SubText, BackgroundTransparency = 1,
            Size = UDim2.new(1, -30, 0, 40),
            Position = UDim2.new(0, 15, 0, 46),
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            TextWrapped = true, TextTransparency = 1, ZIndex = 5001,
        })

        local Yes = Create("TextButton", {
            Parent = Popup, Text = config.YesText or "Да",
            Font = Enum.Font.GothamBold, TextSize = 12,
            TextColor3 = Color3.fromRGB(255,255,255),
            BackgroundColor3 = C.Accent,
            Size = UDim2.new(0, 130, 0, 32),
            Position = UDim2.new(0, 15, 1, -48),
            AutoButtonColor = false, BorderSizePixel = 0,
            BackgroundTransparency = 1, TextTransparency = 1, ZIndex = 5001,
        })
        Create("UICorner", {Parent = Yes, CornerRadius = UDim.new(0, 8)})
        AddBounce(Yes)

        local No = Create("TextButton", {
            Parent = Popup, Text = config.NoText or "Отмена",
            Font = Enum.Font.GothamBold, TextSize = 12,
            TextColor3 = C.Text, BackgroundColor3 = C.Item,
            Size = UDim2.new(0, 130, 0, 32),
            Position = UDim2.new(1, -145, 1, -48),
            AutoButtonColor = false, BorderSizePixel = 0,
            BackgroundTransparency = 1, TextTransparency = 1, ZIndex = 5001,
        })
        Create("UICorner", {Parent = No, CornerRadius = UDim.new(0, 8)})
        AddBounce(No)

        -- Анимация появления
        Tween(Popup, {BackgroundTransparency = 0}, 0.3)
        Tween(Popup:FindFirstChildOfClass("UIStroke"), {Transparency = 0.3}, 0.3)
        Tween(Title, {TextTransparency = 0}, 0.3)
        Tween(Body, {TextTransparency = 0}, 0.3)
        Tween(Yes, {BackgroundTransparency = 0, TextTransparency = 0}, 0.3)
        Tween(No, {BackgroundTransparency = 0, TextTransparency = 0}, 0.3)

        local closed = false
        local function close(result)
            if closed then return end
            closed = true
            if config.Callback then pcall(config.Callback, result) end
            Tween(Backdrop, {BackgroundTransparency = 1}, 0.25)
            Tween(Popup, {BackgroundTransparency = 1}, 0.25)
            Tween(Popup:FindFirstChildOfClass("UIStroke"), {Transparency = 1}, 0.25)
            Tween(Title, {TextTransparency = 1}, 0.25)
            Tween(Body, {TextTransparency = 1}, 0.25)
            Tween(Yes, {BackgroundTransparency = 1, TextTransparency = 1}, 0.25)
            Tween(No, {BackgroundTransparency = 1, TextTransparency = 1}, 0.25)
            task.wait(0.3)
            Popup:Destroy()
            Backdrop:Destroy()
        end

        Yes.MouseButton1Click:Connect(function() close(true) end)
        No.MouseButton1Click:Connect(function() close(false) end)
        Backdrop.MouseButton1Click:Connect(function() close(false) end)
    end

    -- ========================================================
    -- Destroy (полное удаление)
    -- ========================================================
    function Window:Destroy()
        if self.ScreenGui then self.ScreenGui:Destroy() end
    end
end

Library._Internal.AttachWindowPublicMethods = AttachWindowPublicMethods-- ============================================================
-- ФИНАЛЬНЫЙ ПАТЧ CreateWindow
-- ============================================================
local _finalOrigCreateWindow = Library.CreateWindow

function Library:CreateWindow(options)
    local Window = _finalOrigCreateWindow(self, options)

    -- 1) Прикрепляем публичные методы окна
    Library._Internal.AttachWindowPublicMethods(Window)

    -- 2) Прикрепляем методы CreateTab / CreatePage / CreateSection
    Library._Internal.AttachTabMethods(Window)

    -- 3) Оборачиваем цепочку CreateTab → CreatePage → CreateSection,
    --    чтобы внутри CreateSection приклеивались ВСЕ компоненты
    local origCreateTab = Window.CreateTab
    function Window:CreateTab(...)
        local TabObj = origCreateTab(self, ...)

        local origCreatePage = TabObj.CreatePage
        function TabObj:CreatePage(...)
            local PageObj = origCreatePage(self, ...)

            local origCreateSection = PageObj.CreateSection
            function PageObj:CreateSection(...)
                local Elements = origCreateSection(self, ...)

                -- Все наборы компонентов
                Library._Internal.AttachBasicComponents(Elements)
                Library._Internal.AttachAdvancedComponents1(Elements)
                Library._Internal.AttachAdvancedComponents2(Elements)
                Library._Internal.AttachConfigManager(Elements)
                Library._Internal.AttachExtraMethods(Elements)

                return Elements
            end
            return PageObj
        end
        return TabObj
    end

    return Window
end

-- ============================================================
-- EXPORT
-- ============================================================
return Library