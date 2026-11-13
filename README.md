# Calculadora Phoenix LiveView

Uma calculadora interativa desenvolvida em **Elixir** utilizando o **Phoenix Framework** e **Phoenix LiveView**, com processamento de expressões matemáticas em tempo real via WebSockets.

## Funcionalidades
* **Operações Básicas:** Adição, subtração, multiplicação e divisão.
* **Recursos Extras:** Porcentagem (`%`), inversão de sinal (`+/-`), ponto decimal e botão de apagar dígito (`⌫`).
* **Visor Contínuo:** Exibe a expressão matemática completa antes de calcular o resultado.
* **Tempo Real:** Toda a lógica roda no servidor Elixir sem necessidade de escrever JavaScript manual ou criar APIs REST.

## Como rodar o projeto localmente
1. Instale as dependências:
   ```bash
   mix deps.get
   ```
2. Inicie o servidor Phoenix:
   ```bash
   mix phx.server
   ```
3. Acesse no navegador: [`http://localhost:4000/calculadora`](http://localhost:4000/calculadora)

