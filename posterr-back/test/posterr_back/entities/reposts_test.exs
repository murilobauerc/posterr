defmodule PosterrBack.Entities.RepostsTest do
  use PosterrBack.DataCase
  alias PosterrBack.Entities.{Posts, Reposts}
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

    test "trending posts are sorted by descending repost count" do
      user = insert!(:user, %{username: "John"})
      second_user = insert!(:user, %{username: "Delle"})

      post = insert!(:post, %{content: "First post", user_id: user.id})

      second_post =
        insert!(:post, %{content: "Post with just one repost comes by last :( ", user_id: user.id})

      _repost = insert!(:repost, %{post_id: post.id, user_id: user.id})
      _second_repost = insert!(:repost, %{post_id: post.id, user_id: second_user.id})
      _third_repost = insert!(:repost, %{post_id: second_post.id, user_id: user.id})

      posts = Posts.list_posts_sorted("trending", 1, 5)
      assert Enum.at(posts, 0).content == "First post"
      assert Enum.at(posts, 1).content == "Post with just one repost comes by last :( "

      assert length(posts) == 2
    end
  end
end
