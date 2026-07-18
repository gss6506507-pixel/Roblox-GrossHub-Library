-- [[ EXEMPLO DE USO V2 - GROSS HUB ]]
-- Este exemplo mostra como usar o jogador selecionado para realizar ações.

local GrossHub = loadstring(game:HttpGet("https://raw.githubusercontent.com/gss6506507-pixel/Roblox-GrossHub-Library/refs/heads/main/GrossHub_Library.lua"))()

local Window = GrossHub.CreateWindow("Gross Hub V2")

-- Aba de Jogadores
local PlayerTab = Window:CreateTab("Jogadores", "rbxassetid://6026568198")
local PlayerActions = PlayerTab:CreateSection("Ações no Selecionado")

-- Exemplo: Matar Jogador Selecionado
PlayerActions:CreateButton("Kill Selected Player", function()
    local target = Window.GetSelectedPlayer() -- Obtém quem você clicou na lista lateral
    
    if target then
        print("Tentando matar: " .. target.Name)
        -- Exemplo de lógica de Kill (depende do jogo permitir)
        if target.Character and target.Character:FindFirstChild("Humanoid") then
            target.Character.Humanoid.Health = 0
        end
    else
        print("Nenhum jogador selecionado na lista!")
    end
end)

-- Exemplo: Teleportar para o Jogador Selecionado
PlayerActions:CreateButton("Teleport to Selected", function()
    local target = Window.GetSelectedPlayer()
    local LocalPlayer = game.Players.LocalPlayer
    
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame
            print("Teleportado para: " .. target.Name)
        end
    else
        print("Alvo inválido ou não selecionado!")
    end
end)

-- Aba de Configurações
local SettingsTab = Window:CreateTab("Configurações", "rbxassetid://1402032199")
local MenuSection = SettingsTab:CreateSection("Menu")

MenuSection:CreateButton("Destruir Hub", function()
    Window.Destroy()
end)

-- Listar temas
local themes = {"Default", "Dark", "Lemon", "Rose", "Ocean", "Purple"}
MenuSection:CreateDropdown("Mudar Tema", themes, "Default", function(t)
    Window.UpdateTheme(t)
end)
