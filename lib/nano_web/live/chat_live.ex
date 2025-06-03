defmodule NanoWeb.ChatLive do
  use NanoWeb, :live_view
  alias Nano.ChatRooms
  alias NanoWeb.UserAuth

  def mount(_, %{"room_id" => room_id, "user_token" => _user_token} = session, socket) do
    # Mount the current user from the session
    socket = UserAuth.mount_current_user(socket, session)

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
        type: "text",
        chat_room_id: socket.assigns.room.id,
        user_id: socket.assigns.current_user.id
      })
    end

    {:noreply, assign(socket, message: "")}
  end

  def handle_event("send_emoji", %{"emoji" => emoji}, socket) do
    ChatRooms.create_message(%{
      content: emoji,
      type: "emoji",
      chat_room_id: socket.assigns.room.id,
      user_id: socket.assigns.current_user.id
    })

    {:noreply, socket}
  end

  def handle_info({:message_created, message}, socket) do
    {:noreply, stream_insert(socket, :messages, message, at: 0)}
  end
end
