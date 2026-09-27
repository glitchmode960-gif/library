--[[
    Sensei Hub Library
    Version: 1.0.0
    Author: glitchmode960-gif
    Load: local Sensei = loadstring(game:HttpGet("https://raw.githubusercontent.com/glitchmode960-gif/library/main/library.lua"))()
]]

-- ============================================================
-- SERVICES
-- ============================================================
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService      = game:GetService("HttpService")
local CoreGui          = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- ============================================================
-- LIBRARY OBJECT
-- ============================================================
local Sensei = {}
Sensei.__index = Sensei
Sensei.Version = "1.0.0"
Sensei.Brand = "Sensei Hub"
Sensei.Flags = {}
Sensei.Windows = {}
Sensei.Connections = {}

-- ============================================================
-- SAFE FILE SYSTEM
-- ============================================================
local FS = {
    isfolder   = isfolder   or function() return true end,
    makefolder = makefolder or function() end,
    writefile  = writefile  or function() end,
    readfile   = readfile   or function() return "{}" end,
    listfiles  = listfiles  or function() return {} end,
    delfile    = delfile    or function() end,
    isfile     = isfile     or function() return false end,
}

local function SafeWrite(path, data)
    pcall(function()
        local split = path:split("/")
        split[#split] = nil
        local folder = table.concat(split, "/")
        if folder ~= "" and not FS.isfolder(folder) then
            FS.makefolder(folder)
        end
        FS.writefile(path, data)
    end)
end

-- ============================================================
-- THEMES
-- ============================================================
local Themes = {}

local function MakeTheme(name, c)
    return {
        Name        = name,
        Accent      = c.accent,
        AccentLight = c.accentLight,
        AccentDark  = c.accentDark,
        Background  = c.bg,
        Card        = c.card,
        Item        = c.item,
        Hover       = c.hover,
        Text        = c.text,
        SubText     = c.subtext,
        Stroke      = c.stroke,
        Danger      = Color3.fromRGB(210, 65, 75),
        Success     = Color3.fromRGB(50, 165, 95),
        Warning     = Color3.fromRGB(255, 190, 70),
    }
end

Themes.Sensei = MakeTheme("Sensei", {
    accent      = Color3.fromRGB(0, 170, 255),
    accentLight = Color3.fromRGB(120, 220, 255),
    accentDark  = Color3.fromRGB(0, 100, 180),
    bg          = Color3.fromRGB(15, 18, 24),
    card        = Color3.fromRGB(24, 28, 36),
    item        = Color3.fromRGB(34, 40, 50),
    hover       = Color3.fromRGB(44, 52, 64),
    text        = Color3.fromRGB(240, 245, 252),
    subtext     = Color3.fromRGB(150, 165, 185),
    stroke      = Color3.fromRGB(45, 65, 100),
})

Themes.Purple = MakeTheme("Purple", {
    accent      = Color3.fromRGB(138, 43, 226),
    accentLight = Color3.fromRGB(200, 150, 255),
    accentDark  = Color3.fromRGB(90, 30, 150),
    bg          = Color3.fromRGB(15, 12, 22),
    card        = Color3.fromRGB(25, 20, 35),
    item        = Color3.fromRGB(35, 28, 45),
    hover       = Color3.fromRGB(50, 40, 65),
    text        = Color3.fromRGB(245, 240, 252),
    subtext     = Color3.fromRGB(165, 150, 185),
    stroke      = Color3.fromRGB(70, 55, 95),
})

Themes.Red = MakeTheme("Red", {
    accent      = Color3.fromRGB(235, 70, 85),
    accentLight = Color3.fromRGB(255, 150, 160),
    accentDark  = Color3.fromRGB(150, 40, 50),
    bg          = Color3.fromRGB(22, 12, 12),
    card        = Color3.fromRGB(35, 20, 20),
    item        = Color3.fromRGB(48, 28, 28),
    hover       = Color3.fromRGB(65, 40, 40),
    text        = Color3.fromRGB(252, 240, 240),
    subtext     = Color3.fromRGB(200, 170, 170),
    stroke      = Color3.fromRGB(90, 55, 55),
})

Themes.Green = MakeTheme("Green", {
    accent      = Color3.fromRGB(50, 200, 120),
    accentLight = Color3.fromRGB(150, 240, 190),
    accentDark  = Color3.fromRGB(30, 120, 70),
    bg          = Color3.fromRGB(12, 20, 15),
    card        = Color3.fromRGB(20, 32, 25),
    item        = Color3.fromRGB(28, 45, 35),
    hover       = Color3.fromRGB(40, 60, 50),
    text        = Color3.fromRGB(240, 252, 245),
    subtext     = Color3.fromRGB(170, 200, 185),
    stroke      = Color3.fromRGB(50, 85, 65),
})

Themes.Light = MakeTheme("Light", {
    accent      = Color3.fromRGB(80, 100, 220),
    accentLight = Color3.fromRGB(140, 160, 255),
    accentDark  = Color3.fromRGB(50, 60, 150),
    bg          = Color3.fromRGB(240, 240, 245),
    card        = Color3.fromRGB(225, 225, 235),
    item        = Color3.fromRGB(210, 210, 225),
    hover       = Color3.fromRGB(195, 195, 215),
    text        = Color3.fromRGB(30, 35, 50),
    subtext     = Color3.fromRGB(90, 100, 120),
    stroke      = Color3.fromRGB(180, 185, 200),
})

local CurrentTheme = Themes.Sensei

-- ============================================================
-- ICONS
-- ============================================================
local Icons = {
    Minimize = "rbxassetid://6031090990",
    Close    = "rbxassetid://6031091004",
    Expand   = "rbxassetid://6031094667",
    Settings = "rbxassetid://6031280882",
    Copy     = "rbxassetid://6031154871",
    Lock     = "rbxassetid://6031082533",
}

-- ============================================================
-- UTILITY: Create
-- ============================================================
local function Create(className, props)
    local inst = Instance.new(className)
    for k, v in pairs(props or {}) do
        inst[k] = v
    end
    if className == "TextLabel" or className == "TextButton" or className == "TextBox" then
        if not (props and props.TextColor3) then
            inst.TextColor3 = CurrentTheme.Text
        end
        inst.TextTransparency = 0
    end
    return inst
end

-- ============================================================
-- UTILITY: Tween
-- ============================================================
local function Tween(instance, properties, duration)
    local info = TweenInfo.new(
        duration or 0.25,
        Enum.EasingStyle.Quart,
        Enum.EasingDirection.Out
    )
    local tw = TweenService:Create(instance, info, properties)
    tw:Play()
    return tw
end

-- ============================================================
-- UTILITY: AddBounce
-- ============================================================
local function AddBounce(button, factor)
    factor = factor or 0.95
    local scale = button:FindFirstChild("UIScale")
        or Create("UIScale", { Parent = button, Scale = 1 })

    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            Tween(scale, { Scale = factor }, 0.1)
        end
    end)

    button.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            Tween(scale, { Scale = 1 }, 0.15)
        end
    end)
end

-- ============================================================
-- UTILITY: MakeDraggable
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
-- UTILITY: CreateIcon
-- ============================================================
local function CreateIcon(parent, iconId, size, pos, color, zIndex)
    return Create("ImageLabel", {
        Parent = parent,
        BackgroundTransparency = 1,
        Image = iconId,
        ImageColor3 = color or CurrentTheme.Text,
        Size = UDim2.new(0, size or 18, 0, size or 18),
        Position = pos or UDim2.new(0, 0, 0.5, -(size or 18) / 2),
        ZIndex = zIndex or 10,
    })
end

-- ============================================================
-- NOTIFY
-- ============================================================
local NotifContainer

