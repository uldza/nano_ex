defmodule Nano.Rooms do
  import Ecto.Query, warn: false
  alias Nano.Repo
  alias Nano.ChatRooms.Room
  alias Nano.ChatRooms.ProgramQuestion

  # Room functions
  def list_rooms do
    Repo.all(Room)
  end

  def get_room!(id), do: Repo.get!(Room, id)

  def update_room(%Room{} = room, attrs) do
    room
    |> Room.changeset(attrs)
    |> Repo.update()
  end

  # Program Question functions
  def list_room_questions(room_id) do
    ProgramQuestion
    |> where([q], q.room_id == ^room_id)
    |> order_by([q], asc: q.order)
    |> Repo.all()
  end

  def get_question!(id), do: Repo.get!(ProgramQuestion, id)

  def create_question(attrs \\ %{}) do
    %ProgramQuestion{}
    |> ProgramQuestion.changeset(attrs)
    |> Repo.insert()
  end

  def update_question(%ProgramQuestion{} = question, attrs) do
    question
    |> ProgramQuestion.changeset(attrs)
    |> Repo.update()
  end

  def delete_question(%ProgramQuestion{} = question) do
    Repo.delete(question)
  end

  def activate_question(%ProgramQuestion{} = question) do
    # Deactivate any currently active questions for this room
    from(q in ProgramQuestion,
      where: q.room_id == ^question.room_id and q.is_active == true
    )
    |> Repo.update_all(set: [is_active: false, ended_at: DateTime.utc_now()])

    # Activate the new question
    case question
         |> ProgramQuestion.changeset(%{
           is_active: true,
           started_at: DateTime.utc_now()
         })
         |> Repo.update() do
      {:ok, updated_question} ->
        Phoenix.PubSub.broadcast(
          Nano.PubSub,
          "room:#{question.room_id}:questions",
          {:question_activated, updated_question}
        )

        {:ok, updated_question}

      error ->
        error
    end
  end

  def deactivate_question(%ProgramQuestion{} = question) do
    case question
         |> ProgramQuestion.changeset(%{
           is_active: false,
           ended_at: DateTime.utc_now()
         })
         |> Repo.update() do
      {:ok, updated_question} ->
        Phoenix.PubSub.broadcast(
          Nano.PubSub,
          "room:#{question.room_id}:questions",
          {:question_deactivated, updated_question}
        )

        {:ok, updated_question}

      error ->
        error
    end
  end

  def get_active_question(room_id) do
    Repo.get_by(ProgramQuestion, room_id: room_id, is_active: true)
  end
end
