defmodule NanoWeb.AdminController do
  use NanoWeb, :controller

  alias Nano.Accounts

  def dashboard(conn, _params) do
    users = Accounts.list_users()
    render(conn, :dashboard, users: users)
  end
end
