defmodule PosterrBack.Entities.Schemas.Repost do
  @moduledoc """
    Represents the Repost schema
  """
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, except: [:__meta__]}
  schema "reposts" do
    field :post_id, :integer
    field :user_id, :integer
    timestamps()
  end

  @mandatory_fields [:post_id, :user_id]

  def changeset(repost, attrs) do
    repost
    |> cast(attrs, @mandatory_fields)
    |> validate_required(@mandatory_fields)
  end
end
