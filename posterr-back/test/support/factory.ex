defmodule PosterrBack.Factory do
  alias PosterrBack.Entities.Schemas.{Post, User, Repost}
  alias PosterrBack.Repo

  def insert!(:post, attrs) do
    %Post{}
    |> Post.changeset(attrs)
    |> Repo.insert!()
  end

  def insert!(:user, attrs) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert!()
  end

  def insert!(:repost, attrs) do
    %Repost{}
    |> Repost.changeset(attrs)
    |> Repo.insert!()
  end
end
