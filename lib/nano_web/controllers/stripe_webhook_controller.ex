defmodule NanoWeb.StripeWebhookController do
  use NanoWeb, :controller

  alias Nano.Services.StripeService

  @doc """
  Handles incoming Stripe webhook events.
  """
  def webhook(conn, _params) do
    # Verify the webhook signature
    case verify_webhook_signature(conn) do
      {:ok, event} ->
        case StripeService.handle_successful_payment(event) do
          :ok ->
            send_resp(conn, 200, "")

          {:error, reason} ->
            IO.puts("Failed to handle Stripe webhook: #{inspect(reason)}")
            send_resp(conn, 400, "")
        end

      {:error, reason} ->
        IO.puts("Invalid Stripe webhook signature: #{inspect(reason)}")
        send_resp(conn, 400, "")
    end
  end

  # Private functions

  defp verify_webhook_signature(conn) do
    signature = get_req_header(conn, "stripe-signature")
    payload = conn.body_params

    case Stripe.Webhook.construct_event(payload, signature, webhook_secret()) do
      {:ok, event} -> {:ok, event}
      {:error, reason} -> {:error, reason}
    end
  end

  defp webhook_secret do
    Application.get_env(:stripity_stripe, :webhook_secret)
  end
end