function Sensei:Notify(options)
    if not NotifContainer then return end
    options = options or {}

    local title = options.Title or "Уведомление"
    local desc = options.Description or options.Content or ""
    local duration = options.Duration or 3
    local kind = options.Kind or "info"

    local accent = CurrentTheme.Accent
    local symbol = "i"
    if kind == "success" then accent = CurrentTheme.Success; symbol = "✓"
    elseif kind == "error" then accent = CurrentTheme.Danger; symbol = "✕"
    elseif kind == "warning" then accent = CurrentTheme.Warning; symbol = "!" end

    local notif = Create("Frame", {
        Parent = NotifContainer,
        BackgroundColor3 = CurrentTheme.Background,
        Size = UDim2.new(1, 0, 0, 62),
        BackgroundTransparency = 1,
        ZIndex = 201,
        ClipsDescendants = true,
    })
    Create("UICorner", { Parent = notif, CornerRadius = UDim.new(0, 10) })

    local stroke = Create("UIStroke", {
        Parent = notif, Color = accent, Thickness = 1.4, Transparency = 1,
    })

    local iconCircle = Create("Frame", {
        Parent = notif,
        Size = UDim2.new(0, 28, 0, 28),
        Position = UDim2.new(0, 12, 0, 17),
        BackgroundColor3 = accent,
        BackgroundTransparency = 0.85,
        ZIndex = 202,
    })
    Create("UICorner", { Parent = iconCircle, CornerRadius = UDim.new(1, 0) })
    Create("TextLabel", {
        Parent = iconCircle,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = symbol,
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        TextColor3 = accent,
        TextTransparency = 1,
        ZIndex = 203,
    })

    Create("TextLabel", {
        Parent = notif,
        Text = title,
        Font = Enum.Font.GothamBold, TextSize = 13,
        TextColor3 = CurrentTheme.Text, BackgroundTransparency = 1,
        Position = UDim2.new(0, 50, 0, 12),
        Size = UDim2.new(1, -60, 0, 16),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTransparency = 1, ZIndex = 202,
    })

    Create("TextLabel", {
        Parent = notif,
        Text = desc,
        Font = Enum.Font.Gotham, TextSize = 11,
        TextColor3 = CurrentTheme.SubText, BackgroundTransparency = 1,
        Position = UDim2.new(0, 50, 0, 30),
        Size = UDim2.new(1, -60, 0, 22),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true, TextTransparency = 1, ZIndex = 202,
    })

    Tween(notif, { BackgroundTransparency = 0 }, 0.3)
    Tween(stroke, { Transparency = 0.2 }, 0.3)
    task.delay(0.05, function()
        for _, d in ipairs(notif:GetDescendants()) do
            if d:IsA("TextLabel") then
                Tween(d, { TextTransparency = 0 }, 0.3)
            end
        end
    end)

    task.delay(duration, function()
        Tween(notif, { BackgroundTransparency = 1 }, 0.35)
        Tween(stroke, { Transparency = 1 }, 0.35)
        for _, d in ipairs(notif:GetDescendants()) do
            if d:IsA("TextLabel") then
                Tween(d, { TextTransparency = 1 }, 0.35)
            end
        end
        task.wait(0.4)
        notif:Destroy()
    end)
end

-- ============================================================
-- THEME API
-- ============================================================
function Sensei:SetTheme(name)
    if not Themes[name] then return end
    CurrentTheme = Themes[name]
    Sensei._CurrentTheme = CurrentTheme
end

function Sensei:GetTheme() return CurrentTheme end

function Sensei:GetThemes()
    local list = {}
    for name in pairs(Themes) do table.insert(list, name) end
    return list
end

function Sensei:IsValidTheme(name)
    return Themes[name] ~= nil
end

function Sensei:GetInfo()
    return {
        Version = Sensei.Version,
        Brand = Sensei.Brand,
        Themes = Sensei:GetThemes(),
    }
end

-- ============================================================
-- EXPORT INTERNAL
-- ============================================================
Sensei._Internal = {
    Create = Create,
    Tween = Tween,
    AddBounce = AddBounce,
    MakeDraggable = MakeDraggable,
    CreateIcon = CreateIcon,
    Icons = Icons,
    Themes = Themes,
    FS = FS,
    SafeWrite = SafeWrite,
    Services = {
        Players = Players,
        RunService = RunService,
        TweenService = TweenService,
        UserInputService = UserInputService,
        HttpService = HttpService,
        CoreGui = CoreGui,
        LocalPlayer = LocalPlayer,
        Mouse = Mouse,
    },
    SetNotifContainer = function(c) NotifContainer = c end,
    GetCurrentTheme = function() return CurrentTheme end,
    GetThemes = function() return Themes end,
}-- ============================================================
-- CREATE WINDOW
-- ============================================================
local _I = Sensei._Internal
local Create = _I.Create
local Tween = _I.Tween
local AddBounce = _I.AddBounce
local MakeDraggable = _I.MakeDraggable
local CreateIcon = _I.CreateIcon
local Icons = _I.Icons
local FS = _I.FS
local SafeWrite = _I.SafeWrite
local Services = _I.Services
local LocalPlayer = Services.LocalPlayer
local CoreGui = Services.CoreGui

