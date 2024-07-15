defmodule PosterrBack.Services.RepostService do
  alias PosterrBack.Entities.Reposts
  alias PosterrBack.Entities.Schemas.Repost

  @doc """
  Handles the reposting of a post by a user, ensuring the repost hasn't already been made by the same user.
  """
  @spec create_repost(map()) :: {:ok, Repost.t()} | {:error, any()}
  def create_repost(%{"user_id" => user_id, "post_id" => post_id} = _params) do
    case Reposts.get_by(user_id, post_id) do
      nil ->
        case Reposts.create(%{user_id: user_id, post_id: post_id}) do
          {:ok, repost} -> {:ok, repost}
          {:error, changeset} -> {:error, changeset}
        end

      _repost -> {:error, :post_already_reposted}
    end
  end
end
