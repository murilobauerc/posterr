defmodule PosterrBack.Services.PostService do
  alias PosterrBack.Entities.{Posts, Users}
  alias PosterrBack.Entities.Schemas.Post
  require Logger

  @doc """
  Public interface to create a post, ensuring the user hasn't exceeded the daily limit.
  """
  @spec create_post(map()) :: {:ok, Post.t()} | {:error, any()}
  def create_post(%{"user_id" => user_id} = params) do
    with {:ok, count} <- count_user_posts_and_reposts_for_a_day(user_id),
         {:ok, username} <- Users.get_username(user_id),
         true <- count < 5,
         {:ok, post} <- Posts.create(params, user_id) do
      {:ok, build_post_response(post, username)}
    else
      {:error, _} = error -> error
      false -> {:error, :post_daily_limit_exceeded}
    end
  end

  @doc """
  Public interface to list posts with default pagination.
  """
  @spec list_posts(integer, integer) :: {:ok, [Post.t()]} | {:error, any()}
  def list_posts(page_number, page_size) do
    {:ok, Posts.list_posts_with_reposts(page_number, page_size)}
  end

  @doc """
  Public interface to list posts with pagination.
  """
  def list_posts_sorted(sort_type, page_number, page_size) do
    {:ok, Posts.list_posts_sorted(sort_type, page_number, page_size)}
  end

  def list_posts_with_filters(keyword, page_number, page_size) do
    Logger.info("Keyword: #{keyword}")

    {:ok, Posts.list_posts_with_filters(keyword, page_number, page_size)}
  end

  def list_posts_with_filters(keyword, sort_type, page_number, page_size) do
    {:ok, Posts.list_posts_with_filters(keyword, sort_type, page_number, page_size)}
  end

  defp count_user_posts_and_reposts_for_a_day(user_id) do
    {:ok, Posts.count_user_posts_and_reposts_for_a_day(user_id, Date.utc_today())}
  end

  defp build_post_response(post, username) do
    %{
      id: post.id,
      username: username,
      content: post.content,
      inserted_at: post.inserted_at
    }
  end
end
