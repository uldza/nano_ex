defmodule NanoWeb.PlayerController do
  use NanoWeb, :controller

  def show(conn, %{"room_id" => room_id} = _params) do
    video_room = Nano.ChatRooms.get_room!(room_id)
    messages = Nano.ChatRooms.get_messages_for_room(video_room.id)
    render(conn, :show, %{video_room: video_room, messages: messages})
  end
end
