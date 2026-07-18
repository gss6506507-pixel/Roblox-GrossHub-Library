
local GrossHub = {}

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local IsClosing = false
local RuntimeConnections = {}

local function TrackConnection(connection)
    table.insert(RuntimeConnections, connection)
    return connection
end

local function DisconnectRuntime()
    for _, connection in ipairs(RuntimeConnections) do
        if connection and connection.Connected then
            connection:Disconnect()
        end
    end
    table.clear(RuntimeConnections)
end

-- [[ CONFIGURAÇÕES DE TEMA ]]
local Theme = {
    Background = Color3.fromRGB(15, 15, 15),
    Sidebar = Color3.fromRGB(20, 20, 25),
    SidebarTransparency = 0.4,
    Accent = Color3.fromRGB(0, 150, 255),
    TabBackground = Color3.fromRGB(10, 30, 60),
    TabTransparency = 0.5,
    Text = Color3.fromRGB(255, 255, 255),
    TextDark = Color3.fromRGB(150, 150, 150),
    Section = Color3.fromRGB(25, 25, 30),
    Element = Color3.fromRGB(30, 30, 35),
    Stroke = Color3.fromRGB(40, 40, 45),
    SliderHandle = Color3.fromRGB(255, 255, 255)
}

local Themes = {
    Default = { Background = Color3.fromRGB(15, 15, 15), Sidebar = Color3.fromRGB(20, 20, 25), Accent = Color3.fromRGB(0, 150, 255), Section = Color3.fromRGB(25, 25, 30), Element = Color3.fromRGB(30, 30, 35) },
    Dark = { Background = Color3.fromRGB(10, 10, 10), Sidebar = Color3.fromRGB(15, 15, 15), Accent = Color3.fromRGB(100, 100, 100), Section = Color3.fromRGB(20, 20, 20), Element = Color3.fromRGB(25, 25, 25) },
    Lemon = { Background = Color3.fromRGB(20, 20, 10), Sidebar = Color3.fromRGB(25, 25, 15), Accent = Color3.fromRGB(255, 255, 0), Section = Color3.fromRGB(30, 30, 20), Element = Color3.fromRGB(35, 35, 25) },
    Rose = { Background = Color3.fromRGB(20, 10, 15), Sidebar = Color3.fromRGB(25, 15, 20), Accent = Color3.fromRGB(255, 100, 150), Section = Color3.fromRGB(30, 20, 25), Element = Color3.fromRGB(35, 25, 30) },
    Ocean = { Background = Color3.fromRGB(10, 15, 20), Sidebar = Color3.fromRGB(15, 20, 25), Accent = Color3.fromRGB(0, 200, 255), Section = Color3.fromRGB(20, 25, 30), Element = Color3.fromRGB(25, 30, 35) },
    Purple = { Background = Color3.fromRGB(15, 10, 20), Sidebar = Color3.fromRGB(20, 15, 25), Accent = Color3.fromRGB(150, 0, 255), Section = Color3.fromRGB(25, 20, 30), Element = Color3.fromRGB(30, 25, 35) }
}

-- [[ FUNÇÕES UTILITÁRIAS ]]
local function Create(class, props)
    local obj = Instance.new(class)
    for i, v in pairs(props) do if i ~= "Parent" then obj[i] = v end end
    obj.Parent = props.Parent
    return obj
end

-- Sistema de Arrasto Profissional (Lerp / Smooth Drag / Mobile Support)
local function MakeDraggable(frame, dragHandle, extraFrames)
    dragHandle = dragHandle or frame
    extraFrames = extraFrames or {}

    local dragging = false
    local dragInput, dragStart, startPos
    local extraStartPositions = {}
    local lerpFactor = 0.15
    local targetPos = frame.Position
    local extraTargetPositions = {}

    for _, extra in ipairs(extraFrames) do
        extraTargetPositions[extra] = extra.Position
    end

    local function update(input)
        local delta = input.Position - dragStart
        targetPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)

        for extraFrame, extraStartPos in pairs(extraStartPositions) do
            extraTargetPositions[extraFrame] = UDim2.new(
                extraStartPos.X.Scale,
                extraStartPos.X.Offset + delta.X,
                extraStartPos.Y.Scale,
                extraStartPos.Y.Offset + delta.Y
            )
        end
    end

    dragHandle.InputBegan:Connect(function(input)
        if IsClosing then return end

        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            extraStartPositions = {}

            for _, extra in ipairs(extraFrames) do
                extraStartPositions[extra] = extra.Position
            end

            local connection
            connection = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    connection:Disconnect()
                end
            end)
        end
    end)

    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    TrackConnection(UserInputService.InputChanged:Connect(function(input)
        if not IsClosing and input == dragInput and dragging then
            update(input)
        end
    end))

    TrackConnection(RunService.RenderStepped:Connect(function()
        if IsClosing or not frame.Parent then return end

        frame.Position = frame.Position:Lerp(targetPos, lerpFactor)
        for extraFrame, target in pairs(extraTargetPositions) do
            if extraFrame.Parent then
                extraFrame.Position = extraFrame.Position:Lerp(target, lerpFactor)
            end
        end
    end))

    return function(f, newPos)
        extraTargetPositions[f] = newPos
    end
