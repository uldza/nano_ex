defmodule KoodWeb.PageController do
  use KoodWeb, :controller

  def home(conn, _params) do
    client_id = Booster.random_string(12)
    render(conn, :home, client_id: client_id)
  end

  def hls(conn, %{"client" => client}) do
    # Serve master playlist
    master_playlist = generate_master_playlist(client)

    conn
    |> put_resp_content_type("application/vnd.apple.mpegurl")
    |> send_resp(200, master_playlist)
  end

  def hls_playlist(conn, %{"client" => client, "quality" => quality}) do
    # Serve media playlist for specific quality
    media_playlist = generate_media_playlist(client, quality)

    conn
    |> put_resp_content_type("application/vnd.apple.mpegurl")
    |> send_resp(200, media_playlist)
  end

  def hls_segment(conn, %{"client" => client, "quality" => quality, "segment" => segment}) do
    # Serve video/audio segment
    segment_data = get_segment_data(client, quality, segment)

    conn
    |> put_resp_content_type("video/mp2t")
    |> send_resp(200, segment_data)
  end

  # Generate master playlist with different quality options
  defp generate_master_playlist(client) do
    """
    #EXTM3U
    #EXT-X-VERSION:3
    #EXT-X-STREAM-INF:BANDWIDTH=1280000,RESOLUTION=720x480
    /hls/#{client}/720p/playlist.m3u8
    #EXT-X-STREAM-INF:BANDWIDTH=800000,RESOLUTION=480x360
    /hls/#{client}/480p/playlist.m3u8
    #EXT-X-STREAM-INF:BANDWIDTH=400000,RESOLUTION=360x240
    /hls/#{client}/360p/playlist.m3u8
    """
  end

  # Generate media playlist for specific quality
  defp generate_media_playlist(client, quality) do
    segments = get_available_segments(client, quality)

    playlist = """
    #EXTM3U
    #EXT-X-VERSION:3
    #EXT-X-TARGETDURATION:1
    #EXT-X-MEDIA-SEQUENCE:0
    """

    segments_entries = segments
    |> Enum.map(fn segment ->
      "#EXTINF:1.0,\n/hls/#{client}/#{quality}/#{segment}.ts"
    end)
    |> Enum.join("\n")

    playlist <> segments_entries <> "\n#EXT-X-ENDLIST"
  end

  # Get available segments for a client/quality combination
  defp get_available_segments(client, quality) do
    # This would typically query your storage/database
    # For now, returning a simple range
    case {client, quality} do
      {"demo", "720p"} -> 0..5
      {"demo", "480p"} -> 0..5
      {"demo", "360p"} -> 0..5
      _ -> 0..2
    end
  end

  # Get actual segment data
  defp get_segment_data(client, quality, segment) do
    # This would typically read from file system or storage
    # For now, returning placeholder data
    "Segment #{segment} for #{client} at #{quality} quality"
  end
end
