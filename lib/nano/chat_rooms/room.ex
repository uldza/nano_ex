defmodule Nano.ChatRooms.Room do
  use Ecto.Schema
  import Ecto.Changeset

  alias Nano.ChatRooms.Message

  schema "chat_rooms" do
    field :name, :string
    field :description, :string

    field :video_url, :string
    field :video_thumbnail_url, :string

    field :free_minutes, :integer, default: 0

    field :requires_subscription, :boolean, default: false

    has_many :chat_messages, Message, foreign_key: :chat_room_id

    timestamps(type: :utc_datetime)
  end

  def changeset(chat_room, attrs) do
    chat_room
    |> cast(attrs, [:name, :description, :video_url, :video_thumbnail_url, :free_minutes, :requires_subscription])
    |> validate_required([:name, :video_url, :video_thumbnail_url])
    |> validate_length(:name, max: 100)
    |> validate_length(:video_url, min: 10)
    |> validate_length(:video_thumbnail_url, min: 10)
  end
end
