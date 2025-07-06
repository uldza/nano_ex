defmodule NanoWeb.HtmlComponents do
  def deco_class(:primary, %{request_path: "/"}), do: "blue-normal"
  def deco_class(:secondary, %{request_path: "/"}), do: "blue-dark"
  def deco_class(_, %{request_path: "/rooms" <> _}), do: "hidden"
  def deco_class(_, %{request_path: "/admin" <> _}), do: "hidden"
  # Default decorative classes
  def deco_class(:primary, _), do: "yellow-normal"
  def deco_class(:secondary, _), do: "yellow-light-active"

  def cta_link(%{assigns: %{current_user: nil}}), do: "/users/register"

  def cta_link(%{assigns: %{subscription_status: status}})
      when status == "active" or status == "trialing",
      do: "/rooms"

  def cta_link(%{assigns: %{subscription_status: _}}), do: "/subscribe"
end
