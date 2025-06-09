defmodule Nano.ChatRooms.Message do
  use Ecto.Schema
  import Ecto.Changeset

  alias Nano.ChatRooms.Room
  alias Nano.Accounts.User

  @max_length 500
  @min_length 1

  schema "chat_messages" do
    field :content, :string
    field :type, :string, default: "text"

    belongs_to :user, User
    belongs_to :chat_room, Room

    timestamps(type: :utc_datetime)
  end

  def changeset(chat_message, attrs) do
    chat_message
    |> cast(attrs, [:content, :type, :user_id, :chat_room_id])
    |> validate_required([:content, :type, :user_id, :chat_room_id])
    |> validate_length(:content, min: @min_length, max: @max_length)
  end
end
