defmodule Nano.Schema do
  @moduledoc """
  Use this in every schema file.
  """

  defmacro __using__(_) do
    quote do
      use TypedEctoSchema
      import Ecto.Changeset, warn: false
    end
  end
end
