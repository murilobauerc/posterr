defmodule PosterrBackWeb.PostControllerTest do
  use PosterrBackWeb.ConnCase
  import PosterrBack.Factory

  describe "POST /api/posts" do
    test "returns success when creates a post", %{conn: conn} do
      user = insert!(:user, %{username: "John"})

      conn =
        post(conn, Routes.post_path(conn, :create), %{
          content: "This is a new post",
          user_id: user.id
        })

      response = json_response(conn, 201)

      assert %{
               "data" => %{
                 "content" => "This is a new post",
                 "username" => "John",
                 "id" => response["data"]["id"],
                 "inserted_at" => response["data"]["inserted_at"]
               }
             } == response
    end

    test "returns error when user has already created 5 posts", %{conn: conn} do
      user = insert!(:user, %{username: "John"})

      Enum.each(1..5, fn _ ->
        insert!(:post, %{content: "Post content", user_id: user.id})
      end)

      conn =
        post(conn, Routes.post_path(conn, :create), %{
          content: "This is a new post",
          user_id: user.id
        })

      response = json_response(conn, 422)

      assert %{
               "error" => "post_daily_limit_exceeded"
             } == response
    end
  end

  describe "GET /api/posts" do
    test "returns success when retrieves all posts", %{conn: conn} do
      user = insert!(:user, %{username: "John"})
      post = insert!(:post, %{content: "Post content", user_id: user.id})

      conn = get(conn, Routes.post_path(conn, :index))

      response = json_response(conn, 200)

      assert %{
               "data" => [
                 %{
                   "content" => post.content,
                   "username" => user.username,
                   "id" => post.id,
                   "reposts" => [],
                   "inserted_at" => NaiveDateTime.to_iso8601(post.inserted_at)
                 }
               ]
             } == response
    end

    test "returns success when retrieves all posts with reposts", %{conn: conn} do
      user = insert!(:user, %{username: "John"})
      post = insert!(:post, %{content: "Post content", user_id: user.id})
      repost = insert!(:repost, %{post_id: post.id, user_id: user.id})

      conn = get(conn, Routes.post_path(conn, :index))

      response = json_response(conn, 200)

      assert %{
               "data" => [
                 %{
                   "content" => post.content,
                   "username" => user.username,
                   "id" => post.id,
                   "reposts" => [
                     %{
                       "username" => user.username,
                       "content" => post.content,
                       "id" => repost.id,
                       "inserted_at" => NaiveDateTime.to_iso8601(repost.inserted_at)
                     }
                   ],
                   "inserted_at" => NaiveDateTime.to_iso8601(post.inserted_at)
                 }
               ]
             } == response
    end

    test "success when retrieves all posts with sort_type", %{conn: conn} do
      user = insert!(:user, %{username: "John"})
      post = insert!(:post, %{content: "Post content", user_id: user.id})
      repost = insert!(:repost, %{post_id: post.id, user_id: user.id})

      conn =
        get(conn, Routes.post_path(conn, :index), %{
          "page" => "1",
          "limit" => "10",
          "sort_type" => "latest"
        })

      response = json_response(conn, 200)

      assert %{
               "data" => [
                 %{
                   "content" => post.content,
                   "username" => user.username,
                   "id" => post.id,
                   "inserted_at" => NaiveDateTime.to_iso8601(post.inserted_at),
                   "reposts" => [
                     %{
                       "content" => post.content,
                       "id" => repost.id,
                       "inserted_at" => NaiveDateTime.to_iso8601(repost.inserted_at),
                       "username" => user.username
                     }
                   ]
                 }
               ]
             } == response
    end

    test "success when retrieves all posts with keyword and sort_type", %{conn: conn} do
      user = insert!(:user, %{username: "John"})
      post = insert!(:post, %{content: "Post content", user_id: user.id})
      repost = insert!(:repost, %{post_id: post.id, user_id: user.id})

      conn =
        get(conn, Routes.post_path(conn, :index), %{
          "page" => "1",
          "limit" => "10",
          "keyword" => "Post content",
          "sort_type" => "latest"
        })

      response = json_response(conn, 200)

      assert %{
               "data" => [
                 %{
                   "content" => post.content,
                   "username" => user.username,
                   "id" => post.id,
                   "inserted_at" => NaiveDateTime.to_iso8601(post.inserted_at),
                   "reposts" => [
                     %{
                       "content" => post.content,
                       "id" => repost.id,
                       "inserted_at" => NaiveDateTime.to_iso8601(repost.inserted_at),
                       "username" => user.username
                     }
                   ]
                 }
               ]
             } == response
    end

    test "errors when post not found", %{conn: conn} do
      conn = get(conn, Routes.post_path(conn, :index))

      response = json_response(conn, 200)

      assert %{
               "data" => []
             } == response
    end
  end
end
