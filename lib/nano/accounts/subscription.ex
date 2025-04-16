defmodule Nano.Accounts.Subscription do
  use Ecto.Schema
  import Ecto.Changeset

  alias Nano.Accounts.User

  schema "subscriptions" do
    field :stripe_subscription_id, :string
    field :stripe_customer_id, :string
    field :status, :string
    field :current_period_start, :utc_datetime
    field :current_period_end, :utc_datetime
    field :cancel_at_period_end, :boolean, default: false

    belongs_to :user, User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(subscription, attrs) do
    subscription
    |> cast(attrs, [
      :stripe_subscription_id,
      :stripe_customer_id,
      :status,
      :current_period_start,
      :current_period_end,
      :cancel_at_period_end,
      :user_id
    ])
    |> validate_required([
      :stripe_subscription_id,
      :stripe_customer_id,
      :status,
      :current_period_start,
      :current_period_end,
      :user_id
    ])
    |> validate_inclusion(:status, [
      "active",
      "canceled",
      "incomplete",
      "incomplete_expired",
      "past_due",
      "trialing",
      "unpaid"
    ])
    |> unique_constraint(:stripe_subscription_id)
    |> unique_constraint(:stripe_customer_id)
    |> foreign_key_constraint(:user_id)
  end
end
