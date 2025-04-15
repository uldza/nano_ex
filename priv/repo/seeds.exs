# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Nano.Repo.insert!(%Nano.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Nano.ChatRooms

# Create sample video rooms
video_rooms = [
  %{
    name: "Fun Adventure Time",
    description: "Join us for an exciting adventure video!",
    video_url: "https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8",
    video_thumbnail_url: "/images/adventure-time.png"
  },
  %{
    name: "Daily Comedy Show",
    description: "Laugh out loud with our daily comedy show!",
    video_url: "https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8",
    video_thumbnail_url: "/images/adventure-time.png",
    requires_subscription: true
  }
]

# Insert video rooms
Enum.each(video_rooms, fn room_attrs ->
  case ChatRooms.create_room(room_attrs) do
    {:ok, _room} -> :ok
    {:error, changeset} -> IO.puts("Error creating room: #{inspect(changeset.errors)}")
  end
end)

IO.puts("Successfully seeded video rooms!")
