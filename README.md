# Documentação da Biblioteca GrossHub

Esta documentação descreve como usar a biblioteca `GrossHub` para criar interfaces de usuário dinâmicas e modulares no Roblox.

## Como Usar

1.  Salve o arquivo `GrossHub_Library.lua` como um **ModuleScript** no Roblox Studio.
2.  Renomeie o ModuleScript para `GrossHubLib` (ou qualquer outro nome de sua preferência).
3.  No seu script principal (LocalScript), você pode carregar a biblioteca usando `require()`:

    ```lua
    local GrossHub = require(game.ReplicatedStorage.GrossHubLib) -- Ajuste o caminho conforme onde você salvou o ModuleScript
    ```

## Funções Principais

### `GrossHub.CreateWindow(title: string)`

Cria e exibe a janela principal do hub. Retorna um objeto `Window` que permite adicionar abas e controlar o hub.

-   `title`: (Opcional) O título que será exibido no hub e na barra minimizada. Padrão: "GROSS HUB".

**Exemplo:**

```lua
local Window = GrossHub.CreateWindow("Meu Hub Personalizado")
```

### Objeto `Window`

O objeto `Window` retornado por `GrossHub.CreateWindow()` possui os seguintes métodos e propriedades:

#### `Window:CreateTab(name: string, icon: string)`

Cria uma nova aba no hub. Retorna um objeto `Tab`.

-   `name`: O nome da aba (exibido no botão da aba).
-   `icon`: (Opcional) O Asset ID de uma imagem para o ícone da aba (ex: `"rbxassetid://6026568198"`).

**Exemplo:**

```lua
local CombatTab = Window:CreateTab("Combate", "rbxassetid://6026568198")
```

#### `Window.Destroy()`

Destrói o hub com uma animação de "evaporação" e limpa todas as conexões de runtime. É a maneira recomendada de fechar o hub.

**Exemplo:**

```lua
Window.Destroy()
```

#### `Window.UpdateTheme(themeName: string)`

Atualiza o tema visual do hub com base nos temas predefinidos na biblioteca.

-   `themeName`: O nome do tema a ser aplicado (ex: "Default", "Dark", "Lemon", "Rose", "Ocean", "Purple").

**Exemplo:**

```lua
Window.UpdateTheme("Dark")
```

#### `Window.GetSelectedPlayer(): Player`

Retorna o objeto `Player` que está atualmente selecionado na lista de jogadores. Retorna `nil` se nenhum jogador estiver selecionado.

**Exemplo:**

```lua
local selectedPlayer = Window.GetSelectedPlayer()
if selectedPlayer then
    print("Jogador selecionado: " .. selectedPlayer.Name)
end
```

### Objeto `Tab`

O objeto `Tab` retornado por `Window:CreateTab()` possui o seguinte método:

#### `Tab:CreateSection(title: string)`

Cria uma nova seção dentro da aba. Retorna um objeto `Section`.

-   `title`: O título da seção.

**Exemplo:**

```lua
local AimSection = CombatTab:CreateSection("Mira")
```

### Objeto `Section`

O objeto `Section` retornado por `Tab:CreateSection()` possui os seguintes métodos para adicionar elementos de UI:

#### `Section:CreateButton(text: string, callback: function)`

Cria um botão clicável.

-   `text`: O texto exibido no botão.
-   `callback`: Uma função que é executada quando o botão é clicado.

**Exemplo:**

```lua
AimSection:CreateButton("Ativar Aimbot", function()
    print("Aimbot Ativado!")
end)
```

#### `Section:CreateSlider(text: string, min: number, max: number, default: number, callback: function)`

Cria um slider para selecionar um valor numérico.

-   `text`: O texto descritivo do slider.
-   `min`: O valor mínimo do slider.
-   `max`: O valor máximo do slider.
-   `default`: O valor inicial do slider.
-   `callback`: Uma função que recebe o valor atual do slider como argumento (`function(value)`).

**Exemplo:**

```lua
AimSection:CreateSlider("Chance de Acerto", 0, 100, 80, function(value)
    print("Chance de Acerto: " .. value .. "%")
end)
```

#### `Section:CreateToggle(text: string, default: boolean, callback: function)`

Cria um toggle (liga/desliga).

-   `text`: O texto descritivo do toggle.
-   `default`: O estado inicial do toggle (`true` para ligado, `false` para desligado).
-   `callback`: Uma função que recebe o estado atual do toggle como argumento (`function(enabled)`).

**Exemplo:**

```lua
SpeedSection:CreateToggle("Salto Infinito", false, function(enabled)
    print("Salto Infinito: " .. tostring(enabled))
end)
```

#### `Section:CreateDropdown(text: string, options: table, default: string, callback: function)`

Cria um menu dropdown para selecionar uma opção de uma lista.

-   `text`: O texto descritivo do dropdown.
-   `options`: Uma tabela de strings com as opções disponíveis (ex: `{"Opção 1", "Opção 2"}`).
-   `default`: A opção padrão selecionada.
-   `callback`: Uma função que recebe a opção selecionada como argumento (`function(selected)`).

**Exemplo:**

```lua
WeaponSection:CreateDropdown("Arma Selecionada", {"Rifle", "Pistola", "Faca"}, "Rifle", function(selected)
    print("Arma selecionada: " .. selected)
end)
```

#### `Section:CreateTextBox(text: string, default: string, callback: function)`

Cria uma caixa de texto para entrada de texto do usuário.

-   `text`: O texto descritivo da caixa de texto.
-   `default`: O texto padrão na caixa de texto.
-   `callback`: Uma função que é executada quando o foco da caixa de texto é perdido, recebendo o texto inserido como argumento (`function(text)`).

**Exemplo:**

```lua
GeneralSection:CreateTextBox("Nome do Jogador", "Player1", function(text)
    print("Nome do jogador: " .. text)
end)
```

#### `Section:CreateKeybind(text: string, defaultKey: string, callback: function)`

Cria um botão para definir uma tecla de atalho.

-   `text`: O texto descritivo do keybind.
-   `defaultKey`: A tecla padrão (ex: "E", "NONE").
-   `callback`: Uma função que recebe o nome da tecla selecionada como argumento (`function(key)`).

**Exemplo:**

```lua
WeaponSection:CreateKeybind("Recarregar", "R", function(key)
    print("Tecla de recarregar: " .. key)
end)
```

## Temas Disponíveis

A biblioteca `GrossHub` inclui os seguintes temas predefinidos, que podem ser acessados via `GrossHub.Themes`:

-   `Default`
-   `Dark`
-   `Lemon`
-   `Rose`
-   `Ocean`
-   `Purple`

Você pode usar `Window.UpdateTheme(themeName)` para alternar entre eles.

## Considerações Finais

-   A seleção de jogadores é puramente visual e o estado do jogador selecionado pode ser acessado via `Window.GetSelectedPlayer()`.
-   Todas as conexões de eventos e loops de `RunService` são gerenciadas internamente e desconectadas automaticamente quando `Window.Destroy()` é chamado, garantindo uma limpeza eficiente dos recursos.
