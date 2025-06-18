defmodule KoodWeb.ErrorJSON do
  @doc """
  Renders changeset errors.
  """
  def error(%{changeset: changeset}) do
    # When encoded, the changeset returns its errors
    # as a JSON object. So we just pass it forward.
    %{errors: Ecto.Changeset.traverse_errors(changeset, &translate_error/1)}
  end

  def error(%{message: message}) do
    # If you pass a string message, we render it as the error.
    %{error: message}
  end

  @doc """
  Translates changeset errors.
  """
  def translate_error({msg, opts}) do
    # You can make use of gettext to put error messages in
    # the application domain. However, we typically don't
    # pass the app name in the error, so we just need to
    # call gettext with the default domain.
    #
    # Ecto will pass the :count option if the error message
    # contains a count. In this case, we need to ensure
    # the message is pluralized correctly.
    if count = opts[:count] do
      Gettext.dngettext(KoodWeb.Gettext, "errors", msg, msg, count, opts)
    else
      Gettext.dgettext(KoodWeb.Gettext, "errors", msg, opts)
    end
  end
end