function Sensei:CreateWindow(options)
    options = options or {}

    local Title       = options.Title or "Sensei Hub"
    local SubTitle    = options.SubTitle or "Powered by Sensei"
    local ScriptFolder= options.ScriptFolder or "sensei"
    local Size        = options.Size or UDim2.fromOffset(500, 340)

    -- ========================================================
    -- ScreenGui
    -- ========================================================
    local ScreenGui = Create("ScreenGui", {
        Name = "Sensei_UI_" .. tostring(math.random(100000, 999999)),
        Parent = CoreGui,
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    })
    if syn and syn.protect_gui then
        pcall(function() syn.protect_gui(ScreenGui) end)
    end

    -- ========================================================
    -- Notification Container
    -- ========================================================
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
    _I.SetNotifContainer(NotifContainer)

    -- ========================================================
    -- Main Frame
    -- ========================================================
    local MainFrame = Create("Frame", {
        Parent = ScreenGui,
        BackgroundColor3 = _I.GetCurrentTheme().Background,
        Size = Size,
        Position = UDim2.new(0.5, -Size.X.Offset / 2, 0.5, -Size.Y.Offset / 2),
        Active = true,
        BorderSizePixel = 0,
        ClipsDescendants = true,
    })
    local MainScale = Create("UIScale", { Parent = MainFrame, Scale = 1 })
    Create("UICorner", { Parent = MainFrame, CornerRadius = UDim.new(0, 12) })
    local MainStroke = Create("UIStroke", {
        Parent = MainFrame,
        Color = _I.GetCurrentTheme().Stroke,
        Thickness = 1.2,
        Transparency = 0.2,
    })

    MakeDraggable(MainFrame, MainFrame)

    -- ========================================================
    -- Top Bar
    -- ========================================================
    local TopBar = Create("Frame", {
        Parent = MainFrame,
        BackgroundColor3 = _I.GetCurrentTheme().Card,
        BackgroundTransparency = 0.15,
        Size = UDim2.new(1, 0, 0, 36),
        Position = UDim2.new(0, 0, 0, 0),
        BorderSizePixel = 0,
        Active = true,
    })
    Create("UICorner", { Parent = TopBar, CornerRadius = UDim.new(0, 12) })
    Create("Frame", {
        Parent = TopBar,
        BackgroundColor3 = _I.GetCurrentTheme().Card,
        BackgroundTransparency = 0.15,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 14),
        Position = UDim2.new(0, 0, 1, -14),
    })
    MakeDraggable(TopBar, MainFrame)

    -- Иконка логотипа
    CreateIcon(TopBar, Icons.Settings, 18, UDim2.new(0, 12, 0.5, -9), _I.GetCurrentTheme().Accent, 8)

    -- Заголовок
    local TitleContainer = Create("Frame", {
        Parent = TopBar,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 250, 1, 0),
        Position = UDim2.new(0, 38, 0, 0),
        ZIndex = 7,
    })
    Create("TextLabel", {
        Parent = TitleContainer,
        Text = Title,
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextColor3 = _I.GetCurrentTheme().Text,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 4),
        Size = UDim2.new(1, 0, 0, 14),
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    Create("TextLabel", {
        Parent = TitleContainer,
        Text = SubTitle,
        Font = Enum.Font.Gotham,
        TextSize = 9,
        TextColor3 = _I.GetCurrentTheme().SubText,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 19),
        Size = UDim2.new(1, 0, 0, 12),
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    -- Кнопки минимизации и закрытия
    local MinimizeButton = Create("TextButton", {
        Parent = TopBar,
        Text = "",
        BackgroundColor3 = _I.GetCurrentTheme().Item,
        Size = UDim2.new(0, 26, 0, 26),
        Position = UDim2.new(1, -62, 0.5, -13),
        AutoButtonColor = false,
        BorderSizePixel = 0,
    })
    Create("UICorner", { Parent = MinimizeButton, CornerRadius = UDim.new(0, 8) })
    CreateIcon(MinimizeButton, Icons.Minimize, 14, UDim2.new(0.5, -7, 0.5, -7), _I.GetCurrentTheme().Warning)
    AddBounce(MinimizeButton)

    local CloseButton = Create("TextButton", {
        Parent = TopBar,
        Text = "",
        BackgroundColor3 = _I.GetCurrentTheme().Item,
        Size = UDim2.new(0, 26, 0, 26),
        Position = UDim2.new(1, -32, 0.5, -13),
        AutoButtonColor = false,
        BorderSizePixel = 0,
    })
    Create("UICorner", { Parent = CloseButton, CornerRadius = UDim.new(0, 8) })
    CreateIcon(CloseButton, Icons.Close, 14, UDim2.new(0.5, -7, 0.5, -7), _I.GetCurrentTheme().Danger)
    AddBounce(CloseButton)

    -- ========================================================
    -- Sidebar
    -- ========================================================
    local Sidebar = Create("Frame", {
        Parent = MainFrame,
        BackgroundColor3 = _I.GetCurrentTheme().Card,
        BackgroundTransparency = 0.15,
        Size = UDim2.new(0, 130, 1, -36),
        Position = UDim2.new(0, 0, 0, 36),
        Active = true,
        BorderSizePixel = 0,
    })

    -- Аватар + ник игрока
    local ProfileFrame = Create("Frame", {
        Parent = Sidebar,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 76),
    })

    local Avatar = Create("ImageLabel", {
        Parent = ProfileFrame,
        Size = UDim2.new(0, 40, 0, 40),
        Position = UDim2.new(0.5, -20, 0, 10),
        BackgroundColor3 = _I.GetCurrentTheme().Item,
        BorderSizePixel = 0,
    })
    Create("UICorner", { Parent = Avatar, CornerRadius = UDim.new(1, 0) })
    Create("UIStroke", {
        Parent = Avatar,
        Color = _I.GetCurrentTheme().Accent,
        Thickness = 1.5,
        Transparency = 0.3,
    })
    pcall(function()
        local thumb = Players:GetUserThumbnailAsync(
            LocalPlayer.UserId,
            Enum.ThumbnailType.HeadShot,
            Enum.ThumbnailSize.Size100x100
        )
        Avatar.Image = thumb
    end)

    Create("TextLabel", {
        Parent = ProfileFrame,
        Text = LocalPlayer.DisplayName or LocalPlayer.Name,
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        TextColor3 = _I.GetCurrentTheme().Text,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 54),
        Size = UDim2.new(1, 0, 0, 14),
        TextXAlignment = Enum.TextXAlignment.Center,
        TextTruncate = Enum.TextTruncate.AtEnd,
    })
    Create("TextLabel", {
        Parent = ProfileFrame,
        Text = "@" .. LocalPlayer.Name,
        Font = Enum.Font.Gotham,
        TextSize = 9,
        TextColor3 = _I.GetCurrentTheme().SubText,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 66),
        Size = UDim2.new(1, 0, 0, 12),
        TextXAlignment = Enum.TextXAlignment.Center,
        TextTruncate = Enum.TextTruncate.AtEnd,
    })

    -- Контейнер табов
    local TabContainer = Create("ScrollingFrame", {
        Parent = Sidebar,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -10, 1, -90),
        Position = UDim2.new(0, 5, 0, 84),
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = _I.GetCurrentTheme().Stroke,
        BorderSizePixel = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0),
    })
    Create("UIListLayout", {
        Parent = TabContainer,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 4),
    })
    TabContainer:GetChildren()[1]:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        TabContainer.CanvasSize = UDim2.new(0, 0, 0, TabContainer:GetChildren()[1].AbsoluteContentSize.Y + 10)
    end)

    -- Разделитель
    Create("Frame", {
        Parent = MainFrame,
        BackgroundColor3 = _I.GetCurrentTheme().Stroke,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 1, 1, -36),
        Position = UDim2.new(0, 130, 0, 36),
    })

    -- ========================================================
    -- Content Area
    -- ========================================================
    local ContentArea = Create("Frame", {
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -135, 1, -36),
        Position = UDim2.new(0, 135, 0, 36),
        Active = true,
    })

    -- ========================================================
    -- Minibar (свернутое окно)
    -- ========================================================
    local Minibar = Create("Frame", {
        Parent = ScreenGui,
        BackgroundColor3 = _I.GetCurrentTheme().Card,
        Size = UDim2.new(0, 180, 0, 42),
        Position = UDim2.new(0.5, -90, 1, -60),
        Visible = false,
        Active = true,
        BorderSizePixel = 0,
        ZIndex = 10,
    })
    Create("UICorner", { Parent = Minibar, CornerRadius = UDim.new(0, 10) })
    Create("UIStroke", {
        Parent = Minibar,
        Color = _I.GetCurrentTheme().Accent,
        Thickness = 1.4,
        Transparency = 0.3,
    })

    CreateIcon(Minibar, Icons.Settings, 20, UDim2.new(0, 12, 0.5, -10), _I.GetCurrentTheme().Accent)

    Create("TextLabel", {
        Parent = Minibar,
        Text = Title,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextColor3 = _I.GetCurrentTheme().Text,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -80, 1, 0),
        Position = UDim2.new(0, 40, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
    })

    local MinibarExpand = Create("TextButton", {
        Parent = Minibar,
        Text = "",
        BackgroundColor3 = _I.GetCurrentTheme().Item,
        Size = UDim2.new(0, 28, 0, 28),
        Position = UDim2.new(1, -34, 0.5, -14),
        AutoButtonColor = false,
        BorderSizePixel = 0,
        ZIndex = 11,
    })
    Create("UICorner", { Parent = MinibarExpand, CornerRadius = UDim.new(0, 8) })
    CreateIcon(MinibarExpand, Icons.Expand, 14, UDim2.new(0.5, -7, 0.5, -7), _I.GetCurrentTheme().Accent)
    AddBounce(MinibarExpand)

    MakeDraggable(Minibar, Minibar)

    MinibarExpand.MouseButton1Click:Connect(function()
        Minibar.Visible = false
        MainFrame.Visible = true
        MainScale.Scale = 0.9
        Tween(MainScale, { Scale = 1 }, 0.3)
    end)

    -- ========================================================
    -- Минимизация
    -- ========================================================
    MinimizeButton.MouseButton1Click:Connect(function()
        MainScale.Scale = 0.9
        Tween(MainScale, { Scale = 0.85 }, 0.25)
        task.wait(0.2)
        MainFrame.Visible = false
        Minibar.Visible = true
        Minibar.Position = UDim2.new(0.5, -90, 1, -60)
    end)

    -- Закрытие
    CloseButton.MouseButton1Click:Connect(function()
        Tween(MainScale, { Scale = 0.85 }, 0.25)
        task.wait(0.25)
        ScreenGui:Destroy()
    end)

    -- ========================================================
    -- Window API
    -- ========================================================
    local Window = {
        Tabs = {},
        CurrentTab = nil,
        MainFrame = MainFrame,
        Sidebar = Sidebar,
        TabContainer = TabContainer,
        ContentArea = ContentArea,
        ScreenGui = ScreenGui,
        ScriptFolder = ScriptFolder,
        Minibar = Minibar,
        TopBar = TopBar,
        Flags = {},
    }

    function Window:SelectTab(tab)
        if typeof(tab) == "number" then
            tab = self.Tabs[tab]
        end
        if tab and tab.Select then
            tab:Select()
        end
    end

    function Window:Minimize()
        MinimizeButton.MouseButton1Click:Fire()
    end

    function Window:Destroy()
        ScreenGui:Destroy()
    end

    function Window:SetTitle(text)
        TitleContainer:GetChildren()[1].Text = tostring(text)
    end

    function Window:SetSubTitle(text)
        TitleContainer:GetChildren()[2].Text = tostring(text)
    end

    function Window:GetTitle()
        return TitleContainer:GetChildren()[1].Text
    end

    function Window:GetSubTitle()
        return TitleContainer:GetChildren()[2].Text
    end

    table.insert(Sensei.Windows, Window)

    return Window
end-- ============================================================
-- ATTACH TAB METHODS
-- ============================================================
local _I = Sensei._Internal
local Create = _I.Create
local Tween = _I.Tween
local AddBounce = _I.AddBounce
local CreateIcon = _I.CreateIcon
local Icons = _I.Icons

