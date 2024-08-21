defmodule PosterrBackWeb.Router do
  use PosterrBackWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", PosterrBackWeb do
    pipe_through :api

    get "/posts", PostController, :index
    post "/post", PostController, :create

    post "/repost", RepostController, :create
  end
end
