--[[
  _   _           _             _    
 | \ | |         | |           | |   
 |  \| | ___  ___| | _____  ___| | __
 | . ` |/ _ \/ __| |/ / _ \/ __| |/ /
 | |\  | (_) \__ \   <  __/\__ \   < 
 |_| \_|\___/|___/_|\_\___||___/_|\_\
--]]

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = (type(gethui) == "function" and gethui()) or (pcall(function() return game:GetService("CoreGui") end) and game:GetService("CoreGui")) or Players.LocalPlayer:WaitForChild("PlayerGui")

local LuannyUi = {}
LuannyUi.__index = LuannyUi

local AllTextElements = {}
local FontUI = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
local FontTitle = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)

local successIcons, Lucide = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/Icons/refs/heads/main/lucide/dist/Icons.lua"))()
end)
local Icons = (successIcons and type(Lucide) == "table") and Lucide or setmetatable({}, {__index = function() return "" end})

-- ===== 高级动画系统 =====
local AnimationSystem = {}
AnimationSystem.__index = AnimationSystem

function AnimationSystem:FadeIn(element, duration, delay)
    duration = duration or 0.4
    delay = delay or 0
    element.BackgroundTransparency = 1
    element.GroupTransparency = 1
    element.Size = UDim2.new(element.Size.X.Scale, element.Size.X.Offset * 0.9, element.Size.Y.Scale, element.Size.Y.Offset * 0.9)
    
    task.delay(delay, function()
        local tween1 = TweenService:Create(element, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(element.Size.X.Scale, element.Size.X.Offset, element.Size.Y.Scale, element.Size.Y.Offset)
        })
        local tween2 = TweenService:Create(element, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            GroupTransparency = 0,
            BackgroundTransparency = 0
        })
        tween1:Play()
        tween2:Play()
    end)
end

function AnimationSystem:FadeOut(element, duration, callback)
    duration = duration or 0.3
    local tween1 = TweenService:Create(element, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        GroupTransparency = 1,
        BackgroundTransparency = 1
    })
    local tween2 = TweenService:Create(element, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Size = UDim2.new(element.Size.X.Scale, element.Size.X.Offset * 0.9, element.Size.Y.Scale, element.Size.Y.Offset * 0.9)
    })
    tween1:Play()
    tween2:Play()
    tween1.Completed:Connect(function()
        if callback then callback() end
    end)
end

function AnimationSystem:SlideIn(element, direction, duration, delay)
    duration = duration or 0.5
    delay = delay or 0
    local startPos = element.Position
    
    if direction == "left" then
        element.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset - 100, startPos.Y.Scale, startPos.Y.Offset)
    elseif direction == "right" then
        element.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + 100, startPos.Y.Scale, startPos.Y.Offset)
    elseif direction == "up" then
        element.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset, startPos.Y.Scale, startPos.Y.Offset - 50)
    elseif direction == "down" then
        element.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset, startPos.Y.Scale, startPos.Y.Offset + 50)
    end
    
    task.delay(delay, function()
        TweenService:Create(element, TweenInfo.new(duration, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Position = startPos
        }):Play()
    end)
end

function AnimationSystem:ScaleIn(element, duration, delay)
    duration = duration or 0.4
    delay = delay or 0
    element.Size = UDim2.new(element.Size.X.Scale, element.Size.X.Offset * 0.5, element.Size.Y.Scale, element.Size.Y.Offset * 0.5)
    
    task.delay(delay, function()
        TweenService:Create(element, TweenInfo.new(duration, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(element.Size.X.Scale, element.Size.X.Offset, element.Size.Y.Scale, element.Size.Y.Offset)
        }):Play()
    end)
end

function AnimationSystem:Pulse(element, scale, duration)
    scale = scale or 1.05
    duration = duration or 0.3
    local originalSize = element.Size
    
    local tween = TweenService:Create(element, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(originalSize.X.Scale, originalSize.X.Offset * scale, originalSize.Y.Scale, originalSize.Y.Offset * scale)
    })
    tween:Play()
    tween.Completed:Connect(function()
        TweenService:Create(element, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Size = originalSize
        }):Play()
    end)
end

-- 优化通知系统
if CoreGui:FindFirstChild("LuannyNotifyScreen") then
    CoreGui.LuannyNotifyScreen:Destroy()
end

local NotifyScreen = Instance.new("ScreenGui")
NotifyScreen.Name = "LuannyNotifyScreen"
NotifyScreen.IgnoreGuiInset = true
NotifyScreen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
NotifyScreen.Parent = CoreGui

local NotifyContainer = Instance.new("Frame", NotifyScreen)
NotifyContainer.Size = UDim2.new(0, 320, 1, -40)
NotifyContainer.Position = UDim2.new(1, -20, 0, 20)
NotifyContainer.AnchorPoint = Vector2.new(1, 0)
NotifyContainer.BackgroundTransparency = 1

local ListLayout = Instance.new("UIListLayout", NotifyContainer)
ListLayout.FillDirection = Enum.FillDirection.Vertical
ListLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
ListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
ListLayout.Padding = UDim.new(0, 10)

function LuannyUi:Notify(options)
    local titleText = options.Title or "Notification"
    local descText = options.Desc or ""
    local duration = options.Duration or 5
    local noticeColor = options.Color or Color3.fromRGB(160, 90, 255)
    local iconName = options.Icon
    local buttons = options.Buttons or {}
    local hasButtons = #buttons > 0

    local cardHeight = hasButtons and 100 or 65

    local wrapper = Instance.new("Frame", NotifyContainer)
    wrapper.Size = UDim2.new(0, 300, 0, cardHeight)
    wrapper.BackgroundTransparency = 1

    local card = Instance.new("CanvasGroup", wrapper)
    card.Size = UDim2.new(1, 0, 1, 0)
    card.Position = UDim2.new(0, 50, 0, 0)
    card.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
    card.GroupTransparency = 1
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)
    
    local stroke = Instance.new("UIStroke", card)
    stroke.Color = Color3.fromRGB(80, 40, 120)
    stroke.Thickness = 1

    local glow = Instance.new("Frame", card)
    glow.Size = UDim2.new(1, 0, 1, 0)
    glow.BackgroundColor3 = noticeColor
    glow.BackgroundTransparency = 0.8
    glow.ZIndex = 0
    Instance.new("UICorner", glow).CornerRadius = UDim.new(0, 8)

    local textRightOffset = 12
    if iconName and Icons[iconName] then
        textRightOffset = 38
        local ic = Instance.new("ImageLabel", card)
        ic.Size = UDim2.new(0, 20, 0, 20)
        ic.AnchorPoint = Vector2.new(1, 0)
        ic.Position = UDim2.new(1, -12, 0, 12)
        ic.BackgroundTransparency = 1
        ic.Image = Icons[iconName]
        ic.ImageColor3 = noticeColor
    end

    local lblTitle = Instance.new("TextLabel", card)
    lblTitle.Size = UDim2.new(1, -(textRightOffset + 12), 0, 18)
    lblTitle.Position = UDim2.new(0, 12, 0, 12)
    lblTitle.BackgroundTransparency = 1
    lblTitle.Text = titleText
    lblTitle.TextColor3 = Color3.fromRGB(220, 200, 255)
    lblTitle.FontFace = FontTitle
    lblTitle.TextSize = 13
    lblTitle.TextXAlignment = Enum.TextXAlignment.Left

    local lblDesc = Instance.new("TextLabel", card)
    lblDesc.Size = UDim2.new(1, -(textRightOffset + 12), 0, 30)
    lblDesc.Position = UDim2.new(0, 12, 0, 30)
    lblDesc.BackgroundTransparency = 1
    lblDesc.Text = descText
    lblDesc.TextColor3 = Color3.fromRGB(170, 150, 190)
    lblDesc.FontFace = FontUI
    lblDesc.TextSize = 12
    lblDesc.TextWrapped = true
    lblDesc.TextXAlignment = Enum.TextXAlignment.Left
    lblDesc.TextYAlignment = Enum.TextYAlignment.Top

    local progressBg = Instance.new("Frame", card)
    progressBg.Size = UDim2.new(1, 0, 0, 2)
    progressBg.Position = UDim2.new(0, 0, 1, -2)
    progressBg.BackgroundColor3 = Color3.fromRGB(40, 30, 50)
    progressBg.BorderSizePixel = 0

    local progressBar = Instance.new("Frame", progressBg)
    progressBar.Size = UDim2.new(1, 0, 1, 0)
    progressBar.BackgroundColor3 = noticeColor or Color3.fromRGB(160, 90, 255)
    progressBar.BorderSizePixel = 0

    local isClosed = false
    local function closeNotification()
        if isClosed then return end
        isClosed = true
        local closeTween = TweenService:Create(card, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            GroupTransparency = 1,
            Position = UDim2.new(0, 50, 0, 0)
        })
        closeTween:Play()
        closeTween.Completed:Connect(function()
            wrapper:Destroy()
        end)
    end

    if hasButtons then
        lblDesc.Size = UDim2.new(1, -24, 0, 20)
        
        local btnContainer = Instance.new("Frame", card)
        btnContainer.Size = UDim2.new(1, -24, 0, 28)
        btnContainer.Position = UDim2.new(0, 12, 0, 58)
        btnContainer.BackgroundTransparency = 1
        
        local btnLayout = Instance.new("UIListLayout", btnContainer)
        btnLayout.FillDirection = Enum.FillDirection.Horizontal
        btnLayout.SortOrder = Enum.SortOrder.LayoutOrder
        btnLayout.Padding = UDim.new(0, 6)
        
        for _, btnData in ipairs(buttons) do
            local btn = Instance.new("TextButton", btnContainer)
            btn.Size = UDim2.new(1 / #buttons, -((6 * (#buttons - 1)) / #buttons), 1, 0)
            btn.BackgroundColor3 = Color3.fromRGB(45, 35, 55)
            btn.Text = btnData.Title or "Button"
            btn.TextColor3 = Color3.fromRGB(220, 200, 255)
            btn.FontFace = FontUI
            btn.TextSize = 12
            btn.AutoButtonColor = false
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
            
            local btnStroke = Instance.new("UIStroke", btn)
            btnStroke.Color = Color3.fromRGB(80, 50, 110)
            
            btn.MouseEnter:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60, 45, 75)}):Play()
            end)
            btn.MouseLeave:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(45, 35, 55)}):Play()
            end)

            btn.MouseButton1Click:Connect(function()
                if btnData.Callback then task.spawn(btnData.Callback) end
                closeNotification()
            end)
        end
    end

    -- 高级入场动画
    AnimationSystem:FadeIn(card, 0.5)
    AnimationSystem:SlideIn(card, "left", 0.5)
    AnimationSystem:ScaleIn(card, 0.3, 0.1)

    TweenService:Create(progressBar, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
        Size = UDim2.new(0, 0, 1, 0)
    }):Play()

    task.delay(duration, function()
        closeNotification()
    end)
end

function LuannyUi:SetFont(fontAsset)
    if typeof(fontAsset) == "string" then
        FontUI = Font.new(fontAsset, Enum.FontWeight.Medium, Enum.FontStyle.Normal)
        FontTitle = Font.new(fontAsset, Enum.FontWeight.Bold, Enum.FontStyle.Normal)
    elseif typeof(fontAsset) == "EnumItem" then
        FontUI = Font.fromEnum(fontAsset)
        FontTitle = Font.fromEnum(fontAsset)
    elseif typeof(fontAsset) == "Font" then
        FontUI = fontAsset
        FontTitle = fontAsset
    end
    for _, txt in ipairs(AllTextElements) do
        if txt and txt.Parent then
            pcall(function() txt.FontFace = FontUI end)
        end
    end
end

local Initialized = false
local ScreenGui, Overlay, Toolbar, MainContent, DockContainer, InfoContainer, ExpandBtn
local CurrentWindow = nil
local IsBarVisible = true
local IsExpanded = false
local LayoutOrderCount = 0
local WindowConfig = {}

local function RegisterText(element)
    table.insert(AllTextElements, element)
end

local function CreateLockOverlay(parent)
    local lock = Instance.new("Frame", parent)
    lock.Size = UDim2.new(1, 0, 1, 0)
    lock.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
    lock.BackgroundTransparency = 1
    lock.ZIndex = 20
    lock.Visible = false
    Instance.new("UICorner", lock).CornerRadius = UDim.new(0, 8)
    return lock
end

local function UpdateToolbarWidth()
    if not Toolbar or not DockContainer or not InfoContainer then return end
    local dockWidth = DockContainer.Size.X.Offset
    local infoWidth = IsExpanded and 110 or 0
    local padding = IsExpanded and 8 or 0 
    local totalWidth = dockWidth + padding + infoWidth + 16

    if IsExpanded then InfoContainer.Visible = true end

    TweenService:Create(Toolbar, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, totalWidth, 0, 45)
    }):Play()

    local tw = TweenService:Create(InfoContainer, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, infoWidth, 1, 0)
    })
    tw:Play()
    if not IsExpanded then
        tw.Completed:Connect(function() if not IsExpanded then InfoContainer.Visible = false end end)
    end
end

local function ToggleWindow(target, windowHeight)
    local innerFrame = target:FindFirstChildOfClass("CanvasGroup")
    
    if CurrentWindow == target then
        TweenService:Create(Overlay, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {BackgroundTransparency = 1}):Play()
        if innerFrame then
            AnimationSystem:FadeOut(innerFrame, 0.3, function()
                target.Visible = false
            end)
        else
            target.Visible = false
        end
        CurrentWindow = nil
    else
        if CurrentWindow then 
            local oldWindow = CurrentWindow:FindFirstChildOfClass("CanvasGroup")
            if oldWindow then 
                AnimationSystem:FadeOut(oldWindow, 0.2)
            end
            CurrentWindow.Visible = false
        end
        target.Size = UDim2.new(0, 380, 0, windowHeight)
        target.Visible = true
        CurrentWindow = target
        TweenService:Create(Overlay, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {BackgroundTransparency = WindowConfig.Transparent and 0.4 or 0.6}):Play()
        if innerFrame then
            innerFrame.Size = UDim2.new(0, 380, 0, windowHeight - 15)
            innerFrame.GroupTransparency = 1
            AnimationSystem:FadeIn(innerFrame, 0.4, 0.1)
            AnimationSystem:ScaleIn(innerFrame, 0.3, 0.1)
        end
    end
end

function LuannyUi:CreateWindow(config)
    if Initialized then return self end
    Initialized = true

    WindowConfig = {
        Title = config.Title or "Luanny UI",
        Author = config.Author or "Snow",
        Transparent = config.Transparent or false,
        Theme = config.Theme or "Dark",
        ShowWindow = config.ShowWindow == nil and true or config.ShowWindow
    }

    if CoreGui:FindFirstChild("LuannyUI") then CoreGui.LuannyUI:Destroy() end

    local bgColor = WindowConfig.Theme == "Light" and Color3.fromRGB(35, 30, 45) or Color3.fromRGB(12, 10, 16)
    local strokeColor = WindowConfig.Theme == "Light" and Color3.fromRGB(100, 60, 140) or Color3.fromRGB(60, 35, 90)
    local bgAlpha = WindowConfig.Transparent and 0.25 or 0

    ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "LuannyUI"
    ScreenGui.IgnoreGuiInset = true 
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling 
    ScreenGui.Parent = CoreGui

    Overlay = Instance.new("Frame", ScreenGui)
    Overlay.Size = UDim2.new(1, 0, 1, 0)
    Overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Overlay.BackgroundTransparency = 1
    Overlay.BorderSizePixel = 0
    Overlay.ZIndex = 1

    Toolbar = Instance.new("Frame", ScreenGui)
    Toolbar.Size = UDim2.new(0, 16, 0, 45)
    Toolbar.AnchorPoint = Vector2.new(0.5, 1)
    Toolbar.Position = WindowConfig.ShowWindow and UDim2.new(0.5, 0, 1, -20) or UDim2.new(0.5, 0, 1, 60)
    Toolbar.BackgroundColor3 = bgColor
    Toolbar.BackgroundTransparency = bgAlpha
    Toolbar.ZIndex = 5
    Toolbar.ClipsDescendants = false 
    Instance.new("UICorner", Toolbar).CornerRadius = UDim.new(0, 12)
    Instance.new("UIStroke", Toolbar).Color = strokeColor

    MainContent = Instance.new("Frame", Toolbar)
    MainContent.Size = UDim2.new(1, 0, 1, 0)
    MainContent.BackgroundTransparency = 1
    MainContent.ClipsDescendants = true
    MainContent.ZIndex = 6
    Instance.new("UICorner", MainContent).CornerRadius = UDim.new(0, 12)
    
    local layoutMain = Instance.new("UIListLayout", MainContent)
    layoutMain.FillDirection = Enum.FillDirection.Horizontal
    layoutMain.HorizontalAlignment = Enum.HorizontalAlignment.Left
    layoutMain.VerticalAlignment = Enum.VerticalAlignment.Center
    layoutMain.Padding = UDim.new(0, 8)
    Instance.new("UIPadding", MainContent).PaddingLeft = UDim.new(0, 8)

    DockContainer = Instance.new("Frame", MainContent)
    DockContainer.Size = UDim2.new(0, 0, 1, 0)
    DockContainer.BackgroundTransparency = 1
    DockContainer.ZIndex = 7
    local dockLayout = Instance.new("UIListLayout", DockContainer)
    dockLayout.FillDirection = Enum.FillDirection.Horizontal
    dockLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    dockLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    dockLayout.Padding = UDim.new(0, 8)

    dockLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        DockContainer.Size = UDim2.new(0, dockLayout.AbsoluteContentSize.X, 1, 0)
        UpdateToolbarWidth()
    end)

    InfoContainer = Instance.new("Frame", MainContent)
    InfoContainer.Size = UDim2.new(0, 0, 1, 0)
    InfoContainer.BackgroundTransparency = 1
    InfoContainer.ClipsDescendants = true
    InfoContainer.Visible = false
    InfoContainer.LayoutOrder = 2
    InfoContainer.ZIndex = 7
    local InfoLayout = Instance.new("UIListLayout", InfoContainer)
    InfoLayout.FillDirection = Enum.FillDirection.Vertical
    InfoLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    InfoLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    InfoLayout.Padding = UDim.new(0, 2)
    Instance.new("UIPadding", InfoContainer).PaddingRight = UDim.new(0, 5)

    local LblTitle = Instance.new("TextLabel", InfoContainer)
    LblTitle.Size = UDim2.new(1, 0, 0, 16)
    LblTitle.BackgroundTransparency = 1
    LblTitle.Text = WindowConfig.Title
    LblTitle.TextColor3 = Color3.fromRGB(200, 180, 230)
    LblTitle.FontFace = FontUI
    LblTitle.TextSize = 15
    LblTitle.TextXAlignment = Enum.TextXAlignment.Right
    LblTitle.ZIndex = 10
    RegisterText(LblTitle)

    local LblAuthor = Instance.new("TextLabel", InfoContainer)
    LblAuthor.Size = UDim2.new(1, 0, 0, 12)
    LblAuthor.BackgroundTransparency = 1
    LblAuthor.Text = WindowConfig.Author
    LblAuthor.TextColor3 = Color3.fromRGB(160, 140, 190)
    LblAuthor.FontFace = FontUI
    LblAuthor.TextSize = 11
    LblAuthor.TextXAlignment = Enum.TextXAlignment.Right
    LblAuthor.ZIndex = 10
    RegisterText(LblAuthor)

    ExpandBtn = Instance.new("ImageButton", Toolbar)
    ExpandBtn.Size = UDim2.new(0, 24, 0, 24)
    ExpandBtn.AnchorPoint = Vector2.new(0, 0.5)
    ExpandBtn.Position = UDim2.new(1, 6, 0.5, 0)
    ExpandBtn.BackgroundTransparency = 1
    ExpandBtn.Image = Icons["chevron-right"] or ""
    ExpandBtn.ImageColor3 = Color3.fromRGB(200, 180, 230)
    ExpandBtn.ZIndex = 6
    ExpandBtn.MouseButton1Click:Connect(function()
        IsExpanded = not IsExpanded
        ExpandBtn.Image = IsExpanded and Icons["chevron-left"] or Icons["chevron-right"]
        UpdateToolbarWidth()
    end)

    local BtnToggleBar = Instance.new("ImageButton", Toolbar)
    BtnToggleBar.Size = UDim2.new(0, 24, 0, 24)
    BtnToggleBar.AnchorPoint = Vector2.new(0.5, 1)
    BtnToggleBar.Position = UDim2.new(0.5, 0, 0, -6)
    BtnToggleBar.BackgroundTransparency = 1
    BtnToggleBar.Image = Icons["chevron-down"] or ""
    BtnToggleBar.ImageColor3 = Color3.fromRGB(200, 180, 230)
    BtnToggleBar.ZIndex = 6

    IsBarVisible = WindowConfig.ShowWindow
    BtnToggleBar.Image = IsBarVisible and Icons["chevron-down"] or Icons["chevron-up"]
    BtnToggleBar.MouseButton1Click:Connect(function()
        IsBarVisible = not IsBarVisible
        BtnToggleBar.Image = IsBarVisible and Icons["chevron-down"] or Icons["chevron-up"]
        TweenService:Create(Toolbar, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Position = IsBarVisible and UDim2.new(0.5, 0, 1, -20) or UDim2.new(0.5, 0, 1, 60)
        }):Play()
        if not IsBarVisible and CurrentWindow then 
            local h = CurrentWindow:GetAttribute("Height") or 350
            ToggleWindow(CurrentWindow, h) 
        end
    end)

    return self
end

local TabClass = {}
TabClass.__index = TabClass

function LuannyUi:Tab(options)
    if not Initialized then self:CreateWindow({Title = "Luanny UI", Author = "Unknown"}) end
    LayoutOrderCount = LayoutOrderCount + 1

    local titleName = options.Title or "Tab"
    local iconName = options.Icon or "layout-grid"
    local windowHeight = options.Height or 350 
    local tabColor = options.Color or Color3.fromRGB(160, 90, 255)
    
    local winBgColor = WindowConfig.Theme == "Light" and Color3.fromRGB(35, 30, 45) or Color3.fromRGB(14, 12, 18)
    local winStrokeColor = WindowConfig.Theme == "Light" and Color3.fromRGB(100, 60, 140) or Color3.fromRGB(60, 35, 90)

    local btn = Instance.new("TextButton", DockContainer)
    btn.Size = UDim2.new(0, 32, 0, 32); btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255); btn.Text = ""; btn.LayoutOrder = LayoutOrderCount; btn.ZIndex = 8
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    
    local grad = Instance.new("UIGradient", btn)
    grad.Rotation = 45
    
    if typeof(tabColor) == "ColorSequence" then
        grad.Color = tabColor
    else
        local c = typeof(tabColor) == "Color3" and tabColor or Color3.fromRGB(160, 90, 255)
        local darker = Color3.new(c.R * 0.2, c.G * 0.15, c.B * 0.3)
        grad.Color = ColorSequence.new(darker, c)
    end
    
    local ic = Instance.new("ImageLabel", btn)
    ic.Size = UDim2.new(0, 18, 0, 18); ic.AnchorPoint = Vector2.new(0.5, 0.5); ic.Position = UDim2.new(0.5, 0, 0.5, 0); ic.BackgroundTransparency = 1; ic.Image = Icons[iconName] or ""; ic.ImageColor3 = Color3.fromRGB(255,255,255); ic.ZIndex = 9

    local maskFrame = Instance.new("Frame", ScreenGui)
    maskFrame.AnchorPoint = Vector2.new(0.5, 1)
    maskFrame.Position = UDim2.new(0.5, 0, 1, -72)
    maskFrame.Size = UDim2.new(0, 380, 0, windowHeight)
    maskFrame.BackgroundTransparency = 1
    maskFrame.ClipsDescendants = true
    maskFrame.Visible = false
    maskFrame.ZIndex = 10
    maskFrame:SetAttribute("Height", windowHeight)
    
    local frame = Instance.new("CanvasGroup", maskFrame)
    frame.AnchorPoint = Vector2.new(0.5, 1)
    frame.Position = UDim2.new(0.5, 0, 1, 0)
    frame.Size = UDim2.new(0, 380, 0, windowHeight)
    frame.BackgroundColor3 = winBgColor
    frame.BackgroundTransparency = WindowConfig.Transparent and 0.15 or 0
    frame.GroupTransparency = 0
    frame.ZIndex = 10
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)
    Instance.new("UIStroke", frame).Color = winStrokeColor
    
    local tl = Instance.new("TextLabel", frame)
    tl.Size = UDim2.new(1, 0, 0, 45); tl.BackgroundTransparency = 1; tl.Text = titleName; tl.TextColor3 = Color3.fromRGB(200, 180, 230); tl.FontFace = FontUI; tl.TextSize = 22; tl.ZIndex = 11
    RegisterText(tl)

    local container = Instance.new("ScrollingFrame", frame)
    container.Size = UDim2.new(1, 0, 1, -50); container.Position = UDim2.new(0, 0, 0, 45); container.BackgroundTransparency = 1; container.ScrollBarThickness = 0; container.ZIndex = 11
    local layout = Instance.new("UIListLayout", container)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center; layout.SortOrder = Enum.SortOrder.LayoutOrder; layout.Padding = UDim.new(0, 8)
    Instance.new("UIPadding", container).PaddingTop = UDim.new(0, 5)

    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        container.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
    end)

    btn.MouseButton1Click:Connect(function() ToggleWindow(maskFrame, windowHeight) end)

    -- 自动打开第一个Tab
    if not CurrentWindow then
        task.spawn(function()
            task.wait(0.15)
            ToggleWindow(maskFrame, windowHeight)
        end)
    end

    local TabData = {Container = container, ItemCount = 0}
    setmetatable(TabData, TabClass)
    return TabData
end

function TabClass:Section(options)
    self.ItemCount = self.ItemCount + 1
    local titleText = options.Title or "Section"
    
    local sectionFrame = Instance.new("Frame", self.Container)
    sectionFrame.Size = UDim2.new(0, 340, 0, 30)
    sectionFrame.BackgroundTransparency = 1
    sectionFrame.LayoutOrder = self.ItemCount
    
    local lbl = Instance.new("TextLabel", sectionFrame)
    lbl.Size = UDim2.new(1, -10, 1, 0)
    lbl.Position = UDim2.new(0, 5, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = titleText
    lbl.TextColor3 = Color3.fromRGB(180, 160, 210)
    lbl.FontFace = FontUI
    lbl.TextSize = 14
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    RegisterText(lbl)
    
    local line = Instance.new("Frame", sectionFrame)
    line.Size = UDim2.new(1, 0, 0, 1)
    line.Position = UDim2.new(0, 0, 1, -1)
    line.BackgroundColor3 = Color3.fromRGB(120, 70, 180)
    line.BackgroundTransparency = 0.6

    return {
        SetTitle = function(t) lbl.Text = t end,
        Destroy = function() 
            AnimationSystem:FadeOut(sectionFrame, 0.3, function()
                sectionFrame:Destroy()
            end)
        end
    }
end

function TabClass:Button(options)
    self.ItemCount = self.ItemCount + 1
    local isLight = WindowConfig.Theme == "Light"

    local card = Instance.new("TextButton", self.Container)
    card.Size = UDim2.new(0, 340, 0, 55); card.BackgroundColor3 = isLight and Color3.fromRGB(35, 30, 45) or Color3.fromRGB(20, 18, 24); card.BackgroundTransparency = WindowConfig.Transparent and 0.2 or 0; card.Text = ""; card.AutoButtonColor = false; card.LayoutOrder = self.ItemCount; card.ZIndex = 12
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)
    local stroke = Instance.new("UIStroke", card)
    stroke.Color = isLight and Color3.fromRGB(80, 50, 120) or Color3.fromRGB(50, 35, 70)

    local lockOverlay = CreateLockOverlay(card)

    local lblTitle = Instance.new("TextLabel", card)
    lblTitle.Size = UDim2.new(1, -20, 0, 18); lblTitle.Position = UDim2.new(0, 10, 0, 8); lblTitle.BackgroundTransparency = 1; lblTitle.Text = options.Title or "Button"; lblTitle.TextColor3 = Color3.fromRGB(220, 200, 245); lblTitle.FontFace = FontUI; lblTitle.TextSize = 14; lblTitle.TextXAlignment = Enum.TextXAlignment.Left; lblTitle.ZIndex = 13
    RegisterText(lblTitle)

    local lblDesc = Instance.new("TextLabel", card)
    lblDesc.Size = UDim2.new(1, -20, 0, 16); lblDesc.Position = UDim2.new(0, 10, 0, 28); lblDesc.BackgroundTransparency = 1; lblDesc.Text = options.Desc or ""; lblDesc.TextColor3 = Color3.fromRGB(170, 150, 190); lblDesc.FontFace = FontUI; lblDesc.TextSize = 11; lblDesc.TextXAlignment = Enum.TextXAlignment.Left; lblDesc.ZIndex = 13
    RegisterText(lblDesc)

    local ic = Instance.new("ImageLabel", card)
    ic.Size = UDim2.new(0, 16, 0, 16); ic.AnchorPoint = Vector2.new(1, 0.5); ic.Position = UDim2.new(1, -10, 0.5, 0); ic.BackgroundTransparency = 1; ic.Image = Icons[options.Icon or "mouse-pointer-click"] or ""; ic.ImageColor3 = Color3.fromRGB(200, 180, 230); ic.ZIndex = 13

    card.MouseEnter:Connect(function() 
        if not lockOverlay.Visible then 
            TweenService:Create(stroke, TweenInfo.new(0.2), {Color = isLight and Color3.fromRGB(120, 80, 160) or Color3.fromRGB(80, 50, 120)}):Play()
            AnimationSystem:Pulse(card, 1.02, 0.2)
        end 
    end)
    card.MouseLeave:Connect(function() 
        if not lockOverlay.Visible then 
            TweenService:Create(stroke, TweenInfo.new(0.2), {Color = isLight and Color3.fromRGB(80, 50, 120) or Color3.fromRGB(50, 35, 70)}):Play()
        end 
    end)
    
    card.MouseButton1Click:Connect(function()
        if lockOverlay.Visible then return end
        local hoverColor = isLight and Color3.fromRGB(45, 38, 58) or Color3.fromRGB(35, 30, 45)
        local baseColor = isLight and Color3.fromRGB(35, 30, 45) or Color3.fromRGB(20, 18, 24)
        local tw = TweenService:Create(card, TweenInfo.new(0.1), {BackgroundColor3 = hoverColor})
        tw:Play()
        tw.Completed:Connect(function() 
            TweenService:Create(card, TweenInfo.new(0.1), {BackgroundColor3 = baseColor}):Play()
        end)
        if options.Callback then task.spawn(options.Callback) end
    end)

    -- 入场动画
    AnimationSystem:FadeIn(card, 0.3, self.ItemCount * 0.05)
    AnimationSystem:SlideIn(card, "left", 0.3, self.ItemCount * 0.05)

    return {
        SetTitle = function(t) lblTitle.Text = t end,
        SetDesc = function(d) lblDesc.Text = d end,
        Lock = function() lockOverlay.Visible = true; TweenService:Create(lockOverlay, TweenInfo.new(0.2), {BackgroundTransparency = 0.5}):Play() end,
        Unlock = function() TweenService:Create(lockOverlay, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play() task.wait(0.2) lockOverlay.Visible = false end,
        Destroy = function() 
            AnimationSystem:FadeOut(card, 0.3, function()
                card:Destroy()
            end)
        end
    }
end

function TabClass:Toggle(options)
    self.ItemCount = self.ItemCount + 1
    local state = options.Value or false
    local isLight = WindowConfig.Theme == "Light"
    local isCheckbox = options.Type == "Checkbox"

    local card = Instance.new("TextButton", self.Container)
    card.Size = UDim2.new(0, 340, 0, 60); card.BackgroundColor3 = isLight and Color3.fromRGB(35, 30, 45) or Color3.fromRGB(20, 18, 24); card.BackgroundTransparency = WindowConfig.Transparent and 0.2 or 0; card.Text = ""; card.AutoButtonColor = false; card.LayoutOrder = self.ItemCount; card.ZIndex = 12
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)
    Instance.new("UIStroke", card).Color = isLight and Color3.fromRGB(80, 50, 120) or Color3.fromRGB(50, 35, 70)

    local lockOverlay = CreateLockOverlay(card)
    local textOffset = options.Icon and 35 or 10

    if options.Icon then
        local ic = Instance.new("ImageLabel", card)
        ic.Size = UDim2.new(0, 18, 0, 18); ic.Position = UDim2.new(0, 10, 0, 10); ic.BackgroundTransparency = 1; ic.Image = Icons[options.Icon] or ""; ic.ImageColor3 = Color3.fromRGB(200, 180, 230); ic.ZIndex = 13
    end

    local lblTitle = Instance.new("TextLabel", card)
    lblTitle.Size = UDim2.new(1, -(textOffset + 50), 0, 16); lblTitle.Position = UDim2.new(0, textOffset, 0, 10); lblTitle.BackgroundTransparency = 1; lblTitle.Text = options.Title or "Toggle"; lblTitle.TextColor3 = Color3.fromRGB(220, 200, 245); lblTitle.FontFace = FontUI; lblTitle.TextSize = 14; lblTitle.TextXAlignment = Enum.TextXAlignment.Left; lblTitle.ZIndex = 13
    RegisterText(lblTitle)

    local lblDesc = Instance.new("TextLabel", card)
    lblDesc.Size = UDim2.new(1, -20, 0, 28); lblDesc.Position = UDim2.new(0, 10, 0, 28); lblDesc.BackgroundTransparency = 1; lblDesc.Text = options.Desc or ""; lblDesc.TextColor3 = Color3.fromRGB(170, 150, 190); lblDesc.FontFace = FontUI; lblDesc.TextSize = 11; lblDesc.TextWrapped = true; lblDesc.TextXAlignment = Enum.TextXAlignment.Left; lblDesc.TextYAlignment = Enum.TextYAlignment.Top; lblDesc.ZIndex = 13
    RegisterText(lblDesc)

    local offColor = isLight and Color3.fromRGB(60, 50, 80) or Color3.fromRGB(40, 30, 55)
    local switchBg = Instance.new("Frame", card)
    switchBg.AnchorPoint = Vector2.new(1, 0.5); switchBg.Position = UDim2.new(1, -10, 0.5, 0); switchBg.ZIndex = 14

    local checkMark, circle

    if isCheckbox then
        switchBg.Size = UDim2.new(0, 22, 0, 22); switchBg.BackgroundColor3 = state and Color3.fromRGB(160, 90, 255) or offColor
        Instance.new("UICorner", switchBg).CornerRadius = UDim.new(0, 6)
        checkMark = Instance.new("ImageLabel", switchBg); checkMark.Size = UDim2.new(0, 16, 0, 16); checkMark.AnchorPoint = Vector2.new(0.5, 0.5); checkMark.Position = UDim2.new(0.5, 0, 0.5, 0); checkMark.BackgroundTransparency = 1; checkMark.Image = Icons["check"] or ""; checkMark.ImageColor3 = Color3.fromRGB(255, 255, 255); checkMark.ImageTransparency = state and 0 or 1; checkMark.ZIndex = 15
    else
        switchBg.Size = UDim2.new(0, 32, 0, 18); switchBg.BackgroundColor3 = state and Color3.fromRGB(160, 90, 255) or offColor
        Instance.new("UICorner", switchBg).CornerRadius = UDim.new(1, 0)
        circle = Instance.new("Frame", switchBg); circle.Size = UDim2.new(0, 14, 0, 14); circle.AnchorPoint = Vector2.new(0, 0.5); circle.Position = state and UDim2.new(1, -16, 0.5, 0) or UDim2.new(0, 2, 0.5, 0); circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255); circle.ZIndex = 15
        Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)
    end

    local function updateVisual()
        TweenService:Create(switchBg, TweenInfo.new(0.2), {BackgroundColor3 = state and Color3.fromRGB(160, 90, 255) or offColor}):Play()
        if isCheckbox then
            TweenService:Create(checkMark, TweenInfo.new(0.2), {ImageTransparency = state and 0 or 1}):Play()
        else
            TweenService:Create(circle, TweenInfo.new(0.2), {Position = state and UDim2.new(1, -16, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)}):Play()
        end
    end

    card.MouseButton1Click:Connect(function()
        if lockOverlay.Visible then return end
        state = not state
        updateVisual()
        if options.Callback then task.spawn(options.Callback, state) end
    end)

    -- 入场动画
    AnimationSystem:FadeIn(card, 0.3, self.ItemCount * 0.05)
    AnimationSystem:SlideIn(card, "left", 0.3, self.ItemCount * 0.05)

    return {
        SetTitle = function(t) lblTitle.Text = t end,
        SetDesc = function(d) lblDesc.Text = d end,
        SetValue = function(v) state = v; updateVisual() end,
        Lock = function() lockOverlay.Visible = true; TweenService:Create(lockOverlay, TweenInfo.new(0.2), {BackgroundTransparency = 0.5}):Play() end,
        Unlock = function() TweenService:Create(lockOverlay, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play() task.wait(0.2) lockOverlay.Visible = false end,
        Destroy = function() 
            AnimationSystem:FadeOut(card, 0.3, function()
                card:Destroy()
            end)
        end,
        Get = function() return state end
    }
end

-- 其他方法类似添加动画效果...

function LuannyUi:Destroy()
    if ScreenGui then
        AnimationSystem:FadeOut(ScreenGui, 0.5, function()
            ScreenGui:Destroy()
            ScreenGui = nil
        end)
    end
    
    if NotifyScreen then
        NotifyScreen:Destroy()
        NotifyScreen = nil
    end
    
    Initialized = false
    CurrentWindow = nil
    IsBarVisible = true
    IsExpanded = false
    LayoutOrderCount = 0
    WindowConfig = {}
    AllTextElements = {}
end

function LuannyUi:Hide()
    if ScreenGui then
        AnimationSystem:FadeOut(ScreenGui, 0.3)
    end
end

function LuannyUi:Show()
    if ScreenGui then
        ScreenGui.Enabled = true
        AnimationSystem:FadeIn(ScreenGui, 0.3)
    end
end

return LuannyUi