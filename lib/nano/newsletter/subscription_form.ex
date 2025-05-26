defmodule Nano.Newsletter.SubscriptionForm do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :email, :string
    field :unsubscribe, :boolean, default: false
  end

  def changeset(form, attrs \\ %{}) do
    form
    |> cast(attrs, [:email, :unsubscribe])
    |> validate_required([:email])
    |> validate_format(:email, ~r/^[^\s@]+@[^\s@]+\.[^\s@]+$/)
  end
end
