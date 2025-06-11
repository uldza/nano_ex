defmodule Nano.ChatRooms.ProgramQuestion do
  use Ecto.Schema
  import Ecto.Changeset

  schema "program_questions" do
    field :question, :string
    field :answer1, :string
    field :answer2, :string
    field :answer3, :string
    field :answer4, :string
    field :correct_answer, :integer
    field :order, :integer
    field :is_active, :boolean, default: false
    field :started_at, :utc_datetime
    field :ended_at, :utc_datetime

    belongs_to :room, Nano.ChatRooms.Room

    timestamps(type: :utc_datetime)
  end

  def changeset(question, attrs) do
    question
    |> cast(attrs, [
      :question,
      :answer1,
      :answer2,
      :answer3,
      :answer4,
      :correct_answer,
      :order,
      :is_active,
      :room_id
    ])
    |> validate_required([
      :question,
      :answer1,
      :answer2,
      :correct_answer,
      :order,
      :room_id
    ])
    |> validate_inclusion(:correct_answer, 1..4)
    |> validate_inclusion(:order, 1..100)
    |> foreign_key_constraint(:room_id)
  end
end
