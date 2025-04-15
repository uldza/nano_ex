defmodule NanoWeb.PageController do
  use NanoWeb, :controller

  alias Nano.ChatRooms

  def home(conn, _params) do
    rooms = ChatRooms.list_rooms()
    render(conn, :home, rooms: rooms)
  end
end