local function AttachTabMethods(Window)
    -- ========================================================
    -- CreateTab
    -- ========================================================
    function Window:CreateTab(tabName, tabIcon)
        tabName = tabName or "Tab"
        tabIcon = tabIcon or "Home"

        local TabContainer = Window.TabContainer
        local ContentArea = Window.ContentArea

        -- Кнопка таба
        local TabBtn = Create("TextButton", {
            Parent = TabContainer,
            Text = "",
            BackgroundColor3 = _I.GetCurrentTheme().Item,
            BackgroundTransparency = 0.4,
            Size = UDim2.new(1, 0, 0, 30),
            AutoButtonColor = false,
            BorderSizePixel = 0,
        })
        Create("UICorner", { Parent = TabBtn, CornerRadius = UDim.new(0, 8) })
        AddBounce(TabBtn, 0.97)

        -- Индикатор слева
        local Indicator = Create("Frame", {
            Parent = TabBtn,
            BackgroundColor3 = _I.GetCurrentTheme().Accent,
            Size = UDim2.new(0, 3, 0, 0),
            Position = UDim2.new(0, 0, 0.5, 0),
            AnchorPoint = Vector2.new(0, 0.5),
            BorderSizePixel = 0,
        })
        Create("UICorner", { Parent = Indicator, CornerRadius = UDim.new(1, 0) })

        -- Иконка
        local TabIconImg = CreateIcon(TabBtn, Icons.Settings, 14, UDim2.new(0, 10, 0.5, -7), _I.GetCurrentTheme().SubText, 5)

        -- Текст
        local TabText = Create("TextLabel", {
            Parent = TabBtn,
            Text = tabName,
            Font = Enum.Font.GothamMedium,
            TextSize = 12,
            TextColor3 = _I.GetCurrentTheme().SubText,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -30, 1, 0),
            Position = UDim2.new(0, 28, 0, 0),
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            ZIndex = 5,
        })

        -- Контейнер для контента таба
        local TabContent = Create("Frame", {
            Parent = ContentArea,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Visible = false,
        })

        -- ScrollingFrame внутри контента
        local TabScroll = Create("ScrollingFrame", {
            Parent = TabContent,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -10, 1, -10),
            Position = UDim2.new(0, 5, 0, 5),
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = _I.GetCurrentTheme().Stroke,
            BorderSizePixel = 0,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
        })

        Create("UIListLayout", {
            Parent = TabScroll,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 8),
        })
        Create("UIPadding", {
            Parent = TabScroll,
            PaddingTop = UDim.new(0, 6),
            PaddingBottom = UDim.new(0, 6),
            PaddingLeft = UDim.new(0, 2),
            PaddingRight = UDim.new(0, 2),
        })

        -- Объект таба
        local Tab = {
            Name = tabName,
            Icon = tabIcon,
            Button = TabBtn,
            Content = TabContent,
            Scroll = TabScroll,
            Indicator = Indicator,
            TextLabel = TabText,
            IconLabel = TabIconImg,
            IsSelected = false,
        }

        -- ====================================================
        -- Select (выбор таба)
        -- ====================================================
        function Tab:Select()
            -- Снимаем предыдущий
            if Window.CurrentTab and Window.CurrentTab ~= self then
                local prev = Window.CurrentTab
                Tween(prev.Button, { BackgroundTransparency = 0.4 }, 0.2)
                Tween(prev.Indicator, { Size = UDim2.new(0, 3, 0, 0) }, 0.2)
                Tween(prev.TextLabel, { TextColor3 = _I.GetCurrentTheme().SubText }, 0.2)
                if prev.IconLabel then
                    Tween(prev.IconLabel, { ImageColor3 = _I.GetCurrentTheme().SubText }, 0.2)
                end
                prev.Content.Visible = false
                prev.IsSelected = false
            end

            -- Активируем текущий
            Window.CurrentTab = self
            self.IsSelected = true
            self.Content.Visible = true

            Tween(self.Button, { BackgroundTransparency = 0 }, 0.2)
            Tween(self.Indicator, { Size = UDim2.new(0, 3, 0, 16) }, 0.25)
            Tween(self.TextLabel, { TextColor3 = _I.GetCurrentTheme().Text }, 0.2)
            if self.IconLabel then
                Tween(self.IconLabel, { ImageColor3 = _I.GetCurrentTheme().Accent }, 0.2)
            end
        end

        TabBtn.MouseButton1Click:Connect(function()
            Tab:Select()
        end)

        -- Регистрируем таб
        table.insert(Window.Tabs, Tab)
        if #Window.Tabs == 1 then
            Tab:Select()
        end

        return Tab
    end

    -- ========================================================
    -- CreateSection
    -- ========================================================
    function Window:CreateSection(tab, sectionName)
        if not tab or not tab.Scroll then return end

        local SectionContainer = Create("Frame", {
            Parent = tab.Scroll,
            BackgroundColor3 = _I.GetCurrentTheme().Card,
            Size = UDim2.new(1, 0, 0, 30),
            AutomaticSize = Enum.AutomaticSize.Y,
            ClipsDescendants = false,
            BorderSizePixel = 0,
        })
        Create("UICorner", { Parent = SectionContainer, CornerRadius = UDim.new(0, 10) })
        Create("UIStroke", {
            Parent = SectionContainer,
            Color = _I.GetCurrentTheme().Stroke,
            Thickness = 1,
            Transparency = 0.5,
        })

        -- Заголовок секции с цветной полоской
        local TitleRow = Create("Frame", {
            Parent = SectionContainer,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 28),
        })
        Create("Frame", {
            Parent = TitleRow,
            BackgroundColor3 = _I.GetCurrentTheme().Accent,
            BorderSizePixel = 0,
            Size = UDim2.new(0, 3, 0, 12),
            Position = UDim2.new(0, 10, 0.5, -6),
        })
        Create("TextLabel", {
            Parent = TitleRow,
            Text = sectionName or "Section",
            Font = Enum.Font.GothamBold,
            TextSize = 12,
            TextColor3 = _I.GetCurrentTheme().Text,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -30, 1, 0),
            Position = UDim2.new(0, 20, 0, 0),
            TextXAlignment = Enum.TextXAlignment.Left,
        })

        -- Контейнер для элементов
        local ItemContainer = Create("Frame", {
            Parent = SectionContainer,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 0),
            Position = UDim2.new(0, 0, 0, 28),
            AutomaticSize = Enum.AutomaticSize.Y,
        })
        Create("UIPadding", {
            Parent = ItemContainer,
            PaddingTop = UDim.new(0, 4),
            PaddingBottom = UDim.new(0, 10),
            PaddingLeft = UDim.new(0, 10),
            PaddingRight = UDim.new(0, 10),
        })
        Create("UIListLayout", {
            Parent = ItemContainer,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 8),
        })

        -- Возвращаем контейнер, чтобы добавлять элементы
        local Section = {
            Frame = SectionContainer,
            Container = ItemContainer,
            Name = sectionName,
        }

        return Section
    end
end

Sensei._Internal.AttachTabMethods = AttachTabMethods-- ============================================================
-- COMPONENTS: Button, Toggle
-- ============================================================
local _I = Sensei._Internal
local Create = _I.Create
local Tween = _I.Tween
local AddBounce = _I.AddBounce
local CreateIcon = _I.CreateIcon
local Icons = _I.Icons

