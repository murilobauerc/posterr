defmodule PosterrBack.Entities.Reposts do
  @moduledoc """
  Represents the Repost Entity
  """
  alias PosterrBack.Entities.Schemas.Repost

  alias PosterrBack.Repo

  @doc """
  Creates a new repost
  """
  @spec create(attrs :: map()) :: {:ok, Repost.t()} | {:error, Ecto.Changeset.t()}
  def create(attrs) do
    %Repost{}
    |> Repost.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Get a repost by its user id and post id
  """
  @spec get_by(user_id :: integer, post_id :: integer) :: Repost.t() | nil
  def get_by(user_id, post_id) do
    Repo.get_by(Repost, user_id: user_id, post_id: post_id)
  end
end
