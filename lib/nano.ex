defmodule Nano do
  @moduledoc """
  Nano keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """
  @app :nano

  @doc """
  Get environment variable for given application.
  """
  @spec env(atom(), term()) :: term()
  def env(key, default \\ nil) do
    Application.get_env(@app, key, default)
  end
end
