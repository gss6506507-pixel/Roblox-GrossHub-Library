
-- [[ EXEMPLO DE USO V4 - GROSS HUB ]]
-- Este exemplo inclui a nova funcionalidade de definir a imagem do logo diretamente no CreateWindow.

-- Carregando a biblioteca (Certifique-se de usar o link correto da sua biblioteca atualizada)
local GrossHub = loadstring(game:HttpGet("https://raw.githubusercontent.com/gss6506507-pixel/Roblox-GrossHub-Library/refs/heads/main/GrossHub_Library.lua"))()

-- [[ CRIAÇÃO DA JANELA ]]
-- Agora você pode passar o ID da imagem como segundo parâmetro!
-- Formato: Window = GrossHub.CreateWindow("Título", "rbxassetid://ID_DA_IMAGEM")
local Window = GrossHub.CreateWindow("Gross Hub V4", "rbxassetid://120694317945692")

-- [[ ABA: LOCAL PLAYER ]]
local LocalTab = Window:CreateTab("Local Player", "rbxassetid://6026568198")

-- Seção de Movimento
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

-- Seção de Utilidades
local UtilsSection = LocalTab:CreateSection("Utilidades")

UtilsSection:CreateTextBox("Custom Tag", "Digite algo...", function(text)
    print("Tag definida para: " .. text)
end)

UtilsSection:CreateKeybind("Self Destruct Key", "P", function(key)
    print("A tecla de auto-destruição agora é: " .. key)
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
