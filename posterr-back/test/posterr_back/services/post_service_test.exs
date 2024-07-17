defmodule PosterrBack.Services.PostServiceTest do
  use PosterrBack.DataCase
  import PosterrBack.Factory

  alias PosterrBack.Services.PostService
  alias PosterrBack.Services.RepostService

  describe "PostService.create_post" do
    test "returns success when creates a post" do
      user = insert!(:user, %{username: "John"})

      assert {:ok, post} =
               PostService.create_post(%{
                 "content" => "This is a new post",
                 "user_id" => user.id
               })

      assert post.username == "John"
      assert post.content == "This is a new post"
    end

    test "returns success when creates 5 posts" do
      user = insert!(:user, %{username: "John"})

      for _ <- 1..5 do
        assert {:ok, _post} =
                 PostService.create_post(%{
                   "content" => "This is a new post",
                   "user_id" => user.id
                 })
      end

      {:ok, posts} = PostService.list_posts(1, 5)
      assert length(posts) == 5
    end

    test "returns post_daily_limit_exceeded when user creates more than 5 posts" do
      user = insert!(:user, %{username: "John"})

      for _ <- 1..5 do
        assert {:ok, _post} =
                 PostService.create_post(%{
                   "content" => "This is a new post",
                   "user_id" => user.id
                 })
      end
    end

    test "returns post_already_reposted when create posts and repost same post twice" do
      user = insert!(:user, %{username: "John"})

      for _ <- 1..4 do
        assert {:ok, _post} =
                 PostService.create_post(%{
                   "content" => "This is a new post",
                   "user_id" => user.id
                 })
      end

      assert {:ok, post} =
               PostService.create_post(%{
                 "content" => "This is a new post",
                 "user_id" => user.id
               })

      assert {:ok, _repost} =
               RepostService.create_repost(%{
                 "post_id" => post.id,
                 "user_id" => user.id
               })

      assert {:error, :post_already_reposted} =
               RepostService.create_repost(%{
                 "post_id" => post.id,
                 "user_id" => user.id
               })
    end

    test "error when user does not exist" do
      assert {:error, :user_not_found} =
               PostService.create_post(%{
                 "content" => "This is a new post",
                 "user_id" => 0
               })
    end
  end
end
