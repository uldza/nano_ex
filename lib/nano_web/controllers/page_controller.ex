defmodule NanoWeb.PageController do
  use NanoWeb, :controller

  alias Nano.ChatRooms
  alias Nano.Accounts

  def home(conn, _params) do
    rooms = ChatRooms.list_rooms()
    render(conn, :home, rooms: rooms)
  end

  def subscribe(conn, _params) do
    plans = Application.get_env(:nano, :subscription_plans)
    render(conn, :subscribe, plans: plans)
  end

  def checkout(conn, %{"plan" => plan_key}) do
    plans = Application.get_env(:nano, :subscription_plans)

    case Keyword.get(plans, String.to_existing_atom(plan_key)) do
      nil ->
        conn
        |> put_flash(:error, "Invalid subscription plan")
        |> redirect(to: ~p"/subscribe")

      plan ->
        # Here you would typically:
        # 1. Create a Stripe checkout session
        # 2. Redirect to Stripe checkout
        # 3. Handle the webhook for successful payment

        # For now, we'll just show a message
        conn
        |> put_flash(:info, "Redirecting to payment for #{plan.name}...")
        |> redirect(to: ~p"/subscribe")
    end
  end
end
