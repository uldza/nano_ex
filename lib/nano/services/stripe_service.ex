defmodule Nano.Services.StripeService do
  @moduledoc """
  Service module for handling Stripe-related operations.
  """

  alias Nano.Accounts.User
  alias Nano.Accounts.Subscription

  def create_customer(params) do
    Stripe.Customer.create(params)
  end

  def retrieve_customer(customer_id) do
    Stripe.Customer.retrieve(customer_id)
  end

  def create_portal_session(params) do
    Stripe.BillingPortal.Session.create(params)
  end

  def create_checkout_session(%{user: %User{} = user, plan: plan}) do
    {:ok, %Stripe.Customer{id: customer_id}} =
      create_customer(%{email: user.email, metadata: %{"user_id" => user.id}})

    # Update user with stripe customer id
    changeset = User.customer_changeset(user, %{stripe_customer_id: customer_id})
    {:ok, _user} = Nano.Repo.update(changeset)

    session_params = %{
      customer: customer_id,
      client_reference_id: user.id,
      success_url: success_url(),
      cancel_url: cancel_url(),
      mode: "subscription",
      allow_promotion_codes: false,
      line_items: [
        %{
          price: plan.stripe_price_id,
          quantity: 1
        }
      ],
      metadata: %{
        "user_id" => user.id,
        "plan_id" => plan.id,
        "stripe_product_id" => plan.stripe_product_id,
        "stripe_price_id" => plan.stripe_price_id
      },
      automatic_tax: %{enabled: true},
      customer_update: %{address: :auto},
      subscription_data: %{
        trial_period_days: Map.get(plan, :trial_days)
      }
    }

    case Stripe.Checkout.Session.create(session_params) do
      {:ok, %{url: url}} -> {:ok, url}
      {:error, error} -> {:error, error}
    end
  end

  def retrieve_product(stripe_product_id) do
    Stripe.Product.retrieve(stripe_product_id)
  end

  def list_subscriptions(params) do
    Stripe.Subscription.list(params)
  end

  def retrieve_subscription(provider_subscription_id) do
    Stripe.Subscription.retrieve(provider_subscription_id)
  end

  def list_checkout_sessions(params) do
    Stripe.Checkout.Session.list(params)
  end

  def cancel_subscription(subscription) do
    changeset =
      Subscription.changeset(subscription, %{
        status: "canceled",
        cancel_at_period_end: true
      })

    with {:ok, subscription} <- Nano.Repo.update(changeset),
         {:ok, data} <-
           Stripe.Subscription.update(subscription.stripe_subscription_id, %{
             cancel_at_period_end: true
           }) do
      IO.inspect(data)
      :ok
    else
      {:error, err} ->
        IO.inspect(err)
        {:error, :failed_to_cancel_subscription}
    end
  end

  @doc """
  Handles a successful subscription payment webhook.

  ## Parameters
    - event: The Stripe event containing the subscription details

  ## Returns
    - :ok - If the subscription was successfully created/updated
    - {:error, reason} - If there was an error processing the subscription
  """
  def handle_successful_payment(event) do
    case event.type do
      "checkout.session.completed" ->
        handle_checkout_completed(event.data.object)

      "customer.subscription.updated" ->
        handle_subscription_updated(event.data.object)

      "customer.subscription.deleted" ->
        handle_subscription_deleted(event.data.object)

      _ ->
        :ok
    end
  end

  def handle_checkout_completed(session) do
    user_id = String.to_integer(session.metadata["user_id"])
    plan_key = String.to_existing_atom(session.metadata["plan_id"])

    subscription_params = %{
      stripe_subscription_id: session.subscription,
      stripe_customer_id: session.customer,
      user_id: user_id,
      plan_id: plan_key,
      status: "active",
      current_period_start: DateTime.utc_now(),
      current_period_end: DateTime.utc_now() |> DateTime.add(30, :day),
      cancel_at_period_end: false
    }

    case Nano.Repo.insert(Subscription.changeset(%Subscription{}, subscription_params)) do
      {:ok, _subscription} ->
        :ok

      {:error, changeset} ->
        require IEx
        IEx.pry()
        {:error, :failed_to_create_subscription}
    end
  end

  def handle_subscription_updated(subscription) do
    case Nano.Repo.get_by(Subscription, stripe_subscription_id: subscription.id) do
      nil -> {:error, :subscription_not_found}
      sub -> update_subscription_status(sub, subscription)
    end
  end

  # Private functions

  defp handle_subscription_deleted(subscription) do
    case Nano.Repo.get_by(Subscription, stripe_subscription_id: subscription.id) do
      nil -> {:error, :subscription_not_found}
      sub -> cancel_subscription(sub)
    end
  end

  defp update_subscription_status(subscription, stripe_subscription) do
    changeset =
      Subscription.changeset(subscription, %{
        status: stripe_subscription.status,
        current_period_start: DateTime.from_unix!(stripe_subscription.current_period_start),
        current_period_end: DateTime.from_unix!(stripe_subscription.current_period_end),
        cancel_at_period_end: stripe_subscription.cancel_at_period_end
      })

    case Nano.Repo.update(changeset) do
      {:ok, _subscription} -> :ok
      {:error, _changeset} -> {:error, :failed_to_update_subscription}
    end
  end

  defp success_url do
    proto = Application.get_env(:nano, NanoWeb.Endpoint)[:url][:scheme]
    base_url = Application.get_env(:nano, NanoWeb.Endpoint)[:url][:host]
    port = Application.get_env(:nano, NanoWeb.Endpoint)[:url][:port]
    "#{proto}://#{base_url}:#{port}/subscribe/success"
  end

  defp cancel_url do
    proto = Application.get_env(:nano, NanoWeb.Endpoint)[:url][:scheme]
    base_url = Application.get_env(:nano, NanoWeb.Endpoint)[:url][:host]
    port = Application.get_env(:nano, NanoWeb.Endpoint)[:url][:port]
    "#{proto}://#{base_url}:#{port}/subscribe"
  end
end
