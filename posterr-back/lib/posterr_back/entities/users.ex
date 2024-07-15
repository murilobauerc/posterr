defmodule PosterrBack.Entities.Users do
  @moduledoc """
  Represents the User Entity
  """
  alias PosterrBack.Entities.Schemas.User

  alias PosterrBack.Repo

  @doc """
  Creates a new user
  """
  @spec create(attrs :: map()) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def create(attrs) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Get the username of a user
  """
  @spec get_username(integer) :: {:ok, charlist()} | {:error, atom()}
  def get_username(user_id) do
    case Repo.get(User, user_id) do
      nil -> {:error, :user_not_found}
      user -> {:ok, user.username}
    end
  end
end
