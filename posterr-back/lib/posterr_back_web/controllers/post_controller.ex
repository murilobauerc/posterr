defmodule PosterrBackWeb.PostController do
  use PosterrBackWeb, :controller
  require Logger

  alias PosterrBack.Services.PostService
  alias PosterrBack.Entities.Users
  alias PosterrBack.Entities.Schemas.Post

  @doc """
  Handles the creation of a post.
  """
  def create(conn, params) do
    Logger.info("Creating a post with params: #{inspect(params)}")

    case PostService.create_post(params) do
      {:ok, post} ->
        conn
        |> put_status(:created)
        |> json(%{data: post})

      {:error, :post_daily_limit_exceeded} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: :post_daily_limit_exceeded})
    end
  end

  @doc """
  Handles the listing of posts.
  """
  def index(conn, %{"keyword" => keyword, "sort_type" => sort_type} = params) do
    Logger.info("Filtering and sorting posts with keyword: #{keyword} and sort: #{sort_type}")
    filtered_sorted_posts(conn, keyword, sort_type, params["page"], params["limit"])
  end

  def index(conn, %{"sort_type" => sort_type} = params) do
    Logger.info("Sorting posts with sort type: #{sort_type}")
    list_posts_with_sort(conn, sort_type, params["page"], params["limit"])
  end

  def index(conn, %{"keyword" => keyword} = params) do
    Logger.info("Filtering posts with keyword: #{keyword}")
    filtered_posts(conn, keyword, params["page"], params["limit"])
  end

  def index(conn, %{"page" => page, "limit" => limit}) do
    list_posts_with_pagination(conn, page, limit)
  end

  def index(conn, _params) do
    default_page = Application.get_env(:posterr_back, :default_page_number, 1)
    default_limit = Application.get_env(:posterr_back, :default_page_size, 15)
    list_posts_with_pagination(conn, default_page, default_limit)
  end

  defp filtered_sorted_posts(conn, keyword, sort_type, page, limit) do
    posts =
      PostService.list_posts_with_filters(
        keyword,
        sort_type,
        String.to_integer(page),
        String.to_integer(limit)
      )

    render_posts(conn, posts)
  end

  defp list_posts_with_sort(conn, sort_type, page, limit) do
    posts =
      PostService.list_posts_sorted(sort_type, String.to_integer(page), String.to_integer(limit))

    render_posts(conn, posts)
  end

  defp filtered_posts(conn, keyword, page, limit) when is_integer(page) and is_integer(limit) do
    posts = PostService.list_posts_with_filters(keyword, page, limit)
    render_posts(conn, posts)
  end

  defp filtered_posts(conn, keyword, page, limit) do
    page_number = String.to_integer(page)
    page_size = String.to_integer(limit)
    posts = PostService.list_posts_with_filters(keyword, page_number, page_size)
    render_posts(conn, posts)
  end

  defp list_posts_with_pagination(conn, page, limit)
       when is_integer(page) and is_integer(limit) do
    posts = PostService.list_posts(page, limit)
    render_posts(conn, posts)
  end

  defp list_posts_with_pagination(conn, page, limit) do
    page_number = String.to_integer(page)
    page_size = String.to_integer(limit)
    posts = PostService.list_posts(page_number, page_size)
    render_posts(conn, posts)
  end

  defp render_posts(conn, {:ok, posts}) do
    posts = Enum.map(posts, &format_post/1)
    json(conn, %{data: posts})
  end

  defp format_post(%Post{
         id: id,
         user_id: user_id,
         content: content,
         reposts: reposts,
         inserted_at: inserted_at
       }) do
    Logger.info("Formatting post with id: #{id}")

    {:ok, username} = Users.get_username(user_id)

    reposts_data = format_reposts(reposts, username, content)

    %{
      id: id,
      content: content,
      username: username,
      inserted_at: inserted_at,
      reposts: reposts_data
    }
  end

  defp format_reposts(reposts, username, content) when not is_nil(reposts),
    do: Enum.map(reposts, fn repost -> format_single_repost(repost, username, content) end)

  defp format_reposts(_, _, _), do: []

  defp format_single_repost(repost, username, content) do
    %{
      id: repost.id,
      username: username,
      content: content,
      inserted_at: repost.inserted_at
    }
  end
end