end

-- Sistema de Redimensionamento Profissional (Lerp / Mobile Support)
local function MakeResizable(frame, handle)
    local dragging = false
    local dragInput, dragStart, startSize
    local targetSize = frame.Size
    local lerpFactor = 0.15

    local function update(input)
        local delta = input.Position - dragStart
        targetSize = UDim2.new(0, math.max(400, startSize.X.Offset + delta.X), 0, math.max(300, startSize.Y.Offset + delta.Y))
    end

    handle.InputBegan:Connect(function(input)
        if IsClosing then return end

        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startSize = frame.Size

            local connection
            connection = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    connection:Disconnect()
                end
            end)
        end
    end)

    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    TrackConnection(UserInputService.InputChanged:Connect(function(input)
        if not IsClosing and input == dragInput and dragging then
            update(input)
        end
    end))

    TrackConnection(RunService.RenderStepped:Connect(function()
        if not IsClosing and frame.Parent then
            frame.Size = frame.Size:Lerp(targetSize, lerpFactor)
        end
    end))
end

local function PlayEvaporateAnimation(root)
    if not root.Visible then return end

    local tweenInfo = TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
    local scale = root:FindFirstChild("DestroyScale")

    if not scale then
        scale = Create("UIScale", {Name = "DestroyScale", Parent = root, Scale = 1})
    end

    local currentPosition = root.Position
    TweenService:Create(root, tweenInfo, {
        Position = UDim2.new(currentPosition.X.Scale, currentPosition.X.Offset, currentPosition.Y.Scale, currentPosition.Y.Offset - 14),
        BackgroundTransparency = 1,
    }):Play()
    TweenService:Create(scale, tweenInfo, {Scale = 0.84}):Play()

    for _, object in ipairs(root:GetDescendants()) do
        if object:IsA("GuiObject") then
            TweenService:Create(object, tweenInfo, {BackgroundTransparency = 1}):Play()

            if object:IsA("TextLabel") or object:IsA("TextButton") or object:IsA("TextBox") then
                TweenService:Create(object, tweenInfo, {
                    TextTransparency = 1,
                    TextStrokeTransparency = 1,
                }):Play()
            end

            if object:IsA("ImageLabel") or object:IsA("ImageButton") then
                TweenService:Create(object, tweenInfo, {ImageTransparency = 1}):Play()
            end

            if object:IsA("ScrollingFrame") then
                TweenService:Create(object, tweenInfo, {ScrollBarImageTransparency = 1}):Play()
            end
        elseif object:IsA("UIStroke") then
            TweenService:Create(object, tweenInfo, {Transparency = 1}):Play()
        end
    end
end

local UIObjects = {Sections = {}, Elements = {}, TabButtons = {}}
local CurrentTab = nil

local function UpdateTheme(themeName)
    local selectedTheme = Themes[themeName]
    if not selectedTheme then return end
    Theme.Background = selectedTheme.Background
    Theme.Sidebar = selectedTheme.Sidebar
    Theme.Accent = selectedTheme.Accent
    Theme.Section = selectedTheme.Section
    Theme.Element = selectedTheme.Element
    -- These will be applied to the window elements directly
    -- MainFrame.BackgroundColor3 = Theme.Background
    -- ListFrame.BackgroundColor3 = Theme.Background
    -- Sidebar.BackgroundColor3 = Theme.Sidebar
    -- ListHeader.BackgroundColor3 = Theme.Sidebar
    -- MinimizedFrame.BackgroundColor3 = Theme.Background
    for _, section in ipairs(UIObjects.Sections) do section.BackgroundColor3 = Theme.Section end
    for _, element in ipairs(UIObjects.Elements) do
        if element:IsA("TextButton") or element:IsA("TextBox") or element:IsA("Frame") then
            if element.Name:find("Button") or element.Name:find("TextBox") or element.Name:find("Dropdown") then element.BackgroundColor3 = Theme.Element end
        end
    end
    if CurrentTab then CurrentTab.Icon.ImageColor3 = Theme.Accent end
end

local PlayerButtons = {}
local SelectedPlayer = nil

