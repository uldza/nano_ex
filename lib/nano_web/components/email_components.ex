defmodule NanoWeb.EmailComponents do
  @moduledoc """
  A set of html components for use in html email templates.
  See templates/email/template.html.heex for examples on what you can add to emails.
  """

  use Phoenix.Component

  slot(:inner_block)

  def h1(assigns) do
    ~H"""
    <h1>
      {render_slot(@inner_block)}
    </h1>
    """
  end
end
