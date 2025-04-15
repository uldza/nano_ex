defmodule Nano.Repo.Migrations.CreateChatMessages do
  use Ecto.Migration

  def change do
    create table(:chat_messages) do
      add :content, :string, null: false
      add :type, :string, default: "text"
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :chat_room_id, references(:chat_rooms, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end
  end
end
