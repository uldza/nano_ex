defmodule Nano.Newsletter do
  @moduledoc """
  Context module for handling newsletter subscriptions.
  """

  import Ecto.Query, warn: false
  alias Nano.Repo

  defmodule Subscription do
    use Ecto.Schema
    import Ecto.Changeset

    schema "newsletter_subscriptions" do
      field :email, :string
      field :unsubscribed, :boolean, default: false
      timestamps()
    end

    def changeset(subscription, attrs) do
      subscription
      |> cast(attrs, [:email, :unsubscribed])
      |> validate_required([:email])
      |> validate_format(:email, ~r/^[^\s@]+@[^\s@]+\.[^\s@]+$/)
      |> unique_constraint(:email)
    end
  end

  @doc """
  Handles newsletter subscription or unsubscription for a given email.
  Returns `:ok` on success or `{:error, reason}` on failure.
  """
  def handle_subscription(email, unsubscribe \\ false) do
    attrs = %{email: email, unsubscribed: unsubscribe}

    case Repo.get_by(Subscription, email: email) do
      nil ->
        %Subscription{}
        |> Subscription.changeset(attrs)
        |> Repo.insert()
        |> case do
          {:ok, _} -> :ok
          {:error, changeset} -> {:error, changeset}
        end

      subscription ->
        subscription
        |> Subscription.changeset(attrs)
        |> Repo.update()
        |> case do
          {:ok, _} -> :ok
          {:error, changeset} -> {:error, changeset}
        end
    end
  end
end
