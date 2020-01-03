defmodule Twitterclone.Repo do
  use Ecto.Repo,
    otp_app: :twitterclone,
    adapter: Ecto.Adapters.Postgres
end
