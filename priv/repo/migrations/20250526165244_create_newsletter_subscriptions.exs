defmodule Nano.Repo.Migrations.CreateNewsletterSubscriptions do
  use Ecto.Migration

  def change do
    create table(:newsletter_subscriptions) do
      add :email, :string, null: false
      add :unsubscribed, :boolean, default: false, null: false
      timestamps()
    end

    create unique_index(:newsletter_subscriptions, [:email])
  end
end
