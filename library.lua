--[[
    Sensei UI Library — Compact Mobile Edition
    Author: CreativeGPT & Douwe
    Version: 1.0.0
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
    WhitelistedUsers = {},
    Version = "1.0.0",
    Brand   = "Sensei",
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

-- ============================================================
-- Palette (Blue Neon)
-- ============================================================
local AccentColor      = Color3.fromRGB(0, 170, 255)
local AccentColorLight = Color3.fromRGB(120, 220, 255)
local BackgroundColor  = Color3.fromRGB(15, 18, 24)
local CardColor        = Color3.fromRGB(24, 28, 36)
local ItemColor        = Color3.fromRGB(34, 40, 50)
local HoverColor       = Color3.fromRGB(44, 52, 64)
local TextColor        = Color3.fromRGB(235, 240, 248)
local SubTextColor     = Color3.fromRGB(150, 165, 185)
local StrokeColor      = Color3.fromRGB(40, 60, 90)

-- ============================================================
-- Utility: Create instance
-- ============================================================
local function Create(className, props)
    local inst = Instance.new(className)
    if className == "TextBox" then inst.Text = "" end
    for k, v in pairs(props or {}) do
        inst[k] = v
    end
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
-- Utility: Bounce
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
end

-- ============================================================
-- CREATE WINDOW
-- ============================================================
function Library:CreateWindow(options)
    local hubName  = "Sensei"
    local subText  = "Mobile Edition"
    local subColor = AccentColorLight

    if type(options) == "table" then
        hubName  = options.Title or hubName
        subText  = options.Subtitle or subText
        subColor = options.SubtitleColor or subColor
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

    -- Notifications container
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

    -- Main Frame
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

    -- Delta-style Minibar
    local Minibar = Create("Frame", {
        Parent = ScreenGui,
        BackgroundColor3 = CardColor,
        Size = UDim2.new(0, 180, 0, 44),
        Position = UDim2.new(0.5, -90, 1, -80),
        Visible = false,
        Active = true,
        ZIndex = 10,
    })
    Create("UICorner", {Parent = Minibar, CornerRadius = UDim.new(0, 12)})
    local MinibarStroke = Create("UIStroke", {
        Parent = Minibar, Color = AccentColor, Thickness = 1.4, Transparency = 0.2,
    })

    Create("TextLabel", {
        Parent = Minibar, BackgroundTransparency = 1,
        Size = UDim2.new(0, 24, 0, 24),
        Position = UDim2.new(0, 10, 0.5, -12),
        Text = "⚡", Font = Enum.Font.GothamBold,
        TextSize = 16, TextColor3 = AccentColor,
    })

    Create("TextLabel", {
        Parent = Minibar, BackgroundTransparency = 1,
        Size = UDim2.new(1, -80, 1, 0),
        Position = UDim2.new(0, 40, 0, 0),
        Text = hubName, Font = Enum.Font.GothamBold,
        TextSize = 13, TextColor3 = TextColor,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
    })

    local MinibarExpand = Create("TextButton", {
        Parent = Minibar,
        Size = UDim2.new(0, 28, 0, 28),
        Position = UDim2.new(1, -34, 0.5, -14),
        BackgroundColor3 = ItemColor,
        Text = "⤢", Font = Enum.Font.GothamBold,
        TextSize = 14, TextColor3 = AccentColor,
        AutoButtonColor = false, BorderSizePixel = 0,
    })
    Create("UICorner", {Parent = MinibarExpand, CornerRadius = UDim.new(0, 8)})
    AddBounce(MinibarExpand)

    MakeDraggable(Minibar, Minibar)

    MinibarExpand.MouseButton1Click:Connect(function()
        Minibar.Visible = false
        MainFrame.Visible = true
        MainScale.Scale = 0.9
        Tween(MainScale, {Scale = 1}, 0.35)
        Tween(MainFrame, {BackgroundTransparency = 0.05}, 0.35)
    end)

    -- TopBar
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
    Create("Frame", {
        Parent = TopBar, BackgroundColor3 = CardColor,
        BackgroundTransparency = 0.15, BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 14), Position = UDim2.new(0, 0, 1, -14),
    })

    MakeDraggable(TopBar, MainFrame)

    local TitleContainer = Create("Frame", {
        Parent = TopBar, BackgroundTransparency = 1,
        Size = UDim2.new(0, 200, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
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

    -- Minimize → minibar
    MinBtn.MouseButton1Click:Connect(function()
        Minibar.Position = UDim2.new(
            MainFrame.Position.X.Scale,
            MainFrame.Position.X.Offset - 90 + 170,
            MainFrame.Position.Y.Scale,
            MainFrame.Position.Y.Offset - 80
        )
        Tween(MainScale, {Scale = 0.85}, 0.28)
        Tween(MainFrame, {BackgroundTransparency = 1}, 0.28)
        task.wait(0.22)
        MainFrame.Visible = false
        Minibar.Visible = true
        Minibar.Size = UDim2.new(0, 0, 0, 44)
        Tween(Minibar, {Size = UDim2.new(0, 180, 0, 44)}, 0.3)
    end)

    -- Close confirm
    CloseBtn.MouseButton1Click:Connect(function()
        Tween(MainScale, {Scale = 0.85}, 0.3)
        Tween(MainFrame, {BackgroundTransparency = 1}, 0.3)
        task.wait(0.35)
        ScreenGui:Destroy()
    end)

    -- Sidebar
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

    Create("Frame", {
        Parent = MainFrame, BackgroundColor3 = StrokeColor,
        BorderSizePixel = 0, Size = UDim2.new(0, 1, 1, -40),
        Position = UDim2.new(0, 110, 0, 40),
    })

    -- Content Area
    local ContentArea = Create("Frame", {
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -115, 1, -40),
        Position = UDim2.new(0, 115, 0, 40),
        Active = true,
    })

    -- Window API
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

    return Window
end-- ============================================================
-- TAB / PAGE / SECTION / COMPONENTS
-- ============================================================
local function AttachWindowMethods(Window)
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
            BackgroundColor3 = HoverColor, BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 34),
            AutoButtonColor = false, BorderSizePixel = 0,
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
            Parent = TabBtn, Text = tabName,
            Font = Enum.Font.GothamBold, TextSize = 12,
            TextColor3 = SubTextColor, BackgroundTransparency = 1,
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
            Parent = ContentArea, BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0), Visible = false,
        })

        local PageNav = Create("Frame", {
            Parent = TabContent, BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 30),
        })
        Create("UIListLayout", {
            Parent = PageNav, FillDirection = Enum.FillDirection.Horizontal,
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
            Pages = {}, CurrentPage = nil, IsLocked = isLocked,
        }
        table.insert(Window.Tabs, TabConfig)

        TabBtn.MouseButton1Click:Connect(function()
            if isLocked and not isWhitelisted then
                Library:Notify({
                    Title = "Доступ закрыт",
                    Description = "Этот раздел доступен только по подписке.",
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

        -- ================================================
        -- CreatePage
        -- ================================================
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

            local Column = Create("Frame", {
                Parent = PageScroll, BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
            })
            local L_Layout = Create("UIListLayout", {
                Parent = Column, SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 8),
            })
            L_Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                PageScroll.CanvasSize = UDim2.new(0, 0, 0, L_Layout.AbsoluteContentSize.Y + 20)
            end)

            local PageObj = {
                Scroll = PageScroll, Btn = PageBtn,
                Highlight = PageHighlight, Column = Column,
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

            -- ============================================
            -- CreateSection
            -- ============================================
            function PageObj:CreateSection(sectionName)
                sectionName = sectionName or "Section"
                local SectionContainer = Create("Frame", {
                    Parent = Column,
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

                local Elements = {}

                -- ========================================
                -- AddButton
                -- ========================================
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

                -- ========================================
                -- AddToggle
                -- ========================================
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

                -- ========================================
                -- AddSlider
                -- ========================================
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

                -- ========================================
                -- AddDropdown
                -- ========================================
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
                        BorderSizePixel = 0, Visible = false,
                    })
                    Create("UICorner", {Parent = ListFrame, CornerRadius = UDim.new(0, 8)})
                    Create("UIListLayout", {
                        Parent = ListFrame, SortOrder = Enum.SortOrder.LayoutOrder,
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
                        if isMulti then return table.find(selected, opt) ~= nil end
                        return selected == opt
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
                                local txt = b.Text:gsub("^%s+", "")
                                Tween(b, {
                                    TextColor3 = isSelected(txt) and AccentColor or SubTextColor,
                                }, 0.15)
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
                                local txt = b.Text:gsub("^%s+", "")
                                Tween(b, {
                                    TextColor3 = isSelected(txt) and AccentColor or SubTextColor,
                                }, 0.15)
                            end
                            updateText()
                        end,
                        Get = function() return selected end,
                    }
                    return {Set = function(v) selected = v; updateText() end,
                            Get = function() return selected end}
                end

                -- ========================================
                -- AddTextbox
                -- ========================================
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

                -- ========================================
                -- AddKeybind
                -- ========================================
                function Elements:AddKeybind(name, defaultKey, callback)
                    local currentKey = defaultKey or Enum.KeyCode.RightShift
                    local listening = false

                    local Frame = Create("Frame", {
                        Parent = ItemContainer, BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 34),
                    })
                    Create("TextLabel", {
                        Parent = Frame, Text = name or "Keybind",
                        Font = Enum.Font.Gotham, TextSize = 12,
                        TextColor3 = TextColor, BackgroundTransparency = 1,
                        Size = UDim2.new(1, -70, 1, 0),
                        Position = UDim2.new(0, 2, 0, 0),
                        TextXAlignment = Enum.TextXAlignment.Left,
                    })
                    local KeyBtn = Create("TextButton", {
                        Parent = Frame,
                        Text = currentKey and currentKey.Name or "None",
                        Font = Enum.Font.GothamBold, TextSize = 11,
                        TextColor3 = AccentColor, BackgroundColor3 = ItemColor,
                        Size = UDim2.new(0, 64, 0, 24),
                        Position = UDim2.new(1, -66, 0.5, -12),
                        AutoButtonColor = false, BorderSizePixel = 0,
                    })
                    Create("UICorner", {Parent = KeyBtn, CornerRadius = UDim.new(0, 6)})
                    Create("UIStroke", {
                        Parent = KeyBtn, Color = StrokeColor, Thickness = 1, Transparency = 0.6,
                    })
                    AddBounce(KeyBtn)

                    local listenConn
                    local function stopListen()
                        listening = false
                        if listenConn then listenConn:Disconnect(); listenConn = nil end
                        KeyBtn.Text = currentKey and currentKey.Name or "None"
                    end

                    local function startListen()
                        if listening then stopListen(); return end
                        listening = true
                        KeyBtn.Text = "..."
                        listenConn = UserInputService.InputBegan:Connect(function(input)
                            if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
                            if input.KeyCode == Enum.KeyCode.Escape then stopListen(); return end
                            currentKey = input.KeyCode
                            stopListen()
                            if callback then pcall(callback, currentKey) end
                        end)
                    end

                    KeyBtn.MouseButton1Click:Connect(startListen)

                    Window.ConfigElements[name] = {
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

                return Elements
            end
            return PageObj
        end

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

-- ============================================================
-- PATCH: оборачиваем CreateWindow, чтобы AttachWindowMethods применялся
-- ============================================================
local _origCreateWindow = Library.CreateWindow
function Library:CreateWindow(opts)
    local w = _origCreateWindow(self, opts)
    AttachWindowMethods(w)
    return w
end

-- ============================================================
-- EXPORT
-- ============================================================
return Library