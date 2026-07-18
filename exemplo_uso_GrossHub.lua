-- Este é um exemplo de como usar a biblioteca GrossHub.
-- Salve o arquivo GrossHub_Library.lua como um ModuleScript no Roblox Studio
-- e renomeie-o para 'GrossHubLib'.

local GrossHub = require(game.ReplicatedStorage.GrossHubLib) -- Ajuste o caminho conforme necessário

-- Crie uma nova janela do hub
local Window = GrossHub.CreateWindow("Meu Hub Incrível")

-- Crie algumas abas
local CombatTab = Window:CreateTab("Combate", "rbxassetid://6026568198")
local MovementTab = Window:CreateTab("Movimento", "rbxassetid://6026568198")
local SettingsTab = Window:CreateTab("Configurações", "rbxassetid://1402032199")

-- Adicione seções e elementos à aba de Combate
local AimSection = CombatTab:CreateSection("Mira")
AimSection:CreateToggle("Ativar Mira Automática", false, function(enabled)
    print("Mira Automática: " .. tostring(enabled))
end)
AimSection:CreateSlider("Chance de Acerto", 0, 100, 80, function(value)
    print("Chance de Acerto: " .. value .. "%")
end)
AimSection:CreateButton("Ativar Aimbot", function()
    print("Aimbot Ativado!")
end)

local WeaponSection = CombatTab:CreateSection("Armas")
WeaponSection:CreateDropdown("Arma Selecionada", {"Rifle", "Pistola", "Faca"}, "Rifle", function(selected)
    print("Arma selecionada: " .. selected)
end)
WeaponSection:CreateKeybind("Recarregar", "R", function(key)
    print("Tecla de recarregar: " .. key)
end)

-- Adicione seções e elementos à aba de Movimento
local SpeedSection = MovementTab:CreateSection("Velocidade")
SpeedSection:CreateSlider("Velocidade de Caminhada", 16, 100, 30, function(value)
    print("Velocidade de Caminhada: " .. value)
end)
SpeedSection:CreateToggle("Salto Infinito", false, function(enabled)
    print("Salto Infinito: " .. tostring(enabled))
end)

-- Adicione seções e elementos à aba de Configurações
local ThemeSection = SettingsTab:CreateSection("Temas")
local themeList = {}
for name, _ in pairs(GrossHub.Themes) do table.insert(themeList, name) end
ThemeSection:CreateDropdown("Selecionar Tema", themeList, "Default", function(selected)
    Window.UpdateTheme(selected)
    print("Tema selecionado: " .. selected)
end)

local GeneralSection = SettingsTab:CreateSection("Geral")
GeneralSection:CreateButton("Destruir Menu", function()
    Window.Destroy()
    print("Menu destruído!")
end)
GeneralSection:CreateTextBox("Nome do Jogador", "Player1", function(text)
    print("Nome do jogador: " .. text)
end)

-- Exemplo de como obter o jogador selecionado (pode ser usado em outras partes do seu script)
-- local selectedPlayer = Window.GetSelectedPlayer()
-- if selectedPlayer then
--     print("Jogador selecionado: " .. selectedPlayer.Name)
-- end

-- Você pode chamar Window.Destroy() para fechar o hub programaticamente
-- task.delay(10, function()
--     Window.Destroy()
-- end)
