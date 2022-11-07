defmodule Noncegeek.Repo do
  use Ecto.Repo,
    otp_app: :noncegeek,
    adapter: Ecto.Adapters.Postgres
end