local function ApplyPlayerVisual(player, button, instant)
    if not button or not button.Parent then return end

    local isSelected = player == SelectedPlayer
    local properties = {
        BackgroundColor3 = isSelected and Theme.Accent or Theme.Element,
        BackgroundTransparency = isSelected and 0.68 or 1,
        TextColor3 = isSelected and Theme.Text or Theme.TextDark,
    }

    if instant then
        for property, value in pairs(properties) do
            button[property] = value
        end
    else
        TweenService:Create(button, TweenInfo.new(0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), properties):Play()
    end
end

local function UpdatePlayerSelection(player)
    if IsClosing then return end

    SelectedPlayer = (SelectedPlayer == player) and nil or player

    for listedPlayer, button in pairs(PlayerButtons) do
        ApplyPlayerVisual(listedPlayer, button, false)
    end
end

-- GrossHub.CreateWindow function
function GrossHub.CreateWindow(title)
    local Window = {}
    local HUB_TITLE = title or "GROSS HUB"

    local ScreenGui = Create("ScreenGui", { Name = "GrossHub", Parent = (RunService:IsStudio() and LocalPlayer.PlayerGui or game:GetService("CoreGui")), ResetOnSpawn = false, IgnoreGuiInset = true })
    local MainFrame = Create("Frame", { Name = "MainFrame", Parent = ScreenGui, BackgroundColor3 = Theme.Background, BorderSizePixel = 0, Position = UDim2.new(0.5, -350, 0.5, -225), Size = UDim2.new(0, 700, 0, 450), ClipsDescendants = true })
    Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = MainFrame})
    local MainStroke = Create("UIStroke", {Color = Theme.Stroke, Thickness = 1, Parent = MainFrame})

    local Sidebar = Create("Frame", { Name = "Sidebar", Parent = MainFrame, BackgroundColor3 = Theme.Sidebar, BackgroundTransparency = Theme.SidebarTransparency, BorderSizePixel = 0, Size = UDim2.new(0, 180, 1, 0) })

    local Controls = Create("Frame", { Name = "Controls", Parent = Sidebar, BackgroundTransparency = 1, Position = UDim2.new(1, -55, 0, 10), Size = UDim2.new(0, 50, 0, 20) })
    local MinimizeBtn = Create("ImageButton", { Name = "Minimize", Parent = Controls, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 0), Size = UDim2.new(0, 18, 0, 18), Image = "rbxassetid://82235228007110", ImageColor3 = Theme.TextDark })
    local CloseBtn = Create("ImageButton", { Name = "Close", Parent = Controls, BackgroundTransparency = 1, Position = UDim2.new(0, 25, 0, 0), Size = UDim2.new(0, 18, 0, 18), Image = "rbxassetid://117081647256543", ImageColor3 = Theme.TextDark })

    local MinimizedFrame = Create("Frame", { Name = "MinimizedFrame", Parent = ScreenGui, BackgroundColor3 = Theme.Background, BorderSizePixel = 0, Position = UDim2.new(0.5, -100, 0, 50), Size = UDim2.new(0, 200, 0, 35), Visible = false, ClipsDescendants = true })
    Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = MinimizedFrame})
    Create("UIStroke", {Color = Theme.Stroke, Thickness = 1, Parent = MinimizedFrame})
    local MinimizedLabel = Create("TextLabel", { Parent = MinimizedFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 15, 0, 0), Size = UDim2.new(0, 100, 1, 0), Font = Enum.Font.GothamBold, Text = HUB_TITLE, TextColor3 = Theme.Text, TextSize = 18, TextXAlignment = Enum.TextXAlignment.Left })
    local RestoreBtn = Create("ImageButton", { Name = "Restore", Parent = MinimizedFrame, BackgroundTransparency = 1, Position = UDim2.new(1, -30, 0.5, -9), Size = UDim2.new(0, 18, 0, 18), Image = "rbxassetid://15929013661", ImageColor3 = Theme.Text })

    local Logo = Create("ImageLabel", { Name = "Logo", Parent = Sidebar, BackgroundTransparency = 1, Position = UDim2.new(0.5, -40, 0, 35), Size = UDim2.new(0, 80, 0, 80), Image = "rbxassetid://120694317945692" })
    local TitleLabel = Create("TextLabel", { Name = "Title", Parent = Sidebar, BackgroundTransparency = 1, Position = UDim2.new(0, 15, 0, 120), Size = UDim2.new(1, -30, 0, 30), Font = Enum.Font.GothamBold, Text = HUB_TITLE, TextColor3 = Theme.Text, TextSize = 20, TextXAlignment = Enum.TextXAlignment.Center })
    local TabContainer = Create("ScrollingFrame", { Name = "TabContainer", Parent = Sidebar, BackgroundTransparency = 1, BorderSizePixel = 0, Position = UDim2.new(0, 0, 0, 160), Size = UDim2.new(1, 0, 1, -220), ScrollBarThickness = 0, CanvasSize = UDim2.new(0, 0, 0, 0) })
    Create("UIListLayout", {Parent = TabContainer, Padding = UDim.new(0, 5), HorizontalAlignment = Enum.HorizontalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder})

    local UserProfile = Create("Frame", { Name = "UserProfile", Parent = Sidebar, BackgroundColor3 = Color3.fromRGB(25, 25, 30), BorderSizePixel = 0, Position = UDim2.new(0, 0, 1, -60), Size = UDim2.new(1, 0, 0, 60) })
    local RGBLine = Create("Frame", {Name = "RGBLine", Parent = UserProfile, BackgroundColor3 = Color3.new(1,1,1), BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 2)})
    local UIGradient = Create("UIGradient", {Parent = RGBLine, Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)), ColorSequenceKeypoint.new(0.2, Color3.fromRGB(255, 255, 0)), ColorSequenceKeypoint.new(0.4, Color3.fromRGB(0, 255, 0)), ColorSequenceKeypoint.new(0.6, Color3.fromRGB(0, 255, 255)), ColorSequenceKeypoint.new(0.8, Color3.fromRGB(0, 0, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 255)) })})
    TrackConnection(RunService.RenderStepped:Connect(function()
        if not IsClosing then
            UIGradient.Offset = Vector2.new(math.sin(tick() * 2) * 1, 0)
        end
    end))
    local UserImage = Create("ImageLabel", {Name = "UserImage", Parent = UserProfile, BackgroundColor3 = Color3.fromRGB(35, 35, 40), Position = UDim2.new(0, 15, 0.5, -17), Size = UDim2.new(0, 35, 0, 35), Image = "rbxthumb://type=AvatarHeadShot&id="..LocalPlayer.UserId.."&w=150&h=150"})
    Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = UserImage})
    local UserName = Create("TextLabel", {Name = "UserName", Parent = UserProfile, BackgroundTransparency = 1, Position = UDim2.new(0, 60, 0.5, -8), Size = UDim2.new(1, -70, 0, 16), Font = Enum.Font.GothamBold, Text = LocalPlayer.DisplayName or LocalPlayer.Name, TextColor3 = Theme.Text, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd})

    local ListFrame = Create("Frame", { Name = "ListFrame", Parent = ScreenGui, BackgroundColor3 = Theme.Background, BorderSizePixel = 0, Position = UDim2.new(0.5, 360, 0.5, -100), Size = UDim2.new(0, 200, 0, 200), ClipsDescendants = true })
    Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = ListFrame})
    local ListStroke = Create("UIStroke", {Color = Theme.Stroke, Thickness = 1, Parent = ListFrame})
    local ListHeader = Create("Frame", { Name = "Header", Parent = ListFrame, BackgroundColor3 = Theme.Sidebar, Size = UDim2.new(1, 0, 0, 50), BorderSizePixel = 0 })
    local ListTitle = Create("TextLabel", { Name = "ListTitle", Parent = ListHeader, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 5), Size = UDim2.new(1, 0, 0, 20), Font = Enum.Font.GothamBold, Text = "Lista de Jogadores (0)", TextColor3 = Theme.Text, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Center })
    local SearchBox = Create("TextBox", { Name = "SearchBox", Parent = ListHeader, BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 25), Size = UDim2.new(1, -20, 0, 16), Font = Enum.Font.Gotham, PlaceholderText = "Pesquisar", Text = "", TextColor3 = Theme.TextDark, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left })
    local ListContainer = Create("ScrollingFrame", { Name = "ListContainer", Parent = ListFrame, BackgroundTransparency = 1, BorderSizePixel = 0, Position = UDim2.new(0, 10, 0, 60), Size = UDim2.new(1, -20, 1, -70), ScrollBarThickness = 2, ScrollBarImageColor3 = Theme.Accent, CanvasSize = UDim2.new(0, 0, 0, 0) })
    local ListLayout = Create("UIListLayout", {Parent = ListContainer, Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder})

    local ResizeHandle = Create("ImageLabel", { Name = "ResizeHandle", Parent = MainFrame, BackgroundTransparency = 1, Position = UDim2.new(1, -20, 1, -20), Size = UDim2.new(0, 20, 0, 20), Image = "rbxassetid://87584126977170", ImageColor3 = Theme.TextDark, ZIndex = 10, Rotation = 90 })

    local syncListTarget = MakeDraggable(MainFrame, Sidebar, {ListFrame})
    local draggingList = false
    local listDragInput, listDragStart, listStartPos
    local listTargetPos = ListFrame.Position
    ListHeader.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then draggingList = true listDragStart = input.Position listStartPos = ListFrame.Position local connection connection = input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then draggingList = false connection:Disconnect() end end) end end)
    ListHeader.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then listDragInput = input end end)
    TrackConnection(UserInputService.InputChanged:Connect(function(input)
        if not IsClosing and input == listDragInput and draggingList then
            local delta = input.Position - listDragStart
            listTargetPos = UDim2.new(listStartPos.X.Scale, listStartPos.X.Offset + delta.X, listStartPos.Y.Scale, listStartPos.Y.Offset + delta.Y)
            syncListTarget(ListFrame, listTargetPos)
        end
    end))
    TrackConnection(RunService.RenderStepped:Connect(function()
        if not IsClosing and draggingList and ListFrame.Parent then
            ListFrame.Position = ListFrame.Position:Lerp(listTargetPos, 0.15)
        end
    end))

    MakeResizable(MainFrame, ResizeHandle)
    MakeDraggable(MinimizedFrame)

    local function DestroyHub()
        if IsClosing then return end

        IsClosing = true
        DisconnectRuntime()

        MainFrame.Active = false
        ListFrame.Active = false
        MinimizedFrame.Active = false

        PlayEvaporateAnimation(MainFrame)
        PlayEvaporateAnimation(ListFrame)
        PlayEvaporateAnimation(MinimizedFrame)

        task.delay(0.48, function()
            if ScreenGui and ScreenGui.Parent then
                ScreenGui:Destroy()
            end
        end)
    end

    CloseBtn.MouseButton1Click:Connect(DestroyHub)

    MinimizeBtn.MouseButton1Click:Connect(function()
        if IsClosing then return end

        MinimizedLabel.Text = TitleLabel.Text
        MinimizedFrame.Position = UDim2.fromOffset(MainFrame.AbsolutePosition.X, MainFrame.AbsolutePosition.Y)
        MainFrame.Visible = false
        ListFrame.Visible = false
        MinimizedFrame.Visible = true
    end)

    RestoreBtn.MouseButton1Click:Connect(function()
        if IsClosing then return end

        MinimizedFrame.Visible = false
        MainFrame.Visible = true
        ListFrame.Visible = true
    end)

    local function UpdatePlayerList()
        if IsClosing then return end

        if SelectedPlayer and SelectedPlayer.Parent ~= Players then
            SelectedPlayer = nil
        end

        for _, button in pairs(PlayerButtons) do
            if button and button.Parent then
                button:Destroy()
            end
        end
        table.clear(PlayerButtons)

        local players = Players:GetPlayers()
        local visiblePlayersCount = 0
        local query = SearchBox.Text:lower()

        for _, player in ipairs(players) do
            if player ~= LocalPlayer then
                local distance = 0
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    distance = math.floor((LocalPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude)
                end

                local displayText = player.Name .. " - " .. distance .. "m"
                if query == "" or displayText:lower():find(query, 1, true) then
                    visiblePlayersCount = visiblePlayersCount + 1

                    local playerButton = Create("TextButton", {
                        Name = "Player_" .. player.UserId,
                        Parent = ListContainer,
                        BackgroundColor3 = Theme.Element,
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        Size = UDim2.new(1, 0, 0, 22),
                        AutoButtonColor = false,
                        Font = Enum.Font.Gotham,
                        Text = displayText,
                        TextColor3 = Theme.TextDark,
                        TextSize = 12,
                        TextTruncate = Enum.TextTruncate.AtEnd,
                        TextXAlignment = Enum.TextXAlignment.Left,
                    })
                    Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = playerButton})
                    Create("UIPadding", {
                        Parent = playerButton,
                        PaddingLeft = UDim.new(0, 6),
                        PaddingRight = UDim.new(0, 6),
                    })

                    PlayerButtons[player] = playerButton
                    ApplyPlayerVisual(player, playerButton, true)

                    playerButton.MouseButton1Click:Connect(function()
                        UpdatePlayerSelection(player)
                    end)
                end
            end
        end

        local selectedSuffix = SelectedPlayer and (" • " .. SelectedPlayer.Name) or ""
        ListTitle.Text = "Lista de Jogadores (" .. visiblePlayersCount .. ")" .. selectedSuffix
        ListContainer.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y)
    end

    SearchBox:GetPropertyChangedSignal("Text"):Connect(UpdatePlayerList)

    task.spawn(function()
        while not IsClosing do
            task.wait(1)
            if not IsClosing then
                UpdatePlayerList()
            end
        end
    end)

    UpdatePlayerList()

    Window.Destroy = DestroyHub
    Window.UpdateTheme = UpdateTheme
    Window.GetSelectedPlayer = function() return SelectedPlayer end

    local ContentArea = Create("Frame", { Name = "ContentArea", Parent = MainFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 181, 0, 0), Size = UDim2.new(1, -181, 1, 0) })

    function Window:CreateTab(name, icon)
        local Tab = {}
        local TabButton = Create("TextButton", { Name = name.."Tab", Parent = TabContainer, BackgroundColor3 = Theme.TabBackground, BackgroundTransparency = Theme.TabTransparency, Size = UDim2.new(0, 160, 0, 35), AutoButtonColor = false, Text = "", ClipsDescendants = true })
        Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = TabButton})
        local TabIcon = Create("ImageLabel", {Name = "Icon", Parent = TabButton, BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0.5, -9), Size = UDim2.new(0, 18, 0, 18), Image = icon or "rbxassetid://6026568198", ImageColor3 = Theme.TextDark})
        local TabLabel = Create("TextLabel", {Name = "Label", Parent = TabButton, BackgroundTransparency = 1, Position = UDim2.new(0, 35, 0, 0), Size = UDim2.new(1, -35, 1, 0), Font = Enum.Font.GothamBold, Text = name, TextColor3 = Theme.TextDark, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left})
        local TabPage = Create("ScrollingFrame", {Name = name.."Page", Parent = ContentArea, BackgroundTransparency = 1, BorderSizePixel = 0, Position = UDim2.new(0, 20, 0, 20), Size = UDim2.new(1, -40, 1, -40), Visible = false, ScrollBarThickness = 2, ScrollBarImageColor3 = Theme.Accent, CanvasSize = UDim2.new(0, 0, 0, 0)})
        Create("UIListLayout", {Parent = TabPage, Padding = UDim.new(0, 15), SortOrder = Enum.SortOrder.LayoutOrder})
        local function Select()
            if CurrentTab then CurrentTab.Page.Visible = false TweenService:Create(CurrentTab.Button, TweenInfo.new(0.3), {BackgroundTransparency = Theme.TabTransparency}):Play() TweenService:Create(CurrentTab.Label, TweenInfo.new(0.3), {TextColor3 = Theme.TextDark}):Play() TweenService:Create(CurrentTab.Icon, TweenInfo.new(0.3), {ImageColor3 = Theme.TextDark}):Play() end
            TabPage.Visible = true CurrentTab = {Button = TabButton, Page = TabPage, Label = TabLabel, Icon = TabIcon} TweenService:Create(TabButton, TweenInfo.new(0.3), {BackgroundTransparency = 0}):Play() TweenService:Create(TabLabel, TweenInfo.new(0.3), {TextColor3 = Theme.Text}):Play() TweenService:Create(TabIcon, TweenInfo.new(0.3), {ImageColor3 = Theme.Accent}):Play()
        end
        TabButton.MouseButton1Click:Connect(Select)
        if not CurrentTab then Select() end

        function Tab:CreateSection(title)
            local Section = {}
            local SectionFrame = Create("Frame", {Name = title.."Section", Parent = TabPage, BackgroundColor3 = Theme.Section, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 40)})
            Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = SectionFrame})
            Create("UIStroke", {Color = Color3.fromRGB(45, 45, 50), Thickness = 1, Parent = SectionFrame})
            table.insert(UIObjects.Sections, SectionFrame)
            local ElementContainer = Create("Frame", {Name = "Elements", Parent = SectionFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 35), Size = UDim2.new(1, 0, 1, -35)})
            local List = Create("UIListLayout", {Parent = ElementContainer, Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder, HorizontalAlignment = Enum.HorizontalAlignment.Center})
            Create("UIPadding", {Parent = ElementContainer, PaddingBottom = UDim.new(0, 10), PaddingTop = UDim.new(0, 5)})
            List:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() SectionFrame.Size = UDim2.new(1, 0, 0, List.AbsoluteContentSize.Y + 45) TabPage.CanvasSize = UDim2.new(0, 0, 0, TabPage.UIListLayout.AbsoluteContentSize.Y) end)

            function Section:CreateButton(text, callback)
                local ButtonFrame = Create("Frame", {Parent = ElementContainer, BackgroundTransparency = 1, Size = UDim2.new(1, -20, 0, 32)})
                local Button = Create("TextButton", {Parent = ButtonFrame, BackgroundColor3 = Theme.Element, Size = UDim2.new(1, 0, 1, 0), AutoButtonColor = false, Font = Enum.Font.GothamSemibold, Text = text, TextColor3 = Theme.Text, TextSize = 13})
                Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = Button})
                Create("UIStroke", {Color = Theme.Stroke, Parent = Button})
                table.insert(UIObjects.Elements, Button)
                Button.MouseButton1Click:Connect(callback)
            end

            function Section:CreateSlider(text, min, max, default, callback)
                local SliderFrame = Create("Frame", {Parent = ElementContainer, BackgroundTransparency = 1, Size = UDim2.new(1, -20, 0, 45)})
                Create("TextLabel", {Parent = SliderFrame, BackgroundTransparency = 1, Size = UDim2.new(1, -50, 0, 20), Font = Enum.Font.Gotham, Text = text, TextColor3 = Theme.TextDark, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left})
                local ValueLabel = Create("TextLabel", {Parent = SliderFrame, BackgroundTransparency = 1, Position = UDim2.new(1, -50, 0, 0), Size = UDim2.new(0, 50, 0, 20), Font = Enum.Font.GothamBold, Text = tostring(default), TextColor3 = Theme.Accent, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Right})
                local SliderBG = Create("Frame", {Parent = SliderFrame, BackgroundColor3 = Theme.Element, Position = UDim2.new(0, 0, 0, 25), Size = UDim2.new(1, 0, 0, 6)})
                Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = SliderBG})
                local SliderFill = Create("Frame", {Parent = SliderBG, BackgroundColor3 = Theme.Accent, Size = UDim2.new((default - min) / (max - min), 0, 1, 0)})
                Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = SliderFill})
                local SliderHandle = Create("Frame", {Parent = SliderFill, BackgroundColor3 = Theme.SliderHandle, Position = UDim2.new(1, -6, 0.5, -6), Size = UDim2.new(0, 12, 0, 12)})
                Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = SliderHandle})
                local dragging = false
                local targetFillSize = SliderFill.Size
                local function move(input)
                    local pos = math.clamp((input.Position.X - SliderBG.AbsolutePosition.X) / SliderBG.AbsoluteSize.X, 0, 1)
                    local val = math.floor(min + (max - min) * pos)
                    ValueLabel.Text = tostring(val)
                    targetFillSize = UDim2.new(pos, 0, 1, 0)
                    callback(val)
                end
                SliderBG.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true move(input) end end)
                SliderHandle.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true end end)
                TrackConnection(UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = false
                    end
                end))
                TrackConnection(UserInputService.InputChanged:Connect(function(input)
                    if not IsClosing and dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        move(input)
                    end
                end))
                TrackConnection(RunService.RenderStepped:Connect(function()
                    if not IsClosing and SliderFill.Parent then
                        SliderFill.Size = SliderFill.Size:Lerp(targetFillSize, 0.1)
                    end
                end))
            end

            function Section:CreateToggle(text, default, callback)
                local ToggleFrame = Create("Frame", {Parent = ElementContainer, BackgroundTransparency = 1, Size = UDim2.new(1, -20, 0, 32)})
                local Label = Create("TextLabel", {Parent = ToggleFrame, BackgroundTransparency = 1, Size = UDim2.new(1, -50, 1, 0), Font = Enum.Font.Gotham, Text = text, TextColor3 = Theme.TextDark, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left})
                local ToggleBG = Create("Frame", {Parent = ToggleFrame, BackgroundColor3 = Theme.Element, Position = UDim2.new(1, -45, 0.5, -11), Size = UDim2.new(0, 40, 0, 22)})
                Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = ToggleBG})
                local Circle = Create("Frame", {Parent = ToggleBG, BackgroundColor3 = Theme.TextDark, Position = UDim2.new(0, 3, 0.5, -8), Size = UDim2.new(0, 16, 0, 16)})
                Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Circle})
                local state = default or false
                local function update()
                    local targetPos = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
                    local targetColor = state and Theme.Accent or Theme.TextDark
                    TweenService:Create(Circle, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = targetPos, BackgroundColor3 = targetColor}):Play()
                    TweenService:Create(Label, TweenInfo.new(0.4), {TextColor3 = state and Theme.Text or Theme.TextDark}):Play()
                    callback(state)
                end
                ToggleFrame.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then state = not state update() end end)
                update()
            end

            function Section:CreateDropdown(text, options, default, callback)
                local DropdownFrame = Create("Frame", {Parent = ElementContainer, BackgroundTransparency = 1, Size = UDim2.new(1, -20, 0, 28)})
                Create("TextLabel", {Parent = DropdownFrame, BackgroundTransparency = 1, Size = UDim2.new(1, -60, 1, 0), Font = Enum.Font.Gotham, Text = text, TextColor3 = Theme.TextDark, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left})
                local DropdownButton = Create("TextButton", {Name = "Dropdown", Parent = DropdownFrame, BackgroundColor3 = Theme.Element, Position = UDim2.new(1, -85, 0.5, -10), Size = UDim2.new(0, 80, 0, 20), AutoButtonColor = false, Font = Enum.Font.Gotham, Text = default or (options and options[1]) or "None", TextColor3 = Theme.Text, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left})
                Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = DropdownButton})
                Create("UIPadding", {Parent = DropdownButton, PaddingLeft = UDim.new(0, 8)})
                table.insert(UIObjects.Elements, DropdownButton)
                local DropdownList = Create("ScrollingFrame", {Name = "DropdownList", Parent = ScreenGui, BackgroundColor3 = Theme.Element, BorderSizePixel = 0, Size = UDim2.new(0, 80, 0, 0), ZIndex = 10000, ClipsDescendants = true, Visible = false, ScrollBarThickness = 2, ScrollBarImageColor3 = Theme.Accent})
                Create("UIListLayout", {Parent = DropdownList, Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder})
                Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = DropdownList})
                table.insert(UIObjects.Elements, DropdownList)
                local function createOptionButton(optionText)
                    local OptionButton = Create("TextButton", {Parent = DropdownList, BackgroundColor3 = Theme.Element, Size = UDim2.new(1, 0, 0, 22), AutoButtonColor = false, Font = Enum.Font.Gotham, Text = optionText, TextColor3 = Theme.Text, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 10001})
                    Create("UIPadding", {Parent = OptionButton, PaddingLeft = UDim.new(0, 8)})
                    OptionButton.MouseButton1Click:Connect(function() DropdownButton.Text = optionText DropdownList.Visible = false callback(optionText) end)
                    table.insert(UIObjects.Elements, OptionButton)
                end
                if options then for _, option in ipairs(options) do createOptionButton(option) end end
                DropdownButton.MouseButton1Click:Connect(function() DropdownList.Visible = not DropdownList.Visible if DropdownList.Visible then DropdownList.Position = UDim2.new(0, DropdownButton.AbsolutePosition.X, 0, DropdownButton.AbsolutePosition.Y + 25) local targetY = math.min(#options * 24, 120) DropdownList.Size = UDim2.new(0, 80, 0, targetY) DropdownList.CanvasSize = UDim2.new(0, 0, 0, #options * 24) end end)
            end

            function Section:CreateTextBox(text, default, callback)
                local TextBoxFrame = Create("Frame", {Parent = ElementContainer, BackgroundTransparency = 1, Size = UDim2.new(1, -20, 0, 28)})
                Create("TextLabel", {Parent = TextBoxFrame, BackgroundTransparency = 1, Size = UDim2.new(1, -60, 1, 0), Font = Enum.Font.Gotham, Text = text, TextColor3 = Theme.TextDark, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left})
                local TextBox = Create("TextBox", {Name = "TextBox", Parent = TextBoxFrame, BackgroundColor3 = Theme.Element, Position = UDim2.new(1, -85, 0.5, -10), Size = UDim2.new(0, 80, 0, 20), ClearTextOnFocus = false, Font = Enum.Font.Gotham, Text = default or "", PlaceholderText = "...", TextColor3 = Theme.Text, TextSize = 11})
                Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = TextBox})
                table.insert(UIObjects.Elements, TextBox)
                TextBox.FocusLost:Connect(function() callback(TextBox.Text) end)
            end

            function Section:CreateKeybind(text, defaultKey, callback)
                local KeybindFrame = Create("Frame", {Parent = ElementContainer, BackgroundTransparency = 1, Size = UDim2.new(1, -20, 0, 28)})
                Create("TextLabel", {Parent = KeybindFrame, BackgroundTransparency = 1, Size = UDim2.new(1, -60, 1, 0), Font = Enum.Font.Gotham, Text = text, TextColor3 = Theme.TextDark, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left})
                local KeybindButton = Create("TextButton", {Parent = KeybindFrame, BackgroundColor3 = Theme.Element, Position = UDim2.new(1, -85, 0.5, -10), Size = UDim2.new(0, 80, 0, 20), AutoButtonColor = false, Font = Enum.Font.Gotham, Text = defaultKey or "NONE", TextColor3 = Theme.Text, TextSize = 11})
                Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = KeybindButton})
                table.insert(UIObjects.Elements, KeybindButton)
                local isBinding = false
                KeybindButton.MouseButton1Click:Connect(function() isBinding = true KeybindButton.Text = "..." end)
                TrackConnection(UserInputService.InputBegan:Connect(function(input, gp)
                    if not IsClosing and isBinding and not gp then
                        local key = (input.UserInputType == Enum.UserInputType.Keyboard) and input.KeyCode.Name or "NONE"
                        KeybindButton.Text = key
                        isBinding = false
                        callback(key)
                    end
                end))
            end
            return Section
        end
        return Tab
    end

    return Window
end

return GrossHub
