defmodule PosterrBack.Services.RepostServiceTest do
  use PosterrBack.DataCase
  import PosterrBack.Factory

  alias PosterrBack.Services.RepostService
  alias PosterrBack.Services.PostService

  describe "RepostService.create_repost" do
    test "returns success when creates a repost" do
      user = insert!(:user, %{username: "John"})
      post = insert!(:post, %{content: "This is a new post", user_id: user.id})

      assert {:ok, repost} =
               RepostService.create_repost(%{
                 "post_id" => post.id,
                 "user_id" => user.id
               })

      assert repost.post_id == post.id
      assert repost.user_id == user.id
    end

    test "returns success when user reposts a post" do
      user = insert!(:user, %{username: "John"})
      post = insert!(:post, %{content: "This is a new post", user_id: user.id})

      assert {:ok, _repost} =
               RepostService.create_repost(%{
                 "post_id" => post.id,
                 "user_id" => user.id
               })

      {:ok, reposts} = PostService.list_posts(1, 5)
      assert length(reposts) == 1
    end

    test "returns success when different users repost 4 times a same post from another user" do
      first_user = insert!(:user, %{username: "John"})
      second_user = insert!(:user, %{username: "Jane"})
      third_user = insert!(:user, %{username: "Jack"})
      four_user = insert!(:user, %{username: "Jill"})
      five_user = insert!(:user, %{username: "Jenny"})

      post = insert!(:post, %{content: "This is a new post", user_id: first_user.id})

      assert {:ok, _repost} =
               RepostService.create_repost(%{
                 "post_id" => post.id,
                 "user_id" => second_user.id
               })

      assert {:ok, _repost} =
               RepostService.create_repost(%{
                 "post_id" => post.id,
                 "user_id" => third_user.id
               })

      assert {:ok, _repost} =
               RepostService.create_repost(%{
                 "post_id" => post.id,
                 "user_id" => four_user.id
               })

      assert {:ok, _repost} =
               RepostService.create_repost(%{
                 "post_id" => post.id,
                 "user_id" => five_user.id
               })

      {:ok, reposts} = PostService.list_posts(1, 5)
      assert length(reposts) == 1
    end

    test "returns :post_already_reposted when same user tries to repost twice" do
      user = insert!(:user, %{username: "John"})
      post = insert!(:post, %{content: "This is a new post", user_id: user.id})

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
  end
end
