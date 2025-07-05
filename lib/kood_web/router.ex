defmodule KoodWeb.Router do
  use KoodWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {KoodWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/", KoodWeb do
    pipe_through :browser

    get "/", PageController, :home
    get "/hls/:client/hero.m3u8", PageController, :hls
    get "/hls/:client/:quality/playlist", PageController, :hls_playlist
    get "/hls/:client/:quality/:segment", PageController, :hls_segment
  end
end
