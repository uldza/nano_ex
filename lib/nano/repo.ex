defmodule Nano.Repo do
  use Ecto.Repo,
    otp_app: :nano,
    adapter: Ecto.Adapters.SQLite3
end
