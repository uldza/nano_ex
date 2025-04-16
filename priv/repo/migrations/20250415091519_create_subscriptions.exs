defmodule Nano.Repo.Migrations.CreateSubscriptions do
  use Ecto.Migration

  def change do
    create table(:subscriptions) do
      add :stripe_subscription_id, :string, null: false
      add :stripe_customer_id, :string, null: false
      add :status, :string, null: false
      add :current_period_start, :utc_datetime, null: false
      add :current_period_end, :utc_datetime, null: false
      add :cancel_at_period_end, :boolean, default: false
      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:subscriptions, [:stripe_subscription_id])
    create unique_index(:subscriptions, [:stripe_customer_id])
    create index(:subscriptions, [:user_id])
  end
end
