defmodule NanoWeb.NanoComponents do
  @moduledoc """
  Provides core UI components for the web.
  """
  use Phoenix.Component
  import NanoWeb.CoreComponents

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

  @doc """
  Renders top navigations component.
  """
  attr :id, :string, required: true
  attr :menu, :list, default: []
  attr :active_path, :string, default: "/"
  attr :cta, :map
  slot :inner_block, required: false

  def navbar(assigns) do
    ~H"""
    <nav id={@id} class="navbar relative w-full flex flex-wrap items-center mx-auto">
      <div class="navbar-start flex-1">
        <a href="/" class="font-bold text-xl">
          {render_slot(@inner_block)}
        </a>
      </div>
      <div class="navbar-center hidden md:flex flex-shrink-0">
        <ul class="flex items-center gap-4">
          <li :for={menu_item <- @menu} class="">
            <%= if @active_path == menu_item.href do %>
              <.link href={menu_item.href} method={menu_item[:method]} class="theme-btn active">
                {menu_item.name}
              </.link>
            <% else %>
              <.link href={menu_item.href} method={menu_item[:method]} class="theme-btn">
                {menu_item.name}
              </.link>
            <% end %>
          </li>
        </ul>
      </div>
      <%= if @cta do %>
        <div class="navbar-cta-wrap flex flex-shrink-0 pl-4">
          <.user_link name={@cta[:name]} icon={@cta[:icon]} link={@cta[:link]} />
        </div>
      <% end %>
      <div class="dropdown md:hidden absolute top-20 right-0">
        <div id="dropdown-button" tabindex="0" role="button" phx-hook="OpenHide" data-el="dropdown">
          <svg
            xmlns="http://www.w3.org/2000/svg"
            class="h-5 w-5"
            fill="none"
            viewBox="0 0 24 24"
            stroke="currentColor"
          >
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M4 6h16M4 12h8m-8 6h16"
            />
          </svg>
        </div>
      </div>
      <ul
        id="dropdown"
        tabindex="0"
        class="hidden absolute top-20 mt-5 left-0 menu menu-sm dropdown-content z-50 rounded-box w-full mt-3 w-52 p-2 shadow"
      >
        <li :for={menu_item <- @menu}>
          <%= if @active_path == menu_item.href do %>
            <a href={menu_item.href} class="active theme-link">{menu_item.name}</a>
          <% else %>
            <a href={menu_item.href} class="theme-link">{menu_item.name}</a>
          <% end %>
        </li>
      </ul>
    </nav>
    """
  end

  attr :name, :string, default: nil
  attr :link, :string, required: true
  attr :icon, :string

  def user_link(assigns) do
    if assigns.name do
      ~H"""
      <.link class="theme-cta-btn text-xs md:text-base" href={@link}>
        {@name}
      </.link>
      """
    else
      ~H"""
      <.link class="blue-light text-blue-dark rounded-full" href={@link}>
        <.icon name={"hero-" <> @icon} class="w-8 h-8" />
      </.link>
      """
    end
  end
end
