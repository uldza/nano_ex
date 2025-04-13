defmodule NanoWeb.Layouts do
  @moduledoc """
  This module holds different layouts used by your application.
  """
  use NanoWeb, :html

  embed_templates "layouts/*"

  def title(%{assigns: %{page_title: title}}), do: title
  def title(%{assigns: _}), do: ""
  def page_title(%{assigns: %{page_title: title}}), do: title
  def page_title(_), do: "Get this title set"
  def description(%{assigns: %{page_descr: description}}), do: description
  def description(%{assigns: _}), do: ""
  def keywords(%{assigns: %{page_keywords: keywords}}), do: keywords
  def keywords(%{assigns: _}), do: ""

  def og_description(conn), do: description(conn)

  def og_url(%{assigns: assigns}) do
    "#{Nano.env(:domain, "example.com")}#{Map.get(assigns, :active_path, "/")}"
  end

  def og_img(%{assigns: assigns}), do: Map.get(assigns, :page_image)

  def tw_description(conn), do: description(conn)
  def tw_img(%{assigns: assigns}), do: Map.get(assigns, :page_image)
  def tw_card(%{assigns: assigns}), do: Map.get(assigns, :page_image)

  def theme(%{assigns: %{theme: theme}}), do: theme
  def theme(_), do: "default"
end
