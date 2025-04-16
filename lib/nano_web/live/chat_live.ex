defmodule NanoWeb.ChatLive do
  use NanoWeb, :live_view
  alias Nano.ChatRooms

  def mount(_, %{"room_id" => room_id}, socket) do
    if connected?(socket) do
      ChatRooms.subscribe_to_room(room_id)
    end

    room = ChatRooms.get_room!(room_id)
    messages = ChatRooms.get_messages_for_room(room_id)

    {:ok,
     assign(socket,
       room: room,
       messages: messages,
       message: ""
     )}
  end

  def handle_event("send_message", %{"message" => message}, socket) do
    if message != "" do
      ChatRooms.create_message(%{
        content: message,
        room_id: socket.assigns.room.id,
        user_id: socket.assigns.current_user.id
      })
    end

    {:noreply, assign(socket, message: "")}
  end

  def handle_info({:message_created, message}, socket) do
    {:noreply, update(socket, :messages, &(&1 ++ [message]))}
  end
end
