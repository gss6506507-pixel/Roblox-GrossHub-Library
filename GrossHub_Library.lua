
-- ╔═══════════════════════════════════════════════════════════════╗
-- ║                     GROSS HUB v5 - REFACTORED                ║
-- ║                                                               ║
-- ║  Melhorias:                                                   ║
-- ║  • Dropdown com animações e tamanho dinâmico                 ║
-- ║  • Background com imagem customizável                        ║
-- ║  • Código limpo e otimizado                                  ║
-- ║  • Animações suaves em todos os elementos                    ║
-- ╚═══════════════════════════════════════════════════════════════╝

local GrossHub = {}

-- ═══════════════════════════════════════════════════════════════
-- TEMAS PREDEFINIDOS
-- ═══════════════════════════════════════════════════════════════

GrossHub.Themes = {
    Default = {
        Background = Color3.fromRGB(15, 15, 15),
        Sidebar = Color3.fromRGB(20, 20, 25),
        Accent = Color3.fromRGB(0, 150, 255),
        Section = Color3.fromRGB(25, 25, 30),
        Element = Color3.fromRGB(30, 30, 35)
    },
    Dark = {
        Background = Color3.fromRGB(10, 10, 10),
        Sidebar = Color3.fromRGB(15, 15, 15),
        Accent = Color3.fromRGB(100, 100, 100),
        Section = Color3.fromRGB(20, 20, 20),
        Element = Color3.fromRGB(25, 25, 25)
    },
    Lemon = {
        Background = Color3.fromRGB(20, 20, 10),
        Sidebar = Color3.fromRGB(25, 25, 15),
        Accent = Color3.fromRGB(255, 255, 0),
        Section = Color3.fromRGB(30, 30, 20),
        Element = Color3.fromRGB(35, 35, 25)
    },
    Rose = {
        Background = Color3.fromRGB(20, 10, 15),
        Sidebar = Color3.fromRGB(25, 15, 20),
        Accent = Color3.fromRGB(255, 100, 150),
        Section = Color3.fromRGB(30, 20, 25),
        Element = Color3.fromRGB(35, 25, 30)
    },
    Ocean = {
        Background = Color3.fromRGB(10, 15, 20),
        Sidebar = Color3.fromRGB(15, 20, 25),
        Accent = Color3.fromRGB(0, 200, 255),
        Section = Color3.fromRGB(20, 25, 30),
        Element = Color3.fromRGB(25, 30, 35)
    },
    Purple = {
        Background = Color3.fromRGB(15, 10, 20),
        Sidebar = Color3.fromRGB(20, 15, 25),
        Accent = Color3.fromRGB(150, 0, 255),
        Section = Color3.fromRGB(25, 20, 30),
        Element = Color3.fromRGB(30, 25, 35)
    }
}

-- ═══════════════════════════════════════════════════════════════
-- SERVIÇOS E CONFIGURAÇÃO GLOBAL
-- ═══════════════════════════════════════════════════════════════

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local IsClosing = false
local RuntimeConnections = {}

-- ═══════════════════════════════════════════════════════════════
-- UTILITÁRIOS
-- ═══════════════════════════════════════════════════════════════

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

local function Create(class, props)
    local obj = Instance.new(class)
    for i, v in pairs(props) do
        if i ~= "Parent" then
            obj[i] = v
        end
    end
    obj.Parent = props.Parent
    return obj
end

local function Tween(instance, duration, properties)
    local tweenInfo = TweenInfo.new(
        duration,
        Enum.EasingStyle.Quart,
        Enum.EasingDirection.Out
    )
    local tween = TweenService:Create(instance, tweenInfo, properties)
    tween:Play()
    return tween
end

local function AddClickEffect(button, accentColor, elementColor)
    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Tween(button, 0.1, {
                BackgroundColor3 = accentColor,
                BackgroundTransparency = 0.3
            })
        end
    end)
    button.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Tween(button, 0.2, {
                BackgroundColor3 = elementColor,
                BackgroundTransparency = 0
            })
        end
    end)
end

