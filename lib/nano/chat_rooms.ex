defmodule Nano.ChatRooms do
  alias Nano.ChatRooms.Room
  alias Nano.Repo

  def get_room!(id) do
    Repo.get_by!(Room, id: id)
  end
end
