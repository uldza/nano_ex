defmodule Nano.Repo.Migrations.RemoveStripeCustomerIdFromSubscriptions do
  use Ecto.Migration

  def change do
    drop index(:subscriptions, [:stripe_customer_id])
    alter table(:subscriptions) do
      remove :stripe_customer_id
    end
  end
end
