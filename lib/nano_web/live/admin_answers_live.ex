defmodule NanoWeb.AdminAnswersLive do
  use NanoWeb, :live_view

  def mount(_params, %{"room_id" => room_id}, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(Nano.PubSub, "room:#{room_id}:admin_answers")
    end

    {:ok, assign(socket, room_id: room_id, answers: [])}
  end

  def handle_info({:answer_submitted, answer_data}, socket) do
    # Add the new answer to the list of answers
    updated_answers = [answer_data | socket.assigns.answers]
    {:noreply, assign(socket, answers: updated_answers)}
  end

  def render(assigns) do
    ~H"""
    <div class="bg-white rounded-lg shadow-lg p-4 max-h-96 overflow-y-auto">
      <h3 class="text-lg font-semibold text-gray-900 mb-4">Correct answers:</h3>
      <div class="space-y-2">
        <%= for answer <- @answers do %>
          <%= if answer.correct do %>
            <div class="bg-gray-50 rounded p-3 border border-gray-200">
              <div class="flex justify-between items-start">
                <div>
                  <p class="text-sm font-medium text-gray-900">{answer.user_name}</p>
                  <p class="text-sm text-gray-600">
                    Selected answer {answer.answer}: {answer.answer_text}
                  </p>
                </div>
                <span class="text-xs text-gray-500">
                  {Calendar.strftime(DateTime.utc_now(), "%H:%M:%S")}
                </span>
              </div>
            </div>
          <% end %>
        <% end %>
      </div>
    </div>
    """
  end
end
