defmodule NanoWeb.PageController do
  use NanoWeb, :controller

  alias Nano.ChatRooms
  alias Nano.Services.StripeService
  alias Nano.Accounts
  alias Nano.Newsletter
  alias Nano.Newsletter.SubscriptionForm
  alias Nano.Schemas.Support

  def home(conn, _params) do
    render(conn, :home)
  end

  def contacts(conn, _params) do
    form_data = Support.new(%{name: "", email: "", subject: "", message: ""})
    render(conn, :contacts, submit_msg: nil, form: form_data)
  end

  @spec contacts_submit(
          Plug.Conn.t(),
          :invalid | %{optional(:__struct__) => none(), optional(atom() | binary()) => any()}
        ) :: Plug.Conn.t()
  def contacts_submit(conn, params) do
    changeset = Support.changeset(params["support"])
    IO.inspect(changeset)

    if changeset.valid? do
      _ = Nano.Email.support_request(changeset.changes)
      msg = "Paldies! Esam saņēmuši Tavu ziņu! Sniegsim Tev atbildi cik vien ātri iespējams!"
      render(conn, :contacts, submit_msg: msg, form: nil)
    else
      render(conn, :contacts, submit_msg: nil, form: changeset)
    end
  end

  def elements(conn, _params) do
    render(conn, :elements)
  end

  def subscribe(conn, _params) do
    plan = Application.get_env(:nano, :subscription_plan)
    render(conn, :subscribe, plan: plan)
  end

  def checkout(conn, %{"plan" => plan_key}) do
    plan = Application.get_env(:nano, :subscription_plan)
    plan_id = String.to_existing_atom(plan_key)

    if Map.get(plan, :id) == plan_id do
      case StripeService.create_checkout_session(%{user: conn.assigns.current_user, plan: plan}) do
        {:ok, checkout_url} ->
          conn
          |> redirect(external: checkout_url)

        {:error, _reason} ->
          conn
          |> put_flash(:error, "Failed to create checkout session. Please try again later.")
          |> redirect(to: ~p"/subscribe")
      end
    else
      conn
      |> put_flash(:error, "Invalid subscription plan")
      |> redirect(to: ~p"/subscribe")
    end
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
                conn
                |> put_flash(:success, "Veiksmīgi pierakstījies")
                |> redirect(to: ~p"/rooms")

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

  def cancel(conn, _params) do
    render(conn, :cancel)
  end

  def news_subscription_page(conn, _params) do
    form = %SubscriptionForm{}
    changeset = SubscriptionForm.changeset(form)
    render(conn, :subscription_page, form: Phoenix.Component.to_form(changeset))
  end

  def handle_news_subscription(conn, %{"subscription_form" => params}) do
    form = %SubscriptionForm{}
    changeset = SubscriptionForm.changeset(form, params)

    case Ecto.Changeset.apply_action(changeset, :insert) do
      {:ok, %{email: email, unsubscribe: unsubscribe}} ->
        case Newsletter.handle_subscription(email, unsubscribe) do
          :ok ->
            message =
              if unsubscribe,
                do: "Successfully unsubscribed from our newsletter.",
                else: "Thank you for subscribing to our newsletter!"

            conn
            |> put_flash(:info, message)
            |> redirect(to: ~p"/")

          {:error, _changeset} ->
            conn
            |> put_flash(:error, "Something went wrong. Please try again later.")
            |> render(:subscription_page, form: Phoenix.Component.to_form(changeset))
        end

      {:error, _changeset} ->
        conn
        |> render(:subscription_page, form: Phoenix.Component.to_form(changeset))
    end
  end
end
