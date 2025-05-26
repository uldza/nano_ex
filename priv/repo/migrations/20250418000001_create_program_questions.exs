defmodule Nano.Repo.Migrations.CreateProgramQuestions do
  use Ecto.Migration

  def change do
    create table(:program_questions) do
      add :question, :string, null: false
      add :answer1, :string, null: false
      add :answer2, :string, null: false
      add :answer3, :string, null: false
      add :answer4, :string, null: false
      add :correct_answer, :integer, null: false
      add :order, :integer, null: false
      add :is_active, :boolean, default: false
      add :started_at, :utc_datetime
      add :ended_at, :utc_datetime
      add :room_id, references(:chat_rooms, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:program_questions, [:room_id])
    create index(:program_questions, [:order])
    create index(:program_questions, [:is_active])
  end
end
