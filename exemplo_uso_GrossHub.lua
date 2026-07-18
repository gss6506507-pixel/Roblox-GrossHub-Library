-- [[ GROSS HUB LOADER ]]
-- Este script carrega a biblioteca diretamente do seu GitHub e a executa.

local function LoadLibrary()
    local success, result = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/gss6506507-pixel/Roblox-GrossHub-Library/refs/heads/main/GrossHub_Library.lua"))()
    end)
    
    if success then
        return result
    else
        warn("Erro ao carregar a biblioteca GrossHub: " .. tostring(result))
        return nil
    end
end

local GrossHub = LoadLibrary()

if GrossHub then
    -- [[ SEU SCRIPT COMEÇA AQUI ]]
    
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
    -- Para acessar os temas na biblioteca carregada via loadstring:
    -- Nota: Como carregamos via loadstring, precisamos garantir que o retorno tenha os temas expostos.
    -- Na nossa biblioteca, GrossHub é a tabela retornada.
    
    -- Se você quiser listar os temas, pode usar uma tabela local ou garantir que a lib os retorne.
    -- Vamos usar os nomes padrão para este exemplo:
    local availableThemes = {"Default", "Dark", "Lemon", "Rose", "Ocean", "Purple"}
    
    ThemeSection:CreateDropdown("Selecionar Tema", availableThemes, "Default", function(selected)
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
end