local function AttachBasicComponents(Section, Tab)
    local Container = Section.Container

    -- ========================================================
    -- Button
    -- ========================================================
    Section.AddButton = function(self, config)
        config = config or {}
        local name = config.Name or "Button"
        local callback = config.Callback
        local debounce = config.Debounce or 0.3

        local Btn = Create("TextButton", {
            Parent = Container,
            Text = "",
            BackgroundColor3 = _I.GetCurrentTheme().Item,
            Size = UDim2.new(1, 0, 0, 32),
            AutoButtonColor = false,
            BorderSizePixel = 0,
        })
        Create("UICorner", { Parent = Btn, CornerRadius = UDim.new(0, 8) })
        Create("UIStroke", {
            Parent = Btn,
            Color = _I.GetCurrentTheme().Stroke,
            Thickness = 1,
            Transparency = 0.6,
        })
        AddBounce(Btn)

        Create("TextLabel", {
            Parent = Btn,
            Text = name,
            Font = Enum.Font.GothamMedium,
            TextSize = 12,
            TextColor3 = _I.GetCurrentTheme().Text,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -30, 1, 0),
            Position = UDim2.new(0, 12, 0, 0),
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            ZIndex = 5,
        })

        local lastClick = 0
        Btn.MouseButton1Click:Connect(function()
            if (tick() - lastClick) < debounce then return end
            lastClick = tick()
            if callback then pcall(callback) end
        end)

        return Btn
    end

    -- ========================================================
    -- Toggle
    -- ========================================================
    Section.AddToggle = function(self, config)
        config = config or {}
        local name = config.Name or "Toggle"
        local default = config.Default or false
        local callback = config.Callback
        local flag = config.Flag

        -- Читаем из флагов
        if flag and Sensei.Flags[flag] ~= nil then
            default = Sensei.Flags[flag] and true or false
        end

        local state = default
        local Frame = Create("Frame", {
            Parent = Container,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 26),
        })

        Create("TextLabel", {
            Parent = Frame,
            Text = name,
            Font = Enum.Font.Gotham,
            TextSize = 12,
            TextColor3 = _I.GetCurrentTheme().Text,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -60, 1, 0),
            Position = UDim2.new(0, 2, 0, 0),
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
        })

        local Lever = Create("TextButton", {
            Parent = Frame,
            Text = "",
            BackgroundColor3 = state and _I.GetCurrentTheme().Accent or Color3.fromRGB(45, 50, 60),
            Size = UDim2.new(0, 40, 0, 22),
            Position = UDim2.new(1, -42, 0.5, -11),
            AutoButtonColor = false,
            BorderSizePixel = 0,
        })
        Create("UICorner", { Parent = Lever, CornerRadius = UDim.new(1, 0) })
        AddBounce(Lever)

        local Knob = Create("Frame", {
            Parent = Lever,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            Size = UDim2.new(0, 16, 0, 16),
            Position = state and UDim2.new(1, -18, 0.5, -8)
                            or UDim2.new(0, 2, 0.5, -8),
            BorderSizePixel = 0,
        })
        Create("UICorner", { Parent = Knob, CornerRadius = UDim.new(1, 0) })

        local function apply()
            Tween(Lever, {
                BackgroundColor3 = state and _I.GetCurrentTheme().Accent or Color3.fromRGB(45, 50, 60),
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
            if flag then Sensei.Flags[flag] = state end
            if fire ~= false and callback then pcall(callback, state) end
        end

        Lever.MouseButton1Click:Connect(function()
            internalSet(not state, true)
        end)

        local obj = {
            Value = state,
            Set = function(v) internalSet(v, true) end,
            Get = function() return state end,
        }

        -- Авто-вызов callback при загрузке, если flag установлен
        if flag and Sensei.Flags[flag] ~= nil and callback then
            task.defer(function() pcall(callback, state) end)
        end

        return obj
    end
end

Sensei._Internal.AttachBasicComponents = AttachBasicComponents-- ============================================================
-- COMPONENTS: Slider, Dropdown
-- ============================================================
local _I = Sensei._Internal
local Create = _I.Create
local Tween = _I.Tween
local AddBounce = _I.AddBounce
local CreateIcon = _I.CreateIcon
local Icons = _I.Icons
local UserInputService = _I.Services.UserInputService

local function AttachAdvancedComponents(Section)
    local Container = Section.Container

    -- ========================================================
    -- Slider
    -- ========================================================
    Section.AddSlider = function(self, config)
        config = config or {}
        local name = config.Name or "Slider"
        local min = config.Min or 0
        local max = config.Max or 100
        local increment = config.Increment or 1
        local default = config.Default or min
        local callback = config.Callback
        local flag = config.Flag
        local suffix = config.Suffix or ""

        if flag and type(Sensei.Flags[flag]) == "number" then
            default = Sensei.Flags[flag]
        end
        local val = math.clamp(default, min, max)

        local Frame = Create("Frame", {
            Parent = Container,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 46),
        })

        Create("TextLabel", {
            Parent = Frame,
            Text = name,
            Font = Enum.Font.Gotham,
            TextSize = 12,
            TextColor3 = _I.GetCurrentTheme().Text,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -60, 0, 16),
            Position = UDim2.new(0, 2, 0, 0),
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
        })

        local ValLabel = Create("TextLabel", {
            Parent = Frame,
            Text = tostring(math.floor(val)) .. suffix,
            Font = Enum.Font.GothamBold,
            TextSize = 12,
            TextColor3 = _I.GetCurrentTheme().Accent,
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 54, 0, 16),
            Position = UDim2.new(1, -56, 0, 0),
            TextXAlignment = Enum.TextXAlignment.Right,
        })

        local Track = Create("Frame", {
            Parent = Frame,
            BackgroundColor3 = Color3.fromRGB(40, 46, 56),
            Size = UDim2.new(1, 0, 0, 6),
            Position = UDim2.new(0, 0, 0, 26),
            BorderSizePixel = 0,
        })
        Create("UICorner", { Parent = Track, CornerRadius = UDim.new(1, 0) })

        local alpha = (max - min > 0) and (val - min) / (max - min) or 0
        local Fill = Create("Frame", {
            Parent = Track,
            BackgroundColor3 = _I.GetCurrentTheme().Accent,
            Size = UDim2.new(alpha, 0, 1, 0),
            BorderSizePixel = 0,
        })
        Create("UICorner", { Parent = Fill, CornerRadius = UDim.new(1, 0) })

        local Knob = Create("Frame", {
            Parent = Fill,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            Size = UDim2.new(0, 14, 0, 14),
            Position = UDim2.new(1, -7, 0.5, -7),
            BorderSizePixel = 0,
        })
        Create("UICorner", { Parent = Knob, CornerRadius = UDim.new(1, 0) })

        local function apply()
            local a = (max - min > 0) and (val - min) / (max - min) or 0
            Tween(Fill, { Size = UDim2.new(a, 0, 1, 0) }, 0.08)
            ValLabel.Text = tostring(math.floor(val)) .. suffix
        end

        local function internalSet(v, fire)
            val = math.clamp(v, min, max)
            apply()
            if flag then Sensei.Flags[flag] = val end
            if fire ~= false and callback then pcall(callback, val) end
        end

        -- Активная зона
        local Hit = Create("TextButton", {
            Parent = Frame,
            Text = "",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 24),
            Position = UDim2.new(0, 0, 0, 17),
            AutoButtonColor = false,
        })

        local dragging = false
        local function update(input)
            local rel = math.clamp(
                (input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
            local raw = min + (max - min) * rel
            local snapped = math.floor(raw / increment + 0.5) * increment
            internalSet(snapped, true)
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

        local obj = {
            Value = val,
            Set = function(v) internalSet(v, true) end,
            Get = function() return val end,
        }

        if flag and Sensei.Flags[flag] ~= nil and callback then
            task.defer(function() pcall(callback, val) end)
        end

        return obj
    end

    -- ========================================================
    -- Dropdown
    -- ========================================================
    Section.AddDropdown = function(self, config)
        config = config or {}
        local name = config.Name or "Dropdown"
        local options = config.Options or {}
        local default = config.Default or options[1]
        local callback = config.Callback
        local flag = config.Flag
        local multi = config.MultiSelect or false

        if flag and Sensei.Flags[flag] ~= nil then
            default = Sensei.Flags[flag]
        end

        local selected = multi and (type(default) == "table" and default or {}) or default
        local dropped = false
        local optionButtons = {}

        local Wrapper = Create("Frame", {
            Parent = Container,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 50),
            ClipsDescendants = true,
        })

        Create("TextLabel", {
            Parent = Wrapper,
            Text = name,
            Font = Enum.Font.Gotham,
            TextSize = 12,
            TextColor3 = _I.GetCurrentTheme().Text,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 16),
            Position = UDim2.new(0, 2, 0, 0),
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
        })

        local MainBtn = Create("TextButton", {
            Parent = Wrapper,
            Text = "",
            BackgroundColor3 = _I.GetCurrentTheme().Item,
            Size = UDim2.new(1, 0, 0, 28),
            Position = UDim2.new(0, 0, 0, 20),
            AutoButtonColor = false,
            BorderSizePixel = 0,
        })
        Create("UICorner", { Parent = MainBtn, CornerRadius = UDim.new(0, 8) })
        Create("UIStroke", {
            Parent = MainBtn,
            Color = _I.GetCurrentTheme().Stroke,
            Thickness = 1,
            Transparency = 0.6,
        })
        AddBounce(MainBtn, 0.98)

        local SelectedLabel = Create("TextLabel", {
            Parent = MainBtn,
            Text = "",
            Font = Enum.Font.Gotham,
            TextSize = 12,
            TextColor3 = _I.GetCurrentTheme().Text,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -32, 1, 0),
            Position = UDim2.new(0, 10, 0, 0),
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
        })

        local Arrow = Create("TextLabel", {
            Parent = MainBtn,
            Text = "▼",
            Font = Enum.Font.GothamBold,
            TextSize = 10,
            TextColor3 = _I.GetCurrentTheme().SubText,
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 16, 1, 0),
            Position = UDim2.new(1, -22, 0, 0),
        })

        local ListFrame = Create("ScrollingFrame", {
            Parent = Wrapper,
            BackgroundColor3 = _I.GetCurrentTheme().Background,
            Size = UDim2.new(1, 0, 0, 0),
            Position = UDim2.new(0, 0, 0, 50),
            CanvasSize = UDim2.new(0, 0, 0, #options * 26),
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = _I.GetCurrentTheme().Stroke,
            BorderSizePixel = 0,
            Visible = false,
        })
        Create("UICorner", { Parent = ListFrame, CornerRadius = UDim.new(0, 8) })
        Create("UIListLayout", {
            Parent = ListFrame,
            SortOrder = Enum.SortOrder.LayoutOrder,
        })

        local function updateText()
            if multi then
                local arr = {}
                for _, v in ipairs(selected) do table.insert(arr, v) end
                SelectedLabel.Text = #arr == 0 and "Выбрать..." or table.concat(arr, ", ")
            else
                SelectedLabel.Text = selected or "Выбрать..."
            end
        end

        local function isSelected(opt)
            if multi then
                return table.find(selected, opt) ~= nil
            end
            return selected == opt
        end

        for i, opt in ipairs(options) do
            local OptBtn = Create("TextButton", {
                Parent = ListFrame,
                Text = "  " .. tostring(opt),
                Font = Enum.Font.Gotham,
                TextSize = 12,
                TextColor3 = isSelected(opt) and _I.GetCurrentTheme().Accent or _I.GetCurrentTheme().SubText,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 26),
                AutoButtonColor = false,
                TextXAlignment = Enum.TextXAlignment.Left,
                LayoutOrder = i,
            })
            table.insert(optionButtons, OptBtn)

            OptBtn.MouseButton1Click:Connect(function()
                if multi then
                    local idx = table.find(selected, opt)
                    if idx then table.remove(selected, idx)
                    else table.insert(selected, opt) end
                    if flag then Sensei.Flags[flag] = selected end
                    if callback then pcall(callback, selected) end
                else
                    selected = opt
                    if flag then Sensei.Flags[flag] = selected end
                    if callback then pcall(callback, selected) end
                    dropped = false
                    Tween(Arrow, { Rotation = 0 }, 0.2)
                    Tween(Wrapper, { Size = UDim2.new(1, 0, 0, 50) }, 0.2)
                    task.delay(0.2, function() ListFrame.Visible = false end)
                end
                for _, b in ipairs(optionButtons) do
                    local txt = b.Text:gsub("^%s+", "")
                    Tween(b, { TextColor3 = isSelected(txt) and _I.GetCurrentTheme().Accent or _I.GetCurrentTheme().SubText }, 0.15)
                end
                updateText()
            end)
        end

        MainBtn.MouseButton1Click:Connect(function()
            dropped = not dropped
            if dropped then
                ListFrame.Visible = true
                local listHeight = math.min(#options, 4) * 26
                Tween(Arrow, { Rotation = 180 }, 0.2)
                Tween(Wrapper, { Size = UDim2.new(1, 0, 0, 50 + listHeight) }, 0.2)
            else
                Tween(Arrow, { Rotation = 0 }, 0.2)
                Tween(Wrapper, { Size = UDim2.new(1, 0, 0, 50) }, 0.2)
                task.delay(0.2, function()
                    if not dropped then ListFrame.Visible = false end
                end)
            end
        end)

        updateText()

        local obj = {
            Value = selected,
            Set = function(v)
                selected = v
                updateText()
                if flag then Sensei.Flags[flag] = v end
                if callback then pcall(callback, v) end
            end,
            Get = function() return selected end,
        }

        if flag and Sensei.Flags[flag] ~= nil and callback then
            task.defer(function() pcall(callback, selected) end)
        end

        return obj
    end
end

Sensei._Internal.AttachAdvancedComponents = AttachAdvancedComponents-- ============================================================
-- COMPONENTS: Textbox, Label, Paragraph, Divider
-- ============================================================
local _I = Sensei._Internal
local Create = _I.Create
local Tween = _I.Tween
local AddBounce = _I.AddBounce
local CreateIcon = _I.CreateIcon
local Icons = _I.Icons

local function AttachTextComponents(Section)
    local Container = Section.Container

    -- ========================================================
    -- Textbox
    -- ========================================================
    Section.AddTextbox = function(self, config)
        config = config or {}
        local name = config.Name or "Textbox"
        local placeholder = config.Placeholder or "Введите..."
        local default = config.Default or ""
        local callback = config.Callback
        local flag = config.Flag

        if flag and type(Sensei.Flags[flag]) == "string" then
            default = Sensei.Flags[flag]
        end

        local Frame = Create("Frame", {
            Parent = Container,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 50),
        })

        Create("TextLabel", {
            Parent = Frame,
            Text = name,
            Font = Enum.Font.Gotham,
            TextSize = 12,
            TextColor3 = _I.GetCurrentTheme().Text,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 16),
            Position = UDim2.new(0, 2, 0, 0),
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
        })

        local Input = Create("TextBox", {
            Parent = Frame,
            Text = default,
            PlaceholderText = placeholder,
            Font = Enum.Font.Gotham,
            TextSize = 12,
            TextColor3 = _I.GetCurrentTheme().Text,
            PlaceholderColor3 = _I.GetCurrentTheme().SubText,
            BackgroundColor3 = _I.GetCurrentTheme().Item,
            Size = UDim2.new(1, 0, 0, 28),
            Position = UDim2.new(0, 0, 0, 20),
            TextXAlignment = Enum.TextXAlignment.Left,
            ClearTextOnFocus = false,
            BorderSizePixel = 0,
        })
        Create("UIPadding", { Parent = Input, PaddingLeft = UDim.new(0, 10) })
        Create("UICorner", { Parent = Input, CornerRadius = UDim.new(0, 8) })
        Create("UIStroke", {
            Parent = Input,
            Color = _I.GetCurrentTheme().Stroke,
            Thickness = 1,
            Transparency = 0.6,
        })

        Input.FocusLost:Connect(function()
            if flag then Sensei.Flags[flag] = Input.Text end
            if callback then pcall(callback, Input.Text) end
        end)

        return {
            Set = function(v) Input.Text = tostring(v) end,
            Get = function() return Input.Text end,
        }
    end

    -- ========================================================
    -- Label
    -- ========================================================
    Section.AddLabel = function(self, config)
        config = config or {}
        local text = config.Text or "Label"
        local color = config.Color or _I.GetCurrentTheme().SubText

        return Create("TextLabel", {
            Parent = Container,
            Text = text,
            Font = Enum.Font.Gotham,
            TextSize = 12,
            TextColor3 = color,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 22),
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
        })
    end

    -- ========================================================
    -- Paragraph
    -- ========================================================
    Section.AddParagraph = function(self, title, content)
        local Card = Create("Frame", {
            Parent = Container,
            BackgroundColor3 = _I.GetCurrentTheme().Background,
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BorderSizePixel = 0,
        })
        Create("UICorner", { Parent = Card, CornerRadius = UDim.new(0, 8) })
        Create("UIStroke", {
            Parent = Card,
            Color = _I.GetCurrentTheme().Stroke,
            Thickness = 1,
            Transparency = 0.6,
        })
        Create("UIPadding", {
            Parent = Card,
            PaddingTop = UDim.new(0, 10),
            PaddingBottom = UDim.new(0, 10),
            PaddingLeft = UDim.new(0, 12),
            PaddingRight = UDim.new(0, 12),
        })
        Create("UIListLayout", {
            Parent = Card,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 4),
        })

        if title then
            Create("TextLabel", {
                Parent = Card,
                Text = title,
                Font = Enum.Font.GothamBold,
                TextSize = 12,
                TextColor3 = _I.GetCurrentTheme().Text,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 18),
                TextXAlignment = Enum.TextXAlignment.Left,
                LayoutOrder = 1,
            })
        end

        Create("TextLabel", {
            Parent = Card,
            Text = content or "",
            Font = Enum.Font.Gotham,
            TextSize = 11,
            TextColor3 = _I.GetCurrentTheme().SubText,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            LayoutOrder = 2,
        })

        return Card
    end

    -- ========================================================
    -- Divider
    -- ========================================================
    Section.AddDivider = function(self)
        local Wrap = Create("Frame", {
            Parent = Container,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 9),
        })
        Create("Frame", {
            Parent = Wrap,
            BackgroundColor3 = _I.GetCurrentTheme().Stroke,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 1),
            Position = UDim2.new(0, 0, 0.5, 0),
        })
        return Wrap
    end

    -- ========================================================
    -- DividerText
    -- ========================================================
    Section.AddDividerText = function(self, text)
        local Wrap = Create("Frame", {
            Parent = Container,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 20),
        })
        Create("Frame", {
            Parent = Wrap,
            BackgroundColor3 = _I.GetCurrentTheme().Stroke,
            BorderSizePixel = 0,
            Size = UDim2.new(0.4, 0, 0, 1),
            Position = UDim2.new(0, 0, 0.5, 0),
        })
        Create("Frame", {
            Parent = Wrap,
            BackgroundColor3 = _I.GetCurrentTheme().Stroke,
            BorderSizePixel = 0,
            Size = UDim2.new(0.4, 0, 0, 1),
            Position = UDim2.new(0.6, 0, 0.5, 0),
        })
        Create("TextLabel", {
            Parent = Wrap,
            Text = text or "",
            Font = Enum.Font.GothamBold,
            TextSize = 11,
            TextColor3 = _I.GetCurrentTheme().SubText,
            BackgroundTransparency = 1,
            Size = UDim2.new(0.2, 0, 1, 0),
            Position = UDim2.new(0.4, 0, 0, 0),
            TextXAlignment = Enum.TextXAlignment.Center,
        })
        return Wrap
    end
