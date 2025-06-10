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

  def activate_question(%ProgramQuestion{id: id} = question) when is_integer(id) do
    IO.puts("Activating question #{id}")
    # Make question active
    case question
         |> ProgramQuestion.changeset(%{is_active: true})
         |> Repo.update() do
      {:ok, updated_question} ->
        {:ok, updated_question}
      error ->
        error
    end
  end

  def deactivate_question(%ProgramQuestion{id: id} = question) when is_integer(id) do
    # Make question active
    case question
         |> ProgramQuestion.changeset(%{is_active: false})
         |> Repo.update() do
      {:ok, updated_question} ->
        {:ok, updated_question}
      error ->
        error
    end
  end

  def get_active_question(room_id) do
    Repo.get_by(ProgramQuestion, room_id: room_id, is_active: true)
  end
end
