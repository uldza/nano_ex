defmodule Nano.Accounts.UserNotifier do
  import Swoosh.Email

  alias Nano.Mailer

  # Delivers the email using the application mailer.
  defp deliver(recipient, subject, body) do
    email =
      new()
      |> to(recipient)
      |> from({from_name(), from_email()})
      |> subject(subject)
      |> text_body(body)

    with {:ok, _metadata} <- Mailer.deliver(email) do
      {:ok, email}
    end
  end

  @doc """
  Deliver instructions to confirm account.
  """
  def deliver_confirmation_instructions(user, url) do
    deliver(user.email, "Apstiprini pikabu.lv reģistrāciju", """

    Sveiki #{user.email},

    Vari apstiprināt savu PIKABU kontu apmeklējot:

    #{url}

    Ja nepieprasīji reģistrāciju, ignorē šo e-pastu.

    """)
  end

  @doc """
  Deliver instructions to reset a user password.
  """
  def deliver_reset_password_instructions(user, url) do
    deliver(user.email, "Atjauno savu pikabu.lv paroli", """

    Sveiki #{user.email},

    Vari nomainīt savu paroli pikabu.lv apmeklējot:

    #{url}

    Ja nepieprasīji paroles atjaunošanu, ignorē šo e-pastu.

    """)
  end

  @doc """
  Deliver instructions to update a user email.
  """
  def deliver_update_email_instructions(user, url) do
    deliver(user.email, "Nomaini pikabu.lv reģistrācijas epastu", """

    Sveiki #{user.email},

    Vari nomainīt savu pikabu.lv epastu šeit:

    #{url}

    Ja nepieprasīji epasta nomaiņu, ignorē šo e-pastu.
    """)
  end

  defp from_name do
    Application.fetch_env!(:nano, :mailer_default_from_name)
  end

  defp from_email do
    Application.fetch_env!(:nano, :mailer_default_from_email)
  end
end
