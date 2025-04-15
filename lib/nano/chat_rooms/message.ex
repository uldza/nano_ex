defmodule Nano.ChatRooms.Message do
  use Ecto.Schema
  import Ecto.Changeset

  @max_length 500
  @min_length 1

  schema "chat_messages" do
    field :message, :string
    field :user_id, :integer
    field :chat_room_id, :integer

    timestamps(type: :utc_datetime)
  end

  def changeset(chat_message, attrs) do
    chat_message
    |> cast(attrs, [:message, :user_id, :room_id])
    |> validate_required([:message, :user_id, :room_id])
    |> validate_length(:message, min: @min_length, max: @max_length)
  end
end
