defmodule PosterrBackWeb.RepostController do
  use PosterrBackWeb, :controller
  alias PosterrBack.Services.RepostService

  @doc """
  Handles the creation of a repost.
  """
  def create(conn, params) do
    case RepostService.create_repost(params) do
      {:ok, repost} ->
        conn
        |> put_status(:created)
        |> json(%{data: repost})

      {:error, :post_already_reposted} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: :post_already_reposted})
    end
  end
end