end

Sensei._Internal.AttachTextComponents = AttachTextComponents-- ============================================================
-- COMPONENTS: Dialog, Keybind
-- ============================================================
local _I = Sensei._Internal
local Create = _I.Create
local Tween = _I.Tween
local AddBounce = _I.AddBounce
local CreateIcon = _I.CreateIcon
local Icons = _I.Icons
local UserInputService = _I.Services.UserInputService

local function AttachDialogComponents(Window)
    local ScreenGui = Window.ScreenGui

    -- ========================================================
    -- Dialog (модальное окно с кнопками)
    -- ========================================================
    function Window:Dialog(config)
        config = config or {}
        local title = config.Title or "Подтверждение"
        local content = config.Content or ""
        local options = config.Options or {}

        -- Backdrop
        local Backdrop = Create("TextButton", {
            Parent = ScreenGui,
            Text = "",
            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            AutoButtonColor = false,
            BorderSizePixel = 0,
            ZIndex = 1000,
        })
        Tween(Backdrop, { BackgroundTransparency = 0.5 }, 0.25)

        -- Popup
        local Popup = Create("Frame", {
            Parent = ScreenGui,
            BackgroundColor3 = _I.GetCurrentTheme().Background,
            Size = UDim2.new(0, 320, 0, 0),
            Position = UDim2.new(0.5, -160, 0.5, -80),
            BorderSizePixel = 0,
            ZIndex = 1001,
            AutomaticSize = Enum.AutomaticSize.Y,
        })
        Create("UICorner", { Parent = Popup, CornerRadius = UDim.new(0, 12) })
        Create("UIStroke", {
            Parent = Popup,
            Color = _I.GetCurrentTheme().Accent,
            Thickness = 1.4,
            Transparency = 0.3,
        })
        Create("UIPadding", {
            Parent = Popup,
            PaddingTop = UDim.new(0, 16),
            PaddingBottom = UDim.new(0, 16),
            PaddingLeft = UDim.new(0, 16),
            PaddingRight = UDim.new(0, 16),
        })
        Create("UIListLayout", {
            Parent = Popup,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 8),
        })

        Create("TextLabel", {
            Parent = Popup,
            Text = title,
            Font = Enum.Font.GothamBold,
            TextSize = 15,
            TextColor3 = _I.GetCurrentTheme().Text,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 22),
            TextXAlignment = Enum.TextXAlignment.Left,
            LayoutOrder = 1,
        })

        Create("TextLabel", {
            Parent = Popup,
            Text = content,
            Font = Enum.Font.Gotham,
            TextSize = 12,
            TextColor3 = _I.GetCurrentTheme().SubText,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            LayoutOrder = 2,
        })

        local BtnRow = Create("Frame", {
            Parent = Popup,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 30),
            LayoutOrder = 3,
        })
        Create("UIListLayout", {
            Parent = BtnRow,
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 8),
        })

        local function close(result)
            Tween(Backdrop, { BackgroundTransparency = 1 }, 0.25)
            Tween(Popup, { BackgroundTransparency = 1 }, 0.25)
            task.wait(0.3)
            Popup:Destroy()
            Backdrop:Destroy()
            if config.Callback then pcall(config.Callback, result) end
        end

        for i, opt in ipairs(options) do
            local optName = opt.Title or opt.Name or ("Option " .. i)
            local optCallback = opt.Callback

            local Btn = Create("TextButton", {
                Parent = BtnRow,
                Text = optName,
                Font = Enum.Font.GothamBold,
                TextSize = 12,
                TextColor3 = i == #options and Color3.fromRGB(255,255,255) or _I.GetCurrentTheme().Text,
                BackgroundColor3 = i == #options and _I.GetCurrentTheme().Accent or _I.GetCurrentTheme().Item,
                Size = UDim2.new(0, 100, 1, 0),
                AutoButtonColor = false,
                BorderSizePixel = 0,
                LayoutOrder = i,
            })
            Create("UICorner", { Parent = Btn, CornerRadius = UDim.new(0, 8) })
            AddBounce(Btn)

            Btn.MouseButton1Click:Connect(function()
                close(optName)
                if optCallback then pcall(optCallback) end
            end)
        end

        Backdrop.MouseButton1Click:Connect(function()
            close(nil)
        end)

        return Popup
    end
