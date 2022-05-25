defmodule HVS.Repo do
  use Ecto.Repo,
    otp_app: :hvs,
    adapter: Ecto.Adapters.Postgres
end
