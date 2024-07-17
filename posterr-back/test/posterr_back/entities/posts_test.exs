defmodule PosterrBack.Entities.PostsTest do
  use PosterrBack.DataCase
  alias PosterrBack.Entities.Posts
  import PosterrBack.Factory

  describe "Post entity" do
    test "creates a new post" do
      user = insert!(:user, %{username: "John"})
      post = insert!(:post, %{content: "This is a new post", user_id: user.id})
      assert post.content == "This is a new post"
      assert post.user_id == user.id
    end

    test "lists posts with reposts successfully" do
      user = insert!(:user, %{username: "John"})
      post = insert!(:post, %{content: "This is a new post", user_id: user.id})
      _repost = insert!(:repost, %{post_id: post.id, user_id: user.id})
      posts = Posts.list_posts_with_reposts(1, 5)

      assert length(posts) == 1
      assert length(Enum.at(posts, 0).reposts) == 1
      assert Enum.at(posts, 0).content == "This is a new post"
    end

    test "counts user posts and reposts for a day successfully" do
      user = insert!(:user, %{username: "John"})
      post = insert!(:post, %{content: "This is a new post", user_id: user.id})
      _repost = insert!(:repost, %{post_id: post.id, user_id: user.id})

      count = Posts.count_user_posts_and_reposts_for_a_day(user.id, Date.utc_today())

      assert count == 2
    end

    test "lists posts with filter by keyword and pagination successfully" do
      user = insert!(:user, %{username: "John"})
      post = insert!(:post, %{content: "This is a new post", user_id: user.id})

      assert length(Posts.list_posts_with_filters("This is a new post", 1, 5)) == 1
      assert post.content == "This is a new post"
    end

    test "lists posts sorted by latest successfully" do
      user = insert!(:user, %{username: "John"})
      first_post = insert!(:post, %{content: "First post", user_id: user.id})
      _second_post = insert!(:post, %{content: "Second post", user_id: user.id})
      posts = Posts.list_posts_sorted("latest", 1, 5)

      assert length(posts) == 2
      assert Enum.at(posts, 0).inserted_at >= Enum.at(posts, 1).inserted_at
      assert first_post.content == "First post"
    end

    test "lists posts sorted by trending successfully" do
      user = insert!(:user, %{username: "John"})
      first_post = insert!(:post, %{content: "First post", user_id: user.id})
      _second_post = insert!(:post, %{content: "Second post", user_id: user.id})
      posts = Posts.list_posts_sorted("trending", 1, 5)

      assert first_post == Enum.at(posts, 0)
      assert length(posts) == 2
      assert Enum.at(posts, 0).content == "First post"
      assert Enum.at(posts, 1).content == "Second post"
      assert Enum.at(posts, 0).inserted_at >= Enum.at(posts, 1).inserted_at
    end
  end
end