end

-- ============================================================
-- KEYBIND (отдельный компонент)
-- ============================================================
local function AttachKeybindComponent(Section)
    local Container = Section.Container

    Section.AddKeybind = function(self, config)
        config = config or {}
        local name = config.Name or "Keybind"
        local defaultKey = config.Default or Enum.KeyCode.RightShift
        local callback = config.Callback
        local flag = config.Flag

        if flag and type(Sensei.Flags[flag]) == "string" then
            local ok, kc = pcall(function() return Enum.KeyCode[Sensei.Flags[flag]] end)
            if ok and kc then defaultKey = kc end
        end

        local currentKey = defaultKey
        local listening = false

        local Frame = Create("Frame", {
            Parent = Container,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 32),
        })

        Create("TextLabel", {
            Parent = Frame,
            Text = name,
            Font = Enum.Font.Gotham,
            TextSize = 12,
            TextColor3 = _I.GetCurrentTheme().Text,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -80, 1, 0),
            Position = UDim2.new(0, 2, 0, 0),
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
        })

        local KeyBtn = Create("TextButton", {
            Parent = Frame,
            Text = currentKey.Name,
            Font = Enum.Font.GothamBold,
            TextSize = 11,
            TextColor3 = _I.GetCurrentTheme().Accent,
            BackgroundColor3 = _I.GetCurrentTheme().Item,
            Size = UDim2.new(0, 70, 0, 24),
            Position = UDim2.new(1, -72, 0.5, -12),
            AutoButtonColor = false,
            BorderSizePixel = 0,
        })
        Create("UICorner", { Parent = KeyBtn, CornerRadius = UDim.new(0, 6) })
        Create("UIStroke", {
            Parent = KeyBtn,
            Color = _I.GetCurrentTheme().Stroke,
            Thickness = 1,
            Transparency = 0.6,
        })
        AddBounce(KeyBtn)

        local listenConn

        local function stopListen()
            listening = false
            if listenConn then listenConn:Disconnect(); listenConn = nil end
            KeyBtn.Text = currentKey.Name
            Tween(KeyBtn, { TextColor3 = _I.GetCurrentTheme().Accent }, 0.2)
        end

        local function startListen()
            if listening then stopListen(); return end
            listening = true
            KeyBtn.Text = "..."
            Tween(KeyBtn, { TextColor3 = _I.GetCurrentTheme().Warning }, 0.2)
            listenConn = UserInputService.InputBegan:Connect(function(input)
                if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
                if input.KeyCode == Enum.KeyCode.Escape then stopListen(); return end
                currentKey = input.KeyCode
                stopListen()
                if flag then Sensei.Flags[flag] = currentKey.Name end
                if callback then pcall(callback, currentKey) end
            end)
        end

        KeyBtn.MouseButton1Click:Connect(startListen)

        return {
            Set = function(kc)
                if typeof(kc) == "EnumItem" then currentKey = kc end
                KeyBtn.Text = currentKey.Name
                if flag then Sensei.Flags[flag] = currentKey.Name end
            end,
            Get = function() return currentKey end,
        }
    end
end

Sensei._Internal.AttachDialogComponents = AttachDialogComponents
Sensei._Internal.AttachKeybindComponent = AttachKeybindComponent-- ============================================================
-- MINIMIZER + MOBILE BUTTON + CONFIG SAVE/LOAD
-- ============================================================
local _I = Sensei._Internal
local Create = _I.Create
local Tween = _I.Tween
local AddBounce = _I.AddBounce
local CreateIcon = _I.CreateIcon
local Icons = _I.Icons
local FS = _I.FS
local SafeWrite = _I.SafeWrite
local HttpService = _I.Services.HttpService
local UserInputService = _I.Services.UserInputService

