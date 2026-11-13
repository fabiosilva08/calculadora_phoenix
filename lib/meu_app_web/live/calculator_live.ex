defmodule MeuAppWeb.CalculatorLive do
  use MeuAppWeb, :live_view

  # 1. Estado inicial focado na expressão linear acumulada
  def mount(_params, _session, socket) do
    {:ok, assign(socket, display: "0", tokens: [], current_number: "0", fresh: true)}
  end

  # 2. Renderização com o Visor de Expressão Contínua
  def render(assigns) do
    ~H"""
    <!-- Fundo de toda a página Azul Escuro Profundo -->
    <div class="flex justify-center items-center min-h-screen bg-slate-950 font-sans antialiased p-4">
      
      <!-- Corpo da Calculadora -->
      <div class="w-full max-w-sm p-6 bg-slate-900 rounded-[48px] shadow-2xl border border-slate-800/50">
        
        <!-- Visor Linear Contínuo -->
        <div class="w-full text-right px-4 py-12 mb-4 min-h-[160px] flex flex-col justify-end bg-slate-950/40 rounded-3xl border border-slate-800/30">
          <div class="text-white text-4xl font-light tracking-wide break-all font-mono">
            <%= @display %>
          </div>
        </div>

        <!-- Grade de Botões (Esquema Cinza) -->
        <div class="grid grid-cols-4 gap-4">
          <!-- Linha 1: Funções de Controle -->
          <button phx-click="clear" class="btn-moto bg-neutral-700 text-neutral-100 hover:bg-neutral-600 font-medium">AC</button>
          <button phx-click="toggle_sign" class="btn-moto bg-neutral-700 text-neutral-100 hover:bg-neutral-600 font-medium">+/-</button>
          <button phx-click="press_op" phx-value-op="%" class="btn-moto bg-neutral-700 text-neutral-100 hover:bg-neutral-600 font-medium">%</button>
          <button phx-click="press_op" phx-value-op="/" class="btn-moto bg-neutral-700 text-neutral-100 hover:bg-neutral-600">÷</button>

          <!-- Linha 2: Números e Operadores -->
          <button phx-click="press_num" phx-value-num="7" class="btn-moto bg-neutral-800 text-neutral-200 hover:bg-neutral-700">7</button>
          <button phx-click="press_num" phx-value-num="8" class="btn-moto bg-neutral-800 text-neutral-200 hover:bg-neutral-700">8</button>
          <button phx-click="press_num" phx-value-num="9" class="btn-moto bg-neutral-800 text-neutral-200 hover:bg-neutral-700">9</button>
          <button phx-click="press_op" phx-value-op="*" class="btn-moto bg-neutral-700 text-neutral-100 hover:bg-neutral-600">×</button>

          <!-- Linha 3 -->
          <button phx-click="press_num" phx-value-num="4" class="btn-moto bg-neutral-800 text-neutral-200 hover:bg-neutral-700">4</button>
          <button phx-click="press_num" phx-value-num="5" class="btn-moto bg-neutral-800 text-neutral-200 hover:bg-neutral-700">5</button>
          <button phx-click="press_num" phx-value-num="6" class="btn-moto bg-neutral-800 text-neutral-200 hover:bg-neutral-700">6</button>
          <button phx-click="press_op" phx-value-op="-" class="btn-moto bg-neutral-700 text-neutral-100 hover:bg-neutral-600">-</button>

          <!-- Linha 4 -->
          <button phx-click="press_num" phx-value-num="1" class="btn-moto bg-neutral-800 text-neutral-200 hover:bg-neutral-700">1</button>
          <button phx-click="press_num" phx-value-num="2" class="btn-moto bg-neutral-800 text-neutral-200 hover:bg-neutral-700">2</button>
          <button phx-click="press_num" phx-value-num="3" class="btn-moto bg-neutral-800 text-neutral-200 hover:bg-neutral-700">3</button>
          <button phx-click="press_op" phx-value-op="+" class="btn-moto bg-neutral-700 text-neutral-100 hover:bg-neutral-600">+</button>

          <!-- Linha 5 -->
          <button phx-click="press_num" phx-value-num="0" class="btn-moto bg-neutral-800 text-neutral-200 hover:bg-neutral-700">0</button>
          <button phx-click="press_dot" class="btn-moto bg-neutral-800 text-neutral-200 hover:bg-neutral-700">.</button>
          <button phx-click="backspace" class="btn-moto bg-neutral-800 text-neutral-400 hover:bg-neutral-700">⌫</button>
          <button phx-click="calculate" class="btn-moto bg-neutral-200 text-neutral-950 hover:bg-neutral-300 font-bold">=</button>
        </div>
      </div>
    </div>

    <style>
      .btn-moto {
        aspect-ratio: 1 / 1;
        width: 100%;
        border-radius: 9999px;
        font-size: 1.6rem;
        display: flex;
        align-items: center;
        justify-content: center;
        transition: all 120ms cubic-bezier(0.4, 0, 0.2, 1);
      }
      .btn-moto:active {
        transform: scale(0.92);
        opacity: 0.85;
      }
    </style>
    """
  end

  # 3. Lógica de manipulação da cadeia de caracteres (String Stream)
  def handle_event("press_num", %{"num" => num}, socket) do
    if socket.assigns.fresh do
      {:noreply, assign(socket, display: num, current_number: num, fresh: false)}
    else
      last_char = String.last(socket.assigns.display)
      
      # Evita colar número grudado após um operador especial (ex: %)
      if last_char == "%" do
        {:noreply, socket}
      else
        new_display = if socket.assigns.display == "0", do: num, else: socket.assigns.display <> num
        new_current = if socket.assigns.current_number == "0", do: num, else: socket.assigns.current_number <> num
        {:noreply, assign(socket, display: new_display, current_number: new_current)}
      end
    end
  end

  def handle_event("press_dot", _params, socket) do
    if socket.assigns.fresh do
      {:noreply, assign(socket, display: "0.", current_number: "0.", fresh: false)}
    else
      if String.contains?(socket.assigns.current_number, ".") do
        {:noreply, socket}
      else
        {:noreply, assign(socket, 
          display: socket.assigns.display <> ".", 
          current_number: socket.assigns.current_number <> "."
        )}
      end
    end
  end

  def handle_event("press_op", %{"op" => op}, socket) do
    display = socket.assigns.display
    last_char = String.last(display)

    # Impede de colocar dois operadores seguidos (substitui o último se clicado de novo)
    if last_char in ["+", "-", "*", "/"] do
      new_display = String.slice(display, 0..-2) <> op
      {:noreply, assign(socket, display: new_display, current_number: "", fresh: false)}
    else
      {:noreply, assign(socket, display: display <> op, current_number: "", fresh: false)}
    end
  end

  def handle_event("clear", _params, socket) do
    {:ok, socket} = mount(nil, nil, socket)
    {:noreply, socket}
  end

  def handle_event("backspace", _params, socket) do
    display = socket.assigns.display
    if String.length(display) <= 1 or socket.assigns.fresh do
      {:noreply, assign(socket, display: "0", current_number: "0", fresh: true)}
    else
      new_display = String.slice(display, 0..-2)
      # Recalcula sutilmente o token numérico atual ao apagar
      parts = String.split(new_display, ~r{[\+\-\*\/]})
      new_current = List.last(parts) || "0"
      {:noreply, assign(socket, display: new_display, current_number: new_current)}
    end
  end

  def handle_event("toggle_sign", _params, socket) do
    # Inverte o sinal apenas do número atual digitado na expressão
    curr = socket.assigns.current_number
    if curr != "" and curr != "0" do
      inverted = if String.starts_with?(curr, "-"), do: String.replace(curr, "-", ""), else: "-" <> curr
      display = socket.assigns.display
      # Substitui a última ocorrência do número na string do visor
      new_display = String.replace_suffix(display, curr, inverted)
      {:noreply, assign(socket, display: new_display, current_number: inverted)}
    else
      {:noreply, socket}
    end
  end

  def handle_event("calculate", _params, socket) do
    expression = socket.assigns.display
    
    # Processa e avalia a expressão de forma segura transformando os símbolos visuais
    sanitized = expression 
                |> String.replace("÷", "/") 
                |> String.replace("×", "*")
                |> String.replace("%", "*0.01")

    case Code.eval_string(sanitized) do
      {result, _} ->
        formatted = if is_float(result), do: format_result(result), else: to_string(result)
        {:noreply, assign(socket, display: formatted, current_number: formatted, fresh: true)}
      _ ->
        {:noreply, assign(socket, display: "Erro", current_number: "0", fresh: true)}
    end
  rescue
    _ -> {:noreply, assign(socket, display: "Erro", current_number: "0", fresh: true)}
  end

  defp format_result(val) do
    if trunc(val) == val, do: Integer.to_string(trunc(val)), else: Float.to_string(val)
  end
end
