defmodule PosterrBack.Entities.Posts do
  @moduledoc """
  Represents the Post Entity
  """
  import Ecto.Query
  alias PosterrBack.Entities.Schemas.Post
  alias PosterrBack.Entities.Schemas.Repost
  alias PosterrBack.Repo

  @doc """
  Creates a new post
  """
  @spec create(attrs :: map(), user_id :: integer) ::
          {:ok, Post.t()} | {:error, Ecto.Changeset.t()}
  def create(attrs, user_id) do
    %Post{user_id: user_id}
    |> Post.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Lists all posts with pagination.
  """
  @spec list_posts_with_reposts(integer, integer) :: [Post.t()]
  def list_posts_with_reposts(page_number, page_size)
      when is_integer(page_number) and is_integer(page_size) do
    from(p in Post,
      left_join: r in assoc(p, :reposts),
      preload: [:user, reposts: r],
      order_by: [desc: p.inserted_at],
      offset: ^((page_number - 1) * page_size),
      limit: ^page_size
    )
    |> Repo.all()
  end

  @doc """
  Counts the number of posts and reposts made by a user on a given day.
  """
  @spec count_user_posts_and_reposts_for_a_day(integer, Date.t()) :: integer
  def count_user_posts_and_reposts_for_a_day(user_id, date) do
    {:ok, start_of_day} = NaiveDateTime.new(date, ~T[00:00:00])
    {:ok, end_of_day} = NaiveDateTime.new(date, ~T[23:59:59])

    post_count =
      Repo.aggregate(
        from(p in Post,
          where: p.user_id == ^user_id,
          where: p.inserted_at >= ^start_of_day,
          where: p.inserted_at <= ^end_of_day,
          select: count(p.id)
        ),
        :count
      )

    repost_count =
      Repo.aggregate(
        from(r in Repost,
          where: r.user_id == ^user_id,
          where: r.inserted_at >= ^start_of_day,
          where: r.inserted_at <= ^end_of_day,
          select: count(r.id)
        ),
        :count
      )

    post_count + repost_count
  end

  @doc """
  Lists all posts with filter by keyword and pagination.
  """
  @spec list_posts_with_filters(String.t(), integer, integer) :: [Post.t()]
  def list_posts_with_filters(keyword, page_number, page_size) do
    query =
      from(p in Post,
        preload: [:reposts],
        where: p.content == ^keyword,
        order_by: [desc: p.inserted_at],
        offset: ^((page_number - 1) * page_size),
        limit: ^page_size
      )

    Repo.all(query)
  end

  def list_posts_with_filters(keyword, _sort_type, page_number, page_size) do
    query =
      from(p in Post,
        preload: [:reposts],
        join: r in assoc(p, :reposts),
        where: p.content == ^keyword,
        group_by: p.id,
        order_by: [desc: count(r.id)],
        offset: ^((page_number - 1) * page_size),
        limit: ^page_size
      )

    Repo.all(query)
  end

  @doc """
  Lists all posts with pagination based on the sorting type.
  """
  @spec list_posts_sorted(String.t(), integer, integer) :: [Post.t()]
  def list_posts_sorted("latest", page_number, page_size),
    do: list_posts_with_reposts(page_number, page_size)

  @spec list_posts_sorted(String.t(), integer, integer) :: [Post.t()]
  def list_posts_sorted("trending", page_number, page_size) do
    from(p in Post,
      left_join: r in assoc(p, :reposts),
      group_by: p.id,
      order_by: [desc: count(r.id)],
      preload: [:user, :reposts],
      offset: ^((page_number - 1) * page_size),
      limit: ^page_size
    )
    |> Repo.all()
  end

  def list_posts_sorted(_, _, _), do: {:ok, []}
end