local function AttachMinimizer(Window)
    local ScreenGui = Window.ScreenGui

    -- ========================================================
    -- Mobile Button (плавающая кнопка открытия)
    -- ========================================================
    local MobileButton = Create("ImageButton", {
        Parent = ScreenGui,
        Size = UDim2.new(0, 44, 0, 44),
        Position = UDim2.new(0, 20, 0, 100),
        BackgroundColor3 = _I.GetCurrentTheme().Card,
        AutoButtonColor = false,
        BorderSizePixel = 0,
        Image = Icons.Settings,
        ImageColor3 = _I.GetCurrentTheme().Accent,
        Visible = false,
        ZIndex = 50,
    })
    Create("UICorner", { Parent = MobileButton, CornerRadius = UDim.new(0, 10) })
    Create("UIStroke", {
        Parent = MobileButton,
        Color = _I.GetCurrentTheme().Accent,
        Thickness = 1.4,
        Transparency = 0.3,
    })
    AddBounce(MobileButton)

    -- Перетаскивание мобильной кнопки
    do
        local dragging, dragInput, dragStart, startPos
        MobileButton.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = MobileButton.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
            end
        end)
        MobileButton.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement
                or input.UserInputType == Enum.UserInputType.Touch then
                dragInput = input
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if input == dragInput and dragging then
                local delta = input.Position - dragStart
                MobileButton.Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + delta.X,
                    startPos.Y.Scale, startPos.Y.Offset + delta.Y
                )
            end
        end)
    end

    -- Клик по кнопке → открыть окно
    MobileButton.MouseButton1Click:Connect(function()
        Window.MainFrame.Visible = true
        MobileButton.Visible = false
    end)

    -- ========================================================
    -- Minimize Hook (перехватываем сворачивание)
    -- ========================================================
    -- Обёртка над Minimize — показывает мобильную кнопку
    local _origMinimize = Window.Minimize
    function Window:Minimize()
        if _origMinimize then pcall(_origMinimize) end
        task.wait(0.3)
        MobileButton.Visible = true
    end

    -- ========================================================
    -- Minimizer Keybind (сворачивание по клавише)
    -- ========================================================
    function Window:NewMinimizer(config)
        config = config or {}
        local keyCode = config.KeyCode or Enum.KeyCode.LeftControl

        local conn
        conn = UserInputService.InputBegan:Connect(function(input, gpe)
            if gpe then return end
            if input.KeyCode == keyCode then
                if Window.MainFrame.Visible then
                    Window:Minimize()
                else
                    Window.MainFrame.Visible = true
                    MobileButton.Visible = false
                end
            end
        end)

        return {
            KeyCode = keyCode,
            Disconnect = function()
                if conn then conn:Disconnect(); conn = nil end
            end,
        }
    end

    -- ========================================================
    -- Config: Save / Load Flags
    -- ========================================================
    function Window:SaveConfig(slot)
        slot = slot or "default"
        local path = Window.ScriptFolder .. "/" .. slot .. ".json"
        local ok, encoded = pcall(function()
            return HttpService:JSONEncode(Sensei.Flags)
        end)
        if ok then
            SafeWrite(path, encoded)
            Sensei:Notify({
                Title = "Конфиг сохранён",
                Description = slot,
                Kind = "success",
            })
        end
    end

    function Window:LoadConfig(slot)
        slot = slot or "default"
        local path = Window.ScriptFolder .. "/" .. slot .. ".json"
        if not FS.isfile(path) then
            Sensei:Notify({
                Title = "Конфиг не найден",
                Description = slot,
                Kind = "error",
            })
            return
        end
        local ok, content = pcall(function() return FS.readfile(path) end)
        if ok and content then
            local ok2, data = pcall(function() return HttpService:JSONDecode(content) end)
            if ok2 and type(data) == "table" then
                for k, v in pairs(data) do
                    Sensei.Flags[k] = v
                end
                Sensei:Notify({
                    Title = "Конфиг загружен",
                    Description = slot,
                    Kind = "success",
                })
            end
        end
    end

    function Window:ListConfigs()
        local list = {}
        if not FS.listfiles then return list end
        pcall(function()
            for _, file in ipairs(FS.listfiles(Window.ScriptFolder)) do
                local name = file:match("([^/\\]+)%.json$")
                if name then table.insert(list, name) end
            end
        end)
        return list
    end
end

Sensei._Internal.AttachMinimizer = AttachMinimizer-- ============================================================
-- UTILITY: Confirm, Notify Group, Export
-- ============================================================
local _I = Sensei._Internal
local Create = _I.Create
local Tween = _I.Tween
local AddBounce = _I.AddBounce

-- ============================================================
-- CONFIRM (быстрый хелпер над Dialog)
-- ============================================================
function Sensei:Confirm(options)
    options = options or {}
    local title = options.Title or "Подтверждение"
    local content = options.Content or "Ты уверен?"
    local yesText = options.YesText or "Да"
    local noText = options.NoText or "Нет"
    local callback = options.Callback

    local activeWindow = Sensei.Windows[1]
    if not activeWindow then return end

    activeWindow:Dialog({
        Title = title,
        Content = content,
        Options = {
            {
                Title = noText,
                Callback = function()
                    if callback then pcall(callback, false) end
                end,
            },
            {
                Title = yesText,
                Callback = function()
                    if callback then pcall(callback, true) end
                end,
            },
        },
    })
end

-- ============================================================
-- NOTIFY GROUP (групповые уведомления)
-- ============================================================
function Sensei:NotifyGroup(defaults)
    defaults = defaults or {}
    local group = {}

    group.Notify = function(self, options)
        options = options or {}
        Sensei:Notify({
            Title = options.Title or defaults.Title or "Уведомление",
            Description = options.Description or defaults.Description or "",
            Duration = options.Duration or defaults.Duration or 3,
            Kind = options.Kind or defaults.Kind or "info",
        })
    end

    return group
end

-- ============================================================
-- DESTROY ALL WINDOWS
-- ============================================================
function Sensei:DestroyAll()
    for _, win in ipairs(Sensei.Windows) do
        pcall(function() win:Destroy() end)
    end
    Sensei.Windows = {}
    Sensei.Flags = {}
end

-- ============================================================
-- GET FLAG / SET FLAG
-- ============================================================
function Sensei:GetFlag(name)
    return Sensei.Flags[name]
end

function Sensei:SetFlag(name, value)
    Sensei.Flags[name] = value
end

function Sensei:DeleteFlags()
    Sensei.Flags = {}
end

-- ============================================================
-- THEME REGISTER (кастомные темы)
-- ============================================================
function Sensei:RegisterTheme(name, theme)
    if type(name) ~= "string" or type(theme) ~= "table" then return end
    _I.Themes[name] = {
        Name = name,
        Accent      = theme.Accent or _I.GetCurrentTheme().Accent,
        AccentLight = theme.AccentLight or (theme.Accent or _I.GetCurrentTheme().Accent):Lerp(Color3.new(1,1,1), 0.4),
        AccentDark  = theme.AccentDark or _I.GetCurrentTheme().AccentDark,
        Background  = theme.Background or _I.GetCurrentTheme().Background,
        Card        = theme.Card or _I.GetCurrentTheme().Card,
        Item        = theme.Item or _I.GetCurrentTheme().Item,
        Hover       = theme.Hover or _I.GetCurrentTheme().Hover,
        Text        = theme.Text or _I.GetCurrentTheme().Text,
        SubText     = theme.SubText or _I.GetCurrentTheme().SubText,
        Stroke      = theme.Stroke or _I.GetCurrentTheme().Stroke,
        Danger      = theme.Danger or _I.GetCurrentTheme().Danger,
        Success     = theme.Success or _I.GetCurrentTheme().Success,
        Warning     = theme.Warning or _I.GetCurrentTheme().Warning,
    }
end

-- ============================================================
-- APPLY THEME ко всем открытым окнам
-- ============================================================
function Sensei:ApplyTheme(name)
    if not _I.Themes[name] then return end
    Sensei:SetTheme(name)
    for _, win in ipairs(Sensei.Windows) do
        if win.MainFrame then
            Tween(win.MainFrame, { BackgroundColor3 = _I.GetCurrentTheme().Background }, 0.3)
        end
    end
end

-- ============================================================
-- EXPORT to getgenv
-- ============================================================
if getgenv then
    pcall(function()
        getgenv().Sensei = Sensei
        getgenv().SenseiVersion = Sensei.Version
    end)
end

-- ============================================================
-- PUBLIC INFO
-- ============================================================
function Sensei:GetInfo()
    return {
        Version = Sensei.Version,
        Brand = Sensei.Brand,
        Themes = Sensei:GetThemes(),
        Flags = Sensei.Flags,
    }
end

-- ============================================================
-- PRINT LOADED
-- ============================================================
print("[Sensei] Loaded, version:", Sensei.Version)
print("[Sensei] Available themes:", table.concat(Sensei:GetThemes(), ", "))-- ============================================================
-- FINAL PATCH: CreateWindow
-- Прикрепляем все методы к Window
-- ============================================================
local _I = Sensei._Internal
local _origCreateWindow = Sensei.CreateWindow

function Sensei:CreateWindow(options)
    -- Создаём окно
    local Window = _origCreateWindow(self, options)

    -- 1. Прикрепляем методы CreateTab / CreateSection
    _I.AttachTabMethods(Window)

    -- 2. Прикрепляем компоненты к каждой Section
    local _origCreateSection = Window.CreateSection
    function Window:CreateSection(tab, sectionName)
        local Section = _origCreateSection(self, tab, sectionName)

        -- Прикрепляем все наборы компонентов
        _I.AttachBasicComponents(Section, tab)     -- Button, Toggle
        _I.AttachAdvancedComponents(Section)       -- Slider, Dropdown
        _I.AttachTextComponents(Section)           -- Textbox, Label, Paragraph, Divider
        _I.AttachKeybindComponent(Section)         -- Keybind

        return Section
    end

    -- 3. Прикрепляем Dialog
    _I.AttachDialogComponents(Window)

    -- 4. Прикрепляем Minimizer, Mobile Button, Config
    _I.AttachMinimizer(Window)

    -- 5. Регистрируем окно
    Window.CurrentTab = nil

    return Window
end

-- ============================================================
-- UTILITY: Quick Hub (быстрое создание)
-- ============================================================
function Sensei:QuickHub(config)
    config = config or {}
    local Window = Sensei:CreateWindow({
        Title = config.Title or "Sensei Hub",
        SubTitle = config.SubTitle or "Powered by Sensei",
        ScriptFolder = config.ScriptFolder or "sensei",
    })
    local Tab = Window:CreateTab(config.TabName or "Main", config.TabIcon or "Home")
    return Window, Tab
end

-- ============================================================
-- EXPORT
-- ============================================================
return Sensei