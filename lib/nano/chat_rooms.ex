defmodule Nano.ChatRooms do
  alias Nano.ChatRooms.Room
  alias Nano.ChatRooms.Message
  alias Nano.Repo

  import Ecto.Query

  def get_room!(id) do
    Repo.get_by!(Room, id: id)
  end

  def get_messages_for_room(room_id) do
    Repo.all(from m in Message,
              where: m.chat_room_id == ^room_id,
              order_by: [desc: m.inserted_at],
              limit: 100
              )
  end

  def create_room(attrs) do
    %Room{}
    |> Room.changeset(attrs)
    |> Repo.insert()
  end

  def list_rooms do
    q = from r in Room, order_by: [desc: r.inserted_at]
    Repo.all(q)
  end

  def create_message(attrs) do
    %Message{}
    |> Message.changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, message} ->
        Phoenix.PubSub.broadcast(Nano.PubSub, "room:#{message.chat_room_id}", {:message_created, message})
        {:ok, message}
      error -> error
    end
  end

  def subscribe_to_room(room_id) do
    Phoenix.PubSub.subscribe(Nano.PubSub, "room:#{room_id}")
  end
end
