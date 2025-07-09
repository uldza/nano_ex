defmodule NanoWeb.ContentPlug do
  @moduledoc """
  Define needed variables for the content here.
  """
  use NanoWeb, :verified_routes

  import Plug.Conn

  def main_menu(conn, _opts) do
    user = conn.assigns[:current_user]

    path = conn.request_path

    {menus, cta} =
      if user do
        user_cta = %{
          link: ~p"/users/settings",
          icon: "hero-user-circle"
        }

        video = %{href: ~p"/rooms", name: "Video"}
        admin = if user.role == "admin", do: %{href: ~p"/admin", name: "Admin"}
        logout = %{href: ~p"/users/log_out", name: "Iziet", method: "delete"}
        menu = Enum.reject([video, admin, logout], &is_nil/1)

        {menu, user_cta}
      else
        pub_cta = %{
          link: ~p"/users/register",
          name: "Reģistrējies"
        }

        login = %{href: ~p"/users/log_in", name: "Ienākt"}

        {[login], pub_cta}
      end

    conn
    |> assign(:main_menu, menus)
    |> assign(:active_path, path)
    |> assign(:page_cta, cta)
  end
end
