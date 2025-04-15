defmodule NanoWeb.PlayerHTML do
  @moduledoc """
  This module contains pages rendered by PlayerController.
  """
  use NanoWeb, :html

  embed_templates "player_html/*"
end
