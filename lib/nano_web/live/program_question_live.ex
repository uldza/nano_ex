defmodule NanoWeb.ProgramQuestionLive do
  use NanoWeb, :live_view
  alias NanoWeb.UserAuth

  @answer_dimensions %{
    1 => %{width: 86, height: 74, viewBox: "0 0 86 74", pattern_scale: "0.00195312 0.0022779"},
    2 => %{width: 72, height: 79, viewBox: "0 0 72 79", pattern_scale: "0.0021692 0.00195695"},
    3 => %{width: 79, height: 79, viewBox: "0 0 79 79", pattern_scale: "0.00196078 0.00195695"},
    4 => %{width: 68, height: 68, viewBox: "0 0 68 68", pattern_scale: "0.0019685"}
  }

  def mount(_params, %{"room_id" => room_id} = session, socket) do
    # Mount the current user from the session
    socket = UserAuth.mount_current_user(socket, session)

    if connected?(socket) do
      Phoenix.PubSub.subscribe(Nano.PubSub, "room:#{room_id}:questions")
    end

    {:ok,
     assign(socket,
       room_id: room_id,
       active_question: nil,
       answer_dimensions: @answer_dimensions,
       feedback: nil
     )}
  end

  def handle_info({:question_activated, question}, socket) do
    # Transform question into a list of answers with their numbers
    answers =
      [
        {1, question.answer1},
        {2, question.answer2},
        {3, question.answer3},
        {4, question.answer4}
      ]
      |> Enum.filter(fn {_num, text} -> text != nil and text != "" end)

    {:noreply,
     assign(socket, active_question: Map.put(question, :answers, answers), feedback: nil)}
  end

  def handle_info({:question_deactivated, _question}, socket) do
    {:noreply, assign(socket, active_question: nil, feedback: nil)}
  end

  def handle_info(:clear_feedback, socket) do
    {:noreply, assign(socket, feedback: nil)}
  end

  def handle_event("select_answer", %{"answer" => answer_str}, socket) do
    if socket.assigns.active_question do
      [answer_num, answer_text] = String.split(answer_str, ":", parts: 2)
      answer_num = String.to_integer(answer_num)

      # Send the answer to admin
      Phoenix.PubSub.broadcast(
        Nano.PubSub,
        "room:#{socket.assigns.room_id}:admin_answers",
        {
          :answer_submitted,
          %{
            question_id: socket.assigns.active_question.id,
            answer: answer_num,
            answer_text: answer_text,
            user_id: socket.assigns.current_user.id,
            user_name: socket.assigns.current_user.email
          }
        }
      )

      if answer_num == socket.assigns.active_question.correct_answer do
        Process.send_after(self(), :clear_feedback, 6000)
        {:noreply, assign(socket, active_question: nil, feedback: "Tu atbildēji pareizi!")}
      else
        {:noreply, assign(socket, active_question: nil)}
      end
    else
      {:noreply, socket}
    end
  end

  def render(assigns) do
    ~H"""
    <%= if @active_question do %>
      <div
        class="brown-normal rounded-2xl py-4 px-6 border-4 border-[var(--orange-normal)]"
        style="box-shadow: inset -10px -10px 10px rgba(0, 0, 0, .8);"
      >
        <div class="space-y-4">
          <h3 class="text-xl font-bold">{@active_question.question}</h3>

          <div class="grid grid-cols-4 gap-4 px-10">
            <%= for {num, text} <- @active_question.answers do %>
              <% dims = @answer_dimensions[num] %>
              <button phx-click="select_answer" phx-value-answer={"#{num}:#{text}"}>
                <svg
                  width={dims.width}
                  height={dims.height}
                  viewBox={dims.viewBox}
                  fill="none"
                  xmlns="http://www.w3.org/2000/svg"
                  xmlns:xlink="http://www.w3.org/1999/xlink"
                >
                  <g clip-path={"url(#clip0_#{num})"}>
                    <rect width={dims.width} height={dims.height} fill={"url(#pattern0_#{num})"} />
                  </g>
                  <defs>
                    <pattern
                      id={"pattern0_#{num}"}
                      patternContentUnits="objectBoundingBox"
                      width="1"
                      height="1"
                    >
                      <use xlink:href={"#image0_#{num}"} transform={"scale(#{dims.pattern_scale})"} />
                    </pattern>
                    <clipPath id={"clip0_#{num}"}>
                      <rect width={dims.width} height={dims.height} fill="white" />
                    </clipPath>
                    <image
                      id={"image0_#{num}"}
                      preserveAspectRatio="none"
                      xlink:href={"/images/answer-#{num}.png"}
                    />
                  </defs>
                </svg>
              </button>
            <% end %>
          </div>
        </div>
      </div>
    <% end %>

    <%= if @feedback do %>
      <div
        class="brown-normal rounded-2xl py-4 px-6 border-4 border-[var(--orange-normal)] animate-fade-in-out"
        style="box-shadow: inset -10px -10px 10px rgba(0, 0, 0, .8);"
      >
        <div class="space-y-4">
          <h3 class="text-xl font-bold">{@feedback}</h3>
        </div>
      </div>
    <% end %>
    """
  end
end