local function MakeDraggable(frame, dragHandle, extraFrames)
    dragHandle = dragHandle or frame
    extraFrames = extraFrames or {}
    local dragging, dragInput, dragStart, startPos = false
    local extraStartPositions = {}
    local lerpFactor = 0.15
    local targetPos = frame.Position
    local extraTargetPositions = {}
    
    for _, extra in ipairs(extraFrames) do
        extraTargetPositions[extra] = extra.Position
    end
    
    local function update(input)
        local delta = input.Position - dragStart
        targetPos = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
        for extraFrame, extraStartPos in pairs(extraStartPositions) do
            extraTargetPositions[extraFrame] = UDim2.new(
                extraStartPos.X.Scale, extraStartPos.X.Offset + delta.X,
                extraStartPos.Y.Scale, extraStartPos.Y.Offset + delta.Y
            )
        end
    end
    
    dragHandle.InputBegan:Connect(function(input)
        if IsClosing then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging, dragStart, startPos = true, input.Position, frame.Position
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
    
    TrackConnection(RunService.RenderStepped:Connect(function()
        if not IsClosing and dragging then
            frame.Position = frame.Position:Lerp(targetPos, lerpFactor)
            for extraFrame, extraTargetPos in pairs(extraTargetPositions) do
                extraFrame.Position = extraFrame.Position:Lerp(extraTargetPos, lerpFactor)
            end
        end
    end))
end

-- ═══════════════════════════════════════════════════════════════
-- CRIAR JANELA PRINCIPAL
-- ═══════════════════════════════════════════════════════════════

function GrossHub.CreateWindow(title, logoId, bgImageId, bgTransparency)
    local UIObjects = {
        Tabs = {},
        Elements = {}
    }
    
    local Theme = {
        Background = Color3.fromRGB(15, 15, 15),
        Sidebar = Color3.fromRGB(20, 20, 25),
        SidebarTransparency = 0.4,
        Accent = Color3.fromRGB(0, 150, 255),
        TabBackground = Color3.fromRGB(10, 30, 60),
        TabTransparency = 0.5,
        Text = Color3.fromRGB(255, 255, 255),
        TextDark = Color3.fromRGB(180, 180, 180),
        Section = Color3.fromRGB(25, 25, 30),
        Element = Color3.fromRGB(30, 30, 35),
        Stroke = Color3.fromRGB(45, 45, 50),
        SliderHandle = Color3.fromRGB(255, 255, 255)
    }
    
    -- Screen GUI Principal
    local ScreenGui = Create("ScreenGui", {
        Parent = LocalPlayer:WaitForChild("PlayerGui"),
        ResetOnSpawn = false,
        Enabled = true,
        ZIndex = 5000
    })
    
    -- Background (com suporte a imagem)
    local Background = Create("Frame", {
        Parent = ScreenGui,
        BackgroundColor3 = Theme.Background,
        BackgroundTransparency = 0,
        Size = UDim2.fromScale(1, 1),
        ZIndex = 5000
    })
    
    if bgImageId then
        local bgImage = Create("ImageLabel", {
            Parent = Background,
            BackgroundTransparency = 1,
            Image = bgImageId,
            Size = UDim2.fromScale(1, 1),
            ZIndex = 5000
        })
        bgImage.ImageTransparency = bgTransparency or 0.65
    end
    
    -- Container Principal
    local Container = Create("Frame", {
        Parent = Background,
        BackgroundColor3 = Theme.Background,
        BackgroundTransparency = 0.15,
        Position = UDim2.fromOffset(50, 50),
        Size = UDim2.fromOffset(600, 400),
        ZIndex = 5001
    })
    
    Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = Container})
    Create("UIStroke", {Color = Theme.Stroke, Thickness = 1, Parent = Container})
    
    -- TopBar (Draggable)
    local TopBar = Create("Frame", {
        Parent = Container,
        BackgroundColor3 = Theme.Sidebar,
        BackgroundTransparency = 0.3,
        Size = UDim2.new(1, 0, 0, 40),
        ZIndex = 5002
    })
    
    Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = TopBar})
    
    -- Logo
    if logoId then
        Create("ImageLabel", {
            Parent = TopBar,
            BackgroundTransparency = 1,
            Image = logoId,
            Size = UDim2.fromOffset(30, 30),
            Position = UDim2.fromOffset(10, 5),
            ZIndex = 5002
        })
    end
    
    -- Título
    Create("TextLabel", {
        Parent = TopBar,
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Theme.Text,
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        Position = logoId and UDim2.fromOffset(45, 8) or UDim2.fromOffset(10, 8),
        Size = UDim2.new(1, -60, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 5002
    })
    
    -- Botão Fechar
    local CloseButton = Create("TextButton", {
        Parent = TopBar,
        BackgroundColor3 = Theme.Element,
        Text = "✕",
        TextColor3 = Theme.Text,
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        Position = UDim2.new(1, -35, 0.5, -10),
        Size = UDim2.fromOffset(25, 20),
        AutoButtonColor = false,
        ZIndex = 5002
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = CloseButton})
    
    AddClickEffect(CloseButton, Theme.Accent, Theme.Element)
    
    MakeDraggable(Container, TopBar)
    
    -- ═══════════════════════════════════════════════════════════════
    -- SISTEMA DE ABAS (TABS)
    -- ═══════════════════════════════════════════════════════════════
    
    local TabsContainer = Create("Frame", {
        Parent = Container,
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(0, 40),
        Size = UDim2.new(0.25, 0, 1, -40),
        ZIndex = 5001
    })
    
    Create("UIListLayout", {
        Parent = TabsContainer,
        Padding = UDim.new(0, 5),
        SortOrder = Enum.SortOrder.LayoutOrder,
        FillDirection = Enum.FillDirection.Vertical
    })
    
    local ContentContainer = Create("Frame", {
        Parent = Container,
        BackgroundTransparency = 1,
        Position = UDim2.fromScale(0.25, 40/400),
        Size = UDim2.new(0.75, 0, 1, -40),
        ClipsDescendants = true,
        ZIndex = 5001
    })
    
    local Window = {
        ScreenGui = ScreenGui,
        Container = Container,
        Theme = Theme,
        UIObjects = UIObjects,
        CurrentTab = nil
    }
    
    function Window:UpdateTheme(themeName)
        if GrossHub.Themes[themeName] then
            local newTheme = GrossHub.Themes[themeName]
            for key, value in pairs(newTheme) do
                Theme[key] = value
            end
            self:RefreshUI()
        end
    end
    
    function Window:RefreshUI()
        -- Aqui você pode adicionar lógica de refresh da UI
    end
    
    function Window:CreateTab(tabName, iconId)
        local TabButton = Create("TextButton", {
            Parent = TabsContainer,
            BackgroundColor3 = Theme.Element,
            Text = tabName,
            TextColor3 = Theme.Text,
            TextSize = 12,
            Font = Enum.Font.Gotham,
            Size = UDim2.new(1, -10, 0, 32),
            AutoButtonColor = false,
            ZIndex = 5002
        })
        
        Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = TabButton})
        Create("UIStroke", {Color = Theme.Stroke, Parent = TabButton})
        
        local TabContent = Create("ScrollingFrame", {
            Parent = ContentContainer,
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Theme.Accent,
            BorderSizePixel = 0,
            Visible = false,
            ZIndex = 5001
        })
        
        Create("UIListLayout", {
            Parent = TabContent,
            Padding = UDim.new(0, 10),
            SortOrder = Enum.SortOrder.LayoutOrder,
            FillDirection = Enum.FillDirection.Vertical
        })
        
        Create("UIPadding", {
            Parent = TabContent,
            PaddingLeft = UDim.new(0, 10),
            PaddingRight = UDim.new(0, 10),
            PaddingTop = UDim.new(0, 10),
            PaddingBottom = UDim.new(0, 10)
        })
        
        TabButton.MouseButton1Click:Connect(function()
            if Window.CurrentTab then
                Window.CurrentTab.Visible = false
            end
            TabContent.Visible = true
            Window.CurrentTab = TabContent
            Tween(TabButton, 0.2, {
                BackgroundColor3 = Theme.Accent,
                BackgroundTransparency = 0.2
            })
        end)
        
        table.insert(UIObjects.Tabs, TabContent)
        
        local Tab = {
            TabButton = TabButton,
            TabContent = TabContent,
            Theme = Theme,
            UIObjects = UIObjects
        }
        
        -- ═══════════════════════════════════════════════════════════════
        -- CRIAR SEÇÃO DENTRO DA ABA
        -- ═══════════════════════════════════════════════════════════════
        
        function Tab:CreateSection(sectionName)
            local SectionFrame = Create("Frame", {
                Parent = TabContent,
                BackgroundColor3 = Theme.Section,
                BackgroundTransparency = 0.3,
                Size = UDim2.new(1, 0, 0, 0),
                ZIndex = 5001
            })
            
            Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = SectionFrame})
            Create("UIStroke", {Color = Theme.Stroke, Parent = SectionFrame})
            
            local SectionTitle = Create("TextLabel", {
                Parent = SectionFrame,
                BackgroundTransparency = 1,
                Text = sectionName,
                TextColor3 = Theme.Text,
                TextSize = 13,
                Font = Enum.Font.GothamBold,
                Size = UDim2.new(1, 0, 0, 25),
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 5001
            })
            
            Create("UIPadding", {
                Parent = SectionTitle,
                PaddingLeft = UDim.new(0, 12)
            })
            
            local ElementContainer = Create("Frame", {
                Parent = SectionFrame,
                BackgroundTransparency = 1,
                Position = UDim2.fromOffset(0, 25),
                Size = UDim2.new(1, 0, 1, -25),
                ZIndex = 5001
            })
            
            Create("UIListLayout", {
                Parent = ElementContainer,
                Padding = UDim.new(0, 8),
                SortOrder = Enum.SortOrder.LayoutOrder,
                FillDirection = Enum.FillDirection.Vertical
            })
            
            Create("UIPadding", {
                Parent = ElementContainer,
                PaddingLeft = UDim.new(0, 10),
                PaddingRight = UDim.new(0, 10),
                PaddingTop = UDim.new(0, 8),
                PaddingBottom = UDim.new(0, 8)
            })
            
            local Section = {
                Frame = SectionFrame,
                ElementContainer = ElementContainer,
                Theme = Theme
            }
            
            -- ═══════════════════════════════════════════════════════════════
            -- ELEMENTOS DA SEÇÃO
            -- ═══════════════════════════════════════════════════════════════
            
            function Section:CreateButton(text, callback)
                local ButtonFrame = Create("Frame", {
                    Parent = ElementContainer,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 32),
                    ZIndex = 5001
                })
                
                local Button = Create("TextButton", {
                    Parent = ButtonFrame,
                    BackgroundColor3 = Theme.Element,
                    Size = UDim2.fromScale(1, 1),
                    AutoButtonColor = false,
                    Font = Enum.Font.GothamSemibold,
                    Text = text,
                    TextColor3 = Theme.Text,
                    TextSize = 13,
                    ZIndex = 5001
                })
                
                Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = Button})
                Create("UIStroke", {Color = Theme.Stroke, Parent = Button})
                
                AddClickEffect(Button, Theme.Accent, Theme.Element)
                Button.MouseButton1Click:Connect(callback)
            end
            
            function Section:CreateSlider(text, min, max, default, callback)
                local SliderFrame = Create("Frame", {
                    Parent = ElementContainer,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 45),
                    ZIndex = 5001
                })
                
                Create("TextLabel", {
                    Parent = SliderFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -50, 0, 20),
                    Font = Enum.Font.Gotham,
                    Text = text,
                    TextColor3 = Theme.TextDark,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 5001
                })
                
                local ValueLabel = Create("TextLabel", {
                    Parent = SliderFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -50, 0, 0),
                    Size = UDim2.new(0, 50, 0, 20),
                    Font = Enum.Font.GothamBold,
                    Text = tostring(default),
                    TextColor3 = Theme.Accent,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    ZIndex = 5001
                })
                
                local SliderBG = Create("Frame", {
                    Parent = SliderFrame,
                    BackgroundColor3 = Theme.Element,
                    Position = UDim2.fromOffset(0, 25),
                    Size = UDim2.new(1, 0, 0, 6),
                    ZIndex = 5001
                })
                
                Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = SliderBG})
                
                local SliderFill = Create("Frame", {
                    Parent = SliderBG,
                    BackgroundColor3 = Theme.Accent,
                    Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
                    ZIndex = 5002
                })
                
                Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = SliderFill})
                
                local SliderHandle = Create("Frame", {
                    Parent = SliderFill,
                    BackgroundColor3 = Theme.SliderHandle,
                    Position = UDim2.new(1, -6, 0.5, -6),
                    Size = UDim2.fromOffset(12, 12),
                    ZIndex = 5003
                })
                
                Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = SliderHandle})
                
                local dragging, targetFillSize = false, SliderFill.Size
                
                local function move(input)
                    local pos = math.clamp((input.Position.X - SliderBG.AbsolutePosition.X) / SliderBG.AbsoluteSize.X, 0, 1)
                    local val = math.floor(min + (max - min) * pos)
                    ValueLabel.Text = tostring(val)
                    targetFillSize = UDim2.new(pos, 0, 1, 0)
                    callback(val)
                end
                
                SliderBG.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = true
                        move(input)
                    end
                end)
                
                SliderHandle.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = true
                    end
                end)
                
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
                local ToggleFrame = Create("Frame", {
                    Parent = ElementContainer,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 32),
                    ZIndex = 5001
                })
                
                Create("TextLabel", {
                    Parent = ToggleFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -50, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = text,
                    TextColor3 = Theme.TextDark,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 5001
                })
                
                local ToggleBG = Create("Frame", {
                    Parent = ToggleFrame,
                    BackgroundColor3 = Theme.Element,
                    Position = UDim2.new(1, -45, 0.5, -11),
                    Size = UDim2.fromOffset(40, 22),
                    ZIndex = 5001
                })
                
                Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = ToggleBG})
                
                local Circle = Create("Frame", {
                    Parent = ToggleBG,
                    BackgroundColor3 = Theme.TextDark,
                    Position = UDim2.fromOffset(3, 3),
                    Size = UDim2.fromOffset(16, 16),
                    ZIndex = 5002
                })
                
                Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Circle})
                
                local state = default or false
                
                local function update()
                    Tween(Circle, 0.4, {
                        Position = state and UDim2.fromOffset(21, 3) or UDim2.fromOffset(3, 3),
                        BackgroundColor3 = state and Theme.Accent or Theme.TextDark
                    })
                    callback(state)
                end
                
                ToggleFrame.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        state = not state
                        update()
                    end
                end)
                
                update()
            end
            
            function Section:CreateDropdown(text, options, default, callback)
                local DropdownFrame = Create("Frame", {
                    Parent = ElementContainer,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 28),
                    ZIndex = 5001
                })
                
                Create("TextLabel", {
                    Parent = DropdownFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -100, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = text,
                    TextColor3 = Theme.TextDark,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 5001
                })
                
                local DropdownButton = Create("TextButton", {
                    Name = "DropdownButton",
                    Parent = DropdownFrame,
                    BackgroundColor3 = Theme.Element,
                    Position = UDim2.new(1, -100, 0.5, -10),
                    Size = UDim2.fromOffset(100, 20),
                    AutoButtonColor = false,
                    Font = Enum.Font.Gotham,
                    Text = "▼ " .. (default or (options and options[1]) or "None"),
                    TextColor3 = Theme.Text,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Center,
                    ZIndex = 5002
                })
                
                Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = DropdownButton})
                Create("UIStroke", {Color = Theme.Stroke, Parent = DropdownButton})
                
                local DropdownList = Create("ScrollingFrame", {
                    Name = "DropdownList",
                    Parent = ScreenGui,
                    BackgroundColor3 = Theme.Element,
                    BorderSizePixel = 0,
                    Size = UDim2.new(0, 100, 0, 0),
                    ZIndex = 10000,
                    ClipsDescendants = true,
                    Visible = false,
                    ScrollBarThickness = 2,
                    ScrollBarImageColor3 = Theme.Accent,
                    CanvasSize = UDim2.fromScale(0, 0)
                })
                
                Create("UIListLayout", {
                    Parent = DropdownList,
                    Padding = UDim.new(0, 1),
                    SortOrder = Enum.SortOrder.LayoutOrder
                })
                
                Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = DropdownList})
                Create("UIStroke", {Color = Theme.Stroke, Parent = DropdownList})
                
                -- Adicionar opções
                if options then
                    for _, opt in ipairs(options) do
                        local OptionButton = Create("TextButton", {
                            Parent = DropdownList,
                            BackgroundColor3 = Theme.Element,
                            Size = UDim2.new(1, 0, 0, 22),
                            AutoButtonColor = false,
                            Font = Enum.Font.Gotham,
                            Text = opt,
                            TextColor3 = Theme.Text,
                            TextSize = 11,
                            TextXAlignment = Enum.TextXAlignment.Center,
                            ZIndex = 10001
                        })
                        
                        OptionButton.InputBegan:Connect(function(input)
                            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                                Tween(OptionButton, 0.1, {
                                    BackgroundColor3 = Theme.Accent,
                                    BackgroundTransparency = 0.3
                                })
                            end
                        end)
                        
                        OptionButton.InputEnded:Connect(function(input)
                            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                                Tween(OptionButton, 0.2, {
                                    BackgroundColor3 = Theme.Element,
                                    BackgroundTransparency = 0
                                })
                            end
                        end)
                        
                        OptionButton.MouseButton1Click:Connect(function()
                            DropdownButton.Text = "▼ " .. opt
                            DropdownList.Visible = false
                            callback(opt)
                        end)
                    end
                end
                
                DropdownButton.MouseButton1Click:Connect(function()
                    DropdownList.Visible = not DropdownList.Visible
                    if DropdownList.Visible then
                        DropdownList.Position = UDim2.new(
                            0, DropdownButton.AbsolutePosition.X,
                            0, DropdownButton.AbsolutePosition.Y + 25
                        )
                        DropdownList.Size = UDim2.new(0, 100, 0, math.min(#options * 24, 150))
                        DropdownList.CanvasSize = UDim2.new(0, 0, 0, #options * 24)
                        
                        -- Animação de abertura
                        Tween(DropdownList, 0.2, {
                            BackgroundTransparency = 0
                        })
                    else
                        Tween(DropdownList, 0.2, {
                            BackgroundTransparency = 0
                        })
                    end
                end)
            end
            
            function Section:CreateTextBox(text, default, callback)
                local TextBoxFrame = Create("Frame", {
                    Parent = ElementContainer,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 28),
                    ZIndex = 5001
                })
                
                Create("TextLabel", {
                    Parent = TextBoxFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -100, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = text,
                    TextColor3 = Theme.TextDark,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 5001
                })
                
                local TextBox = Create("TextBox", {
                    Name = "TextBox",
                    Parent = TextBoxFrame,
                    BackgroundColor3 = Theme.Element,
                    Position = UDim2.new(1, -100, 0.5, -10),
                    Size = UDim2.fromOffset(100, 20),
                    ClearTextOnFocus = false,
                    Font = Enum.Font.Gotham,
                    Text = default or "",
                    PlaceholderText = "...",
                    TextColor3 = Theme.Text,
                    TextSize = 11,
                    ZIndex = 5001
                })
                
                Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = TextBox})
                TextBox.FocusLost:Connect(function() callback(TextBox.Text) end)
            end
            
            function Section:CreateKeybind(text, defaultKey, callback)
                local KeybindFrame = Create("Frame", {
                    Parent = ElementContainer,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 28),
                    ZIndex = 5001
                })
                
                Create("TextLabel", {
                    Parent = KeybindFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -100, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = text,
                    TextColor3 = Theme.TextDark,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 5001
                })
                
                local KeybindButton = Create("TextButton", {
                    Parent = KeybindFrame,
                    BackgroundColor3 = Theme.Element,
                    Position = UDim2.new(1, -100, 0.5, -10),
                    Size = UDim2.fromOffset(100, 20),
                    AutoButtonColor = false,
                    Font = Enum.Font.Gotham,
                    Text = defaultKey or "NONE",
                    TextColor3 = Theme.Text,
                    TextSize = 11,
                    ZIndex = 5001
                })
                
                Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = KeybindButton})
                
                local isBinding = false
                
                KeybindButton.MouseButton1Click:Connect(function()
                    isBinding = true
                    KeybindButton.Text = "..."
                end)
                
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
    
    CloseButton.MouseButton1Click:Connect(function()
        IsClosing = true
        DisconnectRuntime()
        Tween(Container, 0.3, {
            BackgroundTransparency = 1
        })
        game:GetService("Debris"):AddItem(ScreenGui, 0.5)
    end)
    
    function Window.Destroy()
        CloseButton:Click()
    end
    
    function Window.GetSelectedPlayer()
        -- Placeholder para compatibilidade
        return nil
    end
    
    return Window
end

return GrossHub
