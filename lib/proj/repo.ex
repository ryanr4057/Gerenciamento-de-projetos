defmodule Proj.Repo do
  use Ecto.Repo,
    otp_app: :proj,
    adapter: Ecto.Adapters.SQLite3
end
