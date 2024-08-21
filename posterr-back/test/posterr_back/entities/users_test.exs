defmodule PosterrBack.Entities.UsersTest do
  use PosterrBack.DataCase
  alias PosterrBack.Entities.Users
  import PosterrBack.Factory

  describe "User entity" do
    test "creates a new user" do
      user = insert!(:user, %{username: "John"})
      assert user.username == "John"
    end

    test "gets the username of a user" do
      user = insert!(:user, %{username: "John"})
      assert Users.get_username(user.id) == {:ok, "John"}
    end

    test "fails if the user does not exist" do
      assert Users.get_username(0) == {:error, :user_not_found}
    end
  end
end
