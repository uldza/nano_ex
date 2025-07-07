defmodule Nano.Email do
  @moduledoc """
  Houses functions that generate Swoosh email structs.
  An Swoosh email struct can be delivered by a Swoosh mailer (see mailer.ex). Eg:

      Nano.Email.confirm_register_email(user.email, url)
      |> Nano.Mailer.deliver()
  """

  use Phoenix.Swoosh,
    view: NanoWeb.EmailView,
    layout: {NanoWeb.EmailView, :layout}

  @spec support_request(map()) :: {:error, any()} | {:ok, Swoosh.Email.t()}
  def support_request(req) when is_map(req) do
    to_email = Application.fetch_env!(:nano, :support_email)

    base_email()
    |> to(to_email)
    |> subject("Atbalsta ziņa no WEB")
    |> render_body("support_req.html", req)
    |> premail()
    |> deliver()
  end

  defp base_email() do
    from(new(), {from_name(), from_email()})
  end

  defp premail(email) do
    html = Premailex.to_inline_css(email.html_body)
    text = Premailex.to_text(email.html_body)

    email
    |> html_body(html)
    |> text_body(text)
  end

  defp from_name do
    Application.fetch_env!(:nano, :mailer_default_from_name)
  end

  defp from_email do
    Application.fetch_env!(:nano, :mailer_default_from_email)
  end

  defp deliver(email) do
    with {:ok, _metadata} <- Nano.Mailer.deliver(email) do
      # Returning the email helps with testing
      {:ok, email}
    end
  end
end
