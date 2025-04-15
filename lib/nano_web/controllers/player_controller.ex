defmodule NanoWeb.PlayerController do
  use NanoWeb, :controller

  def room(conn, %{room: room_id} = _params) do
    video_room = Nano.ChatRooms.get_room!(room_id)
    render(conn, :show, %{video_room: video_room})
  end
end
