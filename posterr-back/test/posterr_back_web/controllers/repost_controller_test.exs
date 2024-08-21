defmodule PosterrBackWeb.RepostControllerTest do
  use PosterrBackWeb.ConnCase
  import PosterrBack.Factory

  describe "POST /api/reposts" do
    test "returns success when creates a repost", %{conn: conn} do
      user = insert!(:user, %{username: "John"})
      post = insert!(:post, %{content: "Post content", user_id: user.id})

      conn =
        post(conn, Routes.repost_path(conn, :create), %{
          post_id: post.id,
          user_id: user.id
        })

      response = json_response(conn, 201)

      assert %{
               "data" => %{
                 "post_id" => post.id,
                 "id" => response["data"]["id"],
                 "user_id" => user.id,
                 "inserted_at" => response["data"]["inserted_at"],
                 "updated_at" => response["data"]["updated_at"]
               }
             } == response
    end

    test "fails when user has already reposted the post", %{conn: conn} do
      user = insert!(:user, %{username: "John"})
      post = insert!(:post, %{content: "Post content", user_id: user.id})
      insert!(:repost, %{post_id: post.id, user_id: user.id})

      conn =
        post(conn, Routes.repost_path(conn, :create), %{
          post_id: post.id,
          user_id: user.id
        })

      response = json_response(conn, 422)

      assert %{
               "error" => "post_already_reposted"
             } == response
    end
  end
end
