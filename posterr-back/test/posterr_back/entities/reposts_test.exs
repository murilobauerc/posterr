defmodule PosterrBack.Entities.RepostsTest do
  use PosterrBack.DataCase
  alias PosterrBack.Entities.Reposts
  import PosterrBack.Factory

  describe "Repost entity" do
    test "creates a new repost" do
      user = insert!(:user, %{username: "John"})
      post = insert!(:post, %{content: "This is a new post", user_id: user.id})
      repost = insert!(:repost, %{post_id: post.id, user_id: user.id})

      assert repost.post_id == post.id
      assert repost.user_id == user.id
    end

    test "gets a repost by its user id and post id" do
      user = insert!(:user, %{username: "John"})
      post = insert!(:post, %{content: "This is a new post", user_id: user.id})
      repost = insert!(:repost, %{post_id: post.id, user_id: user.id})

      assert Reposts.get_by(user.id, post.id) == repost
    end
  end
end
