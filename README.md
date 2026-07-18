Documentação da Biblioteca GrossHub 100% IA
Esta documentação descreve como usar a biblioteca `GrossHub` para criar interfaces de usuário dinâmicas e modulares no Roblox, seja via link direto ou ModuleScript.
Como Usar
Opção 1: Link Direto (Recomendado para Scripts/Executores)
Você pode carregar a biblioteca diretamente do GitHub sem precisar de arquivos locais. Use o código abaixo no seu executor:
```lua
local GrossHub = loadstring(game:HttpGet("https://raw.githubusercontent.com/gss6506507-pixel/Roblox-GrossHub-Library/refs/heads/main/GrossHub_Library.lua"))()

-- Inicie seu script aqui
local Window = GrossHub.CreateWindow("Meu Hub")
```
Opção 2: ModuleScript (Roblox Studio)
Salve o arquivo `GrossHub_Library.lua` como um ModuleScript no Roblox Studio.
Renomeie o ModuleScript para `GrossHubLib`.
No seu script principal (LocalScript), carregue a biblioteca:
    ```lua
    local GrossHub = require(game.ReplicatedStorage.GrossHubLib)
    ```
---
Funções Principais
`GrossHub.CreateWindow(title: string)`
Cria e exibe a janela principal do hub. Retorna um objeto `Window`.
`title`: (Opcional) Título do hub. Padrão: "GROSS HUB".
Exemplo:
```lua
local Window = GrossHub.CreateWindow("Meu Hub Personalizado")
```
---
Objeto `Window`
`Window:CreateTab(name: string, icon: string)`
Cria uma nova aba. Retorna um objeto `Tab`.
`icon`: Asset ID da imagem (ex: `"rbxassetid://6026568198"`).
`Window.Destroy()`
Fecha o hub com animação de evaporação e limpa todas as conexões.
`Window.UpdateTheme(themeName: string)`
Altera o tema visual.
Temas: `Default`, `Dark`, `Lemon`, `Rose`, `Ocean`, `Purple`.
`Window.GetSelectedPlayer(): Player`
Retorna o jogador selecionado na lista lateral.
---
Objeto `Tab`
`Tab:CreateSection(title: string)`
Cria uma seção para organizar elementos. Retorna um objeto `Section`.
---
Objeto `Section`
`Section:CreateButton(text: string, callback: function)`
Botão simples.
`Section:CreateSlider(text: string, min: number, max: number, default: number, callback: function)`
Slider numérico. Retorna o valor atual no callback.
`Section:CreateToggle(text: string, default: boolean, callback: function)`
Interruptor liga/desliga.
`Section:CreateDropdown(text: string, options: table, default: string, callback: function)`
Menu de seleção.
`Section:CreateTextBox(text: string, default: string, callback: function)`
Entrada de texto.
`Section:CreateKeybind(text: string, defaultKey: string, callback: function)`
Configuração de tecla de atalho.
---
Considerações Finais
Limpeza: Todas as conexões de eventos são desconectadas automaticamente ao destruir o hub.
Seleção: O jogador selecionado na lista visual é acessível programaticamente para suas funções.
