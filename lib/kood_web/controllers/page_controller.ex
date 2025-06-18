defmodule KoodWeb.PageController do
  use KoodWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
