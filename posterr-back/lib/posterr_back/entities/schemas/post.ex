defmodule PosterrBack.Entities.Schemas.Post do
  @moduledoc """
    Represents the Post schema
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias PosterrBack.Entities.Schemas.User
  alias PosterrBack.Entities.Schemas.Repost

  @derive {Jason.Encoder, only: [:id, :content, :user_id, :inserted_at, :updated_at]}
  schema "posts" do
    field :content, :string

    belongs_to :user, User
    has_many :reposts, Repost, foreign_key: :post_id

    timestamps()
  end

  @mandatory_fields [:content, :user_id]

  def changeset(post, attrs) do
    post
    |> cast(attrs, @mandatory_fields)
    |> validate_required(@mandatory_fields)
    |> validate_length(:content, max: 777)
  end
end
