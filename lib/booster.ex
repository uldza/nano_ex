defmodule Booster do
  @moduledoc """
  Booster keeps the contexts that define it's domain logic.
  """

  @doc """
  Get a random numeric string of given length.
  """
  @spec random_string(length :: non_neg_integer()) :: binary()
  def random_string(length \\ 10) do
    length
    |> :crypto.strong_rand_bytes()
    |> :crypto.bytes_to_integer()
    |> Integer.to_string()
    |> binary_part(0, length)
  end
end
