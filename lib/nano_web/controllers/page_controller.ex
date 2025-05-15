defmodule NanoWeb.PageController do
  use NanoWeb, :controller

  alias Nano.ChatRooms
  alias Nano.Services.StripeService
  alias Nano.Accounts

  def home(conn, _params) do
    rooms = ChatRooms.list_rooms()
    render(conn, :home, rooms: rooms)
  end

  def elements(conn, _params) do
    render(conn, :elements)
  end

  def subscribe(conn, _params) do
    plans = Application.get_env(:nano, :subscription_plans)
    render(conn, :subscribe, plans: plans)
  end

  def success(conn, _params) do
    user = conn.assigns.current_user

    # Get subscription from database
    case Accounts.get_user_subscription(user) do
      nil ->
        # For new subscriptions, fetch the latest checkout session
        case StripeService.list_checkout_sessions(%{customer: user.stripe_customer_id, limit: 1}) do
          {:ok, %{data: [session | _]}} ->
            # Handle the checkout completion
            case StripeService.handle_checkout_completed(session) do
              :ok ->
                # Get rooms based on subscription status
                rooms = ChatRooms.list_rooms()
                render(conn, :success, rooms: rooms)

              {:error, _reason} ->
                conn
                |> put_flash(:error, "Failed to process subscription")
                |> redirect(to: ~p"/subscribe")
            end

          {:ok, %{data: []}} ->
            conn
            |> put_flash(:error, "No active subscription found")
            |> redirect(to: ~p"/subscribe")

          {:error, _reason} ->
            conn
            |> put_flash(:error, "Failed to verify subscription status")
            |> redirect(to: ~p"/subscribe")
        end

      subscription ->
        # Verify subscription status with Stripe
        case StripeService.retrieve_subscription(subscription.stripe_subscription_id) do
          {:ok, stripe_subscription} ->
            # Update subscription status if needed
            StripeService.handle_subscription_updated(stripe_subscription)

            # Get rooms based on subscription status
            rooms = ChatRooms.list_rooms()
            render(conn, :success, rooms: rooms)

          {:error, _reason} ->
            conn
            |> put_flash(:error, "Failed to verify subscription status")
            |> redirect(to: ~p"/subscribe")
        end
    end
  end

  def checkout(conn, %{"plan" => plan_key}) do
    plans = Application.get_env(:nano, :subscription_plans)
    plan_id = String.to_existing_atom(plan_key)

    case Keyword.get(plans, plan_id) do
      nil ->
        conn
        |> put_flash(:error, "Invalid subscription plan")
        |> redirect(to: ~p"/subscribe")

      plan ->
        case StripeService.create_checkout_session(%{user: conn.assigns.current_user, plan: plan}) do
          {:ok, checkout_url} ->
            conn
            |> redirect(external: checkout_url)

          {:error, :invalid_plan} ->
            conn
            |> put_flash(:error, "Invalid subscription plan")
            |> redirect(to: ~p"/subscribe")

          {:error, _reason} ->
            conn
            |> put_flash(:error, "Failed to create checkout session. Please try again later.")
            |> redirect(to: ~p"/subscribe")
        end
    end
  end
end
