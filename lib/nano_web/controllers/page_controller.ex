defmodule NanoWeb.PageController do
  use NanoWeb, :controller

  alias Nano.ChatRooms
  alias Nano.Services.StripeService

  def home(conn, _params) do
    rooms = ChatRooms.list_rooms()
    render(conn, :home, rooms: rooms)
  end

  def subscribe(conn, _params) do
    plans = Application.get_env(:nano, :subscription_plans)
    render(conn, :subscribe, plans: plans)
  end

  def success(conn, _params) do

    rooms = ChatRooms.list_rooms()
    render(conn, :success, rooms: rooms)
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
