defmodule BsShitbot.Repo do
  use Ecto.Repo,
    otp_app: :bs_shitbot,
    adapter: Ecto.Adapters.Postgres
end
