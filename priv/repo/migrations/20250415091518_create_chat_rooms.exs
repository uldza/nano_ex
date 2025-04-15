defmodule Nano.Repo.Migrations.CreateChatRooms do
  use Ecto.Migration

  def change do
    create table(:chat_rooms) do
      add :name, :string, null: false
      add :description, :string
      add :video_url, :string, null: false
      add :video_thumbnail_url, :string, null: false
      add :free_minutes, :integer, default: 0
      add :requires_subscription, :boolean, default: false

      timestamps(type: :utc_datetime)
    end
  end
end
