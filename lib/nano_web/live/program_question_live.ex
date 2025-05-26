defmodule NanoWeb.ProgramQuestionLive do
  use NanoWeb, :live_view

  def mount(_params, %{"room_id" => room_id}, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(Nano.PubSub, "room:#{room_id}:questions")
    end

    {:ok, assign(socket, room_id: room_id, active_question: nil)}
  end

  def handle_info({:question_activated, question}, socket) do
    {:noreply, assign(socket, active_question: question)}
  end

  def handle_info({:question_deactivated, _question}, socket) do
    {:noreply, assign(socket, active_question: nil)}
  end

  def render(assigns) do
    ~H"""
    <div class="bg-white rounded-lg shadow-lg p-4 mb-4">
      <%= if @active_question do %>
        <div class="space-y-4">
          <h3 class="text-xl font-bold text-indigo-800">{@active_question.question}</h3>

          <div class="grid grid-cols-2 gap-4">
            <button
              phx-click="select_answer"
              phx-value-answer="1"
              class="p-3 bg-indigo-50 hover:bg-indigo-100 rounded-lg text-indigo-800 font-medium transition"
            >
              {@active_question.answer_1}
            </button>

            <button
              phx-click="select_answer"
              phx-value-answer="2"
              class="p-3 bg-indigo-50 hover:bg-indigo-100 rounded-lg text-indigo-800 font-medium transition"
            >
              {@active_question.answer_2}
            </button>

            <button
              phx-click="select_answer"
              phx-value-answer="3"
              class="p-3 bg-indigo-50 hover:bg-indigo-100 rounded-lg text-indigo-800 font-medium transition"
            >
              {@active_question.answer_3}
            </button>

            <button
              phx-click="select_answer"
              phx-value-answer="4"
              class="p-3 bg-indigo-50 hover:bg-indigo-100 rounded-lg text-indigo-800 font-medium transition"
            >
              {@active_question.answer_4}
            </button>
          </div>
        </div>
      <% else %>
        <p class="text-gray-500 text-center">No active question at the moment.</p>
      <% end %>
    </div>
    """
  end

  def handle_event("select_answer", %{"answer" => answer}, socket) do
    if socket.assigns.active_question do
      # Here you would typically send the answer to the server
      # and handle the response (e.g., show if it's correct)
      send(self(), {:answer_selected, socket.assigns.active_question.id, answer})
    end

    {:noreply, socket}
  end
end
