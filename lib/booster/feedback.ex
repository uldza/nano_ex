defmodule Booster.Feedback do
  @moduledoc """
  A module, that allows to create feedback forms dynamically from
  predefined textual JSON data structure.

  Can be used to create subscription forms and others where user feedback is needed.
  """

  require Logger

  @ets :feedback

  @doc """
  Setups feedback cache and populates it.
  """
  @spec setup(list()) :: :ok | :error
  def setup(files) do
    # Create ETS when it doesn't exist
    if :ets.info(@ets) == :undefined do
      @ets = :ets.new(@ets, [:named_table, :public, read_concurrency: true])
    end

    objects =
      files
      |> Enum.map(&read_file/1)

    :ets.delete_all_objects(@ets)
    true = :ets.insert(@ets, objects)
    :ok
  end

  @doc """
  Get saved feedback models from ETS table identified by its id.
  """
  @spec get(binary() | atom()) :: {:ok, map()} | {:error, :not_found}
  def get(id) do
    case :ets.lookup(@ets, id) do
      [] -> {:error, :not_found}
      [{^id, data}] -> {:ok, data}
    end
  end

  defp read_file(file_path) do
    {:ok, json} = File.read(file_path)
    {:ok, %{id: id} = data} = Jason.decode(json, keys: :atoms)
    {String.to_atom(id), data}
  end
end
