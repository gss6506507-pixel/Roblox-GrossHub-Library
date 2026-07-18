-- [[ EXEMPLO DE USO V4 - GROSS HUB ]]
-- Este exemplo inclui TextBox e Keybind para demonstrar todas as funções da biblioteca.

local GrossHub = loadstring(game:HttpGet("https://raw.githubusercontent.com/gss6506507-pixel/Roblox-GrossHub-Library/refs/heads/main/GrossHub_Library.lua"))()

local Window = GrossHub.CreateWindow("Gross Hub V4")

-- [[ ABA: LOCAL PLAYER ]]
local LocalTab = Window:CreateTab("Local Player", "rbxassetid://6026568198")

-- Seção de Movimento (Slider e Toggle)
local MovementSection = LocalTab:CreateSection("Movimentação")

MovementSection:CreateSlider("WalkSpeed", 16, 200, 16, function(value)
    local char = game.Players.LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = value
    end
end)

MovementSection:CreateToggle("Infinite Jump", false, function(state)
    _G.InfiniteJump = state
end)

-- Seção de Utilidades (TextBox e Keybind)
local UtilsSection = LocalTab:CreateSection("Utilidades")

-- TextBox: Exemplo de mudar o nome (apenas print)
UtilsSection:CreateTextBox("Custom Tag", "Digite algo...", function(text)
    print("Tag definida para: " .. text)
end)

-- Keybind: Exemplo de tecla para fechar o menu
UtilsSection:CreateKeybind("Self Destruct Key", "P", function(key)
    print("A tecla de auto-destruição agora é: " .. key)
    -- Você pode usar essa variável 'key' em um loop ou evento externo
end)

-- Lógica externa para o Infinite Jump
game:GetService("UserInputService").JumpRequest:Connect(function()
    if _G.InfiniteJump then
        local char = game.Players.LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid:ChangeState("Jumping")
        end
    end
end)

-- [[ ABA: JOGADORES ]]
local PlayerTab = Window:CreateTab("Jogadores", "rbxassetid://6026568198")
local PlayerActions = PlayerTab:CreateSection("Ações no Selecionado")

PlayerActions:CreateButton("Kill Selected Player", function()
    local target = Window.GetSelectedPlayer()
    if target and target.Character and target.Character:FindFirstChild("Humanoid") then
        target.Character.Humanoid.Health = 0
    else
        print("Selecione um jogador na lista!")
    end
end)

-- [[ ABA: CONFIGURAÇÕES ]]
local SettingsTab = Window:CreateTab("Configurações", "rbxassetid://1402032199")
local MenuSection = SettingsTab:CreateSection("Menu")

MenuSection:CreateButton("Destruir Hub", function()
    Window.Destroy()
end)

local themes = {"Default", "Dark", "Lemon", "Rose", "Ocean", "Purple"}
MenuSection:CreateDropdown("Mudar Tema", themes, "Default", function(t)
    Window.UpdateTheme(t)
end)
