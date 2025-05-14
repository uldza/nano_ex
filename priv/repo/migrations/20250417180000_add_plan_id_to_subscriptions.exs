defmodule Nano.Repo.Migrations.AddPlanIdToSubscriptions do
  use Ecto.Migration

  def change do
    alter table(:subscriptions) do
      add :plan_id, :string, null: false
    end

    create index(:subscriptions, [:plan_id])
  end
end
