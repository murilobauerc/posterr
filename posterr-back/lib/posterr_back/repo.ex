defmodule PosterrBack.Repo do
  use Ecto.Repo,
    otp_app: :posterr_back,
    adapter: Ecto.Adapters.Postgres
end
