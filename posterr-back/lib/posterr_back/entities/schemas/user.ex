defmodule PosterrBack.Entities.Schemas.User do
  @moduledoc """
    Represents the User schema
  """
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, except: [:__meta__]}
  schema "users" do
    field :username, :string
    timestamps()
  end

  @mandatory_fields [:username]

  def changeset(user, attrs) do
    user
    |> cast(attrs, @mandatory_fields)
    |> validate_required(@mandatory_fields)
    |> validate_format(:username, ~r/^[a-zA-Z0-9]*$/)
    |> unique_constraint(:username)
  end
end
